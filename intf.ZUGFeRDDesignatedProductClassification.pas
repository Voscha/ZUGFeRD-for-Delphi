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

unit intf.ZUGFeRDDesignatedProductClassification;

interface

uses intf.ZUGFeRDDesignatedProductClassificationCodes, intf.ZUGFeRDHelper;

type
  /// <summary>
  /// Detailed information on the item classification
  /// </summary>
  TZUGFeRDDesignatedProductClassification = class
  private
    FClassName: string;
    FListID: string;
    FListVersionID: string;
    FClassCode: ZUGFeRDNullableInt;
    procedure SetClassCode(const Value: ZUGFeRDNullableInt);
    procedure SetClassName(const Value: string);
    procedure SetListID(const Value: string);
    procedure SetListVersionID(const Value: string);
  public
    /// <summary>
    /// A code for the classification of an item according to type or kind or nature.
    ///
    /// Classification codes are used for the aggregation of similar products, which might be useful for various
    /// purposes, for instance like public procurement, in accordance with the Common Vocabulary for Public Procurement
    /// [CPV]), e-Commerce(UNSPSC) etc.
    /// </summary>
    property ClassCode: ZUGFeRDNullableInt read FClassCode write SetClassCode;

    /// <summary>
    /// Product classification name
    /// </summary>
    property ListID: string read FListID write SetListID;

    /// <summary>
    /// Version of product classification
    /// </summary>
    property ListVersionID: string read FListVersionID write SetListVersionID;

    /// <summary>
    /// Classification name
    /// </summary>
    property ClassName_: string read FClassName write SetClassName;
  end;

implementation

{ TZUGFeRDDesignatedProductClassification }

procedure TZUGFeRDDesignatedProductClassification.SetClassCode(
  const Value: ZUGFeRDNullableInt);
begin
  if Value.HasValue and (Value.Value <= Integer(High(TZUGFeRDDesignatedProductClassificationCodes))) then
    FClassCode := Value
  else
    FClassCode.ClearValue;
end;

procedure TZUGFeRDDesignatedProductClassification.SetClassName(const Value: string);
begin
  FClassName := Value;
end;

procedure TZUGFeRDDesignatedProductClassification.SetListID(const Value: string);
begin
  FListID := Value;
end;

procedure TZUGFeRDDesignatedProductClassification.SetListVersionID(const Value: string);
begin
  FListVersionID := Value;
end;

end.
