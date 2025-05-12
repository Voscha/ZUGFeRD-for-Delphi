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

unit intf.ZUGFeRDAssociatedDocument;

interface

uses
  System.Generics.Collections, intf.ZUGFeRDNote, intf.ZUGFeRDLineStatusCodes,
  intf.ZUGFeRDHelper, intf.ZUGFeRDLineStatusReasonCodes;

type
  /// <summary>
  /// Representation for general information on item level
  /// </summary>
  TZUGFeRDAssociatedDocument = class
  private
    FNotes: TObjectList<TZUGFeRDNote>;
    FLineID: string;
    FParentLineID: string;
    FLineStatusCode: ZUGFeRDNullable<TZUGFeRDLineStatusCodes>;
    FLineStatusReasonCode: ZUGFeRDNullable<TZUGFeRDLineStatusReasonCodes>;
  public
    constructor Create(lineID: string);
    destructor Destroy; override;

    /// <summary>
    ///  Detailed information in free text form
    /// </summary>
    property Notes: TObjectList<TZUGFeRDNote> read FNotes;
    /// <summary>
    /// identifier of the invoice line item
    /// </summary>
    property LineID: string read FLineID write FLineID;
    /// <summary>
    /// Refers to the superior line in a hierarchical structure.
    /// This property is used to map a hierarchy tree of invoice items, allowing child items to reference their parent line.
    /// BT-X-304
    ///
    /// Example usage:
    /// <code>
    /// var tradeLineItem = new TradeLineItem();
    /// tradeLineItem.SetParentLineId("1");
    /// </code>
    /// </summary>
    property ParentLineID: string read FParentLineID write FParentLineID;
    /// <summary>
    /// Type of the invoice line item
    ///
    /// If the LineStatusCode element is used, the LineStatusReasonCode must be filled.
    ///
    /// BT-X-7
    /// </summary>
    property LineStatusCode: ZUGFeRDNullable<TZUGFeRDLineStatusCodes> read FLineStatusCode
      write FLineStatusCode;

    /// <summary>
    /// Subtype of the invoice line item
    ///
    /// BT-X-8
    /// </summary>
    property LineStatusReasonCode: ZUGFeRDNullable<TZUGFeRDLineStatusReasonCodes> read FLineStatusReasonCode
      write FLineStatusReasonCode;

  end;

implementation

constructor TZUGFeRDAssociatedDocument.Create(lineID: string);
begin
  FNotes := TObjectList<TZUGFeRDNote>.Create;
  FLineID := lineID;
end;

destructor TZUGFeRDAssociatedDocument.Destroy;
begin
  FNotes.Free;
  inherited Destroy;
end;


end.
