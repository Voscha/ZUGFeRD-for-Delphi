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

unit intf.ZUGFeRDInvoiceDescriptor22CIIWriter;

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
  TZUGFeRDInvoiceDescriptor22CIIWriter = class(TZUGFeRDInvoiceDescriptorWriter)
  private
    Writer: TZUGFeRDProfileAwareXmlTextWriter;
    Descriptor: TZUGFeRDInvoiceDescriptor;
    procedure _writeOptionalAmount(_writer : TZUGFeRDProfileAwareXmlTextWriter; tagName : string; value : ZUGFeRDNullable<Currency>; numDecimals : Integer = 2; forceCurrency : Boolean = false; profile : TZUGFeRDProfiles = TZUGFERDPROFILES_DEFAULT);
    procedure _writeNotes(_writer : TZUGFeRDProfileAwareXmlTextWriter;notes : TObjectList<TZUGFeRDNote>);
    procedure _writeOptionalLegalOrganization(_writer : TZUGFeRDProfileAwareXmlTextWriter; legalOrganizationTag : String;legalOrganization : TZUGFeRDLegalOrganization; partyType : TZUGFeRDPartyTypes = TZUGFeRDPartyTypes.Unknown);
    procedure _writeOptionalParty(_writer: TZUGFeRDProfileAwareXmlTextWriter; partyType : TZUGFeRDPartyTypes; party : TZUGFeRDParty; contact : TZUGFeRDContact = nil; electronicAddress : TZUGFeRDElectronicAddress = nil; taxRegistrations : TObjectList<TZUGFeRDTaxRegistration> = nil);
    procedure _writeOptionalContact(_writer: TZUGFeRDProfileAwareXmlTextWriter;contactTag: String; contact: TZUGFeRDContact;profile: TZUGFeRDProfiles);
    procedure _writeOptionalTaxes(_writer: TZUGFeRDProfileAwareXmlTextWriter);
    procedure _writeElementWithAttribute(_writer: TZUGFeRDProfileAwareXmlTextWriter; tagName, attributeName,attributeValue, nodeValue: String; profile: TZUGFeRDProfiles = [TZUGFeRDProfile.Unknown]);
    function _translateTaxCategoryCode(taxCategoryCode : TZUGFeRDTaxCategoryCodes) : String;
    function _translateInvoiceType(type_ : TZUGFeRDInvoiceType) : String;
    function _encodeInvoiceType(type_ : TZUGFeRDInvoiceType) : Integer;
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
      _format: TZUGFeRDFormats = TZUGFeRDFormats.CII); override;
    function Validate(descriptor: TZUGFeRDInvoiceDescriptor; throwExceptions: Boolean = True): Boolean; override;
  end;

implementation

{ TZUGFeRDInvoiceDescriptor22CIIWriter }

procedure TZUGFeRDInvoiceDescriptor22CIIWriter.Save(_descriptor: TZUGFeRDInvoiceDescriptor;
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
  Try
    Writer.Formatting := TZUGFeRDXmlFomatting.xmlFormatting_Indented;
    Writer.WriteStartDocument;

    //#region Kopfbereich
    Writer.WriteStartElement('rsm:CrossIndustryInvoice');
    Writer.WriteAttributeString('xmlns', 'a', '', 'urn:un:unece:uncefact:data:standard:QualifiedDataType:100');
    Writer.WriteAttributeString('xmlns', 'rsm', '', 'urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100');
    Writer.WriteAttributeString('xmlns', 'qdt', '', 'urn:un:unece:uncefact:data:standard:QualifiedDataType:100');
    Writer.WriteAttributeString('xmlns', 'ram', '', 'urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100');
    Writer.WriteAttributeString('xmlns', 'xs', '', 'http://www.w3.org/2001/XMLSchema');
    Writer.WriteAttributeString('xmlns', 'udt', '', 'urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100');
    //#endregion

    //#region ExchangedDocumentContext
    //Prozesssteuerung
    Writer.WriteStartElement('rsm:ExchangedDocumentContext');
    if (Descriptor.IsTest) then
    begin
      Writer.WriteStartElement('ram:TestIndicator');
      Writer.WriteElementString('udt:Indicator', ifthen(Descriptor.IsTest,'true','false'));
      Writer.WriteEndElement(); // !ram:TestIndicator
    end;

    if (Descriptor.BusinessProcess <> '') then
    begin
      Writer.WriteStartElement('ram:BusinessProcessSpecifiedDocumentContextParameter', [TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]);
      Writer.WriteElementString('ram:ID', Descriptor.BusinessProcess, [TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]);
      Writer.WriteEndElement(); // !ram:BusinessProcessSpecifiedDocumentContextParameter
    end;

    Writer.WriteStartElement('ram:GuidelineSpecifiedDocumentContextParameter');
    //Gruppierung der Anwendungsempfehlungsinformationen
    Writer.WriteElementString('ram:ID', TZUGFeRDProfileExtensions.EnumToString(Descriptor.Profile,TZUGFeRDVersion.Version22));
    Writer.WriteEndElement(); // !ram:GuidelineSpecifiedDocumentContextParameter
    Writer.WriteEndElement(); // !rsm:ExchangedDocumentContext
    //#endregion

    //Gruppierung der Eigenschaften, die das gesamte Dokument betreffen.
    Writer.WriteStartElement('rsm:ExchangedDocument');
    Writer.WriteElementString('ram:ID', Descriptor.InvoiceNo); //Rechnungsnummer
    Writer.WriteElementString('ram:Name', Descriptor.Name, [TZUGFeRDProfile.Extended]); //Dokumentenart (Freitext)
    Writer.WriteElementString('ram:TypeCode', Format('%d',[_encodeInvoiceType(Descriptor.Type_)])); //Code f�r den Rechnungstyp
                                                                                                               //ToDo: LanguageID      //Sprachkennzeichen
    if (Descriptor.InvoiceDate.HasValue) then
    begin
        Writer.WriteStartElement('ram:IssueDateTime');
        Writer.WriteStartElement('udt:DateTimeString');
        Writer.WriteAttributeString('format', '102');
        Writer.WriteValue(_formatDate(Descriptor.InvoiceDate));
        Writer.WriteEndElement(); // !udt:DateTimeString
        Writer.WriteEndElement(); // !IssueDateTime
    end;
    _writeNotes(Writer, Descriptor.Notes);
    Writer.WriteEndElement(); // !rsm:ExchangedDocument

    //#region SpecifiedSupplyChainTradeTransaction
    //Gruppierung der Informationen zum Gesch�ftsvorfall
    Writer.WriteStartElement('rsm:SupplyChainTradeTransaction');

    //#region  IncludedSupplyChainTradeLineItem
    for var tradeLineItem : TZUGFeRDTradeLineItem in Descriptor.TradeLineItems do
    begin
      Writer.WriteStartElement('ram:IncludedSupplyChainTradeLineItem');

      //#region AssociatedDocumentLineDocument
      //Gruppierung von allgemeinen Positionsangaben
      if (tradeLineItem.AssociatedDocument <> nil) then
      begin
        Writer.WriteStartElement('ram:AssociatedDocumentLineDocument', [TZUGFeRDProfile.Basic,TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]);
        if (tradeLineItem.AssociatedDocument.LineID <> '') then
        begin
          Writer.WriteElementString('ram:LineID', tradeLineItem.AssociatedDocument.LineID);
        end;
        _writeNotes(Writer, tradeLineItem.AssociatedDocument.Notes);
        Writer.WriteEndElement(); // ram:AssociatedDocumentLineDocument(Basic|Comfort|Extended|XRechnung)
      end;
      //#endregion

      // handelt es sich um einen Kommentar?
      var isCommentItem : Boolean := false;
      if tradeLineItem.AssociatedDocument <> nil then
      if ((tradeLineItem.AssociatedDocument.Notes.Count > 0) and
          (tradeLineItem.BilledQuantity = 0) and
          (tradeLineItem.Description<>'')) then
      begin
        isCommentItem := true;
      end;

      //#region SpecifiedTradeProduct
      //Eine Gruppe von betriebswirtschaftlichen Begriffen, die Informationen �ber die in Rechnung gestellten Waren und Dienstleistungen enth�lt
      Writer.WriteStartElement('ram:SpecifiedTradeProduct', [TZUGFeRDProfile.Basic,TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]);
      if (tradeLineItem.GlobalID <> nil) then
      if (tradeLineItem.GlobalID.SchemeID <> TZUGFeRDGlobalIDSchemeIdentifiers.Unknown) and (tradeLineItem.GlobalID.ID<> '') then
      begin
        _writeElementWithAttribute(Writer, 'ram:GlobalID', 'schemeID', TZUGFeRDGlobalIDSchemeIdentifiersExtensions.EnumToString(tradeLineItem.GlobalID.SchemeID), tradeLineItem.GlobalID.ID, [TZUGFeRDProfile.Basic,TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]);
      end;

      Writer.WriteOptionalElementString('ram:SellerAssignedID', tradeLineItem.SellerAssignedID, [TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]);
      Writer.WriteOptionalElementString('ram:BuyerAssignedID', tradeLineItem.BuyerAssignedID, [TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]);

      // BT-153
      Writer.WriteOptionalElementString('ram:Name', tradeLineItem.Name, [TZUGFeRDProfile.Basic,TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended]);
      Writer.WriteOptionalElementString('ram:Name', ifthen(isCommentItem,'TEXT',tradeLineItem.Name), [TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]); // XRechnung erfordert einen Item-Namen (BR-25)

      Writer.WriteOptionalElementString('ram:Description', tradeLineItem.Description, [TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]);

      if (tradeLineItem.ApplicableProductCharacteristics <> nil) then
      if (tradeLineItem.ApplicableProductCharacteristics.Count > 0) then
      begin
        for var productCharacteristic : TZUGFeRDApplicableProductCharacteristic in tradeLineItem.ApplicableProductCharacteristics do
        begin
          Writer.WriteStartElement('ram:ApplicableProductCharacteristic');
          Writer.WriteOptionalElementString('ram:Description', productCharacteristic.Description);
          Writer.WriteOptionalElementString('ram:Value', productCharacteristic.Value);
          Writer.WriteEndElement(); // !ram:ApplicableProductCharacteristic
        end
      end;

      if tradeLineItem.DesignatedProductClassifications.Count > 0 then
      begin
        for var designatedProductClassification in tradeLineItem.DesignatedProductClassifications do
        begin
          Writer.WriteStartElement('ram:DesignatedProductClassification');
          Writer.WriteOptionalElementString('ram:ClassName', designatedProductClassification.ClassName);

          if (designatedProductClassification.ClassCode.HasValue) then
          begin
            Writer.WriteStartElement('ram::ClassCode');
            if not String.IsNullOrWhiteSpace(designatedProductClassification.ListID) then
            begin
              Writer.WriteAttributeString('listID', designatedProductClassification.ListID);
              Writer.WriteAttributeString('listVersionID', designatedProductClassification.ListVersionID);
            end;
            Writer.WriteValue(designatedProductClassification.ClassCode.Value.ToString());
            Writer.WriteEndElement(); // !ram::ClassCode
          end;
          Writer.WriteEndElement(); // !ram:DesignatedProductClassification
        end;
      end;

      Writer.WriteEndElement(); // !ram:SpecifiedTradeProduct(Basic|Comfort|Extended|XRechnung)
      //#endregion
      //#region SpecifiedLineTradeAgreement (Basic, Comfort, Extended, XRechnung)
      //Eine Gruppe von betriebswirtschaftlichen Begriffen, die Informationen �ber den Preis f�r die in der betreffenden Rechnungsposition in Rechnung gestellten Waren und Dienstleistungen enth�lt

      if (descriptor.Profile in [TZUGFeRDProfile.Basic,TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung,TZUGFeRDProfile.XRechnung1]) then
      begin
        Writer.WriteStartElement('ram:SpecifiedLineTradeAgreement', [TZUGFeRDProfile.Basic,TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung,TZUGFeRDProfile.XRechnung1]);

        //#region BuyerOrderReferencedDocument (Comfort, Extended, XRechnung)
        //Detailangaben zur zugeh�rigen Bestellung
        if (tradeLineItem.BuyerOrderReferencedDocument <> nil) then
        begin
          Writer.WriteStartElement('ram:BuyerOrderReferencedDocument', [TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung,TZUGFeRDProfile.XRechnung1]);

          //#region IssuerAssignedID
          //Bestellnummer
          Writer.WriteOptionalElementString('ram:IssuerAssignedID', tradeLineItem.BuyerOrderReferencedDocument.ID, [TZUGFeRDProfile.Extended]);
          //#endregion

          //#region LineID
          //Referenz zur Bestellposition
          //ToDo: fehlt ganz
          //#endregion

          //#region IssueDateTime
          if (tradeLineItem.BuyerOrderReferencedDocument.IssueDateTime.HasValue) then
          begin
            Writer.WriteStartElement('ram:FormattedIssueDateTime', [TZUGFeRDProfile.Extended]);
            Writer.WriteStartElement('qdt:DateTimeString');
            Writer.WriteAttributeString('format', '102');
            Writer.WriteValue(_formatDate(tradeLineItem.BuyerOrderReferencedDocument.IssueDateTime.Value));
            Writer.WriteEndElement(); // !qdt:DateTimeString
            Writer.WriteEndElement(); // !ram:FormattedIssueDateTime
          end;
          //#endregion

          Writer.WriteEndElement(); // !ram:BuyerOrderReferencedDocument
        end;
        //#endregion

        //#region ContractReferencedDocument
        //Detailangaben zum zugeh�rigen Vertrag
        if (tradeLineItem.ContractReferencedDocument <> nil) then
        begin
          Writer.WriteStartElement('ram:ContractReferencedDocument', [TZUGFeRDProfile.Extended]);
          if (tradeLineItem.ContractReferencedDocument.IssueDateTime.HasValue) then
          begin
            Writer.WriteStartElement('ram:FormattedIssueDateTime');
            Writer.WriteStartElement('qdt:DateTimeString');
            Writer.WriteAttributeString('format', '102');
            Writer.WriteValue(_formatDate(tradeLineItem.ContractReferencedDocument.IssueDateTime.Value));
            Writer.WriteEndElement(); // !udt:DateTimeString
            Writer.WriteEndElement(); // !ram:IssueDateTime
          end;
          Writer.WriteOptionalElementString('ram:IssuerAssignedID', tradeLineItem.ContractReferencedDocument.ID);
          Writer.WriteEndElement(); // !ram:ContractReferencedDocument(Extended)
        end;
        //#endregion

        //#region AdditionalReferencedDocument (Extended)
        //Detailangaben zu einer zus�tzlichen Dokumentenreferenz
        for var document : TZUGFeRDAdditionalReferencedDocument in tradeLineItem.AdditionalReferencedDocuments do
        begin
          Writer.WriteStartElement('ram:AdditionalReferencedDocument', [TZUGFeRDProfile.Extended]);
          if (document.IssueDateTime.HasValue) then
          begin
              Writer.WriteStartElement('ram:FormattedIssueDateTime');
              Writer.WriteStartElement('qdt:DateTimeString');
              Writer.WriteAttributeString('format', '102');
              Writer.WriteValue(_formatDate(document.IssueDateTime.Value));
              Writer.WriteEndElement(); // !udt:DateTimeString
              Writer.WriteEndElement(); // !ram:IssueDateTime
          end;

          Writer.WriteElementString('ram:LineID', Format('%s',[tradeLineItem.AssociatedDocument.LineID]));
          Writer.WriteOptionalElementString('ram:IssuerAssignedID', document.ID);
          Writer.WriteElementString('ram:ReferenceTypeCode', TZUGFeRDReferenceTypeCodesExtensions.EnumToString(document.ReferenceTypeCode));

          Writer.WriteEndElement(); // !ram:AdditionalReferencedDocument
        end; // !foreach(document)
        //#endregion

        //#region GrossPriceProductTradePrice (Comfort, Extended, XRechnung)
        var needToWriteGrossUnitPrice := false;

        // the PEPPOL business rule for XRechnung is very specific
        // PEPPOL-EN16931-R046
        if ((descriptor.Profile = TZUGFeRDProfile.XRechnung) and
            tradeLineItem.GrossUnitPrice.HasValue and
            (tradeLineItem.TradeAllowanceCharges.Count > 0)) then
        begin
            needToWriteGrossUnitPrice := true;
        end
        else
        if ((descriptor.Profile <> TZUGFeRDProfile.XRechnung) and
           (tradeLineItem.GrossUnitPrice.HasValue or (tradeLineItem.TradeAllowanceCharges.Count > 0))) then
        begin
          needToWriteGrossUnitPrice := true;
        end;

        if (needToWriteGrossUnitPrice) then
        begin
          Writer.WriteStartElement('ram:GrossPriceProductTradePrice', [TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung,TZUGFeRDProfile.XRechnung1]);
          _writeOptionalAmount(Writer, 'ram:ChargeAmount', tradeLineItem.GrossUnitPrice, 2); //BT-148
          if (tradeLineItem.UnitQuantity.HasValue) then
          begin
            _writeElementWithAttribute(Writer, 'ram:BasisQuantity', 'unitCode', TZUGFeRDQuantityCodesExtensions.EnumToString(tradeLineItem.UnitCode), _formatDecimal(tradeLineItem.UnitQuantity, 4));
          end;

          for var tradeAllowanceCharge : TZUGFeRDTradeAllowanceCharge in tradeLineItem.TradeAllowanceCharges do //BT-147
          begin
            Writer.WriteStartElement('ram:AppliedTradeAllowanceCharge');

            //#region ChargeIndicator
            Writer.WriteStartElement('ram:ChargeIndicator');
            Writer.WriteElementString('udt:Indicator', ifthen(tradeAllowanceCharge.ChargeIndicator,'true','false'));
            Writer.WriteEndElement(); // !ram:ChargeIndicator
            //#endregion

            //#region ChargePercentage
            if (tradeAllowanceCharge.ChargePercentage <> 0.0) then
            begin
              Writer.WriteStartElement('ram:CalculationPercent', [TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung]);
              Writer.WriteValue(_formatDecimal(_asNullableParam<Currency>(tradeAllowanceCharge.ChargePercentage)));
              Writer.WriteEndElement();
            end;
            //#endregion

            //#region BasisAmount
            if (tradeAllowanceCharge.BasisAmount <> 0.0) then
            begin
              Writer.WriteStartElement('ram:BasisAmount', [TZUGFeRDProfile.Extended]); // not in XRechnung, according to CII-SR-123
              Writer.WriteValue(_formatDecimal(_asNullableParam<Currency>(tradeAllowanceCharge.BasisAmount), 2));
              Writer.WriteEndElement();
            end;
            //#endregion

            //#region ActualAmount
            Writer.WriteStartElement('ram:ActualAmount');
            Writer.WriteValue(_formatDecimal(_asNullableParam<Currency>(tradeAllowanceCharge.ActualAmount)));
            Writer.WriteEndElement();
            //#endregion

            if tradeAllowanceCharge.ChargeIndicator then
            begin
              Writer.WriteOptionalElementString('ram:ReasonCode',
                 TZUGFeRDSpecialServiceDescriptionCodesExtensions.EnumToString(
                                           tradeAllowanceCharge.ReasonCodeCharge));
            end else
            begin
              Writer.WriteOptionalElementString('ram:ReasonCode',
                 TZUGFeRDAllowanceOrChargeIdentificationCodesExtensions.EnumToString(
                                           tradeAllowanceCharge.ReasonCodeAllowance));
            end;

            //c# means not in XRechnung according to CII-SR-128
            //TODO Theoretisch auch Basic, Comfort, XRechnung
            Writer.WriteOptionalElementString('ram:Reason', tradeAllowanceCharge.Reason, [TZUGFeRDProfile.Extended]);

            Writer.WriteEndElement(); // !AppliedTradeAllowanceCharge
          end;

          Writer.WriteEndElement(); // ram:GrossPriceProductTradePrice(Comfort|Extended|XRechnung)
        end;
        //#endregion // !GrossPriceProductTradePrice(Comfort|Extended|XRechnung)

        //#region NetPriceProductTradePrice
        //Im Nettopreis sind alle Zu- und Abschl�ge enthalten, jedoch nicht die Umsatzsteuer.
        Writer.WriteStartElement('ram:NetPriceProductTradePrice', [TZUGFeRDProfile.Basic,TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung,TZUGFeRDProfile.XRechnung1]);
        _writeOptionalAmount(Writer, 'ram:ChargeAmount', tradeLineItem.NetUnitPrice, 2); //BT-146

        if (tradeLineItem.UnitQuantity.HasValue) then
        begin
          _writeElementWithAttribute(Writer, 'ram:BasisQuantity', 'unitCode', TZUGFeRDQuantityCodesExtensions.EnumToString(tradeLineItem.UnitCode), _formatDecimal(tradeLineItem.UnitQuantity, 4));
        end;
        Writer.WriteEndElement(); // ram:NetPriceProductTradePrice(Basic|Comfort|Extended|XRechnung)
        //#endregion // !NetPriceProductTradePrice(Basic|Comfort|Extended|XRechnung)

        //#region UltimateCustomerOrderReferencedDocument
        //ToDo: UltimateCustomerOrderReferencedDocument
        //#endregion
        Writer.WriteEndElement(); // ram:SpecifiedLineTradeAgreement
      end;
      //#endregion

      //#region SpecifiedLineTradeDelivery (Basic, Comfort, Extended)
      Writer.WriteStartElement('ram:SpecifiedLineTradeDelivery', [TZUGFeRDProfile.Basic,TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung,TZUGFeRDProfile.XRechnung1]);
      _writeElementWithAttribute(Writer, 'ram:BilledQuantity', 'unitCode', TZUGFeRDQuantityCodesExtensions.EnumToString(tradeLineItem.UnitCode), _formatDecimal(_asNullableParam<Double>(tradeLineItem.BilledQuantity), 4));
      if tradeLineItem.PackageQuantity.HasValue then
        _writeElementWithAttribute(Writer, 'ram:PackageQuantity', 'unitCode', TZUGFeRDQuantityCodesExtensions.EnumToString(tradeLineItem.PackageUnitCode), _formatDecimal(_asNullableParam<Double>(tradeLineItem.PackageQuantity), 4));
      if tradeLineItem.ChargeFreeQuantity.HasValue then
        _writeElementWithAttribute(Writer, 'ram:ChargeFreeQuantity', 'unitCode', TZUGFeRDQuantityCodesExtensions.EnumToString(tradeLineItem.ChargeFreeUnitCode), _formatDecimal(_asNullableParam<Double>(tradeLineItem.ChargeFreeQuantity), 4));

      if (tradeLineItem.DeliveryNoteReferencedDocument <> nil) then
      begin
          Writer.WriteStartElement('ram:DeliveryNoteReferencedDocument', ALL_PROFILES - [TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]); // this violates CII-SR-175 for XRechnung 3
          Writer.WriteOptionalElementString('ram:IssuerAssignedID', tradeLineItem.DeliveryNoteReferencedDocument.ID);

          if (tradeLineItem.DeliveryNoteReferencedDocument.IssueDateTime.HasValue) then
          begin
            Writer.WriteStartElement('ram:FormattedIssueDateTime');
            Writer.WriteStartElement('qdt:DateTimeString');
            Writer.WriteAttributeString('format', '102');
            Writer.WriteValue(_formatDate(tradeLineItem.DeliveryNoteReferencedDocument.IssueDateTime.Value));
            Writer.WriteEndElement(); // !qdt:DateTimeString
            Writer.WriteEndElement(); // !ram:FormattedIssueDateTime
          end;

          Writer.WriteEndElement(); // !ram:DeliveryNoteReferencedDocument
      end;

      if (tradeLineItem.ActualDeliveryDate.HasValue) then
      begin
        Writer.WriteStartElement('ram:ActualDeliverySupplyChainEvent', ALL_PROFILES - [TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]); // this violates CII-SR-170 for XRechnung 3
        Writer.WriteStartElement('ram:OccurrenceDateTime');
        Writer.WriteStartElement('udt:DateTimeString');
        Writer.WriteAttributeString('format', '102');
        Writer.WriteValue(_formatDate(tradeLineItem.ActualDeliveryDate.Value));
        Writer.WriteEndElement(); // !udt:DateTimeString
        Writer.WriteEndElement(); // !OccurrenceDateTime()
        Writer.WriteEndElement(); // !ActualDeliverySupplyChainEvent
      end;

      Writer.WriteEndElement(); // !ram:SpecifiedLineTradeDelivery
      //#endregion

      //#region SpecifiedLineTradeSettlement
      Writer.WriteStartElement('ram:SpecifiedLineTradeSettlement', [TZUGFeRDProfile.Basic,TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung,TZUGFeRDProfile.XRechnung1]);
      //#region ApplicableTradeTax
      Writer.WriteStartElement('ram:ApplicableTradeTax', [TZUGFeRDProfile.Basic,TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung,TZUGFeRDProfile.XRechnung1]);
      Writer.WriteElementString('ram:TypeCode', TZUGFeRDTaxTypesExtensions.EnumToString(tradeLineItem.TaxType));
      Writer.WriteOptionalElementString('ram:ExemptionReason', _translateTaxCategoryCode(tradeLineItem.TaxCategoryCode), [TZUGFeRDProfile.Extended]);
      Writer.WriteElementString('ram:CategoryCode', TZUGFeRDTaxCategoryCodesExtensions.EnumToString(tradeLineItem.TaxCategoryCode)); // BT-151

      if (tradeLineItem.TaxCategoryCode <> TZUGFeRDTaxCategoryCodes.O) then // notwendig, damit die Validierung klappt
      begin
        Writer.WriteElementString('ram:RateApplicablePercent', _formatDecimal(_asNullableParam<Double>(tradeLineItem.TaxPercent)));
      end;

      Writer.WriteEndElement(); // !ram:ApplicableTradeTax(Basic|Comfort|Extended|XRechnung)
      //#endregion // !ApplicableTradeTax(Basic|Comfort|Extended|XRechnung)

      //#region BillingSpecifiedPeriod
      if (tradeLineItem.BillingPeriodStart.HasValue or tradeLineItem.BillingPeriodEnd.HasValue) then
      begin
        Writer.WriteStartElement('ram:BillingSpecifiedPeriod', [TZUGFeRDProfile.BasicWL,TZUGFeRDProfile.Basic,TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung,TZUGFeRDProfile.XRechnung1]);
        if (tradeLineItem.BillingPeriodStart.HasValue) then
        begin
          Writer.WriteStartElement('ram:StartDateTime');
          _writeElementWithAttribute(Writer, 'udt:DateTimeString', 'format', '102', _formatDate(tradeLineItem.BillingPeriodStart.Value));
          Writer.WriteEndElement(); // !StartDateTime
        end;

        if (tradeLineItem.BillingPeriodEnd.HasValue) then
        begin
          Writer.WriteStartElement('ram:EndDateTime');
          _writeElementWithAttribute(Writer, 'udt:DateTimeString', 'format', '102', _formatDate(tradeLineItem.BillingPeriodEnd.Value));
          Writer.WriteEndElement(); // !EndDateTime
        end;
        Writer.WriteEndElement(); // !BillingSpecifiedPeriod
      end;
      //#endregion

      //#region SpecifiedTradeAllowanceCharge (Basic, Comfort, Extended)
      //Abschl�ge auf Ebene der Rechnungsposition (Basic, Comfort, Extended)
      if (descriptor.Profile in [TZUGFeRDProfile.Basic,TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung]) then
      if (tradeLineItem.SpecifiedTradeAllowanceCharges.Count > 0) then
      begin
        Writer.WriteStartElement('ram:SpecifiedTradeAllowanceCharge', [TZUGFeRDProfile.Basic,TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung]);
        for var specifiedTradeAllowanceCharge : TZUGFeRDTradeAllowanceCharge in tradeLineItem.SpecifiedTradeAllowanceCharges do // BG-27 BG-28
        begin
          //#region ChargeIndicator
          Writer.WriteStartElement('ram:ChargeIndicator');
          Writer.WriteElementString('udt:Indicator', ifthen(specifiedTradeAllowanceCharge.ChargeIndicator,'true','false'));
          Writer.WriteEndElement(); // !ram:ChargeIndicator
          //#endregion

          //#region ChargePercentage
          if (specifiedTradeAllowanceCharge.ChargePercentage <> 0.0) then
          begin
            Writer.WriteStartElement('ram:CalculationPercent', [TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung]);
            Writer.WriteValue(_formatDecimal(_asNullableParam<Currency>(specifiedTradeAllowanceCharge.ChargePercentage)));
            Writer.WriteEndElement();
          end;
          //#endregion

          //#region BasisAmount
          if (specifiedTradeAllowanceCharge.BasisAmount <> 0.0) then
          begin
            Writer.WriteStartElement('ram:BasisAmount', [TZUGFeRDProfile.Extended]); // not in XRechnung, according to CII-SR-123
            Writer.WriteValue(_formatDecimal(_asNullableParam<Currency>(specifiedTradeAllowanceCharge.BasisAmount)));
            Writer.WriteEndElement();
          end;
          //#endregion

          //#region ActualAmount
          Writer.WriteStartElement('ram:ActualAmount');
          Writer.WriteValue(_formatDecimal(_asNullableParam<Currency>(specifiedTradeAllowanceCharge.ActualAmount)));
          Writer.WriteEndElement();
          //#endregion

          if specifiedTradeAllowanceCharge.ChargeIndicator then
          begin
            Writer.WriteOptionalElementString('ram:ReasonCode',
               TZUGFeRDSpecialServiceDescriptionCodesExtensions.EnumToString(
                                         specifiedTradeAllowanceCharge.ReasonCodeCharge));
          end else
          begin
            Writer.WriteOptionalElementString('ram:ReasonCode',
               TZUGFeRDAllowanceOrChargeIdentificationCodesExtensions.EnumToString(
                                         specifiedTradeAllowanceCharge.ReasonCodeAllowance));
          end;

          //c# means not in XRechnung according to CII-SR-128
          //TODO Theoretisch auch Basic, Comfort, XRechnung
          Writer.WriteOptionalElementString('ram:Reason', specifiedTradeAllowanceCharge.Reason, [TZUGFeRDProfile.Extended]);
        end;
        Writer.WriteEndElement(); // !ram:SpecifiedTradeAllowanceCharge
      end;
      //#endregion

      //#region SpecifiedTradeSettlementLineMonetarySummation (Basic, Comfort, Extended)
      //Detailinformationen zu Positionssummen
      Writer.WriteStartElement('ram:SpecifiedTradeSettlementLineMonetarySummation');

      var _total : ZUGFErDNullable<double> := 0;

      if (tradeLineItem.LineTotalAmount.HasValue) then
      begin
        _total := tradeLineItem.LineTotalAmount.Value;
      end
      else if (tradeLineItem.NetUnitPrice.HasValue) then
      begin
        _total := tradeLineItem.NetUnitPrice.Value * tradeLineItem.BilledQuantity;
        if tradeLineItem.UnitQuantity.HasValue then
        if (tradeLineItem.UnitQuantity.Value <> 0) then
        begin
          _total := _total.Value / tradeLineItem.UnitQuantity.Value;
        end;
      end;

      Writer.WriteStartElement('ram:LineTotalAmount', [TZUGFeRDProfile.Basic,TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung,TZUGFeRDProfile.XRechnung1]);
      Writer.WriteValue(_formatDecimal(_total));
      Writer.WriteEndElement(); // !ram:LineTotalAmount

      //ToDo: TotalAllowanceChargeAmount
      //Gesamtbetrag der Positionszu- und Abschl�ge
      Writer.WriteEndElement(); // ram:SpecifiedTradeSettlementMonetarySummation
      //#endregion

      //#region AdditionalReferencedDocument
      //Objektkennung auf Ebene der Rechnungsposition
      //ToDo: AdditionalReferencedDocument
      //#endregion

      //#region ReceivableSpecifiedTradeAccountingAccount
      //Detailinformationen zur Buchungsreferenz
      if (((descriptor.Profile = TZUGFeRDProfile.XRechnung1) or
           (descriptor.Profile = TZUGFeRDProfile.XRechnung)) and
           (tradeLineItem.ReceivableSpecifiedTradeAccountingAccounts.Count > 0)) then
      begin
        //only one ReceivableSpecifiedTradeAccountingAccount (BT-133) is allowed in Profile XRechnung
        Writer.WriteStartElement('ram:ReceivableSpecifiedTradeAccountingAccount', [TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung,TZUGFeRDProfile.XRechnung1]);
        begin
          Writer.WriteStartElement('ram:ID');
          Writer.WriteValue(tradeLineItem.ReceivableSpecifiedTradeAccountingAccounts[0].TradeAccountID);  //BT-133
          Writer.WriteEndElement(); // !ram:ID
        end;
        Writer.WriteEndElement(); // !ram:ReceivableSpecifiedTradeAccountingAccount
      end
      else
      begin
        //multiple ReceivableSpecifiedTradeAccountingAccounts are allowed in other profiles
        for var RSTA : TZUGFeRDReceivableSpecifiedTradeAccountingAccount in tradeLineItem.ReceivableSpecifiedTradeAccountingAccounts do
        begin
          Writer.WriteStartElement('ram:ReceivableSpecifiedTradeAccountingAccount', [TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended]);

          Writer.WriteStartElement('ram:ID');
          Writer.WriteValue(RSTA.TradeAccountID);
          Writer.WriteEndElement(); // !ram:ID

          if (RSTA.TradeAccountTypeCode <> TZUGFeRDAccountingAccountTypeCodes.Unknown) then
          begin
            Writer.WriteStartElement('ram:TypeCode', [TZUGFeRDProfile.Extended]);
            Writer.WriteValue((Integer(RSTA.TradeAccountTypeCode)).ToString);
            Writer.WriteEndElement(); // !ram:TypeCode
          end;

          Writer.WriteEndElement(); // !ram:ReceivableSpecifiedTradeAccountingAccount
        end;
      end;
      //#endregion

      Writer.WriteEndElement(); // !ram:SpecifiedLineTradeSettlement
      //#endregion

      Writer.WriteEndElement(); // !ram:IncludedSupplyChainTradeLineItem
    end; // !foreach(tradeLineItem)
    // #endregion

    //#region ApplicableHeaderTradeAgreement
    Writer.WriteStartElement('ram:ApplicableHeaderTradeAgreement');

    // BT-10
    Writer.WriteOptionalElementString('ram:BuyerReference', Descriptor.ReferenceOrderNo);

    //#region SellerTradeParty
    // BT-31: Descriptor.SellerTaxRegistration
    _writeOptionalParty(Writer, TZUGFeRDPartyTypes.SellerTradeParty, Descriptor.Seller, Descriptor.SellerContact, Descriptor.SellerElectronicAddress, Descriptor.SellerTaxRegistration);
    //#endregion

    //region BuyerTradeParty
    // BT-48: Descriptor.BuyerTaxRegistration
    _writeOptionalParty(Writer, TZUGFeRDPartyTypes.BuyerTradeParty, Descriptor.Buyer, Descriptor.BuyerContact, Descriptor.BuyerElectronicAddress, Descriptor.BuyerTaxRegistration);
    //#endregion

    // TODO: implement SellerTaxRepresentativeTradeParty
    // BT-63: the tax registration of the SellerTaxRepresentativeTradeParty

    //#region SellerOrderReferencedDocument (BT-14: Comfort, Extended)
    if (Descriptor.SellerOrderReferencedDocument <> nil) then
    if (Descriptor.SellerOrderReferencedDocument.ID <> '') then
    begin
      Writer.WriteStartElement('ram:SellerOrderReferencedDocument', [TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung1, TZUGFeRDProfile.XRechnung]);
      Writer.WriteElementString('ram:IssuerAssignedID', Descriptor.SellerOrderReferencedDocument.ID);
      if (Descriptor.SellerOrderReferencedDocument.IssueDateTime.HasValue) then
      begin
        Writer.WriteStartElement('ram:FormattedIssueDateTime', [TZUGFeRDProfile.Extended]);
        Writer.WriteStartElement('qdt:DateTimeString');
        Writer.WriteAttributeString('format', '102');
        Writer.WriteValue(_formatDate(Descriptor.SellerOrderReferencedDocument.IssueDateTime.Value));
        Writer.WriteEndElement(); // !qdt:DateTimeString
        Writer.WriteEndElement(); // !IssueDateTime()
      end;

      Writer.WriteEndElement(); // !SellerOrderReferencedDocument
    end;
    //#endregion

    //#region BuyerOrderReferencedDocument
    if (Descriptor.OrderNo <> '') then
    begin
      Writer.WriteStartElement('ram:BuyerOrderReferencedDocument');
      Writer.WriteElementString('ram:IssuerAssignedID', Descriptor.OrderNo);
      if (Descriptor.OrderDate.HasValue) then
      begin
        Writer.WriteStartElement('ram:FormattedIssueDateTime', ALL_PROFILES - [TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]);
        Writer.WriteStartElement('qdt:DateTimeString');
        Writer.WriteAttributeString('format', '102');
        Writer.WriteValue(_formatDate(Descriptor.OrderDate.Value));
        Writer.WriteEndElement(); // !qdt:DateTimeString
        Writer.WriteEndElement(); // !IssueDateTime()
      end;

      Writer.WriteEndElement(); // !BuyerOrderReferencedDocument
    end;
    //#endregion

    //#region ContractReferencedDocument
    // BT-12
    if (Descriptor.ContractReferencedDocument <> nil) then
    begin
      Writer.WriteStartElement('ram:ContractReferencedDocument');
      Writer.WriteElementString('ram:IssuerAssignedID', Descriptor.ContractReferencedDocument.ID);
      if (Descriptor.ContractReferencedDocument.IssueDateTime.HasValue) then
      begin
        Writer.WriteStartElement('ram:FormattedIssueDateTime', ALL_PROFILES  - [TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]);
        Writer.WriteStartElement('qdt:DateTimeString');
        Writer.WriteAttributeString('format', '102');
        Writer.WriteValue(_formatDate(Descriptor.ContractReferencedDocument.IssueDateTime.Value));
        Writer.WriteEndElement(); // !qdt:DateTimeString
        Writer.WriteEndElement(); // !IssueDateTime()
      end;

      Writer.WriteEndElement(); // !ram:ContractReferencedDocument
    end;
    //#endregion

    //#region AdditionalReferencedDocument
    if (Descriptor.AdditionalReferencedDocuments.Count > 0) then
    begin
      for var document : TZUGFeRDAdditionalReferencedDocument in Descriptor.AdditionalReferencedDocuments do
      begin
        Writer.WriteStartElement('ram:AdditionalReferencedDocument', [TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung]);
        Writer.WriteElementString('ram:IssuerAssignedID', document.ID);
        Writer.WriteElementString('ram:TypeCode', TZUGFeRDAdditionalReferencedDocumentTypeCodeExtensions.EnumToString(document.TypeCode));

        if (document.ReferenceTypeCode <> TZUGFeRDReferenceTypeCodes.Unknown) then
        begin
          Writer.WriteElementString('ram:ReferenceTypeCode', TZUGFeRDReferenceTypeCodesExtensions.EnumToString(document.ReferenceTypeCode));
        end;

        Writer.WriteOptionalElementString('ram:Name', document.Name);

        if (document.AttachmentBinaryObject <> nil) then
        begin
          Writer.WriteStartElement('ram:AttachmentBinaryObject');
          Writer.WriteAttributeString('filename', document.Filename);
          Writer.WriteAttributeString('mimeCode', TZUGFeRDMimeTypeMapper.GetMimeType(document.Filename));
          Writer.WriteValue(TZUGFeRDHelper.GetDataAsBase64(document.AttachmentBinaryObject));
          Writer.WriteEndElement(); // !AttachmentBinaryObject()
        end;

        if (document.IssueDateTime.HasValue) then
        begin
          Writer.WriteStartElement('ram:FormattedIssueDateTime');
          Writer.WriteStartElement('qdt:DateTimeString');
          Writer.WriteAttributeString('format', '102');
          Writer.WriteValue(_formatDate(document.IssueDateTime.Value));
          Writer.WriteEndElement(); // !qdt:DateTimeString
          Writer.WriteEndElement(); // !ram:FormattedIssueDateTime
        end;

        Writer.WriteEndElement(); // !ram:AdditionalReferencedDocument
      end;
    end;
    //#endregion

    //#region SpecifiedProcuringProject
    if (Descriptor.SpecifiedProcuringProject <> nil) then
    begin
      Writer.WriteStartElement('ram:SpecifiedProcuringProject', [TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]);
      Writer.WriteElementString('ram:ID', Descriptor.SpecifiedProcuringProject.ID, [TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]);
      Writer.WriteElementString('ram:Name', Descriptor.SpecifiedProcuringProject.Name, [TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]);
      Writer.WriteEndElement(); // !ram:SpecifiedProcuringProject
    end;
    //#endregion

    Writer.WriteEndElement(); // !ApplicableHeaderTradeAgreement
    //#endregion

    //#region ApplicableHeaderTradeDelivery
    Writer.WriteStartElement('ram:ApplicableHeaderTradeDelivery'); // Pflichteintrag
    _writeOptionalParty(Writer, TZUGFeRDPartyTypes.ShipToTradeParty, Descriptor.ShipTo);
    //ToDo: UltimateShipToTradeParty
    _writeOptionalParty(Writer, TZUGFeRDPartyTypes.ShipFromTradeParty, Descriptor.ShipFrom); // ShipFrom shall not be written in XRechnung profiles

    //#region ActualDeliverySupplyChainEvent
    if (Descriptor.ActualDeliveryDate.HasValue) then
    begin
      Writer.WriteStartElement('ram:ActualDeliverySupplyChainEvent');
      Writer.WriteStartElement('ram:OccurrenceDateTime');
      Writer.WriteStartElement('udt:DateTimeString');
      Writer.WriteAttributeString('format', '102');
      Writer.WriteValue(_formatDate(Descriptor.ActualDeliveryDate.Value));
      Writer.WriteEndElement(); // 'udt:DateTimeString
      Writer.WriteEndElement(); // !OccurrenceDateTime()
      Writer.WriteEndElement(); // !ActualDeliverySupplyChainEvent
    end;
    //#endregion

    //#region DespatchAdviceReferencedDocument
    if (Descriptor.DespatchAdviceReferencedDocument <> nil) then
    begin
      Writer.WriteStartElement('ram:DespatchAdviceReferencedDocument');
      Writer.WriteElementString('ram:IssuerAssignedID', Descriptor.DespatchAdviceReferencedDocument.ID);

      if (Descriptor.DespatchAdviceReferencedDocument.IssueDateTime.HasValue) then
      begin
        Writer.WriteStartElement('ram:FormattedIssueDateTime');
        Writer.WriteStartElement('qdt:DateTimeString');
        Writer.WriteAttributeString('format', '102');
        Writer.WriteValue(_formatDate(Descriptor.DespatchAdviceReferencedDocument.IssueDateTime.Value));
        Writer.WriteEndElement(); // "qdt:DateTimeString
        Writer.WriteEndElement(); // !ram:FormattedIssueDateTime
      end;

      Writer.WriteEndElement(); // !DespatchAdviceReferencedDocument
    end;
    //#endregion

    //#region DeliveryNoteReferencedDocument
    if (Descriptor.DeliveryNoteReferencedDocument <> nil) then
    begin
      Writer.WriteStartElement('ram:DeliveryNoteReferencedDocument');
      Writer.WriteElementString('ram:IssuerAssignedID', Descriptor.DeliveryNoteReferencedDocument.ID);

      if (Descriptor.DeliveryNoteReferencedDocument.IssueDateTime.HasValue) then
      begin
        Writer.WriteStartElement('ram:FormattedIssueDateTime', ALL_PROFILES  - [TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]);
        Writer.WriteStartElement('qdt:DateTimeString');
        Writer.WriteAttributeString('format', '102');
        Writer.WriteValue(_formatDate(Descriptor.DeliveryNoteReferencedDocument.IssueDateTime.Value));
        Writer.WriteEndElement(); // 'qdt:DateTimeString
        Writer.WriteEndElement(); // !ram:FormattedIssueDateTime
      end;

      Writer.WriteEndElement(); // !DeliveryNoteReferencedDocument
    end;
    //#endregion

    Writer.WriteEndElement(); // !ApplicableHeaderTradeDelivery
    //#endregion

    //#region ApplicableHeaderTradeSettlement
    Writer.WriteStartElement('ram:ApplicableHeaderTradeSettlement');
    // order of sub-elements of ApplicableHeaderTradeSettlement:
    //   1. CreditorReferenceID (optional)
    //   2. PaymentReference (optional)
    //   3. TaxCurrencyCode (optional)
    //   4. InvoiceCurrencyCode (optional)
    //   5. InvoiceIssuerReference (optional)
    //   6. InvoicerTradeParty (optional)
    //   7. InvoiceeTradeParty (optional)
    //   8. PayeeTradeParty (optional)
    //   9. TaxApplicableTradeCurrencyExchange (optional)
    //  10. SpecifiedTradeSettlementPaymentMeans (optional)
    //  11. ApplicableTradeTax (optional)
    //  12. BillingSpecifiedPeriod (optional)
    //  13. SpecifiedTradeAllowanceCharge (optional)
    //  14. SpecifiedLogisticsServiceCharge (optional)
    //  15. SpecifiedTradePaymentTerms (optional)
    //  16. SpecifiedTradeSettlementHeaderMonetarySummation
    //  17. InvoiceReferencedDocument (optional)
    //  18. ReceivableSpecifiedTradeAccountingAccount (optional)
    //  19. SpecifiedAdvancePayment (optional)

    //   1. CreditorReferenceID (optional)
    if Descriptor.PaymentMeans <> nil then
    if (Descriptor.PaymentMeans.SEPACreditorIdentifier<>'') then
    begin
      Writer.WriteOptionalElementString('ram:CreditorReferenceID', Descriptor.PaymentMeans.SEPACreditorIdentifier, [TZUGFeRDProfile.BasicWL,TZUGFeRDProfile.Basic,TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung,TZUGFeRDProfile.XRechnung1]);
    end;

    //   2. PaymentReference (optional)
    Writer.WriteOptionalElementString('ram:PaymentReference', Descriptor.PaymentReference);

    //   3. TaxCurrencyCode (optional)
    //   BT-6
    if (Descriptor.TaxCurrency <> TZUGFeRDCurrencyCodes.Unknown) then
      Writer.WriteElementString('ram:TaxCurrencyCode', TZUGFerdCurrencyCodesExtensions.EnumToString(
        Descriptor.TaxCurrency), [TZUGFeRDProfile.Comfort, TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung1,
          TZUGFeRDProfile.XRechnung]);

    //   4. InvoiceCurrencyCode (optional)
    Writer.WriteElementString('ram:InvoiceCurrencyCode', TZUGFeRDCurrencyCodesExtensions.EnumToString(Descriptor.Currency));

	  //   5. InvoiceIssuerReference (optional)
		Writer.WriteElementString('ram:InvoiceIssuerReference', Descriptor.SellerReferenceNo,
      [TZUGFeRDProfile.Extended]);

	  //   6. InvoicerTradeParty (optional)
		_writeOptionalParty(Writer, TZUGFeRDPartyTypes.InvoicerTradeParty, Descriptor.Invoicer);

    //   7. InvoiceeTradeParty (optional)
    _writeOptionalParty(Writer, TZUGFeRDPartyTypes.InvoiceeTradeParty, Descriptor.Invoicee);

    //   8. PayeeTradeParty (optional)
    _writeOptionalParty(Writer, TZUGFeRDPartyTypes.PayeeTradeParty, Descriptor.Payee);

    //#region SpecifiedTradeSettlementPaymentMeans
    //  10. SpecifiedTradeSettlementPaymentMeans (optional)

    if (Descriptor.CreditorBankAccounts.Count = 0) and (Descriptor.DebitorBankAccounts.Count = 0) then
    begin
      if (Descriptor.PaymentMeans <> nil) then
      if (Descriptor.PaymentMeans.TypeCode <> TZUGFeRDPaymentMeansTypeCodes.Unknown) then
      begin
        Writer.WriteStartElement('ram:SpecifiedTradeSettlementPaymentMeans', [TZUGFeRDProfile.BasicWL,TZUGFeRDProfile.Basic,TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung,TZUGFeRDProfile.XRechnung1]);
        Writer.WriteElementString('ram:TypeCode', TZUGFeRDPaymentMeansTypeCodesExtensions.EnumToString(Descriptor.PaymentMeans.TypeCode));
        Writer.WriteOptionalElementString('ram:Information', Descriptor.PaymentMeans.Information);

        if (Descriptor.PaymentMeans.FinancialCard <> nil) then
        begin
          Writer.WriteStartElement('ram:ApplicableTradeSettlementFinancialCard', [TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung]);
          Writer.WriteOptionalElementString('ram:ID', Descriptor.PaymentMeans.FinancialCard.Id);
          Writer.WriteOptionalElementString('ram:CardholderName', Descriptor.PaymentMeans.FinancialCard.CardholderName);
          Writer.WriteEndElement(); // !ram:ApplicableTradeSettlementFinancialCard
        end;
        Writer.WriteEndElement(); // !SpecifiedTradeSettlementPaymentMeans
      end;
    end
    else
    begin
      for var creditorAccount : TZUGFeRDBankAccount in Descriptor.CreditorBankAccounts do
      begin
        Writer.WriteStartElement('ram:SpecifiedTradeSettlementPaymentMeans');

        if (Descriptor.PaymentMeans <> nil) then
        if (Descriptor.PaymentMeans.TypeCode <> TZUGFeRDPaymentMeansTypeCodes.Unknown) then
        begin
          Writer.WriteElementString('ram:TypeCode', TZUGFeRDPaymentMeansTypeCodesExtensions.EnumToString(Descriptor.PaymentMeans.TypeCode));
          Writer.WriteOptionalElementString('ram:Information', Descriptor.PaymentMeans.Information);

          if (Descriptor.PaymentMeans.FinancialCard <> nil) then
          begin
              Writer.WriteStartElement('ram:ApplicableTradeSettlementFinancialCard', [TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung]);
              Writer.WriteOptionalElementString('ram:ID', Descriptor.PaymentMeans.FinancialCard.Id);
              Writer.WriteOptionalElementString('ram:CardholderName', Descriptor.PaymentMeans.FinancialCard.CardholderName);
              Writer.WriteEndElement(); // !ram:ApplicableTradeSettlementFinancialCard
          end;
        end;

        Writer.WriteStartElement('ram:PayeePartyCreditorFinancialAccount');
        Writer.WriteElementString('ram:IBANID', creditorAccount.IBAN);
        Writer.WriteOptionalElementString('ram:AccountName', creditorAccount.Name);
        Writer.WriteOptionalElementString('ram:ProprietaryID', creditorAccount.ID);
        Writer.WriteEndElement(); // !PayeePartyCreditorFinancialAccount

        if (creditorAccount.BIC<>'') then
        begin
          Writer.WriteStartElement('ram:PayeeSpecifiedCreditorFinancialInstitution');
          Writer.WriteElementString('ram:BICID', creditorAccount.BIC);
          Writer.WriteEndElement(); // !PayeeSpecifiedCreditorFinancialInstitution
        end;

        Writer.WriteEndElement(); // !SpecifiedTradeSettlementPaymentMeans
      end;

      for var debitorAccount : TZUGFeRDBankAccount in Descriptor.DebitorBankAccounts do
      begin
        Writer.WriteStartElement('ram:SpecifiedTradeSettlementPaymentMeans'); // BG-16

        if (Descriptor.PaymentMeans <> nil) then
        if (Descriptor.PaymentMeans.TypeCode <> TZUGFeRDPaymentMeansTypeCodes.Unknown) then
        begin
          Writer.WriteElementString('ram:TypeCode', TZUGFeRDPaymentMeansTypeCodesExtensions.EnumToString(Descriptor.PaymentMeans.TypeCode));
          Writer.WriteOptionalElementString('ram:Information', Descriptor.PaymentMeans.Information);
        end;

        Writer.WriteStartElement('ram:PayerPartyDebtorFinancialAccount');
        Writer.WriteElementString('ram:IBANID', debitorAccount.IBAN);
        Writer.WriteOptionalElementString('ram:AccountName', debitorAccount.Name);
        Writer.WriteOptionalElementString('ram:ProprietaryID', debitorAccount.ID);
        Writer.WriteEndElement(); // !PayerPartyDebtorFinancialAccount

        if (debitorAccount.BIC<>'') then
        begin
          Writer.WriteStartElement('ram:PayerSpecifiedDebtorFinancialInstitution');
          Writer.WriteElementString('ram:BICID', debitorAccount.BIC);
          Writer.WriteEndElement(); // !PayerSpecifiedDebtorFinancialInstitution
        end;

        Writer.WriteEndElement(); // !SpecifiedTradeSettlementPaymentMeans
      end;
    end;
    //#endregion

    //#region ApplicableTradeTax
    //  11. ApplicableTradeTax (optional)
    _writeOptionalTaxes(Writer);
    //#endregion

    //#region BillingSpecifiedPeriod
    //  12. BillingSpecifiedPeriod (optional)
    if (Descriptor.BillingPeriodStart.HasValue) or (Descriptor.BillingPeriodEnd.HasValue) then
    begin
      Writer.WriteStartElement('ram:BillingSpecifiedPeriod', [TZUGFeRDProfile.BasicWL,TZUGFeRDProfile.Basic,TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung,TZUGFeRDProfile.XRechnung1]);
      if (Descriptor.BillingPeriodStart.HasValue) then
      begin
          Writer.WriteStartElement('ram:StartDateTime');
          _writeElementWithAttribute(Writer, 'udt:DateTimeString', 'format', '102', _formatDate(Descriptor.BillingPeriodStart));
          Writer.WriteEndElement(); // !StartDateTime
      end;

      if (Descriptor.BillingPeriodEnd.HasValue) then
      begin
          Writer.WriteStartElement('ram:EndDateTime');
          _writeElementWithAttribute(Writer, 'udt:DateTimeString', 'format', '102', _formatDate(Descriptor.BillingPeriodEnd));
          Writer.WriteEndElement(); // !EndDateTime
      end;
      Writer.WriteEndElement(); // !BillingSpecifiedPeriod
    end;
    //#endregion

    //13. SpecifiedTradeAllowanceCharge (optional)
    for var tradeAllowanceCharge : TZUGFeRDTradeAllowanceCharge in Descriptor.TradeAllowanceCharges do
    begin
      Writer.WriteStartElement('ram:SpecifiedTradeAllowanceCharge');
      Writer.WriteStartElement('ram:ChargeIndicator');
      Writer.WriteElementString('udt:Indicator', ifthen(tradeAllowanceCharge.ChargeIndicator,'true','false'));
      Writer.WriteEndElement(); // !ram:ChargeIndicator

      if (tradeAllowanceCharge.ChargePercentage <> 0.0) then
      begin
        Writer.WriteStartElement('ram:CalculationPercent', [TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung,TZUGFeRDProfile.XRechnung1]);
        Writer.WriteValue(_formatDecimal(_asNullableParam<Currency>(tradeAllowanceCharge.ChargePercentage)));
        Writer.WriteEndElement();
      end;

      if (tradeAllowanceCharge.BasisAmount <> 0.0) then
      begin
        Writer.WriteStartElement('ram:BasisAmount', [TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung,TZUGFeRDProfile.XRechnung1]);
        Writer.WriteValue(_formatDecimal(_asNullableParam<Currency>(tradeAllowanceCharge.BasisAmount)));
        Writer.WriteEndElement();
      end;

      Writer.WriteStartElement('ram:ActualAmount');
      Writer.WriteValue(_formatDecimal(_asNullableParam<Currency>(tradeAllowanceCharge.ActualAmount)));
      Writer.WriteEndElement();

      if tradeAllowanceCharge.ChargeIndicator then
      begin
        Writer.WriteOptionalElementString('ram:ReasonCode',
           TZUGFeRDSpecialServiceDescriptionCodesExtensions.EnumToString(
                                     tradeAllowanceCharge.ReasonCodeCharge));
      end else
      begin
        Writer.WriteOptionalElementString('ram:ReasonCode',
           TZUGFeRDAllowanceOrChargeIdentificationCodesExtensions.EnumToString(
                                     tradeAllowanceCharge.ReasonCodeAllowance));
      end;

      Writer.WriteOptionalElementString('ram:Reason', tradeAllowanceCharge.Reason);

      if (tradeAllowanceCharge.Tax <> nil) then
      begin
        Writer.WriteStartElement('ram:CategoryTradeTax');
        Writer.WriteElementString('ram:TypeCode', TZUGFeRDTaxTypesExtensions.EnumToString(tradeAllowanceCharge.Tax.TypeCode));
        if (tradeAllowanceCharge.Tax.CategoryCode <> TZUGFeRDTaxCategoryCodes.Unknown) then
          Writer.WriteElementString('ram:CategoryCode', TZUGFeRDTaxCategoryCodesExtensions.EnumToString(tradeAllowanceCharge.Tax.CategoryCode));
        Writer.WriteElementString('ram:RateApplicablePercent', _formatDecimal(_asNullableParam<Currency>(tradeAllowanceCharge.Tax.Percent)));
        Writer.WriteEndElement();
      end;
      Writer.WriteEndElement();
    end;

    //  14. SpecifiedLogisticsServiceCharge (optional)
    for var serviceCharge : TZUGFeRDServiceCharge in Descriptor.ServiceCharges do
    begin
      Writer.WriteStartElement('ram:SpecifiedLogisticsServiceCharge', ALL_PROFILES  - [TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]);
      Writer.WriteOptionalElementString('ram:Description', serviceCharge.Description);
      Writer.WriteElementString('ram:AppliedAmount', _formatDecimal(_asNullableParam<Currency>(serviceCharge.Amount)));
      if (serviceCharge.Tax <> nil) then
      begin
        Writer.WriteStartElement('ram:AppliedTradeTax');
        Writer.WriteElementString('ram:TypeCode', TZUGFeRDTaxTypesExtensions.EnumToString(serviceCharge.Tax.TypeCode));
        if (serviceCharge.Tax.CategoryCode <> TZUGFeRDTaxCategoryCodes.Unknown) then
          Writer.WriteElementString('ram:CategoryCode', TZUGFeRDTaxCategoryCodesExtensions.EnumToString(serviceCharge.Tax.CategoryCode));
        Writer.WriteElementString('ram:RateApplicablePercent', _formatDecimal(_asNullableParam<Currency>(serviceCharge.Tax.Percent)));
        Writer.WriteEndElement();
      end;
      Writer.WriteEndElement();
    end;

    //  15. SpecifiedTradePaymentTerms (optional)
    for var PaymentTerms: TZUGFeRDPaymentTerms in Descriptor.PaymentTermsList do
    begin
      Writer.WriteStartElement('ram:SpecifiedTradePaymentTerms');
      Writer.WriteOptionalElementString('ram:Description', PaymentTerms.Description);
      if (PaymentTerms.DueDate.HasValue) then
      begin
        Writer.WriteStartElement('ram:DueDateDateTime');
        _writeElementWithAttribute(Writer, 'udt:DateTimeString', 'format', '102', _formatDate(PaymentTerms.DueDate.Value));
        Writer.WriteEndElement(); // !ram:DueDateDateTime
      end;
      Writer.WriteOptionalElementString('ram:DirectDebitMandateID', Descriptor.PaymentMeans.SEPAMandateReference);
      Writer.WriteEndElement();
    end;

    //#region SpecifiedTradeSettlementHeaderMonetarySummation
    //  16. SpecifiedTradeSettlementHeaderMonetarySummation
    //Gesamtsummen auf Dokumentenebene
    Writer.WriteStartElement('ram:SpecifiedTradeSettlementHeaderMonetarySummation');
    _writeOptionalAmount(Writer, 'ram:LineTotalAmount', Descriptor.LineTotalAmount);                                  // Summe der Nettobetr�ge aller Rechnungspositionen
    _writeOptionalAmount(Writer, 'ram:ChargeTotalAmount', Descriptor.ChargeTotalAmount);                              // Summe der Zuschl�ge auf Dokumentenebene
    _writeOptionalAmount(Writer, 'ram:AllowanceTotalAmount', Descriptor.AllowanceTotalAmount);                        // Summe der Abschl�ge auf Dokumentenebene

    if (Descriptor.Profile = TZUGFeRDProfile.Extended) then
    begin
      // there shall be no currency for tax basis total amount, see
      // https://github.com/stephanstapel/ZUGFeRD-csharp/issues/56#issuecomment-655525467
      _writeOptionalAmount(Writer, 'ram:TaxBasisTotalAmount', Descriptor.TaxBasisAmount, 2,false);   // Rechnungsgesamtbetrag ohne Umsatzsteuer
    end
    else
    begin
      _writeOptionalAmount(Writer, 'ram:TaxBasisTotalAmount', Descriptor.TaxBasisAmount);   // Rechnungsgesamtbetrag ohne Umsatzsteuer
    end;
    _writeOptionalAmount(Writer, 'ram:TaxTotalAmount', Descriptor.TaxTotalAmount, 2, true);               // Gesamtbetrag der Rechnungsumsatzsteuer, Steuergesamtbetrag in Buchungsw�hrung
    _writeOptionalAmount(Writer, 'ram:RoundingAmount', Descriptor.RoundingAmount, 2, false,[TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]);  // RoundingAmount  //Rundungsbetrag
    _writeOptionalAmount(Writer, 'ram:GrandTotalAmount', Descriptor.GrandTotalAmount);                                // Rechnungsgesamtbetrag einschlie�lich Umsatzsteuer
    _writeOptionalAmount(Writer, 'ram:TotalPrepaidAmount', Descriptor.TotalPrepaidAmount);                            // Vorauszahlungsbetrag
    _writeOptionalAmount(Writer, 'ram:DuePayableAmount', Descriptor.DuePayableAmount);                                // F�lliger Zahlungsbetrag
    Writer.WriteEndElement(); // !ram:SpecifiedTradeSettlementMonetarySummation
    //#endregion

    //#region InvoiceReferencedDocument
    if (Descriptor.InvoiceReferencedDocument <> nil) then
    begin
      Writer.WriteStartElement('ram:InvoiceReferencedDocument');
      Writer.WriteOptionalElementString('ram:IssuerAssignedID', Descriptor.InvoiceReferencedDocument.ID);
      if (Descriptor.InvoiceReferencedDocument.IssueDateTime.HasValue) then
      begin
        Writer.WriteStartElement('ram:FormattedIssueDateTime');
        _writeElementWithAttribute(Writer, 'qdt:DateTimeString', 'format', '102', _formatDate(Descriptor.InvoiceReferencedDocument.IssueDateTime.Value));
        Writer.WriteEndElement(); // !ram:FormattedIssueDateTime
      end;
      Writer.WriteEndElement(); // !ram:InvoiceReferencedDocument
    end;
    //#endregion

    //#region ReceivableSpecifiedTradeAccountingAccount
    if (Descriptor.ReceivableSpecifiedTradeAccountingAccounts <> nil) then
    if (Descriptor.ReceivableSpecifiedTradeAccountingAccounts.Count > 0) then
    begin
      if (descriptor.Profile = TZUGFeRDProfile.XRechnung1) or (descriptor.Profile = TZUGFeRDProfile.XRechnung) then
      begin
        if (Descriptor.ReceivableSpecifiedTradeAccountingAccounts[0].TradeAccountID<>'') then
        begin
          Writer.WriteStartElement('ram:ReceivableSpecifiedTradeAccountingAccount');
          begin
            //BT-19
            Writer.WriteStartElement('ram:ID');
            Writer.WriteValue(Descriptor.ReceivableSpecifiedTradeAccountingAccounts[0].TradeAccountID);
            Writer.WriteEndElement(); // !ram:ID
          end;
          Writer.WriteEndElement(); // !ram:ReceivableSpecifiedTradeAccountingAccount
        end;
      end
      else
      begin
        for var RSTAA : TZUGFeRDReceivableSpecifiedTradeAccountingAccount in Descriptor.ReceivableSpecifiedTradeAccountingAccounts do
        begin
          Writer.WriteStartElement('ram:ReceivableSpecifiedTradeAccountingAccount', [TZUGFeRDProfile.BasicWL,TZUGFeRDProfile.Basic,TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended]);

          //BT-19
          Writer.WriteStartElement('ram:ID', [TZUGFeRDProfile.BasicWL,TZUGFeRDProfile.Basic,TZUGFeRDProfile.Comfort,TZUGFeRDProfile.Extended]);
          Writer.WriteValue(RSTAA.TradeAccountID);
          Writer.WriteEndElement(); // !ram:ID

          if (RSTAA.TradeAccountTypeCode <> TZUGFeRDAccountingAccountTypeCodes.Unknown) then
          begin
            Writer.WriteStartElement('ram:TypeCode', [TZUGFeRDProfile.Extended]);
            Writer.WriteValue(Integer(RSTAA.TradeAccountTypeCode).ToString);
            Writer.WriteEndElement(); // !ram:TypeCode
          end;

          Writer.WriteEndElement(); // !ram:ReceivableSpecifiedTradeAccountingAccount
        end;
      end;
    end;
    //#endregion
    Writer.WriteEndElement(); // !ram:ApplicableHeaderTradeSettlement

    //#endregion

    Writer.WriteEndElement(); // !ram:SpecifiedSupplyChainTradeTransaction
    //#endregion

    Writer.WriteEndElement(); // !ram:Invoice
    Writer.WriteEndDocument();
    Writer.Flush();

    _stream.Seek(streamPosition, soFromBeginning);
  finally
    Writer.Free;
  end;
end;

function TZUGFeRDInvoiceDescriptor22CIIWriter.Validate(descriptor: TZUGFeRDInvoiceDescriptor;
  throwExceptions: Boolean): Boolean;
begin
  result := False;
end;

function TZUGFeRDInvoiceDescriptor22CIIWriter._encodeInvoiceType(
  type_: TZUGFeRDInvoiceType): Integer;
begin
  if (Integer(type_) > 1000) then
    type_ := TZUGFeRDInvoiceType(Integer(type_)-1000);

  case type_ of
    TZUGFeRDInvoiceType.CorrectionOld: Result := Integer(TZUGFeRDInvoiceType.Correction);
    else Result := Integer(type_);
  end;
end;

function TZUGFeRDInvoiceDescriptor22CIIWriter._translateInvoiceType(
  type_: TZUGFeRDInvoiceType): String;
begin
  case type_ of
    SelfBilledInvoice,
    Invoice: Result := 'RECHNUNG';
    SelfBilledCreditNote,
    CreditNote: Result := 'GUTSCHRIFT';
    DebitNote: Result := 'BELASTUNGSANZEIGE';
    DebitnoteRelatedToFinancialAdjustments: Result := 'WERTBELASTUNG';
    PartialInvoice: Result := 'TEILRECHNUNG';
    PrepaymentInvoice: Result := 'VORAUSZAHLUNGSRECHNUNG';
    InvoiceInformation: Result := 'KEINERECHNUNG';
    Correction,
    CorrectionOld: Result := 'KORREKTURRECHNUNG';
    else Result := '';
  end;
end;

function TZUGFeRDInvoiceDescriptor22CIIWriter._translateTaxCategoryCode(
  taxCategoryCode: TZUGFeRDTaxCategoryCodes): String;
begin
  Result := '';
  case taxCategoryCode of
    TZUGFeRDTaxCategoryCodes.A :;
    TZUGFeRDTaxCategoryCodes.AA :;
    TZUGFeRDTaxCategoryCodes.AB :;
    TZUGFeRDTaxCategoryCodes.AC :;
    TZUGFeRDTaxCategoryCodes.AD :;
    TZUGFeRDTaxCategoryCodes.AE : Result := 'Umkehrung der Steuerschuldnerschaft';
    TZUGFeRDTaxCategoryCodes.B: ;
    TZUGFeRDTaxCategoryCodes.C: ;
    TZUGFeRDTaxCategoryCodes.E: Result := 'steuerbefreit';
    TZUGFeRDTaxCategoryCodes.G: Result := 'freier Ausfuhrartikel, Steuer nicht erhoben';
    TZUGFeRDTaxCategoryCodes.H: ;
    TZUGFeRDTaxCategoryCodes.O: Result := 'Dienstleistungen au�erhalb des Steueranwendungsbereichs';
    TZUGFeRDTaxCategoryCodes.S: Result := 'Normalsatz';
    TZUGFeRDTaxCategoryCodes.Z: Result := 'nach dem Nullsatz zu versteuernde Waren';
    TZUGFeRDTaxCategoryCodes.Unknown: ;
    TZUGFeRDTaxCategoryCodes.D: ;
    TZUGFeRDTaxCategoryCodes.F: ;
    TZUGFeRDTaxCategoryCodes.I: ;
    TZUGFeRDTaxCategoryCodes.J: ;
    TZUGFeRDTaxCategoryCodes.K: Result := 'Kein Ausweis der Umsatzsteuer bei innergemeinschaftlichen Lieferungen';
    TZUGFeRDTaxCategoryCodes.L: Result := 'IGIC (Kanarische Inseln)';
    TZUGFeRDTaxCategoryCodes.M: Result := 'IPSI (Ceuta/Melilla)';
  end;
end;

procedure TZUGFeRDInvoiceDescriptor22CIIWriter._writeElementWithAttribute(
  _writer: TZUGFeRDProfileAwareXmlTextWriter; tagName, attributeName, attributeValue,
  nodeValue: String; profile: TZUGFeRDProfiles);
begin
  _writer.WriteStartElement(tagName,profile);
  _writer.WriteAttributeString(attributeName, attributeValue);
  _writer.WriteValue(nodeValue);
  _writer.WriteEndElement(); // !tagName
end;

procedure TZUGFeRDInvoiceDescriptor22CIIWriter._writeNotes(
  _writer: TZUGFeRDProfileAwareXmlTextWriter; notes: TObjectList<TZUGFeRDNote>);
begin
  if notes.Count = 0 then
    exit;

  for var note : TZUGFeRDNote in notes do
  begin
    _writer.WriteStartElement('ram:IncludedNote');
    if (note.ContentCode <> TZUGFeRDContentCodes.Unknown) then
      _writer.WriteElementString('ram:ContentCode', TZUGFeRDContentCodesExtensions.EnumToString(note.ContentCode));
    _writer.WriteElementString('ram:Content', note.Content);
    if (note.SubjectCode <> TZUGFeRDSubjectCodes.Unknown) then
      _writer.WriteElementString('ram:SubjectCode', TZUGFeRDSubjectCodesExtensions.EnumToString(note.SubjectCode));
    _writer.WriteEndElement();
  end;
end;

procedure TZUGFeRDInvoiceDescriptor22CIIWriter._writeOptionalAmount(
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

procedure TZUGFeRDInvoiceDescriptor22CIIWriter._writeOptionalContact(
  _writer: TZUGFeRDProfileAwareXmlTextWriter; contactTag: String; contact: TZUGFeRDContact;
  profile: TZUGFeRDProfiles);
begin
  if contact = nil then
    exit;

  _writer.WriteStartElement(contactTag,profile);

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
    _writer.WriteStartElement('ram:FaxUniversalCommunication',ALL_PROFILES - [TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]);
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

procedure TZUGFeRDInvoiceDescriptor22CIIWriter._writeOptionalLegalOrganization(
  _writer: TZUGFeRDProfileAwareXmlTextWriter; legalOrganizationTag: String;
  legalOrganization: TZUGFeRDLegalOrganization; partyType: TZUGFeRDPartyTypes);
begin
  if (legalOrganization = nil) then
    exit;

  case partyType of
    TZUGFeRDPartyTypes.Unknown: ;
    TZUGFeRDPartyTypes.SellerTradeParty: ; // all profiles
    TZUGFeRDPartyTypes.BuyerTradeParty: ; // all profiles
    TZUGFeRDPartyTypes.ShipToTradeParty:
      if (Descriptor.Profile <> TZUGFeRDProfile.Extended) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung1) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung) then
           exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.UltimateShipToTradeParty:
      if (Descriptor.Profile <> TZUGFeRDProfile.Extended) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung1) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung) then
           exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.ShipFromTradeParty:
      if (Descriptor.Profile <> TZUGFeRDProfile.Extended) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung1) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung) then
           exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.InvoiceeTradeParty:
      if (Descriptor.Profile <> TZUGFeRDProfile.Extended) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung1) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung) then
           exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.PayeeTradeParty: ; // all profiles
    TZUGFeRDPartyTypes.SalesAgentTradeParty:
      if (Descriptor.Profile <> TZUGFeRDProfile.Extended) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung1) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung) then
           exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.BuyerTaxRepresentativeTradeParty:
      if (Descriptor.Profile <> TZUGFeRDProfile.Extended) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung1) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung) then
           exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.ProductEndUserTradeParty:
      if (Descriptor.Profile <> TZUGFeRDProfile.Extended) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung1) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung) then
           exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.BuyerAgentTradeParty:
      if (Descriptor.Profile <> TZUGFeRDProfile.Extended) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung1) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung) then
           exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.InvoicerTradeParty:
      if (Descriptor.Profile <> TZUGFeRDProfile.Extended) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung1) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung) then
           exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.PayerTradeParty:
      if (Descriptor.Profile <> TZUGFeRDProfile.Extended) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung1) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung) then
           exit; // extended, XRechnung1, XRechnung profile only
    else exit;
  end;

  writer.WriteStartElement(legalOrganizationTag, [Descriptor.Profile]);
  if (legalOrganization.ID <> nil) then
  begin
    if (legalOrganization.ID.ID <> '') and (TZUGFeRDGlobalIDSchemeIdentifiersExtensions.EnumToString(legalOrganization.ID.SchemeID)<> '') then
    begin
      writer.WriteStartElement('ram:ID');
      writer.WriteAttributeString('schemeID', TZUGFeRDGlobalIDSchemeIdentifiersExtensions.EnumToString(legalOrganization.ID.SchemeID));
      writer.WriteValue(legalOrganization.ID.ID);
      writer.WriteEndElement();
    end
    else
    begin
      writer.WriteElementString('ram:ID', legalOrganization.ID.ID);
    end;
    // filter according to https://github.com/stephanstapel/ZUGFeRD-csharp/pull/221
    if (((partyType = TZUGFeRDPartyTypes.SellerTradeParty) and (Descriptor.Profile <> TZUGFeRDProfile.Minimum)) or
        ((partyType = TZUGFeRDPartyTypes.PayeeTradeParty) and (Descriptor.Profile <> TZUGFeRDProfile.Minimum)) or
        ((partyType = TZUGFeRDPartyTypes.BuyerTradeParty) and (Descriptor.Profile <> TZUGFeRDProfile.Minimum)) or
         (Descriptor.Profile = TZUGFeRDProfile.Extended) // remaining party types
       ) then
    begin
      writer.WriteOptionalElementString('ram:TradingBusinessName', legalOrganization.TradingBusinessName, [Descriptor.Profile]);
    end;
  end;
  writer.WriteEndElement();
end;

procedure TZUGFeRDInvoiceDescriptor22CIIWriter._writeOptionalParty(
  _writer: TZUGFeRDProfileAwareXmlTextWriter; partyType: TZUGFeRDPartyTypes; party: TZUGFeRDParty;
  contact: TZUGFeRDContact; electronicAddress: TZUGFeRDElectronicAddress;
  taxRegistrations: TObjectList<TZUGFeRDTaxRegistration>);
begin
  // filter according to https://github.com/stephanstapel/ZUGFeRD-csharp/pull/221

  case partyType of
    TZUGFeRDPartyTypes.Unknown: exit;
    TZUGFeRDPartyTypes.SellerTradeParty: ;
    TZUGFeRDPartyTypes.BuyerTradeParty: ;
    TZUGFeRDPartyTypes.ShipToTradeParty:
      if (Descriptor.Profile <> TZUGFeRDProfile.Extended) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung1) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung) then
           exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.UltimateShipToTradeParty:
      if (Descriptor.Profile <> TZUGFeRDProfile.Extended) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung1) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung) then
           exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.ShipFromTradeParty:
      if (Descriptor.Profile <> TZUGFeRDProfile.Extended) then
           exit; // extended profile only
    TZUGFeRDPartyTypes.InvoiceeTradeParty:
      if (Descriptor.Profile <> TZUGFeRDProfile.Extended) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung1) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung) then
           exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.PayeeTradeParty:
      if (Descriptor.Profile = TZUGFeRDProfile.Minimum) then
            exit; // party is written for all profiles but minimum
    TZUGFeRDPartyTypes.SalesAgentTradeParty:
      if (Descriptor.Profile <> TZUGFeRDProfile.Extended) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung1) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung) then
           exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.BuyerTaxRepresentativeTradeParty:
      if (Descriptor.Profile <> TZUGFeRDProfile.Extended) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung1) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung) then
           exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.ProductEndUserTradeParty:
      if (Descriptor.Profile <> TZUGFeRDProfile.Extended) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung1) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung) then
           exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.BuyerAgentTradeParty:
      if (Descriptor.Profile <> TZUGFeRDProfile.Extended) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung1) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung) then
           exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.InvoicerTradeParty:
      if (Descriptor.Profile <> TZUGFeRDProfile.Extended) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung1) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung) then
           exit; // extended, XRechnung1, XRechnung profile only
    TZUGFeRDPartyTypes.PayerTradeParty:
      if (Descriptor.Profile <> TZUGFeRDProfile.Extended) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung1) and
         (Descriptor.Profile <> TZUGFeRDProfile.XRechnung) then
           exit; // extended, XRechnung1, XRechnung profile only
    else exit;
  end;

  if (party = nil) then
    exit;

  case partyType of
    TZUGFeRDPartyTypes.SellerTradeParty:
      writer.WriteStartElement('ram:SellerTradeParty', [Descriptor.Profile]);
    TZUGFeRDPartyTypes.BuyerTradeParty:
      writer.WriteStartElement('ram:BuyerTradeParty', [Descriptor.Profile]);
    TZUGFeRDPartyTypes.ShipToTradeParty:
      writer.WriteStartElement('ram:ShipToTradeParty', [Descriptor.Profile]);
    TZUGFeRDPartyTypes.UltimateShipToTradeParty:
      writer.WriteStartElement('ram:UltimateShipToTradeParty', [Descriptor.Profile]);
    TZUGFeRDPartyTypes.ShipFromTradeParty:
      writer.WriteStartElement('ram:ShipFromTradeParty', [Descriptor.Profile]);
    TZUGFeRDPartyTypes.InvoiceeTradeParty:
      writer.WriteStartElement('ram:InvoiceeTradeParty', [Descriptor.Profile]);
    TZUGFeRDPartyTypes.PayeeTradeParty:
      writer.WriteStartElement('ram:PayeeTradeParty', [Descriptor.Profile]);
    TZUGFeRDPartyTypes.SalesAgentTradeParty:
      writer.WriteStartElement('ram:SalesAgentTradeParty', [Descriptor.Profile]);
    TZUGFeRDPartyTypes.BuyerTaxRepresentativeTradeParty:
      writer.WriteStartElement('ram:BuyerTaxRepresentativeTradeParty', [Descriptor.Profile]);
    TZUGFeRDPartyTypes.ProductEndUserTradeParty:
      writer.WriteStartElement('ram:ProductEndUserTradeParty', [Descriptor.Profile]);
    TZUGFeRDPartyTypes.BuyerAgentTradeParty:
      writer.WriteStartElement('ram:BuyerAgentTradeParty', [Descriptor.Profile]);
    TZUGFeRDPartyTypes.InvoicerTradeParty:
      writer.WriteStartElement('ram:InvoicerTradeParty', [Descriptor.Profile]);
    TZUGFeRDPartyTypes.PayerTradeParty:
      writer.WriteStartElement('ram:PayerTradeParty', [Descriptor.Profile]);
  end;

  if (party.ID <> nil) and not string.IsNullOrWhiteSpace(party.ID.ID) then
  begin
    if (party.ID.SchemeID <> TZUGFeRDGlobalIDSchemeIdentifiers.Unknown) then
    begin
      writer.WriteStartElement('ram:ID');
      writer.WriteAttributeString('schemeID', TZUGFeRDGlobalIDSchemeIdentifiersExtensions.EnumToString(party.ID.SchemeID));
      writer.WriteValue(party.ID.ID);
      writer.WriteEndElement();
    end
    else
      writer.WriteOptionalElementString('ram:ID', party.ID.ID);
  end;

  if (party.GlobalID <> nil) then
  if ((party.GlobalID.ID <> '') and (party.GlobalID.SchemeID <> TZUGFeRDGlobalIDSchemeIdentifiers.Unknown)) then
  begin
    writer.WriteStartElement('ram:GlobalID');
    writer.WriteAttributeString('schemeID', TZUGFeRDGlobalIDSchemeIdentifiersExtensions.EnumToString(party.GlobalID.SchemeID));
    writer.WriteValue(party.GlobalID.ID);
    writer.WriteEndElement();
  end;

  writer.WriteOptionalElementString('ram:Name', party.Name);
  writer.WriteOptionalElementString('ram:Description', party.Description, [TZUGFeRDProfile.Comfort,
    TZUGFeRDProfile.Extended, TZUGFeRDProfile.XRechnung1, TZUGFeRDProfile.XRechnung]);

  _writeOptionalLegalOrganization(writer, 'ram:SpecifiedLegalOrganization', party.SpecifiedLegalOrganization, partyType);
  _writeOptionalContact(writer, 'ram:DefinedTradeContact', contact, [TZUGFeRDProfile.Comfort,
    TZUGFeRDProfile.Extended,TZUGFeRDProfile.XRechnung1,TZUGFeRDProfile.XRechnung]);

  writer.WriteStartElement('ram:PostalTradeAddress');
  writer.WriteOptionalElementString('ram:PostcodeCode', party.Postcode); //buyer: BT-53
  writer.WriteOptionalElementString('ram:LineOne', ifthen(party.ContactName='',party.Street,party.ContactName)); //buyer: BT-50
  if (party.ContactName<>'')then
  begin
      writer.WriteOptionalElementString('ram:LineTwo', party.Street); //buyer: BT-51
  end;

  writer.WriteOptionalElementString('ram:LineThree', party.AddressLine3); //buyer: BT-163
  writer.WriteOptionalElementString('ram:CityName', party.City); //buyer: BT-52
  writer.WriteElementString('ram:CountryID', TZUGFeRDCountryCodesExtensions.EnumToString(party.Country)); //buyer: BT-55
  writer.WriteOptionalElementString('ram:CountrySubDivisionName', party.CountrySubdivisionName); // BT-79
  writer.WriteEndElement(); // !PostalTradeAddress

  if (electronicAddress <> nil) then
  begin
    if (ElectronicAddress.Address<>'') then
    begin
      writer.WriteStartElement('ram:URIUniversalCommunication');
      writer.WriteStartElement('ram:URIID');
      writer.WriteAttributeString('schemeID', TZUGFeRDElectronicAddressSchemeIdentifiersExtensions.EnumToString(electronicAddress.ElectronicAddressSchemeID));
      writer.WriteValue(electronicAddress.Address);
      writer.WriteEndElement();
      writer.WriteEndElement();
    end;
  end;

  if (taxRegistrations <> nil) then
  begin
      // for seller: BT-31
      // for buyer : BT-48
    for var _reg : TZUGFeRDTaxRegistration in taxRegistrations do
    begin
      if (_reg.No <> '') then
      begin
        writer.WriteStartElement('ram:SpecifiedTaxRegistration');
        writer.WriteStartElement('ram:ID');
        writer.WriteAttributeString('schemeID', TZUGFeRDTaxRegistrationSchemeIDExtensions.EnumToString(_reg.SchemeID));
        writer.WriteValue(_reg.No);
        writer.WriteEndElement();
        writer.WriteEndElement();
      end;
    end;
  end;
  writer.WriteEndElement(); // !*TradeParty
end;

procedure TZUGFeRDInvoiceDescriptor22CIIWriter._writeOptionalTaxes(
  _writer: TZUGFeRDProfileAwareXmlTextWriter);
begin
  for var tax : TZUGFeRDTax in Descriptor.Taxes do
  begin
    _writer.WriteStartElement('ram:ApplicableTradeTax');

    _writer.WriteStartElement('ram:CalculatedAmount');
    _writer.WriteValue(_formatDecimal(_asNullableParam<Currency>(tax.TaxAmount)));
    _writer.WriteEndElement(); // !CalculatedAmount

    _writer.WriteElementString('ram:TypeCode', TZUGFeRDTaxTypesExtensions.EnumToString(tax.TypeCode));
    _writer.WriteOptionalElementString('ram:ExemptionReason', tax.ExemptionReason);

    _writer.WriteStartElement('ram:BasisAmount');
    _writer.WriteValue(_formatDecimal(_asNullableParam<Currency>(tax.BasisAmount)));
    _writer.WriteEndElement(); // !BasisAmount

    if (tax.AllowanceChargeBasisAmount <> nil) and ((Descriptor.Profile <> TZUGFeRDProfile.XRechnung1)
      and (Descriptor.Profile <> TZUGFeRDProfile.XRechnung)) then
    begin
      _writer.WriteStartElement('ram:AllowanceChargeBasisAmount');
      _writer.WriteValue(_formatDecimal(tax.AllowanceChargeBasisAmount));
      _writer.WriteEndElement(); // !AllowanceChargeBasisAmount
    end;

    if (tax.CategoryCode <> TZUGFeRDTaxCategoryCodes.Unknown) then
    begin
      _writer.WriteElementString('ram:CategoryCode', TZUGFeRDTaxCategoryCodesExtensions.EnumToString(tax.CategoryCode));
    end;
    if (tax.ExemptionReasonCode <> TZUGFeRDTaxExemptionReasonCodes.Unknown) then
    begin
      _writer.WriteElementString('ram:ExemptionReasonCode', TZUGFeRDTaxExemptionReasonCodesExtensions.EnumToString(tax.ExemptionReasonCode));
    end;
    _writer.WriteElementString('ram:RateApplicablePercent', _formatDecimal(_asNullableParam<Currency>(tax.Percent)));
    _writer.WriteEndElement(); // !ApplicableTradeTax
  end;
end;

end.
