{ * Licensed to the Apache Software Foundation (ASF) under one
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
  * under the License. }

unit intf.ZUGFeRDInvoiceDescriptor23CIIWriter;

interface

uses
  System.SysUtils, System.Classes, System.StrUtils, Generics.Collections,
  intf.ZUGFeRDInvoiceDescriptor, intf.ZUGFeRDInvoiceTypes,
  intf.ZUGFeRDProfileAwareXmlTextWriter, intf.ZUGFeRDInvoiceDescriptorwriter,
  intf.ZUGFeRDProfile, intf.ZUGFeRDExceptions, intf.ZUGFeRDHelper,
  intf.ZUGFeRDCurrencyCodes, intf.ZUGFeRDVersion, intf.ZUGFeRDNote,
  intf.ZUGFeRDContentCodes, intf.ZUGFeRDSubjectCodes, intf.ZUGFeRDContact,
  intf.ZUGFeRDParty, intf.ZUGFeRDTaxRegistration,
  intf.ZUGFeRDGlobalIDSchemeIdentifiers, intf.ZUGFeRDCountryCodes,
  intf.ZUGFeRDTaxRegistrationSchemeID, intf.ZUGFeRDTax, intf.ZUGFeRDTaxTypes,
  intf.ZUGFeRDTaxCategoryCodes, intf.ZUGFeRDTradeLineItem,
  intf.ZUGFeRDAdditionalReferencedDocument,
  intf.ZUGFeRDAdditionalReferencedDocumentTypeCodes,
  intf.ZUGFeRDReferenceTypeCodes, intf.ZUGFeRDPaymentMeansTypeCodes,
  intf.ZUGFeRDBankAccount, intf.ZUGFeRDTradeAllowanceCharge,
  intf.ZUGFeRDPaymentTerms, intf.ZUGFeRDServiceCharge,
  intf.ZUGFeRDQuantityCodes, intf.ZUGFeRDLegalOrganization,
  intf.ZUGFeRDPartyTypes, intf.ZUGFeRDElectronicAddress,
  intf.ZUGFeRDElectronicAddressSchemeIdentifiers,
  intf.ZUGFeRDTaxExemptionReasonCodes,
  intf.ZUGFeRDApplicableProductCharacteristic,
  intf.ZUGFeRDReceivableSpecifiedTradeAccountingAccount,
  intf.ZUGFeRDAccountingAccountTypeCodes, intf.ZUGFeRDMimeTypeMapper,
  intf.ZUGFeRDSpecialServiceDescriptionCodes,
  intf.ZUGFeRDAllowanceOrChargeIdentificationCodes, intf.ZUGFeRDFormats,
  intf.ZUGFeRDDesignatedProductClassificationCodes,
  intf.ZUGFeRDPaymentTermsType,
  intf.ZUGFeRDAllowanceReasonCodes,
  intf.ZUGFeRDTradeDeliveryTermCodes;

type
  TZUGFeRDInvoiceDescriptor23CIIWriter = class(TZUGFeRDInvoiceDescriptorWriter)
  private
    Writer: TZUGFeRDProfileAwareXmlTextWriter;
    Descriptor: TZUGFeRDInvoiceDescriptor;
    procedure _writeOptionalAmount(_writer: TZUGFeRDProfileAwareXmlTextWriter;
      tagName: string; value: ZUGFeRDNullable<Currency>;
      numDecimals: Integer = 2; forceCurrency: Boolean = false;
      profile: TZUGFeRDProfiles = TZUGFERDPROFILES_DEFAULT); overload;
    procedure _writeOptionalAmount(_writer: TZUGFeRDProfileAwareXmlTextWriter;
      tagName: string; value: ZUGFeRDNullable<Double>;
      numDecimals: Integer = 2; forceCurrency: Boolean = false;
      profile: TZUGFeRDProfiles = TZUGFERDPROFILES_DEFAULT); overload;
    procedure _writeNotes(_writer: TZUGFeRDProfileAwareXmlTextWriter;
      notes: TObjectList<TZUGFeRDNote>;
      profile: TZUGFeRDProfiles = [TZUGFeRDProfile.Unknown]);
    procedure _writeOptionalLegalOrganization
      (_writer: TZUGFeRDProfileAwareXmlTextWriter; legalOrganizationTag: String;
      legalOrganization: TZUGFeRDLegalOrganization;
      partyType: TZUGFeRDPartyTypes = TZUGFeRDPartyTypes.Unknown);
    procedure _writeOptionalParty(_writer: TZUGFeRDProfileAwareXmlTextWriter;
      partyType: TZUGFeRDPartyTypes; party: TZUGFeRDParty;
      profile: TZUGFeRDProfiles; contact: TZUGFeRDContact = nil;
      electronicAddress: TZUGFeRDElectronicAddress = nil;
      taxRegistrations: TObjectList<TZUGFeRDTaxRegistration> = nil);
    procedure _writeOptionalContact(_writer: TZUGFeRDProfileAwareXmlTextWriter;
      contactTag: String; contact: TZUGFeRDContact; profile: TZUGFeRDProfiles);
    procedure _writeOptionalTaxes(_writer: TZUGFeRDProfileAwareXmlTextWriter);
    procedure _writeElementWithAttribute
      (_writer: TZUGFeRDProfileAwareXmlTextWriter;
      tagName, attributeName, attributeValue, nodeValue: String;
      profile: TZUGFeRDProfiles = [TZUGFeRDProfile.Unknown]);
    procedure _writeAdditionalReferencedDocument
      (_writer: TZUGFeRDProfileAwareXmlTextWriter;
      document: TZUGFeRDAdditionalReferencedDocument; profile: TZUGFeRDProfiles;
      parentElement: string = '');
    function _translateTaxCategoryCode(taxCategoryCode
      : TZUGFeRDTaxCategoryCodes): String;
//    function _translateInvoiceType(type_: TZUGFeRDInvoiceType): String;
    function _encodeInvoiceType(type_: TZUGFeRDInvoiceType): Integer;
  private const
(*    ALL_PROFILES = [TZUGFeRDProfile.Minimum, TZUGFeRDProfile.BasicWL,
      TZUGFeRDProfile.Basic, TZUGFeRDProfile.Comfort, TZUGFeRDProfile.Extended,
      TZUGFeRDProfile.XRechnung1, TZUGFeRDProfile.XRechnung];
 *)
    PROFILE_COMFORT_EXTENDED_XRECHNUNG = [TZUGFeRDProfile.Comfort,
      TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung1,
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
      _format: TZUGFeRDFormats = TZUGFeRDFormats.CII); override;
    function Validate(Descriptor: TZUGFeRDInvoiceDescriptor;
      throwExceptions: Boolean = True): Boolean; override;
  end;

implementation

uses System.TypInfo, intf.ZUGFeRDDateTypeCodes, Spring.Collections,
  intf.ZUGFeRDLineStatusReasonCodes,
  intf.ZUGFeRDLineStatusCodes, intf.ZUGFeRDTransportmodeCodes, XmlConsts;

{ TZUGFeRDInvoiceDescriptor23CIIWriter }

procedure TZUGFeRDInvoiceDescriptor23CIIWriter.Save
  (_descriptor: TZUGFeRDInvoiceDescriptor; _stream: TStream;
  _format: TZUGFeRDFormats);
var
  streamPosition: Int64;
begin
  if (_stream = nil) then
    raise TZUGFeRDIllegalStreamException.Create('Cannot write to stream');

  // write data
  streamPosition := _stream.Position;

  Descriptor := _descriptor;
  Writer := TZUGFeRDProfileAwareXmlTextWriter.Create(_stream, TEncoding.UTF8,
    Descriptor.profile);

  var
  Namespaces := TCollections.CreateDictionary<string, string>;
  Namespaces.Add('a',
    'urn:un:unece:uncefact:data:standard:QualifiedDataType:100');
  Namespaces.Add('rsm',
    'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100');
  Namespaces.Add('qdt',
    'urn:un:unece:uncefact:data:standard:QualifiedDataType:100');
  Namespaces.Add('ram',
    'urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100');
  Namespaces.Add('xs', 'http://www.w3.org/2001/XMLSchema');
  Namespaces.Add('udt',
    'urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100');

  Writer.SetNamespaces(Namespaces);

  Try
    Writer.Formatting := TZUGFeRDXmlFomatting.xmlFormatting_Indented;
    Writer.WriteStartDocument;

{$REGION 'Kopfbereich'}
    Writer.WriteStartElement('rsm:CrossIndustryInvoice');
    Writer.WriteAttributeString('xmlns', 'a', '',
      'urn:un:unece:uncefact:data:standard:QualifiedDataType:100');
    Writer.WriteAttributeString('xmlns', 'rsm', '',
      'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100');
    Writer.WriteAttributeString('xmlns', 'qdt', '',
      'urn:un:unece:uncefact:data:standard:QualifiedDataType:100');
    Writer.WriteAttributeString('xmlns', 'ram', '',
      'urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100');
    Writer.WriteAttributeString('xmlns', 'xs', '',
      'http://www.w3.org/2001/XMLSchema');
    Writer.WriteAttributeString('xmlns', 'udt', '',
      'urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100');
{$ENDREGION}
{$REGION 'ExchangedDocumentContext'}
    // Prozesssteuerung
    Writer.WriteStartElement('rsm:ExchangedDocumentContext');
    if (Descriptor.IsTest) then
    begin
      Writer.WriteStartElement('ram:TestIndicator');
      Writer.WriteElementString('udt:Indicator', ifthen(Descriptor.IsTest,
        'true', 'false'));
      Writer.WriteEndElement(); // !ram:TestIndicator
    end;

    if not string.IsNullOrWhiteSpace(Descriptor.BusinessProcess) then
    begin
      Writer.WriteStartElement
        ('ram:BusinessProcessSpecifiedDocumentContextParameter',
        [TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung1,
        TZUGFeRDProfile.XRechnung]);
      Writer.WriteElementString('ram:ID', Descriptor.BusinessProcess,
        [TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung1,
        TZUGFeRDProfile.XRechnung]);
      Writer.WriteEndElement();
      // !ram:BusinessProcessSpecifiedDocumentContextParameter
    end;

    Writer.WriteStartElement('ram:GuidelineSpecifiedDocumentContextParameter');
    // Gruppierung der Anwendungsempfehlungsinformationen
    Writer.WriteElementString('ram:ID', TZUGFeRDProfileExtensions.EnumToString
      (Descriptor.profile, TZUGFeRDVersion.Version23));
    Writer.WriteEndElement(); // !ram:GuidelineSpecifiedDocumentContextParameter
    Writer.WriteEndElement(); // !rsm:ExchangedDocumentContext
{$ENDREGION}
{$REGION 'ExchangedDocument'}
    // Gruppierung der Eigenschaften, die das gesamte Dokument betreffen.
    Writer.WriteStartElement('rsm:ExchangedDocument');
    Writer.WriteElementString('ram:ID', Descriptor.InvoiceNo);
    // Rechnungsnummer
    Writer.WriteElementString('ram:Name', Descriptor.Name,
      [TZUGFeRDProfile.Extended]); // Dokumentenart (Freitext)
    Writer.WriteElementString('ram:TypeCode',
      Format('%d', [_encodeInvoiceType(Descriptor.type_)]));
    // Code für den Rechnungstyp
    // ToDo: LanguageID      //Sprachkennzeichen
    if (Descriptor.InvoiceDate.HasValue) then
    begin
      Writer.WriteStartElement('ram:IssueDateTime');
      Writer.WriteStartElement('udt:DateTimeString');
      Writer.WriteAttributeString('format', '102');
      Writer.WriteValue(_formatDate(Descriptor.InvoiceDate));
      Writer.WriteEndElement(); // !udt:DateTimeString
      Writer.WriteEndElement(); // !IssueDateTime
    end;
    _writeNotes(Writer, Descriptor.notes,
      ALL_PROFILES - [TZUGFeRDProfile.Minimum]);
    Writer.WriteEndElement(); // !rsm:ExchangedDocument
{$ENDREGION}
{$REGION 'SpecifiedSupplyChainTradeTransaction'}
    // Gruppierung der Informationen zum Geschäftsvorfall
    Writer.WriteStartElement('rsm:SupplyChainTradeTransaction');

{$REGION 'IncludedSupplyChainTradeLineItem'}
    for var tradeLineItem: TZUGFeRDTradeLineItem in Descriptor.TradeLineItems do
    begin
      Writer.WriteStartElement('ram:IncludedSupplyChainTradeLineItem');

{$REGION 'AssociatedDocumentLineDocument'}
      // Gruppierung von allgemeinen Positionsangaben
      if (tradeLineItem.AssociatedDocument <> nil) then
      begin
        Writer.WriteStartElement('ram:AssociatedDocumentLineDocument',
          [TZUGFeRDProfile.Basic, TZUGFeRDProfile.Comfort,
          TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung1,
          TZUGFeRDProfile.XRechnung]);
        if not string.IsNullOrWhiteSpace(tradeLineItem.AssociatedDocument.LineID)
        then
        begin
          Writer.WriteElementString('ram:LineID',
            tradeLineItem.AssociatedDocument.LineID);
        end;
        // ID der übergeordneten Zeile, BT-X-304, Extended
        // It is necessary that Parent Line Id be written directly under LineId
        if not String.IsNullOrWhiteSpace
          (tradeLineItem.AssociatedDocument.ParentLineID) then
        begin
          Writer.WriteElementString('ram:ParentLineID',
            tradeLineItem.AssociatedDocument.ParentLineID,
            [TZUGFeRDProfile.Extended]);
        end;
        // Typ der Rechnungsposition (Code), BT-X-7, Extended
        if (tradeLineItem.AssociatedDocument.LineStatusCode.HasValue) then
          Writer.WriteElementString('ram:LineStatusCode',
            TZUGFeRDLineStatusCodesExtensions.EnumToString
            (tradeLineItem.AssociatedDocument.LineStatusCode),
            [TZUGFeRDProfile.Extended]);
        // Untertyp der Rechnungsposition, BT-X-8, Extended
        if (tradeLineItem.AssociatedDocument.LineStatusReasonCode.HasValue) then
          Writer.WriteElementString('ram:LineStatusReasonCode',
            TZUGFeRDLineStatusReasonCodesExtensions.EnumToString
            (tradeLineItem.AssociatedDocument.LineStatusReasonCode),
            [TZUGFeRDProfile.Extended]);

        _writeNotes(Writer, tradeLineItem.AssociatedDocument.notes,
          ALL_PROFILES - [TZUGFeRDProfile.Minimum, TZUGFeRDProfile.BasicWL]);
        Writer.WriteEndElement();
        // ram:AssociatedDocumentLineDocument(Basic|Comfort|Extended|XRechnung)
      end;
{$ENDREGION}
      // handelt es sich um einen Kommentar?
      var
        isCommentItem: Boolean := false;
      if tradeLineItem.AssociatedDocument <> nil then
        if ((tradeLineItem.AssociatedDocument.notes.Count > 0) and
          (tradeLineItem.BilledQuantity = 0) and
          (tradeLineItem.Description <> '')) then
        begin
          isCommentItem := True;
        end;

{$REGION 'SpecifiedTradeProduct'}
      // Eine Gruppe von betriebswirtschaftlichen Begriffen, die Informationen über die in Rechnung gestellten Waren und Dienstleistungen enthält
      Writer.WriteStartElement('ram:SpecifiedTradeProduct',
        [TZUGFeRDProfile.Basic, TZUGFeRDProfile.Comfort,
        TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung1,
        TZUGFeRDProfile.XRechnung]);
      if (tradeLineItem.GlobalID <> nil) then
        if (tradeLineItem.GlobalID.SchemeID <>
          TZUGFeRDGlobalIDSchemeIdentifiers.Unknown) and
          (tradeLineItem.GlobalID.ID <> '') then
        begin
          _writeElementWithAttribute(Writer, 'ram:GlobalID', 'schemeID',
            TZUGFeRDGlobalIDSchemeIdentifiersExtensions.EnumToString
            (tradeLineItem.GlobalID.SchemeID), tradeLineItem.GlobalID.ID,
            [TZUGFeRDProfile.Basic, TZUGFeRDProfile.Comfort,
            TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung1,
            TZUGFeRDProfile.XRechnung]);
        end;

      Writer.WriteOptionalElementString('ram:SellerAssignedID',
        tradeLineItem.SellerAssignedID, [TZUGFeRDProfile.Comfort,
        TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung1,
        TZUGFeRDProfile.XRechnung]);
      Writer.WriteOptionalElementString('ram:BuyerAssignedID',
        tradeLineItem.BuyerAssignedID, [TZUGFeRDProfile.Comfort,
        TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung1,
        TZUGFeRDProfile.XRechnung]);

      // BT-153
      Writer.WriteOptionalElementString('ram:Name', tradeLineItem.Name,
        [TZUGFeRDProfile.Basic, TZUGFeRDProfile.Comfort,
        TZUGFeRDProfile.Extended]);
      Writer.WriteOptionalElementString('ram:Name',
        ifthen(isCommentItem, 'TEXT', tradeLineItem.Name),
        [TZUGFeRDProfile.XRechnung1, TZUGFeRDProfile.XRechnung]);
      // XRechnung erfordert einen Item-Namen (BR-25)

      Writer.WriteOptionalElementString('ram:Description',
        tradeLineItem.Description, [TZUGFeRDProfile.Comfort,
        TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung1,
        TZUGFeRDProfile.XRechnung]);

      if (tradeLineItem.ApplicableProductCharacteristics <> nil) then
        if (tradeLineItem.ApplicableProductCharacteristics.Count > 0) then
        begin
          for var productCharacteristic: TZUGFeRDApplicableProductCharacteristic
            in tradeLineItem.ApplicableProductCharacteristics do
          begin
            Writer.WriteStartElement('ram:ApplicableProductCharacteristic');
            Writer.WriteOptionalElementString('ram:Description',
              productCharacteristic.Description);
            Writer.WriteOptionalElementString('ram:Value',
              productCharacteristic.value);
            Writer.WriteEndElement(); // !ram:ApplicableProductCharacteristic
          end
        end;

      if tradeLineItem.DesignatedProductClassifications.Count > 0 then
      begin
        for var designatedProductClassification in tradeLineItem.DesignatedProductClassifications do
        begin
          if (designatedProductClassification.ListID = TZUGFeRDDesignatedProductClassificationCodes.Unknown) then
            continue;

          Writer.WriteStartElement('ram:DesignatedProductClassification', PROFILE_COMFORT_EXTENDED_XRECHNUNG);
          Writer.WriteStartElement('ram:ClassCode');
          Writer.WriteAttributeString('listID', TZUGFeRDDesignatedProductClassificationCodesExtensions.EnumToString(
            designatedProductClassification.ListID));
          Writer.WriteAttributeString('listVersionID', designatedProductClassification.ListVersionID);
          Writer.WriteValue(designatedProductClassification.ClassCode);
          Writer.WriteEndElement(); // !ram::ClassCode
          Writer.WriteOptionalElementString('ram:ClassName', designatedProductClassification.ClassName_);
          Writer.WriteEndElement(); // !ram:DesignatedProductClassification
        end;
      end;

      // TODO: IndividualTradeProductInstance, BG-X-84, Artikel (Handelsprodukt) Instanzen

      // BT-159, Detailinformationen zur Produktherkunft
      if (tradeLineItem.OriginTradeCountry <> nil) then
      begin
        Writer.WriteStartElement('ram:OriginTradeCountry',
          PROFILE_COMFORT_EXTENDED_XRECHNUNG);
        Writer.WriteElementString('ram:ID',
          TZUGFeRDCountryCodesExtensions.EnumToString
          (tradeLineItem.OriginTradeCountry));
        Writer.WriteEndElement(); // !ram:OriginTradeCountry
      end;

      if (Descriptor.profile = TZUGFeRDProfile.Extended) and
        (tradeLineItem.IncludedReferencedProducts <> nil) and
        (tradeLineItem.IncludedReferencedProducts.Count > 0) then
      begin
        for var includedItem in tradeLineItem.IncludedReferencedProducts do
        begin
          Writer.WriteStartElement('ram:IncludedReferencedProduct');
          // TODO: GlobalID, SellerAssignedID, BuyerAssignedID, IndustryAssignedID, Description
          Writer.WriteOptionalElementString('ram:Name', includedItem.Name);
          // BT-X-18
          if (includedItem.UnitQuantity.HasValue) then
            _writeElementWithAttribute(Writer, 'ram:UnitQuantity',
              'unitCode', TZUGFeRDQuantityCodesExtensions.EnumToString
              (includedItem.UnitCode), _formatDecimal(includedItem.UnitQuantity, 4));
          Writer.WriteEndElement(); // !ram:IncludedReferencedProduct
        end;
      end;

      Writer.WriteEndElement();
      // !ram:SpecifiedTradeProduct(Basic|Comfort|Extended|XRechnung)
{$ENDREGION}
{$REGION 'SpecifiedLineTradeAgreement (Basic, Comfort, Extended, XRechnung)'}
      // Eine Gruppe von betriebswirtschaftlichen Begriffen, die Informationen über den Preis für die in der betreffenden Rechnungsposition in Rechnung gestellten Waren und Dienstleistungen enthält
      if (Descriptor.profile in [TZUGFeRDProfile.Basic, TZUGFeRDProfile.Comfort,
        TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung,
        TZUGFeRDProfile.XRechnung1]) then
      begin
        Writer.WriteStartElement('ram:SpecifiedLineTradeAgreement',
          [TZUGFeRDProfile.Basic, TZUGFeRDProfile.Comfort,
          TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung,
          TZUGFeRDProfile.XRechnung1]);

{$REGION 'BuyerOrderReferencedDocument (Comfort, Extended, XRechnung)'}
        // Detailangaben zur zugehörigen Bestellung
        if (tradeLineItem.BuyerOrderReferencedDocument <> nil) then
        begin
          var hasLineID :=
            not string.IsNullOrWhiteSpace(tradeLineItem.BuyerOrderReferencedDocument.LineID);
          var hasIssuerAssignedID := not string.IsNullOrWhiteSpace
            (tradeLineItem.BuyerOrderReferencedDocument.ID);
          var hasIssueDateTime := tradeLineItem.BuyerOrderReferencedDocument.
            IssueDateTime <> nil;

          if (((Descriptor.profile <> TZUGFeRDProfile.Extended) and hasLineID)
            or ((Descriptor.profile = TZUGFeRDProfile.Extended) and
            (hasLineID or hasIssuerAssignedID or hasIssueDateTime))) then
          begin
            Writer.WriteStartElement('ram:BuyerOrderReferencedDocument',
              [TZUGFeRDProfile.Comfort, TZUGFeRDProfile.Extended,
              TZUGFeRDProfile.XRechnung, TZUGFeRDProfile.XRechnung1]);

            // Bestellnummer
            Writer.WriteOptionalElementString('ram:IssuerAssignedID',
              tradeLineItem.BuyerOrderReferencedDocument.ID,
              [TZUGFeRDProfile.Extended]);

            // Referenz zur Bestellposition
            Writer.WriteOptionalElementString('ram:LineID',
              tradeLineItem.BuyerOrderReferencedDocument.LineID);

            if (tradeLineItem.BuyerOrderReferencedDocument.IssueDateTime.
              HasValue) then
            begin
              Writer.WriteStartElement('ram:FormattedIssueDateTime',
                [TZUGFeRDProfile.Extended]);
              Writer.WriteStartElement('qdt:DateTimeString');
              Writer.WriteAttributeString('format', '102');
              Writer.WriteValue
                (_formatDate(tradeLineItem.BuyerOrderReferencedDocument.
                IssueDateTime.value));
              Writer.WriteEndElement(); // !qdt:DateTimeString
              Writer.WriteEndElement(); // !ram:FormattedIssueDateTime
            end;

            Writer.WriteEndElement(); // !ram:BuyerOrderReferencedDocument
          end;
        end;
{$ENDREGION}
{$REGION 'ContractReferencedDocument'}
        // Detailangaben zum zugehörigen Vertrag
        if (tradeLineItem.ContractReferencedDocument <> nil) then
        begin
          Writer.WriteStartElement('ram:ContractReferencedDocument',
            [TZUGFeRDProfile.Extended]);
          // reference to the contract position
          Writer.WriteOptionalElementString('ram:LineID',
            tradeLineItem.ContractReferencedDocument.LineID);

          if (tradeLineItem.ContractReferencedDocument.IssueDateTime.HasValue)
          then
          begin
            Writer.WriteStartElement('ram:FormattedIssueDateTime');
            Writer.WriteStartElement('qdt:DateTimeString');
            Writer.WriteAttributeString('format', '102');
            Writer.WriteValue
              (_formatDate(tradeLineItem.ContractReferencedDocument.
              IssueDateTime.value));
            Writer.WriteEndElement(); // !udt:DateTimeString
            Writer.WriteEndElement(); // !ram:IssueDateTime
          end;
          Writer.WriteOptionalElementString('ram:IssuerAssignedID',
            tradeLineItem.ContractReferencedDocument.ID);
          Writer.WriteEndElement(); // !ram:ContractReferencedDocument(Extended)
        end;
{$ENDREGION}
{$REGION 'AdditionalReferencedDocument (Extended)'}
        // Detailangaben zu einer zusätzlichen Dokumentenreferenz
        for var document: TZUGFeRDAdditionalReferencedDocument
          in tradeLineItem.AdditionalReferencedDocuments do
        begin
          _writeAdditionalReferencedDocument(Writer, document,
            [TZUGFeRDProfile.Extended], 'BG-X-3');
        end; // !foreach(document)
{$ENDREGION}
{$REGION 'GrossPriceProductTradePrice (Comfort, Extended, XRechnung)'}
        var
        needToWriteGrossUnitPrice := false;
        var
        hasGrossUnitPrice := tradeLineItem.GrossUnitPrice.HasValue;
        var
        hasAllowanceCharges := tradeLineItem.TradeAllowanceCharges.Count > 0;

        if (Descriptor.profile in [TZUGFeRDProfile.XRechnung,
          TZUGFeRDProfile.XRechnung1, TZUGFeRDProfile.Comfort]) then
        begin
          // PEPPOL-EN16931-R046: For XRechnung, both must be present
          needToWriteGrossUnitPrice := hasGrossUnitPrice and
            hasAllowanceCharges;
        end
        else
        begin
          // For other profiles, either is sufficient
          needToWriteGrossUnitPrice := hasGrossUnitPrice or hasAllowanceCharges;
        end;

        if (needToWriteGrossUnitPrice) then
        begin
          Writer.WriteStartElement('ram:GrossPriceProductTradePrice',
            PROFILE_COMFORT_EXTENDED_XRECHNUNG);
          _writeOptionalAmount(Writer, 'ram:ChargeAmount',
            tradeLineItem.GrossUnitPrice, 2); // BT-148
          if (tradeLineItem.UnitQuantity.HasValue) then
          begin
            _writeElementWithAttribute(Writer, 'ram:BasisQuantity', 'unitCode',
              TZUGFeRDQuantityCodesExtensions.EnumToString
              (tradeLineItem.UnitCode),
              _formatDecimal(tradeLineItem.UnitQuantity, 4));
          end;

          for var tradeAllowanceCharge: TZUGFeRDTradeAllowanceCharge
            in tradeLineItem.TradeAllowanceCharges do // BT-147
          begin
            Writer.WriteStartElement('ram:AppliedTradeAllowanceCharge');

{$REGION 'ChargeIndicator'}
            Writer.WriteStartElement('ram:ChargeIndicator');
            Writer.WriteElementString('udt:Indicator',
              ifthen(tradeAllowanceCharge.ChargeIndicator, 'true', 'false'));
            Writer.WriteEndElement(); // !ram:ChargeIndicator
{$ENDREGION}
{$REGION 'ChargePercentage'}
            if (tradeAllowanceCharge.ChargePercentage.HasValue) then
            begin
              Writer.WriteStartElement('ram:CalculationPercent',
                [TZUGFeRDProfile.Extended]);
              Writer.WriteValue
                (_formatDecimal(_asNullableParam<Currency>
                (tradeAllowanceCharge.ChargePercentage)));
              Writer.WriteEndElement();
            end;
{$ENDREGION}
{$REGION 'BasisAmount'}
            if (tradeAllowanceCharge.BasisAmount.HasValue) then
            begin
              Writer.WriteStartElement('ram:BasisAmount',
                [TZUGFeRDProfile.Extended]);
              // not in XRechnung, according to CII-SR-123
              Writer.WriteValue
                (_formatDecimal(_asNullableParam<Currency>
                (tradeAllowanceCharge.BasisAmount), 2));
              Writer.WriteEndElement();
            end;
{$ENDREGION}
{$REGION 'ActualAmount'}
            Writer.WriteStartElement('ram:ActualAmount');
            Writer.WriteValue
              (_formatDecimal(_asNullableParam<Currency>
              (tradeAllowanceCharge.ActualAmount)));
            Writer.WriteEndElement();
{$ENDREGION}
            Writer.WriteOptionalElementString('ram:ReasonCode',
              TZUGFeRDAllowanceReasonCodesExtensions.EnumToString
              (tradeAllowanceCharge.ReasonCode));
            Writer.WriteOptionalElementString('ram:Reason',
              tradeAllowanceCharge.Reason, [TZUGFeRDProfile.Extended]);

            Writer.WriteEndElement(); // !AppliedTradeAllowanceCharge
          end;

          Writer.WriteEndElement();
          // ram:GrossPriceProductTradePrice(Comfort|Extended|XRechnung)
        end;
{$ENDREGION} // !GrossPriceProductTradePrice(Comfort|Extended|XRechnung)

{$REGION 'NetPriceProductTradePrice'}
        // Im Nettopreis sind alle Zu- und Abschläge enthalten, jedoch nicht die Umsatzsteuer.
        Writer.WriteStartElement('ram:NetPriceProductTradePrice',
          [TZUGFeRDProfile.Basic, TZUGFeRDProfile.Comfort,
          TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung,
          TZUGFeRDProfile.XRechnung1]);
        _writeOptionalAmount(Writer, 'ram:ChargeAmount',
          tradeLineItem.NetUnitPrice, 2); // BT-146

        if (tradeLineItem.UnitQuantity.HasValue) then
        begin
          _writeElementWithAttribute(Writer, 'ram:BasisQuantity', 'unitCode',
            TZUGFeRDQuantityCodesExtensions.EnumToString
            (tradeLineItem.UnitCode),
            _formatDecimal(tradeLineItem.UnitQuantity, 4));
        end;
        Writer.WriteEndElement();
        // ram:NetPriceProductTradePrice(Basic|Comfort|Extended|XRechnung)
{$ENDREGION} // !NetPriceProductTradePrice(Basic|Comfort|Extended|XRechnung)

{$REGION 'UltimateCustomerOrderReferencedDocument'}
        // ToDo: UltimateCustomerOrderReferencedDocument
{$ENDREGION}
        Writer.WriteEndElement(); // ram:SpecifiedLineTradeAgreement
      end;
{$ENDREGION}

{$REGION 'SpecifiedLineTradeDelivery (Basic, Comfort, Extended)'}
      Writer.WriteStartElement('ram:SpecifiedLineTradeDelivery',
        [TZUGFeRDProfile.Basic, TZUGFeRDProfile.Comfort,
        TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung,
        TZUGFeRDProfile.XRechnung1]);
      _writeElementWithAttribute(Writer, 'ram:BilledQuantity', 'unitCode',
        TZUGFeRDQuantityCodesExtensions.EnumToString(tradeLineItem.UnitCode),
        _formatDecimal(_asNullableParam<Double>
        (tradeLineItem.BilledQuantity), 4));
      if tradeLineItem.ChargeFreeQuantity.HasValue then
        _writeElementWithAttribute(Writer, 'ram:ChargeFreeQuantity', 'unitCode',
          TZUGFeRDQuantityCodesExtensions.EnumToString
          (tradeLineItem.ChargeFreeUnitCode),
          _formatDecimal(_asNullableParam<Double>
          (tradeLineItem.ChargeFreeQuantity), 4));
      if tradeLineItem.PackageQuantity.HasValue then
        _writeElementWithAttribute(Writer, 'ram:PackageQuantity', 'unitCode',
          TZUGFeRDQuantityCodesExtensions.EnumToString
          (tradeLineItem.PackageUnitCode),
          _formatDecimal(_asNullableParam<Double>
          (tradeLineItem.PackageQuantity), 4));
      if (tradeLineItem.ShipTo <> nil) then
        _writeOptionalParty(Writer, TZUGFeRDPartyTypes.ShipToTradeParty,
          tradeLineItem.ShipTo, [TZUGFeRDProfile.Extended]);

      if (tradeLineItem.UltimateShipTo <> nil) then
        _writeOptionalParty(Writer, TZUGFeRDPartyTypes.UltimateShipToTradeParty,
          tradeLineItem.UltimateShipTo, [TZUGFeRDProfile.Extended]);

      if (tradeLineItem.ActualDeliveryDate.HasValue) then
      begin
        Writer.WriteStartElement('ram:ActualDeliverySupplyChainEvent',
          ALL_PROFILES - [TZUGFeRDProfile.XRechnung1, TZUGFeRDProfile.XRechnung]
          ); // this violates CII-SR-170 for XRechnung 3
        Writer.WriteStartElement('ram:OccurrenceDateTime');
        Writer.WriteStartElement('udt:DateTimeString');
        Writer.WriteAttributeString('format', '102');
        Writer.WriteValue(_formatDate(tradeLineItem.ActualDeliveryDate.value));
        Writer.WriteEndElement(); // !udt:DateTimeString
        Writer.WriteEndElement(); // !OccurrenceDateTime()
        Writer.WriteEndElement(); // !ActualDeliverySupplyChainEvent
      end;

      if (tradeLineItem.DeliveryNoteReferencedDocument <> nil) then
      begin
        Writer.WriteStartElement('ram:DeliveryNoteReferencedDocument',
          [TZUGFeRDProfile.Extended]);
        // this violates CII-SR-175 for XRechnung 3
        Writer.WriteOptionalElementString('ram:IssuerAssignedID',
          tradeLineItem.DeliveryNoteReferencedDocument.ID);

        // reference to the delivery note item
        Writer.WriteOptionalElementString('ram:LineID',
          tradeLineItem.DeliveryNoteReferencedDocument.LineID);

        if (tradeLineItem.DeliveryNoteReferencedDocument.IssueDateTime.HasValue)
        then
        begin
          Writer.WriteStartElement('ram:FormattedIssueDateTime');
          Writer.WriteStartElement('qdt:DateTimeString');
          Writer.WriteAttributeString('format', '102');
          Writer.WriteValue
            (_formatDate(tradeLineItem.DeliveryNoteReferencedDocument.
            IssueDateTime.value));
          Writer.WriteEndElement(); // !qdt:DateTimeString
          Writer.WriteEndElement(); // !ram:FormattedIssueDateTime
        end;

        Writer.WriteEndElement(); // !ram:DeliveryNoteReferencedDocument
      end;

      Writer.WriteEndElement(); // !ram:SpecifiedLineTradeDelivery
{$ENDREGION}
{$REGION 'SpecifiedLineTradeSettlement'}
      Writer.WriteStartElement('ram:SpecifiedLineTradeSettlement',
        [TZUGFeRDProfile.Basic, TZUGFeRDProfile.Comfort,
        TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung,
        TZUGFeRDProfile.XRechnung1]);

{$REGION 'ApplicableTradeTax'}
      Writer.WriteStartElement('ram:ApplicableTradeTax',
        [TZUGFeRDProfile.Basic, TZUGFeRDProfile.Comfort,
        TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung,
        TZUGFeRDProfile.XRechnung1]);
      Writer.WriteElementString('ram:TypeCode',
        TZUGFeRDTaxTypesExtensions.EnumToString(tradeLineItem.TaxType));
      Writer.WriteOptionalElementString('ram:ExemptionReason',
        IfThen(string.IsNullOrEmpty(tradeLineItem.TaxExemptionReason),
          _translateTaxCategoryCode(tradeLineItem.TaxCategoryCode),
          tradeLineItem.TaxExemptionReason), [TZUGFeRDProfile.Extended]);
      Writer.WriteElementString('ram:CategoryCode',
        TZUGFeRDTaxCategoryCodesExtensions.EnumToString
        (tradeLineItem.taxCategoryCode)); // BT-151
      if (tradeLineItem.TaxExemptionReasonCode.HasValue) then
        Writer.WriteOptionalElementString('ram:ExemptionReasonCode',
          TZUGFeRDTaxExemptionReasonCodesExtensions.EnumToString
          (tradeLineItem.TaxExemptionReasonCode), [TZUGFeRDProfile.Extended]);
      // BT-X-97

      if (tradeLineItem.taxCategoryCode <> TZUGFeRDTaxCategoryCodes.O) then
      // notwendig, damit die Validierung klappt
        Writer.WriteElementString('ram:RateApplicablePercent',
          _formatDecimal(_asNullableParam<Double>(tradeLineItem.TaxPercent)));

      Writer.WriteEndElement();
      // !ram:ApplicableTradeTax(Basic|Comfort|Extended|XRechnung)
{$ENDREGION} // !ApplicableTradeTax(Basic|Comfort|Extended|XRechnung)

{$REGION 'BillingSpecifiedPeriod'}
      if (tradeLineItem.BillingPeriodStart.HasValue or
        tradeLineItem.BillingPeriodEnd.HasValue) then
      begin
        Writer.WriteStartElement('ram:BillingSpecifiedPeriod',
          [TZUGFeRDProfile.BasicWL, TZUGFeRDProfile.Basic,
          TZUGFeRDProfile.Comfort, TZUGFeRDProfile.Extended,
          TZUGFeRDProfile.XRechnung, TZUGFeRDProfile.XRechnung1]);
        if (tradeLineItem.BillingPeriodStart.HasValue) then
        begin
          Writer.WriteStartElement('ram:StartDateTime');
          _writeElementWithAttribute(Writer, 'udt:DateTimeString', 'format',
            '102', _formatDate(tradeLineItem.BillingPeriodStart.value));
          Writer.WriteEndElement(); // !StartDateTime
        end;

        if (tradeLineItem.BillingPeriodEnd.HasValue) then
        begin
          Writer.WriteStartElement('ram:EndDateTime');
          _writeElementWithAttribute(Writer, 'udt:DateTimeString', 'format',
            '102', _formatDate(tradeLineItem.BillingPeriodEnd.value));
          Writer.WriteEndElement(); // !EndDateTime
        end;
        Writer.WriteEndElement(); // !BillingSpecifiedPeriod
      end;
{$ENDREGION}
{$REGION 'SpecifiedTradeAllowanceCharge (Basic, Comfort, Extended, XRrechnung)'}
      // Abschläge auf Ebene der Rechnungsposition (Basic, Comfort, Extended)
      if (Descriptor.profile in [TZUGFeRDProfile.Basic, TZUGFeRDProfile.Comfort,
        TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung1,
        TZUGFeRDProfile.XRechnung]) then
        if (tradeLineItem.SpecifiedTradeAllowanceCharges.Count > 0) then
        begin
          for var specifiedTradeAllowanceCharge: TZUGFeRDTradeAllowanceCharge
            in tradeLineItem.SpecifiedTradeAllowanceCharges do // BG-27 BG-28
          begin
            Writer.WriteStartElement('ram:SpecifiedTradeAllowanceCharge');
{$REGION 'ChargeIndicator'}
            Writer.WriteStartElement('ram:ChargeIndicator');
            Writer.WriteElementString('udt:Indicator',
              ifthen(specifiedTradeAllowanceCharge.ChargeIndicator, 'true',
              'false'));
            Writer.WriteEndElement(); // !ram:ChargeIndicator
{$ENDREGION}
{$REGION 'ChargePercentage'}
            if (specifiedTradeAllowanceCharge.ChargePercentage.HasValue) then
            begin
              Writer.WriteStartElement('ram:CalculationPercent',
                [TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung]);
              Writer.WriteValue
                (_formatDecimal(_asNullableParam<Currency>
                (specifiedTradeAllowanceCharge.ChargePercentage)));
              Writer.WriteEndElement();
            end;
{$ENDREGION}
{$REGION 'BasisAmount'}
            if (specifiedTradeAllowanceCharge.BasisAmount.HasValue) then
            begin
              Writer.WriteStartElement('ram:BasisAmount',
                ALL_PROFILES - [TZUGFeRDProfile.Basic]);
              // not in XRechnung, according to CII-SR-123
              Writer.WriteValue
                (_formatDecimal(_asNullableParam<Currency>
                (specifiedTradeAllowanceCharge.BasisAmount)));
              Writer.WriteEndElement();
            end;
{$ENDREGION}
{$REGION 'ActualAmount'}
            Writer.WriteStartElement('ram:ActualAmount');
            Writer.WriteValue
              (_formatDecimal(_asNullableParam<Currency>
              (specifiedTradeAllowanceCharge.ActualAmount)));
            Writer.WriteEndElement();
{$ENDREGION}
            Writer.WriteOptionalElementString('ram:ReasonCode',
              TZUGFeRDAllowanceReasonCodesExtensions.EnumToString
              (specifiedTradeAllowanceCharge.ReasonCode));
            Writer.WriteOptionalElementString('ram:Reason',
              specifiedTradeAllowanceCharge.Reason, [TZUGFeRDProfile.Extended]);
          end;
          Writer.WriteEndElement(); // !ram:SpecifiedTradeAllowanceCharge
        end;
{$ENDREGION}
{$REGION 'SpecifiedTradeSettlementLineMonetarySummation (Basic, Comfort, Extended)'}
      // Detailinformationen zu Positionssummen
      Writer.WriteStartElement
        ('ram:SpecifiedTradeSettlementLineMonetarySummation');

      var
        _total: ZUGFeRDNullable<Double> := 0;

      if (tradeLineItem.LineTotalAmount.HasValue) then
      begin
        _total := tradeLineItem.LineTotalAmount.value;
      end
      else if (tradeLineItem.NetUnitPrice.HasValue) then
      begin
        _total := tradeLineItem.NetUnitPrice.value *
          tradeLineItem.BilledQuantity;
        if tradeLineItem.UnitQuantity.HasValue then
          if (tradeLineItem.UnitQuantity.value <> 0) then
          begin
            _total := _total.value / tradeLineItem.UnitQuantity.value;
          end;
      end;

      Writer.WriteStartElement('ram:LineTotalAmount',
        [TZUGFeRDProfile.Basic, TZUGFeRDProfile.Comfort,
        TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung,
        TZUGFeRDProfile.XRechnung1]);
      Writer.WriteValue(_formatDecimal(_total));
      Writer.WriteEndElement(); // !ram:LineTotalAmount

      // ToDo: TotalAllowanceChargeAmount
      // Gesamtbetrag der Positionszu- und Abschläge
      Writer.WriteEndElement(); // ram:SpecifiedTradeSettlementMonetarySummation
{$ENDREGION}
{$REGION 'AdditionalReferencedDocument'}
      // Objektkennung auf Ebene der Rechnungsposition
      if (tradeLineItem.AdditionalReferencedDocuments.Count > 0) then
      begin
        for var document in tradeLineItem.AdditionalReferencedDocuments do
        begin
          if document.TypeCode.Value <> TZUGFeRDAdditionalReferencedDocumentTypeCode.InvoiceDataSheet
          then // PEPPOL-EN16931-R101: Element Document reference can only be used for Invoice line object
            continue;
          if (string.IsNullOrWhiteSpace(document.ID)) then
            continue;

          _writeAdditionalReferencedDocument(Writer, document,
            PROFILE_COMFORT_EXTENDED_XRECHNUNG, 'BT-128-00');
          // only Extended allows multiple entries
          if (Descriptor.profile <> TZUGFeRDProfile.Extended) then
            break;
        end;
      end;
{$ENDREGION}
{$REGION 'ReceivableSpecifiedTradeAccountingAccount'}
      // Detailinformationen zur Buchungsreferenz
      for var traceAccountingAccount
        in tradeLineItem.ReceivableSpecifiedTradeAccountingAccounts do
      begin
        if string.IsNullOrWhiteSpace(traceAccountingAccount.TradeAccountID) then
          continue;

        Writer.WriteStartElement
          ('ram:ReceivableSpecifiedTradeAccountingAccount',
          PROFILE_COMFORT_EXTENDED_XRECHNUNG);
        Writer.WriteStartElement('ram:ID');
        Writer.WriteValue(traceAccountingAccount.TradeAccountID); // BT-133
        Writer.WriteEndElement(); // !ram:ID

        if (traceAccountingAccount.TradeAccountTypeCode.HasValue) then
        begin
          Writer.WriteStartElement('ram:TypeCode', [TZUGFeRDProfile.Extended]);
          Writer.WriteValue(TZUGFeRDAccountingAccountTypeCodesExtensions.
            EnumToString(traceAccountingAccount.TradeAccountTypeCode.value));
          // BT-X-99
          Writer.WriteEndElement(); // !ram:TypeCode
        end;
        Writer.WriteEndElement();
        // !ram:ReceivableSpecifiedTradeAccountingAccount

        // Only Extended allows multiple accounts per line item, otherwise break
        if (Descriptor.profile <> TZUGFeRDProfile.Extended) then
          break;
      end;
{$ENDREGION}
      Writer.WriteEndElement(); // !ram:SpecifiedLineTradeSettlement
{$ENDREGION}
      Writer.WriteEndElement(); // !ram:IncludedSupplyChainTradeLineItem
    end; // !foreach(tradeLineItem)
{$ENDREGION}
{$REGION 'ApplicableHeaderTradeAgreement'}
    Writer.WriteStartElement('ram:ApplicableHeaderTradeAgreement');

{$REGION 'Buyer Reference'}
    // BT-10
    Writer.WriteOptionalElementString('ram:BuyerReference',
      Descriptor.ReferenceOrderNo);
{$ENDREGION}
{$REGION 'SellerTradeParty'}
    // BT-31: Descriptor.SellerTaxRegistration
    _writeOptionalParty(Writer, TZUGFeRDPartyTypes.SellerTradeParty,
      Descriptor.Seller, ALL_PROFILES, Descriptor.SellerContact,
      Descriptor.SellerElectronicAddress, Descriptor.SellerTaxRegistration);
{$ENDREGION}
{$REGION 'BuyerTradeParty'}
    // BT-48: Descriptor.BuyerTaxRegistration
    _writeOptionalParty(Writer, TZUGFeRDPartyTypes.BuyerTradeParty,
      Descriptor.Buyer, ALL_PROFILES, Descriptor.BuyerContact,
      Descriptor.BuyerElectronicAddress, Descriptor.BuyerTaxRegistration);
{$ENDREGION}
{$REGION 'ApplicableTradeDeliveryTerms'}
    if (Descriptor.ApplicableTradeDeliveryTermsCode.HasValue) then
    begin
      // BG-X-22, BT-X-145
      Writer.WriteStartElement('ram:ApplicableTradeDeliveryTerms',
        [TZUGFeRDProfile.Extended]);
      Writer.WriteElementString('ram:DeliveryTypeCode',
        TZUGFeRDTradeDeliveryTermCodesExtensions.EnumToString
        (Descriptor.ApplicableTradeDeliveryTermsCode));
      Writer.WriteEndElement(); // !ApplicableTradeDeliveryTerms
    end;
{$ENDREGION}
{$REGION 'SellerTaxRepresentativeTradeParty'}
    // BT-63: the tax taxRegistration of the SellerTaxRepresentativeTradeParty
    _writeOptionalParty(Writer,
      TZUGFeRDPartyTypes.SellerTaxRepresentativeTradeParty,
      Descriptor.SellerTaxRepresentative, ALL_PROFILES, nil, nil,
      Descriptor.SellerTaxRepresentativeTaxRegistration);
{$ENDREGION}
{$REGION 'SellerOrderReferencedDocument (BT-14: Comfort, Extended)'}
    if (Descriptor.SellerOrderReferencedDocument <> nil) then
      if (Descriptor.SellerOrderReferencedDocument.ID <> '') then
      begin
        Writer.WriteStartElement('ram:SellerOrderReferencedDocument',
          PROFILE_COMFORT_EXTENDED_XRECHNUNG);
        Writer.WriteElementString('ram:IssuerAssignedID',
          Descriptor.SellerOrderReferencedDocument.ID);
        if (Descriptor.SellerOrderReferencedDocument.IssueDateTime.HasValue)
        then
        begin
          Writer.WriteStartElement('ram:FormattedIssueDateTime',
            [TZUGFeRDProfile.Extended]);
          Writer.WriteStartElement('qdt:DateTimeString');
          Writer.WriteAttributeString('format', '102');
          Writer.WriteValue
            (_formatDate(Descriptor.SellerOrderReferencedDocument.
            IssueDateTime.value));
          Writer.WriteEndElement(); // !qdt:DateTimeString
          Writer.WriteEndElement(); // !IssueDateTime()
        end;

        Writer.WriteEndElement(); // !SellerOrderReferencedDocument
      end;
{$ENDREGION}
{$REGION 'BuyerOrderReferencedDocument'}
    if not string.IsNullOrWhiteSpace(Descriptor.OrderNo) then
    begin
      Writer.WriteStartElement('ram:BuyerOrderReferencedDocument');
      Writer.WriteElementString('ram:IssuerAssignedID', Descriptor.OrderNo);
      if (Descriptor.OrderDate.HasValue) then
      begin
        Writer.WriteStartElement('ram:FormattedIssueDateTime',
          ALL_PROFILES - [TZUGFeRDProfile.XRechnung1,
          TZUGFeRDProfile.XRechnung]);
        Writer.WriteStartElement('qdt:DateTimeString');
        Writer.WriteAttributeString('format', '102');
        Writer.WriteValue(_formatDate(Descriptor.OrderDate.value));
        Writer.WriteEndElement(); // !qdt:DateTimeString
        Writer.WriteEndElement(); // !IssueDateTime()
      end;

      Writer.WriteEndElement(); // !BuyerOrderReferencedDocument
    end;
{$ENDREGION}
{$REGION 'ContractReferencedDocument'}
    // BT-12
    if (Descriptor.ContractReferencedDocument <> nil) then
    begin
      Writer.WriteStartElement('ram:ContractReferencedDocument');
      Writer.WriteElementString('ram:IssuerAssignedID',
        Descriptor.ContractReferencedDocument.ID);
      if (Descriptor.ContractReferencedDocument.IssueDateTime.HasValue) then
      begin
        Writer.WriteStartElement('ram:FormattedIssueDateTime',
          ALL_PROFILES - [TZUGFeRDProfile.XRechnung1,
          TZUGFeRDProfile.XRechnung]);
        Writer.WriteStartElement('qdt:DateTimeString');
        Writer.WriteAttributeString('format', '102');
        Writer.WriteValue
          (_formatDate(Descriptor.ContractReferencedDocument.
          IssueDateTime.value));
        Writer.WriteEndElement(); // !qdt:DateTimeString
        Writer.WriteEndElement(); // !IssueDateTime()
      end;

      Writer.WriteEndElement(); // !ram:ContractReferencedDocument
    end;
{$ENDREGION}
{$REGION 'AdditionalReferencedDocument'}
    if (Descriptor.AdditionalReferencedDocuments.Count > 0) then
    begin
      for var document: TZUGFeRDAdditionalReferencedDocument
        in Descriptor.AdditionalReferencedDocuments do
      begin
        _writeAdditionalReferencedDocument(Writer, document,
          PROFILE_COMFORT_EXTENDED_XRECHNUNG,
          ifthen(document.ReferenceTypeCode.HasValue, 'BT-18-00', 'BG-24'));
      end;
    end;
{$ENDREGION}
{$REGION 'SpecifiedProcuringProject'}
    if (Descriptor.SpecifiedProcuringProject <> nil) then
    begin
      Writer.WriteStartElement('ram:SpecifiedProcuringProject',
        [TZUGFeRDProfile.Comfort, TZUGFeRDProfile.Extended,
        TZUGFeRDProfile.XRechnung1, TZUGFeRDProfile.XRechnung]);
      Writer.WriteElementString('ram:ID',
        Descriptor.SpecifiedProcuringProject.ID, [TZUGFeRDProfile.Comfort,
        TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung1,
        TZUGFeRDProfile.XRechnung]);
      Writer.WriteElementString('ram:Name',
        Descriptor.SpecifiedProcuringProject.Name, [TZUGFeRDProfile.Comfort,
        TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung1,
        TZUGFeRDProfile.XRechnung]);
      Writer.WriteEndElement(); // !ram:SpecifiedProcuringProject
    end;
{$ENDREGION}
    Writer.WriteEndElement(); // !ApplicableHeaderTradeAgreement
{$ENDREGION}
{$REGION 'ApplicableHeaderTradeDelivery'}
    Writer.WriteStartElement('ram:ApplicableHeaderTradeDelivery');
    // Pflichteintrag

    // RelatedSupplyChainConsignment --> SpecifiedLogisticsTransportMovement --> ModeCode // Only in extended profile
    if (Descriptor.TransportMode <> nil) then
    begin
      Writer.WriteStartElement('ram:RelatedSupplyChainConsignment',
        [TZUGFeRDProfile.Extended]); // BG-X-24
      Writer.WriteStartElement('ram:SpecifiedLogisticsTransportMovement',
        [TZUGFeRDProfile.Extended]); // BT-X-152-00
      Writer.WriteElementString('ram:ModeCode',
        TZUGFeRDTransportmodeCodesExtensions.EnumToString
        (Descriptor.TransportMode)); // BT-X-152
      Writer.WriteEndElement(); // !ram:SpecifiedLogisticsTransportMovement
      Writer.WriteEndElement(); // !ram:RelatedSupplyChainConsignment
    end;

    _writeOptionalParty(Writer, TZUGFeRDPartyTypes.ShipToTradeParty,
      Descriptor.ShipTo, ALL_PROFILES - [TZUGFeRDProfile.Minimum],
      Descriptor.ShipToContact, nil, Descriptor.ShipToTaxRegistration);
    _writeOptionalParty(Writer, TZUGFeRDPartyTypes.UltimateShipToTradeParty,
      Descriptor.UltimateShipTo, [TZUGFeRDProfile.Extended,
      TZUGFeRDProfile.XRechnung1, TZUGFeRDProfile.XRechnung],
      Descriptor.UltimateShipToContact);
    _writeOptionalParty(Writer, TZUGFeRDPartyTypes.ShipFromTradeParty,
      Descriptor.ShipFrom, [TZUGFeRDProfile.Extended]);

{$REGION 'ActualDeliverySupplyChainEvent'}
    if (Descriptor.ActualDeliveryDate.HasValue) then
    begin
      Writer.WriteStartElement('ram:ActualDeliverySupplyChainEvent');
      Writer.WriteStartElement('ram:OccurrenceDateTime');
      Writer.WriteStartElement('udt:DateTimeString');
      Writer.WriteAttributeString('format', '102');
      Writer.WriteValue(_formatDate(Descriptor.ActualDeliveryDate.value));
      Writer.WriteEndElement(); // 'udt:DateTimeString
      Writer.WriteEndElement(); // !OccurrenceDateTime()
      Writer.WriteEndElement(); // !ActualDeliverySupplyChainEvent
    end;
{$ENDREGION}
{$REGION 'DespatchAdviceReferencedDocument'}
    if (Descriptor.DespatchAdviceReferencedDocument <> nil) then
    begin
      Writer.WriteStartElement('ram:DespatchAdviceReferencedDocument',
        [TZUGFeRDProfile.Extended]);
      Writer.WriteElementString('ram:IssuerAssignedID',
        Descriptor.DespatchAdviceReferencedDocument.ID);

      if (Descriptor.DespatchAdviceReferencedDocument.IssueDateTime.HasValue)
      then
      begin
        Writer.WriteStartElement('ram:FormattedIssueDateTime');
        Writer.WriteStartElement('qdt:DateTimeString');
        Writer.WriteAttributeString('format', '102');
        Writer.WriteValue
          (_formatDate(Descriptor.DespatchAdviceReferencedDocument.
          IssueDateTime.value));
        Writer.WriteEndElement(); // "qdt:DateTimeString
        Writer.WriteEndElement(); // !ram:FormattedIssueDateTime
      end;

      Writer.WriteEndElement(); // !DespatchAdviceReferencedDocument
    end;
{$ENDREGION}
{$REGION 'DeliveryNoteReferencedDocument'}
    if (Descriptor.DeliveryNoteReferencedDocument <> nil) then
    begin
      Writer.WriteStartElement('ram:DeliveryNoteReferencedDocument');
      Writer.WriteElementString('ram:IssuerAssignedID',
        Descriptor.DeliveryNoteReferencedDocument.ID);

      if (Descriptor.DeliveryNoteReferencedDocument.IssueDateTime.HasValue) then
      begin
        Writer.WriteStartElement('ram:FormattedIssueDateTime',
          ALL_PROFILES - [TZUGFeRDProfile.XRechnung1,
          TZUGFeRDProfile.XRechnung]);
        Writer.WriteStartElement('qdt:DateTimeString');
        Writer.WriteAttributeString('format', '102');
        Writer.WriteValue
          (_formatDate(Descriptor.DeliveryNoteReferencedDocument.
          IssueDateTime.value));
        Writer.WriteEndElement(); // 'qdt:DateTimeString
        Writer.WriteEndElement(); // !ram:FormattedIssueDateTime
      end;

      Writer.WriteEndElement(); // !DeliveryNoteReferencedDocument
    end;
{$ENDREGION}
    Writer.WriteEndElement(); // !ApplicableHeaderTradeDelivery
{$ENDREGION}
{$REGION 'ApplicableHeaderTradeSettlement'}
    Writer.WriteStartElement('ram:ApplicableHeaderTradeSettlement');
    // order of sub-elements of ApplicableHeaderTradeSettlement:
    // 1. CreditorReferenceID (optional)
    // 2. PaymentReference (optional)
    // 3. TaxCurrencyCode (optional)
    // 4. InvoiceCurrencyCode (optional)
    // 5. InvoiceIssuerReference (optional)
    // 6. InvoicerTradeParty (optional)
    // 7. InvoiceeTradeParty (optional)
    // 8. PayeeTradeParty (optional)
    // 9. TaxApplicableTradeCurrencyExchange (optional)
    // 10. SpecifiedTradeSettlementPaymentMeans (optional)
    // 11. ApplicableTradeTax (optional)
    // 12. BillingSpecifiedPeriod (optional)
    // 13. SpecifiedTradeAllowanceCharge (optional)
    // 14. SpecifiedLogisticsServiceCharge (optional)
    // 15. SpecifiedTradePaymentTerms (optional)
    // 16. SpecifiedTradeSettlementHeaderMonetarySummation
    // 17. InvoiceReferencedDocument (optional)
    // 18. ReceivableSpecifiedTradeAccountingAccount (optional)
    // 19. SpecifiedAdvancePayment (optional)

    // 1. CreditorReferenceID (BT-90) is only required/allowed on DirectDebit (BR-DE-30)
    if Descriptor.PaymentMeans <> nil then
      if (Descriptor.PaymentMeans.TypeCode
        in [TZUGFeRDPaymentMeansTypeCodes.DirectDebit,
        TZUGFeRDPaymentMeansTypeCodes.SEPADirectDebit]) and
        not string.IsNullOrWhiteSpace
        (Descriptor.PaymentMeans.SEPACreditorIdentifier) then
        Writer.WriteElementString('ram:CreditorReferenceID',
          Descriptor.PaymentMeans.SEPACreditorIdentifier,
          ALL_PROFILES - [TZUGFeRDProfile.Minimum]);

    // 2. PaymentReference (optional)
    Writer.WriteOptionalElementString('ram:PaymentReference',
      Descriptor.PaymentReference, ALL_PROFILES - [TZUGFeRDProfile.Minimum]);

    // 3. TaxCurrencyCode (optional)
    // BT-6
    if (Descriptor.TaxCurrency.HasValue) then
      Writer.WriteElementString('ram:TaxCurrencyCode',
        TZUGFerdCurrencyCodesExtensions.EnumToString(Descriptor.TaxCurrency),
        [TZUGFeRDProfile.Comfort, TZUGFeRDProfile.Extended,
        TZUGFeRDProfile.XRechnung1, TZUGFeRDProfile.XRechnung]);

    // 4. InvoiceCurrencyCode (optional)
    Writer.WriteElementString('ram:InvoiceCurrencyCode',
      TZUGFerdCurrencyCodesExtensions.EnumToString(Descriptor.Currency));

    // 5. InvoiceIssuerReference (optional)
    Writer.WriteOptionalElementString('ram:InvoiceIssuerReference',
      Descriptor.SellerReferenceNo, [TZUGFeRDProfile.Extended]);

    // 6. InvoicerTradeParty (optional)
    _writeOptionalParty(Writer, TZUGFeRDPartyTypes.InvoicerTradeParty,
      Descriptor.Invoicer, [TZUGFeRDProfile.Extended]);

    // 7. InvoiceeTradeParty (optional)
    _writeOptionalParty(Writer, TZUGFeRDPartyTypes.InvoiceeTradeParty,
      Descriptor.Invoicee, [TZUGFeRDProfile.Extended], nil, nil,
      Descriptor.InvoiceeTaxRegistration);

    // 8. PayeeTradeParty (optional)
    _writeOptionalParty(Writer, TZUGFeRDPartyTypes.PayeeTradeParty,
      Descriptor.Payee, ALL_PROFILES - [TZUGFeRDProfile.Minimum]);

{$REGION 'SpecifiedTradeSettlementPaymentMeans'}
    // 10. SpecifiedTradeSettlementPaymentMeans (optional)

    if (Descriptor.CreditorBankAccounts.Count = 0) and
      (Descriptor.DebitorBankAccounts.Count = 0) then
    begin
      if (Descriptor.PaymentMeans <> nil) then
        if (Descriptor.PaymentMeans.TypeCode <>
          TZUGFeRDPaymentMeansTypeCodes.Unknown) then
        begin
          Writer.WriteStartElement('ram:SpecifiedTradeSettlementPaymentMeans',
            [TZUGFeRDProfile.BasicWL, TZUGFeRDProfile.Basic,
            TZUGFeRDProfile.Comfort, TZUGFeRDProfile.Extended,
            TZUGFeRDProfile.XRechnung, TZUGFeRDProfile.XRechnung1]);
          Writer.WriteElementString('ram:TypeCode',
            TZUGFeRDPaymentMeansTypeCodesExtensions.EnumToString
            (Descriptor.PaymentMeans.TypeCode));
          Writer.WriteOptionalElementString('ram:Information',
            Descriptor.PaymentMeans.Information);

          if (Descriptor.PaymentMeans.FinancialCard <> nil) and
            not string.IsNullOrWhiteSpace
            (Descriptor.PaymentMeans.FinancialCard.ID) then
          begin
            Writer.WriteStartElement
              ('ram:ApplicableTradeSettlementFinancialCard',
              PROFILE_COMFORT_EXTENDED_XRECHNUNG);
            Writer.WriteOptionalElementString('ram:ID',
              Descriptor.PaymentMeans.FinancialCard.ID);
            Writer.WriteOptionalElementString('ram:CardholderName',
              Descriptor.PaymentMeans.FinancialCard.CardholderName);
            Writer.WriteEndElement();
            // !ram:ApplicableTradeSettlementFinancialCard
          end;
          Writer.WriteEndElement(); // !SpecifiedTradeSettlementPaymentMeans
        end;
    end
    else
    begin
      for var creditorAccount: TZUGFeRDBankAccount
        in Descriptor.CreditorBankAccounts do
      begin
        Writer.WriteStartElement('ram:SpecifiedTradeSettlementPaymentMeans',
          ALL_PROFILES - [TZUGFeRDProfile.Minimum]);

        if (Descriptor.PaymentMeans <> nil) then
          if (Descriptor.PaymentMeans.TypeCode <>
            TZUGFeRDPaymentMeansTypeCodes.Unknown) then
          begin
            Writer.WriteElementString('ram:TypeCode',
              TZUGFeRDPaymentMeansTypeCodesExtensions.EnumToString
              (Descriptor.PaymentMeans.TypeCode));
            Writer.WriteOptionalElementString('ram:Information',
              Descriptor.PaymentMeans.Information);

            if (Descriptor.PaymentMeans.FinancialCard <> nil) then
            begin
              Writer.WriteStartElement
                ('ram:ApplicableTradeSettlementFinancialCard',
                [TZUGFeRDProfile.Comfort, TZUGFeRDProfile.Extended,
                TZUGFeRDProfile.XRechnung]);
              Writer.WriteOptionalElementString('ram:ID',
                Descriptor.PaymentMeans.FinancialCard.ID);
              Writer.WriteOptionalElementString('ram:CardholderName',
                Descriptor.PaymentMeans.FinancialCard.CardholderName);
              Writer.WriteEndElement();
              // !ram:ApplicableTradeSettlementFinancialCard
            end;
          end;

        Writer.WriteStartElement('ram:PayeePartyCreditorFinancialAccount',
          ALL_PROFILES - [TZUGFeRDProfile.Minimum]);
        Writer.WriteElementString('ram:IBANID', creditorAccount.IBAN);
        Writer.WriteOptionalElementString('ram:AccountName',
          creditorAccount.Name, PROFILE_COMFORT_EXTENDED_XRECHNUNG);
        Writer.WriteOptionalElementString('ram:ProprietaryID',
          creditorAccount.ID);
        Writer.WriteEndElement(); // !PayeePartyCreditorFinancialAccount

        if not String.IsNullOrWhiteSpace(creditorAccount.BIC) then
        begin
          Writer.WriteStartElement
            ('ram:PayeeSpecifiedCreditorFinancialInstitution',
            PROFILE_COMFORT_EXTENDED_XRECHNUNG);
          Writer.WriteElementString('ram:BICID', creditorAccount.BIC);
          Writer.WriteEndElement();
          // !PayeeSpecifiedCreditorFinancialInstitution
        end;

        Writer.WriteEndElement(); // !SpecifiedTradeSettlementPaymentMeans
      end;

      for var debitorAccount: TZUGFeRDBankAccount
        in Descriptor.DebitorBankAccounts do
      begin
        Writer.WriteStartElement('ram:SpecifiedTradeSettlementPaymentMeans',
          ALL_PROFILES - [TZUGFeRDProfile.Minimum]); // BG-16

        if (Descriptor.PaymentMeans <> nil) then
          if (Descriptor.PaymentMeans.TypeCode <>
            TZUGFeRDPaymentMeansTypeCodes.Unknown) then
          begin
            Writer.WriteElementString('ram:TypeCode',
              TZUGFeRDPaymentMeansTypeCodesExtensions.EnumToString
              (Descriptor.PaymentMeans.TypeCode),
              ALL_PROFILES - [TZUGFeRDProfile.Minimum]);
            Writer.WriteOptionalElementString('ram:Information',
              Descriptor.PaymentMeans.Information,
              PROFILE_COMFORT_EXTENDED_XRECHNUNG);
          end;

        Writer.WriteStartElement('ram:PayerPartyDebtorFinancialAccount',
          ALL_PROFILES - [TZUGFeRDProfile.Minimum]);
        Writer.WriteElementString('ram:IBANID', debitorAccount.IBAN);
        Writer.WriteOptionalElementString('ram:AccountName',
          debitorAccount.Name, PROFILE_COMFORT_EXTENDED_XRECHNUNG);
        Writer.WriteOptionalElementString('ram:ProprietaryID',
          debitorAccount.ID);
        Writer.WriteEndElement(); // !PayerPartyDebtorFinancialAccount

        (* if (debitorAccount.BIC<>'') then
          begin
          Writer.WriteStartElement('ram:PayerSpecifiedDebtorFinancialInstitution');
          Writer.WriteElementString('ram:BICID', debitorAccount.BIC);
          Writer.WriteEndElement(); // !PayerSpecifiedDebtorFinancialInstitution
          end;
        *)
        Writer.WriteEndElement(); // !SpecifiedTradeSettlementPaymentMeans
      end;
    end;
{$ENDREGION}
{$REGION 'ApplicableTradeTax'}
    // 11. ApplicableTradeTax (optional)
    _writeOptionalTaxes(Writer);
{$ENDREGION}
{$REGION 'BillingSpecifiedPeriod'}
    // 12. BillingSpecifiedPeriod (optional)
    if (Descriptor.BillingPeriodStart.HasValue) or
      (Descriptor.BillingPeriodEnd.HasValue) then
    begin
      Writer.WriteStartElement('ram:BillingSpecifiedPeriod',
        ALL_PROFILES - [TZUGFeRDProfile.Minimum]);
      if (Descriptor.BillingPeriodStart.HasValue) then
      begin
        Writer.WriteStartElement('ram:StartDateTime');
        _writeElementWithAttribute(Writer, 'udt:DateTimeString', 'format',
          '102', _formatDate(Descriptor.BillingPeriodStart));
        Writer.WriteEndElement(); // !StartDateTime
      end;

      if (Descriptor.BillingPeriodEnd.HasValue) then
      begin
        Writer.WriteStartElement('ram:EndDateTime');
        _writeElementWithAttribute(Writer, 'udt:DateTimeString', 'format',
          '102', _formatDate(Descriptor.BillingPeriodEnd));
        Writer.WriteEndElement(); // !EndDateTime
      end;
      Writer.WriteEndElement(); // !BillingSpecifiedPeriod
    end;
{$ENDREGION}
    // 13. SpecifiedTradeAllowanceCharge (optional)
    for var tradeAllowanceCharge: TZUGFeRDTradeAllowanceCharge
      in Descriptor.TradeAllowanceCharges do
    begin
      Writer.WriteStartElement('ram:SpecifiedTradeAllowanceCharge');
      Writer.WriteStartElement('ram:ChargeIndicator');
      Writer.WriteElementString('udt:Indicator',
        ifthen(tradeAllowanceCharge.ChargeIndicator, 'true', 'false'));
      Writer.WriteEndElement(); // !ram:ChargeIndicator

      if (tradeAllowanceCharge.ChargePercentage.HasValue) then
      begin
        Writer.WriteStartElement('ram:CalculationPercent');
        Writer.WriteValue
          (_formatDecimal(_asNullableParam<Currency>
          (tradeAllowanceCharge.ChargePercentage)));
        Writer.WriteEndElement();
      end;

      if (tradeAllowanceCharge.BasisAmount <> nil) then
      begin
        Writer.WriteStartElement('ram:BasisAmount');
        Writer.WriteValue
          (_formatDecimal(_asNullableParam<Currency>
          (tradeAllowanceCharge.BasisAmount)));
        Writer.WriteEndElement();
      end;

      Writer.WriteStartElement('ram:ActualAmount');
      Writer.WriteValue
        (_formatDecimal(_asNullableParam<Currency>
        (tradeAllowanceCharge.ActualAmount)));
      Writer.WriteEndElement();

      Writer.WriteOptionalElementString('ram:ReasonCode',
        TZUGFeRDAllowanceReasonCodesExtensions.EnumToString
        (tradeAllowanceCharge.ReasonCode));
      Writer.WriteOptionalElementString('ram:Reason',
        tradeAllowanceCharge.Reason);

      if (tradeAllowanceCharge.Tax <> nil) then
      begin
        Writer.WriteStartElement('ram:CategoryTradeTax');
        Writer.WriteElementString('ram:TypeCode',
          TZUGFeRDTaxTypesExtensions.EnumToString
          (tradeAllowanceCharge.Tax.TypeCode));
        if (tradeAllowanceCharge.Tax.CategoryCode.HasValue) then
          Writer.WriteElementString('ram:CategoryCode',
            TZUGFeRDTaxCategoryCodesExtensions.EnumToString
            (tradeAllowanceCharge.Tax.CategoryCode));
        Writer.WriteElementString('ram:RateApplicablePercent',
          _formatDecimal(_asNullableParam<Currency>
          (tradeAllowanceCharge.Tax.Percent)));
        Writer.WriteEndElement();
      end;
      Writer.WriteEndElement();
    end;

    // 14. SpecifiedLogisticsServiceCharge (optional)
    for var serviceCharge: TZUGFeRDServiceCharge in Descriptor.ServiceCharges do
    begin
      Writer.WriteStartElement('ram:SpecifiedLogisticsServiceCharge',
        ALL_PROFILES - [TZUGFeRDProfile.XRechnung1, TZUGFeRDProfile.XRechnung]);
      Writer.WriteOptionalElementString('ram:Description',
        serviceCharge.Description);
      Writer.WriteElementString('ram:AppliedAmount',
        _formatDecimal(_asNullableParam<Currency>(serviceCharge.Amount)));
      if (serviceCharge.Tax <> nil) then
      begin
        Writer.WriteStartElement('ram:AppliedTradeTax');
        Writer.WriteElementString('ram:TypeCode',
          TZUGFeRDTaxTypesExtensions.EnumToString(serviceCharge.Tax.TypeCode));
        if (serviceCharge.Tax.CategoryCode <> TZUGFeRDTaxCategoryCodes.Unknown)
        then
          Writer.WriteElementString('ram:CategoryCode',
            TZUGFeRDTaxCategoryCodesExtensions.EnumToString
            (serviceCharge.Tax.CategoryCode));
        Writer.WriteElementString('ram:RateApplicablePercent',
          _formatDecimal(_asNullableParam<Currency>
          (serviceCharge.Tax.Percent)));
        Writer.WriteEndElement();
      end;
      Writer.WriteEndElement();
    end;

    // 15. SpecifiedTradePaymentTerms (optional)
    // The cardinality depends on the profile.
    case Descriptor.profile of
      TZUGFeRDProfile.Unknown, TZUGFeRDProfile.Minimum:
        ;
      TZUGFeRDProfile.XRechnung:
        begin
          if (Descriptor.PaymentTermsList.Count > 0) or
            (assigned(Descriptor.PaymentMeans) and not string.IsNullOrWhiteSpace
            (Descriptor.PaymentMeans.SEPAMandateReference)) then
          begin
            for var PaymentTerms in Descriptor.PaymentTermsList do
            begin
              Writer.WriteStartElement('ram:SpecifiedTradePaymentTerms');
              var sbPaymentNotes := TStringBuilder.Create();
              try
                var dueDate: ZUGFeRDNullable<TDateTime> := nil;

                if (PaymentTerms.PaymentTermsType.HasValue) then
                begin
                  // also write the descriptions if it exists.
                  if (not string.IsNullOrWhiteSpace(PaymentTerms.Description))
                  then
                  begin
                    sbPaymentNotes.Append(PaymentTerms.Description);
                    sbPaymentNotes.Append(XmlConstants.XmlNewLine);
                  end;

                  if (PaymentTerms.PaymentTermsType.HasValue and
                    PaymentTerms.DueDays.HasValue and
                    PaymentTerms.Percentage.HasValue) then
                  begin
                    sbPaymentNotes.Append('#' +
                      GetEnumName(TypeInfo(TZUGFeRDPaymentTermsType),
                      Integer(PaymentTerms.PaymentTermsType.value)).ToUpper);
                    sbPaymentNotes.Append
                      ('#TAGE=' + IntToStr(PaymentTerms.DueDays.value));
                    sbPaymentNotes.Append
                      ('#PROZENT=' + _formatDecimal(PaymentTerms.Percentage));
                    sbPaymentNotes.Append
                      (ifthen(PaymentTerms.BaseAmount.HasValue,
                      '#BASISBETRAG=' +
                      _formatDecimal(PaymentTerms.BaseAmount), ''));
                    sbPaymentNotes.Append('#');
                  end;
                end
                else
                begin
                  if (not string.IsNullOrWhiteSpace(PaymentTerms.Description)) then
                    sbPaymentNotes.AppendLine(PaymentTerms.Description);
                end;
                if not dueDate.HasValue then
                  dueDate := PaymentTerms.dueDate;

                Writer.WriteOptionalElementString('ram:Description',
                  sbPaymentNotes.ToString());
                if (dueDate.HasValue) then
                begin
                  Writer.WriteStartElement('ram:DueDateDateTime');
                  _writeElementWithAttribute(Writer, 'udt:DateTimeString',
                    'format', '102', _formatDate(dueDate.value));
                  Writer.WriteEndElement(); // !ram:DueDateDateTime
                end;
                // BT-89 is only required/allowed on DirectDebit (BR-DE-29)
                if (Descriptor.PaymentMeans.TypeCode
                  in [TZUGFeRDPaymentMeansTypeCodes.DirectDebit,
                  TZUGFeRDPaymentMeansTypeCodes.SEPADirectDebit]) then
                  Writer.WriteOptionalElementString('ram:DirectDebitMandateID',
                    Descriptor.PaymentMeans.SEPAMandateReference);
                Writer.WriteEndElement();
              finally
                sbPaymentNotes.Free;
              end;
            end;
          end;
        end;
      TZUGFeRDProfile.Extended:
        begin
          for var PaymentTerms in Descriptor.PaymentTermsList do
          begin
            Writer.WriteStartElement('ram:SpecifiedTradePaymentTerms');
            Writer.WriteOptionalElementString('ram:Description',
              PaymentTerms.Description);
            if (PaymentTerms.dueDate.HasValue) then
            begin
              Writer.WriteStartElement('ram:DueDateDateTime');
              _writeElementWithAttribute(Writer, 'udt:DateTimeString', 'format',
                '102', _formatDate(PaymentTerms.dueDate.value));
              Writer.WriteEndElement(); // !ram:DueDateDateTime
            end;
            Writer.WriteOptionalElementString('ram:DirectDebitMandateID',
              Descriptor.PaymentMeans.SEPAMandateReference);
            if (PaymentTerms.PaymentTermsType.HasValue) then
            begin
              if (PaymentTerms.PaymentTermsType = TZUGFeRDPaymentTermsType.
                Skonto) then
              begin
                Writer.WriteStartElement
                  ('ram:ApplicableTradePaymentDiscountTerms');
                if (PaymentTerms.MaturityDate.HasValue) then
                begin
                  Writer.WriteStartElement('ram:BasisDateTime');
                  _writeElementWithAttribute(Writer, 'udt:DateTimeString',
                    'format', '102',
                    _formatDate(PaymentTerms.MaturityDate.value));
                  Writer.WriteEndElement(); // !ram:BasisDateTime
                end;
                if (PaymentTerms.DueDays.HasValue) then
                  _writeElementWithAttribute(Writer, 'ram:BasisPeriodMeasure',
                    'unitCode', 'DAY', PaymentTerms.DueDays.value.ToString);

                _writeOptionalAmount(Writer, 'ram:BasisAmount',
                  PaymentTerms.BaseAmount, 2, false);
                Writer.WriteOptionalElementString('ram:CalculationPercent',
                  _formatDecimal(PaymentTerms.Percentage));
                _writeOptionalAmount(Writer, 'ram:ActualDiscountAmount',
                  PaymentTerms.ActualAmount, 2, false);
                Writer.WriteEndElement();
                // !ram:ApplicableTradePaymentDiscountTerms
              end;
              if (PaymentTerms.PaymentTermsType = TZUGFeRDPaymentTermsType.
                Verzug) then
              begin
                Writer.WriteStartElement
                  ('ram:ApplicableTradePaymentPenaltyTerms');
                if (PaymentTerms.MaturityDate.HasValue) then
                begin
                  Writer.WriteStartElement('ram:BasisDateTime');
                  _writeElementWithAttribute(Writer, 'udt:DateTimeString',
                    'format', '102',
                    _formatDate(PaymentTerms.MaturityDate.value));
                  Writer.WriteEndElement(); // !ram:BasisDateTime
                end;
                if (PaymentTerms.DueDays.HasValue) then
                  _writeElementWithAttribute(Writer, 'ram:BasisPeriodMeasure',
                    'unitCode', 'DAY', PaymentTerms.DueDays.value.ToString);

                _writeOptionalAmount(Writer, 'ram:BasisAmount',
                  PaymentTerms.BaseAmount);
                Writer.WriteOptionalElementString('ram:CalculationPercent',
                  _formatDecimal(PaymentTerms.Percentage));
                _writeOptionalAmount(Writer, 'ram:ActualPenaltyAmount',
                  PaymentTerms.ActualAmount);
                Writer.WriteEndElement();
                // !ram:ApplicableTradePaymentPenaltyTerms
              end;
            end;
            Writer.WriteEndElement();
          end;
          if (Descriptor.PaymentTermsList.Count = 0) and
            (assigned(Descriptor.PaymentMeans) and not string.IsNullOrWhiteSpace
            (Descriptor.PaymentMeans.SEPAMandateReference)) then
          begin
            Writer.WriteStartElement('ram:SpecifiedTradePaymentTerms');
            Writer.WriteOptionalElementString('ram:DirectDebitMandateID',
              Descriptor.PaymentMeans.SEPAMandateReference);
            Writer.WriteEndElement();
          end;
        end;
    else
      begin
        for var PaymentTerms in Descriptor.PaymentTermsList do
        begin
          Writer.WriteStartElement('ram:SpecifiedTradePaymentTerms');
          Writer.WriteOptionalElementString('ram:Description',
            PaymentTerms.Description, ALL_PROFILES - [TZUGFeRDProfile.Minimum]);
          if (PaymentTerms.dueDate.HasValue) then
          begin
            Writer.WriteStartElement('ram:DueDateDateTime',
              ALL_PROFILES - [TZUGFeRDProfile.Minimum]);
            _writeElementWithAttribute(Writer, 'udt:DateTimeString', 'format',
              '102', _formatDate(PaymentTerms.dueDate.value));
            Writer.WriteEndElement(); // !ram:DueDateDateTime
          end;
          Writer.WriteOptionalElementString('ram:DirectDebitMandateID',
            Descriptor.PaymentMeans.SEPAMandateReference,
            ALL_PROFILES - [TZUGFeRDProfile.Minimum]);
          Writer.WriteEndElement();
          // !ram:SpecifiedTradePaymentTerms        end;
        end;
      end;
    end;

{$REGION 'SpecifiedTradeSettlementHeaderMonetarySummation'}
    // 16. SpecifiedTradeSettlementHeaderMonetarySummation
    // Gesamtsummen auf Dokumentenebene
    Writer.WriteStartElement
      ('ram:SpecifiedTradeSettlementHeaderMonetarySummation');
    _writeOptionalAmount(Writer, 'ram:LineTotalAmount',
      Descriptor.LineTotalAmount);
    // Summe der Nettobeträge aller Rechnungspositionen
    _writeOptionalAmount(Writer, 'ram:ChargeTotalAmount',
      Descriptor.ChargeTotalAmount); // Summe der Zuschläge auf Dokumentenebene
    _writeOptionalAmount(Writer, 'ram:AllowanceTotalAmount',
      Descriptor.AllowanceTotalAmount);
    // Summe der Abschläge auf Dokumentenebene

    if (Descriptor.profile = TZUGFeRDProfile.Extended) then
    begin
      // there shall be no currency for tax basis total amount, see
      // https://github.com/stephanstapel/ZUGFeRD-csharp/issues/56#issuecomment-655525467
      _writeOptionalAmount(Writer, 'ram:TaxBasisTotalAmount',
        Descriptor.TaxBasisAmount); // Rechnungsgesamtbetrag ohne Umsatzsteuer
    end
    else
    begin
      _writeOptionalAmount(Writer, 'ram:TaxBasisTotalAmount',
        Descriptor.TaxBasisAmount); // Rechnungsgesamtbetrag ohne Umsatzsteuer
    end;
    _writeOptionalAmount(Writer, 'ram:TaxTotalAmount',
      Descriptor.TaxTotalAmount, 2, True);
    // Gesamtbetrag der Rechnungsumsatzsteuer, Steuergesamtbetrag in Buchungswährung
    _writeOptionalAmount(Writer, 'ram:RoundingAmount',
      Descriptor.RoundingAmount, 2, false, [TZUGFeRDProfile.Comfort,
      TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung1,
      TZUGFeRDProfile.XRechnung]); // RoundingAmount  //Rundungsbetrag
    _writeOptionalAmount(Writer, 'ram:GrandTotalAmount',
      Descriptor.GrandTotalAmount);
    // Rechnungsgesamtbetrag einschließlich Umsatzsteuer
    _writeOptionalAmount(Writer, 'ram:TotalPrepaidAmount',
      Descriptor.TotalPrepaidAmount); // Vorauszahlungsbetrag
    _writeOptionalAmount(Writer, 'ram:DuePayableAmount',
      Descriptor.DuePayableAmount); // Fälliger Zahlungsbetrag
    Writer.WriteEndElement(); // !ram:SpecifiedTradeSettlementMonetarySummation
{$ENDREGION}
{$REGION 'InvoiceReferencedDocument'}
    for var InvoiceReferencedDocument
      in Descriptor.InvoiceReferencedDocuments do
    begin
      Writer.WriteStartElement('ram:InvoiceReferencedDocument',
        ALL_PROFILES - [TZUGFeRDProfile.Minimum]);
      Writer.WriteOptionalElementString('ram:IssuerAssignedID',
        InvoiceReferencedDocument.ID);
      if (InvoiceReferencedDocument.IssueDateTime.HasValue) then
      begin
        Writer.WriteStartElement('ram:FormattedIssueDateTime');
        _writeElementWithAttribute(Writer, 'qdt:DateTimeString', 'format',
          '102', _formatDate(InvoiceReferencedDocument.IssueDateTime.value));
        Writer.WriteEndElement(); // !ram:FormattedIssueDateTime
      end;
      Writer.WriteEndElement(); // !ram:InvoiceReferencedDocument
    end;
{$ENDREGION}
{$REGION 'ReceivableSpecifiedTradeAccountingAccount'}
    // Detailinformationen zur Buchungsreferenz, BT-19-00
    if (Descriptor.ReceivableSpecifiedTradeAccountingAccounts <> nil) then
      if (Descriptor.ReceivableSpecifiedTradeAccountingAccounts.Count > 0) then
      begin
        for var traceAccountingAccount
          in Descriptor.ReceivableSpecifiedTradeAccountingAccounts do
        begin
          if string.IsNullOrWhiteSpace(traceAccountingAccount.TradeAccountID)
          then
            continue;
          Writer.WriteStartElement
            ('ram:ReceivableSpecifiedTradeAccountingAccount',
            ALL_PROFILES - [TZUGFeRDProfile.Minimum]);
          Writer.WriteStartElement('ram:ID');
          Writer.WriteValue(traceAccountingAccount.TradeAccountID);
          Writer.WriteEndElement(); // !ram:ID

          if traceAccountingAccount.TradeAccountTypeCode.HasValue then
          begin
            Writer.WriteStartElement('ram:TypeCode');
            Writer.WriteValue(TZUGFeRDAccountingAccountTypeCodesExtensions.
              EnumToString(traceAccountingAccount.TradeAccountTypeCode));
            Writer.WriteEndElement;
          end;

          Writer.WriteEndElement();
          // !ram:ReceivableSpecifiedTradeAccountingAccount

          // Only BasicWL and Extended allow multiple accounts
          if not(Descriptor.profile in [TZUGFeRDProfile.BasicWL,
            TZUGFeRDProfile.Extended]) then
            break;
        end;
      end;
{$ENDREGION}
    Writer.WriteEndElement(); // !ram:ApplicableHeaderTradeSettlement

{$ENDREGION}
    Writer.WriteEndElement(); // !ram:SpecifiedSupplyChainTradeTransaction
{$ENDREGION}
    Writer.WriteEndElement(); // !ram:Invoice
    Writer.WriteEndDocument();
    Writer.Flush();

    _stream.Seek(streamPosition, soFromBeginning);
  finally
    Writer.Free;
  end;
end;

function TZUGFeRDInvoiceDescriptor23CIIWriter.Validate
  (Descriptor: TZUGFeRDInvoiceDescriptor; throwExceptions: Boolean): Boolean;
begin
  result := false;
end;

function TZUGFeRDInvoiceDescriptor23CIIWriter._encodeInvoiceType
  (type_: TZUGFeRDInvoiceType): Integer;
begin
  if (Integer(type_) > 1000) then
    type_ := TZUGFeRDInvoiceType(Integer(type_) - 1000);

  case type_ of
    TZUGFeRDInvoiceType.CorrectionOld:
      result := Integer(TZUGFeRDInvoiceType.Correction);
  else
    result := Integer(type_);
  end;
end;

(*
function TZUGFeRDInvoiceDescriptor23CIIWriter._translateInvoiceType
  (type_: TZUGFeRDInvoiceType): String;
begin
  case type_ of
    SelfBilledInvoice, Invoice:
      result := 'RECHNUNG';
    SelfBilledCreditNote, CreditNote:
      result := 'GUTSCHRIFT';
    DebitNote:
      result := 'BELASTUNGSANZEIGE';
    DebitnoteRelatedToFinancialAdjustments:
      result := 'WERTBELASTUNG';
    PartialInvoice:
      result := 'TEILRECHNUNG';
    PrepaymentInvoice:
      result := 'VORAUSZAHLUNGSRECHNUNG';
    InvoiceInformation:
      result := 'KEINERECHNUNG';
    Correction, CorrectionOld:
      result := 'KORREKTURRECHNUNG';
  else
    result := '';
  end;
end;
*)

function TZUGFeRDInvoiceDescriptor23CIIWriter._translateTaxCategoryCode
  (taxCategoryCode: TZUGFeRDTaxCategoryCodes): String;
begin
  result := '';
  case taxCategoryCode of
    TZUGFeRDTaxCategoryCodes.A:
      ;
    TZUGFeRDTaxCategoryCodes.AA:
      ;
    TZUGFeRDTaxCategoryCodes.AB:
      ;
    TZUGFeRDTaxCategoryCodes.AC:
      ;
    TZUGFeRDTaxCategoryCodes.AD:
      ;
    TZUGFeRDTaxCategoryCodes.AE:
      result := 'Umkehrung der Steuerschuldnerschaft';
    TZUGFeRDTaxCategoryCodes.B:
      ;
    TZUGFeRDTaxCategoryCodes.C:
      ;
    TZUGFeRDTaxCategoryCodes.E:
      result := 'steuerbefreit';
    TZUGFeRDTaxCategoryCodes.G:
      result := 'freier Ausfuhrartikel, Steuer nicht erhoben';
    TZUGFeRDTaxCategoryCodes.H:
      ;
    TZUGFeRDTaxCategoryCodes.O:
      result := 'Dienstleistungen außerhalb des Steueranwendungsbereichs';
    TZUGFeRDTaxCategoryCodes.S:
      result := 'Normalsatz';
    TZUGFeRDTaxCategoryCodes.Z:
      result := 'nach dem Nullsatz zu versteuernde Waren';
    TZUGFeRDTaxCategoryCodes.Unknown:
      ;
    TZUGFeRDTaxCategoryCodes.D:
      ;
    TZUGFeRDTaxCategoryCodes.F:
      ;
    TZUGFeRDTaxCategoryCodes.I:
      ;
    TZUGFeRDTaxCategoryCodes.J:
      ;
    TZUGFeRDTaxCategoryCodes.K:
      result := 'Kein Ausweis der Umsatzsteuer bei innergemeinschaftlichen Lieferungen';
    TZUGFeRDTaxCategoryCodes.L:
      result := 'IGIC (Kanarische Inseln)';
    TZUGFeRDTaxCategoryCodes.M:
      result := 'IPSI (Ceuta/Melilla)';
  end;
end;

procedure TZUGFeRDInvoiceDescriptor23CIIWriter.
  _writeAdditionalReferencedDocument(_writer: TZUGFeRDProfileAwareXmlTextWriter;
  document: TZUGFeRDAdditionalReferencedDocument; profile: TZUGFeRDProfiles;
  parentElement: string);
begin
  if string.IsNullOrWhiteSpace(document.ID) then
    exit;

  _writer.WriteStartElement('ram:AdditionalReferencedDocument', profile);
  _writer.WriteElementString('ram:IssuerAssignedID', document.ID);

  var
  subProfile := profile;
  case IndexText(parentElement, ['BT-18-00', 'BG-24', 'BG-X-3']) of
    0, 1:
      subProfile := [TZUGFeRDProfile.Comfort, TZUGFeRDProfile.Extended,
        TZUGFeRDProfile.XRechnung];
    2:
      subProfile := [TZUGFeRDProfile.Extended];
  end;
  if (parentElement = 'BG-24') or (parentElement = 'BG-X-3') then
    Writer.WriteOptionalElementString('ram:URIID', document.URIID, subProfile);
  // BT-124, BT-X-28
  if (parentElement = 'BG-X-3') then
    Writer.WriteOptionalElementString('ram:LineID', document.LineID,
      subProfile); // BT-X-29

  if document.TypeCode.HasValue then
    _writer.WriteElementString('ram:TypeCode',
      TZUGFeRDAdditionalReferencedDocumentTypeCodeExtensions.EnumToString
      (document.TypeCode));

  if document.ReferenceTypeCode.HasValue then
  begin
    // CII-DT-024: ReferenceTypeCode is only allowed in BT-18-00 and BT-128-00 for InvoiceDataSheet
    if (((parentElement = 'BT-18-00') or (parentElement = 'BT-128-00')) and
      (document.TypeCode = TZUGFeRDAdditionalReferencedDocumentTypeCode.
      InvoiceDataSheet)) or (parentElement = 'BG-X-3') then
      _writer.WriteElementString('ram:ReferenceTypeCode',
        TZUGFeRDReferenceTypeCodesExtensions.EnumToString
        (document.ReferenceTypeCode));
  end;

  if (parentElement = 'BG-24') or (parentElement = 'BG-X-3') then
    _writer.WriteOptionalElementString('ram:Name', document.Name, subProfile);

  if (document.AttachmentBinaryObject <> nil) and (document.AttachmentBinaryObject.Size > 0) then
  begin
    _writer.WriteStartElement('ram:AttachmentBinaryObject'); // BT-125
    _writer.WriteAttributeString('filename', document.Filename); // BT-125-2
    _writer.WriteAttributeString('mimeCode',
      TZUGFeRDMimeTypeMapper.GetMimeType(document.Filename)); // BT-125-1
    _writer.WriteValue(TZUGFeRDHelper.GetDataAsBase64
      (document.AttachmentBinaryObject));
    _writer.WriteEndElement(); // !AttachmentBinaryObject()
  end;

  if (document.IssueDateTime.HasValue) then
  begin
    _writer.WriteStartElement('ram:FormattedIssueDateTime');
    _writer.WriteStartElement('qdt:DateTimeString');
    _writer.WriteAttributeString('format', '102');
    _writer.WriteValue(_formatDate(document.IssueDateTime.value));
    _writer.WriteEndElement(); // !qdt:DateTimeString
    _writer.WriteEndElement(); // !ram:FormattedIssueDateTime
  end;

  _writer.WriteEndElement(); // !ram:AdditionalReferencedDocument
end;

procedure TZUGFeRDInvoiceDescriptor23CIIWriter._writeElementWithAttribute
  (_writer: TZUGFeRDProfileAwareXmlTextWriter;
  tagName, attributeName, attributeValue, nodeValue: String;
  profile: TZUGFeRDProfiles);
begin
  _writer.WriteStartElement(tagName, profile);
  _writer.WriteAttributeString(attributeName, attributeValue);
  _writer.WriteValue(nodeValue);
  _writer.WriteEndElement(); // !tagName
end;

procedure TZUGFeRDInvoiceDescriptor23CIIWriter._writeNotes
  (_writer: TZUGFeRDProfileAwareXmlTextWriter; notes: TObjectList<TZUGFeRDNote>;
  profile: TZUGFeRDProfiles);
begin
  if notes.Count = 0 then
    exit;

  for var note: TZUGFeRDNote in notes do
  begin
    _writer.WriteStartElement('ram:IncludedNote');
    if (note.ContentCode <> TZUGFeRDContentCodes.Unknown) then
      _writer.WriteElementString('ram:ContentCode',
        TZUGFeRDContentCodesExtensions.EnumToString(note.ContentCode));
    _writer.WriteOptionalElementString('ram:Content', note.Content);
    if (note.SubjectCode <> TZUGFeRDSubjectCodes.Unknown) then
      _writer.WriteElementString('ram:SubjectCode',
        TZUGFeRDSubjectCodesExtensions.EnumToString(note.SubjectCode));
    _writer.WriteEndElement();
  end;
end;

procedure TZUGFeRDInvoiceDescriptor23CIIWriter._writeOptionalAmount
  (_writer: TZUGFeRDProfileAwareXmlTextWriter; tagName: string;
  value: ZUGFeRDNullable<Currency>; numDecimals: Integer;
  forceCurrency: Boolean; profile: TZUGFeRDProfiles);
begin
  if (value.HasValue) then // && (value.Value != decimal.MinValue))
  begin
    _writer.WriteStartElement(tagName, profile);
    if forceCurrency then
      _writer.WriteAttributeString('currencyID',
        TZUGFerdCurrencyCodesExtensions.EnumToString(Descriptor.Currency));
    _writer.WriteValue(_formatDecimal(value, numDecimals));
    _writer.WriteEndElement; // !tagName
  end;
end;

procedure TZUGFeRDInvoiceDescriptor23CIIWriter._writeOptionalAmount(
  _writer: TZUGFeRDProfileAwareXmlTextWriter; tagName: string; value: ZUGFeRDNullable<Double>;
  numDecimals: Integer; forceCurrency: Boolean; profile: TZUGFeRDProfiles);
begin
  if (value.HasValue) then // && (value.Value != decimal.MinValue))
  begin
    _writer.WriteStartElement(tagName, profile);
    if forceCurrency then
      _writer.WriteAttributeString('currencyID',
        TZUGFerdCurrencyCodesExtensions.EnumToString(Descriptor.Currency));
    _writer.WriteValue(_formatDecimal(value, numDecimals));
    _writer.WriteEndElement; // !tagName
  end;
end;

procedure TZUGFeRDInvoiceDescriptor23CIIWriter._writeOptionalContact
  (_writer: TZUGFeRDProfileAwareXmlTextWriter; contactTag: String;
  contact: TZUGFeRDContact; profile: TZUGFeRDProfiles);
begin
  if contact = nil then
    exit;

  _writer.WriteStartElement(contactTag, profile);

  _writer.WriteOptionalElementString('ram:PersonName', contact.Name);
  _writer.WriteOptionalElementString('ram:DepartmentName', contact.OrgUnit);

  if (contact.PhoneNo <> '') then
  begin
    _writer.WriteStartElement('ram:TelephoneUniversalCommunication');
    _writer.WriteElementString('ram:CompleteNumber', contact.PhoneNo);
    _writer.WriteEndElement();
  end;

  if (contact.FaxNo <> '') then
  begin
    _writer.WriteStartElement('ram:FaxUniversalCommunication',
      ALL_PROFILES - [TZUGFeRDProfile.XRechnung1, TZUGFeRDProfile.XRechnung]);
    _writer.WriteElementString('ram:CompleteNumber', contact.FaxNo);
    _writer.WriteEndElement();
  end;

  if (contact.EmailAddress <> '') then
  begin
    _writer.WriteStartElement('ram:EmailURIUniversalCommunication');
    _writer.WriteElementString('ram:URIID', contact.EmailAddress);
    _writer.WriteEndElement();
  end;

  _writer.WriteEndElement();
end;

procedure TZUGFeRDInvoiceDescriptor23CIIWriter._writeOptionalLegalOrganization
  (_writer: TZUGFeRDProfileAwareXmlTextWriter; legalOrganizationTag: String;
  legalOrganization: TZUGFeRDLegalOrganization; partyType: TZUGFeRDPartyTypes);
begin
  if (legalOrganization = nil) then
    exit;

  case partyType of
    TZUGFeRDPartyTypes.Unknown:
      ;
    TZUGFeRDPartyTypes.SellerTradeParty:
      ; // all profiles
    TZUGFeRDPartyTypes.BuyerTradeParty:
      ; // all profiles
    TZUGFeRDPartyTypes.ShipToTradeParty:
      if Descriptor.profile = TZUGFeRDProfile.Minimum then
        exit; // it is also possible to add ShipToTradeParty() to a LineItem. In this case, the correct profile filter is different!
    TZUGFeRDPartyTypes.UltimateShipToTradeParty:
      if (Descriptor.profile <> TZUGFeRDProfile.Extended) and
        (Descriptor.profile <> TZUGFeRDProfile.XRechnung1) and
        (Descriptor.profile <> TZUGFeRDProfile.XRechnung) then
        exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.ShipFromTradeParty:
      if (Descriptor.profile <> TZUGFeRDProfile.Extended) and
        (Descriptor.profile <> TZUGFeRDProfile.XRechnung1) and
        (Descriptor.profile <> TZUGFeRDProfile.XRechnung) then
        exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.InvoiceeTradeParty:
      if (Descriptor.profile <> TZUGFeRDProfile.Extended) and
        (Descriptor.profile <> TZUGFeRDProfile.XRechnung1) and
        (Descriptor.profile <> TZUGFeRDProfile.XRechnung) then
        exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.PayeeTradeParty:
      ; // all profiles
    TZUGFeRDPartyTypes.SalesAgentTradeParty:
      if (Descriptor.profile <> TZUGFeRDProfile.Extended) and
        (Descriptor.profile <> TZUGFeRDProfile.XRechnung1) and
        (Descriptor.profile <> TZUGFeRDProfile.XRechnung) then
        exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.BuyerTaxRepresentativeTradeParty:
      if (Descriptor.profile <> TZUGFeRDProfile.Extended) and
        (Descriptor.profile <> TZUGFeRDProfile.XRechnung1) and
        (Descriptor.profile <> TZUGFeRDProfile.XRechnung) then
        exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.ProductEndUserTradeParty:
      if (Descriptor.profile <> TZUGFeRDProfile.Extended) and
        (Descriptor.profile <> TZUGFeRDProfile.XRechnung1) and
        (Descriptor.profile <> TZUGFeRDProfile.XRechnung) then
        exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.BuyerAgentTradeParty:
      if (Descriptor.profile <> TZUGFeRDProfile.Extended) and
        (Descriptor.profile <> TZUGFeRDProfile.XRechnung1) and
        (Descriptor.profile <> TZUGFeRDProfile.XRechnung) then
        exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.InvoicerTradeParty:
      if (Descriptor.profile <> TZUGFeRDProfile.Extended) and
        (Descriptor.profile <> TZUGFeRDProfile.XRechnung1) and
        (Descriptor.profile <> TZUGFeRDProfile.XRechnung) then
        exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.PayerTradeParty:
      if (Descriptor.profile <> TZUGFeRDProfile.Extended) and
        (Descriptor.profile <> TZUGFeRDProfile.XRechnung1) and
        (Descriptor.profile <> TZUGFeRDProfile.XRechnung) then
        exit; // extended, XRechnung1, XRechnung profile only
  else
    exit;
  end;

  Writer.WriteStartElement(legalOrganizationTag, [Descriptor.profile]);
  if (legalOrganization.ID <> nil) then
  begin
    if (legalOrganization.ID.ID <> '') and
      (TZUGFeRDGlobalIDSchemeIdentifiersExtensions.EnumToString
      (legalOrganization.ID.SchemeID) <> '') then
    begin
      Writer.WriteStartElement('ram:ID');
      Writer.WriteAttributeString('schemeID',
        TZUGFeRDGlobalIDSchemeIdentifiersExtensions.EnumToString
        (legalOrganization.ID.SchemeID));
      Writer.WriteValue(legalOrganization.ID.ID);
      Writer.WriteEndElement();
    end
    else
    begin
      Writer.WriteElementString('ram:ID', legalOrganization.ID.ID);
    end;

    // filter according to https://github.com/stephanstapel/ZUGFeRD-csharp/pull/221
    if ((Descriptor.profile <> TZUGFeRDProfile.Minimum) and
      (partyType in [TZUGFeRDPartyTypes.SellerTradeParty,
      TZUGFeRDPartyTypes.PayeeTradeParty, TZUGFeRDPartyTypes.BuyerTradeParty]))
      or (Descriptor.profile = TZUGFeRDProfile.Extended)
    // * remaining party types */
    then
    begin
      Writer.WriteOptionalElementString('ram:TradingBusinessName',
        legalOrganization.TradingBusinessName, [Descriptor.profile]);
    end;
  end;
  Writer.WriteEndElement();
end;

procedure TZUGFeRDInvoiceDescriptor23CIIWriter._writeOptionalParty
  (_writer: TZUGFeRDProfileAwareXmlTextWriter; partyType: TZUGFeRDPartyTypes;
  party: TZUGFeRDParty; profile: TZUGFeRDProfiles; contact: TZUGFeRDContact;
  electronicAddress: TZUGFeRDElectronicAddress;
  taxRegistrations: TObjectList<TZUGFeRDTaxRegistration>);
begin
  if (party = nil) then
    exit;

  case partyType of
    TZUGFeRDPartyTypes.Unknown:
      exit;
    TZUGFeRDPartyTypes.SellerTradeParty:
      Writer.WriteStartElement('ram:SellerTradeParty', profile);
    TZUGFeRDPartyTypes.SellerTaxRepresentativeTradeParty:
      Writer.WriteStartElement('ram:SellerTaxRepresentativeTradeParty',
        profile);
    TZUGFeRDPartyTypes.BuyerTradeParty:
      Writer.WriteStartElement('ram:BuyerTradeParty', profile);
    TZUGFeRDPartyTypes.ShipToTradeParty:
      Writer.WriteStartElement('ram:ShipToTradeParty', profile);
    TZUGFeRDPartyTypes.UltimateShipToTradeParty:
      Writer.WriteStartElement('ram:UltimateShipToTradeParty', profile);
    TZUGFeRDPartyTypes.ShipFromTradeParty:
      Writer.WriteStartElement('ram:ShipFromTradeParty', profile);
    TZUGFeRDPartyTypes.InvoiceeTradeParty:
      Writer.WriteStartElement('ram:InvoiceeTradeParty', profile);
    TZUGFeRDPartyTypes.PayeeTradeParty:
      Writer.WriteStartElement('ram:PayeeTradeParty', profile);
    TZUGFeRDPartyTypes.PayerTradeParty:
      Writer.WriteStartElement('ram:PayerTradeParty', profile);
    TZUGFeRDPartyTypes.SalesAgentTradeParty:
      Writer.WriteStartElement('ram:SalesAgentTradeParty', profile);
    TZUGFeRDPartyTypes.BuyerTaxRepresentativeTradeParty:
      Writer.WriteStartElement('ram:BuyerTaxRepresentativeTradeParty', profile);
    TZUGFeRDPartyTypes.ProductEndUserTradeParty:
      Writer.WriteStartElement('ram:ProductEndUserTradeParty', profile);
    TZUGFeRDPartyTypes.BuyerAgentTradeParty:
      Writer.WriteStartElement('ram:BuyerAgentTradeParty', profile);
    TZUGFeRDPartyTypes.InvoicerTradeParty:
      Writer.WriteStartElement('ram:InvoicerTradeParty', profile);
  else
    exit;
  end;

  if (party.ID <> nil) and not string.IsNullOrWhiteSpace(party.ID.ID) then
  begin
    if (party.ID.SchemeID <> TZUGFeRDGlobalIDSchemeIdentifiers.Unknown) then
    begin
      Writer.WriteStartElement('ram:ID');
      Writer.WriteAttributeString('schemeID',
        TZUGFeRDGlobalIDSchemeIdentifiersExtensions.EnumToString
        (party.ID.SchemeID));
      Writer.WriteValue(party.ID.ID);
      Writer.WriteEndElement();
    end
    else
      Writer.WriteOptionalElementString('ram:ID', party.ID.ID);
  end;

  if (party.GlobalID <> nil) then
    if ((party.GlobalID.ID <> '') and (party.GlobalID.SchemeID <>
      TZUGFeRDGlobalIDSchemeIdentifiers.Unknown)) then
    begin
      Writer.WriteStartElement('ram:GlobalID');
      Writer.WriteAttributeString('schemeID',
        TZUGFeRDGlobalIDSchemeIdentifiersExtensions.EnumToString
        (party.GlobalID.SchemeID));
      Writer.WriteValue(party.GlobalID.ID);
      Writer.WriteEndElement();
    end;

  Writer.WriteOptionalElementString('ram:Name', party.Name);
  Writer.WriteOptionalElementString('ram:Description', party.Description,
    PROFILE_COMFORT_EXTENDED_XRECHNUNG);

  _writeOptionalLegalOrganization(Writer, 'ram:SpecifiedLegalOrganization',
    party.SpecifiedLegalOrganization, partyType);
  _writeOptionalContact(Writer, 'ram:DefinedTradeContact', contact,
    [TZUGFeRDProfile.Comfort, TZUGFeRDProfile.Extended,
    TZUGFeRDProfile.XRechnung1, TZUGFeRDProfile.XRechnung]);

  // spec 2.3 says: Minimum/BuyerTradeParty does not include PostalTradeAddress
  if (Descriptor.profile = TZUGFeRDProfile.Extended) or
    (partyType in [TZUGFeRDPartyTypes.BuyerTradeParty,
    TZUGFeRDPartyTypes.SellerTradeParty,
    TZUGFeRDPartyTypes.BuyerTaxRepresentativeTradeParty,
    TZUGFeRDPartyTypes.ShipToTradeParty, TZUGFeRDPartyTypes.ShipFromTradeParty,
    TZUGFeRDPartyTypes.UltimateShipToTradeParty,
    TZUGFeRDPartyTypes.SalesAgentTradeParty]) then
  begin
    Writer.WriteStartElement('ram:PostalTradeAddress');
    Writer.WriteOptionalElementString('ram:PostcodeCode', party.Postcode);
    // buyer: BT-53
    Writer.WriteOptionalElementString('ram:LineOne',
      ifthen(party.ContactName = '', party.Street, party.ContactName));
    // buyer: BT-50
    if (party.ContactName <> '') then
      Writer.WriteOptionalElementString('ram:LineTwo', party.Street);
    // buyer: BT-51
    Writer.WriteOptionalElementString('ram:LineThree', party.AddressLine3);
    // buyer: BT-163
    Writer.WriteOptionalElementString('ram:CityName', party.City);
    // buyer: BT-52
    Writer.WriteElementString('ram:CountryID',
      TZUGFeRDCountryCodesExtensions.EnumToString(party.Country));
    // buyer: BT-55
    Writer.WriteOptionalElementString('ram:CountrySubDivisionName',
      party.CountrySubdivisionName); // BT-79
    Writer.WriteEndElement(); // !PostalTradeAddress
  end;

  if (electronicAddress <> nil) then
  begin
    if (electronicAddress.Address <> '') then
    begin
      Writer.WriteStartElement('ram:URIUniversalCommunication');
      Writer.WriteStartElement('ram:URIID');
      Writer.WriteAttributeString('schemeID',
        TZUGFeRDElectronicAddressSchemeIdentifiersExtensions.EnumToString
        (electronicAddress.ElectronicAddressSchemeID));
      Writer.WriteValue(electronicAddress.Address);
      Writer.WriteEndElement();
      Writer.WriteEndElement();
    end;
  end;

  if (taxRegistrations <> nil) then
  begin
    // for seller: BT-31
    // for buyer : BT-48
    for var _reg: TZUGFeRDTaxRegistration in taxRegistrations do
    begin
      if (_reg.No <> '') then
      begin
        Writer.WriteStartElement('ram:SpecifiedTaxRegistration');
        Writer.WriteStartElement('ram:ID');
        Writer.WriteAttributeString('schemeID',
          TZUGFeRDTaxRegistrationSchemeIDExtensions.EnumToString
          (_reg.SchemeID));
        Writer.WriteValue(_reg.No);
        Writer.WriteEndElement();
        Writer.WriteEndElement();
      end;
    end;
  end;
  Writer.WriteEndElement(); // !*TradeParty
end;

procedure TZUGFeRDInvoiceDescriptor23CIIWriter._writeOptionalTaxes
  (_writer: TZUGFeRDProfileAwareXmlTextWriter);
begin
  for var Tax: TZUGFeRDTax in Descriptor.Taxes do
  begin
    _writer.WriteStartElement('ram:ApplicableTradeTax');

    _writer.WriteStartElement('ram:CalculatedAmount');
    _writer.WriteValue
      (_formatDecimal(_asNullableParam<Currency>(Tax.TaxAmount)));
    _writer.WriteEndElement(); // !CalculatedAmount

    _writer.WriteElementString('ram:TypeCode',
      TZUGFeRDTaxTypesExtensions.EnumToString(Tax.TypeCode));
    _writer.WriteOptionalElementString('ram:ExemptionReason',
      Tax.ExemptionReason);
    _writer.WriteStartElement('ram:BasisAmount');
    _writer.WriteValue
      (_formatDecimal(_asNullableParam<Currency>(Tax.BasisAmount)));
    _writer.WriteEndElement(); // !BasisAmount

    if (Tax.LineTotalBasisAmount.HasValue and
      (Tax.LineTotalBasisAmount.value <> 0)) then
    begin
      _writer.WriteStartElement('ram:LineTotalBasisAmount',
        [TZUGFeRDProfile.Extended]);
      _writer.WriteValue(_formatDecimal(Tax.LineTotalBasisAmount));
      _writer.WriteEndElement();
    end;

    if Tax.AllowanceChargeBasisAmount.HasValue and
      (Tax.AllowanceChargeBasisAmount.value <> 0) then
    begin
      _writer.WriteStartElement('ram:AllowanceChargeBasisAmount');
      _writer.WriteValue(_formatDecimal(Tax.AllowanceChargeBasisAmount));
      _writer.WriteEndElement(); // !AllowanceChargeBasisAmount
    end;

    if (Tax.CategoryCode.HasValue) then
    begin
      _writer.WriteElementString('ram:CategoryCode',
        TZUGFeRDTaxCategoryCodesExtensions.EnumToString(Tax.CategoryCode));
    end;
    if (Tax.ExemptionReasonCode.HasValue) then
    begin
      _writer.WriteElementString('ram:ExemptionReasonCode',
        TZUGFeRDTaxExemptionReasonCodesExtensions.EnumToString
        (Tax.ExemptionReasonCode));
    end;

    if (Tax.TaxPointDate.HasValue) then
    begin
      Writer.WriteStartElement('ram:TaxPointDate');
      Writer.WriteStartElement('udt:DateTimeString');
      Writer.WriteAttributeString('format', '102');
      Writer.WriteValue(_formatDate(Tax.TaxPointDate.value));
      Writer.WriteEndElement(); // !udt:DateString
      Writer.WriteEndElement(); // !TaxPointDate
    end;
    if (Tax.TaxPointDate.HasValue) then
      Writer.WriteElementString('ram:DueDateTypeCode',
        TZUGFeRDDateTypeCodesExtensions.EnumToString(Tax.DueDateTypeCode));

    _writer.WriteElementString('ram:RateApplicablePercent',
      _formatDecimal(_asNullableParam<Currency>(Tax.Percent)));
    _writer.WriteEndElement(); // !ApplicableTradeTax
  end;
end;

end.
