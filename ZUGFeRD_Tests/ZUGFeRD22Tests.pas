unit ZUGFeRD22Tests;

interface

uses
  DUnitX.TestFramework,  System.Classes, System.SysUtils, System.Generics.Collections, TestBase,
  InvoiceProvider;

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
  end;

implementation

uses intf.ZUGFeRDInvoiceDescriptor, intf.ZUGFeRDProfile, intf.ZUGFeRDInvoiceTypes, intf.ZUGFeRDHelper,
  intf.ZUGFeRDTradeLineItem, intf.ZUGFeRDVersion, intf.ZUGFeRDTradeAllowanceCharge, intf.ZUGFeRDTaxTypes,
  intf.ZUGFeRDTaxCategoryCodes, intf.ZUGFeRDElectronicAddressSchemeIdentifiers, intf.ZUGFeRDParty,
  intf.ZUGFeRDLegalOrganization, intf.ZUGFeRDAdditionalReferencedDocumentTypeCodes,
  intf.ZUGFeRDReferenceTypeCodes, intf.ZUGFeRDAdditionalReferencedDocument,
  intf.ZUGFeRDContractReferencedDocument;

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
begin

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

end;

procedure TZUGFeRD22Tests.TestMimetypeOfEmbeddedAttachment;
begin

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

end;

procedure TZUGFeRD22Tests.TestMissingPropertiesAreNull;
begin

end;

procedure TZUGFeRD22Tests.TestOrderInformation;
begin

end;

procedure TZUGFeRD22Tests.TestPartyExtensions;
begin

end;

procedure TZUGFeRD22Tests.TestReadTradeLineBillingPeriod;
begin

end;

procedure TZUGFeRD22Tests.TestReadTradeLineLineID;
begin

end;

procedure TZUGFeRD22Tests.TestReadTradeLineProductCharacteristics;
begin

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

end;

procedure TZUGFeRD22Tests.TestTotalRoundingExtended;
begin

end;

procedure TZUGFeRD22Tests.TestTotalRoundingXRechnung;
begin

end;

procedure TZUGFeRD22Tests.TestTradeAllowanceChargeWithExplicitPercentage;
begin

end;

procedure TZUGFeRD22Tests.TestTradeAllowanceChargeWithoutExplicitPercentage;
begin

end;

procedure TZUGFeRD22Tests.TestValidTaxTypes;
begin

end;

procedure TZUGFeRD22Tests.TestWriteAndReadBusinessProcess;
begin

end;

procedure TZUGFeRD22Tests.TestWriteAndReadDespatchAdviceDocumentReferenceXRechnung;
begin

end;

procedure TZUGFeRD22Tests.TestWriteAndReadExtended;
begin

end;

procedure TZUGFeRD22Tests.TestWriteTradeLineBilledQuantity;
begin

end;

procedure TZUGFeRD22Tests.TestWriteTradeLineBillingPeriod;
begin

end;

procedure TZUGFeRD22Tests.TestWriteTradeLineLineID;
begin

end;

procedure TZUGFeRD22Tests.TestWriteTradeLineNetUnitPrice;
begin

end;

procedure TZUGFeRD22Tests.TestWriteTradeLineProductCharacteristics;
begin

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
