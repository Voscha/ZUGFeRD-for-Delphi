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

unit intf.ZUGFeRDDateTypeCodes;

interface

uses
  System.SysUtils,
  intf.ZUGFeRDHelper;

type
  TZUGFeRDDateTypeCodes = (

    /// <summary>
    /// Date of invoice
    /// </summary>
    InvoiceDate = 5,

    /// <summary>
    /// Date of delivery of goods to establishments/domicile/site
    /// </summary>
    DeliveryDate = 29,

    /// <summary>
    /// Payment date
    /// </summary>
    PaymentDate = 72
  );

  TZUGFeRDDateTypeCodesExtensions = class
    class function FromString(s: string): ZUGFeRDNullable<TZUGFeRDDateTypeCodes>;
    class function EnumToString(c: ZUGFeRDNullable<TZUGFeRDDateTypeCodes>): string;
  end;

implementation

{ TZUGFeRDDateTypeCodesExtensions }

class function TZUGFeRDDateTypeCodesExtensions.EnumToString(
  c: ZUGFeRDNullable<TZUGFeRDDateTypeCodes>): string;
begin
  if Not(c.HasValue) then
    exit('');
  case c.Value of
    TZUGFeRDDateTypeCodes.InvoiceDate: Result := '5';
    TZUGFeRDDateTypeCodes.DeliveryDate: Result := '29';
    TZUGFeRDDateTypeCodes.PaymentDate: Result := '72';
  else
    Result := '';
  end;
end;

class function TZUGFeRDDateTypeCodesExtensions.FromString(
  s: string): ZUGFeRDNullable<TZUGFeRDDateTypeCodes>;
begin
  if s='' then
    exit(Nil);
  if SameText(s,'5') then
    Result := TZUGFeRDDateTypeCodes.InvoiceDate else
  if SameText(s,'29') then
    Result := TZUGFeRDDateTypeCodes.DeliveryDate else
  if SameText(s,'72') then
    Result := TZUGFeRDDateTypeCodes.PaymentDate else
  Result := Nil
end;

end.
