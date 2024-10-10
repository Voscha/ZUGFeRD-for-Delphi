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

unit intf.UBLTaxRegistrationSchemeIDMapper;

interface

uses intf.ZUGFeRDTaxRegistrationSchemeID;

type
  TUBLTaxRegistrationSchemeIDMapper = class
    class function Map(const value: string):TZUGFeRDTaxRegistrationSchemeID; overload;
    class function Map(const _type: TZUGFeRDTaxRegistrationSchemeID): string; overload;
  end;

implementation

uses System.SysUtils;

{ TUBLTaxRegistrationSchemeIDMapperBL }

class function TUBLTaxRegistrationSchemeIDMapper.Map(
  const _type: TZUGFeRDTaxRegistrationSchemeID): string;
begin
  if (_type = TZUGFeRDTaxRegistrationSchemeID.VA) then
    exit ('VAT')
  else if (_type = TZUGFerDTaxRegistrationSchemeID.FC) then
    exit ('ID')
  else
    result := TZUGFeRDTaxRegistrationSchemeIDExtensions.EnumToString(_type);

end;

class function TUBLTaxRegistrationSchemeIDMapper.Map(
  const value: string): TZUGFeRDTaxRegistrationSchemeID;
begin
  if (value.ToUpper.Trim.Equals('VAT')) then
    exit (TZUGfeRDTaxRegistrationSchemeID.VA)
  else if (value.ToUpper().Trim().Equals('ID')) then
    exit (TZUGFerDTaxRegistrationSchemeID.FC)
  else
    result := TZUGFeRDTaxRegistrationSchemeIDExtensions.FromString(value);
end;

end.
