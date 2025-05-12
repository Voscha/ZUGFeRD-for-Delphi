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
    procedure TestParentLineId();
    [Test]
    procedure TestInvoiceCreation;
    [Test]
    procedure TestTradelineitemProductCharacterstics;
    [Test]
    procedure TestSpecialUnitCodes();
    [Test]
    procedure TestTradelineitemAdditionalDocuments();
    /// <summary>
    /// https://github.com/stephanstapel/ZUGFeRD-csharp/issues/319
    /// </summary>
    [Test]
    procedure TestSkippingOfAllowanceChargeBasisAmount;
    [Test]
    procedure TestAllowanceChargeOnDocumentLevel();
    [Test]
    procedure TestInvoiceWithAttachment;
    [Test]
    procedure TestActualDeliveryDateWithoutDeliveryAddress;
    [Test]
    procedure TestActualDeliveryDateWithDeliveryAddress;
    [Test]
    procedure TestActualDeliveryAddressWithoutDeliveryDate;
    [Test]
    procedure TestTaxTypes();
    /// <summary>
    /// We expect this format:
    ///   <cac:PaymentTerms>
    ///     <cbc:Note>
    ///       #SKONTO#TAGE#14#PROZENT=0.00#BASISBETRAG=123.45#
    ///     </cbc:Note>
    ///   </cac:PaymentTerms>
    /// </summary>
    [Test]
    procedure TestSingleSkontoForCorrectIndention;
    /// <summary>
    /// We expect this format:
    ///   <cac:PaymentTerms>
    ///     <cbc:Note>
    ///       #SKONTO#TAGE#14#PROZENT=5.00#BASISBETRAG=123.45#
    ///       #SKONTO#TAGE#21#PROZENT=1.00#BASISBETRAG=123.45#
    ///     </cbc:Note>
    ///   </cac:PaymentTerms>
    /// </summary>
    [Test]
    procedure TestMultiSkontoForCorrectIndention;
    [Test]
    procedure TestBuyerOrderReferenceLineId;
    [Test]
    procedure TestMultipleCreditorBankAccounts;
    [Test]
    procedure TestBuyerPartyIdwithoutGloablID;
    [Test]
    procedure TestPartyIdentificationForSeller;
    [Test]
    procedure TestPartyIdentificationShouldExistOneTime;
    [Test]
    procedure TestInDebitInvoiceTheFinancialAccountNameAndFinancialInstitutionBranchShouldNotExist;
    [Test]
    procedure TestInDebitInvoiceThePaymentMandateIdShouldExist;
    [Test]
    procedure TestInvoiceWithoutOrderReferenceShouldNotWriteEmptyOrderReferenceElement;
    [Test]
    procedure TestApplicableTradeTaxWithExemption;
    [Test]
    procedure TestNote;
    [Test]
    procedure TestDespatchDocumentReference;
    [Test]
    procedure TestSampleCreditNote326;
    [Test]
    procedure TestSampleCreditNote384;
    [Test]
    procedure TestReferenceXRechnung21UBL;
    [Test]
    procedure TestDecimals;
    [Test]
    procedure TestDesignatedProductClassificationWithFullClassification;
    /// <summary>
    /// UBL credit notes contain tag names different from invoices for the document, the trade line items and the billed quantity.
    /// </summary>
    [Test]
    procedure TestBasicCreditNote;
    /// <summary>
    /// UBL credit notes could have the tag "ns0"
    /// </summary>
    [Test]
    procedure TestCreditNoteTagNS0;
    /// <summary>
    /// Test DateTime format "yyyy-mm-dd+hh:mm" / "yyyy-MM-ddXXX"
    /// </summary>
    [Test]
    procedure TestNonStandardDateTimeFormat;
    [Test]
    procedure TestSellerPartyDescription;
  end;

implementation

uses Winapi.ActiveX, intf.ZUGFeRDProfile, intf.ZUGFeRDFormats,
  intf.ZUGFeRDInvoiceDescriptor, intf.ZUGFeRDApplicableProductCharacteristic, intf.ZUGFeRDTaxTypes,
  intf.ZUGFeRDTaxCategoryCodes, intf.ZUGFeRDHelper, intf.ZUGFeRDTax,
  intf.ZUGFeRDAdditionalReferencedDocumentTypeCodes, intf.ZUGFeRDReferenceTypeCodes,
  intf.ZUGFeRDAdditionalReferencedDocument, intf.ZUGFeRDCurrencyCodes,
  intf.ZUGFeRDQuantityCodes, intf.ZUGFeRDTradeLineItem;

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

procedure TXRechnungUBLTests.TestActualDeliveryAddressWithoutDeliveryDate;
begin

end;

procedure TXRechnungUBLTests.TestActualDeliveryDateWithDeliveryAddress;
begin

end;

procedure TXRechnungUBLTests.TestActualDeliveryDateWithoutDeliveryAddress;
begin

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
  Assert.AreEqual(loadedAllowanceCharge.Tax.CategoryCode.Value, taxCategoryCode, 'taxCategoryCode');
  Assert.AreEqual(loadedAllowanceCharge.Tax.Percent, taxPercent, 'taxPercent');
  loadedInvoice.Free;

end; procedure TXRechnungUBLTests.TestApplicableTradeTaxWithExemption;
begin

end;

procedure TXRechnungUBLTests.TestBasicCreditNote;
begin

end;

procedure TXRechnungUBLTests.TestBuyerOrderReferenceLineId;
begin

end;

procedure TXRechnungUBLTests.TestBuyerPartyIdwithoutGloablID;
begin

end;

procedure TXRechnungUBLTests.TestCreditNoteTagNS0;
begin

end;

procedure TXRechnungUBLTests.TestDecimals;
begin

end;

procedure TXRechnungUBLTests.TestDesignatedProductClassificationWithFullClassification;
begin

end;

procedure TXRechnungUBLTests.TestDespatchDocumentReference;
begin

end;

procedure TXRechnungUBLTests.TestInDebitInvoiceTheFinancialAccountNameAndFinancialInstitutionBranchShouldNotExist;
begin

end;

procedure TXRechnungUBLTests.TestInDebitInvoiceThePaymentMandateIdShouldExist;
begin

end;

// !TestAllowanceChargeOnDocumentLevel

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
end; procedure TXRechnungUBLTests.TestInvoiceWithoutOrderReferenceShouldNotWriteEmptyOrderReferenceElement;
begin

end;

procedure TXRechnungUBLTests.TestMultipleCreditorBankAccounts;
begin

end;

procedure TXRechnungUBLTests.TestMultiSkontoForCorrectIndention;
begin

end;

procedure TXRechnungUBLTests.TestNonStandardDateTimeFormat;
begin

end;

procedure TXRechnungUBLTests.TestNote;
begin

end;

procedure TXRechnungUBLTests.TestParentLineId;
var
  path: string;
  desc: TZUGFeRDInvoiceDescriptor;
begin
  path := '..\..\..\demodata\xRechnung\xRechnung UBL.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var s := TFileStream.Create(path, fmOpenRead);
  desc := TZUGFeRDInvoiceDescriptor.Load(s);
  s.free;

  desc.TradeLineItems.Clear();
  desc.AdditionalReferencedDocuments.Clear();

  desc.AddTradeLineItem(
                '1',
                'Trennblätter A4',
                '',
                TZUGFeRDQuantityCodes.H87,
                nil,
                TZUGFeRDNullableParam<Currency>.Create(9.9),
                TZUGFeRDNullableParam<Currency>.Create(9.9),
                20,
                0,
                TZUGFeRDTaxTypes.VAT,
                TZUGFeRDTaxCategoryCodes.S,
                19.0
                );

  desc.AddTradeLineItem(
                '2',
                'Abschlagsrechnungen',
                '',
                TZUGFeRDQuantityCodes.C62,
                nil,
                TZUGFeRDNullableParam<Currency>.Create(0.0),
                TZUGFeRDNullableParam<Currency>.Create(0.0),
                0,
                0,
                TZUGFeRDTaxTypes.VAT,
                TZUGFeRDTaxCategoryCodes.S,
                0
                );

  var subTradeLineItem1: TZUGFeRDTradeLineItem := desc.AddTradeLineItem(
                '2.1',
                'Abschlagsrechnung vom 01.01.2024',
                '',
                TZUGFeRDQuantityCodes.C62,
                nil,
                nil,
                TZUGFeRDNullableParam<Currency>.Create(500),
                -1,
                0,
                TZUGFeRDTaxTypes.VAT,
                TZUGFeRDTaxCategoryCodes.S,
                19.0
                );
  subTradeLineItem1.SetParentLineId('2');

  var subTradeLineItem2: TZUGFeRDTradeLineItem := desc.AddTradeLineItem(
                '2.2',
                'Abschlagsrechnung vom 20.01.2024',
                '',
                TZUGFeRDQuantityCodes.C62,
                nil,
                nil,
                TZUGFeRDNullableParam<Currency>.Create(500),
                -1,
                0,
                TZUGFeRDTaxTypes.VAT,
                TZUGFeRDTaxCategoryCodes.S,
                19.0
                );
  subTradeLineItem2.SetParentLineId('2');

  var subTradeLineItem3: TZUGFeRDTradeLineItem := desc.AddTradeLineItem(
                '2.2.1',
                'Abschlagsrechnung vom 10.01.2024',
                '',
                TZUGFeRDQuantityCodes.C62,
                nil,
                nil,
                TZUGFeRDNullableParam<Currency>.Create(100),
                -1,
                0,
                TZUGFeRDTaxTypes.VAT,
                TZUGFeRDTaxCategoryCodes.S,
                19.0
                );
  subTradeLineItem3.SetParentLineId('2.2');

  desc.AddTradeLineItem(
                '3',
                'Joghurt Banane',
                '',
                TZUGFeRDQuantityCodes.H87,
                nil,
                TZUGFeRDNullableParam<Currency>.Create(5.5),
                TZUGFeRDNullableParam<Currency>.Create(5.5),
                50,
                0,
                TZUGFeRDTaxTypes.VAT,
                TZUGFeRDTaxCategoryCodes.S,
                7.0
                );

  var ms := TMemoryStream.create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  ms.Seek(0, soBeginning);
  desc.Free;

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.AreEqual(loadedInvoice.TradeLineItems.Count, 6);
  Assert.AreEqual(loadedInvoice.TradeLineItems[0].AssociatedDocument.ParentLineID, '');
  Assert.AreEqual(loadedInvoice.TradeLineItems[1].AssociatedDocument.ParentLineID, '');
  Assert.AreEqual(loadedInvoice.TradeLineItems[2].AssociatedDocument.ParentLineID, '2');
  Assert.AreEqual(loadedInvoice.TradeLineItems[3].AssociatedDocument.ParentLineID, '2');
  Assert.AreEqual(loadedInvoice.TradeLineItems[4].AssociatedDocument.ParentLineID, '2.2');
  Assert.AreEqual(loadedInvoice.TradeLineItems[5].AssociatedDocument.ParentLineID, '');
  loadedInvoice.Free;
end;

procedure TXRechnungUBLTests.TestPartyIdentificationForSeller;
begin

end;

procedure TXRechnungUBLTests.TestPartyIdentificationShouldExistOneTime;
begin

end;

procedure TXRechnungUBLTests.TestReferenceXRechnung21UBL;
begin

end;

procedure TXRechnungUBLTests.TestSampleCreditNote326;
begin

end;

procedure TXRechnungUBLTests.TestSampleCreditNote384;
begin

end;

procedure TXRechnungUBLTests.TestSellerPartyDescription;
begin

end;

procedure TXRechnungUBLTests.TestSingleSkontoForCorrectIndention;
begin

end;

// !TestInvoiceWithAttachment()

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

procedure TXRechnungUBLTests.TestSpecialUnitCodes;
var
  desc: TZUGFeRDInvoiceDescriptor;
begin
  desc := FInvoiceProvider.CreateInvoice();

  desc.TradeLineItems[0].UnitCode := TZUGFeRDQuantityCodes._4G;
  desc.TradeLineItems[1].UnitCode := TZUGFeRDQuantityCodes.H87;

  var ms := TMemoryStream.Create;

  desc.Save(ms, FVersion, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  ms.Seek(0, soBeginning);
  desc.Free;

  var loadedInvoice := TZUGFerdInvoiceDescriptor.Load(ms);
  ms.Free;

  // test the raw xml file
  var ss := TStringStream.Create('', TEncoding.UTF8);
  ms.SaveToStream(ss);
  var content := ss.DataString;
  ss.Free;
  Assert.IsTrue(content.Contains('unitCode="H87"'));
  Assert.IsTrue(content.Contains('unitCode="4G"'));

  Assert.IsNotNull(loadedInvoice.TradeLineItems);
  Assert.AreEqual(loadedInvoice.TradeLineItems[0].UnitCode, TZUGFeRDQuantityCodes._4G);
  Assert.AreEqual(loadedInvoice.TradeLineItems[1].UnitCode, TZUGFeRDQuantityCodes.H87);
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

procedure TXRechnungUBLTests.TestTradelineitemAdditionalDocuments;
begin

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
