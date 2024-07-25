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
  intf.ZUGFeRDTaxRegistrationSchemeID, intf.ZUGFeRDPaymentMeansTypeCodes, intf.ZUGFeRDPaymentTerms;

{ TInvoiceProvider }

function TInvoiceProvider.CreateInvoice: TZUGFeRDInvoiceDescriptor;
begin
  var desc:TZUGFeRDInvoiceDescriptor := TZUGFeRDInvoiceDescriptor.CreateInvoice('471102',
    EncodeDate(2018, 03, 05), TZUGFeRDCurrencyCodes.EUR);
	desc.Name := 'WARENRECHNUNG';
  desc.AddNote('Rechnung gemäß Bestellung vom 01.03.2018.');
  desc.AddNote('Lieferant GmbH\r\nLieferantenstraße 20\r\n80333 München\r\nDeutschland\r\nGeschäftsführer: Hans Muster\r\nHandelsregisternummer: H A 123\r\n',
                TZUGFeRDSubjectCodes.REG);

  desc.AddTradeLineItem(
    'Trennblätter A4',
    '',
    TZUGFeRDQuantityCodes.H87,
    nil,
    TZUGFeRDNullableParam<Currency>.Create(9.9),
    TZUGFeRDNullableParam<Currency>.Create(9.9),
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
    TZUGFeRDNullableParam<Currency>.Create(5.5),
    TZUGFeRDNullableParam<Currency>.Create(5.5),
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

  desc.SetSellerContact('Max Mustermann', 'Muster-Einkauf', 'Max@Mustermann.de', '+49891234567');
  desc.AddSellerTaxRegistration('201/113/40209', TZUGFeRDTaxRegistrationSchemeID.FC);
  desc.AddSellerTaxRegistration('DE123456789', TZUGFeRDTaxRegistrationSchemeID.VA);

  desc.SetBuyer(
    'Kunden AG Mitte', '69876', 'Frankfurt', 'Kundenstraße 15',
    TZUGFeRDCountryCodes.DE, 'GE2020211'
  );

  desc.ActualDeliveryDate := ZUGFeRDNullableDateTime.Create(EncodeDate(2018, 03, 05));
  desc.SetPaymentMeans(TZUGFeRDPaymentMeansTypeCodes.SEPACreditTransfer, 'Zahlung per SEPA Überweisung.');
  desc.AddCreditorFinancialAccount(
    'DE02120300000000202051',
    'BYLADEM1001',
    '',
    '',
    '',
    'Kunden AG');
  desc.AddDebitorFinancialAccount(
    'DB02120300000000202051',
    'DBBYLADEM1001',
    '',
    '',
    'KundenDB AG');
  desc.AddApplicableTradeTax(275.0, 7.0, TZUGFeRDTaxTypes.VAT, TZUGFeRDTaxCategoryCodes.S);
  desc.AddApplicableTradeTax(198.0, 19.0,TZUGFeRDTaxTypes.VAT, TZUGFeRDTaxCategoryCodes.S);

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
