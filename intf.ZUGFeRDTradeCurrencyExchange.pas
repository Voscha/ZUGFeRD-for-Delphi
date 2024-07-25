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

unit intf.ZUGFeRDTradeCurrencyExchange;

interface

uses intf.ZUGFeRDCurrencyCodes, intf.ZUGFeRDHelper;

type
	/// <summary>
	/// Specification of the invoice currency, local currency and exchange rate
	/// </summary>
	TTradeCurrencyExchange = class
  private
    FSourceCurrency: TZUGFeRDCurrencyCodes;
    FTargetCurrency: TZUGFeRDCurrencyCodes;
    FConversionRate: Double;
    FConversionRateTimestamp: ZUGFeRDNullable<TDateTime>;
    procedure SetSourceCurrency(const Value: TZUGFerDCurrencyCodes);
    procedure SetTargetCurrency(const Value: TZUGFeRDCurrencyCodes);
    procedure SetConversionRate(const Value: Double);
  public
    constructor Create(_sourceCurrency, _targetCurrency: TZUGFeRDCurrencyCodes; _conversionRate: Double;
      _conversionRateTimestamp: IZUGFeRDNullableParam<TDateTime> = nil);
		/// <summary>
		/// Invoice currency
		/// </summary>
		property SourceCurrency: TZUGFeRDCurrencyCodes read FSourceCurrency write SetSourceCurrency; { get; private set; }
		/// <summary>
		/// Local currency
		/// </summary>
		property TargetCurrency: TZUGFeRDCurrencyCodes read FTargetCurrency write SetTargetCurrency; { get; private set; }
		/// <summary>
		/// Exchange rate
		/// </summary>
		property ConversionRate: Double read FConversionRate write SetConversionRate; { get; private set; }
		/// <summary>
		/// Exchange rate date
		/// </summary>
		property ConversionRateTimestamp: ZUGFeRDNullable<TDateTime> read FConversionRateTimestamp
      write FConversionRateTimestamp; { get; private set; }

  end;


implementation

{ TTradeCurrencyExchange }

constructor TTradeCurrencyExchange.Create(_sourceCurrency, _targetCurrency: TZUGFeRDCurrencyCodes;
  _conversionRate: Double; _conversionRateTimestamp: IZUGFeRDNullableParam<TDateTime>);
begin
  FSourceCurrency := _sourceCurrency;
  FTargetCurrency := _targetCurrency;
  FConversionrate := _conversionRate;
  FConversionRateTimestamp := _conversionRateTimestamp;
end;

procedure TTradeCurrencyExchange.SetConversionRate(const Value: Double);
begin
  FConversionRate := Value;
end;

procedure TTradeCurrencyExchange.SetSourceCurrency(const Value: TZUGFerDCurrencyCodes);
begin
  FSourceCurrency := Value;
end;

procedure TTradeCurrencyExchange.SetTargetCurrency(const Value: TZUGFeRDCurrencyCodes);
begin
  FTargetCurrency := Value;
end;

end.
