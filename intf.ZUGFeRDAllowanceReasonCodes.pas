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

unit intf.ZUGFeRDAllowanceReasonCodes;

interface

type
    /// <summary>
    /// Reason codes according to UN/EDIFACT UNTDID 7161 code list
    /// </summary>
	TZUGFeRDAllowanceReasonCodes = (
		/// <summary>
		/// Unknown
		/// </summary>
		Unknown = 0,

		/// <summary>
		/// Advertising
		/// </summary>
		Advertising = 1,

		/// <summary>
		/// Off-premises discount
		/// </summary>
		OffPremisesDiscount = 2,

		/// <summary>
		/// Customer discount
		/// </summary>
		CustomerDiscount = 3,

		/// <summary>
		/// Damaged goods
		/// </summary>
		DamagedGoods = 4,

		/// <summary>
		/// Early payment allowance
		/// </summary>
		EarlyPaymentAllowance = 66,

		/// <summary>
		/// Discount
		/// </summary>
		Discount = 95,

		/// <summary>
		/// Volume discount
		/// </summary>
		VolumeDiscount = 100,

		/// <summary>
		/// Special agreement
		/// </summary>
		SpecialAgreement = 102,

		/// <summary>
		/// Freight charge
		/// </summary>
		FreightCharge = 30, // FC

		/// <summary>
		/// Insurance
		/// </summary>
		Insurance = 31, // INS

		/// <summary>
		/// Packaging
		/// </summary>
		Packaging = 32, // PAC

		/// <summary>
		/// Pallet charge
		/// </summary>
		PalletCharge = 33, // PC

		/// <summary>
		/// Handling service
		/// </summary>
		HandlingService = 34, // SH

		/// <summary>
		/// Transport costs
		/// </summary>
		TransportCosts = 35, // TC

    /// <summary>
    /// Testing service
    /// </summary>
    TestingService = 36, // TAC

    /// <summary>
    /// Miscellaneous service
    /// </summary>
		MiscellaneousService = 99 // ZZZ
	);

  TZUGFeRDAllowanceReasonCodesExtensions = class
  public
    class function FromString(const s: string): TZUGFeRDAllowanceReasonCodes;
    class function EnumToString(codes: TZUGFeRDAllowanceReasonCodes): string;
  end;



implementation

uses System.SysUtils;


{ TZUGFeRDAllowanceReasonCodesExtensions }

class function TZUGFeRDAllowanceReasonCodesExtensions.EnumToString(
  codes: TZUGFeRDAllowanceReasonCodes): string;
begin
  case Codes of
    Unknown: result := '0';
    Advertising: result := 'AA';
    OffPremisesDiscount: result := 'ABL';
    CustomerDiscount: result := 'ADR';
    DamagedGoods: result := 'ADT';
    EarlyPaymentAllowance: result := 'EAB';
    Discount: result := '95';
    VolumeDiscount: result := '100';
    SpecialAgreement: result := '102';
    FreightCharge: result := 'FC';
    Insurance: result := 'FI';
    Packaging: result := 'PAC';
    PalletCharge: result := 'PC';
    HandlingService: result := 'SH';
    TransportCosts: result := 'TC';
    TestingService: result := 'TAC';
    MiscellaneousService: result := 'ZZZ';
  end;
end;

class function TZUGFeRDAllowanceReasonCodesExtensions.FromString(
  const s: string): TZUGFeRDAllowanceReasonCodes;
begin
  if SameText(s, 'AA') then
    result := Advertising
  else if SameText(s, 'ABL') then
    result := OffPremisesDiscount
  else if SameText(s, 'ADR') then
    result := CustomerDiscount
  else if SameText(s, 'ADT') then
    result := DamagedGoods
  else if SameText(s, 'EAB') then
    result := EarlyPaymentAllowance
  else if SameText(s, '95') then
    result := Discount
  else if SameText(s, '100') then
    result := VolumeDiscount
  else if SameText(s, '102') then
    result := SpecialAgreement
  else if SameText(s, 'FC') then
    result := FreightCharge
  else if SameText(s, 'FI') then
    result := Insurance
  else if SameText(s, 'PAC') then
    result := Packaging
  else if SameText(s, 'PC') then
    result := PalletCharge
  else if SameText(s, 'SH') then
    result := HandlingService
  else if SameText(s, 'TC') then
    result := TransportCosts
  else if SameText(s, 'TAC') then
    result := TestingService
  else if SameText(s, 'ZZZ') then
    result := MiscellaneousService
  else
    result := Unknown;
end;

end.
