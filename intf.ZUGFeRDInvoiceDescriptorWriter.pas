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

unit intf.ZUGFeRDInvoiceDescriptorWriter;

interface

uses
  System.Classes, System.SysUtils, System.DateUtils, System.StrUtils
  , System.Math
  ,intf.ZUGFeRDInvoiceDescriptor,intf.ZUGFeRDProfileAwareXmlTextWriter
  ,intf.ZUGFeRDProfile, intf.ZUGFeRDFormats, intf.ZUGFeRDHelper;

type
  TZUGFeRDInvoiceDescriptorWriter = class abstract
  private
    function _FloatFormat(cval: Currency; numDecimals: Integer): string;
  public
    procedure Save(_descriptor: TZUGFeRDInvoiceDescriptor; _stream: TStream;
      _format: TZUGFeRDFormats = TZUGFeRDFormats.CII); overload; virtual; abstract;
    procedure Save(_descriptor: TZUGFeRDInvoiceDescriptor; const _filename: string;
      _format: TZUGFeRDFormats = TZUGFeRDFormats.CII); overload;
    function Validate(descriptor: TZUGFeRDInvoiceDescriptor; throwExceptions: Boolean = True): Boolean; virtual; abstract;
  public
    procedure WriteOptionalElementString(writer: TZUGFeRDProfileAwareXmlTextWriter; const tagName, value: string; profile: TZUGFeRDProfiles = TZUGFERDPROFILES_DEFAULT);
    function _formatDecimal(value: IZUGFeRDNullableParam<Currency>; numDecimals: Integer = 2): string; overload;
    function _formatDecimal(value: IZUGFeRDNullableParam<Double>; numDecimals: Integer = 2): string; overload;
    function _formatDate(date: TDateTime; formatAs102: Boolean = True; toUBLDate: Boolean = False): string;
    function _asNullableParam<T>(Param: T): IZUGFeRDNullableParam<T>;
  end;

implementation

procedure TZUGFeRDInvoiceDescriptorWriter.Save(_descriptor: TZUGFeRDInvoiceDescriptor;
  const _filename: string; _format: TZUGFeRDFormats = TZUGFeRDFormats.CII);
var
  fs: TFileStream;
begin
  if Validate(_descriptor, True) then
  begin
    fs := TFileStream.Create(_filename, fmCreate or fmOpenWrite);
    try
      Save(_descriptor, fs, _format);
      //fs.Flush;
      //fs.Close;
    finally
      fs.Free;
    end;
  end;
end;

procedure TZUGFeRDInvoiceDescriptorWriter.WriteOptionalElementString(
  writer: TZUGFeRDProfileAwareXmlTextWriter;
  const tagName, value: string;
  profile: TZUGFeRDProfiles = TZUGFERDPROFILES_DEFAULT);
begin
  if not value.IsEmpty then
    writer.WriteElementString(tagName, value, profile);
end;

function TZUGFeRDInvoiceDescriptorWriter._formatDecimal(
  value: IZUGFeRDNullableParam<Currency>; numDecimals: Integer): string;
var
  cVal: Currency;
begin
  if value = nil then
    Exit(String.Empty);

  cval := RoundTo(value.Value,-numDecimals);
  result := _FloatFormat(cval, numDecimals)
end;

function TZUGFeRDInvoiceDescriptorWriter._formatDecimal(value: IZUGFeRDNullableParam<Double>;
  numDecimals: Integer): string;
var
  dval: Double;
begin
  if value = nil then
    Exit(String.Empty);
  dval := RoundTo(value.Value,-numDecimals);
  result := _FloatFormat(dval, numDecimals)
end;

function TZUGFeRDInvoiceDescriptorWriter._asNullableParam<T>(Param: T): IZUGFeRDNullableParam<T>;
begin
  result := TZUGFeRDNullableParam<T>.Create(Param);
end;

function TZUGFeRDInvoiceDescriptorWriter._FloatFormat(cval: Currency;
    numDecimals: Integer): string;
var
  i: Integer;
  formatString: string;
begin
  formatString := '0.';
  for i := 0 to numDecimals - 1 do
    formatString := formatString + '0';

  Result := FormatFloat(formatString, cval);
  Result := ReplaceText(Result,',','.');
end;

function TZUGFeRDInvoiceDescriptorWriter._formatDate(date: TDateTime; formatAs102: Boolean;
  toUBLDate: Boolean): string;
begin
  if formatAs102 then
    Result := FormatDateTime('yyyymmdd', date)
  else if toUBLDate then
    Result := FormatDateTime('yyyy-mm-dd', date)
  else
    Result := FormatDateTime('yyyy-mm-ddThh:nn:ss', date);
end;



end.
