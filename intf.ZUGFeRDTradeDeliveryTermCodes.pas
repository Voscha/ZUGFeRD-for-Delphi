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

unit intf.ZUGFeRDTradeDeliveryTermCodes;

interface

uses System.SysUtils, System.TypInfo, Intf.ZUGFeRDHelper;

type

  /// <summary>
  /// Delivery term codes according to UNTDID 4053 + INCOTERMS code lists
	/// Lieferbedingung (Code), BT-X-145
  /// </summary>
  TZUGFeRDTradeDeliveryTermCodes = (
		/// <summary>
		/// Lieferung durch den Lieferanten organisiert
		/// Delivery arranged by the supplier
		///
		/// Indicates that the supplier will arrange delivery of the goods.
		/// </summary>
		_1,

		/// <summary>
		/// Lieferung durch Logistikdienstleister organisiert
		/// Delivery arranged by logistic service provider
		///
		/// Code indicating that the logistic service provider has
		/// arranged the delivery of goods.
		/// </summary>
		_2,

    /// <summary>
    /// CFR
    /// Kosten und Fracht
    /// </summary>
    CFR,

    /// <summary>
    /// CIF
    /// Kosten, Versicherung und Fracht
    /// </summary>
    CIF,

    /// <summary>
    /// CIP
    /// Transport und Versicherung bezahlt nach (benannten Bestimmungsort einfügen)
    /// </summary>
    CIP,

    /// <summary>
    /// CPT
    /// Frachtfrei nach (benannten Bestimmungsort einfügen)
    /// </summary>
    CPT,

    /// <summary>
    /// DAP
    /// Geliefert am Ort (benannten Bestimmungsort einfügen)
    /// </summary>
    DAP,

    /// <summary>
    /// DDP
    /// Geliefert verzollt (benannten Bestimmungsort einfügen)
    /// </summary>
    DDP,

    /// <summary>
    /// DPU
    /// Geliefert am Ort der Entladung (benannten Ort der Entladung einfügen)
    /// </summary>
    DPU,

    /// <summary>
    /// EXW
    /// Ab Werk (benannten Ort der Lieferung einfügen)
    /// </summary>
    EXW,

    /// <summary>
    /// FAS
    /// Frei Längsseite Schiff (benannten Verschiffungshafen einfügen)
    /// </summary>
    FAS,

    /// <summary>
    /// FCA
    /// Frei Frachtführer (benannten Ort der Zustellung einfügen)
    /// </summary>
    FCA,

    /// <summary>
    /// FOB
    /// Frei an Bord (benannten Verschiffungshafen einfügen)
    /// </summary>
    FOB
  );

  TZUGFeRDTradeDeliveryTermCodesExtensions = class
  public
    class function FromString(const s: string): ZUGFeRDNullable<TZUGFeRDTradeDeliveryTermCodes>;
    class function EnumToString(t: ZUGFeRDNullable<TZUGFeRDTradeDeliveryTermCodes>): string;
  end;

implementation

{ TZUGFeRDTradeDeliveryTermCodesExtensions }

class function TZUGFeRDTradeDeliveryTermCodesExtensions.EnumToString(
  t: ZUGFeRDNullable<TZUGFeRDTradeDeliveryTermCodes>): string;
begin
  if not t.HasValue then
    Result:= ''
  else begin
    case t.Value of
      _1: Result := '1' ;
      _2: Result := '2';
      else begin
        Result := GetEnumName(TypeInfo(TZUGFeRDTradeDeliveryTermCodes), Ord(t.Value));
      end;
    end;
  end;
end;

class function TZUGFeRDTradeDeliveryTermCodesExtensions.FromString(
  const s: string): ZUGFeRDNullable<TZUGFeRDTradeDeliveryTermCodes>;
var
  enumValue: Integer;
begin
  if s.IsNullOrEmpty(s) then
    result := nil
  else begin
    if s = '1' then
      Result := TZUGFeRDTradeDeliveryTermCodes._1
    else if s = '2' then
      Result :=  TZUGFeRDTradeDeliveryTermCodes._2
    else begin
      enumValue := GetEnumValue(TypeInfo(TZUGFeRDTradeDeliveryTermCodes), s);
      if enumValue >= 0 then
        Result := TZUGFeRDTradeDeliveryTermCodes(enumValue)
      else
        Result := nil;
    end;
  end;

end;

end.
