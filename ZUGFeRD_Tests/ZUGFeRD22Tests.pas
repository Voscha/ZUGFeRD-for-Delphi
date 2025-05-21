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

unit ZUGFeRD22Tests;

interface

uses
  DUnitX.TestFramework,  System.Classes, System.SysUtils, System.Generics.Collections, TestBase,
  InvoiceProvider, System.DateUtils, XML.XMLDoc, intf.ZUGFeRDProfile, System.IOUtils;


type
  [TestFixture]
  TZUGFeRD22Tests = class(TTestBase)
  private
    FInvoiceProvider: TInvoiceProvider;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestLineStatusCode;
    [Test]
    procedure TestExtendedInvoiceWithIncludedItems;
    [Test]
    procedure TestReferenceEReportingFacturXInvoice;
    [Test]
    procedure TestReferenceBasicFacturXInvoice;
    [Test]
    procedure TestStoringReferenceBasicFacturXInvoice;
    [Test]
    procedure TestReferenceBasicWLInvoice;
    [Test]
    procedure TestReferenceExtendedInvoice;
    [Test]
    procedure TestReferenceMinimumInvoice;
    [Test]
    procedure TestReferenceXRechnung1CII;
    [Test]
    procedure TestElectronicAddress;
    [Test]
    procedure TestMinimumInvoice;
    [Test]
    procedure TestInvoiceWithAttachmentXRechnung;
    [Test]
    procedure TestInvoiceWithAttachmentExtended;
    [Test]
    procedure TestInvoiceWithAttachmentComfort;
    [Test]
    procedure TestInvoiceWithAttachmentBasic;
    [Test]
    procedure TestXRechnung1;
    [Test]
    procedure TestXRechnung2;
    [Test]
    procedure TestCreateInvoice_WithProfileEReporting;
    [Test]
    procedure TestBuyerOrderReferencedDocumentWithExtended;
    [Test]
    procedure TestBuyerOrderReferencedDocumentWithXRechnung;
    [Test]
    procedure TestContractReferencedDocumentWithXRechnung;
    [Test]
    procedure TestContractReferencedDocumentWithExtended;
    [Test]
    procedure TestTotalRoundingExtended;
    [Test]
    procedure TestTotalRoundingXRechnung;
    [Test]
    procedure TestMissingPropertiesAreNull;
    [Test]
    procedure TestMissingPropertiesAreEmpty;
    [Test]
    procedure TestReadTradeLineBillingPeriod;
    [Test]
    procedure TestReadTradeLineLineID;
    [Test]
    procedure TestReadTradeLineProductCharacteristics;
    [Test]
    procedure TestWriteTradeLineProductCharacteristics;
    [Test]
    procedure TestWriteTradeLineBillingPeriod;
    [Test]
    procedure TestWriteTradeLineBilledQuantity;
    [Test]
    procedure TestWriteTradeLineChargeFreePackage;
    [Test]
    procedure TestWriteTradeLineNetUnitPrice;
    [Test]
    procedure TestWriteTradeLineLineID;
    [Test]
    procedure TestLoadingSepaPreNotification;
    [Test]
    procedure TestStoringSepaPreNotification;
    [Test]
    procedure TestValidTaxTypes;
    [Test]
    procedure TestInvalidTaxTypes;
    [Test]
    procedure TestAdditionalReferencedDocument;
    [Test]
    procedure TestPartyExtensions;
    [Test]
    procedure TestShipTo;
    [Test]
    procedure TestShipToTradePartyOnItemLevel;
    [Test]
    procedure TestParty_WithTaxRegistration;
    [Test]
    procedure TestUltimateShipToTradePartyOnItemLevel;
    [Test]
    procedure TestMimetypeOfEmbeddedAttachment;
    [Test]
    procedure TestOrderInformation;
    [Test]
    procedure TestSellerOrderReferencedDocument;
    [Test]
    procedure TestWriteAndReadBusinessProcess;
    /// <summary>
    /// This test ensure that Writer and Reader uses the same path and namespace for elements
    /// </summary>
    [Test]
    procedure TestWriteAndReadExtended;
    /// <summary>
    /// This test ensure that BIC won't be written if empty
    /// </summary>
    [Test]
    procedure TestFinancialInstitutionBICEmpty;
    /// <summary>
    /// This test ensure that no BIC is created for the debitor account even if it specified
    /// </summary>
    [Test]
    procedure TestNoBICIDForDebitorFinancialInstitution();
    /// <summary>
    /// This test ensure that BIC won't be written if empty
    /// </summary>
    [Test]
    procedure TestAltteilSteuer;
    [Test]
    procedure TestBasisQuantityStandard;
    [Test]
    procedure TestBasisQuantityMultiple;
    [Test]
    procedure TestTradeAllowanceChargeWithoutExplicitPercentage;
    [Test]
    procedure TestTradeAllowanceChargeWithExplicitPercentage;
    [Test]
    procedure TestWriteAndReadDespatchAdviceDocumentReferenceXRechnung;
    [Test]
    procedure TestWriteAndReadDespatchAdviceDocumentReferenceExtended;
    [Test]
    procedure TestSpecifiedTradeAllowanceCharge(profile: TZUGFeRDProfile);
    [Test]
    procedure TestSpecifiedTradeAllowanceChargeNotWrittenInMinimum();
    [Test]
    procedure TestSellerDescription;
    [Test]
    procedure TestSellerContact;
    [Test]
    procedure ShouldLoadCiiWithoutQdtNamespace;
    [Test]
    procedure TestDesignatedProductClassificationWithFullClassification;
    [Test]
    procedure TestDesignatedProductClassificationWithEmptyVersionId;
    [Test]
    procedure TestDesignatedProductClassificationWithEmptyListIdAndVersionId;
    [Test]
    procedure TestDesignatedProductClassificationWithoutAnyOptionalInformation();
//    [Test]
//    procedure TestDesignatedProductClassificationWithoutClassCode;
    [Test]
    procedure TestPaymentTermsMultiCardinalityWithExtended;
    [Test]
    procedure TestPaymentTermsMultiCardinalityWithBasic;
    [Test]
    procedure TestPaymentTermsMultiCardinalityWithMinimum;
    [Test]
    procedure TestPaymentTermsSingleCardinality;
    [Test]
    procedure TestPaymentTermsMultiCardinalityXRechnungStructured;
//    procedure TestPaymentTermsSingleCardinalityStructured;
    [Test]
    procedure TestBuyerOrderReferenceLineId;
    [Test]
    procedure TestRequiredDirectDebitFieldsShouldExist;
    [Test]
    procedure TestInNonDebitInvoiceTheDirectDebitFieldsShouldNotExist;
    [Test]
    procedure TestSpecifiedTradePaymentTermsDueDate;
    [Test]
    procedure TestSpecifiedTradePaymentTermsDescription;
    [Test]
    procedure TestSpecifiedTradePaymentTermsCalculationPercent;
    [Test]
    procedure TestTradeLineItemUnitChargeFreePackageQuantity;
    [Test]
    procedure TestApplicableTradeDeliveryTermsExists;
    [Test]
    procedure TestApplicableTradeDeliveryTermsIsNull;
    [Test]
    procedure TestInvoiceExemptions;
    [Test]
    procedure TestOriginTradeCountry;
    [Test]
    procedure TestLoadingCurrency;
    [Test]
    procedure TestLoadingSellerCountry;
    [Test]
    procedure TestLoadingBuyerCountry;
    [Test]
    procedure TestLoadingInvoiceType;
    [Test]
    procedure TestNonRSMInvoice;
    [Test]
    procedure TestRSMInvoice;
  end;

implementation

uses intf.ZUGFeRDInvoiceDescriptor, intf.ZUGFeRDInvoiceTypes, intf.ZUGFeRDHelper,
  intf.ZUGFeRDTradeLineItem, intf.ZUGFeRDVersion, intf.ZUGFeRDTradeAllowanceCharge, intf.ZUGFeRDTaxTypes,
  intf.ZUGFeRDTaxCategoryCodes, intf.ZUGFeRDElectronicAddressSchemeIdentifiers, intf.ZUGFeRDParty,
  intf.ZUGFeRDLegalOrganization, intf.ZUGFeRDAdditionalReferencedDocumentTypeCodes,
  intf.ZUGFeRDReferenceTypeCodes, intf.ZUGFeRDAdditionalReferencedDocument,
  intf.ZUGFeRDContractReferencedDocument, intf.ZUGFeRDCurrencyCodes, intf.ZUGFeRDGlobalID,
  intf.ZUGFeRDApplicableProductCharacteristic, intf.ZUGFeRDGlobalIDSchemeIdentifiers,
  intf.ZUGFeRDQuantityCodes, intf.ZUGFeRDCountryCodes, intf.ZUGFeRDPaymentTerms,
  intf.ZUGFeRDTaxRegistration, intf.ZUGFeRDTaxRegistrationSchemeID,
  intf.ZUGFeRDSellerOrderreferencedDocument, intf.ZUGFeRDPaymentMeansTypeCodes,
  intf.ZUGFeRDSpecifiedProcuringProject, intf.ZUGFeRDFinancialCard, intf.ZUGFeRDNote,
  intf.ZUGFeRDBankAccount, intf.ZUGFeRDTax, intf.ZUGFeRDServiceCharge, intf.ZUGFeRDSubjectCodes,
  intf.ZUGFeRDDesignatedProductClassificationCodes, intf.ZUGFeRDPaymentTermsType,
  intf.ZUGFeRDContentCodes, intf.ZUGFeRDXmlHelper, intf.ZUGFeRDFormats,winapi.ActiveX,
  intf.ZUGFeRDLineStatusCodes, intf.ZUGFeRDLineStatusReasonCodes,
  intf.ZUGFeRDAllowanceReasonCodes, intf.ZUGFeRDTradeDeliveryTermCodes,
  intf.ZUGFeRDTaxExemptionReasonCodes, XMLConsts;

procedure TZUGFeRD22Tests.Setup;
begin
  CoInitialize(nil);
  FInvoiceProvider := TInvoiceProvider.create;
end;

procedure TZUGFeRD22Tests.ShouldLoadCiiWithoutQdtNamespace;
begin
  var path := '..\..\..\demodata\xRechnung\xRechnung CII - without qdt.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var desc := TZUGFeRDInvoiceDescriptor.Load(path);

  Assert.AreEqual(desc.Profile, TZUGFeRDProfile.XRechnung);
  Assert.AreEqual(desc.Type_, TZUGFeRDInvoiceType.Invoice);
  Assert.AreEqual(desc.InvoiceNo, '123456XX');
  Assert.AreEqual(desc.TradeLineItems.Count, 2);
  Assert.AreEqual(desc.LineTotalAmount.Value, Currency(314.86));

  desc.Free;
end; // !ShouldLoadCIIWithoutQdtNamespace()

procedure TZUGFeRD22Tests.TearDown;
begin
  CoUninitialize;
  FInvoiceProvider.Free;
end;

procedure TZUGFeRD22Tests.TestAdditionalReferencedDocument;
begin
  var id := TZUGFerdHelper.CreateUuid;
  var uuid := TZUGFerdHelper.CreateUuid;
  var issueDateTime: TDateTime := Date;

  var desc := FInvoiceProvider.CreateInvoice();

  // BG-24
  desc.AddAdditionalReferencedDocument(
      id,
      TZUGFeRDAdditionalReferencedDocumentTypeCode.InvoiceDataSheet,
      TZUGFeRDNullableParam<TDateTime>.Create(issueDateTime),
      'Invoice Data Sheet',
      nil,
      nil,
      '',
      uuid);

  desc.AddAdditionalReferencedDocument(
      id + '2',
      TZUGFeRDAdditionalReferencedDocumentTypeCode.ReferenceDocument,
      TZUGFeRDNullableParam<TDateTime>.Create(issueDateTime),
      '',
      TZUGFeRDNullableParam<TZUGFeRDReferenceTypeCodes>.Create(PP));

  var ms := TMemoryStream.Create();
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  desc.Free;

  ms.Seek(0, soBeginning);
  var reader := TStreamReader.Create(ms);
  var text := reader.ReadToEnd();
  reader.Free;

  ms.Seek(0, soBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.AreEqual(2, loadedInvoice.AdditionalReferencedDocuments.Count);
  // checks for 1st document
  Assert.AreEqual('Invoice Data Sheet', loadedInvoice.AdditionalReferencedDocuments[0].Name);
  Assert.AreEqual(issueDateTime, loadedInvoice.AdditionalReferencedDocuments[0].IssueDateTime.Value);
  Assert.AreEqual(id, loadedInvoice.AdditionalReferencedDocuments[0].ID);
  Assert.AreEqual(uuID, loadedInvoice.AdditionalReferencedDocuments[0].URIID);
  Assert.IsEmpty(loadedInvoice.AdditionalReferencedDocuments[0].LineID);
  Assert.IsNull(loadedInvoice.AdditionalReferencedDocuments[0].ReferenceTypeCode);
  Assert.AreEqual(TZUGFeRDAdditionalReferencedDocumentTypeCode.InvoiceDataSheet,
    loadedInvoice.AdditionalReferencedDocuments[0].TypeCode.Value);
  // checks for 2nd document
  Assert.AreEqual('', loadedInvoice.AdditionalReferencedDocuments[1].Name);
  Assert.AreEqual(issueDateTime, loadedInvoice.AdditionalReferencedDocuments[1].IssueDateTime.Value);
  Assert.AreEqual(id + '2', loadedInvoice.AdditionalReferencedDocuments[1].ID);
  Assert.IsEmpty(loadedInvoice.AdditionalReferencedDocuments[1].URIID);
  Assert.IsEmpty(loadedInvoice.AdditionalReferencedDocuments[1].LineID);
  Assert.IsNull(loadedInvoice.AdditionalReferencedDocuments[1].ReferenceTypeCode);

  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestAltteilSteuer;
begin
  var desc := TZUGFeRDInvoiceDescriptor.CreateInvoice('112233', EncodeDate(2021, 04, 23), TZUGFerDCurrencyCodes.EUR);
  desc.Notes.Clear();
  desc.Notes.Add(TZUGFeRDNote.Create(
    'Rechnung enthält 100 EUR (Umsatz)Steuer auf Altteile gem. Abschn. 10.5 Abs. 3 UStAE',
    TZUGFeRDSubjectCodes.ADU,
    TZUGFeRDContentCodes.Unknown)
  );

  desc.TradeLineItems.Clear();
  desc.AddTradeLineItem('Neumotor', '',
    TZUGFeRDQuantityCodes.C62,
    TZUGFeRDNullableParam<Double>.Create(1),
    nil,
    TZUGFeRDNullableParam<Double>.Create(1000),
    1,
    0,
    TZUGFeRDTaxTypes.VAT,
    TZUGFeRDTaxCategoryCodes.S,
    19);
(*
const name: string;
  const description: string;
  const unitCode: TZUGFeRDQuantityCodes = TZUGFeRDQuantityCodes.Unknown;
  const unitQuantity: IZUGFeRDNullableParam<Double> = nil;
  const grossUnitPrice: IZUGFeRDNullableParam<Currency> = nil;
  const netUnitPrice: IZUGFeRDNullableParam<Currency> = nil;
  const billedQuantity: Double = 0;
  const lineTotalAmount: Currency = 0;
  const taxType: TZUGFeRDTaxTypes = TZUGFeRDTaxTypes.Unknown;
  const categoryCode: TZUGFeRDTaxCategoryCodes = TZUGFeRDTaxCategoryCodes.Unknown;
  const taxPercent: Double = 0;
*)
  desc.AddTradeLineItem('Bemessungsgrundlage und Umsatzsteuer auf Altteil', '',
    TZUGFeRDQuantityCodes.C62,
    TZUGFeRDNullableParam<Double>.Create(1),
    nil,
    TZUGFeRDNullableParam<Double>.Create(100),
    1,
    0,
    TZUGFeRDTaxTypes.VAT,
    TZUGFeRDTaxCategoryCodes.S,
    19);

  desc.AddTradeLineItem('Korrektur/Stornierung Bemessungsgrundlage der Umsatzsteuer auf Altteil', '',
    TZUGFeRDQuantityCodes.C62,
    TZUGFeRDNullableParam<Double>.Create(1),
    nil,
    TZUGFeRDNullableParam<Double>.Create(-100),
    1,
    0,
    TZUGFeRDTaxTypes.VAT,
    TZUGFeRDTaxCategoryCodes.Z,
    0);

  desc.AddApplicableTradeTax(1000, 19, (1000 / 100 * 19), TZUGFeRDTaxTypes.VAT,
    TZUGFeRDNullableParam<TZUGFeRDTaxCategoryCodes>.Create(TZUGFeRDTaxCategoryCodes.S));

  desc.SetTotals(
    TZUGFeRDNullableParam<Currency>.create(1500),
    nil,
    nil,
    TZUGFeRDNullableParam<Currency>.create(1500),
    TZUGFeRDNullableParam<Currency>.create(304),
    TZUGFeRDNullableParam<Currency>.create(1804),
    nil,
    TZUGFeRDNullableParam<Currency>.create(1804)
    );

  var ms := TMemoryStream.Create;

  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);
  desc.Free;
  ms.Seek(0, soBeginning);

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.isNull(loadedInvoice.Invoicee);
  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestApplicableTradeDeliveryTermsExists;
begin
  var uuid := TZUGFerdHelper.CreateUuid;

  var desc := FInvoiceProvider.CreateInvoice();
  desc.ApplicableTradeDeliveryTermsCode := TZuGFeRDTradeDeliveryTermCodes.CFR;

  var ms := TMemoryStream.create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  desc.Free;

  ms.Seek(0, soFromBeginning);
  var reader := TStreamReader.create(ms);
  var text := reader.ReadToEnd();
  reader.Free;

  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.AreEqual(TZUGFeRDProfile.Extended, loadedInvoice.Profile);
  Assert.AreEqual(loadedInvoice.ApplicableTradeDeliveryTermsCode.Value, TZUGFeRDTradeDeliveryTermCodes.CFR);
  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestApplicableTradeDeliveryTermsIsNull;
begin
  var uuid := TZUGFerdHelper.CreateUuid;

  var desc := FInvoiceProvider.CreateInvoice();

  var ms := TMemoryStream.create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  desc.Free;

  ms.Seek(0, soFromBeginning);
  var reader := TStreamReader.Create(ms);
  var text := reader.ReadToEnd();
  reader.Free;

  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.AreEqual(TZUGFeRDProfile.Extended, loadedInvoice.Profile);
  Assert.IsNull(loadedInvoice.ApplicableTradeDeliveryTermsCode);
  loadedInvoice.Free;

end;

procedure TZUGFeRD22Tests.TestBasisQuantityMultiple;
begin
  var desc := FInvoiceProvider.CreateInvoice();

  desc.TradeLineItems.Clear();
  desc.AddTradeLineItem('Joghurt Banane', '',
    TZUGFeRDQuantityCodes.H87,
    TZUGFeRDNullableParam<Double>.Create(10),
    TZUGFeRDNullableParam<Double>.Create(5.5),
    TZUGFeRDNullableParam<Double>.Create(5.5),
    50,
    0,
    TZUGFeRDTaxTypes.VAT,
    TZUGFeRDTaxCategoryCodes.S,
    7,
    '',
    TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.EAN, '4000050986428'),
    'ARNR2'
  );

  var ms := TMemoryStream.Create;

  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);
  desc.Free;
  ms.Seek(0, soBeginning);

  var XmlDoc := NewXmlDocument();
  XMLDoc.LoadFromStream(ms);
  ms.Free;

  var doc := TZUGFeRDXmlHelper.PrepareDocumentForXPathQuerys(XMLDoc);
  var node := doc.SelectSingleNode('//ram:SpecifiedTradeSettlementLineMonetarySummation//ram:LineTotalAmount');
  Assert.AreEqual('27.50', node.Text);

  XMLDoc := nil;
end;

procedure TZUGFeRD22Tests.TestBasisQuantityStandard;
begin
  var desc := FInvoiceProvider.CreateInvoice();

  desc.TradeLineItems.Clear();
  desc.AddTradeLineItem('Joghurt Banane', '',
    TZUGFeRDQuantityCodes.H87,
    nil,
    TZUGFeRDNullableParam<Double>.Create(5.5),
    TZUGFeRDNullableParam<Double>.Create(5.5),
    50,
    0,
    TZUGFeRDTaxTypes.VAT,
    TZUGFeRDTaxCategoryCodes.S,
    7,
    '',
    TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.EAN, '4000050986428'),
    'ARNR2'
  );

  var ms := TMemoryStream.Create;

  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);
  desc.Free;

  ms.Seek(0, soBeginning);

  var XMLdoc := NewXMLDocument;
  XMLdoc.LoadFromStream(ms);
  ms.Free;
(*
  XmlNamespaceManager nsmgr = new XmlNamespaceManager(doc.DocumentElement.OwnerDocument.NameTable);
  nsmgr.AddNamespace("qdt", "urn:un:unece:uncefact:data:standard:QualifiedDataType:100");
  nsmgr.AddNamespace("a", "urn:un:unece:uncefact:data:standard:QualifiedDataType:100");
  nsmgr.AddNamespace("rsm", "urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100");
  nsmgr.AddNamespace("ram", "urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100");
  nsmgr.AddNamespace("udt", "urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100");
*)
  var doc := TZUGFeRDXmlHelper.PrepareDocumentForXPathQuerys(xmldoc);
  var node := doc.SelectSingleNode('//ram:SpecifiedTradeSettlementLineMonetarySummation//ram:LineTotalAmount');
  Assert.AreEqual('275.00', node.Text);

  XMLDoc := nil;
end;

procedure TZUGFeRD22Tests.TestBuyerOrderReferencedDocumentWithExtended;
begin
  var uuid := TZUGFerdHelper.CreateUuid;
  var orderDate: ZUGFeRDNullable<TDateTime> := Today;

  var desc := FInvoiceProvider.CreateInvoice();
  desc.SetBuyerOrderReferenceDocument(uuid, orderDate);

  var ms := TMemoryStream.create();
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  ms.Seek(0, soBeginning);

  Assert.AreEqual(desc.Profile, TZUGFeRDProfile.Extended);
  desc.Free;

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.AreEqual(loadedInvoice.OrderNo, uuid);
  Assert.AreEqual(loadedInvoice.OrderDate.Value, orderDate.Value); // explicitly not to be set in XRechnung, see separate test case

  loadedInvoice.Free;
end;// !TestBuyerOrderReferencedDocumentWithExtended()

procedure TZUGFeRD22Tests.TestBuyerOrderReferencedDocumentWithXRechnung;
begin
  var uuid := TZUGFerdHelper.CreateUuid;
  var orderDate: ZUGFeRDNullable<TDateTime> := Today;

  var desc := FInvoiceProvider.CreateInvoice();
  desc.SetBuyerOrderReferenceDocument(uuid, orderDate);

  var ms :=TMemoryStream.Create();
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);
  ms.Seek(0, soBeginning);

  Assert.AreEqual(desc.Profile, TZUGFeRDProfile.XRechnung);
  desc.Free;

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.AreEqual(loadedInvoice.OrderNo, uuid);
  Assert.isNull(loadedInvoice.OrderDate); // explicitly not to be set in XRechnung, see separate test case

  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestBuyerOrderReferenceLineId;
begin
  var path := '..\..\..\demodata\zugferd22\zugferd_2p2_EXTENDED_Fremdwaehrung-factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var s := TFile.Open(path, TFileMode.fmOpen);
  var desc := TZUGFeRDInvoiceDescriptor.Load(s);
  s.Free;

  Assert.AreEqual(desc.TradeLineItems.First.BuyerOrderReferencedDocument.LineID, '1');
  Assert.AreEqual(desc.TradeLineItems.First().BuyerOrderReferencedDocument.ID, 'ORDER84359');

  desc.Free;
end;

// !TestBuyerOrderReferencedDocumentWithXRechnung()

procedure TZUGFeRD22Tests.TestContractReferencedDocumentWithExtended;
var
  desc: TZUGFeRDInvoiceDescriptor;
begin
  var uuid := TZUGFerdHelper.CreateUuid;
  var issueDateTime: TDateTime := Date;

  desc := FInvoiceProvider.CreateInvoice();
  try
    desc.ContractReferencedDocument := TZUGFeRDContractReferencedDocument.CreateWithParams(uuid, issueDateTime);
    var ms := TMemoryStream.Create;
    desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFerDProfile.Extended);
    ms.Seek(0, soBeginning);
    Assert.AreEqual(desc.Profile, TZUGFerDProfile.Extended);

    var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
    ms.Free;
    Assert.AreEqual(loadedInvoice.ContractReferencedDocument.ID, uuid);
    Assert.AreEqual(loadedInvoice.ContractReferencedDocument.IssueDateTime.Value, issueDateTime);
    loadedInvoice.Free;
  finally
    desc.Free;
  end;

end;

procedure TZUGFeRD22Tests.TestContractReferencedDocumentWithXRechnung;
var
  desc: TZUGFeRDInvoiceDescriptor;
begin
  var uuid := TZUGFerdHelper.CreateUuid;
  var issueDateTime: ZUGFeRDNullable<TDateTime> := Date;

  desc := FInvoiceProvider.CreateInvoice();
  try
    desc.ContractReferencedDocument := TZUGFeRDContractReferencedDocument.CreateWithParams(uuid, IssueDateTime);

    desc.Save('TestInvoice.xml', TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);
    var ms := TMemoryStream.Create;
    desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);
    ms.Seek(0, soBeginning);
    Assert.AreEqual(desc.Profile, TZUGFeRDProfile.XRechnung);

    var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
    ms.Free;
    Assert.AreEqual(loadedInvoice.ContractReferencedDocument.ID, uuid);
    Assert.isNull(loadedInvoice.ContractReferencedDocument.IssueDateTime); // explicitly not to be set in XRechnung, see separate test case
    loadedInvoice.Free;
  finally
    desc.Free;
  end;

end;

procedure TZUGFeRD22Tests.TestCreateInvoice_WithProfileEReporting;
var
  desc: TZUGFeRDInvoiceDescriptor;
begin
  desc := FInvoiceProvider.CreateInvoice();
  try
    var ms := TMemoryStream.Create();

    desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.EReporting);
    Assert.AreEqual(desc.Profile, TZUGFeRDProfile.EReporting);

    ms.Seek(0, soBeginning);
    var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
    ms.Free;
    Assert.AreEqual(loadedInvoice.Profile, TZUGFeRDProfile.EReporting);
    loadedInvoice.Free;
  finally
    desc.Free;
  end;
end;

procedure TZUGFeRD22Tests.TestDesignatedProductClassificationWithEmptyListIdAndVersionId;
begin
  // test with empty version id value
	var desc := FInvoiceProvider.CreateInvoice();
	desc.TradeLineItems.First().AddDesignatedProductClassification(
    TZUGFeRDDesignatedProductClassificationCodes.HS,
    '', 'Class Code');

	var ms := TMemoryStream.create;

	desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);
  ms.Seek(0, soFromBeginning);

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

	Assert.AreEqual(TZUGFeRDDesignatedProductClassificationCodes.HS,
    desc.TradeLineItems.First().DesignatedProductClassifications.First().ListID);
  Assert.AreEqual(String.Empty, loadedInvoice.TradeLineItems.First().DesignatedProductClassifications.First.ListVersionID);
  Assert.AreEqual('Class Code', loadedInvoice.TradeLineItems.First().DesignatedProductClassifications.First.ClassCode);
  Assert.AreEqual(String.Empty, loadedInvoice.TradeLineItems.First().DesignatedProductClassifications.First.ClassName_);
  desc.Free;
  loadedInvoice.Free;

end; // !TestDesignatedProductClassificationWithEmptyListIdAndVersionId()

procedure TZUGFeRD22Tests.TestDesignatedProductClassificationWithEmptyVersionId;
begin
  // test with empty version id value
	var desc := FInvoiceProvider.CreateInvoice();
	desc.TradeLineItems.First().AddDesignatedProductClassification(
    TZUGFeRDDesignatedProductClassificationCodes.HS,
    '', 'Class Code', 'Class Name');

  var ms := TMemoryStream.create;

  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);
  ms.Seek(0, soFromBeginning);

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.AreEqual(TZUGFeRDDesignatedProductClassificationCodes.HS,
    desc.TradeLineItems.First.DesignatedProductClassifications.First.ListID);
  Assert.IsEmpty(desc.TradeLineItems.First.DesignatedProductClassifications.First.ListVersionID);
  Assert.AreEqual('Class Code', desc.TradeLineItems.First.DesignatedProductClassifications.First().ClassCode);
  Assert.AreEqual('Class Name', desc.TradeLineItems.First.DesignatedProductClassifications.First().ClassName_);

  desc.Free;
  loadedInvoice.Free;
end; // !TestDesignatedProductClassificationWithEmptyVersionId()


procedure TZUGFeRD22Tests.TestDesignatedProductClassificationWithFullClassification;
begin
  var desc := FInvoiceProvider.CreateInvoice();
  desc.TradeLineItems.First().AddDesignatedProductClassification(
     TZUGFeRDDesignatedProductClassificationCodes.HS,
     'List Version ID Value', 'Class Code', 'Class Name');

  var ms := TMemoryStream.create;

  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);

  // string comparison
	ms.Seek(0, soFromBeginning);
  var reader := TStreamReader.Create(ms);
  var content: string := reader.ReadToEnd();

	Assert.IsTrue(content.Contains('<ram:DesignatedProductClassification>'));
  Assert.IsTrue(content.Contains('<ram:ClassCode listID="HS" listVersionID="List Version ID Value">Class Code</ram:ClassCode>'));
  Assert.IsTrue(content.Contains('<ram:ClassName>Class Name</ram:ClassName>'));
  reader.Free;

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
  Assert.AreEqual('Class Name',
    loadedInvoice.TradeLineItems.First.DesignatedProductClassifications.First.ClassName_);
  desc.Free;
  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestDesignatedProductClassificationWithoutAnyOptionalInformation;
begin
  // test with empty _Version id value
  var desc := FInvoiceProvider.CreateInvoice();
  desc.TradeLineItems.First().AddDesignatedProductClassification(
    TZUGFeRDDesignatedProductClassificationCodes.HS);

  var ms := TMemoryStream.create;

  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);
  desc.Free;

  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.AreEqual(TZUGFeRDDesignatedProductClassificationCodes.HS,
    desc.TradeLineItems.First.DesignatedProductClassifications.First.ListID);
  Assert.IsEmpty(desc.TradeLineItems.First.DesignatedProductClassifications.First.ListVersionID);
  Assert.IsEmpty(desc.TradeLineItems.First.DesignatedProductClassifications.First.ClassCode);
  Assert.IsEmpty(desc.TradeLineItems.First.DesignatedProductClassifications.First.ClassName_);
  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestElectronicAddress;
var
  desc: TZUGFeRDInvoicedescriptor;
begin
  desc := FInvoiceProvider.CreateInvoice;
  try
    desc.SetSellerElectronicAddress('DE123456789', TZUGFeRDElectronicAddressSchemeIdentifiers.GermanyVatNumber);
    desc.SetBuyerElectronicAddress('LU987654321', TZUGFeRDElectronicAddressSchemeIdentifiers.LuxemburgVatNumber);

    var ms := TMemoryStream.Create;
    desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);
    ms.Seek(0, soBeginning);
    Assert.AreEqual(desc.SellerElectronicAddress.Address, 'DE123456789');
    Assert.AreEqual(desc.SellerElectronicAddress.ElectronicAddressSchemeID,
      TZUGFeRDElectronicAddressSchemeIdentifiers.GermanyVatNumber);
    Assert.AreEqual(desc.BuyerElectronicAddress.Address, 'LU987654321');
    Assert.AreEqual(desc.BuyerElectronicAddress.ElectronicAddressSchemeID,
      TZUGFeRDElectronicAddressSchemeIdentifiers.LuxemburgVatNumber);

    var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
    ms.Free;
    Assert.AreEqual(loadedInvoice.SellerElectronicAddress.Address, 'DE123456789');
    Assert.AreEqual(loadedInvoice.SellerElectronicAddress.ElectronicAddressSchemeID,
      TZUGFeRDElectronicAddressSchemeIdentifiers.GermanyVatNumber);
    Assert.AreEqual(loadedInvoice.BuyerElectronicAddress.Address, 'LU987654321');
    Assert.AreEqual(loadedInvoice.BuyerElectronicAddress.ElectronicAddressSchemeID,
      TZUGFeRDElectronicAddressSchemeIdentifiers.LuxemburgVatNumber);
    loadedInvoice.Free;
  finally
    desc.Free;
  end;

end;

procedure TZUGFeRD22Tests.TestExtendedInvoiceWithIncludedItems;

var
  path: string;
  desc: TZUGFeRDInvoiceDescriptor;
begin
  path := '..\..\..\demodata\zugferd21\zugferd_2p1_EXTENDED_Warenrechnung-factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var fs: TFileStream := TFile.Open(path, TFileMode.fmOpen);
  desc := TZUGFeRDInvoiceDescriptor.Load(fs);
  fs.Free;

  desc.TradeLineItems.Clear();

  var tradeLineItem1 := desc.AddTradeLineItem(
      '1',
      'Trennblätter A4', '',
      TZUGFeRDQuantityCodes.H87,
      nil,
      TZUGFeRDNullableParam<Double>.Create(9.9),
      TZUGFeRDNullableParam<Double>.Create(9.9),
      20.0,
      0.0,
      TZUGFeRDTaxTypes.VAT,
      TZUGFeRDTaxCategoryCodes.S,
      19.0
  );

  tradeLineItem1.AddIncludedReferencedProduct('Test', TZUGFeRDNullableParam<Double>.Create(1),
    TZUGFeRDNullableParam<TZUGFeRDQuantityCodes>.Create(TZUGFeRDQuantityCodes.C62)).AddIncludedReferencedProduct('Test2');

  var ms := TMemoryStream.Create;
  fs := TFileStream.Create('Test.xml', fmCreate);
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  desc.Save(fs, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  fs.Free;
  desc.Free;

  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.AreEqual(loadedInvoice.TradeLineItems.Count, 1);
  Assert.AreEqual(loadedInvoice.TradeLineItems[0].IncludedReferencedProducts.Count, 2);
  Assert.AreEqual(loadedInvoice.TradeLineItems[0].IncludedReferencedProducts[0].Name, 'Test');
  Assert.AreEqual(loadedInvoice.TradeLineItems[0].IncludedReferencedProducts[0].UnitQuantity.Value,Double(1));
  Assert.AreEqual(loadedInvoice.TradeLineItems[0].IncludedReferencedProducts[0].UnitCode.Value,
    TZUGFeRDQuantityCodes.C62);
  Assert.AreEqual(loadedInvoice.TradeLineItems[0].IncludedReferencedProducts[1].Name, 'Test2');
  Assert.AreEqual(loadedInvoice.TradeLineItems[0].IncludedReferencedProducts[1].UnitQuantity.HasValue, false);
  Assert.isNull(loadedInvoice.TradeLineItems[0].IncludedReferencedProducts[1].UnitCode);

  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestFinancialInstitutionBICEmpty;
begin
  var uuid := TZUGFerdHelper.CreateUuid;

  var desc := FInvoiceProvider.CreateInvoice();
  //PayeeSpecifiedCreditorFinancialInstitution
  desc.CreditorBankAccounts[0].BIC := '';
  //PayerSpecifiedDebtorFinancialInstitution
  desc.AddDebitorFinancialAccount('DE02120300000000202051', '');

  var ms := TMemoryStream.Create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Comfort);
  desc.Save('test.xml', TZUGFeRDVersion.Version23, TZUGFeRDProfile.Comfort);
  desc.Free;

  ms.Seek(0, soBeginning);
  var reader := TStreamReader.Create(ms);
  var text := reader.ReadToEnd();
  reader.Free;

  ms.Seek(0, soBeginning);
  var XmlDoc := NewXmlDocument();
  XMLDoc.LoadFromStream(ms);
  ms.Free;

  var doc := TZUGFeRDXmlHelper.PrepareDocumentForXPathQuerys(xmldoc);
  var creditorFinancialInstitutions := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayeeSpecifiedCreditorFinancialInstitution');
  var debitorFinancialInstitutions := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayerSpecifiedDebtorFinancialInstitution');

  Assert.AreEqual(creditorFinancialInstitutions.Length, 0);
  Assert.AreEqual(debitorFinancialInstitutions.Length, 0);

  XMLDoc := nil;
end;

procedure TZUGFeRD22Tests.TestInNonDebitInvoiceTheDirectDebitFieldsShouldNotExist;
begin
  var d := TZUGFeRDInvoiceDescriptor.Create;
  d.Type_ := TZUGFeRDInvoiceType.Invoice;
  d.InvoiceNo := '471102';
  d.Currency := TZUGFeRDCurrencyCodes.EUR;
  d.InvoiceDate := EncodeDate(2018, 3, 5);
  d.AddTradeLineItem('1', 'Trennblätter A4', '',
      TZUGFeRDQuantityCodes.H87,
      nil,
      TZUGFeRDNullableParam<Double>.Create(11.781),
      TZUGFeRDNullableParam<Double>.Create(9.9),
      Double(20),
      0,
      TZUGFeRDTaxTypes.VAT,
      TZUGFeRDTaxCategoryCodes.S,
      Double(19.0),
      '',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.EAN, '4012345001235'),
      'TB100A4'
      );

  d.SetSeller('Lieferant GmbH', '80333', 'München', 'Lieferantenstraße 20',
      TZUGFeRDCountryCodes.DE, '', TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN,
        '4000001123452'), TZUGFeRDLegalOrganization.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN,
          '4000001123452', 'Lieferant GmbH'));
  d.SetBuyer('Kunden AG Mitte', '69876', 'Frankfurt', 'Kundenstraße 15',
      TZUGFeRDCountryCodes.DE, 'GE2020211',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN, '4000001987658'));

  d.SetPaymentMeans(TZUGFeRDPaymentMeansTypeCodes.SEPACreditTransfer,
      'Information of Payment Means', 'DE98ZZZ09999999999', 'REF A-123');
  d.AddDebitorFinancialAccount('DE21860000000086001055', '');
  var _tempPaymentTerms := TZUGFeRDPaymentTerms.Create;
  _tempPaymentTerms.Description :=
      'Der Betrag in Höhe von EUR 235,62 wird am 20.03.2018 von Ihrem Konto per SEPA-Lastschrift eingezogen.';
  d.PaymentTermsList.Add(_tempPaymentTerms);

  d.SetTotals(
      TZUGFerdNullableParam<Currency>.Create(198.00),
      nil,
      nil,
      TZUGFeRDNullableParam<Currency>.create(198.00),
      TZUGFeRDNullableParam<Currency>.create(37.62),
      TZUGFeRDNullableParam<Currency>.create(235.62),
      nil,
      TZUGFeRDNullableParam<Currency>.create(235.62));

  d.SellerTaxRegistration.Add(TZUGFeRDTaxRegistration.CreateWithParams(
    TZUGFeRDTaxRegistrationSchemeID.FC, '201/113/40209'));
  d.SellerTaxRegistration.Add(TZUGFeRDTaxRegistration.CreateWithParams(
    TZUGFeRDTaxRegistrationSchemeID.VA, 'DE123456789'));

  d.AddApplicableTradeTax(198.00, 19.00, (198.00 / 100 * 19.00), TZUGFeRDTaxTypes.VAT,
    TZUGFeRDNullableParam<TZUGFeRDTaxCategoryCodes>.Create(TZUGFeRDTaxCategoryCodes.S));


  var Stream := TBytesStream.Create;
  d.Save(stream, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);
  stream.Seek(0, soFromBeginning);
  d.free;

  // test the raw xml file
  var content: string := TEncoding.UTF8.GetString(Stream.Bytes);
  Stream.Free;

  Assert.IsFalse(content.Contains('<ram:CreditorReferenceID>DE98ZZZ09999999999</ram:CreditorReferenceID>'));
  Assert.IsFalse(content.Contains('<ram:DirectDebitMandateID>REF A-123</ram:DirectDebitMandateID>'));

end;

procedure TZUGFeRD22Tests.TestInvalidTaxTypes;
begin
  var invoice := FInvoiceProvider.CreateInvoice();
  for var Item in invoice.TradeLineItems do
    Item.TaxType := TZUGFeRDTaxTypes.AAA;

  var ms := TMemoryStream.Create;
  try
    invoice.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Basic);
  except
      Assert.Fail();
  end;

  try
    invoice.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.BasicWL);
  except
      Assert.Fail();
  end;

  try
    invoice.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Comfort);
  except
      Assert.Fail();
  end;

  try
      invoice.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Comfort);
  except
      Assert.Fail();
  end;

  // allowed in extended profile

  try
    invoice.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung1);
  except
      Assert.Fail();
  end;

  try
    invoice.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);
  except
    Assert.Fail();
  end;
  Assert.AreEqual(TZUGFeRDInvoiceType.Invoice, invoice.type_);
  ms.Free;
  invoice.Free;
end;

procedure TZUGFeRD22Tests.TestInvoiceExemptions;
begin
  var path := '..\..\..\documentation\zugferd23de\Beispiele\4. EXTENDED\EXTENDED_InnergemeinschLieferungMehrereBestellungen\factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var desc := TZUGFeRDInvoiceDescriptor.Load(path);

  var tax := desc.Taxes.First();

  Assert.AreEqual('Kein Ausweis der Umsatzsteuer bei innergemeinschaftlichen Lieferungen', tax.ExemptionReason);
  Assert.AreEqual(TZUGFeRDTaxCategoryCodes.K, tax.CategoryCode.Value);
  Assert.AreEqual(TZUGFeRDTaxTypes.VAT, tax.TypeCode);
  Assert.AreEqual(Currency(0), tax.Percent);
  Assert.IsNull(tax.ExemptionReasonCode);

  var tradeLineItems := desc.TradeLineItems;

  for var tradeLineItem in tradeLineItems do
  begin
    Assert.AreEqual('Kein Ausweis der Umsatzsteuer bei innergemeinschaftlichen Lieferungen',
      tradeLineItem.TaxExemptionReason);
    Assert.AreEqual(TZUGFeRDTaxCategoryCodes.K, tradeLineItem.TaxCategoryCode);
    Assert.AreEqual(TZUGFeRDTaxTypes.VAT, tradeLineItem.TaxType);
    Assert.AreEqual(Double(0), tradeLineItem.TaxPercent);
    Assert.IsNull(tradeLineItem.TaxExemptionReasonCode);
  end;

  tax.ExemptionReason := 'Steuerfreie innergemeinschaftlichen Lieferung';
  tax.ExemptionReasonCode := TZUGFeRDTaxExemptionReasonCodes.VATEX_EU_IC;

  for var Item in desc.TradeLineItems do
  begin
    Item.TaxExemptionReason := 'Steuerfreie innergemeinschaftlichen Lieferung';
    Item.TaxExemptionReasonCode := TZUGFeRDTaxExemptionReasonCodes.VATEX_EU_IC;
  end;

  var ms := TMemoryStream.Create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  ms.Seek(0, soFromBeginning);
  desc.Free;

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  var taxLoaded := loadedInvoice.Taxes.First();

  Assert.AreEqual('Steuerfreie innergemeinschaftlichen Lieferung', taxLoaded.ExemptionReason);
  Assert.AreEqual(TZUGFeRDTaxCategoryCodes.K, taxLoaded.CategoryCode.Value);
  Assert.AreEqual(TZUGFeRDTaxTypes.VAT, taxLoaded.TypeCode);
  Assert.AreEqual(Currency(0), taxLoaded.Percent);
  Assert.AreEqual(TZUGFeRDTaxExemptionReasonCodes.VATEX_EU_IC, taxLoaded.ExemptionReasonCode.Value);

  var tradeLineItemsLoaded := loadedInvoice.TradeLineItems;

  for var tradeLineItem in tradeLineItemsLoaded do
  begin
      Assert.AreEqual('Steuerfreie innergemeinschaftlichen Lieferung', tradeLineItem.TaxExemptionReason);
      Assert.AreEqual(TZUGFeRDTaxCategoryCodes.K, tradeLineItem.TaxCategoryCode);
      Assert.AreEqual(TZUGFeRDTaxTypes.VAT, tradeLineItem.TaxType);
      Assert.AreEqual(Double(0), tradeLineItem.TaxPercent);
      Assert.AreEqual(TZUGFeRDTaxExemptionReasonCodes.VATEX_EU_IC, tradeLineItem.TaxExemptionReasonCode.Value);
  end;

  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestInvoiceWithAttachmentBasic;
var
  desc: TZUGFeRDInvoiceDescriptor;
  data: TBytes;
begin
  desc := FInvoiceProvider.CreateInvoice();
  var filename: string  := 'myrandomdata.bin';

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

    var ms := TMemoryStream.Create();
    desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Basic);
    ms.Seek(0, soBeginning);

    var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
    ms.Free;

    Assert.AreEqual(loadedInvoice.AdditionalReferencedDocuments.Count, 0);
    loadedInvoice.Free;
  finally
    desc.Free;
  end;
end;

procedure TZUGFeRD22Tests.TestInvoiceWithAttachmentComfort;
var
  desc: TZUGFeRDInvoiceDescriptor;
  data: TBytes;
begin
  desc := FInvoiceProvider.CreateInvoice();
  var filename: string  := 'myrandomdata.bin';

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

    var ms := TMemoryStream.Create();
    desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Comfort);
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

procedure TZUGFeRD22Tests.TestInvoiceWithAttachmentExtended;
var
  desc: TZUGFeRDInvoiceDescriptor;
  data: TBytes;
begin
  desc := FInvoiceProvider.CreateInvoice();
  var filename: string  := 'myrandomdata.bin';

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

    var ms := TMemoryStream.Create();
    desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
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

procedure TZUGFeRD22Tests.TestInvoiceWithAttachmentXRechnung;
var
  desc: TZUGFeRDInvoiceDescriptor;
  data: TBytes;
begin
  desc := FInvoiceProvider.CreateInvoice();
  var filename: string  := 'myrandomdata.bin';

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

    var ms := TMemoryStream.Create();
    desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);
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

procedure TZUGFeRD22Tests.TestLineStatusCode;
var
  path: string;
  desc: TZUGFeRDInvoiceDescriptor;
begin
  path := '..\..\..\demodata\zugferd21\zugferd_2p1_EXTENDED_Warenrechnung-factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var fs: TFileStream := TFile.Open(path, TFileMode.fmOpen);
  desc := TZUGFeRDInvoiceDescriptor.Load(fs);
  fs.Free;

  desc.TradeLineItems.Clear();

  var tradeLineItem1 := desc.AddTradeLineItem(
      'Trennblätter A4', '',
      TZUGFeRDQuantityCodes.H87,
      nil,
      TZUGFeRDNullableParam<Double>.Create(9.9),
      TZUGFeRDNullableParam<Double>.Create(9.9),
      20.0,
      0.0,
      TZUGFeRDTaxTypes.VAT,
      TZUGFeRDTaxCategoryCodes.S,
      19.0
  );

  tradeLineItem1.SetLineStatus(TZUGFeRDLineStatusCodes.New, TZUGFeRDLineStatusReasonCodes.DETAIL);

  desc.AddTradeLineItem(
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

  var tradeLineItem3 := desc.AddTradeLineItem(
      'Abschlagsrechnung vom 01.01.2024', '',
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

  tradeLineItem3.SetLineStatus(TZUGFeRDLineStatusCodes.DocumentationClaim, TZUGFeRDLineStatusReasonCodes.INFORMATION);

  var ms := TMemoryStream.Create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  desc.Free;

  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.AreEqual(loadedInvoice.TradeLineItems.Count, 3);
  Assert.AreEqual(loadedInvoice.TradeLineItems[0].AssociatedDocument.LineStatusCode.Value, TZUGFeRDLineStatusCodes.New);
  Assert.AreEqual(loadedInvoice.TradeLineItems[0].AssociatedDocument.LineStatusReasonCode.Value, TZUGFeRDLineStatusReasonCodes.DETAIL);
  Assert.IsNull(loadedInvoice.TradeLineItems[1].AssociatedDocument.LineStatusCode);
  Assert.IsNull(loadedInvoice.TradeLineItems[1].AssociatedDocument.LineStatusReasonCode);
  Assert.AreEqual(loadedInvoice.TradeLineItems[2].AssociatedDocument.LineStatusCode.Value, TZUGFeRDLineStatusCodes.DocumentationClaim);
  Assert.AreEqual(loadedInvoice.TradeLineItems[2].AssociatedDocument.LineStatusReasonCode.Value, TZUGFeRDLineStatusReasonCodes.INFORMATION);

  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestLoadingBuyerCountry;
begin
  var path := '..\..\..\demodata\zugferd21\zugferd_2p1_EXTENDED_Warenrechnung-factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var s := TFile.Open(path, TFileMode.fmOpen);
  var desc := TZUGFeRDInvoiceDescriptor.Load(s);
  s.Free;

  Assert.AreEqual(desc.Buyer.Country, TZUGFeRDCountryCodes.DE);
  desc.Free;
end;

procedure TZUGFeRD22Tests.TestLoadingCurrency;
begin
  var path := '..\..\..\demodata\zugferd21\zugferd_2p1_EXTENDED_Warenrechnung-factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var s := TFile.Open(path, TFileMode.fmOpen);
  var desc := TZUGFeRDInvoiceDescriptor.Load(s);
  s.Free;

  Assert.AreEqual(desc.Currency, TZUGFeRDCurrencyCodes.EUR);
  Assert.IsNull(desc.TaxCurrency);
  desc.Free;

end;

procedure TZUGFeRD22Tests.TestLoadingInvoiceType;
begin
  // load standrd invoice
  var path := '..\..\..\demodata\zugferd21\zugferd_2p1_EXTENDED_Warenrechnung-factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var desc := TZUGFeRDInvoiceDescriptor.Load(path);

  Assert.AreEqual(desc.Type_, TZUGFeRDInvoiceType.Invoice);

  // load correction
  path := '..\..\..\documentation\zugferd23en\Examples\4. EXTENDED\EXTENDED_Rechnungskorrektur\factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);
  desc.Free;
  desc := TZUGFeRDInvoiceDescriptor.Load(path);

  Assert.AreEqual(desc.Type_, TZUGFeRDInvoiceType.Correction);
  desc.Free;

end;

procedure TZUGFeRD22Tests.TestLoadingSellerCountry;
begin
  var path := '..\..\..\demodata\zugferd21\zugferd_2p1_EXTENDED_Warenrechnung-factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var s := TFile.Open(path, TFileMode.fmOpen);
  var desc := TZUGFeRDInvoiceDescriptor.Load(s);
  s.Free;

  Assert.AreEqual(desc.Seller.Country, TZUGFeRDCountryCodes.DE);
  desc.Free;
end;

procedure TZUGFeRD22Tests.TestLoadingSepaPreNotification;
begin
  var path := '..\..\..\demodata\zugferd21\zugferd_2p1_EN16931_SEPA_Prenotification.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var invoiceDescriptor := TZUGFeRDInvoiceDescriptor.Load(path);
  Assert.AreEqual(TZUGFeRDProfile.Comfort, invoiceDescriptor.Profile);
  Assert.AreEqual(TZUGFeRDInvoiceType.Invoice, invoiceDescriptor.Type_);

  Assert.AreEqual('DE98ZZZ09999999999', invoiceDescriptor.PaymentMeans.SEPACreditorIdentifier);
  Assert.AreEqual('REF A-123', invoiceDescriptor.PaymentMeans.SEPAMandateReference);
  Assert.AreEqual(1, invoiceDescriptor.DebitorBankAccounts.Count);
  Assert.AreEqual('DE21860000000086001055', invoiceDescriptor.DebitorBankAccounts[0].IBAN);

  Assert.AreEqual('Der Betrag in Höhe von EUR 529,87 wird am 20.03.2018 von Ihrem Konto per SEPA-Lastschrift eingezogen.',
    invoiceDescriptor.PaymentTermsList.First.Description.Trim());
  invoiceDescriptor.Free;
end;

procedure TZUGFeRD22Tests.TestMimetypeOfEmbeddedAttachment;
var
  data: TBytes;
begin
  var desc := FInvoiceProvider.CreateInvoice();
  var filename1 := 'myrandomdata.pdf';
  var filename2 := 'myrandomdata.bin';
  var timestamp: TDateTime := Date;

  SetLength(data, 32768);
  RandomizeByteArray(data);

  var msref1 := TMemoryStream.Create;
  msref1.WriteBuffer(data[0], Length(data));
  msref1.Position := 0;
  desc.AddAdditionalReferencedDocument(
        'My-File-PDF',
        TZUGFeRDAdditionalReferencedDocumentTypeCode.ReferenceDocument,
        TZUGFeRDNullableParam<TDateTime>.Create(timestamp),
        'EmbeddedPdf',
        nil,
        msref1,
        filename1
    );

  var msref2 := TMemoryStream.Create;
  msref2.WriteBuffer(data[0], Length(data));
  msref2.Position := 0;
  desc.AddAdditionalReferencedDocument(
        'My-File-BIN',
        TZUGFeRDAdditionalReferencedDocumentTypeCode.ReferenceDocument,
        TZUGFeRDNullableParam<TDateTime>.Create(timestamp.IncDay(-2)),
        'EmbeddedPdf',
        nil,
        msref2,
        filename2
    );

  var ms := TMemoryStream.Create;

  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  ms.Seek(0, soBeginning);
  desc.Free;

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;
  Assert.AreEqual(loadedInvoice.AdditionalReferencedDocuments.Count, 2);

  for var document in loadedInvoice.AdditionalReferencedDocuments do
  begin
    if document.ID = 'My-File-PDF' then
    begin
      Assert.AreEqual(document.Filename, filename1);
      Assert.AreEqual('application/pdf', document.MimeType);
      Assert.AreEqual(timestamp, document.IssueDateTime.Value);
    end;

    if document.ID = 'My-File-BIN' then
    begin
      Assert.AreEqual(document.Filename, filename2);
      Assert.AreEqual('application/octet-stream', document.MimeType);
      Assert.AreEqual(timestamp.IncDay(-2), document.IssueDateTime.Value);
    end;
  end;
  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestMinimumInvoice;
var
  desc: TZUGFeRDInvoiceDescriptor;
begin
  desc := FInvoiceProvider.CreateInvoice;
  try
    desc.Invoicee := TZUGFeRDParty.Create; // this information will not be stored in the output file since it is available in Extended profile only
    desc.Invoicee.Name := 'Invoicee';

    desc.Seller := TZUGFeRDParty.Create;
    desc.Seller.Name := 'Seller';
    desc.Seller.SpecifiedLegalOrganization := TZUGFeRDLegalOrganization.Create;
    desc.Seller.SpecifiedLegalOrganization.TradingBusinessName :=
      'Trading business name for seller party';
    desc.TaxBasisAmount := 73; // this information will not be stored in the output file since it is available in Extended profile only

    var ms := TMemoryStream.Create;
    desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFerDProfile.Minimum);
    ms.Seek(0, soBeginning);

    var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
    ms.Free;

    Assert.isNull(loadedInvoice.Invoicee);
    Assert.isNotNull(loadedInvoice.Seller);
    Assert.isnotNull(loadedInvoice.Seller.SpecifiedLegalOrganization);
    Assert.AreEqual(loadedInvoice.Seller.SpecifiedLegalOrganization.TradingBusinessName, '');
    loadedInvoice.Free;
  finally
    desc.Free;
  end;


end;

procedure TZUGFeRD22Tests.TestMissingPropertiesAreEmpty;
begin
  var path := '..\..\..\demodata\zugferd21\zugferd_2p1_BASIC_Einfach-factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var invoiceDescriptor := TZUGFerdInvoiceDescriptor.Load(path);
  try
    Assert.IsTrue(TZUGFeRDHelper.TrueForAll<TZUGFeRDTradeLineItem>(invoiceDescriptor.TradeLineItems,
      function(Item: TZUGFeRDTradeLineItem): Boolean
      begin
        result := Item.ApplicableProductCharacteristics.Count = 0;
      end));
  finally
    invoiceDescriptor.Free;
  end;
end;

procedure TZUGFeRD22Tests.TestMissingPropertiesAreNull;
begin
  var path := '..\..\..\demodata\zugferd21\zugferd_2p1_BASIC_Einfach-factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var invoiceDescriptor := TZUGFerdInvoiceDescriptor.Load(path);
  try
    Assert.IsTrue(TZUGFeRDHelper.TrueForAll<TZUGFeRDTradeLineItem>(invoiceDescriptor.TradeLineItems,
      function(Item: TZUGFeRDTradeLineItem): Boolean
      begin
        result := Item.BillingPeriodStart = nil;
      end));
    Assert.IsTrue(TZUGFeRDHelper.TrueForAll<TZUGFeRDTradeLineItem>(invoiceDescriptor.TradeLineItems,
      function(Item: TZUGFeRDTradeLineItem): Boolean
      begin
        result := Item.BillingPeriodEnd = nil;
      end));
  finally
    InvoiceDescriptor.Free;
  end;
end;

procedure TZUGFeRD22Tests.TestNoBICIDForDebitorFinancialInstitution;
begin
  var desc := FInvoiceProvider.CreateInvoice();
  //PayerSpecifiedDebtorFinancialInstitution
  desc.AddDebitorFinancialAccount('DE02120300000000202051', 'MYBIC');

  var ms := TMemoryStream.Create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Comfort);
  desc.Free;

  ms.Seek(0, soBeginning);
  var reader := TStreamReader.Create(ms);
  var text := reader.ReadToEnd();
  reader.Free;

  ms.Seek(0, soBeginning);
  var XmlDoc := NewXmlDocument();
  XMLDoc.LoadFromStream(ms);
  ms.Free;

  var doc := TZUGFeRDXmlHelper.PrepareDocumentForXPathQuerys(xmldoc);

  // no financial instituation shall be present for the debitor
  var debitorFinancialInstitutions := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayeeSpecifiedDebtorFinancialInstitution');
  Assert.AreEqual(debitorFinancialInstitutions.length, 0);

  XMLDoc := nil;
end;

procedure TZUGFeRD22Tests.TestNonRSMInvoice;
begin
  var path := '..\..\..\demodata\xRechnung\non_rsm_zugferd-invoice.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var desc := TZUGFeRDInvoiceDescriptor.Load(path);

  Assert.AreEqual(desc.Profile, TZUGFeRDProfile.Extended);
  Assert.AreEqual(desc.InvoiceNo, '47110818');
  Assert.AreEqual(desc.InvoiceDate.Value, EncodeDate(2018, 10, 31));
  desc.Free;
end;

procedure TZUGFeRD22Tests.TestOrderInformation;
begin
  var path := '..\..\..\demodata\zugferd21\zugferd_2p1_EXTENDED_Warenrechnung-factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var timestamp: TDateTime := Date;

  var s := TFileStream.Create(path, fmOpenRead);
  var desc := TZUGFeRDInvoiceDescriptor.Load(s);
  desc.OrderDate := timestamp;
  desc.OrderNo := '12345';
  s.Free;

  var ms := TMemoryStream.Create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  desc.Free;

  ms.Seek(0, soBeginning);
  var reader := TStreamReader.Create(ms);
  var text := reader.ReadToEnd();
  reader.Free;

  ms.Seek(0, soBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;
  Assert.AreEqual(timestamp, loadedInvoice.OrderDate.Value);
  Assert.AreEqual('12345', loadedInvoice.OrderNo);
  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestOriginTradeCountry;
begin
  var desc := FInvoiceProvider.CreateInvoice();
  desc.TradeLineItems[0].OriginTradeCountry := TZUGFeRDCountryCodes.DE;

  var ms := TMemoryStream.create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  ms.Seek(0, soFromBeginning);
  desc.Free;

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  var items := loadedInvoice.TradeLineItems;

  Assert.IsNotNull(items[0].OriginTradeCountry);
  Assert.AreEqual(items[0].OriginTradeCountry.Value, TZUGFeRDCountryCodes.DE);

  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestPartyExtensions;
begin
  var desc := FInvoiceProvider.CreateInvoice();
  desc.Invoicee := TZUGFeRDParty.Create;

  with desc.Invoicee do
  begin
    Name := 'Invoicee';
    ContactName := 'Max Mustermann';
    Postcode := '83022';
    City := 'Rosenheim';
    Street := 'Münchnerstraße 123';
    AddressLine3 := 'EG links';
    CountrySubdivisionName := 'Bayern';
    Country := TZUGFeRDCountryCodes.DE;
  end;;

  desc.Payee := TZUGFeRDParty.Create; // most of this information will NOT be stored in the output file
  with desc.Payee do
  begin
    Name := 'Payee';
    ContactName := 'Max Mustermann';
    Postcode := '83022';
    City := 'Rosenheim';
    Street := 'Münchnerstraße 123';
    AddressLine3 := 'EG links';
    CountrySubdivisionName := 'Bayern';
    Country := TZUGFeRDCountryCodes.DE;
  end;

  var ms1 := TMemoryStream.create();

  // test with Comfort
  desc.Save(ms1, TZUGFeRDVersion.Version23, TZUGFerDProfile.Comfort);
  ms1.Seek(0, soFromBeginning);

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms1);
  ms1.Free;
  Assert.IsNull(loadedInvoice.Invoicee);
  Assert.IsNotNull(loadedInvoice.Seller);
  Assert.IsNotNull(loadedInvoice.Payee);

  Assert.AreEqual(loadedInvoice.Seller.Name, 'Lieferant GmbH');
  Assert.AreEqual(loadedInvoice.Seller.Street, 'Lieferantenstraße 20');
  Assert.AreEqual(loadedInvoice.Seller.City, 'München');
  Assert.AreEqual(loadedInvoice.Seller.Postcode, '80333');

  Assert.AreEqual(loadedInvoice.Payee.Name, 'Payee');
  Assert.IsEmpty(loadedInvoice.Payee.ContactName);
  Assert.AreEqual(loadedInvoice.Payee.Postcode, '');
  Assert.AreEqual(loadedInvoice.Payee.City, '');
  Assert.AreEqual(loadedInvoice.Payee.Street, '');
  Assert.AreEqual(loadedInvoice.Payee.AddressLine3, '');
  Assert.AreEqual(loadedInvoice.Payee.CountrySubdivisionName, '');
  Assert.AreEqual(loadedInvoice.Payee.Country, TZUGFeRDCountryCodes.Unknown);
  loadedInvoice.Free;

  // test with Extended
  var ms2 := TMemoryStream.create();
  desc.Save(ms2, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  ms2.Seek(0, soFromBeginning);
  desc.Free;

  loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms2);
  ms2.Free;

  Assert.AreEqual(loadedInvoice.Invoicee.Name, 'Invoicee');
  Assert.AreEqual(loadedInvoice.Invoicee.ContactName, 'Max Mustermann');
  Assert.AreEqual(loadedInvoice.Invoicee.Postcode, '83022');
  Assert.AreEqual(loadedInvoice.Invoicee.City, 'Rosenheim');
  Assert.AreEqual(loadedInvoice.Invoicee.Street, 'Münchnerstraße 123');
  Assert.AreEqual(loadedInvoice.Invoicee.AddressLine3, 'EG links');
  Assert.AreEqual(loadedInvoice.Invoicee.CountrySubdivisionName, 'Bayern');
  Assert.AreEqual(loadedInvoice.Invoicee.Country, TZUGFeRDCountryCodes.DE);

  Assert.AreEqual(loadedInvoice.Seller.Name, 'Lieferant GmbH');
  Assert.AreEqual(loadedInvoice.Seller.Street, 'Lieferantenstraße 20');
  Assert.AreEqual(loadedInvoice.Seller.City, 'München');
  Assert.AreEqual(loadedInvoice.Seller.Postcode, '80333');

  Assert.AreEqual(loadedInvoice.Payee.Name, 'Payee');
  Assert.AreEqual(loadedInvoice.Payee.ContactName, 'Max Mustermann');
  Assert.AreEqual(loadedInvoice.Payee.Postcode, '83022');
  Assert.AreEqual(loadedInvoice.Payee.City, 'Rosenheim');
  Assert.AreEqual(loadedInvoice.Payee.Street, 'Münchnerstraße 123');
  Assert.AreEqual(loadedInvoice.Payee.AddressLine3, 'EG links');
  Assert.AreEqual(loadedInvoice.Payee.CountrySubdivisionName, 'Bayern');
  Assert.AreEqual(loadedInvoice.Payee.Country, TZUGFeRDCountryCodes.DE);
  loadedInvoice.Free;

end;

procedure TZUGFeRD22Tests.TestParty_WithTaxRegistration;
begin
  var desc := FInvoiceProvider.CreateInvoice;

  var Party := TZUGFeRDParty.create;
  Party.ID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiers.Unknown;
  Party.ID.ID := 'SL1001';
  Party.GlobalID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiers.GLN;
  Party.GlobalID.ID := 'MusterGLN';
  Party.Name := 'AbKunden AG Mitte';
  Party.Postcode := '12345';
  Party.ContactName := 'Einheit: 5.OG rechts';
  Party.Street := 'Verwaltung Straße 40';
  Party.City := 'Musterstadt';
  Party.Country := TZUGFeRDCountryCodes.DE;
  Party.CountrySubdivisionName := 'Hessen';

  desc.ShipTo := Party;

  desc.AddShipToTaxRegistration('DE123456789', TZUGFeRDTaxRegistrationSchemeID.VA);

  var InvoiceeParty := TZUGFeRDParty.Create;
  InvoiceeParty.Name := 'Invoicee';
  InvoiceeParty.ContactName := 'Max Mustermann';
  InvoiceeParty.Postcode := '83022';
  InvoiceeParty.City := 'Rosenheim';
  InvoiceeParty.Street := 'Münchnerstraße 123';
  InvoiceeParty.AddressLine3 := 'EG links';
  InvoiceeParty.CountrySubdivisionName := 'Bayern';
  InvoiceeParty.Country := TZUGFeRDCountryCodes.DE;

  desc.Invoicee := InvoiceeParty;

  desc.AddInvoiceeTaxRegistration('DE987654321', TZUGFeRDTaxRegistrationSchemeID.VA);


  var ms := TMemoryStream.create;
  var fs := TFileStream.Create('Test.xml', fmCreate);
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  desc.Save(fs, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  fs.Free;
  desc.Free;

  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.IsNotNull(loadedInvoice.ShipTo);
  Assert.AreEqual(1, loadedInvoice.ShipToTaxRegistration.Count);
  Assert.AreEqual('DE123456789', loadedInvoice.ShipToTaxRegistration.First.No);

  Assert.IsNotNull(loadedInvoice.Invoicee);
  Assert.AreEqual(1, loadedInvoice.InvoiceeTaxRegistration.Count);
  Assert.AreEqual('DE987654321', loadedInvoice.InvoiceeTaxRegistration.First.No);
  loadedInvoice.Free;

end;


procedure TZUGFeRD22Tests.TestPaymentTermsMultiCardinalityWithBasic;
begin
  // Arrange
  var timestamp: TDateTime := Date;
  var desc := FInvoiceProvider.CreateInvoice();

  desc.PaymentTermsList.Clear();
  desc.AddTradePaymentTerms('Zahlbar innerhalb 30 Tagen netto bis 04.04.2018',
    TZUGFeRDNullableParam<TDateTime>.Create(EncodeDate(2018, 4, 4)));
  desc.AddTradePaymentTerms('3% Skonto innerhalb 10 Tagen bis 15.03.2018',
    TZUGFeRDNullableParam<TDateTime>.Create(EncodeDate(2018, 3, 15)),
    TZUGFeRDNullableParam<TZUGFeRDPaymentTermsType>.Create(TZUGFeRDPaymentTermsType.Skonto),
    TZUGFeRDNullableParam<Integer>.Create(10),
    TZUGFeRDNullableParam<Currency>.Create(3));
  desc.PaymentTermsList.First.DueDate := timestamp.IncDay(14);

  var ms := TMemoryStream.Create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Basic);
  desc.Free;

  ms.Seek(0, soFromBeginning);
  var reader := TStreamReader.Create(ms);
  var text := reader.ReadToEnd();
  reader.Free;

  ms.Seek(0, soFromBeginning);
  Assert.AreEqual(TZUGFeRDInvoiceDescriptor.GetVersion(ms), TZUGFeRDVersion.Version23);

  // Act
  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFerdInvoiceDescriptor.Load(ms);
  ms.Free;

  // Assert
  // PaymentTerms
  var paymentTerms := loadedInvoice.PaymentTermsList;
  Assert.IsNotNull(paymentTerms);
  Assert.AreEqual(2, paymentTerms.Count);

  var paymentTerm := TZUGFeRDHelper.FindFirstMatchingItem<TZUGFeRDPaymentTerms>(loadedInvoice.PaymentTermsList,
    function(Item: TZUGFeRDPaymentTerms): Boolean
    begin
      result := Item.Description.StartsWith('Zahlbar');
    end);

  Assert.IsNotNull(paymentTerm);
  Assert.IsNull(paymentTerm.PaymentTermsType);
  Assert.AreEqual('Zahlbar innerhalb 30 Tagen netto bis 04.04.2018', paymentTerm.Description);
  Assert.AreEqual(timestamp.IncDay(14), paymentTerm.DueDate.Value);

  paymentTerm := loadedInvoice.PaymentTermsList.Last;
  Assert.IsNotNull(paymentTerm);
  Assert.IsNull(paymentTerm.PaymentTermsType);
  Assert.AreEqual('3% Skonto innerhalb 10 Tagen bis 15.03.2018', paymentTerm.Description);
  Assert.IsNull(paymentTerm.Percentage);

  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestPaymentTermsMultiCardinalityWithExtended;
begin
  // Arrange
  var timestamp: TDateTime := Date;
  var baseAmount: Currency := 123;
  var percentage: Currency := 3;
  var actualAmount: Currency := 123 * 3 / 100;
  var desc := FInvoiceProvider.CreateInvoice();

  desc.PaymentTermsList.Clear();
  desc.AddTradePaymentTerms('Zahlbar innerhalb 30 Tagen netto bis 04.04.2018',
    TZUGFeRDNullableParam<TDateTime>.Create(timestamp.IncDay(14)));
  desc.AddTradePaymentTerms('3% Skonto innerhalb 10 Tagen bis 15.03.2018',
    TZUGFeRDNullableParam<TDateTime>.Create(EncodeDate(2018, 3, 15)),
    TZUGFeRDNullableParam<TZUGFeRDPaymentTermsType>.Create(TZUGFeRDPaymentTermsType.Skonto),
    TZUGFeRDNullableParam<Integer>.Create(10),
    TZUGFeRDNullableParam<Currency>.Create(percentage),
    TZUGFeRDNullableParam<Currency>.Create(baseAmount),
    TZUGFeRDNullableParam<Currency>.Create(actualAmount));

  var ms := TMemoryStream.Create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  desc.Free;

  ms.Seek(0, soFromBeginning);
  var reader := TStreamReader.Create(ms);
  var text := reader.ReadToEnd();
  reader.Free;

  ms.Seek(0, soFromBeginning);
  Assert.AreEqual(TZUGFeRDInvoiceDescriptor.GetVersion(ms), TZUGFeRDVersion.Version23);

  // Act
  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  // Assert
  // PaymentTerms
  var paymentTerms := loadedInvoice.PaymentTermsList;
  Assert.IsNotNull(paymentTerms);
  Assert.AreEqual(2, paymentTerms.Count);

  var paymentTerm := TZUGFeRDHelper.FindFirstMatchingItem<TZUGFeRDPaymentTerms>(loadedInvoice.PaymentTermsList,
    function(Item: TZUGFeRDPaymentTerms): Boolean
    begin
      result := Item.Description.StartsWith('Zahlbar');
    end);

  Assert.IsNotNull(paymentTerm);
  Assert.AreEqual('Zahlbar innerhalb 30 Tagen netto bis 04.04.2018', paymentTerm.Description);
  Assert.AreEqual(timestamp.incDay(14), paymentTerm.DueDate.Value);

  paymentTerm := TZUGFeRDHelper.FindFirstMatchingItem<TZUGFeRDPaymentTerms>(loadedInvoice.PaymentTermsList,
    function(Item: TZUGFeRDPaymentTerms): Boolean
    begin
      result := Item.PaymentTermsType = TZUGFeRDPaymentTermsType.Skonto;
    end);
  Assert.IsNotNull(paymentTerm);
  Assert.AreEqual('3% Skonto innerhalb 10 Tagen bis 15.03.2018', paymentTerm.Description);
  Assert.AreEqual(percentage, paymentTerm.Percentage.Value);
  Assert.AreEqual(baseAmount, paymentTerm.BaseAmount.Value);
  Assert.AreEqual(actualAmount, paymentTerm.ActualAmount.Value);
  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestPaymentTermsMultiCardinalityWithMinimum;
begin
  // Arrange
  var timestamp:TDateTime := Date;
  var desc := FInvoiceProvider.CreateInvoice();
  desc.PaymentTermsList.Clear();
  desc.AddTradePaymentTerms('Zahlbar innerhalb 30 Tagen netto bis 04.04.2018',
    TZUGFeRDNullableParam<TDateTime>.Create(EncodeDate(2018, 4, 4)));
  desc.AddTradePaymentTerms('3% Skonto innerhalb 10 Tagen bis 15.03.2018',
    TZUGFeRDNullableParam<TDateTime>.Create(EncodeDate(2018, 3, 15)),
    TZUGFeRDNullableParam<TZUGFeRDPaymentTermsType>.Create(TZUGFeRDPaymentTermsType.Skonto),
    TZUGFeRDNullableParam<Integer>.Create(10),
    TZUGFeRDNullableParam<Currency>.Create(3));
  desc.PaymentTermsList.First.DueDate := timestamp.IncDay(14);

  var ms := TMemoryStream.Create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Minimum);
  desc.Free;

  ms.Seek(0, soFromBeginning);
  var reader := TStreamReader.Create(ms);
  var text := reader.ReadToEnd();
  reader.Free;

  ms.Seek(0, soFromBeginning);
  Assert.AreEqual(TZUGFeRDInvoiceDescriptor.GetVersion(ms), TZUGFeRDVersion.Version23);

  // Act
  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFerdInvoiceDescriptor.Load(ms);
  ms.Free;

  // Assert
  // PaymentTerms
  var paymentTerms := loadedInvoice.PaymentTermsList;
  Assert.IsNotNull(paymentTerms);
  Assert.AreEqual(0, paymentTerms.Count);
  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestPaymentTermsMultiCardinalityXRechnungStructured;
begin
  var timestamp: TDateTime := Date;
  var desc := FInvoiceProvider.CreateInvoice();
  desc.PaymentTermsList.Clear();
  desc.AddTradePaymentTerms('', nil,
    TZUGFeRDNullableParam<TZUGFeRDPaymentTermsType>.Create(TZUGFeRDPaymentTermsType.Skonto),
    TZUGFeRDNullableParam<Integer>.Create(14),
    TZUGFeRDNullableParam<Currency>.Create(2.25));
  desc.PaymentTermsList.First.DueDate := timestamp.IncDay(14);
  desc.AddTradePaymentTerms('Description2', nil,
    TZUGFeRDNullableParam<TZUGFeRDPaymentTermsType>.Create(TZUGFeRDPaymentTermsType.Skonto),
    TZUGFeRDNullableParam<Integer>.Create(28),
    TZUGFeRDNullableParam<Currency>.Create(1));

  var ms := TMemoryStream.Create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);
  desc.Free;

  ms.Seek(0, soFromBeginning);
  var reader := TStreamReader.Create(ms);
  var text := reader.ReadToEnd();
  reader.Free;

  ms.Seek(0, soFromBeginning);
  Assert.AreEqual(TZUGFeRDInvoiceDescriptor.GetVersion(ms), TZUGFeRDVersion.Version23);


  // Act
  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFerdInvoiceDescriptor.Load(ms);
  ms.Free;

  // Assert
  // PaymentTerms
  var paymentTerms := loadedInvoice.PaymentTermsList;
  Assert.IsNotNull(paymentTerms);
  Assert.AreEqual(2, paymentTerms.Count);
  var firstPaymentTerm := loadedInvoice.PaymentTermsList.First;
  Assert.IsNotNull(firstPaymentTerm);
  Assert.AreEqual('#SKONTO#TAGE=14#PROZENT=2.25#', firstPaymentTerm.Description);
  Assert.AreEqual(timestamp.incDay(14), firstPaymentTerm.DueDate.Value);


  var secondPaymentTerm := loadedInvoice.PaymentTermsList.Last;
  Assert.IsNotNull(secondPaymentTerm);
  Assert.AreEqual(Format('Description2%s#SKONTO#TAGE=28#PROZENT=1.00#', [XmlConstants.XmlNewLine]), secondPaymentTerm.Description);

  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestPaymentTermsSingleCardinality;
begin
  // Arrange
  var timestamp: TDateTime := Date;
  var desc := FInvoiceProvider.CreateInvoice();
  desc.PaymentTermsList.Clear();
  desc.AddTradePaymentTerms(
    'Zahlbar innerhalb 30 Tagen netto bis 04.04.2018',
    TZUGFeRDNullableParam<TDateTime>.Create(EncodeDate(2018, 4, 4)));
  desc.PaymentTermsList.First.DueDate := timestamp.IncDay(14);

  var ms := TMemoryStream.create();
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Comfort);
  desc.Free;

  ms.Seek(0, soFromBeginning);
  var reader := TStreamReader.create(ms);
  var text: string := reader.ReadToEnd();
  reader.Free;

  ms.Seek(0, soFromBeginning);
  Assert.AreEqual(TZUGFeRDInvoiceDescriptor.GetVersion(ms), TZUGFeRDVersion.Version23);

  // Act
  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  // Assert
  // PaymentTerms
  var paymentTerms := loadedInvoice.PaymentTermsList;
  Assert.IsNotNull(paymentTerms);
  Assert.AreEqual(1, paymentTerms.Count);
  var paymentTerm := loadedInvoice.PaymentTermsList.First;
  Assert.IsNotNull(paymentTerm);
  Assert.AreEqual('Zahlbar innerhalb 30 Tagen netto bis 04.04.2018', paymentTerm.Description);
  Assert.AreEqual(timestamp.IncDay(14), paymentTerm.DueDate.Value);

  loadedInvoice.Free;
end;

(*
procedure TZUGFeRD22Tests.TestPaymentTermsSingleCardinalityStructured;
begin
  // Arrange
  var timestamp: TDateTime := Date;
  var desc := FInvoiceProvider.CreateInvoice();
  desc.PaymentTermsList.Clear();
  desc.AddTradePaymentTerms(
    '',
    nil,
    TZUGFeRDNullableParam<TZUGFeRDPaymentTermsType>.Create(TZUGFeRDPaymentTermsType.Skonto),
    TZUGFeRDNullableParam<Integer>.create(14),
    TZUGFeRDNullableParam<Currency>.create(2.25)
  );
  desc.AddTradePaymentTerms(
    '',
    nil,
    TZUGFeRDNullableParam<TZUGFeRDPaymentTermsType>.Create(TZUGFeRDPaymentTermsType.Skonto),
    TZUGFeRDNullableParam<Integer>.create(28),
    TZUGFeRDNullableParam<Currency>.create(1)
  );
  desc.PaymentTermsList.First.DueDate := timestamp.IncDay(14);

  var ms := TMemoryStream.create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFerDProfile.XRechnung);
  desc.Free;

  ms.Seek(0, soFromBeginning);
  var reader := TStreamReader.create(ms);
  var text: string := reader.ReadToEnd();
  reader.Free;

  ms.Seek(0, soFromBeginning);
  Assert.AreEqual(TZUGFerdInvoiceDescriptor.GetVersion(ms), TZUGFeRDVersion.Version23);

  // Act
  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  // Assert
  // PaymentTerms
  var paymentTerms := loadedInvoice.PaymentTermsList;
  Assert.IsNotNull(paymentTerms);
  Assert.AreEqual(1, paymentTerms.Count);
  var paymentTerm := loadedInvoice.PaymentTermsList.First;
  Assert.IsNotNull(paymentTerm);
  Assert.AreEqual('#SKONTO#TAGE=14#PROZENT=2.25#' + #10 +
    '#SKONTO#TAGE=28#PROZENT=1.00#', paymentTerm.Description);
  Assert.AreEqual(timestamp.incDay(14), paymentTerm.DueDate.Value);
  //Assert.AreEqual(PaymentTermsType.Skonto, paymentTerm.PaymentTermsType);
  //Assert.AreEqual(10, paymentTerm.DueDays);
  //Assert.AreEqual(3m, paymentTerm.Percentage);

  loadedInvoice.Free;
end;
*)

procedure TZUGFeRD22Tests.TestReadTradeLineBillingPeriod;
begin
  var path := '..\..\..\demodata\xRechnung\xrechnung with trade line settlement data.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var invoiceDescriptor := TZUGFeRDInvoiceDescriptor.Load(path);
  try
    var tradeLineItem := invoiceDescriptor.TradeLineItems[0];
    Assert.AreEqual(EncodeDate(2021, 01, 01), tradeLineItem.BillingPeriodStart.Value);
    Assert.AreEqual(EncodeDate(2021, 01, 31), tradeLineItem.BillingPeriodEnd.Value);
  finally
    invoiceDescriptor.free;
  end;
end;

procedure TZUGFeRD22Tests.TestReadTradeLineLineID;
begin
  var path := '..\..\..\demodata\xRechnung\xrechnung with trade line settlement data.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var invoiceDescriptor := TZUGFerDInvoiceDescriptor.Load(path);
  try
    var tradeLineItem := invoiceDescriptor.TradeLineItems[0];
    Assert.AreEqual('2', tradeLineItem.AssociatedDocument.LineID);
  finally
    invoiceDescriptor.Free;
  end;
end;

procedure TZUGFeRD22Tests.TestReadTradeLineProductCharacteristics;
begin
  var path := '..\..\..\demodata\xRechnung\xrechnung with trade line settlement data.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var invoiceDescriptor := TZUGFeRDInvoiceDescriptor.Load(path);
  try
    var tradeLineItem := invoiceDescriptor.TradeLineItems[0];

    var firstProductCharacteristic := tradeLineItem.ApplicableProductCharacteristics[0];
    Assert.AreEqual('METER_LOCATION', firstProductCharacteristic.Description);
    Assert.AreEqual('DE213410213', firstProductCharacteristic.Value);

    var secondProductCharacteristic := tradeLineItem.ApplicableProductCharacteristics[1];
    Assert.AreEqual('METER_NUMBER', secondProductCharacteristic.Description);
    Assert.AreEqual('123', secondProductCharacteristic.Value);
  finally
    invoiceDescriptor.Free;
  end;

end;

procedure TZUGFeRD22Tests.TestReferenceBasicFacturXInvoice;
var
  path: string;
  desc: TZUGFeRDInvoiceDescriptor;
begin
  path := '..\..\..\demodata\zugferd21\zugferd_2p1_BASIC_Einfach-factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var s := TFileStream.Create(path, fmOpenRead);
  desc := TZUGFeRDInvoiceDescriptor.Load(s);
  s.Free;
  try
    Assert.AreEqual(desc.Profile, TZUGFeRDProfile.Basic);
    Assert.AreEqual(desc.Type_, TZUGFeRDInvoiceType.Invoice);
    Assert.AreEqual(desc.InvoiceNo, '471102');
    Assert.AreEqual(desc.TradeLineItems.Count, 1);
    Assert.AreEqual(desc.LineTotalAmount.value, Currency(198.0));
  finally
    desc.Free;
  end;
end;

procedure TZUGFeRD22Tests.TestReferenceBasicWLInvoice;
var
  path: string;
  desc: TZUGFeRDInvoiceDescriptor;
begin
  path := '..\..\..\demodata\zugferd21\zugferd_2p1_BASIC-WL_Einfach-factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var s := TFileStream.Create(path, fmOpenread);
  desc := TZUGFeRDInvoiceDescriptor.Load(s);
  s.Free;
  try
    Assert.AreEqual(desc.Profile, TZUGFeRDProfile.BasicWL);
    Assert.AreEqual(desc.Type_, TZUGFeRDInvoiceType.Invoice);
    Assert.AreEqual(desc.InvoiceNo, '471102');
    Assert.AreEqual(desc.TradeLineItems.Count, 0);
    Assert.AreEqual(desc.LineTotalAmount.Value, Currency(624.90));
  finally
    desc.Free;
  end;

end;

procedure TZUGFeRD22Tests.TestReferenceEReportingFacturXInvoice;
var
  path: string;
  desc: TZUGFeRDInvoiceDescriptor;
begin
  path := '..\..\..\demodata\zugferd21\zugferd_2p1_EREPORTING-factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var s := TFileStream.Create(path, fmOpenRead);
  desc := TZUGFeRDInvoiceDescriptor.Load(s);
  s.Free;
  try
    Assert.AreEqual(desc.Profile, TZUGFeRDProfile.EReporting);
    Assert.AreEqual(desc.Type_, TZUGFeRDInvoiceType.Invoice);
    Assert.AreEqual(desc.InvoiceNo, '471102');
    Assert.AreEqual(desc.TradeLineItems.Count, 0);
    Assert.AreEqual(desc.LineTotalAmount.Value, Currency(0.0)); // not present in file
    Assert.AreEqual(desc.TaxBasisAmount.Value, Currency(198.0));
    Assert.AreEqual(desc.IsTest, false); // not present in file
  finally
    desc.Free;
  end;

end;

procedure TZUGFeRD22Tests.TestReferenceExtendedInvoice;
var
  path: string;
  desc: TZUGFeRDInvoiceDescriptor;
begin

  path := '..\..\..\demodata\zugferd21\zugferd_2p1_EXTENDED_Warenrechnung-factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var s := TFileStream.Create(path, fmOpenRead);
  desc := TZUGFeRDInvoiceDescriptor.Load(s);
  s.Free;
  try
    Assert.AreEqual(desc.Profile, TZUGFeRDProfile.Extended);
    Assert.AreEqual(desc.Type_, TZUGFeRDInvoiceType.Invoice);
    Assert.AreEqual(desc.InvoiceNo, 'R87654321012345');
    Assert.AreEqual(desc.TradeLineItems.Count, 6);
    Assert.AreEqual(desc.LineTotalAmount.Value, Currency(457.20));

    var _tradeAllowanceCharges: TObjectList<TZUGFeRDTradeAllowanceCharge> := desc.TradeAllowanceCharges;
    for var charge: TZUGFeRDTradeAllowanceCharge in _tradeAllowanceCharges do
    begin
      Assert.AreEqual(charge.Tax.TypeCode, TZUGFeRDTaxTypes.VAT);
      Assert.AreEqual(charge.Tax.CategoryCode.Value, TZUGFeRDTaxCategoryCodes.S);
    end;

    Assert.AreEqual(_tradeAllowanceCharges.Count, 4);
    Assert.AreEqual(_tradeAllowanceCharges[0].Tax.Percent, Currency(19));
    Assert.AreEqual(_tradeAllowanceCharges[1].Tax.Percent, Currency(7));
    Assert.AreEqual(_tradeAllowanceCharges[2].Tax.Percent, Currency(19));
    Assert.AreEqual(_tradeAllowanceCharges[3].Tax.Percent, Currency(7));

    Assert.AreEqual(desc.ServiceCharges.Count, 1);
    Assert.AreEqual(desc.ServiceCharges[0].Tax.TypeCode, TZUGFeRDTaxTypes.VAT);
    Assert.AreEqual(desc.ServiceCharges[0].Tax.CategoryCode.Value, TZUGFeRDTaxCategoryCodes.S);
    Assert.AreEqual(desc.ServiceCharges[0].Tax.Percent, Currency(19));
  finally
    desc.Free;
  end;
end;

procedure TZUGFeRD22Tests.TestReferenceMinimumInvoice;
var
  path: string;
  desc: TZUGFeRDInvoiceDescriptor;
begin
  path := '..\..\..\demodata\zugferd21\zugferd_2p1_MINIMUM_Rechnung-factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var s := TFileStream.Create(path, fmOpenRead);
  desc := TZUGFeRDInvoiceDescriptor.Load(s);
  s.Free;
  try
    Assert.AreEqual(desc.Profile, TZUGFeRDProfile.Minimum);
    Assert.AreEqual(desc.Type_, TZUGFeRDInvoiceType.Invoice);
    Assert.AreEqual(desc.InvoiceNo, '471102');
    Assert.AreEqual(desc.TradeLineItems.Count, 0);
    Assert.AreEqual(desc.LineTotalAmount.Value, Currency(0.0)); // not present in file
    Assert.AreEqual(desc.TaxBasisAmount.Value, Currency(198.0));
  finally
    desc.Free;
  end;

end;

procedure TZUGFeRD22Tests.TestReferenceXRechnung1CII;
var
  path: string;
  desc: TZUGFeRDInvoiceDescriptor;
begin
  path := '..\..\..\demodata\xRechnung\xRechnung CII.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  desc := TZUGFeRDInvoiceDescriptor.Load(path);
  try
    Assert.AreEqual(desc.Profile, TZUGFeRDProfile.XRechnung1);
    Assert.AreEqual(desc.Type_, TZUGFeRDInvoiceType.Invoice);
    Assert.AreEqual(desc.InvoiceNo, '0815-99-1-a');
    Assert.AreEqual(desc.TradeLineItems.Count, 2);
    Assert.AreEqual(desc.LineTotalAmount.Value, Currency(1445.98));
  finally
    desc.Free;
  end;

end;

(*
procedure TZUGFeRD22Tests.TestReferenceXRechnung21UBL;
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
  Assert.AreEqual(desc.TradeLineItems[0].BilledQuantity, Double(1));
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
  Assert.AreEqual(desc.Taxes[0].TypeCode, TZUGFeRDTaxTypes(53));
  Assert.AreEqual(desc.Taxes[0].CategoryCode.Value, TZUGFeRDTaxCategoryCodes(19));

  Assert.AreEqual(desc.Taxes[1].TaxAmount, Currency(14.0000));
  Assert.AreEqual(desc.Taxes[1].BasisAmount, Currency(200.00));
  Assert.AreEqual(desc.Taxes[1].Percent, Currency(7));
  Assert.AreEqual(desc.Taxes[1].TypeCode, TZUGFeRDTaxTypes(53));
  Assert.AreEqual(desc.Taxes[1].CategoryCode.Value, TZUGFeRDTaxCategoryCodes(19));

  Assert.AreEqual(desc.PaymentTermsList.First.DueDate.Value, EncodeDate(2020, 6, 21));

  Assert.AreEqual(desc.CreditorBankAccounts[0].IBAN, 'DE12500105170648489890');
  Assert.AreEqual(desc.CreditorBankAccounts[0].BIC, 'INGDDEFFXXX');
  Assert.AreEqual(desc.CreditorBankAccounts[0].Name, 'Harry Hirsch');

  Assert.AreEqual(desc.PaymentMeans.TypeCode, TZUGFeRDPaymentMeansTypeCodes(30));
  desc.Free;
end;
*)

procedure TZUGFeRD22Tests.TestRequiredDirectDebitFieldsShouldExist;
begin
  var d := TZUGFeRDInvoiceDescriptor.Create;
  d.Type_ := TZUGFeRDInvoiceType.Invoice;
  d.InvoiceNo := '471102';
  d.Currency := TZUGFeRDCurrencyCodes.EUR;
  d.InvoiceDate := EncodeDate(2018, 3, 5);
  d.AddTradeLineItem('1', 'Trennblätter A4', '',
      TZUGFeRDQuantityCodes.H87,
      nil,
      TZUGFeRDNullableParam<Double>.Create(11.781),
      TZUGFeRDNullableParam<Double>.Create(9.9),
      Double(20),
      0,
      TZUGFeRDTaxTypes.VAT,
      TZUGFeRDTaxCategoryCodes.S,
      Double(19.0),
      '',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.EAN, '4012345001235'),
      'TB100A4'
      );

  d.SetSeller('Lieferant GmbH', '80333', 'München', 'Lieferantenstraße 20',
      TZUGFeRDCountryCodes.DE, '', TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN,
        '4000001123452'), TZUGFeRDLegalOrganization.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN,
          '4000001123452', 'Lieferant GmbH'));
  d.SetBuyer('Kunden AG Mitte', '69876', 'Frankfurt', 'Kundenstraße 15',
      TZUGFeRDCountryCodes.DE, 'GE2020211',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN, '4000001987658'));

  d.SetPaymentMeansSepaDirectDebit('DE98ZZZ09999999999', 'REF A-123');
  d.AddDebitorFinancialAccount('DE21860000000086001055', '');
  var _tempPaymentTerms := TZUGFeRDPaymentTerms.Create;
  _tempPaymentTerms.Description :=
      'Der Betrag in Höhe von EUR 235,62 wird am 20.03.2018 von Ihrem Konto per SEPA-Lastschrift eingezogen.';
  d.PaymentTermsList.Add(_tempPaymentTerms);

  d.SetTotals(
      TZUGFerdNullableParam<Currency>.Create(198.00),
      nil,
      nil,
      TZUGFeRDNullableParam<Currency>.create(198.00),
      TZUGFeRDNullableParam<Currency>.create(37.62),
      TZUGFeRDNullableParam<Currency>.create(235.62),
      nil,
      TZUGFeRDNullableParam<Currency>.create(235.62));

  d.SellerTaxRegistration.Add(TZUGFeRDTaxRegistration.CreateWithParams(
    TZUGFeRDTaxRegistrationSchemeID.FC, '201/113/40209'));

  d.SellerTaxRegistration.Add(TZUGFeRDTaxRegistration.CreateWithParams(
    TZUGFeRDTaxRegistrationSchemeID.VA, 'DE123456789'));
  d.AddApplicableTradeTax(198.00, 19.00, (198.00 / 100 * 19.00), TZUGFeRDTaxTypes.VAT,
    TZUGFeRDNullableParam<TZUGFeRDTaxCategoryCodes>.Create(TZUGFeRDTaxCategoryCodes.S));

  var Stream := TBytesStream.Create;
  d.Save(stream, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);
  stream.Seek(0, soFromBeginning);
  d.free;

  // test the raw xml file
  var content: string := TEncoding.UTF8.GetString(Stream.Bytes);
  Stream.Free;


  Assert.IsTrue(content.Contains('<ram:CreditorReferenceID>DE98ZZZ09999999999</ram:CreditorReferenceID>'));
  Assert.IsTrue(content.Contains('<ram:DirectDebitMandateID>REF A-123</ram:DirectDebitMandateID>'));

end;

procedure TZUGFeRD22Tests.TestRSMInvoice;
begin
  var path := '..\..\..\demodata\xRechnung\xRechnung CII.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var desc := TZUGFeRDInvoiceDescriptor.Load(path);

  Assert.AreEqual(desc.Profile, TZUGFeRDProfile.XRechnung1);
  Assert.AreEqual(desc.InvoiceNo, '0815-99-1-a');
  Assert.AreEqual(desc.InvoiceDate.Value, EncodeDate(2020, 06, 21));
  desc.Free;
end;

procedure TZUGFeRD22Tests.TestSellerContact;
begin
  var invoice := FInvoiceProvider.CreateInvoice;

  var description := 'Test description';

  invoice.SetSeller(
      'Lieferant GmbH',
      '80333',
      'München',
      'Lieferantenstraße 20',
      TZUGFeRDCountryCodes.DE,
      '',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN, '4000001123452'),
      TZUGFeRDLegalOrganization.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN, '4000001123452',
        'Lieferant GmbH'),
      description);

  var SELLER_CONTACT := '1-123';
  var ORG_UNIT := '2-123';
  var EMAIL_ADDRESS := '3-123';
  var PHONE_NO := '4-123';
  var FAX_NO := '5-123';
  invoice.SetSellerContact(SELLER_CONTACT, ORG_UNIT, EMAIL_ADDRESS, PHONE_NO, FAX_NO);

  var ms := TMemoryStream.Create;
  invoice.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  invoice.Free;

  ms.Position := 0;
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.AreEqual(SELLER_CONTACT, loadedInvoice.SellerContact.Name);
  Assert.AreEqual(ORG_UNIT, loadedInvoice.SellerContact.OrgUnit);
  Assert.AreEqual(EMAIL_ADDRESS, loadedInvoice.SellerContact.EmailAddress);
  Assert.AreEqual(PHONE_NO, loadedInvoice.SellerContact.PhoneNo);
  Assert.AreEqual(FAX_NO, loadedInvoice.SellerContact.FaxNo);

  Assert.AreEqual(loadedInvoice.Seller.Description, description);
  loadedInvoice.Free;
end; // !TestSellerContact()

procedure TZUGFeRD22Tests.TestSellerDescription;
begin
  var invoice := FInvoiceProvider.CreateInvoice();

  var description := 'Test description';

  invoice.SetSeller('Lieferant GmbH', '80333', 'München', 'Lieferantenstraße 20',
      TZUGFeRDCountryCodes.DE, '',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN, '4000001123452'),
      TZUGFeRDLegalOrganization.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN,
        '4000001123452', 'Lieferant GmbH'),
      description
  );

  var ms := TMemoryStream.Create;
  invoice.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  invoice.Free;

  ms.Position := 0;
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.AreEqual(loadedInvoice.Seller.Description, description);
  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestSellerOrderReferencedDocument;
begin
  var uuid := TZUGFerdHelper.CreateUuid;
  var issueDateTime: TDateTime := Date;

  var desc := FInvoiceProvider.CreateInvoice();
  desc.SellerOrderReferencedDocument := TZUGFeRDSellerOrderReferencedDocument.CreateWithParams(
    uuid, issueDateTime);

  var ms := TMemoryStream.Create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  desc.Free;

  ms.Seek(0, soBeginning);
  var reader := TStreamReader.Create(ms);
  var text := reader.ReadToEnd();
  reader.Free;

  ms.Seek(0, soBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.AreEqual(TZUGFeRDProfile.Extended, loadedInvoice.Profile);
  Assert.AreEqual(uuid, loadedInvoice.SellerOrderReferencedDocument.ID);
  Assert.AreEqual(issueDateTime, loadedInvoice.SellerOrderReferencedDocument.IssueDateTime.Value);
  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestShipTo;
begin
  var desc := FInvoiceProvider.CreateInvoice();

  var Party := TZUGFeRDParty.Create;
  Party.ID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiers.Unknown;
  Party.ID.ID := 'SL1001';
  Party.GlobalID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiers.GLN;
  Party.GlobalID.ID := 'MusterGLN';
  Party.Name := 'AbKunden AG Mitte';
  Party.Postcode := '12345';
  Party.ContactName := 'Einheit: 5.OG rechts';
  Party.Street := 'Verwaltung Straße 40';
  Party.City := 'Musterstadt';
  Party.Country := TZUGFeRDCountryCodes.DE;
  Party.CountrySubdivisionName := 'Hessen';

  desc.ShipTo := Party;
  // test minimum
  var ms := TMemoryStream.create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Minimum);
  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.IsNull(loadedInvoice.ShipTo);
  loadedInvoice.Free;

  // test basic
  ms := TMemoryStream.create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Basic);
  ms.Seek(0, soFromBeginning);
  loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.IsNotNull(loadedInvoice.ShipTo);
  Assert.AreEqual(loadedInvoice.ShipTo.ID.ID, 'SL1001');
  Assert.AreEqual(loadedInvoice.ShipTo.GlobalID.ID, 'MusterGLN');
  Assert.AreEqual(loadedInvoice.ShipTo.GlobalID.SchemeID.Value, TZUGFeRDGlobalIDSchemeIdentifiers.GLN);
  Assert.AreEqual(loadedInvoice.ShipTo.Name, 'AbKunden AG Mitte');
  Assert.AreEqual(loadedInvoice.ShipTo.Postcode, '12345');
  Assert.AreEqual(loadedInvoice.ShipTo.ContactName, 'Einheit: 5.OG rechts');
  Assert.AreEqual(loadedInvoice.ShipTo.Street, 'Verwaltung Straße 40');
  Assert.AreEqual(loadedInvoice.ShipTo.City, 'Musterstadt');
  Assert.AreEqual(loadedInvoice.ShipTo.Country, TZUGFeRDCountryCodes.DE);
  Assert.AreEqual(loadedInvoice.ShipTo.CountrySubdivisionName, 'Hessen');
  loadedInvoice.Free;

  // test basic wl
  ms := TMemoryStream.create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.BasicWL);
  ms.Seek(0, soFromBeginning);
  loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.IsNotNull(loadedInvoice.ShipTo);
  Assert.AreEqual(loadedInvoice.ShipTo.ID.ID, 'SL1001');
  Assert.AreEqual(loadedInvoice.ShipTo.GlobalID.ID, 'MusterGLN');
  Assert.AreEqual(loadedInvoice.ShipTo.GlobalID.SchemeID.Value, TZUGFeRDGlobalIDSchemeIdentifiers.GLN);
  Assert.AreEqual(loadedInvoice.ShipTo.Name, 'AbKunden AG Mitte');
  Assert.AreEqual(loadedInvoice.ShipTo.Postcode, '12345');
  Assert.AreEqual(loadedInvoice.ShipTo.ContactName, 'Einheit: 5.OG rechts');
  Assert.AreEqual(loadedInvoice.ShipTo.Street, 'Verwaltung Straße 40');
  Assert.AreEqual(loadedInvoice.ShipTo.City, 'Musterstadt');
  Assert.AreEqual(loadedInvoice.ShipTo.Country, TZUGFeRDCountryCodes.DE);
  Assert.AreEqual(loadedInvoice.ShipTo.CountrySubdivisionName, 'Hessen');
  loadedInvoice.Free;

  // test comfort
  ms := TMemoryStream.create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Comfort);
  ms.Seek(0, soFromBeginning);
  loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.IsNotNull(loadedInvoice.ShipTo);
  Assert.AreEqual(loadedInvoice.ShipTo.ID.ID, 'SL1001');
  Assert.AreEqual(loadedInvoice.ShipTo.GlobalID.ID, 'MusterGLN');
  Assert.AreEqual(loadedInvoice.ShipTo.GlobalID.SchemeID.Value, TZUGFeRDGlobalIDSchemeIdentifiers.GLN);
  Assert.AreEqual(loadedInvoice.ShipTo.Name, 'AbKunden AG Mitte');
  Assert.AreEqual(loadedInvoice.ShipTo.Postcode, '12345');
  Assert.AreEqual(loadedInvoice.ShipTo.ContactName, 'Einheit: 5.OG rechts');
  Assert.AreEqual(loadedInvoice.ShipTo.Street, 'Verwaltung Straße 40');
  Assert.AreEqual(loadedInvoice.ShipTo.City, 'Musterstadt');
  Assert.AreEqual(loadedInvoice.ShipTo.Country, TZUGFeRDCountryCodes.DE);
  Assert.AreEqual(loadedInvoice.ShipTo.CountrySubdivisionName, 'Hessen');
  loadedInvoice.Free;

  // test extended
  ms := TMemoryStream.create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  ms.Seek(0, soFromBeginning);
  loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.IsNotNull(loadedInvoice.ShipTo);
  Assert.AreEqual(loadedInvoice.ShipTo.ID.ID, 'SL1001');
  Assert.AreEqual(loadedInvoice.ShipTo.GlobalID.ID, 'MusterGLN');
  Assert.AreEqual(loadedInvoice.ShipTo.GlobalID.SchemeID.Value, TZUGFeRDGlobalIDSchemeIdentifiers.GLN);
  Assert.AreEqual(loadedInvoice.ShipTo.Name, 'AbKunden AG Mitte');
  Assert.AreEqual(loadedInvoice.ShipTo.Postcode, '12345');
  Assert.AreEqual(loadedInvoice.ShipTo.ContactName, 'Einheit: 5.OG rechts');
  Assert.AreEqual(loadedInvoice.ShipTo.Street, 'Verwaltung Straße 40');
  Assert.AreEqual(loadedInvoice.ShipTo.City, 'Musterstadt');
  Assert.AreEqual(loadedInvoice.ShipTo.Country, TZUGFeRDCountryCodes.DE);
  Assert.AreEqual(loadedInvoice.ShipTo.CountrySubdivisionName, 'Hessen');
  loadedInvoice.Free;
  desc.Free;
end;

procedure TZUGFeRD22Tests.TestShipToTradePartyOnItemLevel;
begin
  var desc := FInvoiceProvider.CreateInvoice();

  var Party := TZUGFeRDParty.Create;
  Party.Name := 'ShipTo';
  Party.City := 'ShipToCity';

  desc.TradeLineItems.First.ShipTo := Party;

  // test minimum
  var ms := TMemoryStream.create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Minimum);
  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.IsNotNull(loadedInvoice.TradeLineItems);
  Assert.IsNull(loadedInvoice.TradeLineItems.First().ShipTo);
  Assert.IsNull(loadedInvoice.TradeLineItems.First().UltimateShipTo);
  loadedInvoice.Free;

  // test basic
  ms := TMemoryStream.create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Basic);
  ms.Seek(0, soFromBeginning);
  loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.IsNotNull(loadedInvoice.TradeLineItems);
  Assert.IsNull(loadedInvoice.TradeLineItems.First().ShipTo);
  Assert.IsNull(loadedInvoice.TradeLineItems.First().UltimateShipTo);
  loadedInvoice.Free;

  // test comfort
  ms := TMemoryStream.create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Comfort);
  ms.Seek(0, soFromBeginning);
  loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.IsNotNull(loadedInvoice.TradeLineItems);
  Assert.IsNull(loadedInvoice.TradeLineItems.First().ShipTo);
  Assert.IsNull(loadedInvoice.TradeLineItems.First().UltimateShipTo);
  loadedInvoice.Free;

  // test extended
  ms := TMemoryStream.create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  ms.Seek(0, soFromBeginning);
  loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.IsNotNull(loadedInvoice.TradeLineItems);
  Assert.IsNotNull(loadedInvoice.TradeLineItems.First().ShipTo);
  Assert.IsNull(loadedInvoice.TradeLineItems.First().UltimateShipTo);

  Assert.AreEqual(loadedInvoice.TradeLineItems.First().ShipTo.Name, 'ShipTo');
  Assert.AreEqual(loadedInvoice.TradeLineItems.First().ShipTo.City, 'ShipToCity');
  loadedInvoice.Free;

  desc.Free;
end;

procedure TZUGFeRD22Tests.TestSpecifiedTradeAllowanceCharge(profile: TZUGFeRDProfile);
begin
  var invoice := FInvoiceProvider.CreateInvoice();
  try
    invoice.TradeLineItems[0].AddSpecifiedTradeAllowanceCharge(true, TZUGFeRDCurrencyCodes.EUR,
      TZUGFeRDNullableParam<Currency>.Create(198), 19.8, TZUGFeRDNullableParam<Currency>.Create(10), 'Discount 10%');

    var ms := TMemoryStream.Create;
    invoice.Save(ms, TZUGFeRDVersion.Version23, TZUGFerDProfile.Extended);
    ms.Position := 0;

    var loadedInvoice := TZUGFerDInvoiceDescriptor.Load(ms);
    ms.Free;
    var allowanceCharge := loadedInvoice.TradeLineItems[0].SpecifiedTradeAllowanceCharges.First();

    Assert.AreEqual(allowanceCharge.ChargeIndicator, false);//false = discount
    //CurrencyCodes are not written bei InvoiceDescriptor22Writer
    //Assert.AreEqual(allowanceCharge.Currency, CurrencyCodes.EUR);
    Assert.AreEqual(allowanceCharge.BasisAmount.Value, Currency(198));
    Assert.AreEqual(allowanceCharge.ActualAmount, Currency(19.8));
    Assert.AreEqual(allowanceCharge.ChargePercentage.Value, Currency(10));
    Assert.AreEqual(allowanceCharge.Reason, 'Discount 10%');
    loadedInvoice.Free;
  finally
    invoice.Free;
  end;

end;

procedure TZUGFeRD22Tests.TestSpecifiedTradeAllowanceChargeNotWrittenInMinimum;
begin
  var invoice := FInvoiceProvider.CreateInvoice();

  invoice.TradeLineItems[0].AddSpecifiedTradeAllowanceCharge(true,
    TZUGFeRDCurrencyCodes.EUR,
    TZUGFeRDNullableParam<Currency>.Create(198.0),
    19.8,
    TZUGFeRDNullableParam<Currency>.Create(10),
    'Discount 10%');

  var ms := TMemoryStream.create;
  invoice.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Minimum);
  ms.Position := 0;
  invoice.Free;

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.AreEqual(0, loadedInvoice.TradeLineItems[0].SpecifiedTradeAllowanceCharges.Count);
  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestSpecifiedTradePaymentTermsCalculationPercent;
begin
  var path := '..\..\..\documentation\zugferd23en\Examples\4. EXTENDED\EXTENDED_Warenrechnung\factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var desc := TZUGFeRDInvoiceDescriptor.Load(path);
  Assert.IsNotNull(desc.PaymentTermsList.First().Percentage);
  Assert.AreEqual(Currency(2.0), desc.PaymentTermsList.First().Percentage.Value);
  desc.Free;
end;

procedure TZUGFeRD22Tests.TestSpecifiedTradePaymentTermsDescription;
begin
  var path := '..\..\..\documentation\zugferd23en\Examples\4. EXTENDED\EXTENDED_Warenrechnung\factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var desc := TZUGFeRDInvoiceDescriptor.Load(path);
  Assert.IsNotEmpty(desc.PaymentTermsList.First().Description);
  Assert.AreEqual('Bei Zahlung innerhalb 14 Tagen gewähren wir 2,0% Skonto.',
    desc.PaymentTermsList.First().Description);
  desc.Free;
end;

procedure TZUGFeRD22Tests.TestSpecifiedTradePaymentTermsDueDate;
begin
  var path := '..\..\..\documentation\zugferd23en\Examples\2. BASIC\BASIC_Einfach\factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var desc := TZUGFeRDInvoiceDescriptor.Load(path);
  Assert.IsTrue(desc.PaymentTermsList.First().DueDate.HasValue);
  Assert.AreEqual(EncodeDate(2024, 12, 15), desc.PaymentTermsList.First().DueDate.Value);
  desc.Free;
end;

procedure TZUGFeRD22Tests.TestStoringReferenceBasicFacturXInvoice;
var
  path: string;
  originalDesc: TZUGFeRDInvoiceDescriptor;
begin
  path := '..\..\..\demodata\zugferd21\zugferd_2p1_BASIC_Einfach-factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var s := TFileStream.Create(path, fmOpenRead);
  originalDesc := TZUGFeRDInvoiceDescriptor.Load(s);
  s.Free;
  try
    Assert.AreEqual(originalDesc.Profile, TZUGFeRDProfile.Basic);
    Assert.AreEqual(originalDesc.Type_, TZUGFeRDInvoiceType.Invoice);
    Assert.AreEqual(originalDesc.InvoiceNo, '471102');
    Assert.AreEqual(originalDesc.TradeLineItems.Count, 1);
    Assert.IsTrue(TZUGFeRDHelper.TrueForAll<TZUGFeRDTradeLineItem>(originalDesc.TradeLineItems,
      function(Item: TZUGFeRDTradeLineItem): Boolean
      begin
        result := Item.BillingPeriodStart = nil;
      end));

    Assert.IsTrue(TZUGFeRDHelper.TrueForAll<TZUGFeRDTradeLineItem>(originalDesc.TradeLineItems,
      function(Item: TZUGFeRDTradeLineItem): Boolean
      begin
        result := Item.BillingPeriodEnd = nil;
      end));
    Assert.IsTrue(TZUGFeRDHelper.TrueForAll<TZUGFeRDTradeLineItem>(originalDesc.TradeLineItems,
      function(Item: TZUGFeRDTradeLineItem): Boolean
      begin
        result := Item.ApplicableProductCharacteristics.Count = 0;
      end));
    Assert.AreEqual(originalDesc.LineTotalAmount.Value, Currency(198.0));
    Assert.AreEqual(originalDesc.Taxes[0].TaxAmount, Currency(37.62));
    Assert.AreEqual(originalDesc.Taxes[0].Percent, Currency(19.0));
    originalDesc.IsTest := false;

    var ms := TMemoryStream.Create;
    originalDesc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Basic);
    originalDesc.Save('zugferd_2p1_BASIC_Einfach-factur-x_Result.xml', TZUGFeRDVersion.Version23);

    var desc := TZUGFeRDInvoiceDescriptor.Load(ms);
    ms.Free;

    Assert.AreEqual(desc.Profile, TZUGFeRDProfile.Basic);
    Assert.AreEqual(desc.Type_, TZUGFeRDInvoiceType.Invoice);
    Assert.AreEqual(desc.InvoiceNo, '471102');
    Assert.AreEqual(desc.TradeLineItems.Count, 1);
    Assert.IsTrue(TZUGFeRDHelper.TrueForAll<TZUGFeRDTradeLineItem>(desc.TradeLineItems,
      function(Item: TZUGFeRDTradeLineItem): Boolean
      begin
        result := Item.BillingPeriodStart = nil;
      end));
    Assert.IsTrue(TZUGFeRDHelper.TrueForAll<TZUGFeRDTradeLineItem>(desc.TradeLineItems,
      function(Item: TZUGFeRDTradeLineItem): Boolean
      begin
        result := Item.BillingPeriodEnd = nil
      end));
    Assert.IsTrue(TZUGFeRDHelper.TrueForAll<TZUGFeRDTradeLineItem>(desc.TradeLineItems,
      function(Item: TZUGFeRDTradeLineItem): Boolean
      begin
        result := Item.ApplicableProductCharacteristics.Count = 0;
      end));
    Assert.AreEqual(desc.LineTotalAmount.Value, Currency(198.0));
    Assert.AreEqual(desc.Taxes[0].TaxAmount, Currency(37.62));
    Assert.AreEqual(desc.Taxes[0].Percent, Currency(19.0));
    desc.Free;
  finally
    originalDesc.Free;
  end;

end;

procedure TZUGFeRD22Tests.TestStoringSepaPreNotification;
begin
  var d := TZUGFeRDInvoiceDescriptor.Create;
  d.Type_ := TZUGFeRDInvoiceType.Invoice;
  d.InvoiceNo := '471102';
  d.Currency := TZUGFeRDCurrencyCodes.EUR;
  d.InvoiceDate := EncodeDate(2018, 3, 5);
  d.AddTradeLineItem('1', 'Trennblätter A4', '',
      TZUGFeRDQuantityCodes.H87,
      nil,
      TZUGFeRDNullableParam<Double>.Create(9.9),
      TZUGFeRDNullableParam<Double>.Create(9.9),
      Double(20),
      0,
      TZUGFeRDTaxTypes.VAT,
      TZUGFeRDTaxCategoryCodes.S,
      Double(19.0),
      '',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.EAN, '4012345001235'),
      'TB100A4'
      );
  d.AddTradeLineItem('2', 'Joghurt Banane', '',
      TZUGFeRDQuantityCodes.H87,
      nil,
      TZUGFeRDNullableParam<Double>.Create(5.5),
      TZUGFeRDNullableParam<Double>.Create(5.5),
      Double(50),
      0,
      TZUGFeRDTaxTypes.VAT,
      TZUGFeRDTaxCategoryCodes.S,
      Double(7.0),
      '',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.EAN, '4000050986428'),
      'ARNR2'
      );

  d.SetSeller('Lieferant GmbH', '80333', 'München', 'Lieferantenstraße 20',
      TZUGFeRDCountryCodes.DE, '', TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN,
        '4000001123452'), TZUGFeRDLegalOrganization.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN,
          '4000001123452', 'Lieferant GmbH'));
  d.SetBuyer('Kunden AG Mitte', '69876', 'Frankfurt', 'Kundenstraße 15',
      TZUGFeRDCountryCodes.DE, 'GE2020211',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN, '4000001987658'));

  d.SetPaymentMeansSepaDirectDebit('DE98ZZZ09999999999', 'REF A-123');
  d.AddDebitorFinancialAccount('DE21860000000086001055', '');
  var _tempPaymentTerms := TZUGFeRDPaymentTerms.Create;
  _tempPaymentTerms.Description :=
      'Der Betrag in Höhe von EUR 529,87 wird am 20.03.2018 von Ihrem Konto per SEPA-Lastschrift eingezogen.';
  d.PaymentTermsList.Add(_tempPaymentTerms);

  d.SetTotals(
      TZUGFerdNullableParam<Currency>.Create(473.00),
      nil,
      nil,
      TZUGFeRDNullableParam<Currency>.create(473.00),
      TZUGFeRDNullableParam<Currency>.create(56.87),
      TZUGFeRDNullableParam<Currency>.create(529.87),
      nil,
      TZUGFeRDNullableParam<Currency>.create(529.87));
  d.SellerTaxRegistration.Add(TZUGFeRDTaxRegistration.CreateWithParams(
    TZUGFeRDTaxRegistrationSchemeID.FC, '201/113/40209'));

  d.SellerTaxRegistration.Add(TZUGFeRDTaxRegistration.CreateWithParams(
    TZUGFeRDTaxRegistrationSchemeID.VA, 'DE123456789'));
  d.AddApplicableTradeTax(275.00, 7.00, (275.00 / 100 * 7.00), TZUGFeRDTaxTypes.VAT,
    TZUGFeRDNullableParam<TZUGFeRDTaxCategoryCodes>.Create(TZUGFeRDTaxCategoryCodes.S));
  d.AddApplicableTradeTax(198.00, 19.00, (198.00 / 100 * 19.00), TZUGFeRDTaxTypes.VAT,
    TZUGFeRDNullableParam<TZUGFeRDTaxCategoryCodes>.Create(TZUGFeRDTaxCategoryCodes.S));

  var stream := TMemoryStream.Create;
  d.Save(stream, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Comfort);
  d.Free;

  stream.Seek(0, soBeginning);
  var d2 := TZUGFeRDInvoiceDescriptor.Load(stream);
  stream.Free;

  Assert.AreEqual('DE98ZZZ09999999999', d2.PaymentMeans.SEPACreditorIdentifier);
  Assert.AreEqual('REF A-123', d2.PaymentMeans.SEPAMandateReference);
  Assert.AreEqual(1, d2.DebitorBankAccounts.Count);
  Assert.AreEqual('DE21860000000086001055', d2.DebitorBankAccounts[0].IBAN);
  Assert.AreEqual('0088', TZUGFeRDGlobalIDSchemeIdentifiersExtensions.EnumToString(
    d2.Seller.SpecifiedLegalOrganization.ID.SchemeID));
  Assert.AreEqual('4000001123452', d2.Seller.SpecifiedLegalOrganization.ID.ID);
  Assert.AreEqual('Lieferant GmbH', d2.Seller.SpecifiedLegalOrganization.TradingBusinessName);
  d2.Free;

end;

procedure TZUGFeRD22Tests.TestTotalRoundingExtended;
var
  desc: TZUGFerDInvoiceDescriptor;
begin
  var uuid := TZUGFerdHelper.CreateUuid;
  var issueDateTime: TDateTime := Date;

  desc := FInvoiceProvider.CreateInvoice();
  try
    desc.ContractReferencedDocument := TZUGFeRDContractReferencedDocument.CreateWithParams(uuid, IssueDateTime);
    desc.SetTotals(
      TZUGFeRDNullableParam<Currency>.create(1.99),
      TZUGFeRDNullableParam<Currency>.create(0),
      TZUGFeRDNullableParam<Currency>.create(0),
      TZUGFeRDNullableParam<Currency>.create(0),
      TZUGFeRDNullableParam<Currency>.create(0),
      TZUGFeRDNullableParam<Currency>.create(2),
      TZUGFeRDNullableParam<Currency>.create(0),
      TZUGFeRDNullableParam<Currency>.create(2),
      TZUGFeRDNullableParam<Currency>.create(0.01));

    var msExtended := TMemoryStream.Create;
    desc.Save(msExtended, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
    msExtended.Seek(0, soBeginning);

    var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(msExtended);
    msExtended.Free;
    Assert.AreEqual(loadedInvoice.RoundingAmount.Value, Currency(0.01));
    loadedInvoice.Free;

    var msBasic := TMemoryStream.Create;
    desc.Save(msBasic, TZUGFeRDVersion.Version23);
    msBasic.Seek(0, soBeginning);

    loadedInvoice := TZUGFerDInvoiceDescriptor.Load(msBasic);
    msBasic.Free;
    Assert.AreEqual(loadedInvoice.RoundingAmount.Value, Currency(0));
    loadedInvoice.Free;
  finally
    desc.Free;
  end;
end;

procedure TZUGFeRD22Tests.TestTotalRoundingXRechnung;
var
  desc: TZUGFerDInvoiceDescriptor;
begin
  var uuid := TZUGFerdHelper.CreateUuid;
  var issueDateTime: TDateTime := Date;

  desc := FInvoiceProvider.CreateInvoice();
  try
    desc.ContractReferencedDocument := TZUGFeRDContractReferencedDocument.CreateWithParams(uuid, IssueDateTime);
    desc.SetTotals(
      TZUGFeRDNullableParam<Currency>.create(1.99),
      TZUGFeRDNullableParam<Currency>.create(0),
      TZUGFeRDNullableParam<Currency>.create(0),
      TZUGFeRDNullableParam<Currency>.create(0),
      TZUGFeRDNullableParam<Currency>.create(0),
      TZUGFeRDNullableParam<Currency>.create(2),
      TZUGFeRDNullableParam<Currency>.create(0),
      TZUGFeRDNullableParam<Currency>.create(2),
      TZUGFeRDNullableParam<Currency>.create(0.01));

    var msExtended := TMemoryStream.Create;
    desc.Save(msExtended, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);
    msExtended.Seek(0, soBeginning);

    var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(msExtended);
    msExtended.Free;
    Assert.AreEqual(loadedInvoice.RoundingAmount.Value, Currency(0.01));
    loadedInvoice.Free;

    var msBasic := TMemoryStream.Create;
    desc.Save(msBasic, TZUGFeRDVersion.Version23);
    msBasic.Seek(0, soBeginning);

    loadedInvoice := TZUGFerDInvoiceDescriptor.Load(msBasic);
    msBasic.Free;
    Assert.AreEqual(loadedInvoice.RoundingAmount.Value, Currency(0));
    loadedInvoice.Free;
  finally
    desc.Free;
  end;
end;

procedure TZUGFeRD22Tests.TestTradeAllowanceChargeWithExplicitPercentage;
begin
  var invoice := FInvoiceProvider.CreateInvoice();

  // fake values, does not matter for our test case
  invoice.AddTradeAllowanceCharge(true, 100,
    TZUGFeRDCurrencyCodes.EUR, 10, 12,
    '', TZUGFeRDTaxTypes.VAT,
    TZUGFeRDTaxCategoryCodes.S, 19);

  var ms := TMemoryStream.Create;
  invoice.Save(ms, TZUGFeRDVersion.Version23, TZUGfeRDProfile.Extended);
  invoice.Free;
  ms.Position := 0;
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;
  var allowanceCharges := loadedInvoice.TradeAllowanceCharges;

  Assert.IsTrue(allowanceCharges.Count = 1);
  Assert.AreEqual(allowanceCharges[0].BasisAmount.Value, Currency(100));
  Assert.AreEqual(allowanceCharges[0].Amount, Currency(10));
  Assert.AreEqual(allowanceCharges[0].ChargePercentage.Value, Currency(12));
  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestTradeAllowanceChargeWithoutExplicitPercentage;
begin
  var invoice := FInvoiceProvider.CreateInvoice();

  // fake values, does not matter for our test case
  invoice.AddTradeAllowanceCharge(true, TZUGFeRDNullableParam<Currency>.create(100),
    TZUGFeRDCurrencyCodes.EUR, 10, '',
    TZUGFeRDTaxTypes.VAT, TZUGFeRDTaxCategoryCodes.S, 19);

  var ms := TMemoryStream.Create;
  invoice.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  invoice.Free;
  ms.Position := 0;

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  var allowanceCharges := loadedInvoice.TradeAllowanceCharges;

  Assert.IsTrue(allowanceCharges.Count = 1);
  Assert.AreEqual(allowanceCharges[0].BasisAmount.value, Currency(100));
  Assert.AreEqual(allowanceCharges[0].Amount, Currency(10));
  Assert.AreEqual(allowanceCharges[0].ChargePercentage.Value, Currency(0));
  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestTradeLineItemUnitChargeFreePackageQuantity;
begin
  var path := '..\..\..\documentation\zugferd23en\Examples\4. EXTENDED\EXTENDED_Warenrechnung\factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var desc := TZUGFeRDInvoiceDescriptor.Load(path);
  Assert.IsNull(desc.TradeLineItems.First().UnitQuantity);
  Assert.IsNull(desc.TradeLineItems.First().ChargeFreeQuantity);
  Assert.IsNotNull(desc.TradeLineItems.First().PackageQuantity);
  desc.Free;
end;

procedure TZUGFeRD22Tests.TestUltimateShipToTradePartyOnItemLevel;
begin
  var desc := FInvoiceProvider.CreateInvoice;

  var Party := TZUGFeRDParty.create;
  Party.Name := 'ShipTo';
  Party.City := 'ShipToCity';

  desc.TradeLineItems.First.UltimateShipTo := Party;

  // test minimum
  var ms := TMemoryStream.create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Minimum);
  ms.Seek(0, soFromBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.IsNotNull(loadedInvoice.TradeLineItems);
  Assert.IsNull(loadedInvoice.TradeLineItems.First.ShipTo);
  Assert.IsNull(loadedInvoice.TradeLineItems.First.UltimateShipTo);
  loadedInvoice.Free;

  // test basic
  ms := TMemoryStream.create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Basic);
  ms.Seek(0, soFromBeginning);
  loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.IsNotNull(loadedInvoice.TradeLineItems);
  Assert.IsNull(loadedInvoice.TradeLineItems.First.ShipTo);
  Assert.IsNull(loadedInvoice.TradeLineItems.First.UltimateShipTo);
  loadedInvoice.Free;

  // test comfort
  ms := TMemoryStream.create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Comfort);
  ms.Seek(0, soFromBeginning);
  loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.IsNotNull(loadedInvoice.TradeLineItems);
  Assert.IsNull(loadedInvoice.TradeLineItems.First().ShipTo);
  Assert.IsNull(loadedInvoice.TradeLineItems.First().UltimateShipTo);
  loadedInvoice.Free;

  // test extended
  ms := TMemoryStream.create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  ms.Seek(0, soFromBeginning);
  loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.IsNotNull(loadedInvoice.TradeLineItems);
  Assert.IsNull(loadedInvoice.TradeLineItems.First.ShipTo);
  Assert.IsNotNull(loadedInvoice.TradeLineItems.First.UltimateShipTo);

  Assert.AreEqual(loadedInvoice.TradeLineItems.First.UltimateShipTo.Name, 'ShipTo');
  Assert.AreEqual(loadedInvoice.TradeLineItems.First.UltimateShipTo.City, 'ShipToCity');
  loadedInvoice.Free;

  desc.Free;

end;

procedure TZUGFeRD22Tests.TestValidTaxTypes;
begin
  var invoice := FInvoiceProvider.CreateInvoice();
  for var Item  in invoice.TradeLineItems do
    Item.TaxType := TZUGFeRDTaxTypes.VAT;

  var ms := TMemoryStream.Create;
  try
    invoice.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Basic);
  except
    on E:Exception do
      Assert.Fail('', E);
  end;

  try
    invoice.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.BasicWL);

  except
      Assert.Fail();
  end;

  try
    invoice.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Comfort);
  except
    Assert.Fail();
  end;

  try
    invoice.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  except
      Assert.Fail();
  end;

  try
    invoice.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung1);
  except
    Assert.Fail();
  end;

  for var Item  in invoice.TradeLineItems do
    Item.TaxType := TZUGFeRDTaxTypes.AAA;

  try
    invoice.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);
  except
      Assert.Fail();
  end;

  // extended profile supports other tax types as well:
//  invoice.TradeLineItems.ForEach(i => i.TaxType = TaxTypes.AAA);
  try
    invoice.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  except
    Assert.Fail();
  end;
  Assert.AreEqual(TZUGFeRDInvoiceType.Invoice, Invoice.Type_);

  ms.Free;
  Invoice.Free;
end;

procedure TZUGFeRD22Tests.TestWriteAndReadBusinessProcess;
begin
  var desc := FInvoiceProvider.CreateInvoice();
  desc.BusinessProcess := 'A1';

  var ms := TMemoryStream.Create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  desc.Free;
  ms.Seek(0, soBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.AreEqual('A1', loadedInvoice.BusinessProcess);
  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestWriteAndReadDespatchAdviceDocumentReferenceExtended;
begin
  var desc := FInvoiceProvider.CreateInvoice();
  var despatchAdviceNo := '421567982';
  var despatchAdviceDate: ZUGFerdNullable<TDateTime> := EncodeDate(2024, 5, 14);
  desc.SetDespatchAdviceReferencedDocument(despatchAdviceNo, despatchAdviceDate);

  var ms := TMemoryStream.Create;
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  desc.Free;

  ms.Seek(0, soBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.AreEqual(despatchAdviceNo, loadedInvoice.DespatchAdviceReferencedDocument.ID);
  Assert.AreEqual(despatchAdviceDate.Value, loadedInvoice.DespatchAdviceReferencedDocument.IssueDateTime.Value);
  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestWriteAndReadDespatchAdviceDocumentReferenceXRechnung;
begin
  var desc := FInvoiceProvider.CreateInvoice();
  var despatchAdviceNo := '421567982';
  var despatchAdviceDate: ZUGFerdNullable<TDateTime> := EncodeDate(2024, 5, 14);
  desc.SetDespatchAdviceReferencedDocument(despatchAdviceNo, despatchAdviceDate);

  var ms := TMemoryStream.Create;
  var fs := TFileStream.Create('TestWriteAndReadDespatchAdviceDocumentReferenceXRechnung.xml', fmCreate);
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);
  desc.Save(fs, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);
  fs.Free;
  desc.Free;

  ms.Seek(0, soBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.IsNull(loadedInvoice.DespatchAdviceReferencedDocument);
  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestWriteAndReadExtended;
var
  data: TBytes;
begin
  var desc := FInvoiceProvider.CreateInvoice();
  var filename2 := 'myrandomdata.bin';
  var timestamp: TDateTime := Date;

  SetLength(data, 32768);
  RandomizeByteArray(data);

  var msref1 := TMemoryStream.Create;
  msref1.WriteBuffer(data[0], Length(data));
  msref1.Position := 0;

  desc.AddAdditionalReferencedDocument(
      'My-File-BIN',
      TZUGFeRDAdditionalReferencedDocumentTypeCode.ReferenceDocument,
      TZUGFeRDNullableParam<TDateTime>.Create(timestamp.IncDay(-2)),
      'EmbeddedPdf',
      nil,
      msref1,
      filename2);

  desc.OrderNo := '12345';
  desc.OrderDate := timestamp;

  desc.SetContractReferencedDocument('12345', TZUGFeRDNullableParam<TDateTime>.create(timestamp));

  desc.SpecifiedProcuringProject := TZUGFeRDSpecifiedProcuringProject.CreateWithParams('123', 'Project 123');

  var _ShipTo := TZUGFeRDParty.Create;
  _shipTo.ID := TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.Unknown, '123');
  _ShipTo.GlobalID := TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.DUNS, '789');
  _ShipTo.Name := 'Ship To';
  _ShipTo.ContactName := 'Max Mustermann';
  _ShipTo.Street := 'Münchnerstr. 55';
  _ShipTo.Postcode := '83022';
  _ShipTo.City := 'Rosenheim';
  _ShipTo.Country := TZUGFeRDCountryCodes.DE;

  desc.ShipTo := _ShipTo;

  var _UltimateShipTo := TZUGFeRDParty.Create;
  _UltimateShipTo.ID := TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.Unknown, '123');
  _UltimateShipTo.GlobalID := TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.DUNS, '789');
  _UltimateShipTo.Name := 'Ultimate Ship To';
  _UltimateShipTo.ContactName := 'Max Mustermann';
  _UltimateShipTo.Street := 'Münchnerstr. 55';
  _UltimateShipTo.Postcode := '83022';
  _UltimateShipTo.City := 'Rosenheim';
  _UltimateShipTo.Country := TZUGFeRDCountryCodes.DE;

  desc.UltimateShipTo := _UltimateShipTo;


  var _ShipFrom := TZUGFeRDParty.create;
  _ShipFrom.ID := TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.Unknown, '123');
  _ShipFrom.GlobalID := TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.DUNS, '789');
  _ShipFrom.Name := 'Ship From';
  _ShipFrom.ContactName := 'Eva Musterfrau';
  _ShipFrom.Street := 'Alpenweg 5';
  _ShipFrom.Postcode := '83022';
  _ShipFrom.City := 'Rosenheim';
  _ShipFrom.Country := TZUGFeRDCountryCodes.DE;

  desc.ShipFrom := _ShipFrom;

  desc.PaymentMeans.SEPACreditorIdentifier := 'SepaID';
  desc.PaymentMeans.SEPAMandateReference := 'SepaMandat';
  desc.PaymentMeans.FinancialCard := TZUGFeRDFinancialCard.CreateWithParams('123', 'Mustermann');

  desc.PaymentReference := 'PaymentReference';

  var _Invoicee := TZUGFeRDParty.Create;
  _Invoicee.Name := 'Test';
  _Invoicee.ContactName := 'Max Mustermann';
  _Invoicee.Postcode := '83022';
  _Invoicee.City := 'Rosenheim';
  _Invoicee.Street := 'Münchnerstraße 123';
  _Invoicee.AddressLine3 := 'EG links';
  _Invoicee.CountrySubdivisionName := 'Bayern';
  _Invoicee.Country := TZUGFeRDCountryCodes.DE;

  desc.Invoicee := _Invoicee;

  var _Payee := TZUGFeRDParty.Create;
  _Payee.Name := 'Test';
  _Payee.ContactName := 'Max Mustermann';
  _Payee.Postcode := '83022';
  _Payee.City := 'Rosenheim';
  _Payee.Street := 'Münchnerstraße 123';
  _Payee.AddressLine3 := 'EG links';
  _Payee.CountrySubdivisionName := 'Bayern';
  _Payee.Country := TZUGFeRDCountryCodes.DE;

  desc.Payee := _Payee; // this information will not be stored in the output file since it is available in Extended profile only

  desc.AddDebitorFinancialAccount('DE02120300000000202052', 'BYLADEM1001', '', '', 'Musterbank');
  desc.BillingPeriodStart := timestamp;
  desc.BillingPeriodEnd := timestamp.IncDay(14);

  desc.AddTradeAllowanceCharge(false, TZUGFerDNullableParam<Currency>.Create(5),
    TZUGFeRDCurrencyCodes.EUR, 15, 'Reason for charge',
    TZUGFeRDTaxTypes.AAB, TZUGFeRDTaxCategoryCodes.AB, 19.0, TZUGFeRDAllowanceReasonCodes.Packaging);
  desc.AddLogisticsServiceCharge(10, 'Logistics service charge', TZUGFeRDTaxTypes.AAC, TZUGFeRDTaxCategoryCodes.AC, 7);

  desc.PaymentTermsList[0].DueDate := timestamp.IncDay(14);
  desc.AddInvoiceReferencedDocument('RE-12345', timestamp);


  //set additional LineItem data
  var lineItem := TZUGFeRDHelper.FindFirstMatchingItem<TZUGFerdTradeLineItem>(desc.TradeLineItems,
    function(Item: TZUGFeRDTradeLineItem): Boolean
    begin
      result := Item.SellerAssignedID = 'TB100A4';
    end);
  Assert.IsNotNull(lineItem);
  lineItem.Description := 'This is line item TB100A4';
  lineItem.BuyerAssignedID := '0815';
  lineItem.SetOrderReferencedDocument('12345', TZUGFeRDNullableParam<TDateTime>.Create(timestamp), '1');
  lineItem.SetDeliveryNoteReferencedDocument('12345', TZUGFeRDNullableParam<TDateTime>.Create(timestamp), '1');
  lineItem.SetContractReferencedDocument('12345', TZUGFeRDNullableParam<TDateTime>.Create(timestamp), '1');

  // To align with PEPPOL-EN16931-R101, this shall be ignored
  lineItem.AddAdditionalReferencedDocument('xyz',
    TZUGFeRDAdditionalReferencedDocumentTypeCode.ReferenceDocument,
    TZUGFeRDNullableParam<TZUGFeRDReferenceTypeCodes>.create(TZUGFeRDReferenceTypeCodes.AAB),
    TZUGFeRDNullableParam<TDateTime>.Create(timestamp));

  lineItem.AddAdditionalReferencedDocument('abc',
    TZUGFeRDAdditionalReferencedDocumentTypeCode.InvoiceDataSheet,
    TZUGFeRDNullableParam<TZUGFeRDReferenceTypeCodes>.create(TZUGFeRDReferenceTypeCodes.PP),
    TZUGFeRDNullableParam<TDateTime>.Create(timestamp));

  lineItem.UnitQuantity := 3;
  lineItem.ActualDeliveryDate := timestamp;

  lineItem.ApplicableProductCharacteristics.Add(
    TZUGFeRDApplicableProductCharacteristic.CreateWithParams('Product characteristics', 'Product value'));

  lineItem.BillingPeriodStart := timestamp;
  lineItem.BillingPeriodEnd := timestamp.IncDay(10);

  lineItem.AddReceivableSpecifiedTradeAccountingAccount('987654');
  lineItem.AddTradeAllowanceCharge(false, TZUGFeRDCurrencyCodes.EUR,
  TZUGFeRDNullableParam<Currency>.Create(10), 50, 'Reason: UnitTest',
  TZUGFeRDAllowancereasonCodes.Packaging);


  var ms := TMemoryStream.create;
  var fs := TFileStream.create('Test22.xml', fmcreate);
  desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  desc.Save(fs, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  fs.Free;
  desc.Free;

  ms.Seek(0, soBeginning);
  Assert.AreEqual(TZUGFeRDInvoiceDescriptor.GetVersion(ms), TZUGFeRDVersion.Version23);

  ms.Seek(0, soBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.AreEqual('471102', loadedInvoice.InvoiceNo);
  Assert.AreEqual(EncodeDate(2018, 03, 05), loadedInvoice.InvoiceDate.Value);
  Assert.AreEqual(TZUGFeRDCurrencyCodes.EUR, loadedInvoice.Currency);
  Assert.IsTrue(TZUGFeRDHelper.Any<TZUGFeRDNote>(loadedInvoice.Notes,
    function(Item: TZUGFeRDNote): Boolean
    begin
      result := Item.Content = 'Rechnung gemäß Bestellung vom 01.03.2018.';
    end));
  Assert.AreEqual('04011000-12345-34', loadedInvoice.ReferenceOrderNo);
  Assert.AreEqual('Lieferant GmbH', loadedInvoice.Seller.Name);
  Assert.AreEqual('80333', loadedInvoice.Seller.Postcode);
  Assert.AreEqual('München', loadedInvoice.Seller.City);

  Assert.AreEqual('Lieferantenstraße 20', loadedInvoice.Seller.Street);
  Assert.AreEqual(TZUGFeRDCountryCodes.DE, loadedInvoice.Seller.Country);
  Assert.AreEqual(TZUGFeRDGlobalIDSchemeIdentifiers.GLN, loadedInvoice.Seller.GlobalID.SchemeID.Value);
  Assert.AreEqual('4000001123452', loadedInvoice.Seller.GlobalID.ID);
  Assert.AreEqual('Max Mustermann', loadedInvoice.SellerContact.Name);
  Assert.AreEqual('Muster-Einkauf', loadedInvoice.SellerContact.OrgUnit);
  Assert.AreEqual('Max@Mustermann.de', loadedInvoice.SellerContact.EmailAddress);
  Assert.AreEqual('+49891234567', loadedInvoice.SellerContact.PhoneNo);

  Assert.AreEqual('Kunden AG Mitte', loadedInvoice.Buyer.Name);
  Assert.AreEqual('69876', loadedInvoice.Buyer.Postcode);
  Assert.AreEqual('Frankfurt', loadedInvoice.Buyer.City);
  Assert.AreEqual('Kundenstraße 15', loadedInvoice.Buyer.Street);
  Assert.AreEqual(TZUGFeRDCountryCodes.DE, loadedInvoice.Buyer.Country);
  Assert.AreEqual<string>('GE2020211', loadedInvoice.Buyer.ID.ID);

  Assert.AreEqual('12345', loadedInvoice.OrderNo);
  Assert.AreEqual(timestamp, loadedInvoice.OrderDate.Value);

  Assert.AreEqual('12345', loadedInvoice.ContractReferencedDocument.ID);
  Assert.AreEqual(timestamp, loadedInvoice.ContractReferencedDocument.IssueDateTime.Value);

  Assert.AreEqual('123', loadedInvoice.SpecifiedProcuringProject.ID);
  Assert.AreEqual('Project 123', loadedInvoice.SpecifiedProcuringProject.Name);

  Assert.AreEqual('Ultimate Ship To', loadedInvoice.UltimateShipTo.Name);

  Assert.AreEqual<string>('123', loadedInvoice.ShipTo.ID.ID);
  Assert.AreEqual(TZUGFeRDGlobalIDSchemeIdentifiers.DUNS, loadedInvoice.ShipTo.GlobalID.SchemeID.Value);
  Assert.AreEqual('789', loadedInvoice.ShipTo.GlobalID.ID);
  Assert.AreEqual('Ship To', loadedInvoice.ShipTo.Name);
  Assert.AreEqual('Max Mustermann', loadedInvoice.ShipTo.ContactName);
  Assert.AreEqual('Münchnerstr. 55', loadedInvoice.ShipTo.Street);
  Assert.AreEqual('83022', loadedInvoice.ShipTo.Postcode);
  Assert.AreEqual('Rosenheim', loadedInvoice.ShipTo.City);
  Assert.AreEqual(TZUGFeRDCountryCodes.DE, loadedInvoice.ShipTo.Country);

  Assert.AreEqual<string>('123', loadedInvoice.ShipFrom.ID.ID);
  Assert.AreEqual(TZUGFeRDGlobalIDSchemeIdentifiers.DUNS, loadedInvoice.ShipFrom.GlobalID.SchemeID.Value);
  Assert.AreEqual('789', loadedInvoice.ShipFrom.GlobalID.ID);
  Assert.AreEqual('Ship From', loadedInvoice.ShipFrom.Name);
  Assert.AreEqual('Eva Musterfrau', loadedInvoice.ShipFrom.ContactName);
  Assert.AreEqual('Alpenweg 5', loadedInvoice.ShipFrom.Street);
  Assert.AreEqual('83022', loadedInvoice.ShipFrom.Postcode);
  Assert.AreEqual('Rosenheim', loadedInvoice.ShipFrom.City);
  Assert.AreEqual(TZUGFeRDCountryCodes.DE, loadedInvoice.ShipFrom.Country);

  Assert.AreEqual(EncodeDate(2018, 03, 05), loadedInvoice.ActualDeliveryDate.Value);
  Assert.AreEqual(TZUGFeRDPaymentMeansTypeCodes.SEPACreditTransfer, loadedInvoice.PaymentMeans.TypeCode);
  Assert.AreEqual('Zahlung per SEPA Überweisung.', loadedInvoice.PaymentMeans.Information);

  Assert.AreEqual('PaymentReference', loadedInvoice.PaymentReference);

  Assert.AreEqual('', loadedInvoice.PaymentMeans.SEPACreditorIdentifier);
  Assert.AreEqual('SepaMandat', loadedInvoice.PaymentMeans.SEPAMandateReference);
  Assert.AreEqual('123', loadedInvoice.PaymentMeans.FinancialCard.Id);
  Assert.AreEqual('Mustermann', loadedInvoice.PaymentMeans.FinancialCard.CardholderName);

  var bankAccount := TZUGFeRDHelper.FindFirstMatchingItem<TZUGFeRDBankAccount>(loadedInvoice.CreditorBankAccounts,
    function(Item: TZUGFeRDBankAccount): Boolean
    begin
      result := Item.IBAN = 'DE02120300000000202051';
    end);
  Assert.IsNotNull(bankAccount);
  Assert.AreEqual('Kunden AG', bankAccount.Name);
  Assert.AreEqual('DE02120300000000202051', bankAccount.IBAN);
  Assert.AreEqual('BYLADEM1001', bankAccount.BIC);

  var debitorBankAccount := TZUGFeRDHelper.FindFirstMatchingItem<TZUGFeRDBankAccount>(loadedInvoice.DebitorBankAccounts,
    function(Item: TZUGFeRDBankAccount): Boolean
    begin
      result := Item.IBAN = 'DE02120300000000202052';
    end);
  Assert.IsNotNull(debitorBankAccount);
  Assert.AreEqual('DE02120300000000202052', debitorBankAccount.IBAN);


  Assert.AreEqual('Test', loadedInvoice.Invoicee.Name);
  Assert.AreEqual('Max Mustermann', loadedInvoice.Invoicee.ContactName);
  Assert.AreEqual('83022', loadedInvoice.Invoicee.Postcode);
  Assert.AreEqual('Rosenheim', loadedInvoice.Invoicee.City);
  Assert.AreEqual('Münchnerstraße 123', loadedInvoice.Invoicee.Street);
  Assert.AreEqual('EG links', loadedInvoice.Invoicee.AddressLine3);
  Assert.AreEqual('Bayern', loadedInvoice.Invoicee.CountrySubdivisionName);
  Assert.AreEqual(TZUGFeRDCountryCodes.DE, loadedInvoice.Invoicee.Country);

  Assert.AreEqual('Test', loadedInvoice.Payee.Name);
  Assert.AreEqual('Max Mustermann', loadedInvoice.Payee.ContactName);
  Assert.AreEqual('83022', loadedInvoice.Payee.Postcode);
  Assert.AreEqual('Rosenheim', loadedInvoice.Payee.City);
  Assert.AreEqual('Münchnerstraße 123', loadedInvoice.Payee.Street);
  Assert.AreEqual('EG links', loadedInvoice.Payee.AddressLine3);
  Assert.AreEqual('Bayern', loadedInvoice.Payee.CountrySubdivisionName);
  Assert.AreEqual(TZUGFeRDCountryCodes.DE, loadedInvoice.Payee.Country);


  var tax := TZUGFeRDHelper.FindFirstMatchingItem<TZUGFeRDTax>(loadedInvoice.Taxes,
    function(Item: TZUGFeRDTax): Boolean
    begin
      result := Item.BasisAmount = 275;
    end);
  Assert.IsNotNull(tax);
  Assert.AreEqual(Currency(275), tax.BasisAmount);
  Assert.AreEqual(Currency(7), tax.Percent);
  Assert.AreEqual(TZUGFeRDTaxTypes.VAT, tax.TypeCode);
  Assert.AreEqual(TZUGFeRDTaxCategoryCodes.S, tax.CategoryCode.Value);

  Assert.AreEqual(timestamp, loadedInvoice.BillingPeriodStart.Value);
  Assert.AreEqual(timestamp.IncDay(14), loadedInvoice.BillingPeriodEnd.Value);

  //TradeAllowanceCharges
  var tradeAllowanceCharge := TZUGFeRDHelper.FindFirstMatchingItem<TZUGFeRDTradeAllowanceCharge>(
    loadedInvoice.TradeAllowanceCharges, function(Item: TZUGFeRDTradeAllowanceCharge): Boolean
    begin
      result := Item.Reason = 'Reason for charge';
    end);
  Assert.IsNotNull(tradeAllowanceCharge);
  Assert.IsTrue(tradeAllowanceCharge.ChargeIndicator);
  Assert.AreEqual('Reason for charge', tradeAllowanceCharge.Reason);
  Assert.AreEqual(Currency(5), tradeAllowanceCharge.BasisAmount.Value);
  Assert.AreEqual(Currency(15), tradeAllowanceCharge.ActualAmount);
  Assert.AreEqual(TZUGFeRDCurrencyCodes.EUR, tradeAllowanceCharge.Currency);
  Assert.AreEqual(Currency(19), tradeAllowanceCharge.Tax.Percent);
  Assert.AreEqual(TZUGFeRDTaxTypes.AAB, tradeAllowanceCharge.Tax.TypeCode);
  Assert.AreEqual(TZUGFeRDTaxCategoryCodes.AB, tradeAllowanceCharge.Tax.CategoryCode.Value);

  //ServiceCharges
  var serviceCharge := TZUGFeRDHelper.FindFirstMatchingItem<TZUGFeRDServiceCharge>(
    loadedInvoice.ServiceCharges, function(Item: TZUGFeRDServiceCharge): Boolean
    begin
      result := Item.Description = 'Logistics service charge';
    end);
  Assert.IsNotNull(serviceCharge);
  Assert.AreEqual('Logistics service charge', serviceCharge.Description);
  Assert.AreEqual(Currency(10), serviceCharge.Amount);
  Assert.AreEqual(Currency(7), serviceCharge.Tax.Percent);
  Assert.AreEqual(TZUGFeRDTaxTypes.AAC, serviceCharge.Tax.TypeCode);
  Assert.AreEqual(TZUGFeRDTaxCategoryCodes.AC, serviceCharge.Tax.CategoryCode.Value);

  Assert.AreEqual('Zahlbar innerhalb 30 Tagen netto bis 04.04.2018, 3% Skonto innerhalb 10 Tagen bis 15.03.2018',
    loadedInvoice.PaymentTermsList[0].Description);
  Assert.AreEqual(timestamp.IncDay(14), loadedInvoice.PaymentTermsList[0].DueDate.Value);


  Assert.AreEqual(Currency(473.0), loadedInvoice.LineTotalAmount.Value);
  Assert.IsNull(loadedInvoice.ChargeTotalAmount); // optional
  Assert.IsNull(loadedInvoice.AllowanceTotalAmount); // optional
  Assert.AreEqual(Currency(473.0), loadedInvoice.TaxBasisAmount.Value);
  Assert.AreEqual(Currency(56.87), loadedInvoice.TaxTotalAmount.Value);
  Assert.AreEqual(Currency(529.87), loadedInvoice.GrandTotalAmount.Value);
  Assert.IsNull(loadedInvoice.TotalPrepaidAmount); // optional
  Assert.AreEqual(Currency(529.87), loadedInvoice.DuePayableAmount.Value);

  //InvoiceReferencedDocument
  Assert.AreEqual('RE-12345', loadedInvoice.InvoiceReferencedDocuments.First.ID);
  Assert.AreEqual(timestamp, loadedInvoice.InvoiceReferencedDocuments.First.IssueDateTime.Value);


  //Line items
  var loadedLineItem := TZUGFeRDHelper.FindFirstMatchingItem<TZUGFeRDTradeLineItem>(loadedInvoice.TradeLineItems,
    function(Item: TZUGFeRDTradeLineItem): Boolean
    begin
      result := Item.SellerAssignedID = 'TB100A4';
    end);
  Assert.IsNotNull(loadedLineItem);
  Assert.IsTrue(not string.IsNullOrEmpty(loadedLineItem.AssociatedDocument.LineID));
  Assert.AreEqual('This is line item TB100A4', loadedLineItem.Description);

  Assert.AreEqual('Trennblätter A4', loadedLineItem.Name);

  Assert.AreEqual('TB100A4', loadedLineItem.SellerAssignedID);
  Assert.AreEqual('0815', loadedLineItem.BuyerAssignedID);
  Assert.AreEqual(TZUGFeRDGlobalIDSchemeIdentifiers.EAN, loadedLineItem.GlobalID.SchemeID.Value);
  Assert.AreEqual('4012345001235', loadedLineItem.GlobalID.ID);

  //GrossPriceProductTradePrice
  Assert.AreEqual(Double(9.9), loadedLineItem.GrossUnitPrice.Value);
  Assert.AreEqual(TZUGFeRDQuantityCodes.H87, loadedLineItem.UnitCode);
  Assert.AreEqual(Double(3), loadedLineItem.UnitQuantity.Value);

  //NetPriceProductTradePrice
  Assert.AreEqual(Double(9.9), loadedLineItem.NetUnitPrice.Value);
  Assert.AreEqual(Double(20), loadedLineItem.BilledQuantity);

  Assert.AreEqual(TZUGFeRDTaxTypes.VAT, loadedLineItem.TaxType);
  Assert.AreEqual(TZUGFeRDTaxCategoryCodes.S, loadedLineItem.TaxCategoryCode);
  Assert.AreEqual(Double(19), loadedLineItem.TaxPercent);

  Assert.AreEqual('12345', loadedLineItem.BuyerOrderReferencedDocument.ID);
  Assert.AreEqual(timestamp, loadedLineItem.BuyerOrderReferencedDocument.IssueDateTime.Value);
  Assert.AreEqual('12345', loadedLineItem.DeliveryNoteReferencedDocument.ID);
  Assert.AreEqual(timestamp, loadedLineItem.DeliveryNoteReferencedDocument.IssueDateTime.Value);
  Assert.AreEqual('12345', loadedLineItem.ContractReferencedDocument.ID);
  Assert.AreEqual(timestamp, loadedLineItem.ContractReferencedDocument.IssueDateTime.Value);

  Assert.IsTrue(loadedLineItem.AdditionalReferencedDocuments.Count = 1);
  var lineItemReferencedDoc := loadedLineItem.AdditionalReferencedDocuments.First();
  Assert.IsNotNull(lineItemReferencedDoc);
  Assert.AreEqual('abc', lineItemReferencedDoc.ID);
  Assert.AreEqual(TZUGFeRDAdditionalReferencedDocumentTypeCode.InvoiceDataSheet, lineItemReferencedDoc.TypeCode.Value);
  Assert.AreEqual(timestamp, lineItemReferencedDoc.IssueDateTime.Value);
  Assert.AreEqual(TZUGFeRDReferenceTypeCodes.PP, lineItemReferencedDoc.ReferenceTypeCode.Value);


  var productCharacteristics := loadedLineItem.ApplicableProductCharacteristics.First();
  Assert.IsNotNull(productCharacteristics);
  Assert.AreEqual('Product characteristics', productCharacteristics.Description);
  Assert.AreEqual('Product value', productCharacteristics.Value);

  Assert.AreEqual(timestamp, loadedLineItem.ActualDeliveryDate.Value);
  Assert.AreEqual(timestamp, loadedLineItem.BillingPeriodStart.Value);
  Assert.AreEqual(timestamp.IncDay(10), loadedLineItem.BillingPeriodEnd.Value);

  var accountingAccount := loadedLineItem.ReceivableSpecifiedTradeAccountingAccounts.First();
  Assert.IsNotNull(accountingAccount);
  Assert.AreEqual('987654', accountingAccount.TradeAccountID);


  var lineItemTradeAllowanceCharge := TZUGFeRDHelper.FindFirstMatchingItem<TZUGFeRDTradeAllowanceCharge>(
    loadedLineItem.TradeAllowanceCharges, function(Item: TZUGFeRDTradeAllowanceCharge): Boolean
    begin
      result := Item.Reason = 'Reason: UnitTest';
    end);
  Assert.IsNotNull(lineItemTradeAllowanceCharge);
  Assert.IsTrue(lineItemTradeAllowanceCharge.ChargeIndicator);
  Assert.AreEqual(Currency(10), lineItemTradeAllowanceCharge.BasisAmount.Value);
  Assert.AreEqual(Currency(50), lineItemTradeAllowanceCharge.ActualAmount);
  Assert.AreEqual('Reason: UnitTest', lineItemTradeAllowanceCharge.Reason);
  loadedInvoice.Free;

end;

procedure TZUGFeRD22Tests.TestWriteTradeLineBilledQuantity;
begin
  // Read XRechnung
  var path := '..\..\..\demodata\xRechnung\xrechnung with trade line settlement empty.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var fileStream := TFileStream.Create(path, fmOpenread);
  var originalInvoiceDescriptor := TZUGFeRDInvoiceDescriptor.Load(fileStream);
  fileStream.free;

  // Modifiy trade line settlement data
  var _tempTradeLineItem := OriginalInvoiceDescriptor.AddTradeLineItem('', '');
  _tempTradeLineItem.BilledQuantity := 10;
  _tempTradeLineItem.NetUnitPrice := 1;

  originalInvoiceDescriptor.IsTest := false;

  var memoryStream := TMemoryStream.Create;
  originalInvoiceDescriptor.Save(memoryStream, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Basic);
  originalInvoiceDescriptor.Save('xrechnung with trade line settlement filled.xml', TZUGFeRDVersion.Version23);
  originalInvoiceDescriptor.Free;

  // Load Invoice and compare to expected
  var invoiceDescriptor := TZUGFeRDInvoiceDescriptor.Load(memoryStream);
  memoryStream.Free;
  Assert.AreEqual(Double(10), invoiceDescriptor.TradeLineItems[0].BilledQuantity);
  invoiceDescriptor.Free;
end;

procedure TZUGFeRD22Tests.TestWriteTradeLineBillingPeriod;
begin
  // Read XRechnung
  var path := '..\..\..\demodata\xRechnung\xrechnung with trade line settlement empty.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var s := TFileStream.Create(path, fmOpenread);
  var originalInvoiceDescriptor := TZUGFeRDInvoiceDescriptor.Load(s);
  s.Free;

  // Modifiy trade line settlement data
  var _tempTradeLineItem := originalInvoiceDescriptor.AddTradeLineItem('', '');
  _tempTradeLineItem.BillingPeriodStart := EncodeDate(2020,1,1);
  _tempTradeLineItem.BillingPeriodEnd := EncodeDate(2021, 1, 1);

  var _tempTradeLineItem2 := originalInvoiceDescriptor.AddTradeLineItem('', '');
  _tempTradeLineItem2.BillingPeriodStart := EncodeDate(2021,1,1);
  _tempTradeLineItem2.BillingPeriodEnd := EncodeDate(2022, 1, 1);

  originalInvoiceDescriptor.IsTest := false;

  var memoryStream := TMemoryStream.create;
  originalInvoiceDescriptor.Save(memoryStream, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Basic);
  originalInvoiceDescriptor.Save('xrechnung with trade line settlement filled.xml', TZUGFeRDVersion.Version23);
  originalInvoiceDescriptor.Free;
  // Load Invoice and compare to expected
  var invoiceDescriptor := TZUGFeRDInvoiceDescriptor.Load(memoryStream);
  memoryStream.Free;

  var firstTradeLineItem := invoiceDescriptor.TradeLineItems[0];
  Assert.AreEqual(EncodeDate(2020, 1, 1), firstTradeLineItem.BillingPeriodStart.Value);
  Assert.AreEqual(EncodeDate(2021, 1, 1), firstTradeLineItem.BillingPeriodEnd.Value);

  var secondTradeLineItem := invoiceDescriptor.TradeLineItems[1];
  Assert.AreEqual(EncodeDate(2021, 1, 1), secondTradeLineItem.BillingPeriodStart.Value);
  Assert.AreEqual(EncodeDate(2022, 1, 1), secondTradeLineItem.BillingPeriodEnd.Value);
  invoiceDescriptor.Free;

end;

procedure TZUGFeRD22Tests.TestWriteTradeLineChargeFreePackage;
begin
  // Read XRechnung
  var path := '..\..\..\demodata\xRechnung\xrechnung with trade line settlement empty.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var fs: TFileStream := TFile.Open(path, TFileMode.fmOpen);
  var originalInvoiceDescriptor := TZUGFeRDInvoiceDescriptor.Load(fs);
  fs.Free;

  // Modifiy trade line settlement data
  originalInvoiceDescriptor.AddTradeLineItem('', '')
      .SetChargeFreeQuantity(10, TZUGFeRDQuantityCodes.C62)
      .SetPackageQuantity(20, TZUGFeRDQuantityCodes.C62);

  originalInvoiceDescriptor.IsTest := false;

  var memoryStream := TMemoryStream.Create;
  originalInvoiceDescriptor.Save(memoryStream, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  originalInvoiceDescriptor.Save('xrechnung with trade line settlement filled.xml',
    TZUGFeRDVersion.Version23, TZUGFeRDProfile.Extended);
  originalInvoiceDescriptor.Free;

  // Load Invoice and compare to expected
  var invoiceDescriptor := TZUGFeRDInvoiceDescriptor.Load(memoryStream);
  memoryStream.Free;

  Assert.AreEqual(Double(10), invoiceDescriptor.TradeLineItems[0].ChargeFreeQuantity.Value);
  Assert.AreEqual(TZUGFeRDQuantityCodes.C62, invoiceDescriptor.TradeLineItems[0].ChargeFreeUnitCode);
  Assert.AreEqual(Double(20), invoiceDescriptor.TradeLineItems[0].PackageQuantity.Value);
  Assert.AreEqual(TZUGFeRDQuantityCodes.C62, invoiceDescriptor.TradeLineItems[0].PackageUnitCode);

  invoiceDescriptor.Free;
end;

procedure TZUGFeRD22Tests.TestWriteTradeLineLineID;
begin
  // Read XRechnung
  var path := '..\..\..\demodata\xRechnung\xrechnung with trade line settlement empty.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var fileStream := TFileStream.Create(path, fmOpenRead);
  var originalInvoiceDescriptor := TZUGFeRDInvoiceDescriptor.Load(fileStream);
  fileStream.Free;

  // Modifiy trade line settlement data
  originalInvoiceDescriptor.TradeLineItems.Clear; //

  originalInvoiceDescriptor.AddTradeLineCommentItem('2', 'Comment_2');
  originalInvoiceDescriptor.AddTradeLineCommentItem('3', 'Comment_3');
  originalInvoiceDescriptor.IsTest := false;

  var memoryStream := TMemoryStream.Create;
  originalInvoiceDescriptor.Save(memoryStream, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Basic);
  originalInvoiceDescriptor.Save('xrechnung with trade line settlement filled.xml', TZUGFeRDVersion.Version23);
  originalInvoiceDescriptor.Free;
  memoryStream.Free;

  // Load Invoice and compare to expected
  var invoiceDescriptor := TZUGFeRDInvoiceDescriptor.Load('xrechnung with trade line settlement filled.xml');

  var firstTradeLineItem := invoiceDescriptor.TradeLineItems[0];
  Assert.AreEqual('2', firstTradeLineItem.AssociatedDocument.LineID);

  var secondTradeLineItem := invoiceDescriptor.TradeLineItems[1];
  Assert.AreEqual('3', secondTradeLineItem.AssociatedDocument.LineID);
  invoiceDescriptor.Free;

end;

procedure TZUGFeRD22Tests.TestWriteTradeLineNetUnitPrice;
begin
  // Read XRechnung
  var path := '..\..\..\demodata\xRechnung\xrechnung with trade line settlement empty.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var fileStream := TFileStream.Create(path, fmOpenread);
  var originalInvoiceDescriptor := TZUGFeRDInvoiceDescriptor.Load(fileStream);
  fileStream.Free;

  var _tempTradeLineItem := OriginalInvoiceDescriptor.AddTradeLineItem('', '');
  _tempTradeLIneItem.NetUnitPrice := 25;
  // Modifiy trade line settlement data
  originalInvoiceDescriptor.IsTest := false;

  var memoryStream := TMemoryStream.Create;
  originalInvoiceDescriptor.Save(memoryStream, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Basic);
  originalInvoiceDescriptor.Save('xrechnung with trade line settlement filled.xml', TZUGFeRDVersion.Version23);
  originalInvoiceDescriptor.Free;

  // Load Invoice and compare to expected
  var invoiceDescriptor := TZUGFeRDInvoiceDescriptor.Load(memoryStream);
  memoryStream.Free;
  Assert.AreEqual(Double(25), invoiceDescriptor.TradeLineItems[0].NetUnitPrice.Value);
  invoiceDescriptor.Free;

end;

procedure TZUGFeRD22Tests.TestWriteTradeLineProductCharacteristics;
begin
  var path := '..\..\..\demodata\xRechnung\xrechnung with trade line settlement empty.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var fileStream := TFileStream.Create(path, fmOpenRead);
  var originalInvoiceDescriptor := TZUGFeRDInvoiceDescriptor.Load(fileStream);
  fileStream.Free;

  // Modifiy trade line settlement data
  var _tempTradeLineItem := OriginalInvoiceDescriptor.AddTradeLineItem('', '');
  _tempTradeLineItem.ApplicableProductCharacteristics.Add(
    TZUGFeRDApplicableProductCharacteristic.CreateWithParams('Description_1_1', 'Value_1_1'));
  _tempTradeLineItem.ApplicableProductCharacteristics.Add(
    TZUGFeRDApplicableProductCharacteristic.CreateWithParams('Description_1_2', 'Value_1_2'));

  var _tempTradeLineItem2 := OriginalInvoiceDescriptor.AddTradeLineItem('', '');
  _tempTradeLineItem2.ApplicableProductCharacteristics.Add(
    TZUGFeRDApplicableProductCharacteristic.CreateWithParams('Description_2_1', 'Value_2_1'));
  _tempTradeLineItem2.ApplicableProductCharacteristics.Add(
    TZUGFeRDApplicableProductCharacteristic.CreateWithParams('Description_2_2', 'Value_2_2'));

  originalInvoiceDescriptor.IsTest := false;

  var memoryStream := TMemoryStream.Create;
  originalInvoiceDescriptor.Save(memoryStream, TZUGFeRDVersion.Version23, TZUGFeRDProfile.Basic);
  originalInvoiceDescriptor.Save('xrechnung with trade line settlement filled.xml', TZUGFeRDVersion.Version23);
  originalInvoiceDescriptor.Free;

  // Load Invoice and compare to expected
  var invoiceDescriptor := TZUGFeRDInvoiceDescriptor.Load(memoryStream);
  memoryStream.Free;

  var firstTradeLineItem := invoiceDescriptor.TradeLineItems[0];
  Assert.AreEqual('Description_1_1', firstTradeLineItem.ApplicableProductCharacteristics[0].Description);
  Assert.AreEqual('Value_1_1', firstTradeLineItem.ApplicableProductCharacteristics[0].Value);
  Assert.AreEqual('Description_1_2', firstTradeLineItem.ApplicableProductCharacteristics[1].Description);
  Assert.AreEqual('Value_1_2', firstTradeLineItem.ApplicableProductCharacteristics[1].Value);

  var secondTradeLineItem := invoiceDescriptor.TradeLineItems[1];
  Assert.AreEqual('Description_2_1', secondTradeLineItem.ApplicableProductCharacteristics[0].Description);
  Assert.AreEqual('Value_2_1', secondTradeLineItem.ApplicableProductCharacteristics[0].Value);
  Assert.AreEqual('Description_2_2', secondTradeLineItem.ApplicableProductCharacteristics[1].Description);
  Assert.AreEqual('Value_2_2', secondTradeLineItem.ApplicableProductCharacteristics[1].Value);
  invoiceDescriptor.Free;
end;

procedure TZUGFeRD22Tests.TestXRechnung1;
var
  desc: TZUGFeRDInvoiceDescriptor;
begin
  desc := FInvoiceProvider.CreateInvoice();
  try
    var ms := TMemoryStream.Create();
    desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung1);
    ms.Seek(0, soBeginning);
    Assert.AreEqual(desc.Profile, TZUGFeRDProfile.XRechnung1);

    var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
    ms.Free;
    Assert.AreEqual(loadedInvoice.Profile, TZUGFeRDProfile.XRechnung1);
    loadedInvoice.Free;
  finally
    desc.Free;
  end;
end;

procedure TZUGFeRD22Tests.TestXRechnung2;
var
  desc: TZUGFeRDInvoiceDescriptor;
begin
  desc := FInvoiceProvider.CreateInvoice();
  try
    var ms := TMemoryStream.Create;

    desc.Save(ms, TZUGFeRDVersion.Version23, TZUGFeRDProfile.XRechnung);
    Assert.AreEqual(desc.Profile, TZUGFeRDProfile.XRechnung);

    ms.Seek(0, soBeginning);
    var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
    ms.Free;
    Assert.AreEqual(loadedInvoice.Profile, TZUGFeRDProfile.XRechnung);
    loadedInvoice.Free;
  finally
    desc.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TZUGFeRD22Tests);

end.
