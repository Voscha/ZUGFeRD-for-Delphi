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
  InvoiceProvider, System.DateUtils, XML.XMLDoc, intf.ZUGFeRDVersion;

type
  [TestFixture]
  TXRechnungUBLTests = class(TTestBase)
  private
    FInvoiceProvider: TInvoiceProvider;
    FVersion: TZUGFeRDVersion;
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
    [Test]
    procedure TestAllowanceChargeOnDocumentLevel();
    [Test]
    procedure TestTaxTypes();
  end;

implementation

uses Winapi.ActiveX, intf.ZUGFeRDProfile, intf.ZUGFeRDFormats,
  intf.ZUGFeRDInvoiceDescriptor, intf.ZUGFeRDApplicableProductCharacteristic, intf.ZUGFeRDTaxTypes,
  intf.ZUGFeRDTaxCategoryCodes, intf.ZUGFeRDHelper, intf.ZUGFeRDTax,
  intf.ZUGFeRDAdditionalReferencedDocumentTypeCodes, intf.ZUGFeRDReferenceTypeCodes,
  intf.ZUGFeRDAdditionalReferencedDocument, intf.ZUGFeRDCurrencyCodes;

{ TXRechnungUBLTests }

procedure TXRechnungUBLTests.Setup;
begin
  CoInitialize(nil);
  FInvoiceProvider := TInvoiceProvider.create;
  FVersion := TZUGFeRDVersion.Version23;
end;

procedure TXRechnungUBLTests.TearDown;
begin
  CoUninitialize;
  FInvoiceProvider.Free;
end;

procedure TXRechnungUBLTests.TestAllowanceChargeOnDocumentLevel;
begin
  var desc := FInvoiceProvider.CreateInvoice();

  // Test Values
  var isDiscount: Boolean := true;
  var basisAmount: ZUGFeRDNullable<Currency> := 123.45;
  var currencyCode: TZUGFeRDCurrencyCodes := TZUGFeRDCurrencyCodes.EUR;
  var actualAmount: Currency := 12.34;
  var reason: string := 'Gutschrift';
  var taxTypeCode: TZUGFeRDTaxTypes := TZUGFeRDTaxTypes.VAT;
  var taxCategoryCode: TZUGFeRDTaxCategoryCodes := TZUGFeRDTaxCategoryCodes.AA;
  var taxPercent:Currency := 19.0;

  desc.AddTradeAllowanceCharge(isDiscount, basisAmount, currencyCode, actualAmount, reason,
    taxTypeCode, taxCategoryCode, taxPercent);

  var testAllowanceCharge := desc.TradeAllowanceCharges.First();

  var ms := TMemoryStream.create();

  desc.Save(ms, FVersion, TZUGFeRDProfile.Extended, TZUGFeRDFormats.UBL);
  ms.Seek(0, soFromBeginning);
  desc.Free;

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  var loadedAllowanceCharge := loadedInvoice.TradeAllowanceCharges[0];

  Assert.AreEqual(loadedInvoice.TradeAllowanceCharges.Count, 1);
  Assert.AreEqual(loadedAllowanceCharge.ChargeIndicator, not isDiscount, 'isDiscount');
  Assert.AreEqual(loadedAllowanceCharge.BasisAmount.Value, basisAmount.Value, 'basisAmount');
  Assert.AreEqual(loadedAllowanceCharge.Currency, currencyCode, 'currency');
  Assert.AreEqual(loadedAllowanceCharge.Amount, actualAmount, 'actualAmount');
  Assert.AreEqual(loadedAllowanceCharge.Reason, reason, 'reason');
  Assert.AreEqual(loadedAllowanceCharge.Tax.TypeCode, taxTypeCode, 'taxTypeCode');
  Assert.AreEqual(loadedAllowanceCharge.Tax.CategoryCode, taxCategoryCode, 'taxCategoryCode');
  Assert.AreEqual(loadedAllowanceCharge.Tax.Percent, taxPercent, 'taxPercent');
  loadedInvoice.Free;

end; // !TestAllowanceChargeOnDocumentLevel

procedure TXRechnungUBLTests.TestInvoiceCreation;
begin
  var desc := FInvoiceProvider.CreateInvoice();

  var ms := TMemoryStream.Create;

  desc.Save(ms, FVersion, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  desc.Save('test.xml', FVersion, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
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
end; // !TestInvoiceCreation()

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
    desc.Save(ms, FVersion, TZUGFeRDProfile.Extended, TZUGFeRDFormats.UBL);


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
  desc.Save(ms, FVersion, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
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
end;

procedure TXRechnungUBLTests.TestTaxTypes;
var
  data: TBytes;
begin
  var desc := FInvoiceProvider.CreateInvoice();
  var ms := TMemoryStream.create();

  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  ms.Seek(0, soFromBeginning);
  desc.Free;

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);

  // test writing and parsing
  Assert.AreEqual(loadedInvoice.Taxes.Count, 2);
  Assert.IsTrue(TZUGFeRDHelper.TrueForAll<TZUGFeRDTax>(loadedInvoice.Taxes,
    function(Item: TZUGFerDTax): boolean
    begin
     result := Item.TypeCode = TZUGFerDTaxTypes.VAT;
    end));

  // test the raw xml file

  SetLength(data, ms.Size);
  ms.Position := 0;
  ms.ReadBuffer(data[0], ms.Size);
  var content: string := TEncoding.UTF8.GetString(data);
  ms.Free;

  Assert.IsFalse(content.ToUpper.Contains(string.UpperCase('<cbc:ID>VA</cbc:ID>')));
  Assert.IsTrue(content.ToUpper.Contains(string.UpperCase('<cbc:ID>VAT</cbc:ID>')));

  Assert.IsFalse(content.ToUpper.Contains(string.UpperCase('<cbc:ID>FC</cbc:ID>')));
  Assert.IsTrue(content.ToUpper.Contains(string.UpperCase('<cbc:ID>ID</cbc:ID>')));
  loadedInvoice.Free;
end;

procedure TXRechnungUBLTests.TestTradelineitemProductCharacterstics;
begin
  var desc := FInvoiceProvider.CreateInvoice();

  desc.TradeLineItems[0].ApplicableProductCharacteristics.Add(
    TZUGFeRDApplicableProductCharacteristic.CreateWithParams('Test Description', '1.5 kg'));
  desc.TradeLineItems[0].ApplicableProductCharacteristics.Add(
    TZUGFeRDApplicableProductCharacteristic.CreateWithParams('UBL Characterstics 2', '3 kg'));

  var ms := TMemoryStream.Create;

  desc.Save(ms, FVersion, TZUGFerDProfile.XRechnung, TZUGFeRDFormats.UBL);
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
