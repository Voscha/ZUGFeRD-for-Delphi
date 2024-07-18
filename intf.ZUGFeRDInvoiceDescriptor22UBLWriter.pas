unit intf.ZUGFeRDInvoiceDescriptor22UBLWriter;

interface

uses
  System.SysUtils,System.Classes,System.StrUtils,Generics.Collections
  ,intf.ZUGFeRDInvoiceDescriptor
  ,intf.ZUGFeRDInvoiceTypes
  ,intf.ZUGFeRDProfileAwareXmlTextWriter
  ,intf.ZUGFeRDInvoiceDescriptorwriter
  ,intf.ZUGFeRDProfile
  ,intf.ZUGFeRDExceptions
  ,intf.ZUGFeRDHelper
  ,intf.ZUGFeRDCurrencyCodes
  ,intf.ZUGFeRDVersion
  ,intf.ZUGFeRDNote
  ,intf.ZUGFeRDContentCodes
  ,intf.ZUGFeRDSubjectCodes
  ,intf.ZUGFeRDContact
  ,intf.ZUGFeRDParty
  ,intf.ZUGFeRDTaxRegistration
  ,intf.ZUGFeRDGlobalIDSchemeIdentifiers
  ,intf.ZUGFeRDCountryCodes
  ,intf.ZUGFeRDTaxRegistrationSchemeID
  ,intf.ZUGFeRDTax
  ,intf.ZUGFeRDTaxTypes
  ,intf.ZUGFeRDTaxCategoryCodes
  ,intf.ZUGFeRDTradeLineItem
  ,intf.ZUGFeRDAdditionalReferencedDocument
  ,intf.ZUGFeRDAdditionalReferencedDocumentTypeCodes
  ,intf.ZUGFeRDReferenceTypeCodes
  ,intf.ZUGFeRDPaymentMeansTypeCodes
  ,intf.ZUGFeRDBankAccount
  ,intf.ZUGFeRDTradeAllowanceCharge
  ,intf.ZUGFeRDPaymentTerms
  ,intf.ZUGFeRDServiceCharge
  ,intf.ZUGFeRDQuantityCodes
  ,intf.ZUGFeRDLegalOrganization
  ,intf.ZUGFeRDPartyTypes
  ,intf.ZUGFeRDElectronicAddress
  ,intf.ZUGFeRDElectronicAddressSchemeIdentifiers
  ,intf.ZUGFeRDTaxExemptionReasonCodes
  ,intf.ZUGFeRDApplicableProductCharacteristic
  ,intf.ZUGFeRDReceivableSpecifiedTradeAccountingAccount
  ,intf.ZUGFeRDAccountingAccountTypeCodes
  ,intf.ZUGFeRDMimeTypeMapper
  ,intf.ZUGFeRDSpecialServiceDescriptionCodes
  ,intf.ZUGFeRDAllowanceOrChargeIdentificationCodes
  ,intf.ZUGFeRDFormats;

type
  TZUGFeRDInvoiceDescriptor22UBLWriter = class(TZUGFeRDInvoiceDescriptorWriter)
  private
    Writer: TZUGFeRDProfileAwareXmlTextWriter;
    Descriptor: TZUGFeRDInvoiceDescriptor;
    procedure _writeOptionalAmount(_writer : TZUGFeRDProfileAwareXmlTextWriter; tagName : string; value : ZUGFeRDNullable<Currency>; numDecimals : Integer = 2; forceCurrency : Boolean = false; profile : TZUGFeRDProfiles = TZUGFERDPROFILES_DEFAULT);
    procedure _writeNotes(_writer : TZUGFeRDProfileAwareXmlTextWriter;notes : TObjectList<TZUGFeRDNote>);
    procedure _writeOptionalParty(_writer: TZUGFeRDProfileAwareXmlTextWriter; partyType : TZUGFeRDPartyTypes; party : TZUGFeRDParty; contact : TZUGFeRDContact = nil; electronicAddress : TZUGFeRDElectronicAddress = nil; taxRegistrations : TObjectList<TZUGFeRDTaxRegistration> = nil);
    function _encodeInvoiceType(type_ : TZUGFeRDInvoiceType) : Integer;
  public
    /// <summary>
    /// Saves the given invoice to the given stream.
    /// Make sure that the stream is open and writeable. Otherwise, an IllegalStreamException will be thron.
    /// </summary>
    /// <param name="_descriptor">The invoice object that should be saved</param>
    /// <param name="_stream">The target stream for saving the invoice</param>
    /// <param name="_format">Format of the target file</param>
    procedure Save(_descriptor: TZUGFeRDInvoiceDescriptor; _stream: TStream;
      _format: TZUGFeRDFormats = TZUGFeRDFormats.UBL); override;
    function Validate(descriptor: TZUGFeRDInvoiceDescriptor; throwExceptions: Boolean = True): Boolean; override;
  end;

implementation

{ TZUGFeRDInvoiceDescriptor22UBLWriter }

procedure TZUGFeRDInvoiceDescriptor22UBLWriter.Save(_descriptor: TZUGFeRDInvoiceDescriptor;
  _stream: TStream; _format: TZUGFeRDFormats);
var
  streamPosition : Int64;
begin
  if (_stream = nil) then
    raise TZUGFeRDIllegalStreamException.Create('Cannot write to stream');

  // write data
  streamPosition := _stream.Position;

  Descriptor := _descriptor;
  Writer := TZUGFeRDProfileAwareXmlTextWriter.Create(_stream,TEncoding.UTF8,Descriptor.Profile);
  try
    Writer.Formatting := TZUGFeRDXmlFomatting.xmlFormatting_Indented;
    Writer.WriteStartDocument;

    if not ((Descriptor.Type_ = TZUGFeRDInvoiceType.Invoice) or (Descriptor.Type_ = TZUGFeRDInvoiceType.CreditNote)) then
      raise TZUGFeRDNotImplementedException.create('Not implemented yet.');

{$REGION 'Kopfbereich'}
      // UBL has different namespace for different types
      if (Descriptor.Type_ = TZUGFeRDInvoiceType.Invoice) then
      begin
        Writer.WriteStartElement('ubl:Invoice');
        Writer.WriteAttributeString('xmlns', 'ubl', '', 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2');
      end
      else if (Descriptor.Type_ = TZUGFeRDInvoiceType.CreditNote) then
      begin
        Writer.WriteStartElement('ubl:CreditNote');
        Writer.WriteAttributeString('xmlns', '', '', 'urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2');
      end;
      Writer.WriteAttributeString('xmlns', 'cac', '', 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2');
      Writer.WriteAttributeString('xmlns', 'cbc', '', 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2');
      Writer.WriteAttributeString('xmlns', 'ext', '', 'urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2');
      Writer.WriteAttributeString('xmlns', 'xs', '', 'http://www.w3.org/2001/XMLSchema');
{$ENDREGION}


  finally
    Writer.Free;
  end;
end;

function TZUGFeRDInvoiceDescriptor22UBLWriter.Validate(descriptor: TZUGFeRDInvoiceDescriptor;
  throwExceptions: Boolean): Boolean;
begin
  raise TZUGFeRDNotImplementedException.Create('Validate not implemented');
end;

function TZUGFeRDInvoiceDescriptor22UBLWriter._encodeInvoiceType(
  type_: TZUGFeRDInvoiceType): Integer;
begin
  if (Integer(type_) > 1000) then
    type_ := TZUGFeRDInvoiceType(Integer(type_)-1000);

  case type_ of
    TZUGFeRDInvoiceType.CorrectionOld: Result := Integer(TZUGFeRDInvoiceType.Correction);
    else Result := Integer(type_);
  end;
end;

procedure TZUGFeRDInvoiceDescriptor22UBLWriter._writeNotes(
  _writer: TZUGFeRDProfileAwareXmlTextWriter; notes: TObjectList<TZUGFeRDNote>);
begin
  if notes.Count = 0 then
    exit;

  for var note : TZUGFeRDNote in notes do
  begin
    _writer.WriteElementString('cbc:Note', note.Content);
  end;
end;

procedure TZUGFeRDInvoiceDescriptor22UBLWriter._writeOptionalAmount(
  _writer: TZUGFeRDProfileAwareXmlTextWriter; tagName: string; value: ZUGFeRDNullable<Currency>;
  numDecimals: Integer; forceCurrency: Boolean; profile: TZUGFeRDProfiles);
begin
  if (value.HasValue) then // && (value.Value != decimal.MinValue))
  begin
    _writer.WriteStartElement(tagName,profile);
    if forceCurrency then
      _writer.WriteAttributeString('currencyID', TZUGFeRDCurrencyCodesExtensions.EnumToString(Descriptor.Currency));
    _writer.WriteValue(_formatDecimal(value.Value, numDecimals));
    _writer.WriteEndElement; // !tagName
  end;
end;

procedure TZUGFeRDInvoiceDescriptor22UBLWriter._writeOptionalParty(
  _writer: TZUGFeRDProfileAwareXmlTextWriter; partyType: TZUGFeRDPartyTypes; party: TZUGFeRDParty;
  contact: TZUGFeRDContact; electronicAddress: TZUGFeRDElectronicAddress;
  taxRegistrations: TObjectList<TZUGFeRDTaxRegistration>);
begin
  // filter according to https://github.com/stephanstapel/ZUGFeRD-csharp/pull/221

  case partyType of
    TZUGFeRDPartyTypes.Unknown: exit;
    TZUGFeRDPartyTypes.SellerTradeParty: ;
    TZUGFeRDPartyTypes.BuyerTradeParty: ;
    else exit;
  end;

  if (party = nil) then
    exit;

  case partyType of
    TZUGFeRDPartyTypes.SellerTradeParty:
      _writer.WriteStartElement('cac:AccountingSupplierParty', [Descriptor.Profile]);
    TZUGFeRDPartyTypes.BuyerTradeParty:
      _writer.WriteStartElement('cac:AccountingCustomerParty', [Descriptor.Profile]);
  end;

  _writer.WriteStartElement('cac:Party', [Descriptor.Profile]);

  if (ElectronicAddress <> nil) then
  begin
    _writer.WriteStartElement('cbc:EndpointID');
    _writer.WriteAttributeString('schemeID',
      TZUGFeRDElectronicAddressSchemeIdentifiersExtensions.EnumToString(
        electronicAddress.ElectronicAddressSchemeID));
    _writer.WriteValue(ElectronicAddress.Address);
    _writer.WriteEndElement();
  end;

  _writer.WriteStartElement('cac:PartyIdentification');
  if (Descriptor.PaymentMeans.SEPAMandateReference.IsEmpty) then
  begin
    _writer.WriteStartElement('cbc:ID');
    _writer.WriteAttributeString('schemeID', 'SEPA');
    _writer.WriteValue(Descriptor.PaymentMeans.SEPACreditorIdentifier);
    _writer.WriteEndElement();//!ID
  end;
  _writer.WriteEndElement();//!PartyIdentification

  _writer.WriteStartElement('cac:PostalAddress');

  _writer.WriteElementString('cbc:StreetName', party.Street);
  _writer.WriteOptionalElementString('cbc:AdditionalStreetName', party.AddressLine3);
  _writer.WriteElementString('cbc:CityName', party.City);
  _writer.WriteElementString('cbc:PostalZone', party.Postcode);

  _writer.WriteStartElement('cac:Country');
  _writer.WriteElementString('cbc:IdentificationCode', TZUGFeRDCountryCodesExtensions.EnumToString(party.Country));
  _writer.WriteEndElement(); //!Country

  _writer.WriteEndElement(); //!PostalTradeAddress

  for var tax in taxRegistrations do
  begin
    _writer.WriteStartElement('cac:PartyTaxScheme');
    _writer.WriteElementString('cbc:CompanyID', tax.No);
    _writer.WriteStartElement('cac:TaxScheme');
    _writer.WriteElementString('cbc:ID', TZUGFeRDTaxRegistrationSchemeIDExtensions.EnumToString(tax.SchemeID));
    _writer.WriteEndElement(); //!TaxScheme
    _writer.WriteEndElement(); //!PartyTaxScheme
  end;

  _writer.WriteStartElement('cac:PartyLegalEntity');

  _writer.WriteElementString('cbc:RegistrationName', party.Name);

  _writer.WriteEndElement(); //!PartyLegalEntity

  if (contact <> nil) then
  begin
    _writer.WriteStartElement('cac:Contact');

    _writer.WriteElementString('cbc:Name', contact.Name);
    _writer.WriteElementString('cbc:Telephone', contact.PhoneNo);
    _writer.WriteElementString('cbc:ElectronicMail', contact.EmailAddress);

    _writer.WriteEndElement();
  end;

  _writer.WriteEndElement(); //!Party

end;

end.
