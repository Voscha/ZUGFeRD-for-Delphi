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

unit intf.ZUGFeRDTax;

interface

uses
  System.SysUtils,System.Math,
  intf.ZUGFeRDTaxTypes,
  intf.ZUGFeRDTaxCategoryCodes,
  intf.ZUGFeRDTaxExemptionReasonCodes,
  intf.ZUGFeRDHelper;

type
  /// <summary>
  /// Structure for holding tax information (generally applicable trade tax)
  /// </summary>
  TZUGFeRDTax = class
  private
    FBasisAmount: Currency;
    FPercent: Currency;
    FTypeCode: TZUGFeRDTaxTypes;
    FCategoryCode: ZUGFeRDNullable<TZUGFeRDTaxCategoryCodes>;
    FAllowanceChargeBasisAmount: ZUGFeRDNullable<Currency>;
    FExemptionReasonCode: ZUGFeRDNullable<TZUGFeRDTaxExemptionReasonCodes>;
    FExemptionReason: string;
    FLineTotalBasisAmount: ZUGFeRDNullable<Currency>;
    function GetTaxAmount: Currency;
  public
    /// <summary>
    /// Returns the amount of the tax (Percent * BasisAmount)
    ///
    /// This information is calculated live.
    /// </summary>
    property TaxAmount: Currency read GetTaxAmount;
    /// <summary>
    /// VAT category taxable amount
    /// </summary>
    property BasisAmount: Currency read FBasisAmount write FBasisAmount;
    /// <summary>
    /// Tax rate
    /// </summary>
    property Percent: Currency read FPercent write FPercent;
    /// <summary>
    /// Type of tax.
    ///
    /// Generally, the fixed value is: "VAT"
    /// </summary>
    property TypeCode: TZUGFeRDTaxTypes read FTypeCode write FTypeCode default TZUGFeRDTaxTypes.VAT;
    /// <summary>
    /// The code valid for the invoiced goods sales tax category.
    /// </summary>
    property CategoryCode: ZUGFeRDNullable<TZUGFeRDTaxCategoryCodes> read FCategoryCode write FCategoryCode; 
    /// <summary>
    /// Total amount of charges / allowances on document level
    /// </summary>
    property AllowanceChargeBasisAmount: ZUGFeRDNullable<Currency> read FAllowanceChargeBasisAmount write FAllowanceChargeBasisAmount;
    /// <summary>
    /// A monetary value used as the line total basis on which this trade related tax, levy or duty is calculated
    /// </summary>
    property LineTotalBasisAmount: ZUGFeRDNullable<Currency> read FLineTotalBasisAmount write FLineTotalBasisAmount;
    /// <summary>
    /// ExemptionReasonCode for no Tax
    /// </summary>
    property ExemptionReasonCode: ZUGFeRDNullable<TZUGFeRDTaxExemptionReasonCodes> read FExemptionReasonCode write FExemptionReasonCode;
    /// <summary>
    /// Exemption Reason Text for no Tax
    /// </summary>
    property ExemptionReason: string read FExemptionReason write FExemptionReason;
  end;

implementation

{ TZUGFeRDTax }

function TZUGFeRDTax.GetTaxAmount: Currency;
begin
  //TODO pruefen System.Math.Round(0.01m * this.Percent * this.BasisAmount, 2, MidpointRounding.AwayFromZero);
  Result := RoundTo(0.01 * FPercent * FBasisAmount,-2);
end;

end.
