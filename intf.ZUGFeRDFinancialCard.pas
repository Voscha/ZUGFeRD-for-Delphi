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

unit intf.ZUGFeRDFinancialCard;

interface

type
  /// <summary>
  ///     Payment card information.
  /// </summary>
  TZUGFeRDFinancialCard = class
  private
    FId: string;
    FCardholderName: string;
  public
    constructor CreateWithParams(const aId, aCardholderName: string);
    /// <summary>
    ///     Payment card primary account number.
    /// </summary>
    property Id: string read FId write FId;
    /// <summary>
    ///     Payment card holder name.
    /// </summary>
    property CardholderName: string read FCardholderName write FCardholderName;
  end;

implementation

{ TZUGFeRDFinancialCard }

constructor TZUGFeRDFinancialCard.CreateWithParams(const aId, aCardholderName: string);
begin
  inherited Create;
  FId := aID;
  FCardholdername := aCardholderName;
end;

end.
