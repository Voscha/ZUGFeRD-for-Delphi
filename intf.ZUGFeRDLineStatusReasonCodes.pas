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
unit intf.ZUGFeRDLineStatusReasonCodes;

interface

uses System.SysUtils,System.TypInfo, Intf.ZUGFeRDHelper;

type
    /// <summary>
    /// Used in BT-X-8
    /// </summary>
    TZUGFeRDLineStatusReasonCodes = (
      /// <summary>
      /// Unknown/ invalid line status code
      /// </summary>
      Unknown,

      /// <summary>
      /// Detail
      ///
      /// Regular item position (standard case)
      /// </summary>
      DETAIL,

      /// <summary>
      /// Subtotal
      /// </summary>
      GROUP,

      /// <summary>
      /// Solely information
      ///
      /// For information only
      /// </summary>
      INFORMATION
    );

  TZUGFeRDLineStatusReasonCodesExtensions = class
  public
    class function FromString(const s: string):  ZUGFeRDNullable<TZUGFeRDLineStatusReasonCodes>;
    class function EnumToString(t: ZUGFeRDNullable<TZUGFeRDLineStatusReasonCodes>): string;
  end;

implementation

{ TZUGFeRDLineStatusReasonCodesExtension }


class function TZUGFeRDLineStatusReasonCodesExtensions.EnumToString(
  t: ZUGFeRDNullable<TZUGFeRDLineStatusReasonCodes>): string;
begin
  if not t.HasValue then
    Result:= 'Unknown'
  else
    Result := GetEnumName(TypeInfo(TZUGFeRDLineStatusReasonCodes), Integer(t.Value));

end;

class function TZUGFeRDLineStatusReasonCodesExtensions.FromString(
  const s: string): ZUGFeRDNullable<TZUGFeRDLineStatusReasonCodes>;
var
  enumValue : Integer;
begin
  if string.IsNullOrEmpty(s) then
    Result := nil
  else begin
    enumValue := GetEnumValue(TypeInfo(TZUGFeRDLineStatusReasonCodes), s);
    if enumValue >= 0 then
      Result := TZUGFeRDLineStatusReasonCodes(enumValue)
    else
      Result :=  TZUGFeRDLineStatusReasonCodes.Unknown
  end;
end;

end.
