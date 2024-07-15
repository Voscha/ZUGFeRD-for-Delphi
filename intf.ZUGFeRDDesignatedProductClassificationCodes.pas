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

unit intf.ZUGFeRDDesignatedProductClassificationCodes;

interface

uses System.TypInfo;

type
  TZUGFeRDDesignatedProductClassicficationCodes =  (
    HS,
    Unknown
  );

  TZUGFeRDDesignatedProductClassicficationCodesExtensions = class
  public
    class function FromString(const s: string): TZUGFeRDDesignatedProductClassicficationCodes;
    class function EnumToString(codes: TZUGFeRDDesignatedProductClassicficationCodes): string;
  end;

implementation

{ TZUGFeRDDesignatedProductClassicficationCodesExtensions }

class function TZUGFeRDDesignatedProductClassicficationCodesExtensions.EnumToString(
  codes: TZUGFeRDDesignatedProductClassicficationCodes): string;
begin
  Result := GetEnumName(TypeInfo(TZUGFeRDDesignatedProductClassicficationCodes), Integer(codes));
end;

class function TZUGFeRDDesignatedProductClassicficationCodesExtensions.FromString(
  const s: string): TZUGFeRDDesignatedProductClassicficationCodes;
var
  enumValue : Integer;
begin
  enumValue := GetEnumValue(TypeInfo(TZUGFeRDDesignatedProductClassicficationCodes), s);
  Result := TZUGFeRDDesignatedProductClassicficationCodes(enumValue);
end;

end.
