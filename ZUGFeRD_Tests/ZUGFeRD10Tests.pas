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

unit ZUGFeRD10Tests;

interface

uses
  DUnitX.TestFramework, System.Classes, System.SysUtils, TestBase, InvoiceProvider, XML.XMLIntf;

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
    /// <summary>
    /// This test ensure that a BIC is created for the debitor account if it specified (in contrary to later versions of ZUGFeRD)
    /// </summary>
    [Test]
    procedure TestBICIDForDebitorFinancialInstitution;
    [Test]
    procedure TestSpecifiedTradePaymentTermsDescription;
    [Test]
    procedure TestSpecifiedTradePaymentTermsCalculationPercent;
    [Test]
    procedure TestMissingPropertiesAreNull;
  end;

implementation

uses intf.ZUGFeRDInvoiceDescriptor, intf.ZUGFeRDProfile, intf.ZUGFeRDInvoiceTypes, intf.ZUGFeRDVersion,
  intf.ZUGFeRDTradeLineItem, winapi.ActiveX, XML.XMLDoc, intf.ZUGFeRDXmlHelper;

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

procedure TZUGFeRD10Tests.TestBICIDForDebitorFinancialInstitution;
var
  desc: TZUGFeRDInvoiceDescriptor;
  XMLdoc: IXMLDocument;
begin
  desc := FInvoiceProvider.CreateInvoice();
  //PayerSpecifiedDebtorFinancialInstitution
  desc.AddDebitorFinancialAccount('DE02120300000000202051', 'MYBIC');

  var ms := TMemoryStream.Create;
  desc.Save(ms, TZUGFeRDVersion.Version1, TZUGFeRDProfile.Comfort);
  desc.Free;

  ms.Seek(0, soFromBeginning);

  var reader := TStreamReader.Create(ms);
  var text := reader.ReadToEnd();
  reader.Free;

  ms.Seek(0, soFromBeginning);

  XMLdoc := NewXMLDocument;
  XMLdoc.LoadFromStream(ms);
  ms.Free;

  XMLdoc.DocumentElement.DeclareNamespace('rsm', 'urn:ferd:CrossIndustryDocument:invoice:1p0');
  XMLdoc.DocumentElement.DeclareNamespace('ram', 'urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:12');
  XMLdoc.DocumentElement.DeclareNamespace('udt', 'urn:un:unece:uncefact:data:standard:UnqualifiedDataType:15');

  // no financial instituation shall be present for the debitor
  var doc := TZUGFeRDXmlHelper.PrepareDocumentForXPathQuerys(XMLdoc);
  var nodes := doc.SelectNodes('//ram:ApplicableSupplyChainTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayerSpecifiedDebtorFinancialInstitution');
  Assert.AreEqual(nodes.Length, 1);
  Assert.AreEqual(nodes[0].SelectSingleNode('./ram:BICID').Text, 'MYBIC');


end;  // !TestBICIDForDebitorFinancialInstitution()

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
      Assert.IsNull(TLI.BillingPeriodStart);
      Assert.IsNull(TLI.BillingPeriodEnd);
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
    Assert.IsTrue(desc.IsTest);
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
    Assert.AreEqual(desc.CreditorBankAccounts[0].BankName, 'Hausbank M�nchen');
  finally
    desc.Free;
  end;

end;

procedure TZUGFeRD10Tests.TestSpecifiedTradePaymentTermsCalculationPercent;
var
  path: string;
  desc: TZUGFeRDInvoiceDescriptor;
begin
  path := '..\..\..\demodata\zugferd10\ZUGFeRD_1p0_EXTENDED_Warenrechnung.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);

  desc := TZUGFeRDInvoiceDescriptor.Load(path);
  try
    Assert.IsNotNull(desc.PaymentTermsList.First().Percentage);
    Assert.AreEqual(Currency(2.0), desc.PaymentTermsList.First().Percentage.Value);
  finally
    desc.Free;
  end;
end;

procedure TZUGFeRD10Tests.TestSpecifiedTradePaymentTermsDescription;
var
  path: string;
  desc: TZUGFeRDInvoiceDescriptor;
begin
  path := '..\..\..\demodata\zugferd10\ZUGFeRD_1p0_EXTENDED_Warenrechnung.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);
  desc := TZUGFeRDInvoiceDescriptor.Load(path);
  try
    Assert.IsNotNull(desc.PaymentTermsList.First().Description);
    Assert.AreEqual('Bei Zahlung innerhalb 14 Tagen gew�hren wir 2,0% Skonto.',
      desc.PaymentTermsList.First().Description);
  finally
    desc.Free;
  end;
end; // !TestSpecifiedTradePaymentTermsDescription()

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
