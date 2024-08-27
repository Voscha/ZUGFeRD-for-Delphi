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

unit DataTypeReaderTests;

interface

uses
  DUnitX.TestFramework,  System.Classes, System.SysUtils, System.Generics.Collections, TestBase,
  System.DateUtils, XML.XMLDoc;

type
  [TestFixture]
  TDataTypeReaderTests = class(TTestBase)
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure ReadFormattedIssueDateTime_ReturnsCorrectDateTime_WhenNodeContainsQdt;
    [Test]
    procedure ReadFormattedIssueDateTime_ReturnsCorrectDateTime_WhenNodeContainsUdt;
    [Test]
    procedure ReadFormattedIssueDateTime_ReturnsDefaultValue_WhenNodeIsEmpty;
    [Test]
    procedure ReadFormattedIssueDateTime_ReturnsDefaultValue_WhenNodeDoesNotContainQdtOrUdt;
  end;

implementation

uses intf.ZUGFeRDXmlHelper, intf.ZUGFeRDDataTypeReader, intf.ZUGFeRDHelper, winapi.ActiveX;

{ TDataTypeReaderTests }

procedure TDataTypeReaderTests.ReadFormattedIssueDateTime_ReturnsCorrectDateTime_WhenNodeContainsQdt;
begin
  // Arrange
  var XMLDoc := NewXmlDocument();
  XMLDoc.LoadFromXml('<root xmlns="http://www.sample.com/file" xmlns:qdt="http://example.com/1">' +
              '<dateTime>' +
              '<qdt:DateTimeString format="102">20230101</qdt:DateTimeString>' +
              '</dateTime></root>');
  XMLDoc.DocumentElement.SetAttributeNS('xmlns:qdt','','http://example.com/1');
  XMLDoc.DocumentElement.SetAttributeNS('xmlns:def','','http://www.sample.com/file');

  var doc := TZUGFeRDXmlHelper.PrepareDocumentForXPathQuerys(XMLDoc);
  var node := doc.SelectSingleNode('//def:dateTime');

  // Act
  var result := DataTypereader.ReadFormattedIssueDateTime(node, '.', nil);

  // Assert
  Assert.AreEqual(EncodeDate(2023, 1, 1), result.Value);

end;

procedure TDataTypeReaderTests.ReadFormattedIssueDateTime_ReturnsCorrectDateTime_WhenNodeContainsUdt;
begin
  // Arrange
  var XMLDoc := NewXmlDocument();
  XMLDoc.LoadFromXml('<root xmlns="http://www.sample.com/file" xmlns:udt="http://example.com/1">' +
              '<dateTime>' +
              '<udt:DateTimeString format="102">20230101</udt:DateTimeString>' +
              '</dateTime></root>');
  XMLDoc.DocumentElement.SetAttributeNS('xmlns:udt','','http://example.com/1');
  XMLDoc.DocumentElement.SetAttributeNS('xmlns:def','','http://www.sample.com/file');

  var doc := TZUGFeRDXmlHelper.PrepareDocumentForXPathQuerys(XMLDoc);
  var node := doc.SelectSingleNode('//def:dateTime');

  // Act
  var result := DataTypereader.ReadFormattedIssueDateTime(node, '.', nil);

  // Assert
  Assert.AreEqual(EncodeDate(2023, 1, 1), result.Value);

end;

procedure TDataTypeReaderTests.ReadFormattedIssueDateTime_ReturnsDefaultValue_WhenNodeDoesNotContainQdtOrUdt;
begin
  // Arrange
  var XMLDoc := NewXmlDocument();
  XMLDoc.LoadFromXml('<root><dateTime>NoSpecialTag</dateTime></root>');
  var doc := TZUGFeRDXmlHelper.PrepareDocumentForXPathQuerys(XMLDoc);
  var node := doc.SelectSingleNode('//dateTime');

  var expected: TDateTime := EncodeDate(2023, 1, 1);
  // Act
  var result :=  DataTypereader.ReadFormattedIssueDateTime(node, '.',
    TZUGFeRDNullableParam<TDateTime>.Create(expected));

  // Assert
  Assert.AreEqual(expected, result.Value);
end;

procedure TDataTypeReaderTests.ReadFormattedIssueDateTime_ReturnsDefaultValue_WhenNodeIsEmpty;
begin
  // Arrange
  var XMLDoc := NewXmlDocument();
  XMLDoc.LoadFromXml('<root><dateTime></dateTime></root>');
  var doc := TZUGFeRDXmlHelper.PrepareDocumentForXPathQuerys(XMLDoc);
  var node := doc.SelectSingleNode('//dateTime');

  var expected: TDateTime := EncodeDate(2023, 1, 1);
  // Act
  var result :=  DataTypereader.ReadFormattedIssueDateTime(node, '.',
    TZUGFeRDNullableParam<TDateTime>.Create(expected));

  // Assert
  Assert.AreEqual(expected, result.Value);

end;

procedure TDataTypeReaderTests.Setup;
begin
  CoInitialize(nil);
end;

procedure TDataTypeReaderTests.TearDown;
begin
  CoUninitialize;
end;

end.
