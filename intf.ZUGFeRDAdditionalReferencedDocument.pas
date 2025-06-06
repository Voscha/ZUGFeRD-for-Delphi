﻿{* Licensed to the Apache Software Foundation (ASF) under one
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

unit intf.ZUGFeRDAdditionalReferencedDocument;

interface

uses
  System.SysUtils,System.Classes,
  intf.ZUGFeRDBaseReferencedDocument,
  intf.ZUGFeRDAdditionalReferencedDocumentTypeCodes,
  intf.ZUGFeRDReferenceTypeCodes,
  intf.ZUGFeRDMimeTypeMapper,
  intf.ZUGFeRDHelper
  ;

type
  /// <summary>
  /// Reference documents are supposed to hold additional data you might want to show on item level.
  ///
  /// Reference documents are used e.g. for commissions on item level
  /// </summary>
  TZUGFeRDAdditionalReferencedDocument = class(TZUGFeRDBaseReferencedDocument)
  private
    FReferenceTypeCode: ZUGFeRDNullable<TZUGFeRDReferenceTypeCodes>;
    FName: string;
    FAttachmentBinaryObject: TMemoryStream;
    FFilename: string;
    FTypeCode: ZUGFeRDNullable<TZUGFeRDAdditionalReferencedDocumentTypeCode>;
    FURIID: string;
    FLineID: string;
    function GetMimeType: string;
  public
    constructor Create(CreateAttachmentBinaryObject : Boolean);
    destructor Destroy; override;
  public
    /// <summary>
    /// External document location
    /// BT-124, BT-X-28
    /// </summary>
    property URIID: string read FURIID write FURIID;
    /// <summary>
    /// Referenced position
    /// BT-X-29
    /// </summary>
    property LineID: string read FLineID write FLineID;
    /// <summary>
    /// Type of the reference document
    /// BT-17-0, BT-18-0, BT-122-0, BT-X-30
    /// </summary>
    property TypeCode: ZUGFeRDNullable<TZUGFeRDAdditionalReferencedDocumentTypeCode> read FTypeCode write FTypeCode;
    /// <summary>
    /// Reference documents are strongly typed, specify ReferenceTypeCode to allow easy processing by invoicee
    /// </summary>
    property ReferenceTypeCode: ZUGFeRDNullable<TZUGFeRDReferenceTypeCodes> read FReferenceTypeCode write FReferenceTypeCode;
    /// <summary>
    /// Description of document
    /// </summary>
    property Name: string read FName write FName;
    /// <summary>
    /// An attached document embedded as binary object or sent together with the invoice.
    /// </summary>
    property AttachmentBinaryObject: TMemoryStream read FAttachmentBinaryObject write FAttachmentBinaryObject;
    /// <summary>
    /// Filename of attachment
    /// </summary>
    property Filename: string read FFilename write FFilename;
    /// <summary>
    /// MimeType of the attached document embedded as binary object.
    /// </summary>
    property MimeType: string read GetMimeType;
  end;

implementation

constructor TZUGFeRDAdditionalReferencedDocument.Create(CreateAttachmentBinaryObject : Boolean);
begin
  inherited Create;
  if CreateAttachmentBinaryObject then
    FAttachmentBinaryObject := TMemoryStream.Create
  else
    FAttachmentBinaryObject := nil;
end;

destructor TZUGFeRDAdditionalReferencedDocument.Destroy;
begin
  if Assigned(FAttachmentBinaryObject) then begin FAttachmentBinaryObject.Free; FAttachmentBinaryObject := nil; end;
  inherited;
end;

function TZUGFeRDAdditionalReferencedDocument.GetMimeType: string;
begin
  Result := TZUGFeRDMimeTypeMapper.GetMimeType(FFilename);
end;

end.
