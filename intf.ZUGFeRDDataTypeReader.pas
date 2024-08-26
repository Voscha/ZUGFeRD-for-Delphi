(*
 * Licensed to the Apache Software Foundation (ASF) under one
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
 * under the License.
 *)
unit intf.ZUGFeRDDataTypeReader;

interface

uses Xml.Win.msxmldom, Winapi.MSXMLIntf, Winapi.msxml,
intf.ZUGFeRDHelper, intf.ZUGFeRDXMLUtils, System.SysUtils;

type
  DataTypeReader = record
    class function ReadFormattedIssueDateTime(node: IXMLDOMNode; const xpath: string;
      defaultValue: IZUGFeRDNullableParam<TDateTime> = nil): ZUGFeRDNullable<TDateTime>; static;
  end;

implementation

{ DataTypeReader }

class function DataTypeReader.ReadFormattedIssueDateTime(node: IXMLDOMNode; const xpath: string;
  defaultValue: IZUGFeRDNullableParam<TDateTime>): ZUGFeRDNullable<TDateTime>;
var
  selectedNode: IXMLDOMNode;
  xml: string;
begin
  selectedNode := node.SelectSingleNode(xpath);
  if (selectedNode = nil) then
    exit(defaultValue);

  xml := selectedNode.Xml;
  if (xml.Contains('<qdt:')) then
    exit(XmlUtils._nodeAsDateTime(selectedNode, './qdt:DateTimeString'))
  else if (xml.Contains('<udt:')) then
    exit(XmlUtils._nodeAsDateTime(selectedNode, './udt:DateTimeString'));

  result := defaultValue;
end; // !ReadFormattedIssueDateTime()


end.
