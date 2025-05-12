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

unit ZUGFeRD20Tests;

interface

uses
  DUnitX.TestFramework, System.Classes, System.SysUtils, TestBase, InvoiceProvider,
  System.Generics.Collections;

type
  [TestFixture]
  TZUGFerd20Tests = class(TTestBase)
  private
    FInvoiceProvider: TInvoiceProvider;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestReferenceBasicInvoice;
    [Test]
    procedure TestReferenceExtendedInvoice;
    [Test]
    procedure TestTotalRounding;
    [Test]
    procedure TestMissingPropertiesAreNull;
    [Test]
    procedure TestMissingPropertListsEmpty;
    [Test]
    procedure TestLoadingSepaPreNotification;
    [Test]
    procedure TestStoringSepaPreNotification;
    [Test]
    procedure TestPartyExtensions;
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
  end;

implementation

uses intf.ZUGFeRDInvoiceDescriptor, intf.ZUGFeRDProfile, intf.ZUGFeRDInvoiceTypes, intf.ZUGFeRDVersion,
  intf.ZUGFeRDCurrencyCodes, intf.ZUGFeRDQuantityCodes, intf.ZUGFeRDTaxCategoryCodes, intf.ZUGFeRDTaxTypes,
  intf.ZUGFeRDGlobalID, intf.ZUGFeRDGlobalIDSchemeIdentifiers, intf.ZUGFeRDHelper, intf.ZUGFeRDCountryCodes,
  intf.ZUGFeRDLegalOrganization, intf.ZUGFeRDPaymentTerms, intf.ZUGFeRDTaxRegistration,
  intf.ZUGFeRDTaxRegistrationSchemeID, intf.ZUGFeRDParty, intf.ZUGFeRDPartyTypes,
  intf.ZUGFeRDAdditionalReferencedDocumentTypeCodes, intf.ZUGFeRDReferenceTypeCodes,
  intf.ZUGFeRDSellerOrderReferencedDocument, intf.ZUGFeRDSpecifiedProcuringProject,
  intf.ZUGFeRDFinancialCard, intf.ZUGFeRDTradeLineItem, intf.ZUGFeRDApplicableProductCharacteristic,
  intf.ZUGFeRDBankAccount, intf.ZUGFeRDPaymentMeansTypeCodes, intf.ZUGFeRDNote, intf.ZUGFeRDTax,
  intf.ZUGFeRDTradeAllowanceCharge, intf.ZUGFeRDServiceCharge, intf.ZUGFeRDAdditionalReferencedDocument,
  System.DateUtils, Winapi.ActiveX;


procedure TZUGFerd20Tests.Setup;
begin
  CoInitialize(nil);
  FInvoiceProvider := TInvoiceProvider.create;
end;

procedure TZUGFerd20Tests.TearDown;
begin
  CoUninitialize;
  FInvoiceProvider.Free;
end;

procedure TZUGFerd20Tests.TestLoadingSepaPreNotification;
var
  desc: TZUGFeRDInvoiceDescriptor;
  path: string;
begin
  path := '..\..\..\demodata\zugferd20\zugferd_2p0_EN16931_SEPA_Prenotification.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  desc := TZUGFeRDInvoiceDescriptor.Load(path);
  try
    Assert.AreEqual(TZUGFeRDProfile.Comfort, desc.Profile);

    Assert.AreEqual('DE98ZZZ09999999999', desc.PaymentMeans.SEPACreditorIdentifier);
    Assert.AreEqual('REF A-123', desc.PaymentMeans.SEPAMandateReference);
    Assert.AreEqual(1, desc.DebitorBankAccounts.Count);
    Assert.AreEqual('DE21860000000086001055', desc.DebitorBankAccounts[0].IBAN);

    Assert.AreEqual('Der Betrag in Höhe von EUR 529,87 wird am 20.03.2018 von Ihrem Konto per SEPA-Lastschrift eingezogen.',
      desc.PaymentTermsList[0].Description.Trim);
  finally
    desc.Free;
  end;

end;

procedure TZUGFerd20Tests.TestMimetypeOfEmbeddedAttachment;
var
  path: string;
  desc: TZUGFeRDInvoiceDescriptor;
  data: TBytes;
begin
  path := '..\..\..\demodata\zugferd20\zugferd_2p0_EXTENDED_Warenrechnung.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var s := TFileStream.Create(path, fmOpenRead);
  desc := TZUGFeRDInvoiceDescriptor.Load(s);
  s.free;

  try
    var filename1 := 'myrandomdata.pdf';
    var filename2 := 'myrandomdata.bin';
    var timestamp: TDateTime := Date;

    SetLength(data, 32768);
    RandomizeByteArray(data);

(*
const id: string; const typeCode: TZUGFeRDAdditionalReferencedDocumentTypeCode;
  const issueDateTime: TDateTime = 0; const name: string = ''; const referenceTypeCode: TZUGFeRDReferenceTypeCodes = TZUGFeRDReferenceTypeCodes.Unknown;
  const attachmentBinaryObject: TMemoryStream = nil; const filename: string = '');
*)
    var msref1 := TMemoryStream.Create;
    msref1.WriteBuffer(data[0], Length(data));
    msref1.Position := 0;
    desc.AddAdditionalReferencedDocument(
          'My-File-PDF',
          TZUGFeRDAdditionalReferencedDocumentTypeCode.ReferenceDocument,
          TZUGFeRDNullableParam<TDateTime>.Create(timestamp),
          'EmbeddedPdf',
          TZUGFeRDReferenceTypeCodes.Unknown,
          msref1,
          filename1
      );

    var msref2 := TMemoryStream.Create;
    msref2.WriteBuffer(data[0], Length(data));
    msref2.Position := 0;
    desc.AddAdditionalReferencedDocument(
          'My-File-BIN',
          TZUGFeRDAdditionalReferencedDocumentTypeCode.ReferenceDocument,
          TZUGFeRDNullableParam<TDateTime>.Create(timestamp),
          'EmbeddedBin',
          TZUGFeRDReferenceTypeCodes.Unknown,
          msref2,
          filename2
      );

    var msSave := TMemoryStream.Create;
    desc.Save(msSave, TZUGFeRDVersion.Version20, TZUGFeRDProfile.Extended);
    msSave.Seek(0, sobeginning);
    msSave.SaveToFile('Test.XML');

    var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(msSave);
    msSave.Free;

    //One document is already referenced in "zuferd_2p0_EXTENDED_Warenrechnung.xml"
    Assert.AreEqual(loadedInvoice.AdditionalReferencedDocuments.Count, 3);

    For var document in loadedInvoice.AdditionalReferencedDocuments do
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
        Assert.AreEqual(timestamp, document.IssueDateTime.Value);
      end;
    end;
    loadedInvoice.Free;
  finally
    desc.Free;
  end;

end;

procedure TZUGFerd20Tests.TestMissingPropertiesAreNull;
var
  i: Integer;
  desc: TZUGFeRDInvoiceDescriptor;
  path: string;
begin
  path := '..\..\..\demodata\zugferd20\zugferd_2p0_BASIC_Einfach.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  desc := TZUGFeRDInvoiceDescriptor.Load(path);
  try
    for i := 0 to desc.TradeLineItems.Count - 1 do
    begin
      Assert.IsNULL(desc.TradeLineItems[i].BillingPeriodStart);
      Assert.IsNULL(desc.TradeLineItems[i].BillingPeriodEnd);
    end;
  finally
    desc.Free;
  end;
end;

procedure TZUGFerd20Tests.TestMissingPropertListsEmpty;
var
  i: Integer;
  desc: TZUGFeRDInvoiceDescriptor;
  path: string;
begin
  path := '..\..\..\demodata\zugferd20\zugferd_2p0_BASIC_Einfach.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  desc := TZUGFeRDInvoiceDescriptor.Load(path);
  try
    for i := 0 to desc.TradeLineItems.Count - 1 do
     Assert.IsTrue(desc.TradeLineItems[i].ApplicableProductCharacteristics.Count = 0);
  finally
    desc.Free;
  end;

end;

procedure TZUGFerd20Tests.TestOrderInformation;
var
  path: string;
  desc: TZUGFeRDInvoiceDescriptor;
begin
  path := '..\..\..\demodata\zugferd20\zugferd_2p0_EXTENDED_Warenrechnung.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var timestamp: TDateTime := Date;

  var s := TFileStream.Create(path, fmOpenRead);
  desc := TZUGFeRDInvoiceDescriptor.Load(s);
  desc.OrderDate := timestamp;
  desc.OrderNo := '12345';
  s.Free;

  try
    var ms := TMemoryStream.Create;
    desc.Save(ms, TZUGFeRDVersion.Version20, TZUGFeRDProfile.Extended);

    ms.Seek(0, soBeginning);
    //var reader := TStreamReader.Create(ms);
    //var text := reader.ReadToEnd;

    //ms.Seek(0, soBeginning);
    var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
    try
      Assert.AreEqual(timestamp, loadedInvoice.OrderDate.Value);
      Assert.AreEqual('12345', loadedInvoice.OrderNo);
    finally
      ms.Free;
      loadedInvoice.Free;
    end;
  finally
    desc.Free;
  end;

end;

procedure TZUGFerd20Tests.TestPartyExtensions;
var
  desc: TZUGFeRDInvoiceDescriptor;
  path: string;
begin
  path := '..\..\..\demodata\zugferd20\zugferd_2p0_BASIC_Einfach.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var FS: TFileStream := TFileStream.Create(path, fmOpenRead);
  desc := TZUGFeRDInvoiceDescriptor.Load(FS);
  FS.Free;
  try
    var _tempInvoicee := TZUGFeRDParty.create;
    _tempInvoicee.Name := 'Test';
    _tempInvoicee.ContactName := 'Max Mustermann';
    _tempInvoicee.Postcode := '83022';
    _tempInvoicee.City := 'Rosenheim';
    _tempInvoicee.Street := 'Münchnerstraße 123';
    _tempInvoicee.AddressLine3 := 'EG links';
    _tempInvoicee.CountrySubdivisionName := 'Bayern';
    _tempInvoicee.Country := TZUGFeRDCountryCodes.DE;

    desc.Invoicee :=  _tempInvoicee;// this information will not be stored in the output file since it is available in Extended profile only

    var MS: TMemoryStream :=TMemoryStream.Create;
    desc.Save(MS, TZUGFeRDVersion.Version20, TZUGFeRDProfile.Extended);
    MS.Seek(0, soBeginning);

    var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(MS);
    MS.Free;

    Assert.AreEqual('Test', loadedInvoice.Invoicee.Name);
    Assert.AreEqual('Max Mustermann', loadedInvoice.Invoicee.ContactName);
    Assert.AreEqual('83022', loadedInvoice.Invoicee.Postcode);
    Assert.AreEqual('Rosenheim', loadedInvoice.Invoicee.City);
    Assert.AreEqual('Münchnerstraße 123', loadedInvoice.Invoicee.Street);
    Assert.AreEqual('EG links', loadedInvoice.Invoicee.AddressLine3);
    Assert.AreEqual('Bayern', loadedInvoice.Invoicee.CountrySubdivisionName);
    Assert.AreEqual(TZUGFeRDCountryCodes.DE, loadedInvoice.Invoicee.Country);
    loadedInvoice.Free;
  finally
    desc.Free;
  end;
end;

procedure TZUGFerd20Tests.TestReferenceBasicInvoice;
var
  desc: TZUGFeRDInvoicedescriptor;
  path: string;
  FS: TFileStream;
begin
  path := '..\..\..\demodata\zugferd20\zugferd_2p0_BASIC_Einfach.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  FS := TFileStream.Create(path, fmOpenRead);
  desc := TZUGFeRDInvoiceDescriptor.Load(FS);
  try
    Assert.AreEqual(desc.Profile, TZUGFeRDProfile.Basic);
    Assert.AreEqual(desc.Type_, TZUGFeRDInvoiceType.Invoice);
    Assert.AreEqual(desc.InvoiceNo, '471102');
    Assert.AreEqual(desc.TradeLineItems.Count, 1);
    var LTA := desc.LineTotalAmount.Value;
    Assert.AreEqual(LTA, 198.00);
    Assert.IsFalse(desc.IsTest);
  finally
    desc.Free;
    FS.Free;
  end;

end;

procedure TZUGFerd20Tests.TestReferenceExtendedInvoice;
var
  desc: TZUGFeRDInvoicedescriptor;
  path: string;
  FS: TFileStream;
begin
  path := '..\..\..\demodata\zugferd20\zugferd_2p0_EXTENDED_Warenrechnung.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  FS  := TFileStream.Create(path, fmOpenRead);
  desc := TZUGFeRDInvoiceDescriptor.Load(FS);
  try
    Assert.AreEqual(desc.Profile, TZUGFeRDProfile.Extended);
    Assert.AreEqual(desc.Type_, TZUGFeRDInvoiceType.Invoice);
    Assert.AreEqual(desc.InvoiceNo, 'R87654321012345');
    Assert.AreEqual(desc.TradeLineItems.Count, 6);
    var LTA := desc.LineTotalAmount.Value;
    Assert.AreEqual(LTA, 457.20);
    Assert.IsTrue(desc.IsTest);
  finally
    desc.Free;
    FS.Free;
  end;
end;

procedure TZUGFerd20Tests.TestSellerOrderReferencedDocument;
var
  desc: TZUGFeRDInvoicedescriptor;
  path: string;
begin
  path := '..\..\..\demodata\zugferd20\zugferd_2p0_EXTENDED_Warenrechnung.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  var s := TFileStream.Create(path, fmOpenRead);
  desc := TZUGFeRDInvoiceDescriptor.Load(s);
  s.Free;
  try
    var uuid := TZUGFerdHelper.CreateUuid;
    var issueDateTime: TDateTime := Date;

    desc.SellerOrderReferencedDocument := TZUGFeRDSellerOrderReferencedDocument.CreateWithParams(uuid, issueDateTime);

    var ms := TMemoryStream.Create;
    desc.Save(ms, TZUGFeRDVersion.Version20, TZUGFeRDProfile.Extended);

    //???
    //ms.Seek(0, SeekOrigin.Begin);
    //StreamReader reader = new StreamReader(ms);
    // string text = reader.ReadToEnd();

    ms.Seek(0, soBeginning);
    var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
    ms.Free;

    Assert.AreEqual(TZUGFeRDProfile.Extended, loadedInvoice.Profile);
    Assert.AreEqual(uuid, loadedInvoice.SellerOrderReferencedDocument.ID);
    Assert.AreEqual(issueDateTime, loadedInvoice.SellerOrderReferencedDocument.IssueDateTime.Value);
    loadedInvoice.Free;
  finally
    desc.Free;
  end;

end;

procedure TZUGFerd20Tests.TestStoringSepaPreNotification;
var
  d: TZUGFeRDInvoiceDescriptor;
  ms: TMemoryStream;
begin
  d := TZUGFeRDInvoiceDescriptor.Create;
  ms:= TMemoryStream.Create;
  try
    d.Type_ := TZUGFerDInvoiceType.Invoice;
    d.InvoiceNo := '471102';
    d.Currency := TZUGFeRDCurrencyCodes.EUR;
    d.InvoiceDate := EncodeDate(2018, 3, 5);
    d.AddTradeLineItem(
      '1',
      'Trennblätter A4',
      '',
      TZUGFeRDQuantityCodes.C62,
      nil,
      TZUGFeRDNullableParam<Currency>.Create(9.9),
      TZUGFeRDNullableParam<Currency>.Create(9.9),
      20,
      0,
      TZUGFeRDTaxTypes.VAT,
      TZUGFeRDTaxCategoryCodes.S,
      19.0,
      '',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.EAN, '4012345001235'),
      'TB100A4'
    );


    d.AddTradeLineItem(
      '2',
      'Joghurt Banane',
      '',
      TZUGFeRDQuantityCodes.C62,
      nil,
      TZUGFeRDNullableParam<Currency>.Create(5.5),
      TZUGFeRDNullableParam<Currency>.Create(5.5),
      50,
      0,
      TZUGFeRDTaxTypes.VAT,
      TZUGFeRDTaxCategoryCodes.S,
      7.0,
      '',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.EAN, '4000050986428'),
      'ARNR2'
    );

    d.SetSeller(
      'Lieferant GmbH',
      '80333',
      'München',
      'Lieferantenstraße 20',
      TZUGFeRDCountryCodes.DE,
      '',
      TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN, '4000001123452'),
      TZUGFeRDLegalOrganization.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN, '4000001123452',
        'Lieferant GmbH')
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
    var PM := TZUGFeRDPaymentTerms.create;
    PM.Description := 'Der Betrag in Höhe von EUR 529,87 wird am 20.03.2018 von Ihrem Konto per SEPA-Lastschrift eingezogen.';
    d.PaymentTermsList.Add(PM);
    d.SetTotals(
      TZUGFeRDNullableParam<Currency>.create(473.00),
      nil,
      nil,
      TZUGFeRDNullableParam<Currency>.create(473.00),
      TZUGFeRDNullableParam<Currency>.create(56.87),
      TZUGFeRDNullableParam<Currency>.create(529.87),
      nil,
      TZUGFeRDNullableParam<Currency>.create(529.87));
    d.SellerTaxRegistration.Add(TZUGFeRDTaxRegistration.CreateWithParams(TZUGFeRDTaxRegistrationSchemeID.FC,
      '201/113/40209'));
    d.SellerTaxRegistration.Add(TZUGFeRDTaxRegistration.CreateWithParams(TZUGFeRDTaxRegistrationSchemeID.VA,
      'DE123456789'));
    d.AddApplicableTradeTax(275.00, 7.00, TZUGFeRDTaxTypes.VAT, TZUGFeRDTaxCategoryCodes.S);
    d.AddApplicableTradeTax(198.00, 19.00, TZUGFeRDTaxTypes.VAT, TZUGFeRDTaxCategoryCodes.S);

    d.Save(ms, TZUGFeRDVersion.Version20, TZUGFeRDProfile.Comfort);
    ms.Seek(0, soBeginning);

    var d2 := TZUGFeRDInvoiceDescriptor.Load(ms);

    Assert.AreEqual('DE98ZZZ09999999999', d2.PaymentMeans.SEPACreditorIdentifier);
    Assert.AreEqual('REF A-123', d2.PaymentMeans.SEPAMandateReference);
    Assert.AreEqual(1, d2.DebitorBankAccounts.Count);
    Assert.AreEqual('DE21860000000086001055', d2.DebitorBankAccounts[0].IBAN);
    d2.Free;
  finally
    ms.Free;
    d.free;
  end;
end;

procedure TZUGFerd20Tests.TestTotalRounding;
var
  uuid: string;
  issueDateTime: TDateTime;
  desc: TZUGFeRDInvoiceDescriptor;
  msExtended, msBasic: TMemoryStream;
  loadedInvoice: TZUGFeRDInvoiceDescriptor;
begin
  uuid := TZUGFeRDHelper.CreateUuid;
  issueDateTime := date;

  desc := TZUGFeRDInvoiceDescriptor.Create;
  try
    desc.SetContractReferencedDocument(uuid, TZUGFeRDNullableParam<TDateTime>.create(issueDateTime));
    desc.SetTotals(TZUGFeRDNullableParam<Currency>.create(1.99), nil, nil, nil, nil,
      TZUGFeRDNullableParam<Currency>.create(2), nil, TZUGFeRDNullableParam<Currency>.create(2),
      TZUGFeRDNullableParam<Currency>.create(0.01));

    msExtended := TMemoryStream.Create;
    desc.Save(msExtended, TZUGFeRDVersion.Version20, TZUGFeRDProfile.Extended);
    msExtended.Seek(0, soBeginning);

    loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(msExtended);
    Assert.AreEqual(loadedInvoice.RoundingAmount.Value, Currency(0.01));
    loadedInvoice.Free;
    msExtended.Free;
(*
    msBasic := TMemoryStream.Create;
    desc.Save(msBasic, TZUGFeRDVersion.Version20);
    msBasic.Seek(0, soBeginning);

    loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(msBasic);
    Assert.AreEqual(loadedInvoice.RoundingAmount.Value, Currency(0));
    loadedInvoice.Free;
    msBasic.Free;
*)
  finally
    desc.Free;
  end;

end;

procedure TZUGFerd20Tests.TestWriteAndReadBusinessProcess;
var
  desc: TZUGFeRDInvoiceDescriptor;
begin
  desc := FInvoiceProvider.CreateInvoice;
  try
    desc.BusinessProcess := 'A1';

    var ms := TMemoryStream.create;
    desc.Save(ms, TZUGFeRDVersion.Version20, TZUGFeRDProfile.Extended);
    ms.Seek(0, soBeginning);
    var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
    ms.Free;
    Assert.AreEqual('A1', loadedInvoice.BusinessProcess);
    loadedInvoice.Free;
  finally
    desc.Free;
  end;

end;

procedure TZUGFerd20Tests.TestWriteAndReadExtended;
var
  desc: TZUGFeRDInvoiceDescriptor;
  data: TBytes;
  lineItem: TZUGFeRDTradeLineItem;
begin
  desc := FInvoiceProvider.CreateInvoice;
  try
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
      TZUGFeRDNullableParam<TDateTime>.Create(timestamp- 2),
      'EmbeddedPdf',
      TZUGFeRDReferenceTypeCodes.Unknown,
      msref1,
      filename2);

    desc.OrderNo := '12345';
    desc.OrderDate := timestamp;

    desc.SetContractReferencedDocument('12345', TZUGFeRDNullableParam<TDateTime>.create(timestamp));

    desc.SpecifiedProcuringProject := TZUGFeRDSpecifiedProcuringProject.CreateWithParams('123', 'Project 123');

    var _PartyTo := TZUGFeRDParty.Create;
    _PartyTo.ID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiers.Unknown;
    _PartyTo.ID.ID := '123';
    _PartyTo.GlobalID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiers.DUNS;
    _PartyTo.GlobalID.ID := '789';
    _PartyTo.Name := 'Ship To';
    _PartyTo.ContactName := 'Max Mustermann';
    _PartyTo.Street := 'Münchnerstr. 55';
    _PartyTo.Postcode := '83022';
    _PartyTo.City := 'Rosenheim';
    _PartyTo.Country := TZUGFeRDCountryCodes.DE;

    desc.ShipTo := _PartyTo;

    var _PartyFrom := TZUGFeRDParty.Create;
    _PartyFrom.ID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiers.Unknown;
    _PartyFrom.ID.ID := '123';
    _PartyFrom.GlobalID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiers.DUNS;
    _PartyFrom.GlobalID.ID := '789';
    _PartyFrom.Name := 'Ship From';
    _PartyFrom.ContactName := 'Eva Musterfrau';
    _PartyFrom.Street := 'Alpenweg 5';
    _PartyFrom.Postcode := '83022';
    _PartyFrom.City := 'Rosenheim';
    _PartyFrom.Country := TZUGFeRDCountryCodes.DE;

    desc.ShipFrom := _PartyFrom;

    desc.PaymentMeans.SEPACreditorIdentifier := 'SepaID';
    desc.PaymentMeans.SEPAMandateReference := 'SepaMandat';
    desc.PaymentMeans.FinancialCard := TZUGFeRDFinancialCard.CreateWithParams('123', 'Mustermann');

    desc.PaymentReference := 'PaymentReference';

    var _PartyInv := TZUGFeRDParty.create;
    _PartyInv.Name := 'Test';
    _PartyInv.ContactName := 'Max Mustermann';
    _PartyInv.Postcode := '83022';
    _PartyInv.City := 'Rosenheim';
    _PartyInv.Street := 'Münchnerstraße 123';
    _PartyInv.AddressLine3 := 'EG links';
    _PartyInv.CountrySubdivisionName := 'Bayern';
    _PartyInv.Country := TZUGFeRDCountryCodes.DE;

    desc.Invoicee := _PartyInv;

    var _PartyPayee := TZUGFeRDParty.Create;
    _PartyPayee.Name := 'Test';
    _PartyPayee.ContactName := 'Max Mustermann';
    _PartyPayee.Postcode := '83022';
    _PartyPayee.City := 'Rosenheim';
    _PartyPayee.Street := 'Münchnerstraße 123';
    _PartyPayee.AddressLine3 := 'EG links';
    _PartyPayee.CountrySubdivisionName := 'Bayern';
    _PartyPayee.Country := TZUGFeRDCountryCodes.DE;

    desc.Payee := _PartyPayee; // this information will not be stored in the output file since it is available in Extended profile only

    desc.AddDebitorFinancialAccount('DE02120300000000202052', 'BYLADEM1001', '', '', 'Musterbank');
    desc.BillingPeriodStart := timestamp;
    desc.BillingPeriodEnd := timestamp.IncDay(14);

    desc.AddTradeAllowanceCharge(false, TZUGFeRDNullableParam<Currency>.create(5),
      TZUGFeRDCurrencyCodes.EUR, 15, 'Reason for charge',
      TZUGFeRDTaxTypes.AAB, TZUGFeRDTaxCategoryCodes.AB, 19);
    desc.AddLogisticsServiceCharge(10, 'Logistics service charge', TZUGFeRDTaxTypes.AAC,
      TZUGFeRDTaxCategoryCodes.AC, 7);

    if desc.PaymentTermsList.Count > 0 then
      desc.PaymentTermsList[0].DueDate := timestamp.IncDay(14)
    else begin
      var _PaymentTerms := TZUGFeRDPaymentTerms.Create;
      _PaymentTerms.DueDate := timestamp.IncDay(14);
      desc.PaymentTermsList.Add(_PaymentTerms);
    end;
    desc.AddInvoiceReferencedDocument('RE-12345', timestamp);


    var list: TObjectlist<TZUGFeRDTradeLineItem> := desc.TradeLineItems;
    lineitem := TZUGFeRDHelper.FindFirstMatchingItem<TZUGFeRDTradeLineItem>(list,
      function(Item: TZUGFerdTradeLineItem): Boolean
      begin
        result := Item.SellerAssignedID = 'TB100A4';
      end);

    Assert.IsNotNull(lineItem);
    lineItem.Description := 'This is line item TB100A4';
    lineItem.BuyerAssignedID := '0815';
    lineItem.SetOrderReferencedDocument('12345', TZUGFeRDNullableParam<TDateTime>.create(timestamp));
    lineItem.SetDeliveryNoteReferencedDocument('12345', TZUGFeRDNullableParam<TDateTime>.create(timestamp));
    lineItem.SetContractReferencedDocument('12345', TZUGFeRDNullableParam<TDateTime>.create(timestamp));

    lineItem.AddAdditionalReferencedDocument('xyz', TZUGFeRDReferenceTypeCodes.AAB,
      TZUGFeRDNullableParam<TDateTime>.create(timestamp));

    lineItem.UnitQuantity := 3;
    lineItem.ActualDeliveryDate := timestamp;

    lineItem.ApplicableProductCharacteristics.Add(TZUGFerdApplicableProductCharacteristic.CreateWithParams(
      'Product characteristics', 'Product value'));

    lineItem.BillingPeriodStart := timestamp;
    lineItem.BillingPeriodEnd := timestamp.IncDay(10);

    lineItem.AddReceivableSpecifiedTradeAccountingAccount('987654');
    lineItem.AddTradeAllowanceCharge(false, TZUGFeRDCurrencyCodes.EUR, 10, 50, 'Reason: UnitTest');


    var ms := TMemoryStream.create;
    desc.Save(ms, TZUGFeRDVersion.Version20, TZUGFeRDProfile.Extended);

    //???
    //ms.Seek(0, soBeginning);
    //StreamReader reader = new StreamReader(ms);
    //string text = reader.ReadToEnd();

    ms.Seek(0, soBeginning);
    var loadedInvoice := TZUGFerDInvoiceDescriptor.Load(ms);
    ms.Free;

    Assert.AreEqual('471102', loadedInvoice.InvoiceNo);
    Assert.AreEqual(EncodeDate(2018, 03, 05), loadedInvoice.InvoiceDate.Value);
    Assert.AreEqual(TZUGFeRDCurrencyCodes.EUR, loadedInvoice.Currency);
    Assert.IsTrue(TZUGFeRDHelper.Any<TZUGFeRDNote>(loadedInvoice.Notes,
      function(Item: TZUGFeRDNote):Boolean
      begin
        result := Item.Content = 'Rechnung gemäß Bestellung vom 01.03.2018.';
      end));
    Assert.AreEqual('04011000-12345-34', loadedInvoice.ReferenceOrderNo);
    Assert.AreEqual('Lieferant GmbH', loadedInvoice.Seller.Name);
    Assert.AreEqual('80333', loadedInvoice.Seller.Postcode);
    Assert.AreEqual('München', loadedInvoice.Seller.City);

    Assert.AreEqual('Lieferantenstraße 20', loadedInvoice.Seller.Street);
    Assert.AreEqual(TZUGFeRDCountryCodes.DE, loadedInvoice.Seller.Country);
    Assert.AreEqual(TZUGFeRDGlobalIDSchemeIdentifiers.GLN, loadedInvoice.Seller.GlobalID.SchemeID);
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

    //Currently not implemented
    //Assert.AreEqual("12345", loadedInvoice.ContractReferencedDocument.ID);
    //Assert.AreEqual(timestamp, loadedInvoice.ContractReferencedDocument.IssueDateTime);

    //Currently not implemented
    //Assert.AreEqual("123", loadedInvoice.SpecifiedProcuringProject.ID);
    //Assert.AreEqual("Project 123", loadedInvoice.SpecifiedProcuringProject.Name);

    Assert.AreEqual<string>('123', loadedInvoice.ShipTo.ID.ID);
    Assert.AreEqual(TZUGFeRDGlobalIDSchemeIdentifiers.DUNS, loadedInvoice.ShipTo.GlobalID.SchemeID);
    Assert.AreEqual('789', loadedInvoice.ShipTo.GlobalID.ID);
    Assert.AreEqual('Ship To', loadedInvoice.ShipTo.Name);
    Assert.AreEqual('Max Mustermann', loadedInvoice.ShipTo.ContactName);
    Assert.AreEqual('Münchnerstr. 55', loadedInvoice.ShipTo.Street);
    Assert.AreEqual('83022', loadedInvoice.ShipTo.Postcode);
    Assert.AreEqual('Rosenheim', loadedInvoice.ShipTo.City);
    Assert.AreEqual(TZUGFeRDCountryCodes.DE, loadedInvoice.ShipTo.Country);

    Assert.AreEqual<string>('123', loadedInvoice.ShipFrom.ID.ID);
    Assert.AreEqual(TZUGFeRDGlobalIDSchemeIdentifiers.DUNS, loadedInvoice.ShipFrom.GlobalID.SchemeID);
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

    Assert.AreEqual('SepaID', loadedInvoice.PaymentMeans.SEPACreditorIdentifier);
    Assert.AreEqual('SepaMandat', loadedInvoice.PaymentMeans.SEPAMandateReference);
    Assert.AreEqual('123', loadedInvoice.PaymentMeans.FinancialCard.Id);
    Assert.AreEqual('Mustermann', loadedInvoice.PaymentMeans.FinancialCard.CardholderName);

    var bankAccount: TZUGFeRDBankAccount := TZUGFeRDHelper.FindFirstMatchingItem<TZUGFeRDBankAccount>(
      loadedInvoice.CreditorBankAccounts,
      function(Item: TZUGFeRDBankAccount): Boolean
      begin
        result := Item.IBAN = 'DE02120300000000202051';
      end);

    Assert.IsNotNull(bankAccount);
    Assert.AreEqual('Kunden AG', bankAccount.Name);
    Assert.AreEqual('DE02120300000000202051', bankAccount.IBAN);
    Assert.AreEqual('BYLADEM1001', bankAccount.BIC);

    var debitorBankAccount: TZUGFeRDBankAccount := TZUGFeRDHelper.FindFirstMatchingItem<TZUGFeRDBankAccount>(
      loadedInvoice.DebitorBankAccounts,
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

    var tax: TZUGFeRDTax := TZUGFeRDHelper.FindFirstMatchingItem<TZUGFeRDTax>(loadedInvoice.Taxes,
      function(Item: TZUGFeRDTax): Boolean
      begin
        result := Item.BasisAmount = 275.0;
      end);
    Assert.IsNotNull(tax);
    Assert.AreEqual(Currency(275.0), tax.BasisAmount);
    Assert.AreEqual(Currency(7), tax.Percent);
    Assert.AreEqual(TZUGFeRDTaxTypes.VAT, tax.TypeCode);
    Assert.AreEqual(TZUGFeRDTaxCategoryCodes.S, tax.CategoryCode.Value);

    Assert.AreEqual(timestamp, loadedInvoice.BillingPeriodStart.Value);
    Assert.AreEqual(timestamp.IncDay(14), loadedInvoice.BillingPeriodEnd.Value);

    //TradeAllowanceCharges
    var tradeAllowanceCharge: TZUGFeRDTradeAllowanceCharge := TZUGFeRDHelper.FindFirstMatchingItem
      <TZUGFeRDTradeAllowanceCharge>(loadedInvoice.TradeAllowanceCharges,
      function(Item: TZUGFeRDTradeAllowanceCharge):Boolean
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
    var serviceCharge: TZUGFeRDServiceCharge := TZUGFeRDHelper.FindFirstMatchingItem<TZUGFeRDServiceCharge>
      (loadedInvoice.ServiceCharges, function(Item: TZUGFeRDServiceCharge): Boolean
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
    var loadedLineItem: TZUGFeRDTradeLineItem := TZUGFeRDHelper.FindFirstMatchingItem<TZUGFeRDTradeLineItem>
      (loadedInvoice.TradeLineItems,
      function(Item: TZUGFeRDTradeLIneItem): Boolean
      begin
        result := Item.SellerAssignedID = 'TB100A4';
      end);
    Assert.IsNotNull(loadedLineItem);
    Assert.IsTrue(not string.IsNullOrEmpty(loadedLineItem.AssociatedDocument.LineID));
    Assert.AreEqual('This is line item TB100A4', loadedLineItem.Description);

    Assert.AreEqual('Trennblätter A4', loadedLineItem.Name);

    Assert.AreEqual('TB100A4', loadedLineItem.SellerAssignedID);
    Assert.AreEqual('0815', loadedLineItem.BuyerAssignedID);
    Assert.AreEqual(TZUGFeRDGlobalIDSchemeIdentifiers.EAN, loadedLineItem.GlobalID.SchemeID);
    Assert.AreEqual('4012345001235', loadedLineItem.GlobalID.ID);

    //GrossPriceProductTradePrice
    Assert.AreEqual(Currency(9.9), loadedLineItem.GrossUnitPrice.Value);
    Assert.AreEqual(TZUGFeRDQuantityCodes.H87, loadedLineItem.UnitCode);
    Assert.AreEqual(Double(3), loadedLineItem.UnitQuantity.Value);

    //NetPriceProductTradePrice
    Assert.AreEqual(Currency(9.9), loadedLineItem.NetUnitPrice.Value);
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

    var lineItemReferencedDoc: TZUGFeRDAdditionalReferencedDocument := TZUGFeRDHelper.FindFirstMatchingItem
      <TZUGFeRDAdditionalReferencedDocument>(loadedLineItem.AdditionalReferencedDocuments,
      function(Item: TZUGFeRDAdditionalReferencedDocument): Boolean
      begin
        result := True;
      end);
    Assert.IsNotNull(lineItemReferencedDoc);
    Assert.AreEqual('xyz', lineItemReferencedDoc.ID);
    Assert.AreEqual(timestamp, lineItemReferencedDoc.IssueDateTime.Value);
    Assert.AreEqual(TZUGFeRDReferenceTypeCodes.AAB, lineItemReferencedDoc.ReferenceTypeCode);


    var productCharacteristics: TZUGFeRDApplicableProductCharacteristic :=
      TZUGFeRDHelper.FindFirstMatchingItem<TZUGFeRDApplicableProductCharacteristic>(
        loadedLineItem.ApplicableProductCharacteristics,
        function(Item: TZUGFeRDApplicableProductCharacteristic): Boolean
        begin
          result := True;
        end);
    Assert.IsNotNull(productCharacteristics);
    Assert.AreEqual('Product characteristics', productCharacteristics.Description);
    Assert.AreEqual('Product value', productCharacteristics.Value);

    Assert.AreEqual(timestamp, loadedLineItem.ActualDeliveryDate.Value);
    Assert.AreEqual(timestamp, loadedLineItem.BillingPeriodStart.Value);
    Assert.AreEqual(timestamp.IncDay(10), loadedLineItem.BillingPeriodEnd.Value);

    //Currently not implemented
    //var accountingAccount = loadedLineItem.ReceivableSpecifiedTradeAccountingAccounts.FirstOrDefault();
    //Assert.IsNotNull(accountingAccount);
    //Assert.AreEqual("987654", accountingAccount.TradeAccountID);


    var lineItemTradeAllowanceCharge: TZUGFeRDTradeAllowanceCharge := TZUGFeRDHelper.FindFirstMatchingItem
      <TZUGFeRDTradeAllowanceCharge>(loadedLineItem.TradeAllowanceCharges,
      function(Item: TZUGFeRDTradeAllowanceCharge): Boolean
      begin
        result := Item.Reason = 'Reason: UnitTest';
      end);
    Assert.IsNotNull(lineItemTradeAllowanceCharge);
    Assert.IsTrue(lineItemTradeAllowanceCharge.ChargeIndicator);
    Assert.AreEqual(Currency(10), lineItemTradeAllowanceCharge.BasisAmount.Value);
    Assert.AreEqual(Currency(50), lineItemTradeAllowanceCharge.ActualAmount);
    Assert.AreEqual('Reason: UnitTest', lineItemTradeAllowanceCharge.Reason);
    loadedInvoice.Free;
  finally
    desc.Free;
  end;

end;

initialization
  TDUnitX.RegisterTestFixture(TZUGFerd20Tests);

end.
