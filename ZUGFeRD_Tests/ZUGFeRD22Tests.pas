unit ZUGFeRD22Tests;

interface

uses
  DUnitX.TestFramework,  System.Classes, System.SysUtils, System.Generics.Collections, TestBase,
  InvoiceProvider, System.DateUtils;

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
    procedure TestMimetypeOfEmbeddedAttachment;
    [Test]
    procedure TestOrderInformation;
    [Test]
    procedure TestSellerOrderReferencedDocument;
    [Test]
    procedure TestWriteAndReadBusinessProcess;
    [Test]
    procedure TestWriteAndReadExtended;
    [Test]
    procedure TestFinancialInstitutionBICEmpty;
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
    procedure TestReferenceXRechnung21UBL;
    [Test]
    procedure TestWriteAndReadDespatchAdviceDocumentReferenceXRechnung;
    [Test]
    procedure TestSpecifiedTradeAllowanceCharge;
  end;

implementation

uses intf.ZUGFeRDInvoiceDescriptor, intf.ZUGFeRDProfile, intf.ZUGFeRDInvoiceTypes, intf.ZUGFeRDHelper,
  intf.ZUGFeRDTradeLineItem, intf.ZUGFeRDVersion, intf.ZUGFeRDTradeAllowanceCharge, intf.ZUGFeRDTaxTypes,
  intf.ZUGFeRDTaxCategoryCodes, intf.ZUGFeRDElectronicAddressSchemeIdentifiers, intf.ZUGFeRDParty,
  intf.ZUGFeRDLegalOrganization, intf.ZUGFeRDAdditionalReferencedDocumentTypeCodes,
  intf.ZUGFeRDReferenceTypeCodes, intf.ZUGFeRDAdditionalReferencedDocument,
  intf.ZUGFeRDContractReferencedDocument, intf.ZUGFeRDCurrencyCodes, intf.ZUGFeRDGlobalID,
  intf.ZUGFeRDApplicableProductCharacteristic, intf.ZUGFeRDGlobalIDSchemeIdentifiers,
  intf.ZUGFeRDQuantityCodes, intf.ZUGFeRDCountryCodes, intf.ZUGFeRDPaymentTerms,
  intf.ZUGFeRDTaxRegistration, intf.ZUGFeRDTaxRegistrationSchemeID,
  intf.ZUGFeRDSellerOrderreferencedDocument;

procedure TZUGFeRD22Tests.Setup;
begin
  FInvoiceProvider := TInvoiceProvider.create;
end;

procedure TZUGFeRD22Tests.TearDown;
begin
  FInvoiceProvider.Free;
end;

procedure TZUGFeRD22Tests.TestAdditionalReferencedDocument;
begin
  var uuid := TZUGFerdHelper.CreateUuid;
  var issueDateTime: TDateTime := Date;

  var desc := FInvoiceProvider.CreateInvoice();
  desc.AddAdditionalReferencedDocument(uuid, TZUGFeRDAdditionalReferencedDocumentTypeCode.Unknown,
    issueDateTime, 'Additional Test Document');

  var ms := TMemoryStream.Create();
  desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Extended);
  desc.Free;

  ms.Seek(0, soBeginning);
  var reader := TStreamReader.Create(ms);
  var text := reader.ReadToEnd();
  reader.Free;

  ms.Seek(0, soBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;
  Assert.AreEqual(1, loadedInvoice.AdditionalReferencedDocuments.Count);
  Assert.AreEqual('Additional Test Document', loadedInvoice.AdditionalReferencedDocuments[0].Name);
  Assert.AreEqual(issueDateTime, loadedInvoice.AdditionalReferencedDocuments[0].IssueDateTime.Value);
  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestAltteilSteuer;
begin

end;

procedure TZUGFeRD22Tests.TestBasisQuantityMultiple;
begin

end;

procedure TZUGFeRD22Tests.TestBasisQuantityStandard;
begin

end;

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
    desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFerDProfile.Extended);
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
  var issueDateTime: TDateTime := Date;

  desc := FInvoiceProvider.CreateInvoice();
  try
    desc.ContractReferencedDocument := TZUGFeRDContractReferencedDocument.CreateWithParams(uuid, IssueDateTime);

    desc.Save('TestInvoice.xml', TZUGFeRDVersion.Version22, TZUGFeRDProfile.XRechnung);
    var ms := TMemoryStream.Create;
    desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.XRechnung);
    ms.Seek(0, soBeginning);
    Assert.AreEqual(desc.Profile, TZUGFeRDProfile.XRechnung);

    var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
    ms.Free;
    Assert.AreEqual(loadedInvoice.ContractReferencedDocument.ID, uuid);
    Assert.IsNull(loadedInvoice.ContractReferencedDocument.IssueDateTime); // explicitly not to be set in XRechnung
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

    desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.EReporting);
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

procedure TZUGFeRD22Tests.TestElectronicAddress;
var
  desc: TZUGFeRDInvoicedescriptor;
begin
  desc := FInvoiceProvider.CreateInvoice;
  try
    desc.SetSellerElectronicAddress('DE123456789', TZUGFeRDElectronicAddressSchemeIdentifiers.GermanyVatNumber);
    desc.SetBuyerElectronicAddress('LU987654321', TZUGFeRDElectronicAddressSchemeIdentifiers.LuxemburgVatNumber);

    var ms := TMemoryStream.Create;
    desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.XRechnung);
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

procedure TZUGFeRD22Tests.TestFinancialInstitutionBICEmpty;
begin

end;

procedure TZUGFeRD22Tests.TestInvalidTaxTypes;
begin
  var invoice := FInvoiceProvider.CreateInvoice();
  for var Item in invoice.TradeLineItems do
    Item.TaxType := TZUGFeRDTaxTypes.AAA;

  var ms := TMemoryStream.Create;
  try
    invoice.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Basic);
  except
      Assert.Fail();
  end;

  try
    invoice.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.BasicWL);
  except
      Assert.Fail();
  end;

  try
    invoice.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Comfort);
  except
      Assert.Fail();
  end;

  try
      invoice.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Comfort);
  except
      Assert.Fail();
  end;

  // allowed in extended profile

  try
    invoice.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.XRechnung1);
  except
      Assert.Fail();
  end;

  try
    invoice.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.XRechnung);
  except
    Assert.Fail();
  end;
  Assert.AreEqual(TZUGFeRDInvoiceType.Invoice, invoice.type_);
  ms.Free;
  invoice.Free;
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
            0,
            'Ausführbare Datei',
            TZUGFeRDReferenceTypeCodes.Unknown,
            msref1,
            filename
    );

    var ms := TMemoryStream.Create();
    desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Basic);
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
            0,
            'Ausführbare Datei',
            TZUGFeRDReferenceTypeCodes.Unknown,
            msref1,
            filename
    );

    var ms := TMemoryStream.Create();
    desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Comfort);
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
            0,
            'Ausführbare Datei',
            TZUGFeRDReferenceTypeCodes.Unknown,
            msref1,
            filename
    );

    var ms := TMemoryStream.Create();
    desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Extended);
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
            0,
            'Ausführbare Datei',
            TZUGFeRDReferenceTypeCodes.Unknown,
            msref1,
            filename
    );

    var ms := TMemoryStream.Create();
    desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.XRechnung);
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
    invoiceDescriptor.PaymentTermsList[0].Description.Trim());
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
        timestamp,
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
        timestamp.IncDay(-2),
        'EmbeddedPdf',
        TZUGFeRDReferenceTypeCodes.Unknown,
        msref2,
        filename2
    );

  var ms := TMemoryStream.Create;

  desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Extended);
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
    desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFerDProfile.Minimum);
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
  desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Extended);
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

procedure TZUGFeRD22Tests.TestPartyExtensions;
begin
  var desc := FInvoiceProvider.CreateInvoice();
  var _party := TZUGFeRDParty.Create;
  _party.Name := 'Test';
  _party.ContactName := 'Max Mustermann';
  _party.Postcode := '83022';
  _party.City := 'Rosenheim';
  _party.Street := 'Münchnerstraße 123';
  _party.AddressLine3 := 'EG links';
  _party.CountrySubdivisionName := 'Bayern';
  _party.Country := TZUGFeRDCountryCodes.DE;

  desc.Invoicee := _Party; // this information will not be stored in the output file since it is available in Extended profile only

  var ms := TMemoryStream.Create;

  desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Extended);
  desc.Free;
  ms.Seek(0, soBeginning);

  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;
  Assert.AreEqual('Test', loadedInvoice.Invoicee.Name);
  Assert.AreEqual('Max Mustermann', loadedInvoice.Invoicee.ContactName);
  Assert.AreEqual('83022', loadedInvoice.Invoicee.Postcode);
  Assert.AreEqual('Rosenheim', loadedInvoice.Invoicee.City);
  Assert.AreEqual('Münchnerstraße 123', loadedInvoice.Invoicee.Street);
  Assert.AreEqual('EG links', loadedInvoice.Invoicee.AddressLine3);
  Assert.AreEqual('Bayern', loadedInvoice.Invoicee.CountrySubdivisionName);
  Assert.AreEqual(TZUGFeRDCountryCodes.DE, loadedInvoice.Invoicee.Country);
  loadedInvoice.Free;
end;

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
      Assert.AreEqual(charge.Tax.CategoryCode, TZUGFeRDTaxCategoryCodes.S);
    end;

    Assert.AreEqual(_tradeAllowanceCharges.Count, 4);
    Assert.AreEqual(_tradeAllowanceCharges[0].Tax.Percent, Currency(19));
    Assert.AreEqual(_tradeAllowanceCharges[1].Tax.Percent, Currency(7));
    Assert.AreEqual(_tradeAllowanceCharges[2].Tax.Percent, Currency(19));
    Assert.AreEqual(_tradeAllowanceCharges[3].Tax.Percent, Currency(7));

    Assert.AreEqual(desc.ServiceCharges.Count, 1);
    Assert.AreEqual(desc.ServiceCharges[0].Tax.TypeCode, TZUGFeRDTaxTypes.VAT);
    Assert.AreEqual(desc.ServiceCharges[0].Tax.CategoryCode, TZUGFeRDTaxCategoryCodes.S);
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

procedure TZUGFeRD22Tests.TestReferenceXRechnung21UBL;
begin

end;

procedure TZUGFeRD22Tests.TestSellerOrderReferencedDocument;
begin
  var uuid := TZUGFerdHelper.CreateUuid;
  var issueDateTime: TDateTime := Date;

  var desc := FInvoiceProvider.CreateInvoice();
  desc.SellerOrderReferencedDocument := TZUGFeRDSellerOrderReferencedDocument.CreateWithParams(
    uuid, issueDateTime);

  var ms := TMemoryStream.Create;
  desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Extended);
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

procedure TZUGFeRD22Tests.TestSpecifiedTradeAllowanceCharge;

begin
  var invoice := FInvoiceProvider.CreateInvoice();
  try
    invoice.TradeLineItems[0].AddSpecifiedTradeAllowanceCharge(true, TZUGFeRDCurrencyCodes.EUR,
      198, 19.8, 10, 'Discount 10%');

    var ms := TMemoryStream.Create;
    invoice.Save(ms, TZUGFeRDVersion.Version22, TZUGFerDProfile.Extended);
    ms.Position := 0;

    var loadedInvoice := TZUGFerDInvoiceDescriptor.Load(ms);
    ms.Free;
    var allowanceCharge := loadedInvoice.TradeLineItems[0].SpecifiedTradeAllowanceCharges.First();

    Assert.AreEqual(allowanceCharge.ChargeIndicator, false);//false = discount
    //CurrencyCodes are not written bei InvoiceDescriptor22Writer
    //Assert.AreEqual(allowanceCharge.Currency, CurrencyCodes.EUR);
    Assert.AreEqual(allowanceCharge.BasisAmount, Currency(198));
    Assert.AreEqual(allowanceCharge.ActualAmount, Currency(19.8));
    Assert.AreEqual(allowanceCharge.ChargePercentage, Currency(10));
    Assert.AreEqual(allowanceCharge.Reason, 'Discount 10%');
    loadedInvoice.Free;
  finally
    invoice.Free;
  end;

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
    originalDesc.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Basic);
    originalDesc.Save('zugferd_2p1_BASIC_Einfach-factur-x_Result.xml', TZUGFeRDVersion.Version22);

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
      TZUGFeRDNullableParam<Currency>.Create(9.9),
      TZUGFeRDNullableParam<Currency>.Create(9.9),
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
      TZUGFeRDNullableParam<Currency>.Create(5.5),
      TZUGFeRDNullableParam<Currency>.Create(5.5),
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
  d.AddApplicableTradeTax(275.00, 7.00, TZUGFeRDTaxTypes.VAT, TZUGFeRDTaxCategoryCodes.S);
  d.AddApplicableTradeTax(198.00, 19.00, TZUGFeRDTaxTypes.VAT, TZUGFeRDTaxCategoryCodes.S);

  var stream := TMemoryStream.Create;
  d.Save(stream, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Comfort);
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
    desc.Save(msExtended, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Extended);
    msExtended.Seek(0, soBeginning);

    var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(msExtended);
    msExtended.Free;
    Assert.AreEqual(loadedInvoice.RoundingAmount.Value, Currency(0.01));
    loadedInvoice.Free;

    var msBasic := TMemoryStream.Create;
    desc.Save(msBasic, TZUGFeRDVersion.Version22);
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
    desc.Save(msExtended, TZUGFeRDVersion.Version22, TZUGFeRDProfile.XRechnung);
    msExtended.Seek(0, soBeginning);

    var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(msExtended);
    msExtended.Free;
    Assert.AreEqual(loadedInvoice.RoundingAmount.Value, Currency(0.01));
    loadedInvoice.Free;

    var msBasic := TMemoryStream.Create;
    desc.Save(msBasic, TZUGFeRDVersion.Version22);
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

end;

procedure TZUGFeRD22Tests.TestTradeAllowanceChargeWithoutExplicitPercentage;
begin

end;

procedure TZUGFeRD22Tests.TestValidTaxTypes;
begin
  var invoice := FInvoiceProvider.CreateInvoice();
  for var Item  in invoice.TradeLineItems do
    Item.TaxType := TZUGFeRDTaxTypes.VAT;

  var ms := TMemoryStream.Create;
  try
    invoice.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Basic);
  except
    on E:Exception do
      Assert.Fail('', E);
  end;

  try
    invoice.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.BasicWL);

  except
      Assert.Fail();
  end;

  try
    invoice.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Comfort);
  except
    Assert.Fail();
  end;

  try
    invoice.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Extended);
  except
      Assert.Fail();
  end;

  try
    invoice.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.XRechnung1);
  except
    Assert.Fail();
  end;

  for var Item  in invoice.TradeLineItems do
    Item.TaxType := TZUGFeRDTaxTypes.AAA;

  try
    invoice.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.XRechnung);
  except
      Assert.Fail();
  end;

  // extended profile supports other tax types as well:
//  invoice.TradeLineItems.ForEach(i => i.TaxType = TaxTypes.AAA);
  try
    invoice.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Extended);
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
  desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Extended);
  desc.Free;
  ms.Seek(0, soBeginning);
  var loadedInvoice := TZUGFeRDInvoiceDescriptor.Load(ms);
  ms.Free;

  Assert.AreEqual('A1', loadedInvoice.BusinessProcess);
  loadedInvoice.Free;
end;

procedure TZUGFeRD22Tests.TestWriteAndReadDespatchAdviceDocumentReferenceXRechnung;
begin

end;

procedure TZUGFeRD22Tests.TestWriteAndReadExtended;
begin

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
  var _tempTradeLineItem := TZUGFeRDTradeLineItem.Create;
  _tempTradeLineItem.BilledQuantity := 10;
  _tempTradeLineItem.NetUnitPrice := 1;
  originalInvoiceDescriptor.TradeLineItems.Add(_tempTradeLineItem);

  originalInvoiceDescriptor.IsTest := false;

  var memoryStream := TMemoryStream.Create;
  originalInvoiceDescriptor.Save(memoryStream, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Basic);
  originalInvoiceDescriptor.Save('xrechnung with trade line settlement filled.xml', TZUGFeRDVersion.Version22);
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
  var _tempTradeLineItem := TZUGFeRDTradeLineItem.Create;
  _tempTradeLineItem.BillingPeriodStart := EncodeDate(2020,1,1);
  _tempTradeLineItem.BillingPeriodEnd := EncodeDate(2021, 1, 1);
  originalInvoiceDescriptor.TradeLineItems.Add(_tempTradeLineItem);

  var _tempTradeLineItem2 := TZUGFeRDTradeLineItem.Create;
  _tempTradeLineItem2.BillingPeriodStart := EncodeDate(2021,1,1);
  _tempTradeLineItem2.BillingPeriodEnd := EncodeDate(2022, 1, 1);
  originalInvoiceDescriptor.TradeLineItems.Add(_tempTradeLineItem2);

  originalInvoiceDescriptor.IsTest := false;

  var memoryStream := TMemoryStream.create;
  originalInvoiceDescriptor.Save(memoryStream, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Basic);
  originalInvoiceDescriptor.Save('xrechnung with trade line settlement filled.xml', TZUGFeRDVersion.Version22);
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
  originalInvoiceDescriptor.Save(memoryStream, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Basic);
  originalInvoiceDescriptor.Save('xrechnung with trade line settlement filled.xml', TZUGFeRDVersion.Version22);
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

  var _tempTradeLineItem := TZUGFeRDTradeLineItem.Create;
  _tempTradeLIneItem.NetUnitPrice := 25;
  // Modifiy trade line settlement data
  originalInvoiceDescriptor.TradeLineItems.Add(_tempTradeLineItem);

  originalInvoiceDescriptor.IsTest := false;

  var memoryStream := TMemoryStream.Create;
  originalInvoiceDescriptor.Save(memoryStream, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Basic);
  originalInvoiceDescriptor.Save('xrechnung with trade line settlement filled.xml', TZUGFeRDVersion.Version22);
  originalInvoiceDescriptor.Free;

  // Load Invoice and compare to expected
  var invoiceDescriptor := TZUGFeRDInvoiceDescriptor.Load(memoryStream);
  memoryStream.Free;
  Assert.AreEqual(Currency(25), invoiceDescriptor.TradeLineItems[0].NetUnitPrice.Value);
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
  var _tempTradeLineItem := TZUGFeRDTradeLineItem.Create;
  _tempTradeLineItem.ApplicableProductCharacteristics.Add(
    TZUGFeRDApplicableProductCharacteristic.CreateWithParams('Description_1_1', 'Value_1_1'));
  _tempTradeLineItem.ApplicableProductCharacteristics.Add(
    TZUGFeRDApplicableProductCharacteristic.CreateWithParams('Description_1_2', 'Value_1_2'));
  originalInvoiceDescriptor.TradeLineItems.Add(_tempTradeLineItem);

  var _tempTradeLineItem2 := TZUGFeRDTradeLineItem.Create;
  _tempTradeLineItem2.ApplicableProductCharacteristics.Add(
    TZUGFeRDApplicableProductCharacteristic.CreateWithParams('Description_2_1', 'Value_2_1'));
  _tempTradeLineItem2.ApplicableProductCharacteristics.Add(
    TZUGFeRDApplicableProductCharacteristic.CreateWithParams('Description_2_2', 'Value_2_2'));
  originalInvoiceDescriptor.TradeLineItems.Add(_tempTradeLineItem2);

  originalInvoiceDescriptor.IsTest := false;

  var memoryStream := TMemoryStream.Create;
  originalInvoiceDescriptor.Save(memoryStream, TZUGFeRDVersion.Version22, TZUGFeRDProfile.Basic);
  originalInvoiceDescriptor.Save('xrechnung with trade line settlement filled.xml', TZUGFeRDVersion.Version22);
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
    desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.XRechnung1);
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

    desc.Save(ms, TZUGFeRDVersion.Version22, TZUGFeRDProfile.XRechnung);
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
