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
  , intf.ZUGFeRDDesignatedProductClassification
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
    procedure _writeApplicableProductCharacteristics(_writer : TZUGFeRDProfileAwareXmlTextWriter;
      productCharacteristics: TObjectlist<TZUGFeRDApplicableProductCharacteristic>);
    procedure _writeCommodityClassification(_writer : TZUGFeRDProfileAwareXmlTextWriter;
       designatedProductClassifications: TObjectlist<TZUGFeRDDesignatedProductClassification>);
  private const
    ALL_PROFILES = [TZUGFeRDProfile.Minimum,
                    TZUGFeRDProfile.BasicWL,
                    TZUGFeRDProfile.Basic,
                    TZUGFeRDProfile.Comfort,
                    TZUGFeRDProfile.Extended,
                    TZUGFeRDProfile.XRechnung1,
                    TZUGFeRDProfile.XRechnung];
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

    Writer.WriteElementString('cbc:CustomizationID', 'urn:cen.eu:en16931:2017#compliant#urn:xoev-de:kosit:standard:xrechnung_3.0');
    Writer.WriteElementString('cbc:ProfileID', 'urn:fdc:peppol.eu:2017:poacc:billing:01:1.0');

    Writer.WriteElementString('cbc:ID', Descriptor.InvoiceNo); //Rechnungsnummer
    Writer.WriteElementString('cbc:IssueDate', _formatDate(Descriptor.InvoiceDate, false, true));

    Writer.WriteElementString('cbc:InvoiceTypeCode', Format('%d', [_encodeInvoiceType(Descriptor.Type_)])); //Code für den Rechnungstyp


    _writeNotes(Writer, Descriptor.Notes);

    Writer.WriteElementString('cbc:DocumentCurrencyCode', TZUGFeRDCurrencyCodesExtensions.EnumToString(Descriptor.Currency));

    //   BT-6
    if (Descriptor.TaxCurrency <> TZUGFeRDCurrencyCodes.Unknown) then
      Writer.WriteElementString('cbc:TaxCurrencyCode',
        TZUGFeRDCurrencyCodesExtensions.EnumToString(Descriptor.TaxCurrency));

    Writer.WriteOptionalElementString('cbc:BuyerReference', Descriptor.ReferenceOrderNo);

    // OrderReference
    Writer.WriteStartElement('cac:OrderReference');
    Writer.WriteElementString('cbc:ID', Descriptor.OrderNo);
    Writer.WriteEndElement(); // !OrderReference



    // ContractDocumentReference
    if (Descriptor.ContractReferencedDocument <> nil) then
    begin
      Writer.WriteStartElement('cac:ContractDocumentReference');
      Writer.WriteOptionalElementString('cbc:ID', Descriptor.ContractReferencedDocument.ID);
      Writer.WriteEndElement(); // !ContractDocumentReference
    end;

    if (Descriptor.AdditionalReferencedDocuments.Count > 0) then
    begin
      for var document : TZUGFeRDAdditionalReferencedDocument in Descriptor.AdditionalReferencedDocuments do
      begin
        Writer.WriteStartElement('cac:AdditionalDocumentReference');
        Writer.WriteStartElement('cbc:ID'); // BT-18, BT-22
        Writer.WriteAttributeString('schemeID', TZUGFeRDReferenceTypeCodesExtensions.EnumToString(
          document.ReferenceTypeCode)); // BT-18-1
        Writer.WriteValue(document.ID);
        Writer.WriteEndElement(); // !cbc:ID

        if (document.TypeCode <> TZUGFeRDAdditionalReferencedDocumentTypeCode.Unknown) then
          Writer.WriteElementString('cbc:DocumentTypeCode',
            TZUGFeRDAdditionalReferencedDocumentTypeCodeExtensions.EnumToString(document.TypeCode));

        Writer.WriteOptionalElementString('cbc:DocumentType', document.Name); // BT-123

        Writer.WriteStartElement('cac:Attachment');

        Writer.WriteStartElement('cbc:EmbeddedDocumentBinaryObject'); // BT-125
        Writer.WriteAttributeString('filename', document.Filename);
        Writer.WriteAttributeString('mimeCode', TZUGFeRDMimeTypeMapper.GetMimeType(document.Filename));
        Writer.WriteValue(TZUGFeRDHelper.GetDataAsBase64(document.AttachmentBinaryObject));
        Writer.WriteEndElement(); // !cbc:EmbeddedDocumentBinaryObject

        {*
         // not supported yet
        Writer.WriteStartElement("cac:ExternalReference");
        Writer.WriteStartElement("cbc:URI"); // BT-124
        Writer.WriteValue("");
        Writer.WriteEndElement(); // !cbc:URI
        Writer.WriteEndElement(); // !cac:ExternalReference
        *}

        Writer.WriteEndElement(); // !cac:Attachment
        Writer.WriteEndElement(); // !AdditionalDocumentReference
      end;
    end;


    // ProjectReference
    if (Descriptor.SpecifiedProcuringProject <> nil) then
    begin
      Writer.WriteStartElement('cac:ProjectReference');
      Writer.WriteOptionalElementString('cbc:ID', Descriptor.SpecifiedProcuringProject.ID);
      Writer.WriteEndElement(); // !ProjectReference
    end;

    {$REGION 'SellerTradeParty'}
      //AccountingSupplierParty
      _writeOptionalParty(Writer, TZUGFeRDPartyTypes.SellerTradeParty, Descriptor.Seller,
        Descriptor.SellerContact, Descriptor.SellerElectronicAddress, Descriptor.SellerTaxRegistration);
    {$ENDREGION}

    {$REGION 'BuyerTradeParty'}
      //AccountingCustomerParty
      _writeOptionalParty(Writer, TZUGFeRDPartyTypes.BuyerTradeParty, Descriptor.Buyer,
        Descriptor.BuyerContact, Descriptor.BuyerElectronicAddress, Descriptor.BuyerTaxRegistration);
    {$ENDREGION}

    {$REGION 'PaymentMeans'}
      if ((Descriptor.PaymentMeans <> nil) and
        (Descriptor.PaymentMeans.TypeCode <> TZUGFeRDPaymentMeansTypeCodes.Unknown)) then
      begin
        Writer.WriteStartElement('cac:PaymentMeans', ALL_PROFILES - [TZUGFeRDProfile.Minimum]);
        Writer.WriteElementString('cbc:PaymentMeansCode',
          TZUGFeRDPaymentMeansTypeCodesExtensions.EnumToString(Descriptor.PaymentMeans.TypeCode));
        Writer.WriteOptionalElementString('cbc:PaymentID', Descriptor.PaymentReference);

        if (Descriptor.PaymentMeans.FinancialCard <> nil) then
        begin
          Writer.WriteStartElement('cac:CardAccount', ALL_PROFILES - [TZUGFeRDProfile.Minimum]);
          Writer.WriteElementString('cbc:PrimaryAccountNumberID', Descriptor.PaymentMeans.FinancialCard.Id);
          Writer.WriteElementString('cbc:HolderName', Descriptor.PaymentMeans.FinancialCard.CardholderName);
          Writer.WriteEndElement(); //!CardAccount
        end;

        if (Descriptor.CreditorBankAccounts.Count > 0) then
        begin
          for var account: TZUGFeRDBankAccount in Descriptor.CreditorBankAccounts do
          begin
            // PayeeFinancialAccount
            Writer.WriteStartElement('cac:PayeeFinancialAccount');

            Writer.WriteElementString('cbc:ID', account.IBAN);
            Writer.WriteElementString('cbc:Name', account.Name);

            Writer.WriteStartElement('cac:FinancialInstitutionBranch');
            Writer.WriteElementString('cbc:ID', account.BIC);

            //[UBL - CR - 664] - A UBL invoice should not include the FinancialInstitutionBranch FinancialInstitution
            //Writer.WriteStartElement("cac:FinancialInstitution");
            //Writer.WriteElementString("cbc:Name", account.BankName);

            //Writer.WriteEndElement(); // !FinancialInstitution
            Writer.WriteEndElement(); // !FinancialInstitutionBranch

            Writer.WriteEndElement(); // !PayeeFinancialAccount
          end;
        end;

        if (Descriptor.DebitorBankAccounts.Count > 0) then
        begin
          // PaymentMandate --> PayerFinancialAccount
          for var account: TZUGFeRDBankAccount in Descriptor.DebitorBankAccounts do
          begin
            Writer.WriteStartElement('cac:PaymentMandate');

            Writer.WriteStartElement('cac:PayerFinancialAccount');

            Writer.WriteElementString('cbc:ID', account.IBAN);
            Writer.WriteElementString('cbc:Name', account.Name);

            Writer.WriteStartElement('cac:FinancialInstitutionBranch');
            Writer.WriteElementString('cbc:ID', account.BIC);

            //[UBL - CR - 664] - A UBL invoice should not include the FinancialInstitutionBranch FinancialInstitution
            //Writer.WriteStartElement("cac:FinancialInstitution");
            //Writer.WriteElementString("cbc:Name", account.BankName);

            //Writer.WriteEndElement(); // !FinancialInstitution
            Writer.WriteEndElement(); // !FinancialInstitutionBranch

            Writer.WriteEndElement(); // !PayerFinancialAccount
            Writer.WriteEndElement(); // !PaymentMandate
          end;
        end;

        Writer.WriteEndElement(); //!PaymentMeans
      end;
    {$ENDREGION}

    // PaymentTerms (optional)
    if (Descriptor.PaymentTermsList.Count > 0) then
    begin
      Writer.WriteStartElement('cac:PaymentTerms');
      Writer.WriteOptionalElementString('cbc:Note', Descriptor.PaymentTermsList[0].Description);
      Writer.WriteEndElement();
    end;


    // Tax Total
    Writer.WriteStartElement('cac:TaxTotal');
    _writeOptionalAmount(Writer, 'cbc:TaxAmount', Descriptor.TaxTotalAmount, 2, true);

    for var tax: TZUGFeRDTax in Descriptor.Taxes do
    begin
      Writer.WriteStartElement('cac:TaxSubtotal');
      _writeOptionalAmount(Writer, 'cbc:TaxableAmount', tax.BasisAmount, 2, true);
      _writeOptionalAmount(Writer, 'cbc:TaxAmount', tax.TaxAmount, 2, true);

      Writer.WriteStartElement('cac:TaxCategory');
      Writer.WriteElementString('cbc:ID',
        TZUGFeRDTaxCategoryCodesExtensions.EnumToString(tax.CategoryCode));
      Writer.WriteElementString('cbc:Percent', _formatDecimal(_asNullableParam<Currency>(tax.Percent)));

      Writer.WriteStartElement('cac:TaxScheme');
      Writer.WriteElementString('cbc:ID', TZUGFeRDTaxTypesExtensions.EnumToString(tax.TypeCode));
      Writer.WriteEndElement();// !TaxScheme

      Writer.WriteEndElement();// !TaxCategory
      Writer.WriteEndElement();// !TaxSubtotal
    end;

    Writer.WriteEndElement();// !TaxTotal

    Writer.WriteStartElement('cac:LegalMonetaryTotal');
    _writeOptionalAmount(Writer, 'cbc:LineExtensionAmount', Descriptor.LineTotalAmount, 2, true);
    _writeOptionalAmount(Writer, 'cbc:TaxExclusiveAmount', Descriptor.TaxBasisAmount, 2, true);
    _writeOptionalAmount(Writer, 'cbc:TaxInclusiveAmount', Descriptor.GrandTotalAmount, 2, true);
    _writeOptionalAmount(Writer, 'cbc:ChargeTotalAmount', Descriptor.ChargeTotalAmount, 2, true);
    _writeOptionalAmount(Writer, 'cbc:AllowanceTotalAmount', Descriptor.AllowanceTotalAmount, 2, true);
    //_writeOptionalAmount(Writer, "cbc:TaxAmount", this.Descriptor.TaxTotalAmount, forceCurrency: true);
    _writeOptionalAmount(Writer, 'cbc:PrepaidAmount', Descriptor.TotalPrepaidAmount, 2, true);
    _writeOptionalAmount(Writer, 'cbc:PayableAmount', Descriptor.DuePayableAmount, 2, true);
    //_writeOptionalAmount(Writer, "cbc:PayableAlternativeAmount", this.Descriptor.RoundingAmount, forceCurrency: true);
    Writer.WriteEndElement(); //!LegalMonetaryTotal

    for var tradelineitem: TZUGFeRDTradeLineItem in Descriptor.TradeLineItems do
    begin
      Writer.WriteStartElement('cac:InvoiceLine');
      Writer.WriteElementString('cbc:ID', tradeLineItem.AssociatedDocument.LineID);

      //Writer.WriteElementString("cbc:InvoicedQuantity", tradeLineItem.BilledQuantity.ToString());
      Writer.WriteStartElement('cbc:InvoicedQuantity');
      Writer.WriteAttributeString('unitCode', TZUGFeRDQuantityCodesExtensions.EnumToString(tradeLineItem.UnitCode));
      Writer.WriteValue(_formatDecimal(_asNullableParam<Double>(tradeLineItem.BilledQuantity)));
      Writer.WriteEndElement();


      //Writer.WriteElementString("cbc:LineExtensionAmount", tradeLineItem.LineTotalAmount.ToString());
      Writer.WriteStartElement('cbc:LineExtensionAmount');
      Writer.WriteAttributeString('currencyID',
        TZUGFeRDCurrencyCodesExtensions.EnumToString(Descriptor.Currency));
      Writer.WriteValue(_formatDecimal(tradeLineItem.LineTotalAmount));

      Writer.WriteEndElement();


      Writer.WriteStartElement('cac:Item');

      Writer.WriteElementString('cbc:Description', tradeLineItem.Description);
      Writer.WriteElementString('cbc:Name', tradeLineItem.Name);

      Writer.WriteStartElement('cac:SellersItemIdentification');
      Writer.WriteElementString('cbc:ID', tradeLineItem.SellerAssignedID);
      Writer.WriteEndElement(); //!SellersItemIdentification

      if not string.IsNullOrWhiteSpace(tradeLineItem.BuyerAssignedID) then
      begin
          Writer.WriteStartElement('cac:BuyersItemIdentification');
          Writer.WriteElementString('cbc:ID', tradeLineItem.BuyerAssignedID);
          Writer.WriteEndElement(); //!BuyersItemIdentification
      end;

      _writeApplicableProductCharacteristics(Writer, tradeLineItem.ApplicableProductCharacteristics);
      _writeCommodityClassification(Writer, tradeLineItem.DesignatedProductClassifications);

      //[UBL-SR-48] - Invoice lines shall have one and only one classified tax category.
      Writer.WriteStartElement('cac:ClassifiedTaxCategory');
      Writer.WriteElementString('cbc:ID', TZUGFeRDTaxCategoryCodesExtensions.EnumToString(tradeLineItem.TaxCategoryCode));
      Writer.WriteElementString('cbc:Percent', _formatDecimal(_asNullableParam<Currency>(tradeLineItem.TaxPercent)));

      Writer.WriteStartElement('cac:TaxScheme');
      Writer.WriteElementString('cbc:ID', TZUGFeRDTaxTypesExtensions.EnumToString(tradeLineItem.TaxType));
      Writer.WriteEndElement();// !TaxScheme

      Writer.WriteEndElement();// !ClassifiedTaxCategory

      Writer.WriteEndElement(); //!Item


      Writer.WriteStartElement('cac:Price');

        //Writer.WriteElementString("cbc:BaseQuantity", tradeLineItem.UnitQuantity.ToString());
        //Writer.WriteStartElement("cbc:BaseQuantity");
        //Writer.WriteAttributeString("unitCode", this.Descriptor.Currency.EnumToString());
        //Writer.WriteValue(tradeLineItem.UnitQuantity.ToString());
        //Writer.WriteEndElement();

        //Writer.WriteElementString("cbc:PriceAmount", tradeLineItem.NetUnitPrice.ToString());
        Writer.WriteStartElement('cbc:PriceAmount');
        Writer.WriteAttributeString('currencyID',
          TZUGFeRDCurrencyCodesExtensions.EnumToString(Descriptor.Currency));
        Writer.WriteValue(_formatDecimal(tradeLineItem.NetUnitPrice));
        Writer.WriteEndElement();

        Writer.WriteEndElement(); //!Price

        // TODO Add Tax Information for the tradeline item

        Writer.WriteEndElement(); //!InvoiceLine
    end;


    Writer.WriteEndDocument();
    Writer.Flush();

    _stream.Seek(streamPosition, soFromBeginning);
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

procedure TZUGFeRDInvoiceDescriptor22UBLWriter._writeApplicableProductCharacteristics(
  _writer: TZUGFeRDProfileAwareXmlTextWriter;
  productCharacteristics: TObjectlist<TZUGFeRDApplicableProductCharacteristic>);
begin
  if (productCharacteristics.Count > 0) then
  begin
    for var characteristic: TZUGFeRDApplicableProductCharacteristic in productCharacteristics do
    begin
      _writer.WriteStartElement('cac:AdditionalItemProperty');
      _writer.WriteElementString('cbc:Name', characteristic.Description);
      _writer.WriteElementString('cbc:Value', characteristic.Value);
      _writer.WriteEndElement();
    end;
  end;
end;
// !_writeApplicableProductCharacteristics()

procedure TZUGFeRDInvoiceDescriptor22UBLWriter._writeCommodityClassification(
  _writer: TZUGFeRDProfileAwareXmlTextWriter;
   designatedProductClassifications: TObjectlist<TZUGFeRDDesignatedProductClassification>);
begin
  if ((designatedProductClassifications = nil) or (designatedProductClassifications.Count = 0)) then
    exit;

  _writer.WriteStartElement('cac:CommodityClassification');

  for var classification: TZUGFeRDDesignatedProductClassification in designatedProductClassifications do
  begin
    if not classification.ClassCode.HasValue then
      continue;
    _writer.WriteStartElement('cbc:ItemClassificationCode'); // BT-158
    _writer.WriteValue(classification.ClassCode.Value.ToString, ALL_PROFILES);

    if not String.IsNullOrWhiteSpace(classification.ListID) then
      _writer.WriteAttributeString('listID', classification.ListID); // BT-158-1


    if not String.IsNullOrWhiteSpace(classification.ListVersionID) then
      _writer.WriteAttributeString('listVersionID', classification.ListVersionID); // BT-158-2

    // no name attribute in Peppol Billing!
    _writer.WriteEndElement();
  end;
  _writer.WriteEndElement();
end; // !_WriteCommodityClassification()


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
    _writer.WriteValue(_formatDecimal(value, numDecimals));
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
    TZUGFeRDPartyTypes.ShipFromTradeParty: exit;
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

  if (Descriptor.PaymentMeans.SEPAMandateReference.IsEmpty) then
  begin
    _writer.WriteStartElement('cac:PartyIdentification');
    _writer.WriteStartElement('cbc:ID');
    _writer.WriteAttributeString('schemeID', 'SEPA');
    _writer.WriteValue(Descriptor.PaymentMeans.SEPACreditorIdentifier);
    _writer.WriteEndElement();//!ID

    _writer.WriteEndElement();//!PartyIdentification
  end;

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

  if (party.GlobalID <> nil) then
  begin
    //Party legal registration identifier (BT-30)
    _writer.WriteElementString('cbc:CompanyID', party.GlobalID.ID);
  end;

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
