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

unit intf.ZUGFeRDXMLUtils;

interface

uses System.Classes, System.SysUtils, Xml.Win.msxmldom, Winapi.MSXMLIntf, Winapi.msxml,
  intf.ZUGFeRDHelper;

type
  XMLUtils = class
  private
    class function SafeParseDateTime(const year: string = '0'; const month: string = '0';
      const day: string = '0'; const hour: string = '0'; const minute: string = '0';
      const second: string = '0'): TDateTime;
  public
    class function _nodeAsBool(node: IXmlDomNode; const xpath: string; defaultValue: Boolean = False): Boolean;
    class function _nodeAsString(node: IXmlDomNode; const xpath: string; defaultValue: string = ''): string;
    class function _nodeAsInt(node: IXmlDomNode; const xpath: string; defaultValue: Integer = 0): Integer;
    /// <summary>
    ///  reads the value from given xpath and interprets the value as decimal
    /// </summary>
    class function _nodeAsDecimal(node: IXmlDomNode; const xpath: string;
      defaultValue: IZUGFeRDNullableParam<Currency> = nil): ZUGFeRDNullable<Currency>;
    class function _nodeAsDouble(node: IXmlDomNode; const xpath: string;
      defaultValue: IZUGFeRDNullableParam<Double> = nil): ZUGFeRDNullable<Double>;
    class function _nodeAsDateTime(node: IXmlDomNode; const xpath: string;
      defaultValue: IZUGFeRDNullableParam<TDateTime> = nil): ZUGFeRDNullable<TDateTime>;
  end;

implementation

uses
  System.Variants, intf.ZUGFeRDExceptions, System.DateUtils;
{ XMLUtils }

class function XMLUtils.SafeParseDateTime(const year, month, day, hour, minute,
  second: string): TDateTime;
var
  _year, _month, _day, _hour, _minute, _second: Integer;
begin
  Result := 0;

  if not TryStrToInt(year, _year) then
    exit;

  if not TryStrToInt(month, _month) then
    exit;

  if not TryStrToInt(day, _day) then
    exit;

  if not TryStrToInt(hour, _hour) then
    exit;

  if not TryStrToInt(minute, _minute) then
    exit;

  if not TryStrToInt(second, _second) then
    exit;

  Result := EncodeDateTime(_year, _month, _day, _hour, _minute, _second, 0);
end;

class function XMLUtils._nodeAsBool(node: IXmlDomNode; const xpath: string;
  defaultValue: Boolean): Boolean;
var
  value: string;
begin
  Result := defaultValue;

  if node = nil then
    exit;

  value := _nodeAsString(node, xpath);
  if value.IsEmpty then
    exit
  else
  begin
    value := value.Trim.ToLower;
    if (value = 'true') or (value = '1') then
      Result := true
    else
      Result := false;
  end;

end;

class function XMLUtils._nodeAsDateTime(node: IXmlDomNode; const xpath: string;
  defaultValue: IZUGFeRDNullableParam<TDateTime>): ZUGFeRDNullable<TDateTime>;
var
  format, rawValue, year, month, day, hour, minute, second, week: string;
  dateNode: IXmlDomNode;
  aDayOfWeek: Integer;
  jan4,aDay : TDateTime;
begin
  Result := defaultValue;

  if node = nil then
    exit;

  format := '';
  dateNode := node.SelectSingleNode(xpath);
  if dateNode = nil then
  begin
    exit(defaultValue);
  end;

  if dateNode.Attributes.getNamedItem('format') <> nil then
  if dateNode.Attributes.getNamedItem('format').text <> '' then
    format := dateNode.Attributes.getNamedItem('format').text;

  rawValue := dateNode.text;

  if (Trim(rawValue) = '') then // we have to deal with real-life ZUGFeRD files :(
    exit;

  if (format='102') then
  begin
    if Length(rawValue) <> 8 then
      raise Exception.Create('Wrong length of datetime element (format 102)');

    year := Copy(rawValue, 1, 4);
    month := Copy(rawValue, 5, 2);
    day := Copy(rawValue, 7, 2);

    Result := SafeParseDateTime(year, month, day);
    exit;
  end else
  if (format='610') then
  begin
    if Length(rawValue) <> 6 then
      raise Exception.Create('Wrong length of datetime element (format 610)');

    year := Copy(rawValue, 1, 4);
    month := Copy(rawValue, 5, 2);
    day := '1';

    Result := SafeParseDateTime(year, month, day);
    exit;
  end else
  if (format='616') then
  begin
    if Length(rawValue) <> 6 then
      raise Exception.Create('Wrong length of datetime element (format 616)');

    year := Copy(rawValue, 1, 4);
    week := Copy(rawValue, 5, 2);

    jan4 := EncodeDate(StrToInt(year), 1, 4);
    aDay := IncWeek(jan4, StrToInt(week) - 1);
    aDayOfWeek := DayOfWeek(aDay) - 1;

    Result := aDay - aDayOfWeek;
    exit;
  end;

  // if none of the codes above is present, use fallback approach
  if Length(rawValue) = 8 then
  begin
    year := Copy(rawValue, 1, 4);
    month := Copy(rawValue, 5, 2);
    day := Copy(rawValue, 7, 2);

    Result := SafeParseDateTime(year, month, day);
    exit;
  end
  else if (Length(rawValue) = 10) then
  begin
    year := '';
    if (rawValue[5] = '-') and (rawValue[8] = '-') then // yyyy-mm-dd
    begin
      year := Copy(rawValue, 1, 4);
      month := Copy(rawValue, 6, 2);
      day := Copy(rawValue, 9, 2);
    end
    else if (rawValue[3] = FormatSettings.DateSeparator) and (rawValue[6] = FormatSettings.DateSeparator) then //dd.mm.yyyy
    begin
      year := Copy(rawValue, 7, 4);
      month := Copy(rawValue, 4, 2);
      day := Copy(rawValue, 1, 2);
    end;
    if year <> '' then
      Result := SafeParseDateTime(year, month, day);
    exit;
  end
  else if Length(rawValue) = 19 then
  begin
    year := Copy(rawValue, 1, 4);
    month := Copy(rawValue, 6, 2);
    day := Copy(rawValue, 9, 2);
    hour := Copy(rawValue, 12, 2);
    minute := Copy(rawValue, 15, 2);
    second := Copy(rawValue, 18, 2);

    Result := SafeParseDateTime(year, month, day, hour, minute, second);
    exit;
  end
  else
    raise TZUGFeRDUnsupportedException.Create('Invalid length of datetime value');
end;

class function XMLUtils._nodeAsDecimal(node: IXmlDomNode; const xpath: string;
  defaultValue: IZUGFeRDNullableParam<Currency>): ZUGFeRDNullable<Currency>;
var
  temp: string;
  Value: Currency;
begin
  if defaultValue = nil then
    Result := ZUGFeRDNullable<Currency>.Create(False)
  else
    Result := defaultValue.Value;

  if node = nil then
    exit;

  temp := _nodeAsString(node, xpath);
  if TryStrToCurr(temp, Value, FormatSettings.Invariant) then
    Result := Value;

end;

class function XMLUtils._nodeAsDouble(node: IXmlDomNode; const xpath: string;
  defaultValue: IZUGFeRDNullableParam<Double>): ZUGFeRDNullable<Double>;
var
  temp: string;
  Value: Double;
begin
  if defaultValue = nil then
    Result := ZUGFeRDNullable<Double>.Create(False)
  else
    Result := defaultValue.Value;

  if node = nil then
    exit;

  temp := _nodeAsString(node, xpath);
  if TryStrToFloat(temp, Value, FormatSettings.Invariant) then
    Result := Value;
end;

class function XMLUtils._nodeAsInt(node: IXmlDomNode; const xpath: string;
  defaultValue: Integer): Integer;
var
  temp: string;
begin
  Result := defaultValue;

  if node = nil then
    exit;

  temp := _nodeAsString(node, xpath);

  TryStrToInt(temp, Result);
end;

class function XMLUtils._nodeAsString(node: IXmlDomNode; const xpath: string;
  defaultValue: string): string;
var
  _node: IXmlDomNode;
begin
  Result := defaultValue;

  if node = nil then
    exit;

  try
    _node := node.SelectSingleNode(xpath);
    if _node <> nil then
      Result := _node.Text;
    exit;
  except
    on ex: Exception do
      raise ex;
  end;
end;

end.
