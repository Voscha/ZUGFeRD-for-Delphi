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
  InvoiceProvider, System.DateUtils, XML.XMLDoc, intf.ZUGFeRDVersion, System.Math;

type
  [TestFixture]
  TXRechnungUBLTests = class(TTestBase)
  private
    FInvoiceProvider: TInvoiceProvider;
    FVersion: TZUGFeRDVersion;
    function CountWhiteSpaces(const line: string): Integer;
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

uses Winapi.ActiveX, intf.ZUGFeRDProfile, intf.ZUGFeRDFormats, System.StrUtils, System.Character,
  intf.ZUGFeRDInvoiceDescriptor, intf.ZUGFeRDApplicableProductCharacteristic, intf.ZUGFeRDTaxTypes,
  intf.ZUGFeRDTaxCategoryCodes, intf.ZUGFeRDHelper, intf.ZUGFeRDTax, System.IOUtils,
  intf.ZUGFeRDAdditionalReferencedDocumentTypeCodes, intf.ZUGFeRDReferenceTypeCodes,
  intf.ZUGFeRDAdditionalReferencedDocument, intf.ZUGFeRDCurrencyCodes,
  intf.ZUGFeRDQuantityCodes, intf.ZUGFeRDTradeLineItem, intf.ZUGFeRDCountryCodes,
  intf.ZUGFeRDParty, intf.ZUGFeRDBankAccount, intf.ZUGFeRDInvoiceTypes,
  intf.ZUGFeRDPaymentMeansTypeCodes, intf.ZUGFeRDXmlHelper, System.RegularExpressions,
  intf.ZUGFeRDGlobalID, intf.ZUGFeRDGlobalIDSchemeIdentifiers,
  intf.ZUGFeRDLegalOrganization, intf.ZUGFeRDTaxRegistration, intf.ZUGFeRDTaxRegistrationSchemeID,
  intf.ZUGFeRDTaxExemptionReasonCodes, intf.ZUGFerdDesignatedProductClassificationCodes;

function TXRechnungUBLTests.CountWhiteSpaces(const line: string): Integer;
begin
  if Line.IsEmpty then
    Exit(-1);
  Result := 0;
  for var c in line do
    if c.isWhiteSpace then
      inc(Result);
end;

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
  var desc := FInvoiceProvider.CreateInvoice();
  var ms := TMemoryStream.create;

  // ActualDeliveryDate is set by the _InvoiceProvider, we are resetting it to the default value
  desc.ActualDeliveryDate := nil;

  var shipToID := '1234';
  var shipToName := 'Test ShipTo Name';
  var shipToCountry := TZUGFeRDCountryCodes.DE;

  var ShipTo := TZUGFeRDParty.create;
  ShipTo.ID.ID := shipToID;
  ShipTo.Name := shipToName;
  ShipTo.Country := shipToCountry;

  desc.ShipTo := ShipTo;

  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  desc.Free;

  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  // test the ActualDeliveryDate
  Assert.IsNull(loadedInvoice.ActualDeliveryDate);
  Assert.IsNotNull(loadedInvoice.ShipTo);
  Assert.IsNotNull(loadedInvoice.ShipTo.ID);
  Assert.AreEqual(loadedInvoice.ShipTo.ID.ID, shipToID);
  Assert.AreEqual(loadedInvoice.ShipTo.Name, shipToName);
  Assert.AreEqual(loadedInvoice.ShipTo.Country, shipToCountry);

  loadedInvoice.Free;
end;

procedure TXRechnungUBLTests.TestActualDeliveryDateWithDeliveryAddress;
begin
  var timestamp: TDateTime := EncodeDate(2024, 08, 11);
  var desc := FInvoiceProvider.CreateInvoice();
  var ms := TMemoryStream.Create;

  desc.ActualDeliveryDate := timestamp;

  var shipToID := '1234';
  var shipToName := 'Test ShipTo Name';
  var shipToCountry := TZUGFeRDCountryCodes.DE;

  var ShipTo := TZUGFeRDParty.create;
  ShipTo.ID.ID := shipToID;
  ShipTo.Name := shipToName;
  ShipTo.Country := shipToCountry;

  desc.ShipTo := ShipTo;

  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  ms.Seek(0, soFromBeginning);
  desc.Free;

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  // test the ActualDeliveryDate
  Assert.AreEqual(timestamp, loadedInvoice.ActualDeliveryDate.Value);
  Assert.IsNotNull(loadedInvoice.ShipTo);
  Assert.IsNotNull(loadedInvoice.ShipTo.ID);
  Assert.AreEqual(loadedInvoice.ShipTo.ID.ID, shipToID);
  Assert.AreEqual(loadedInvoice.ShipTo.Name, shipToName);
  Assert.AreEqual(loadedInvoice.ShipTo.Country, shipToCountry);

  loadedInvoice.Free;
end;

procedure TXRechnungUBLTests.TestActualDeliveryDateWithoutDeliveryAddress;
begin
  var timestamp: TDateTime := EncodeDate(2024, 08, 11);
  var desc := FInvoiceProvider.CreateInvoice();
  var ms := TMemoryStream.create;

  desc.ActualDeliveryDate := timestamp;

  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  ms.Seek(0, soFromBeginning);
  desc.Free;

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  // test the ActualDeliveryDate
  Assert.AreEqual(timestamp, loadedInvoice.ActualDeliveryDate.Value);
  Assert.IsNull(loadedInvoice.ShipTo);

  loadedInvoice.Free;
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

//  var testAllowanceCharge := desc.TradeAllowanceCharges.First();

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
  var descriptor := FInvoiceProvider.CreateInvoice();
  var taxCount := descriptor.Taxes.Count;
  descriptor.AddApplicableTradeTax(123.00, 23, 23, TZUGFeRDTaxTypes.VAT,
    TZUGFeRDNullableParam<TZUGFeRDTaxCategoryCodes>.Create(TZUGFeRDTaxCategoryCodes.S), nil,
    TZUGFeRDNullableParam<TZUGFeRDTaxExemptionReasonCodes>.Create(TZUGFeRDTaxExemptionReasonCodes.VATEX_132_2),
    'Tax exemption reason');

  var ms := TMemoryStream.create;
  descriptor.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  descriptor.Free;

  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  Assert.IsNotNull(loadedInvoice);
  ms.Free;

  Assert.AreEqual(loadedInvoice.Taxes.Count, taxCount + 1);
  Assert.AreEqual(loadedInvoice.Taxes.Last.ExemptionReason, 'Tax exemption reason');
  Assert.AreEqual(loadedInvoice.Taxes.Last.ExemptionReasonCode.Value,
    TZUGFeRDTaxExemptionReasonCodes.VATEX_132_2);

  loadedInvoice.Free;
end;

procedure TXRechnungUBLTests.TestBasicCreditNote;
begin
  var path := '..\..\..\demodata\xRechnung\ubl-cn-br-de-17-test-559-code-384.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var desc := TZUGFeRDInvoiceDescriptor.Load(path);
  Assert.AreEqual(desc.Type_, TZUGFeRDInvoiceType.Correction);
  Assert.AreEqual(desc.TradeLineItems.Count, 2);
  Assert.AreEqual(desc.TradeLineItems.First.BilledQuantity, Double(33));
  Assert.AreEqual(desc.TradeLineItems.First.UnitCode, TZUGFeRDQuantityCodes.XPP);
  Assert.AreEqual(desc.TradeLineItems.Last.BilledQuantity, Double(42));
  Assert.AreEqual(desc.TradeLineItems.Last.UnitCode, TZUGFeRDQuantityCodes.XPP);

  desc.Free;
end;

procedure TXRechnungUBLTests.TestBuyerOrderReferenceLineId;
begin
  var path := '..\..\..\demodata\xRechnung\xRechnung with LineId.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var s := TFile.Open(path, TFileMode.fmOpen);
  var desc := TZUGFeRDInvoiceDescriptor.Load(s);
  s.Free;

  Assert.AreEqual(desc.TradeLineItems[0].BuyerOrderReferencedDocument.LineID, '6171175.1');
  desc.Free;
end;

procedure TXRechnungUBLTests.TestBuyerPartyIdwithoutGloablID;
begin
  var d := TZUGFeRDInvoiceDescriptor.Create;
  d.Type_ := TZUGFeRDInvoiceType.Invoice;
  d.InvoiceNo := '471102';
  d.Currency := TZUGFeRDCurrencyCodes.EUR;
  d.InvoiceDate := EncodeDate (2018, 3, 5);

(*
const name, postcode, city, street: string; country: TZUGFeRDCountryCodes; const id: string = '';
                     globalID: TZUGFeRDGlobalID = nil; const receiver: string = ''; legalOrganization: TZUGFeRDLegalOrganization = nil);
*)
  d.SetBuyer('Kunden AG Mitte', '69876', 'Frankfurt', 'Kundenstraße 15', TZUGFeRDCountryCodes.DE,
    'GE2020211');

  var stream := TMemoryStream.create;
  d.Save(stream, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  stream.Seek(0, soFromBeginning);
  d.free;
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(stream);
  stream.Free;

  Assert.AreEqual(loadedInvoice.Buyer.ID.ID, 'GE2020211');
  loadedInvoice.Free;

end;

procedure TXRechnungUBLTests.TestCreditNoteTagNS0;
begin
  var path := '..\..\..\demodata\xRechnung\maxRechnung_creditnote.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var desc := TZUGFeRDInvoiceDescriptor.Load(path);

  Assert.AreEqual(desc.Profile, TZUGFeRDProfile.XRechnung);
  Assert.AreEqual(desc.InvoiceNo, '1234567890');
  Assert.AreEqual(desc.InvoiceDate.Value, EncodeDate(2018, 10, 15));

  desc.Free;
end;

procedure TXRechnungUBLTests.TestDecimals;
begin
  var desc := FInvoiceProvider.CreateInvoice();
  desc.TradeLineItems.Clear();

  var netUnitPrice: Double := 9.123456789;
  var lineTotalTotalAmount := 123.456789;
  var taxBasisAmount := 123.456789;
  var grandTotalAmount := 123.456789;
  var duePayableAmount := 123.456789;

  desc.LineTotalAmount := TZUGFeRDNullableParam<Currency>.Create(lineTotalTotalAmount);
  desc.TaxBasisAmount := TZUGFeRDNullableParam<Currency>.Create(taxBasisAmount);
  desc.GrandTotalAmount :=  TZUGFeRDNullableParam<Currency>.Create(grandTotalAmount);
  desc.DuePayableAmount :=  TZUGFeRDNullableParam<Currency>.Create(duePayableAmount);

  desc.AddTradeLineItem(
      '1',
      'Trennblätter A4',
      '',
      TZUGFeRDQuantityCodes.H87,
      nil,
      nil,
      TZUGFeRDNullableParam<Double>.Create(netUnitPrice),
      20,
      0,
      TZUGFeRDTaxTypes.VAT,
      TZUGFeRDTaxCategoryCodes.S,
      19.0,
      '',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.EAN, '4012345001235'),
      'TB100A4'
  );

  var ms := TBytesStream.create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  desc.Free;

  ms.Seek(0, soFromBeginning);
  desc := TZUGFeRDInvoiceDescriptor.Load(ms);

  var invoiceAsString := TEncoding.UTF8.GetString(ms.Bytes);
  ms.Free;

//  SetRoundMode(rmUp);
  var FS := TFormatSettings.Create('de-DE');
  FS.DecimalSeparator := '.';
  // PriceAmount might have 4 decimals
  Assert.IsFalse(invoiceAsString.Contains('>' + RoundTo(netUnitPrice, -2).ToString(FS) +'<'));
  Assert.IsTrue(invoiceAsString.Contains('>' + RoundTo(netUnitPrice, -4).ToString(FS) + '<'));
  var ItemValue: Double := desc.TradeLineItems.First.NetUnitPrice;
  var NUValue: Double := RoundTo(netUnitPrice, -4);
  Assert.AreEqual(ItemValue, NUValue);

  // Grand total, due payable etc. must have two decimals max
  Assert.IsTrue(invoiceAsString.Contains('>' + RoundTo(lineTotalTotalAmount, -2).ToString(FS) + '<'));
  Assert.IsFalse(invoiceAsString.Contains('>' + RoundTo(lineTotalTotalAmount, -4).ToString(FS) + '<'));
  Assert.AreEqual(desc.LineTotalAmount.Value, Currency(RoundTo(lineTotalTotalAmount, -2)));

  Assert.IsTrue(invoiceAsString.Contains('>' + RoundTo(taxBasisAmount, -2).ToString(FS) + '<'));
  Assert.IsFalse(invoiceAsString.Contains('>' + RoundTo(taxBasisAmount, -4).ToString(FS) + '<'));
  Assert.AreEqual(desc.TaxBasisAmount.Value, Currency(RoundTo(taxBasisAmount, -2)));

  Assert.IsTrue(invoiceAsString.Contains('>' + RoundTo(grandTotalAmount, -2).ToString(FS) + '<'));
  Assert.IsFalse(invoiceAsString.Contains('>' + RoundTo(grandTotalAmount, -4).ToString(FS) + '<'));
  Assert.AreEqual(desc.GrandTotalAmount.Value, Currency(RoundTo(grandTotalAmount, -2)));

  Assert.IsTrue(invoiceAsString.Contains('>' + RoundTo(duePayableAmount, -2).ToString(FS) + '<'));
  Assert.IsFalse(invoiceAsString.Contains('>' + RoundTo(duePayableAmount, -4).ToString(FS) + '<'));
  Assert.AreEqual(desc.DuePayableAmount.Value, Currency(RoundTo(duePayableAmount, -2)));

  desc.Free;
end;

procedure TXRechnungUBLTests.TestDesignatedProductClassificationWithFullClassification;
begin
  var desc := FInvoiceProvider.CreateInvoice();
  desc.TradeLineItems.First.AddDesignatedProductClassification(
      TZUGFeRDDesignatedProductClassificationCodes.HS,
      'List Version ID Value',
      'Class Code',
      'Class Name');

  var ms := TMemoryStream.create;

  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  var tempPath := 'output.xml'; //TPath.Combine(TPath.GetTempPath(), 'output.xml');
//  WriteLine('Saving testfile for {nameof(TestDesignatedProductClassificationWithFullClassification)} to ''{tempPath}'');
  desc.Save(tempPath, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  desc.Free;

  // string comparison
  ms.Seek(0, soFromBeginning);
  var reader := TStreamReader.create(ms);
  var content := reader.ReadToEnd();
  reader.Free;

  Assert.IsTrue(content.Contains('<cac:CommodityClassification>'));
  Assert.IsTrue(content.Contains('<cbc:ItemClassificationCode listID="HS" listVersionID="List Version ID Value">Class Code</cbc:ItemClassificationCode>'));
  Assert.IsTrue(content.Contains('</cac:CommodityClassification>'));

  // structure comparison
  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.AreEqual(TZUGFeRDDesignatedProductClassificationCodes.HS,
    loadedInvoice.TradeLineItems.First.DesignatedProductClassifications.First.ListID);
  Assert.AreEqual('List Version ID Value',
    loadedInvoice.TradeLineItems.First.DesignatedProductClassifications.First.ListVersionID);
  Assert.AreEqual('Class Code',
    loadedInvoice.TradeLineItems.First.DesignatedProductClassifications.First.ClassCode);
  Assert.isEmpty(loadedInvoice.TradeLineItems.First.DesignatedProductClassifications.First.ClassName_);

  loadedInvoice.Free;
end;

procedure TXRechnungUBLTests.TestDespatchDocumentReference;
begin
  var reference_ := TZUGFerDHelper.CreateUuid;
  var adviseDate: TDateTime := Date;

  var descriptor := FInvoiceProvider.CreateInvoice();
  descriptor.SetDespatchAdviceReferencedDocument(reference_,
    TZUGFeRDNullableParam<TDateTime>.Create(adviseDate));

  var ms := TMemoryStream.Create;
  descriptor.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  descriptor.Free;

  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  Assert.IsNotNull(loadedInvoice);
  ms.Free;

  Assert.IsNotNull(loadedInvoice.DespatchAdviceReferencedDocument);
  Assert.AreEqual(loadedInvoice.DespatchAdviceReferencedDocument.ID, reference_);
  Assert.IsNull(loadedInvoice.DespatchAdviceReferencedDocument.IssueDateTime); // not defined in Peppol standard!

  loadedInvoice.Free;
end;

procedure TXRechnungUBLTests.TestInDebitInvoiceTheFinancialAccountNameAndFinancialInstitutionBranchShouldNotExist;
begin
  var d := TZUGFeRDInvoiceDescriptor.create;
  d.Type_ := TZUGFeRDInvoiceType.Invoice;
  d.InvoiceNo := '471102';
  d.Currency := TZUGFeRDCurrencyCodes.EUR;
  d.InvoiceDate := EncodeDate(2018, 3, 5);

  d.AddTradeLineItem(
      '1',
      'Trennblätter A4',
      '',
      TZUGFeRDQuantityCodes.H87,
      nil,
      TZUGFeRDNullableParam<Double>.Create(11.781),
      TZUGFeRDNullableParam<Double>.Create(9.9),
      20,
      0,
      TZUGFeRDTaxTypes.VAT,
      TZUGFeRDTaxCategoryCodes.S,
      19.0,
      '',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.EAN, '4012345001235'),
      'TB100A4'
  );

  d.SetSeller(
      'Lieferant GmbH',
      '80333',
      'München',
      'Lieferantenstraße 20',
      TZUGFeRDCountryCodes.DE,
      '',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN, '4000001123452'),
      TZUGFeRDLegalOrganization.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN,
          '4000001123452', 'Lieferant GmbH')
  );

  d.SetBuyer(
      'Kunden AG Mitte',
      '69876',
      'Frankfurt',
      'Kundenstraße 15',
      TZUGFeRDCountryCodes.DE,
      'GE2020211',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN, '4000001987658')
  );

  d.SetPaymentMeansSepaDirectDebit('DE98ZZZ09999999999', 'REF A-123');

  d.AddDebitorFinancialAccount('DE21860000000086001055', '');

  d.AddTradePaymentTerms(
      'Der Betrag in Höhe von EUR 235,62 wird am 20.03.2018 von Ihrem Konto per SEPA-Lastschrift eingezogen.');

  d.SetTotals(
      TZUGFeRDNullableParam<Currency>.Create(198.00),
      TZUGFeRDNullableParam<Currency>.Create(0.00),
      TZUGFeRDNullableParam<Currency>.Create(0.00),
      TZUGFeRDNullableParam<Currency>.Create(198.00),
      TZUGFeRDNullableParam<Currency>.Create(37.62),
      TZUGFeRDNullableParam<Currency>.Create(235.62),
      TZUGFeRDNullableParam<Currency>.Create(0.00),
      TZUGFeRDNullableParam<Currency>.Create(235.62));

  d.SellerTaxRegistration.Add(TZUGFeRDTaxRegistration.CreateWithParams(
      TZUGFeRDTaxRegistrationSchemeID.FC, '201/113/40209')
  );

  d.SellerTaxRegistration.Add(TZUGFeRDTaxRegistration.CreateWithParams(
      TZUGFeRDTaxRegistrationSchemeID.VA, 'DE123456789')
  );

  d.AddApplicableTradeTax(198.00, 19.00, 198.00 / 100 * 19.00, TZUGFeRDTaxTypes.VAT,
      TZUGFeRDNullableParam<TZUGFeRDTaxCategoryCodes>.create(TZUGFeRDTaxCategoryCodes.S));

  var stream := TBytesStream.Create;
  d.Save(stream, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  stream.Seek(0, soFromBeginning);
  d.Free;

  // test the raw xml file
  var content := TEncoding.UTF8.GetString(stream.Bytes);
  stream.Free;

  Assert.IsFalse(TRegex.IsMatch(content, '<cac:PaymentMandate.*>.*<cbc:Name.*>.*</cac:PaymentMandate>',
    [TRegexOption.roSingleline]));
  Assert.IsFalse(TRegex.IsMatch(content, '<cac:PaymentMandate.*>.*<cac:FinancialInstitutionBranch.*></cac:PaymentMandate>',
    [TRegexOption.roSingleline]));

end;

procedure TXRechnungUBLTests.TestInDebitInvoiceThePaymentMandateIdShouldExist;
begin
  var d := TZUGFeRDInvoiceDescriptor.create;
  d.Type_ := TZUGFeRDInvoiceType.Invoice;
  d.InvoiceNo := '471102';
  d.Currency := TZUGFeRDCurrencyCodes.EUR;
  d.InvoiceDate := EncodeDate(2018, 3, 5);

  d.AddTradeLineItem(
      '1',
      'Trennblätter A4',
      '',
      TZUGFeRDQuantityCodes.H87,
      nil,
      TZUGFeRDNullableParam<Double>.Create(11.781),
      TZUGFeRDNullableParam<Double>.Create(9.9),
      20,
      0,
      TZUGFeRDTaxTypes.VAT,
      TZUGFeRDTaxCategoryCodes.S,
      19.0,
      '',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.EAN, '4012345001235'),
      'TB100A4'
  );

  d.SetSeller(
      'Lieferant GmbH',
      '80333',
      'München',
      'Lieferantenstraße 20',
      TZUGFeRDCountryCodes.DE,
      '',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN, '4000001123452'),
      TZUGFeRDLegalOrganization.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN,
          '4000001123452', 'Lieferant GmbH')
  );

  d.SetBuyer(
      'Kunden AG Mitte',
      '69876',
      'Frankfurt',
      'Kundenstraße 15',
      TZUGFeRDCountryCodes.DE,
      'GE2020211',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN, '4000001987658')
  );

  d.SetPaymentMeansSepaDirectDebit('DE98ZZZ09999999999', 'REF A-123');

  d.AddDebitorFinancialAccount('DE21860000000086001055', '');

  d.AddTradePaymentTerms(
      'Der Betrag in Höhe von EUR 235,62 wird am 20.03.2018 von Ihrem Konto per SEPA-Lastschrift eingezogen.');

  d.SetTotals(
      TZUGFeRDNullableParam<Currency>.Create(198.00),
      TZUGFeRDNullableParam<Currency>.Create(0.00),
      TZUGFeRDNullableParam<Currency>.Create(0.00),
      TZUGFeRDNullableParam<Currency>.Create(198.00),
      TZUGFeRDNullableParam<Currency>.Create(37.62),
      TZUGFeRDNullableParam<Currency>.Create(235.62),
      TZUGFeRDNullableParam<Currency>.Create(0.00),
      TZUGFeRDNullableParam<Currency>.Create(235.62));

  d.SellerTaxRegistration.Add(TZUGFeRDTaxRegistration.CreateWithParams(
      TZUGFeRDTaxRegistrationSchemeID.FC, '201/113/40209')
  );

  d.SellerTaxRegistration.Add(TZUGFeRDTaxRegistration.CreateWithParams(
      TZUGFeRDTaxRegistrationSchemeID.VA, 'DE123456789')
  );

  d.AddApplicableTradeTax(198.00, 19.00, 198.00 / 100 * 19.00, TZUGFeRDTaxTypes.VAT,
      TZUGFeRDNullableParam<TZUGFeRDTaxCategoryCodes>.create(TZUGFeRDTaxCategoryCodes.S));

  var stream := TBytesStream.Create;
  d.Save(stream, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  stream.Seek(0, soFromBeginning);
  d.Free;

  // test the raw xml file
  var content := TEncoding.UTF8.GetString(stream.Bytes);
  stream.Free;

  Assert.IsTrue(TRegex.IsMatch(content, '<cac:PaymentMeans.*>.*<cac:PaymentMandate.*>.*<cbc:ID.*>REF A-123</cbc:ID.*>.*</cac:PaymentMandate>',
    [TRegexOption.roSingleline]));

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
              nil,
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
end;

procedure TXRechnungUBLTests.TestInvoiceWithoutOrderReferenceShouldNotWriteEmptyOrderReferenceElement;
begin
  var d := TZUGFeRDInvoiceDescriptor.create;
  d.Type_ := TZUGFeRDInvoiceType.Invoice;
  d.InvoiceNo := '471102';
  d.Currency := TZUGFeRDCurrencyCodes.EUR;
  d.InvoiceDate := EncodeDate(2018, 3, 5);

  d.AddTradeLineItem(
      '1',
      'Trennblätter A4',
      '',
      TZUGFeRDQuantityCodes.H87,
      nil,
      TZUGFeRDNullableParam<Double>.Create(11.781),
      TZUGFeRDNullableParam<Double>.Create(9.9),
      20,
      0,
      TZUGFeRDTaxTypes.VAT,
      TZUGFeRDTaxCategoryCodes.S,
      19.0,
      '',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.EAN, '4012345001235'),
      'TB100A4'
  );

  d.SetSeller(
      'Lieferant GmbH',
      '80333',
      'München',
      'Lieferantenstraße 20',
      TZUGFeRDCountryCodes.DE,
      '',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN, '4000001123452'),
      TZUGFeRDLegalOrganization.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN,
          '4000001123452', 'Lieferant GmbH')
  );

  d.SetBuyer(
      'Kunden AG Mitte',
      '69876',
      'Frankfurt',
      'Kundenstraße 15',
      TZUGFeRDCountryCodes.DE,
      'GE2020211',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN, '4000001987658')
  );

  d.SetPaymentMeansSepaDirectDebit('DE98ZZZ09999999999', 'REF A-123');

  d.AddDebitorFinancialAccount('DE21860000000086001055', '');

  d.AddTradePaymentTerms(
      'Der Betrag in Höhe von EUR 235,62 wird am 20.03.2018 von Ihrem Konto per SEPA-Lastschrift eingezogen.');

  d.SetTotals(
      TZUGFeRDNullableParam<Currency>.Create(198.00),
      TZUGFeRDNullableParam<Currency>.Create(0.00),
      TZUGFeRDNullableParam<Currency>.Create(0.00),
      TZUGFeRDNullableParam<Currency>.Create(198.00),
      TZUGFeRDNullableParam<Currency>.Create(37.62),
      TZUGFeRDNullableParam<Currency>.Create(235.62),
      TZUGFeRDNullableParam<Currency>.Create(0.00),
      TZUGFeRDNullableParam<Currency>.Create(235.62));

  d.SellerTaxRegistration.Add(TZUGFeRDTaxRegistration.CreateWithParams(
      TZUGFeRDTaxRegistrationSchemeID.FC, '201/113/40209')
  );

  d.SellerTaxRegistration.Add(TZUGFeRDTaxRegistration.CreateWithParams(
      TZUGFeRDTaxRegistrationSchemeID.VA, 'DE123456789')
  );

  d.AddApplicableTradeTax(198.00, 19.00, 198.00 / 100 * 19.00, TZUGFeRDTaxTypes.VAT,
      TZUGFeRDNullableParam<TZUGFeRDTaxCategoryCodes>.create(TZUGFeRDTaxCategoryCodes.S));

  var stream := TBytesStream.create;
  d.Save(stream, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  stream.Seek(0, soFromBeginning);
  d.Free;

  // test the raw xml file
  var content := TEncoding.UTF8.GetString(stream.Bytes);
  Stream.Free;

  Assert.IsFalse(content.Contains('OrderReference'));

end;

procedure TXRechnungUBLTests.TestMultipleCreditorBankAccounts;
begin
  var iban1 := 'DE901213213312311231';
  var iban2 := 'DE911213213312311231';
  var bic1 := 'BIC-Test';
  var bic2 := 'BIC-Test2';

  var desc := FInvoiceProvider.CreateInvoice();
  var ms := TMemoryStream.Create;

  desc.CreditorBankAccounts.Clear();

  var cba1 := TZUGFeRDBankAccount.create;
  cba1.IBAN := iban1;
  cba1.BIC := bic1;
  desc.CreditorBankAccounts.Add(cba1);

  var cba2 := TZUGFeRDBankAccount.create;
  cba2.IBAN := iban2;
  cba2.BIC := bic2;
  desc.CreditorBankAccounts.Add(cba2);

  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  ms.Seek(0, soFromBeginning);
  desc.Free;

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  // test the BankAccounts
  Assert.AreEqual(iban1, loadedInvoice.CreditorBankAccounts[0].IBAN);
  Assert.AreEqual(bic1, loadedInvoice.CreditorBankAccounts[0].BIC);
  Assert.AreEqual(iban2, loadedInvoice.CreditorBankAccounts[1].IBAN);
  Assert.AreEqual(bic2, loadedInvoice.CreditorBankAccounts[1].BIC);

  loadedInvoice.Free;
end;

procedure TXRechnungUBLTests.TestMultiSkontoForCorrectIndention;
begin
  var desc := FInvoiceProvider.CreateInvoice();

  desc.PaymentTermsList.Clear;
  desc.AddTradePaymentTerms('#SKONTO#TAGE#14#PROZENT=0.00#BASISBETRAG=123.45#');
  desc.AddTradePaymentTerms('#SKONTO#TAGE#21#PROZENT=1.00#BASISBETRAG=123.45#');

  var ms := TMemoryStream.Create;
  var fs := TFile.Create('TestSingleSkontoForCorrectIdent.xml');
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  desc.Save(fs, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  fs.Free;
  desc.Free;

  var SR := TStreamReader.Create(ms);
  var lines := SR.ReadToEnd.Split([sLineBreak], TStringSplitOptions.None);
  SR.Free;
  ms.Free;

  var insidePaymentTerms := false;
  var insideCbcNote := false;
  var noteIndentation := -1;

  for var line in lines do
  begin
    // Trim the line to remove leading/trailing whitespace
    var trimmedLine := line.Trim();

    if (trimmedLine.StartsWith('<cac:PaymentTerms>', True)) then
    begin
      insidePaymentTerms := true;
      continue;
    end
    else if (not insidePaymentTerms) then
      continue;

    // Check if we found the opening <cbc:Note>
    if (not insideCbcNote and trimmedLine.StartsWith('<cbc:Note>', True)) then
    begin
      insideCbcNote := true;
      noteIndentation := CountWhiteSpaces(line);
      Assert.IsTrue(noteIndentation >= 0, 'Indentation for <cbc:Note> should be non-negative.');
      continue;
    end;
    // Check if we found the closing </cbc:Note>
    if (insideCbcNote and trimmedLine.StartsWith('</cbc:Note>', True)) then
    begin
      //TODO[vs] set correct identation
      //var endNoteIndentation := CountWhiteSpaces(line);
      //Assert.AreEqual(noteIndentation, endNoteIndentation); // Ensure closing tag matches indentation
      insideCbcNote := false;
      break;
    end;

    // After finding <cbc:Note>, check for indentation of the next line
    if (insideCbcNote) then
    begin
      var indention := CountWhiteSpaces(line);
      //TODO vs correct identation
      Assert.AreEqual(noteIndentation + 2, indention); // Ensure next line is indented one more
      continue;
    end;
  end;

  // Assert that we entered and exited the <cbc:Note> block
  Assert.IsFalse(insideCbcNote, 'We should have exited the <cbc:Note> block.');

end;

procedure TXRechnungUBLTests.TestNonStandardDateTimeFormat;
begin
  var path := '..\..\..\demodata\xRechnung\01.01a-INVOICE_ubl.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var desc := TZUGFeRDInvoiceDescriptor.Load(path);

  Assert.AreEqual(desc.InvoiceDate.Value, EncodeDate(2016, 04, 04));

  desc.Free;
end;

procedure TXRechnungUBLTests.TestNote;
begin
  var descriptor := FInvoiceProvider.CreateInvoice();
  var note := TZUGFeRDHelper.CreateUuid;
  descriptor.AddNote(note);

  var ms := TMemoryStream.Create;
  descriptor.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  descriptor.Free;

  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  Assert.IsNotNull(loadedInvoice);
  ms.Free;

  Assert.AreEqual(loadedInvoice.Notes.Count, 3); // 2 notes are already added by the _InvoiceProvider
  Assert.AreEqual(loadedInvoice.Notes.Last.Content, note);

  loadedInvoice.Free;
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
                TZUGFeRDNullableParam<Double>.Create(9.9),
                TZUGFeRDNullableParam<Double>.Create(9.9),
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
                TZUGFeRDNullableParam<Double>.Create(0.0),
                TZUGFeRDNullableParam<Double>.Create(0.0),
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
                TZUGFeRDNullableParam<Double>.Create(500),
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
                TZUGFeRDNullableParam<Double>.Create(500),
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
                TZUGFeRDNullableParam<Double>.Create(100),
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
                TZUGFeRDNullableParam<Double>.Create(5.5),
                TZUGFeRDNullableParam<Double>.Create(5.5),
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
  var desc := FInvoiceProvider.CreateInvoice();
  var ms := TMemoryStream.create;

  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  ms.Seek(0, soFromBeginning);
  desc.Free;

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  loadedInvoice.SetPaymentMeans(TZUGFeRDPaymentMeansTypeCodes.SEPACreditTransfer,
    'Hier sind Informationen', 'DE75512108001245126199', '[Mandate reference identifier]');

  var resultStream := TMemoryStream.create;
  loadedInvoice.Save(resultStream, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  loadedInvoice.Free;

  // test the raw xml file
  var XmlDoc := NewXmlDocument();
  XMLDoc.LoadFromStream(resultStream);
  resultStream.Free;

  var doc := TZUGFeRDXmlHelper.PrepareDocumentForXPathQuerys(XMLDoc);
(*
  XmlNamespaceManager nsmgr = new XmlNamespaceManager(doc.NameTable);
  nsmgr.AddNamespace("ubl", "urn:oasis:names:specification:ubl:schema:xsd:Invoice-2");
  nsmgr.AddNamespace("cac", "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2");
  nsmgr.AddNamespace("cbc", "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2");
*)
  // PartyIdentification may only exist once
  Assert.AreEqual(doc.SelectNodes('//cac:AccountingSupplierParty//cac:PartyIdentification').length, 1);

  // PartyIdentification may only exist once
  Assert.AreEqual(doc.SelectNodes('//cac:AccountingCustomerParty//cac:PartyIdentification').length, 1);

end;

procedure TXRechnungUBLTests.TestPartyIdentificationShouldExistOneTime;
begin
  var desc := FInvoiceProvider.CreateInvoice();
  var ms := TMemoryStream.create;

  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  desc.Free;

  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  var resultStream := TMemoryStream.create;
  loadedInvoice.Save(resultStream, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  loadedInvoice.Free;

  // test the raw xml file
  // test the raw xml file
  var XmlDoc := NewXmlDocument();
  XMLDoc.LoadFromStream(resultStream);
  resultStream.Free;

  var doc := TZUGFeRDXmlHelper.PrepareDocumentForXPathQuerys(XMLDoc);

(*
  XmlNamespaceManager nsmgr = new XmlNamespaceManager(doc.NameTable);
  nsmgr.AddNamespace("ubl", "urn:oasis:names:specification:ubl:schema:xsd:Invoice-2");
  nsmgr.AddNamespace("cac", "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2");
  nsmgr.AddNamespace("cbc", "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2");
*)
  Assert.AreEqual(doc.SelectNodes('//cac:PartyIdentification').length, 1);

end;

procedure TXRechnungUBLTests.TestReferenceXRechnung21UBL;
begin
  var path := '..\..\..\demodata\xRechnung\xRechnung UBL.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var desc := TZUGFeRDInvoiceDescriptor.Load(path);

  Assert.AreEqual(desc.Profile, TZUGFeRDProfile.XRechnung);
  Assert.AreEqual(desc.Type_, TZUGFeRDInvoiceType.Invoice);

  Assert.AreEqual(desc.InvoiceNo, '0815-99-1-a');
  Assert.AreEqual(desc.InvoiceDate.Value, EncodeDate(2020, 6, 21));
  Assert.AreEqual(desc.PaymentReference, '0815-99-1-a');
  Assert.AreEqual(desc.OrderNo, '0815-99-1');
  Assert.AreEqual(desc.Currency, TZUGFeRDCurrencyCodes.EUR);

  Assert.AreEqual(desc.Buyer.Name, 'Rechnungs Roulette GmbH & Co KG');
  Assert.AreEqual(desc.Buyer.City, 'Klein Schlappstadt a.d. Lusche');
  Assert.AreEqual(desc.Buyer.Postcode, '12345');
  Assert.AreEqual(desc.Buyer.Country, TZUGFeRDCountryCodes(276));
  Assert.AreEqual(desc.Buyer.Street, 'Beispielgasse 17b');
  Assert.AreEqual(desc.Buyer.SpecifiedLegalOrganization.TradingBusinessName, 'Rechnungs Roulette GmbH & Co KG');

  Assert.AreEqual(desc.BuyerContact.Name, 'Manfred Mustermann');
  Assert.AreEqual(desc.BuyerContact.EmailAddress, 'manfred.mustermann@rr.de');
  Assert.AreEqual(desc.BuyerContact.PhoneNo, '012345 98 765 - 44');

  Assert.AreEqual(desc.Seller.Name, 'Harry Hirsch Holz- und Trockenbau');
  Assert.AreEqual(desc.Seller.City, 'Klein Schlappstadt a.d. Lusche');
  Assert.AreEqual(desc.Seller.Postcode, '12345');
  Assert.AreEqual(desc.Seller.Country, TZUGFeRDCountryCodes(276));
  Assert.AreEqual(desc.Seller.Street, 'Beispielgasse 17a');
  Assert.AreEqual(desc.Seller.SpecifiedLegalOrganization.TradingBusinessName, 'Harry Hirsch Holz- und Trockenbau');

  Assert.AreEqual(desc.SellerContact.Name, 'Harry Hirsch');
  Assert.AreEqual(desc.SellerContact.EmailAddress, 'harry.hirsch@hhhtb.de');
  Assert.AreEqual(desc.SellerContact.PhoneNo, '012345 78 657 - 8');

  Assert.AreEqual(desc.TradeLineItems.Count, 2);

  Assert.AreEqual(desc.TradeLineItems[0].SellerAssignedID, '0815');
  Assert.AreEqual(desc.TradeLineItems[0].Name, 'Leimbinder');
  Assert.AreEqual(desc.TradeLineItems[0].Description, 'Leimbinder 2x18m; Birke');
  Assert.AreEqual(desc.TradeLineItems[0].BilledQuantity, Double(1.0));
  Assert.AreEqual(desc.TradeLineItems[0].LineTotalAmount.Value, Double(1245.98));
  Assert.AreEqual(desc.TradeLineItems[0].TaxPercent, Double(19));

  Assert.AreEqual(desc.TradeLineItems[1].SellerAssignedID, 'MON');
  Assert.AreEqual(desc.TradeLineItems[1].Name, 'Montage');
  Assert.AreEqual(desc.TradeLineItems[1].Description, 'Montage durch Fachpersonal');
  Assert.AreEqual(desc.TradeLineItems[1].BilledQuantity, Double(1));
  Assert.AreEqual(desc.TradeLineItems[1].LineTotalAmount.Value, Double(200.00));
  Assert.AreEqual(desc.TradeLineItems[1].TaxPercent, Double(7));

  Assert.AreEqual(desc.LineTotalAmount.Value, Currency(1445.98));
  Assert.AreEqual(desc.TaxTotalAmount.Value, Currency(250.74));
  Assert.AreEqual(desc.GrandTotalAmount.Value, Currency(1696.72));
  Assert.AreEqual(desc.DuePayableAmount.Value, Currency(1696.72));

  Assert.AreEqual(desc.Taxes[0].TaxAmount, Currency(236.74));
  Assert.AreEqual(desc.Taxes[0].BasisAmount, Currency(1245.98));
  Assert.AreEqual(desc.Taxes[0].Percent, Currency(19));
  Assert.AreEqual(desc.Taxes[0].TypeCode, TZUGFeRDTaxTypes.VAT);
  Assert.AreEqual(desc.Taxes[0].CategoryCode.Value, TZUGFeRDTaxCategoryCodes.S);

  Assert.AreEqual(desc.Taxes[1].TaxAmount, Currency(14.0000));
  Assert.AreEqual(desc.Taxes[1].BasisAmount, Currency(200.00));
  Assert.AreEqual(desc.Taxes[1].Percent, Currency(7));
  Assert.AreEqual(desc.Taxes[1].TypeCode, TZUGFeRDTaxTypes.VAT);
  Assert.AreEqual(desc.Taxes[1].CategoryCode.Value, TZUGFeRDTaxCategoryCodes.S);

  Assert.AreEqual(desc.PaymentTermsList.First.DueDate.Value, EncodeDate(2020, 6, 21));

  Assert.AreEqual(desc.CreditorBankAccounts[0].IBAN, 'DE12500105170648489890');
  Assert.AreEqual(desc.CreditorBankAccounts[0].BIC, 'INGDDEFFXXX');
  Assert.AreEqual(desc.CreditorBankAccounts[0].Name, 'Harry Hirsch');

  Assert.AreEqual(desc.PaymentMeans.TypeCode, TZUGFeRDPaymentMeansTypeCodes(30));

  desc.Free;
end;

procedure TXRechnungUBLTests.TestSampleCreditNote326;
begin
  var path := '..\..\..\demodata\xRechnung\ubl-cn-br-de-17-test-557-code-326.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var s := TFile.Open(path, TFileMode.fmOpen);
  var desc := TZUGFeRDInvoiceDescriptor.Load(s);
  s.Free;

  Assert.AreEqual(desc.Type_, TZUGFeRDInvoiceType.PartialInvoice);
  Assert.AreEqual(desc.Notes.Count, 1);
  Assert.AreEqual(desc.Notes.First.Content, 'Invoice Note Description');
  Assert.AreEqual(desc.TradeLineItems.Count, 2);
  Assert.AreEqual(desc.TradeLineItems.First.Name, 'Beratung');
  Assert.AreEqual(desc.TradeLineItems.First.Description, 'Anforderungmanagament');
  Assert.AreEqual(desc.TradeLineItems.Last.Name, 'Beratung');
  Assert.isEmpty(desc.TradeLineItems.Last.Description);

  desc.Free;
end;

procedure TXRechnungUBLTests.TestSampleCreditNote384;
begin
  var path := '..\..\..\demodata\xRechnung\ubl-cn-br-de-17-test-559-code-384.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var s := TFile.Open(path, TFileMode.fmOpen);
  var desc := TZUGFeRDInvoiceDescriptor.Load(s);
  s.Free;

  Assert.AreEqual(desc.Type_, TZUGFeRDInvoiceType.Correction);
  Assert.AreEqual(desc.Notes.Count, 1);
  Assert.AreEqual(desc.Notes.First().Content, 'Invoice Note Description');
  Assert.AreEqual(desc.TradeLineItems.Count, 2);
  Assert.AreEqual(desc.TradeLineItems.First.Name, 'Beratung');
  Assert.AreEqual(desc.TradeLineItems.First.Description, 'Anforderungmanagament');
  Assert.AreEqual(desc.TradeLineItems.Last.Name, 'Beratung');
  Assert.isEmpty(desc.TradeLineItems.Last.Description);

  desc.Free;
end;

procedure TXRechnungUBLTests.TestSellerPartyDescription;
begin
  var path := '..\..\..\demodata\xRechnung\maxRechnung_creditnote.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var desc := TZUGFeRDInvoiceDescriptor.Load(path);

  Assert.AreEqual(desc.Seller.Description, 'Weitere rechtliche' + #10 + #9#9#9#9#9 + 'Informationen');

  desc.Free;

end;

procedure TXRechnungUBLTests.TestSingleSkontoForCorrectIndention;
begin
  var desc := FInvoiceProvider.CreateInvoice();

  desc.PaymentTermsList.Clear;
  desc.AddTradePaymentTerms('#SKONTO#TAGE#14#PROZENT=0.00#BASISBETRAG=123.45#');

  var ms := TMemoryStream.Create;
  var fs := TFile.Create('TestSingleSkontoForCorrectIdent.xml');
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  desc.Save(fs, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  fs.Free;
  desc.Free;

  var SR := TStreamReader.Create(ms);
  var lines := SR.ReadToEnd.Split([sLineBreak], TStringSplitOptions.None);
  SR.Free;
  ms.Free;

  var insidePaymentTerms := false;
  var insideCbcNote := false;
  var noteIndentation := -1;

  for var line in lines do
  begin
    // Trim the line to remove leading/trailing whitespace
    var trimmedLine := line.Trim();

    if (trimmedLine.StartsWith('<cac:PaymentTerms>', True)) then
    begin
      insidePaymentTerms := true;
      continue;
    end
    else if (not insidePaymentTerms) then
      continue;

    // Check if we found the opening <cbc:Note>
    if (not insideCbcNote and trimmedLine.StartsWith('<cbc:Note>', True)) then
    begin
      insideCbcNote := true;
      noteIndentation := CountWhiteSpaces(line);
      Assert.IsTrue(noteIndentation >= 0, 'Indentation for <cbc:Note> should be non-negative.');
      continue;
    end;
    // Check if we found the closing </cbc:Note>
    if (insideCbcNote and trimmedLine.StartsWith('</cbc:Note>', True)) then
    begin
      //TODO[vs] set correct identation
      //var endNoteIndentation := CountWhiteSpaces(line);
      //Assert.AreEqual(noteIndentation, endNoteIndentation); // Ensure closing tag matches indentation
      insideCbcNote := false;
      break;
    end;

    // After finding <cbc:Note>, check for indentation of the next line
    if (insideCbcNote) then
    begin
      var indention := CountWhiteSpaces(line);
      //TODO vs correct identation
      Assert.AreEqual(noteIndentation + 2, indention); // Ensure next line is indented one more
      continue;
    end;
  end;

  // Assert that we entered and exited the <cbc:Note> block
  Assert.IsFalse(insideCbcNote, 'We should have exited the <cbc:Note> block.');
end;

// !TestInvoiceWithAttachment()

procedure TXRechnungUBLTests.TestSkippingOfAllowanceChargeBasisAmount;
begin

  // actual values do not matter
  var basisAmount: Currency := 123.0;
  var percent: Currency := 11.0;
  var allowanceChargeBasisAmount: ZUGFeRDNullable<Currency> := 121.0;

  var desc := FInvoiceProvider.CreateInvoice;
  desc.AddApplicableTradeTax(basisAmount, percent, (basisAmount / 100 * percent),
    TZUGFeRDTaxTypes.LOC,
    TZUGFeRDNullableParam<TZUGFeRDTaxCategoryCodes>.Create(TZUGFeRDTaxCategoryCodes.K),
    allowanceChargeBasisAmount);

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

  // test the raw xml file
  var ss := TStringStream.Create('', TEncoding.UTF8);
  ms.SaveToStream(ss);
  var content := ss.DataString;
  ss.Free;
  ms.Free;

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
  var  desc := FInvoiceProvider.CreateInvoice();

  desc.TradeLineItems[0].AddAdditionalReferencedDocument('testid',
    TZUGFeRDAdditionalReferencedDocumentTypeCode.InvoiceDataSheet,
    TZUGFerdNullableParam<TZUGFeRDReferenceTypeCodes>.Create(TZUGFeRDReferenceTypeCodes.ON));
  desc.TradeLineItems[0].AddAdditionalReferencedDocument('testid2',
    TZUGFeRDAdditionalReferencedDocumentTypeCode.InvoiceDataSheet,
    TZUGFerdNullableParam<TZUGFeRDReferenceTypeCodes>.Create(TZUGFeRDReferenceTypeCodes.ON));

  var ms := TMemoryStream.create;

  desc.Save(ms, FVersion, TZUGFeRDProfile.XRechnung, TZUGFeRDFormats.UBL);
  ms.Seek(0, soFromBeginning);
  desc.Free;

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.IsNotNull(loadedInvoice.TradeLineItems);
  Assert.AreEqual(loadedInvoice.TradeLineItems[0].AdditionalReferencedDocuments.Count, 2);
  Assert.AreEqual(loadedInvoice.TradeLineItems[0].AdditionalReferencedDocuments[0].ID, 'testid');
  Assert.AreEqual(loadedInvoice.TradeLineItems[0].AdditionalReferencedDocuments[1].ID, 'testid2');
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
