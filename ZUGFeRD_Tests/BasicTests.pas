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

unit BasicTests;

interface

uses
  DUnitX.TestFramework, TestBase, InvoiceProvider;

type
  [TestFixture]
  TBasicTests = class(TTestBase)
  private
    FInvoiceProvider: TInvoiceProvider;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestAutomaticLineIds;
    [Test]
    procedure TestManualLineIds;
    [Test]
    procedure TestCommentLine;
    [Test]
    procedure TestGetVersion;



  end;

implementation

uses intf.ZUGFeRDInvoiceDescriptor, intf.ZUGFeRDVersion, System.SysUtils;

procedure TBasicTests.Setup;
begin
  FInvoiceProvider := TInvoiceProvider.create;
end;

procedure TBasicTests.TearDown;
begin
  FInvoiceProvider.Free;
end;

procedure TBasicTests.TestAutomaticLineIds;
var
  desc: TZUGFeRDInvoiceDescriptor;
begin
  desc := FInvoiceProvider.CreateInvoice;
  try
    desc.TradeLineItems.Clear;

    desc.AddTradeLineItem('Item1', '');
    desc.AddTradeLineItem('Item2', '');

    Assert.AreEqual(desc.TradeLineItems[0].AssociatedDocument.LineID, '1');
    Assert.AreEqual(desc.TradeLineItems[1].AssociatedDocument.LineID, '2');
  finally
    desc.Free;
  end;

end;

procedure TBasicTests.TestCommentLine;
var
  GUID: TGUID;
  desc: TZUGFeRDInvoiceDescriptor;
begin
  CreateGuid(GUID);
  var COMMENT: string := GUIDToString(GUID);
  CreateGUID(GUID);
  var CUSTOM_LINE_ID: string := GUIDToString(GUID);

  // test with automatic line id
  desc := FInvoiceProvider.CreateInvoice;
  try
    var numberOfTradeLineItems := desc.TradeLineItems.Count;
    desc.AddTradeLineCommentItem(COMMENT);

    Assert.AreEqual(numberOfTradeLineItems + 1, desc.TradeLineItems.Count);
    Assert.IsNotNull(desc.TradeLineItems[desc.TradeLineItems.Count - 1].AssociatedDocument);
    Assert.IsNotNull(desc.TradeLineItems[desc.TradeLineItems.Count - 1].AssociatedDocument.Notes);
    Assert.AreEqual(desc.TradeLineItems[desc.TradeLineItems.Count - 1].AssociatedDocument.Notes.Count, 1);
    Assert.AreEqual(desc.TradeLineItems[desc.TradeLineItems.Count - 1].AssociatedDocument.Notes[0].Content, COMMENT);
  finally
    desc.Free;
  end;


  // test with manual line id
  desc := FInvoiceProvider.CreateInvoice;
  try
    var numberOfTradeLineItems := desc.TradeLineItems.Count;
    desc.AddTradeLineCommentItem(CUSTOM_LINE_ID, COMMENT);

    Assert.AreEqual(numberOfTradeLineItems + 1, desc.TradeLineItems.Count);
    Assert.IsNotNull(desc.TradeLineItems[desc.TradeLineItems.Count - 1].AssociatedDocument);
    Assert.IsNotNull(desc.TradeLineItems[desc.TradeLineItems.Count - 1].AssociatedDocument.LineID, CUSTOM_LINE_ID);
    Assert.IsNotNull(desc.TradeLineItems[desc.TradeLineItems.Count - 1].AssociatedDocument.Notes);
    Assert.AreEqual(desc.TradeLineItems[desc.TradeLineItems.Count - 1].AssociatedDocument.Notes.Count, 1);
    Assert.AreEqual(desc.TradeLineItems[desc.TradeLineItems.Count - 1].AssociatedDocument.Notes[0].Content, COMMENT);
  finally
    desc.Free;
  end;

end;

procedure TBasicTests.TestGetVersion;
var
  path: string;
begin
  path := '..\..\..\demodata\zugferd10\ZUGFeRD_1p0_COMFORT_Einfach.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);
  Assert.AreEqual(TZUGFeRDInvoiceDescriptor.GetVersion(path), TZUGFeRDVersion.Version1);

  path := '..\..\..\demodata\zugferd20\zugferd_2p0_BASIC_Einfach.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);
  Assert.AreEqual(TZUGFeRDInvoiceDescriptor.GetVersion(path), TZUGFeRDVersion.Version20);

  path := '..\..\..\demodata\zugferd21\zugferd_2p1_BASIC_Einfach-factur-x.xml';
  path := makeSurePathIsCrossPlatformCompatible(path);
  Assert.AreEqual(TZUGFeRDInvoiceDescriptor.GetVersion(path), TZUGFeRDVersion.Version22);

end;

procedure TBasicTests.TestManualLineIds;
var
  desc: TZUGFeRDInvoiceDescriptor;
begin
  desc := FInvoiceProvider.CreateInvoice();
  try
    desc.TradeLineItems.Clear();
    desc.AddTradeLineItem('item-01', 'Item1', '');
    desc.AddTradeLineItem('item-02', 'Item2', '');

    Assert.AreEqual(desc.TradeLineItems[0].AssociatedDocument.LineID, 'item-01');
    Assert.AreEqual(desc.TradeLineItems[1].AssociatedDocument.LineID, 'item-02');
  finally
    desc.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TBasicTests);

end.
