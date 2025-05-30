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

unit intf.ZUGFeRDBuyerOrderReferencedDocument;

interface

uses intf.ZUGFeRDBaseReferencedDocument;

type
  /// <summary>
  /// Structure containing details of the associated order
  /// </summary>
  TZUGFeRDBuyerOrderReferencedDocument = class(TZUGFeRDBaseReferencedDocument)
  private
    FLineID: string;
  public
    /// <summary>
    /// Reference to the order position BT-132
    /// </summary>
    property LineID: string read FLineID write FLineID;

  end;

implementation

{ TZUGFeRDBuyerOrderReferencedDocument }


end.
