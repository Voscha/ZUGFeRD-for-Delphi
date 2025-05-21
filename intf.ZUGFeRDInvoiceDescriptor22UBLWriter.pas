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
  ,intf.ZUGFeRDFormats,
  intf.UBLTaxRegistrationSchemeIDMapper,
  intf.ZUGFeRDDesignatedProductClassificationCodes,
  intf.ZUGFeRDAllowanceReasonCodes,
  intf.ZUGFeRDIncludedReferencedProduct;

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
    procedure _writeTradeLineItem(_writer: TZUGFeRDProfileAwareXmlTextWriter;
      tradeLineItem: TZUGFeRDTradeLineItem; isInvoice: Boolean = true);
    procedure _writeIncludedReferencedProducts(_writer: TZUGFeRDProfileAwareXmlTextWriter;
       includedReferencedProducts: TObjectList<TZUGFeRDIncludedReferencedProduct>);
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

  var isInvoice := true;
  if (Descriptor.Type_ = TZUGFeRDInvoiceType.Invoice) or (Descriptor.Type_ = TZUGFeRDInvoiceType.Correction) then
  begin
    // this is a duplicate, just to make sure: also a Correction is regarded as an Invoice
    isInvoice := true;
  end
  else if (Descriptor.Type_ = TZUGFeRDInvoiceType.CreditNote) then
    isInvoice := false
  else
      raise TZUGFeRDNotImplementedException.Create('Not implemented yet.');


  Writer := TZUGFeRDProfileAwareXmlTextWriter.Create(_stream,TEncoding.UTF8, Descriptor.Profile);
  try
    Writer.Formatting := TZUGFeRDXmlFomatting.xmlFormatting_Indented;
(*
    if (isInvoice) then
      Writer.DocumentElement.DeclareNamespace('ubl', 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2')
    else
        namespaces.Add("ubl", "urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2");
    }
*)

    Writer.WriteStartDocument;

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

    if (isInvoice) then
      Writer.WriteElementString('cbc:InvoiceTypeCode', Format('%d', [_encodeInvoiceType(Descriptor.Type_)])) //Code für den Rechnungstyp
    else
      Writer.WriteElementString('cbc:CreditNoteTypeCode', Format('%d', [_encodeInvoiceType(Descriptor.Type_)])); //Code für den Rechnungstyp

    _writeNotes(Writer, Descriptor.Notes);

    Writer.WriteElementString('cbc:DocumentCurrencyCode', TZUGFeRDCurrencyCodesExtensions.EnumToString(Descriptor.Currency));

    //   BT-6
    if (Descriptor.TaxCurrency.HasValue) then
      Writer.WriteElementString('cbc:TaxCurrencyCode',
        TZUGFeRDCurrencyCodesExtensions.EnumToString(Descriptor.TaxCurrency.Value));

    Writer.WriteOptionalElementString('cbc:BuyerReference', Descriptor.ReferenceOrderNo);

    if (Descriptor.BillingPeriodEnd.HasValue or Descriptor.BillingPeriodEnd.HasValue) then
    begin
        Writer.WriteStartElement('cac:InvoicePeriod');

        if (Descriptor.BillingPeriodStart.HasValue) then
          Writer.WriteElementString('cbc:StartDate', _formatDate(Descriptor.BillingPeriodStart.Value, false, true));
        if (Descriptor.BillingPeriodEnd.HasValue) then
          Writer.WriteElementString('cbc:EndDate', _formatDate(Descriptor.BillingPeriodEnd.Value, false, true));
    end;

    // OrderReference
    if not string.IsNullOrWhiteSpace(Descriptor.OrderNo) then
    begin
      Writer.WriteStartElement('cac:OrderReference');
      Writer.WriteElementString('cbc:ID', Descriptor.OrderNo);
      if assigned(Descriptor.SellerOrderReferencedDocument) then
        Writer.WriteOptionalElementString('cbc:SalesOrderID', Descriptor.SellerOrderReferencedDocument.ID);
      Writer.WriteEndElement(); // !OrderReference
    end;

    // BillingReference
    if (Descriptor.InvoiceReferencedDocuments.Count > 0) then
    begin
      Writer.WriteStartElement('cac:BillingReference');
      for var InvoiceReferencedDocument in Descriptor.InvoiceReferencedDocuments do
      begin
        Writer.WriteStartElement('cac:InvoiceDocumentReference', [TZUGFeRDProfile.Extended,
          TZUGFeRDProfile.XRechnung1, TZUGFeRDProfile.XRechnung]);
        Writer.WriteOptionalElementString('cbc:ID', InvoiceReferencedDocument.ID);
        if (invoiceReferencedDocument.IssueDateTime.HasValue) then
        begin
          Writer.WriteElementString('cbc:IssueDate', _formatDate(invoiceReferencedDocument.IssueDateTime.Value, false, true));
        end;
        Writer.WriteEndElement(); // !ram:InvoiceDocumentReference
        break; // only one reference allowed in UBL
        end;
        Writer.WriteEndElement(); // !cac:BillingReference
    end;

    // DespatchDocumentReference
    if (Descriptor.DespatchAdviceReferencedDocument <> nil) then
    begin
      Writer.WriteStartElement('cac:DespatchDocumentReference');
      Writer.WriteOptionalElementString('cbc:ID', Descriptor.DespatchAdviceReferencedDocument.ID);
      Writer.WriteEndElement(); // !DespatchDocumentReference
    end;

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
        if document.ReferenceTypeCode.HasValue then
          Writer.WriteAttributeString('schemeID', TZUGFeRDReferenceTypeCodesExtensions.EnumToString(
            document.ReferenceTypeCode)); // BT-18-1
        Writer.WriteValue(document.ID);
        Writer.WriteEndElement(); // !cbc:ID

        if (document.TypeCode.HasValue) then
          Writer.WriteElementString('cbc:DocumentTypeCode',
            TZUGFeRDAdditionalReferencedDocumentTypeCodeExtensions.EnumToString(document.TypeCode));
        Writer.WriteOptionalElementString('cbc:DocumentDescription', document.Name); // BT-123

        if (document.AttachmentBinaryObject <> nil) then
        begin
          Writer.WriteStartElement('cac:Attachment');

          Writer.WriteStartElement('cbc:EmbeddedDocumentBinaryObject'); // BT-125
          Writer.WriteAttributeString('filename', document.Filename);
          Writer.WriteAttributeString('mimeCode', TZUGFeRDMimeTypeMapper.GetMimeType(document.Filename));
          Writer.WriteValue(TZUGFeRDHelper.GetDataAsBase64(document.AttachmentBinaryObject));
          Writer.WriteEndElement(); // !cbc:EmbeddedDocumentBinaryObject
        end;

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

    if Descriptor.SellerTaxRepresentative <> nil then
      _writeOptionalParty(Writer, TZUGFeRDPartyTypes.SellerTaxRepresentativeTradeParty,
        Descriptor.SellerTaxRepresentative);

    // Delivery = ShipToTradeParty
    if ((Descriptor.ShipTo <> nil) or (Descriptor.ActualDeliveryDate.HasValue)) then
    begin
      Writer.WriteStartElement('cac:Delivery');

      if (Descriptor.ActualDeliveryDate.HasValue) then
      begin
        Writer.WriteStartElement('cbc:ActualDeliveryDate');
        Writer.WriteValue(_formatDate(Descriptor.ActualDeliveryDate.Value, false, true));
        Writer.WriteEndElement(); // !ActualDeliveryDate
      end;

      if (Descriptor.ShipTo <> nil) then
      begin
        Writer.WriteStartElement('cac:DeliveryLocation');

        if (Descriptor.ShipTo.ID <> nil) then// despite this is a mandatory field, the component should not throw an exception if this is not the case
        begin
          Writer.WriteOptionalElementString('cbc:ID', Descriptor.ShipTo.ID.ID);
        end;
        Writer.WriteStartElement('cac:Address');
        Writer.WriteOptionalElementString('cbc:StreetName', Descriptor.ShipTo.Street);
        Writer.WriteOptionalElementString('cbc:AdditionalStreetName', Descriptor.ShipTo.AddressLine3);
        Writer.WriteOptionalElementString('cbc:CityName', Descriptor.ShipTo.City);
        Writer.WriteOptionalElementString('cbc:PostalZone', Descriptor.ShipTo.Postcode);
        Writer.WriteOptionalElementString('cbc:CountrySubentity', Descriptor.ShipTo.CountrySubdivisionName);
        Writer.WriteStartElement('cac:Country');
        if (Descriptor.ShipTo.Country <> TZUGFeRDCountryCodes.Unknown) then
          Writer.WriteElementString('cbc:IdentificationCode', TZUGFeRDCountryCodesExtensions.EnumToString(
            Descriptor.ShipTo.Country));
        Writer.WriteEndElement(); // !Country
        Writer.WriteEndElement(); // !Address
        Writer.WriteEndElement(); // !DeliveryLocation

        if (not string.IsNullOrWhiteSpace(Descriptor.ShipTo.Name)) then
        begin
          Writer.WriteStartElement('cac:DeliveryParty');
          Writer.WriteStartElement('cac:PartyName');
          Writer.WriteStartElement('cbc:Name');
          Writer.WriteValue(Descriptor.ShipTo.Name);
          Writer.WriteEndElement(); // !Name
          Writer.WriteEndElement(); // !PartyName
          Writer.WriteEndElement(); // !DeliveryParty
        end;
      end;

      Writer.WriteEndElement(); // !Delivery
    end;

    // PaymentMeans
    if (not Descriptor.AnyCreditorFinancialAccount and not Descriptor.AnyDebitorFinancialAccount) then
    begin
      if (Descriptor.PaymentMeans <> nil) then
      begin

        if ((Descriptor.PaymentMeans <> nil) and (Descriptor.PaymentMeans.TypeCode <> TZUGFeRDPaymentMeansTypeCodes.Unknown)) then
        begin
          Writer.WriteStartElement('cac:PaymentMeans', [TZUGFeRDProfile.BasicWL, TZUGFeRDProfile.Basic,
            TZUGFeRDProfile.Comfort, TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung1, TZUGFeRDProfile.XRechnung]);
          Writer.WriteElementString('cbc:PaymentMeansCode', TZUGFeRDPaymentMeansTypeCodesExtensions.EnumToString(
            Descriptor.PaymentMeans.TypeCode));
          Writer.WriteOptionalElementString('cbc:PaymentID', Descriptor.PaymentReference);

          if (Descriptor.PaymentMeans.FinancialCard <> nil) then
          begin
            Writer.WriteStartElement('cac:CardAccount', ALL_PROFILES - [TZUGFeRDProfile.Minimum]);
            Writer.WriteElementString('cbc:PrimaryAccountNumberID', Descriptor.PaymentMeans.FinancialCard.Id);
            Writer.WriteOptionalElementString('cbc:HolderName', Descriptor.PaymentMeans.FinancialCard.CardholderName);
            Writer.WriteEndElement(); //!CardAccount
          end;
          Writer.WriteEndElement(); // !PaymentMeans
        end;
      end;
    end
    else
    begin
        for var account in Descriptor.CreditorBankAccounts do
        begin
            Writer.WriteStartElement('cac:PaymentMeans', ALL_PROFILES - [TZUGFeRDProfile.Minimum]);

            if ((Descriptor.PaymentMeans <> nil) and (Descriptor.PaymentMeans.TypeCode <> TZUGFeRDPaymentMeansTypeCodes.Unknown)) then
            begin
                Writer.WriteElementString('cbc:PaymentMeansCode', TZUGFeRDPaymentMeansTypeCodesExtensions.EnumToString(
                  Descriptor.PaymentMeans.TypeCode));
                Writer.WriteOptionalElementString('cbc:PaymentID', Descriptor.PaymentReference);

                if (Descriptor.PaymentMeans.FinancialCard <> nil) then
                begin
                    Writer.WriteStartElement('cac:CardAccount', ALL_PROFILES - [TZUGFeRDProfile.Minimum]);
                    Writer.WriteElementString('cbc:PrimaryAccountNumberID', Descriptor.PaymentMeans.FinancialCard.Id);
                    Writer.WriteOptionalElementString('cbc:HolderName', Descriptor.PaymentMeans.FinancialCard.CardholderName);
                    Writer.WriteEndElement(); //!CardAccount
                end;
            end;

            // PayeeFinancialAccount
            Writer.WriteStartElement('cac:PayeeFinancialAccount');
            Writer.WriteElementString('cbc:ID', account.IBAN);
            Writer.WriteOptionalElementString('cbc:Name', account.Name);

            if (not string.IsNullOrWhiteSpace(account.BIC)) then
            begin
                Writer.WriteStartElement('cac:FinancialInstitutionBranch');
                Writer.WriteElementString('cbc:ID', account.BIC);

                //[UBL - CR - 664] - A UBL invoice should not include the FinancialInstitutionBranch FinancialInstitution
                //Writer.WriteStartElement("cac", "FinancialInstitution");
                //Writer.WriteElementString("cbc", "Name", account.BankName);

                //Writer.WriteEndElement(); // !FinancialInstitution
                Writer.WriteEndElement(); // !FinancialInstitutionBranch
            end;

            Writer.WriteEndElement(); // !PayeeFinancialAccount

            Writer.WriteEndElement(); // !PaymentMeans
        end;

        //[BR - 67] - An Invoice shall contain maximum one Payment Mandate(BG - 19).
        For var account in Descriptor.DebitorBankAccounts do
        begin
            Writer.WriteStartElement('cac:PaymentMeans', ALL_PROFILES - [TZUGFeRDProfile.Minimum]);

            if ((Descriptor.PaymentMeans <> nil) and (Descriptor.PaymentMeans.TypeCode <> TZUGFeRDPaymentMeansTypeCodes.Unknown)) then
            begin
                Writer.WriteElementString('cbc:PaymentMeansCode', TZUGFeRDPaymentMeansTypeCodesExtensions.EnumToString(
                  Descriptor.PaymentMeans.TypeCode));
                Writer.WriteOptionalElementString('cbc:PaymentID', Descriptor.PaymentReference);
            end;

            Writer.WriteStartElement('cac:PaymentMandate');

            //PEPPOL-EN16931-R061: Mandate reference MUST be provided for direct debit.
            Writer.WriteElementString('cbc:ID', Descriptor.PaymentMeans.SEPAMandateReference);

            Writer.WriteStartElement('cac:PayerFinancialAccount');

            Writer.WriteElementString('cbc:ID', account.IBAN);

            //[UBL-CR-440]-A UBL invoice should not include the PaymentMeans PaymentMandate PayerFinancialAccount Name
            //Writer.WriteElementString("cbc", "Name", account.Name);

            //[UBL-CR-446]-A UBL invoice should not include the PaymentMeans PaymentMandate PayerFinancialAccount FinancialInstitutionBranch
            //Writer.WriteStartElement("cac", "FinancialInstitutionBranch");
            //Writer.WriteElementString("cbc", "ID", account.BIC);

            //[UBL - CR - 664] - A UBL invoice should not include the FinancialInstitutionBranch FinancialInstitution
            //Writer.WriteStartElement("cac", "FinancialInstitution");
            //Writer.WriteElementString("cbc", "Name", account.BankName);

            //Writer.WriteEndElement(); // !FinancialInstitution
            //Writer.WriteEndElement(); // !FinancialInstitutionBranch

            Writer.WriteEndElement(); // !PayerFinancialAccount
            Writer.WriteEndElement(); // !PaymentMandate

            Writer.WriteEndElement(); // !PaymentMeans
        end;
    end;

    // PaymentTerms (optional)
    var List := TZUGFeRDHelper.Where<TZUGFeRDPaymentTerms>(Descriptor.PaymentTermsList,
      function(Item: TZUGFeRDPaymentTerms): Boolean
      begin
        result := not String.IsNullOrEmpty(Item.description);
      end);
    try
      if List.Count > 0  then
      begin
        Writer.WriteStartElement('cac:PaymentTerms');
        if TZUGFeRDHelper.Any<TZUGFeRDPaymentTerms>(Descriptor.PaymentTermsList,
                  function(Item: TZUGFeRDPaymentTerms): Boolean
                  begin
                    result := not String.IsNullOrEmpty(Item.description);
                  end) then
        begin
          Writer.WriteStartElement('cbc:Note');
          var sbPaymentNotes := TStringBuilder.Create();
          try
            sbPaymentNotes.AppendLine;
            for var paymentTerms in List do
            begin
              sbPaymentNotes.Append(Writer.RawIdentation);
              sbPaymentNotes.AppendLine(paymentTerms.Description);
            end;
//            sbPaymentNotes.AppendLine;
            Writer.WriteRawString(sbPaymentNotes.ToString);
          finally
            sbPaymentNotes.Free;
          end;
          Writer.WriteEndElement();
        end;
        Writer.WriteEndElement(); // !PaymentTerms
      end;
    finally
      List.Free;
    end;

    {$REGION 'AllowanceCharge'}
    for var tradeAllowanceCharge: TZUGFeRDTradeAllowanceCharge in Descriptor.TradeAllowanceCharges do
    begin
      Writer.WriteStartElement('cac:AllowanceCharge');

      Writer.WriteElementString('cbc:ChargeIndicator', IfThen(tradeAllowanceCharge.ChargeIndicator, 'true', 'false'));

      if (tradeAllowanceCharge.ReasonCode <> TZUGFeRDAllowanceReasonCodes.Unknown) then
      begin
        Writer.WriteStartElement('cbc:AllowanceChargeReasonCode'); // BT-97 / BT-104
        Writer.WriteValue(TZUGFeRDAllowanceReasonCodesExtensions.EnumToString(
          tradeAllowanceCharge.ReasonCode));
        Writer.WriteEndElement();
      end;

      if (not string.IsNullOrWhiteSpace(tradeAllowanceCharge.Reason)) then
      begin
        Writer.WriteStartElement('cbc:AllowanceChargeReason'); // BT-97 / BT-104
        Writer.WriteValue(tradeAllowanceCharge.Reason);
        Writer.WriteEndElement();
      end;

      if tradeAllowanceCharge.ChargePercentage.HasValue and (tradeAllowanceCharge.BasisAmount <> nil) then
      begin
        Writer.WriteStartElement('cbc:MultiplierFactorNumeric');
        Writer.WriteValue(_formatDecimal(tradeAllowanceCharge.ChargePercentage, 2));
        Writer.WriteEndElement();
      end;

      Writer.WriteStartElement('cbc:Amount'); // BT-92 / BT-99
      Writer.WriteAttributeString('currencyID', TZUGFeRDCurrencyCodesExtensions.EnumToString(Descriptor.Currency));
      Writer.WriteValue(_formatDecimal(TZUGFerDNullableParam<currency>.Create(tradeAllowanceCharge.ActualAmount)));
      Writer.WriteEndElement();

      if (tradeAllowanceCharge.BasisAmount <> nil) then
      begin
        Writer.WriteStartElement('cbc:BaseAmount'); // BT-93 / BT-100
        Writer.WriteAttributeString('currencyID', TZUGFeRDCurrencyCodesExtensions.EnumToString(Descriptor.Currency));
        Writer.WriteValue(_formatDecimal(tradeAllowanceCharge.BasisAmount));
        Writer.WriteEndElement();
      end;

      Writer.WriteStartElement('cac:TaxCategory');
      Writer.WriteElementString('cbc:ID', TZUGFeRDTaxCategoryCodesExtensions.EnumToString(
        tradeAllowanceCharge.Tax.CategoryCode));
      if (tradeAllowanceCharge.Tax.Percent <> 0) then
      begin
        Writer.WriteElementString('cbc:Percent', _formatDecimal(TZUGFerDNullableParam<currency>.Create(
          tradeAllowanceCharge.Tax.Percent)));
      end;
      Writer.WriteStartElement('cac:TaxScheme');
      Writer.WriteElementString('cbc:ID', TZUGFeRDTaxTypesExtensions.EnumToString(
        tradeAllowanceCharge.Tax.TypeCode));
      Writer.WriteEndElement(); // cac:TaxScheme
      Writer.WriteEndElement(); // cac:TaxCategory

      Writer.WriteEndElement(); // !AllowanceCharge()
    end;
    {$ENDREGION}

    if Descriptor.AnyApplicableTradeTaxes and (Descriptor.TaxTotalAmount <> nil) then
    begin
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

        if (tax.ExemptionReasonCode.HasValue) then
          Writer.WriteElementString('cbc:TaxExemptionReasonCode',
            TZUGFeRDTaxExemptionReasonCodesExtensions.EnumToString(tax.ExemptionReasonCode));
        Writer.WriteOptionalElementString('cbc:TaxExemptionReason', tax.ExemptionReason);
        Writer.WriteStartElement('cac:TaxScheme');
        Writer.WriteElementString('cbc:ID', TZUGFeRDTaxTypesExtensions.EnumToString(tax.TypeCode));
        Writer.WriteEndElement();// !TaxScheme

        Writer.WriteEndElement();// !TaxCategory
        Writer.WriteEndElement();// !TaxSubtotal
      end;

      Writer.WriteEndElement();// !TaxTotal
    end;

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
      if (String.IsNullOrEmpty(tradeLineItem.AssociatedDocument.ParentLineID)) then
        _writeTradeLineItem(Writer, tradeLineItem, isInvoice);
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
    if classification.ListID = TZUGFeRDDesignatedProductClassificationCodes.Unknown then
      continue;

    writer.WriteStartElement('cbc:ItemClassificationCode'); // BT-158
    Writer.WriteAttributeString('listID', TZUGFeRDDesignatedProductClassificationCodesExtensions.EnumToString(
      classification.ListID)); // BT-158-1

    if (not String.IsNullOrWhiteSpace(classification.ListVersionID)) then
      Writer.WriteAttributeString('listVersionID', classification.ListVersionID); // BT-158-2

    // no name attribute in Peppol Billing!
    writer.WriteValue(classification.ClassCode, ALL_PROFILES);
    writer.WriteEndElement();
  end;

  _writer.WriteEndElement();
end; // !_WriteCommodityClassification()

procedure TZUGFeRDInvoiceDescriptor22UBLWriter._writeIncludedReferencedProducts(
  _writer: TZUGFeRDProfileAwareXmlTextWriter;
  includedReferencedProducts: TObjectList<TZUGFeRDIncludedReferencedProduct>);
begin
  if (includedReferencedProducts.Count > 0) then
  begin
    for var item in includedReferencedProducts do
    begin
       //TODO:
    end;
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
    TZUGFeRDPartyTypes.SellerTaxRepresentativeTradeParty: ;
    TZUGFeRDPartyTypes.ShipFromTradeParty: exit;
    TZUGFeRDPartyTypes.ShipToTradeParty: exit;
    else exit;
  end;

  if (party = nil) then
    exit;

  case partyType of
    TZUGFeRDPartyTypes.SellerTradeParty:
      _writer.WriteStartElement('cac:AccountingSupplierParty', [Descriptor.Profile]);
    TZUGFeRDPartyTypes.BuyerTradeParty:
      _writer.WriteStartElement('cac:AccountingCustomerParty', [Descriptor.Profile]);
    TZUGFeRDPartyTypes.SellerTaxRepresentativeTradeParty:
      _writer.WriteStartElement('cac:TaxRepresentativeParty', [Descriptor.Profile]);
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

  if (partyType = TZUGFeRDPartyTypes.SellerTradeParty) then
  begin
      // This is the identification of the seller, not the buyer
      if (not string.IsNullOrWhiteSpace(Descriptor.PaymentMeans.SEPACreditorIdentifier)) then
      begin
        _writer.WriteStartElement('cac:PartyIdentification');
        _writer.WriteStartElement('cbc:ID');
        _writer.WriteAttributeString('schemeID', 'SEPA');
        _writer.WriteValue(Descriptor.PaymentMeans.SEPACreditorIdentifier);
        _writer.WriteEndElement();//!ID

        _writer.WriteEndElement();//!PartyIdentification
      end;
  end
  else if (partyType = TZUGFeRDPartyTypes.BuyerTradeParty) then
  begin
    if ((party.GlobalID <> nil) and (not String.IsNullOrWhiteSpace(party.GlobalID.ID))) then
    begin
      _writer.WriteStartElement('cac:PartyIdentification');
      _writer.WriteStartElement('cbc:ID');

      if (party.GlobalID.SchemeID.HasValue) then
        _writer.WriteAttributeString('schemeID', TZUGFeRDGlobalIDSchemeIdentifiersExtensions.EnumToString(
          party.GlobalID.SchemeID.Value));
      _writer.WriteValue(party.GlobalID.ID);
      _writer.WriteEndElement();//!ID
      _writer.WriteEndElement();//!PartyIdentification
    end
    else if ((party.ID <> nil) and (not String.IsNullOrWhiteSpace(party.ID.ID))) then
    begin
      _writer.WriteStartElement('cac:PartyIdentification');
      _writer.WriteStartElement('cbc:ID');
      _writer.WriteValue(party.ID.ID);
      _writer.WriteEndElement();//!ID
      _writer.WriteEndElement();//!PartyIdentification
    end;
  end;

  if not string.IsNullOrWhiteSpace(party.Name) then
  begin
    _writer.WriteStartElement('cac:PartyName');
    _writer.WriteStartElement('cbc:Name');
    _writer.WriteValue(party.Name);
    _writer.WriteEndElement();//!Name
    _writer.WriteEndElement();//!PartyName
  end;

  _writer.WriteStartElement('cac:PostalAddress');

  _writer.WriteElementString('cbc:StreetName', party.Street);
  _writer.WriteOptionalElementString('cbc:AdditionalStreetName', party.AddressLine3);
  _writer.WriteElementString('cbc:CityName', party.City);
  _writer.WriteElementString('cbc:PostalZone', party.Postcode);
  _writer.WriteOptionalElementString('cbc:CountrySubentity', party.CountrySubdivisionName);

  _writer.WriteStartElement('cac:Country');
  if (party.Country <> TZUGFeRDCountryCodes.Unknown) then
    _writer.WriteElementString('cbc:IdentificationCode', TZUGFeRDCountryCodesExtensions.EnumToString(party.Country));

  _writer.WriteEndElement(); //!Country

  _writer.WriteEndElement(); //!PostalTradeAddress

  for var tax in taxRegistrations do
  begin
    _writer.WriteStartElement('cac:PartyTaxScheme');
    _writer.WriteElementString('cbc:CompanyID', tax.No);
    _writer.WriteStartElement('cac:TaxScheme');
    _writer.WriteElementString('cbc:ID', TUBLTaxRegistrationSchemeIDMapper.Map(tax.SchemeID));
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

  if not party.Description.isEmpty then
  begin
    //Party additional legal information (BT-33)
    _writer.WriteElementString('cbc:CompanyLegalForm', party.Description);
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
  _writer.WriteEndElement(); //PartyType ????VS
end;

procedure TZUGFeRDInvoiceDescriptor22UBLWriter._writeTradeLineItem(
  _writer: TZUGFeRDProfileAwareXmlTextWriter; tradeLineItem: TZUGFeRDTradeLineItem;
  isInvoice: Boolean);
begin
  if (String.IsNullOrWhiteSpace(tradeLineItem.AssociatedDocument.ParentLineID)) then
  begin
    if (isInvoice) then
      _writer.WriteStartElement('cac:InvoiceLine')
    else
      _writer.WriteStartElement('cac:CreditNoteLine');
  end
  else
  begin
    if (isInvoice) then
      _writer.WriteStartElement('cac:SubInvoiceLine')
    else
      _writer.WriteStartElement('cac:SubCreditNoteLine');
  end;
  _writer.WriteElementString('cbc:ID', tradeLineItem.AssociatedDocument.LineID);

  if (isInvoice) then
    _writer.WriteStartElement('cbc:InvoicedQuantity')
  else
    _writer.WriteStartElement('cbc:CreditedQuantity');

  _writer.WriteAttributeString('unitCode', TZUGFeRDQuantityCodesExtensions.EnumToString(tradeLineItem.UnitCode));
  _writer.WriteValue(_formatDecimal(_asNullableParam<Double>(tradeLineItem.BilledQuantity)));
  _writer.WriteEndElement(); // !InvoicedQuantity || CreditedQuantity

  _writer.WriteStartElement('cbc:LineExtensionAmount');
  _writer.WriteAttributeString('currencyID', TZUGFeRDCurrencyCodesExtensions.EnumToString(Descriptor.Currency));
  _writer.WriteValue(_formatDecimal(tradeLineItem.LineTotalAmount));
  _writer.WriteEndElement(); // !LineExtensionAmount

  if (tradeLineItem.AdditionalReferencedDocuments.Count > 0) then
  begin
    for var document in tradeLineItem.AdditionalReferencedDocuments do
    begin
      _writer.WriteStartElement('cac:DocumentReference');
      _writer.WriteStartElement('cbc:ID'); // BT-18, BT-22

      if (document.ReferenceTypeCode.HasValue) then
        _writer.WriteAttributeString('schemeID',
          TZUGFeRDReferenceTypeCodesExtensions.EnumToString(document.ReferenceTypeCode)); // BT-18-1

      _writer.WriteValue(document.ID);
      _writer.WriteEndElement(); // !cbc:ID
      if (document.TypeCode.HasValue) then
      _writer.WriteElementString('cbc:DocumentTypeCode',
        TZUGFeRDAdditionalReferencedDocumentTypeCodeExtensions.EnumToString(document.TypeCode));
      _writer.WriteOptionalElementString('cbc:DocumentDescription', document.Name); // BT-123

      _writer.WriteEndElement(); // !DocumentReference
    end;
  end;

  _writer.WriteStartElement('cac:Item');

  _writer.WriteOptionalElementString('cbc:Description', tradeLineItem.Description);
  _writer.WriteElementString('cbc:Name', tradeLineItem.Name);

  if (not string.IsNullOrWhiteSpace(tradeLineItem.BuyerAssignedID)) then
  begin
    _writer.WriteStartElement('cac:BuyersItemIdentification');
    _writer.WriteElementString('cbc:ID', tradeLineItem.BuyerAssignedID);
    _writer.WriteEndElement(); //!BuyersItemIdentification
  end;

  if (not string.IsNullOrWhiteSpace(tradeLineItem.SellerAssignedID)) then
  begin
    _writer.WriteStartElement('cac:SellersItemIdentification');
    _writer.WriteElementString('cbc:ID', tradeLineItem.SellerAssignedID);
    _writer.WriteEndElement(); //!SellersItemIdentification
  end;

  _writeIncludedReferencedProducts(_writer, tradeLineItem.IncludedReferencedProducts);
  _WriteCommodityClassification(_writer, tradeLineItem.DesignatedProductClassifications);

  //[UBL-SR-48] - Invoice lines shall have one and only one classified tax category.
  _writer.WriteStartElement('cac:ClassifiedTaxCategory');
  _writer.WriteElementString('cbc:ID', TZUGFeRDTaxCategoryCodesExtensions.EnumToString(tradeLineItem.TaxCategoryCode));
  _writer.WriteElementString('cbc:Percent', _formatDecimal(_asNullableParam<Double>(tradeLineItem.TaxPercent)));

  _writer.WriteStartElement('cac:TaxScheme');
  _writer.WriteElementString('cbc:ID', TZUGFeRDTaxTypesExtensions.EnumToString(tradeLineItem.TaxType));
  _writer.WriteEndElement();// !TaxScheme

  _writer.WriteEndElement();// !ClassifiedTaxCategory

  _writeApplicableProductCharacteristics(Writer, tradeLineItem.ApplicableProductCharacteristics);

  _writer.WriteEndElement(); //!Item

  _writer.WriteStartElement('cac:Price');  // BG-29

  _writer.WriteStartElement('cbc:PriceAmount');
  _writer.WriteAttributeString('currencyID', TZUGFeRDCurrencyCodesExtensions.EnumToString(Descriptor.Currency));
  // UBL-DT-01 explicitly excempts the price amount from the 2 decimal rule for amount elements,
  // thus allowing for 4 decimal places (needed for e.g. fuel prices)
  _writer.WriteValue(_formatDecimal(tradeLineItem.NetUnitPrice, 4));
  _writer.WriteEndElement();

  if (tradeLineItem.UnitQuantity.HasValue) then
  begin
    _writer.WriteStartElement('cbc:BaseQuantity'); // BT-149
    _writer.WriteAttributeString('unitCode', TZUGFeRDQuantityCodesExtensions.EnumToString(tradeLineItem.UnitCode)); // BT-150
    _writer.WriteValue(_formatDecimal(tradeLineItem.UnitQuantity));
    _writer.WriteEndElement();
  end;

  var charges := tradeLineItem.TradeAllowanceCharges;
  if (charges.Count > 0) then// only one charge possible in UBL
  begin
    _writer.WriteStartElement('cac:AllowanceCharge');

    _writer.WriteElementString('cbc:ChargeIndicator', IfThen(charges[0].ChargeIndicator, 'true', 'false'));

    _writer.WriteStartElement('cbc:Amount'); // BT-147
    _writer.WriteAttributeString('currencyID', TZUGFeRDCurrencyCodesExtensions.EnumToString(
      Descriptor.Currency));
    _writer.WriteValue(_formatDecimal(_asNullableParam<Currency>(charges[0].ActualAmount)));
    _writer.WriteEndElement();

    if (charges[0].BasisAmount <> nil) then// BT-148 is optional
    begin
      _writer.WriteStartElement('cbc:BaseAmount'); // BT-148
      _writer.WriteAttributeString('currencyID', TZUGFeRDCurrencyCodesExtensions.EnumToString(
        Descriptor.Currency));
      _writer.WriteValue(_formatDecimal(charges[0].BasisAmount));
      _writer.WriteEndElement();
    end;

    _writer.WriteEndElement(); // !AllowanceCharge()
  end;

  _writer.WriteEndElement(); //!Price

  // TODO Add Tax Information for the tradeline item

  //Write sub invoice lines recursively
  var List := TZUGFeRDHelper.Where<TZUGFeRDTradeLineItem>(Descriptor.TradeLineItems,
    function(Item: TZUGFerdTradeLineItem): Boolean
    begin
      result := Item.AssociatedDocument.ParentLineID = tradeLineItem.AssociatedDocument.LineID;
    end);
  try
    for var subTradeLineItem in List do
      _WriteTradeLineItem(_writer, subTradeLineItem, isInvoice);
  finally
    List.Free;
  end;

  _writer.WriteEndElement(); //!InvoiceLine
end;

end.
