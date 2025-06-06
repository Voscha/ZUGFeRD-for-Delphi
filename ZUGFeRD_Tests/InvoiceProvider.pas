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

unit InvoiceProvider;

interface

uses System.SysUtils,intf.ZUGFeRDInvoiceDescriptor;

type
  TInvoiceProvider = class
  public
    function CreateInvoice: TZUGFeRDInvoiceDescriptor;
  end;

implementation

uses intf.ZUGFeRDCurrencyCodes, intf.ZUGFeRDSubjectCodes, intf.ZUGFeRDQuantityCodes,
  intf.ZUGFeRDTaxTypes, intf.ZUGFeRDHelper, intf.ZUGFeRDTaxCategoryCodes, intf.ZUGFeRDGlobalID,
  intf.ZUGFeRDGlobalIDSchemeIdentifiers, intf.ZUGFeRDCountryCodes, intf.ZUGFeRDLegalOrganization,
  intf.ZUGFeRDTaxRegistrationSchemeID, intf.ZUGFeRDPaymentMeansTypeCodes, intf.ZUGFeRDPaymentTerms,
  intf.ZUGFeRDElectronicAddressSchemeIdentifiers;

{ TInvoiceProvider }

function TInvoiceProvider.CreateInvoice: TZUGFeRDInvoiceDescriptor;
begin
  var desc:TZUGFeRDInvoiceDescriptor := TZUGFeRDInvoiceDescriptor.CreateInvoice('471102',
    EncodeDate(2018, 03, 05), TZUGFeRDCurrencyCodes.EUR);
  desc.BusinessProcess := 'urn:fdc:peppol.eu:2017:poacc:billing:01:1.0';
	desc.Name := 'WARENRECHNUNG';
  desc.AddNote('Rechnung gemäß Bestellung vom 01.03.2018.');
  desc.AddNote('Lieferant GmbH\r\nLieferantenstraße 20\r\n80333 München\r\nDeutschland\r\nGeschäftsführer: Hans Muster\r\nHandelsregisternummer: H A 123\r\n',
                TZUGFeRDSubjectCodes.REG);

  desc.AddTradeLineItem(
    'Trennblätter A4',
    '',
    TZUGFeRDQuantityCodes.H87,
    nil,
    TZUGFeRDNullableParam<Double>.Create(9.9),
    TZUGFeRDNullableParam<Double>.Create(9.9),
    20.0,
    0,
    TZugFeRDTaxTypes.VAT,
    TZUGFeRDTaxCategoryCodes.S,
    19.0,
    '',
    TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.EAN, '4012345001235'),
    'TB100A4'
  );

  desc.AddTradeLineItem(
    'Joghurt Banane',
    '',
    TZUGFeRDQuantityCodes.H87,
    nil,
    TZUGFeRDNullableParam<Double>.Create(5.5),
    TZUGFeRDNullableParam<Double>.Create(5.5),
    50,
    0,
    TZugFeRDTaxTypes.VAT,
    TZUGFeRDTaxCategoryCodes.S,
    7.0,
    '',
    TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.EAN, '4000050986428'),
    'ARNR2'
   );

  desc.ReferenceOrderNo := '04011000-12345-34';
  desc.SetSeller(
    'Lieferant GmbH', '80333', 'München', 'Lieferantenstraße 20',
    TZUGFeRDCountryCodes.DE, '', TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN, '4000001123452'),
    TZUGFeRDLegalOrganization.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiers.GLN, '4000001123452', 'Lieferant GmbH')
  );
  desc.SetSellerElectronicAddress('DE123456789', TZUGFeRDElectronicAddressSchemeIdentifiers.GermanyVatNumber);
  desc.SetSellerContact('Max Mustermann', 'Muster-Einkauf', 'Max@Mustermann.de', '+49891234567');
  desc.AddSellerTaxRegistration('201/113/40209', TZUGFeRDTaxRegistrationSchemeID.FC);
  desc.AddSellerTaxRegistration('DE123456789', TZUGFeRDTaxRegistrationSchemeID.VA);

  desc.SetBuyer(
    'Kunden AG Mitte', '69876', 'Frankfurt', 'Kundenstraße 15',
    TZUGFeRDCountryCodes.DE, 'GE2020211'
  );
  desc.SetBuyerElectronicAddress('DE2020211', TZUGFeRDElectronicAddressSchemeIdentifiers.GermanyVatNumber);

  desc.ActualDeliveryDate := ZUGFeRDNullableDateTime.Create(EncodeDate(2018, 03, 05));
  desc.SetPaymentMeans(TZUGFeRDPaymentMeansTypeCodes.SEPACreditTransfer, 'Zahlung per SEPA Überweisung.');
  desc.AddCreditorFinancialAccount(
    'DE02120300000000202051',
    'BYLADEM1001',
    '',
    '',
    '',
    'Kunden AG');

  desc.AddApplicableTradeTax(275.0, 7.0, (275.0/100 * 7), TZUGFeRDTaxTypes.VAT,
    TZUGFeRDNullableParam<TZUGFeRDTaxCategoryCodes>.Create(TZUGFeRDTaxCategoryCodes.S));
  desc.AddApplicableTradeTax(198.0, 19.0,(198.0/100 * 19), TZUGFeRDTaxTypes.VAT,
     TZUGFeRDNullableParam<TZUGFeRDTaxCategoryCodes>.Create(TZUGFeRDTaxCategoryCodes.S));

  var PaymentTerms: TZUGFeRDPaymentTerms := TZUGFeRDPaymentTerms.Create;
  PaymentTerms.Description := 'Zahlbar innerhalb 30 Tagen netto bis 04.04.2018, 3% Skonto innerhalb 10 Tagen bis 15.03.2018';
  desc.PaymentTermsList.Add(PaymentTerms);
  desc.SetTotals(
    TZUGFeRDNullableParam<Currency>.create(473.0),
    nil,
    nil,
    TZUGFeRDNullableParam<Currency>.create(473.0),
    TZUGFeRDNullableParam<Currency>.create(56.87),
    TZUGFeRDNullableParam<Currency>.create(529.87),
    nil,
    TZUGFeRDNullableParam<Currency>.create(529.87)
  );

  result := desc;
end;

end.
