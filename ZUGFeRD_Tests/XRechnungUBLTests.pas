{* Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.}

unit XRechnungUBLTests;

interface

uses
  DUnitX.TestFramework,  System.Classes, System.SysUtils, System.Generics.Collections, TestBase,
  InvoiceProvider, System.DateUtils, XML.XMLDoc;

type
  [TestFixture]
  TXRechnungUBLTests = class(TTestBase)
  private
    FInvoiceProvider: TInvoiceProvider;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestInvoiceCreation;
    [Test]
    procedure TestTradelineitemProductCharacterstics;
    /// <summary>
    /// https://github.com/stephanstapel/ZUGFeRD-csharp/issues/319
    /// </summary>
    [Test]
    procedure TestSkippingOfAllowanceChargeBasisAmount;
    [Test]
    procedure TestInvoiceWithAttachment;
  end;

implementation

uses Winapi.ActiveX, intf.ZUGFeRDVersion, intf.ZUGFeRDProfile, intf.ZUGFeRDFormats,
  intf.ZUGFeRDInvoiceDescriptor, intf.ZUGFeRDApplicableProductCharacteristic, intf.ZUGFeRDTaxTypes,
  intf.ZUGFeRDTaxCategoryCodes, intf.ZUGFeRDHelper, intf.ZUGFeRDTax,
  intf.ZUGFeRDAdditionalReferencedDocumentTypeCodes, intf.ZUGFeRDReferenceTypeCodes,
  intf.ZUGFeRDAdditionalReferencedDocument;

{ TXRechnungUBLTests }

procedure TXRechnungUBLTests.Setup;
begin
  CoInitialize(nil);
  FInvoiceProvider := TInvoiceProvider.create;
end;

procedure TXRechnungUBLTests.TearDown;
begin
  CoUninitialize;
  FInvoiceProvider.Free;
end;

procedure TXRechnungUBLTests.TestInvoiceCreation;
begin
  var desc := FInvoiceProvider.CreateInvoice();

  var ms := TMemoryStream.Create;

  desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  desc.Save('test.xml', TZUGFeRDVersion.Version22, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  desc.Free;
  ms.Seek(0, soBeginning);

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.isNull(loadedInvoice.Invoicee);
  Assert.isNotNull(loadedInvoice.Seller);
  Assert.AreEqual(loadedInvoice.Taxes.Count, 2);
  Assert.AreEqual(loadedInvoice.SellerContact.Name, 'Max Mustermann');
  Assert.IsNull(loadedInvoice.BuyerContact);
  loadedInvoice.Free;
end;

procedure TXRechnungUBLTests.TestInvoiceWithAttachment;
var
  data: TBytes;
begin
  var desc := FInvoiceProvider.CreateInvoice;
  var filename := 'myrandomdata.bin';
  try
    SetLength(data, 32768);
    RandomizeByteArray(data);

    var msref1 := TMemoryStream.Create;
    msref1.WriteBuffer(data[0], Length(data));
    msref1.Position := 0;
    desc.AddAdditionalReferencedDocument(
              'My-File',
              TZUGFeRDAdditionalReferencedDocumentTypeCode.ReferenceDocument,
              nil,
              'Ausführbare Datei',
              TZUGFeRDReferenceTypeCodes.Unknown,
              msref1,
              filename
    );

    var ms := TMemoryStream.create;
    desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Extended, TZUGFeRDFormats.UBL);


    ms.Seek(0, soBeginning);

    var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
    ms.Free;

    Assert.AreEqual(loadedInvoice.AdditionalReferencedDocuments.Count, 1);

    for var document: TZUGFeRDAdditionalReferencedDocument in loadedInvoice.AdditionalReferencedDocuments do
    begin
      if (document.ID = 'My-File') then
      begin
        Assert.AreEqual(document.AttachmentBinaryObject, msref1);
        Assert.AreEqual(document.Filename, filename);
        break;
      end;
    end;
    loadedInvoice.Free;
  finally
    desc.Free;
  end;
end; // !TestInvoiceWithAttachment()

procedure TXRechnungUBLTests.TestSkippingOfAllowanceChargeBasisAmount;
begin

  // actual values do not matter
  var basisAmount: Currency := 123.0;
  var percent: Currency := 11.0;
  var allowanceChargeBasisAmount: ZUGFeRDNullable<Currency> := 121.0;

  var desc := FInvoiceProvider.CreateInvoice;
  desc.AddApplicableTradeTax(basisAmount, percent,
    TZUGFeRDTaxTypes.LOC, TZUGFeRDTaxCategoryCodes.K, allowanceChargeBasisAmount);

  var ms := TMemoryStream.create;
  desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  desc.Free;
  ms.Seek(0, soBeginning);

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  var tax := TZUGFeRDHelper.FindFirstMatchingItem<TZUGFeRDTax>(loadedInvoice.Taxes,
    function(Item:TZUGFeRDTax): Boolean
    begin
      result := Item.TypeCode = TZUGFeRDTaxTypes.LOC;
    end);

  Assert.IsNotNull(tax);
  Assert.AreEqual(basisAmount, tax.BasisAmount);
  Assert.AreEqual(percent, tax.Percent);
  Assert.isNull(tax.AllowanceChargeBasisAmount);
  loadedInvoice.Free;
end; // !TestInvoiceCreation()


procedure TXRechnungUBLTests.TestTradelineitemProductCharacterstics;
begin
  var desc := FInvoiceProvider.CreateInvoice();

  desc.TradeLineItems[0].ApplicableProductCharacteristics.Add(
    TZUGFeRDApplicableProductCharacteristic.CreateWithParams('Test Description', '1.5 kg'));
  desc.TradeLineItems[0].ApplicableProductCharacteristics.Add(
    TZUGFeRDApplicableProductCharacteristic.CreateWithParams('UBL Characterstics 2', '3 kg'));

  var ms := TMemoryStream.Create;

  desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFerDProfile.XRechnung, TZUGFeRDFormats.UBL);
  desc.Free;
  ms.Seek(0, soBeginning);

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.IsNotNull(loadedInvoice.TradeLineItems);
  Assert.AreEqual(loadedInvoice.TradeLineItems[0].ApplicableProductCharacteristics.Count, 2);
  Assert.AreEqual(loadedInvoice.TradeLineItems[0].ApplicableProductCharacteristics[0].Description,
    'Test Description');
  Assert.AreEqual(loadedInvoice.TradeLineItems[0].ApplicableProductCharacteristics[0].Value,
    '1.5 kg');

  Assert.AreEqual(loadedInvoice.TradeLineItems[0].ApplicableProductCharacteristics[1].Description,
    'UBL Characterstics 2');
  Assert.AreEqual(loadedInvoice.TradeLineItems[0].ApplicableProductCharacteristics[1].Value, '3 kg');
  loadedInvoice.Free;
end;

end.
