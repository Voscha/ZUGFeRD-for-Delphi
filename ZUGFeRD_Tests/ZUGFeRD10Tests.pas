unit ZUGFeRD10Tests;

interface

uses
  DUnitX.TestFramework, System.Classes, System.SysUtils, TestBase, InvoiceProvider;

type
  [TestFixture]
  TZUGFeRD10Tests = class(TTestBase)
  private
    FInvoiceProvider: TInvoiceProvider;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestReferenceComfortInvoice;
    [Test]
    procedure TestReferenceComfortInvoiceRabattiert;
    [Test]
    procedure TestStoringInvoiceViaFile;
    [Test]
    procedure TestStoringInvoiceViaStreams;
    [Test]
    procedure TestMissingPropertiesAreNull;
  end;

implementation

uses intf.ZUGFeRDInvoiceDescriptor, intf.ZUGFeRDProfile, intf.ZUGFeRDInvoiceTypes, intf.ZUGFeRDVersion,
  intf.ZUGFeRDTradeLineItem, winapi.ActiveX;

procedure TZUGFeRD10Tests.Setup;
begin
  CoInitialize(nil);
  FInvoiceProvider := TInvoiceProvider.create;
end;

procedure TZUGFeRD10Tests.TearDown;
begin
  FInvoiceProvider.Free;
  CoUninitialize;
end;

procedure TZUGFeRD10Tests.TestMissingPropertiesAreNull;
var
  i: Integer;
  path: string;
  desc: TZUGFeRDInvoiceDescriptor;
  TLI: TZUGFeRDTradeLineItem;
begin
  path := '..\..\..\demodata\zugferd10\ZUGFeRD_1p0_COMFORT_Einfach.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  desc := TZUGFeRDInvoiceDescriptor.Load(path);
  try
    For i := 0 to desc.TradeLineItems.Count - 1 do
    begin
      TLI := desc.TradeLineItems[i];
      Assert.IsTrue(TLI.BillingPeriodStart.Value = Default(TDateTime));
      Assert.IsTrue(TLI.BillingPeriodEnd.Value = Default(TDateTime));
    end;
  finally
    desc.Free;
  end;

end;

procedure TZUGFeRD10Tests.TestReferenceComfortInvoice;
var
  path: string;
  desc: TZUGFeRDInvoiceDescriptor;
begin
  path := '..\..\..\demodata\zugferd10\ZUGFeRD_1p0_COMFORT_Einfach.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);
  desc := TZUGFeRDInvoiceDescriptor.Load(path);
  try
    Assert.AreEqual(desc.Profile, TZUGFeRDProfile.Comfort);
    Assert.AreEqual(desc.Type_, TZUGFeRDInvoiceType.Invoice);
  finally
    desc.Free;
  end;
end;

procedure TZUGFeRD10Tests.TestReferenceComfortInvoiceRabattiert;
var
  path: string;
  desc: TZUGFeRDInvoiceDescriptor;
begin
  path := '..\..\..\demodata\zugferd10\ZUGFeRD_1p0_COMFORT_Rabatte.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  desc := TZUGFeRDInvoiceDescriptor.Load(path);
  try
    desc.Save('test.xml', TZUGFeRDVersion.Version1, TZUGFeRDProfile.Comfort);

    Assert.AreEqual(desc.Profile, TZUGFeRDProfile.Comfort);
    Assert.AreEqual(desc.Type_, TZUGFeRDInvoiceType.Invoice);
    Assert.AreEqual(desc.CreditorBankAccounts[0].BankName, 'Hausbank München');
  finally
    desc.Free;
  end;

end;

procedure TZUGFeRD10Tests.TestStoringInvoiceViaFile;
var
  path: string;
  desc, desc2: TZUGFeRDInvoiceDescriptor;
begin
  path := 'output.xml';

  desc := FInvoiceProvider.CreateInvoice;
  desc2 := nil;
  try
    desc.Save(path, TZUGFeRDVersion.Version1, TZUGFeRDProfile.Comfort);
    desc2 := TZUGFeRDInvoiceDescriptor.Load(path);
    Assert.AreEqual(desc2.Profile, TZUGFeRDProfile.Comfort);
    Assert.AreEqual(desc2.Type_, TZUGFeRDInvoiceType.Invoice);
    Assert.AreEqual(TZUGFeRDInvoiceDescriptor.GetVersion(path), TZUGFeRDVersion.Version1);
    // TODO: Add more asserts
  finally
    desc2.Free;
    desc.Free;
  end;
end;

procedure TZUGFeRD10Tests.TestStoringInvoiceViaStreams;
var
  desc, desc2: TZUGFeRDInvoiceDescriptor;
  path: string;
  saveStream, loadStream: TFileStream;
  ms: TMemoryStream;
begin
  path := 'output_stream.xml';
  desc := FInvoiceProvider.CreateInvoice;
  try
    saveStream := TFileStream.Create(path, fmCreate);
    try
     desc.Save(saveStream, TZUGFeRDVersion.Version1, TZUGFeRDProfile.Comfort);
    finally
      SaveStream.Free;
    end;

    loadStream := TFileStream.create(path, fmOpenRead);
    desc2 := TZUGFeRDInvoiceDescriptor.Load(loadStream);
    try
      Assert.AreEqual(desc2.Profile, TZUGFeRDProfile.Comfort);
      Assert.AreEqual(desc2.Type_, TZUGFeRDInvoiceType.Invoice);
    finally
      desc2.Free;
      loadStream.Free;
    end;

    // try again with a memory stream
    ms := TMemoryStream.create;
    desc.Save(ms, TZUGFeRDVersion.Version1, TZUGFeRDProfile.Comfort);
    (*
    byte[] data = ms.ToArray();
    string s = System.Text.Encoding.Default.GetString(data);
    *)
   // TODO: Add more asserts
    ms.Free;
  finally
    desc.Free;
  end;

end;

initialization
  TDUnitX.RegisterTestFixture(TZUGFeRD10Tests);

end.
