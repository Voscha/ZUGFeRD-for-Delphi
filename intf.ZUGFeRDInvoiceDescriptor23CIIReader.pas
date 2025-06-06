﻿{* Licensed to the Apache Software Foundation (ASF) under one
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

unit intf.ZUGFeRDInvoiceDescriptor23CIIReader;

interface

uses
  System.SysUtils, System.Classes, System.DateUtils, System.Math
  ,System.NetEncoding, System.Variants
  ,Xml.XMLDoc, Xml.xmldom, Xml.XMLIntf
  ,Xml.Win.msxmldom, Winapi.MSXMLIntf, Winapi.msxml
  ,intf.ZUGFeRDXmlHelper
  ,intf.ZUGFeRDInvoiceDescriptorReader
  ,intf.ZUGFeRDTradeLineItem
  ,intf.ZUGFeRDParty
  ,intf.ZUGFeRDAdditionalReferencedDocument
  ,intf.ZUGFeRDInvoiceDescriptor
  ,intf.ZUGFeRDExceptions
  ,intf.ZUGFeRDProfile,intf.ZUGFeRDInvoiceTypes
  ,intf.ZUGFeRDSubjectCodes
  ,intf.ZUGFeRDLegalOrganization
  ,intf.ZUGFeRDGlobalID,intf.ZUGFeRDGlobalIDSchemeIdentifiers
  ,intf.ZUGFeRDCountryCodes
  ,intf.ZUGFeRDTaxRegistrationSchemeID
  ,intf.ZUGFeRDElectronicAddressSchemeIdentifiers
  ,intf.ZUGFeRDContact
  ,intf.ZUGFeRDAdditionalReferencedDocumentTypeCodes
  ,intf.ZUGFeRDReferenceTypeCodes
  ,intf.ZUGFeRDDeliveryNoteReferencedDocument
  ,intf.ZUGFeRDCurrencyCodes
  ,intf.ZUGFeRDPaymentMeans,intf.ZUGFeRDPaymentMeansTypeCodes
  ,intf.ZUGFeRDFinancialCard
  ,intf.ZUGFeRDBankAccount
  ,intf.ZUGFeRDTaxTypes,intf.ZUGFeRDTaxCategoryCodes
  ,intf.ZUGFeRDTaxExemptionReasonCodes
  ,intf.ZUGFeRDInvoiceReferencedDocument
  ,intf.ZUGFeRDPaymentTerms
  ,intf.ZUGFeRDSellerOrderReferencedDocument
  ,intf.ZUGFeRDReceivableSpecifiedTradeAccountingAccount
  ,intf.ZUGFeRDAccountingAccountTypeCodes
  ,intf.ZUGFeRDContractReferencedDocument
  ,intf.ZUGFeRDSpecifiedProcuringProject
  ,intf.ZUGFeRDQuantityCodes
  ,intf.ZUGFeRDApplicableProductCharacteristic
  ,intf.ZUGFeRDBuyerOrderReferencedDocument
  ,intf.ZUGFeRDAssociatedDocument
  ,intf.ZUGFeRDNote
  ,intf.ZUGFeRDContentCodes
  ,intf.ZUGFeRDDespatchAdviceReferencedDocument
  ,intf.ZUGFeRDSpecialServiceDescriptionCodes
  ,intf.ZUGFeRDAllowanceOrChargeIdentificationCodes
  ,intf.ZUGFeRDDesignatedProductClassificationCodes
  , intf.ZUGFeRDAllowanceReasonCodes
  ;

type
  TZUGFeRDInvoiceDescriptor23CIIReader = class(TZUGFeRDInvoiceDescriptorReader)
  private
    function GetValidURIs : TArray<string>;
    function _parseTradeLineItem(tradeLineItem : IXmlDomNode {nsmgr: XmlNamespaceManager = nil; }) : TZUGFeRDTradeLineItem;
    function _nodeAsParty(basenode: IXmlDomNode; const xpath: string) : TZUGFeRDParty;
    function _nodeAsContact(basenode: IXmlDomNode; const xpath: string) : TZUGFeRDContact;
    function _readAdditionalReferencedDocument(a_oXmlNode : IXmlDomNode {nsmgr: XmlNamespaceManager = nil; }) : TZUGFeRDAdditionalReferencedDocument;
    function _nodeAsLegalOrganization(basenode: IXmlDomNode; const xpath: string) : TZUGFeRDLegalOrganization;
  public
    function IsReadableByThisReaderVersion(stream: TStream): Boolean; override;
    function IsReadableByThisReaderVersion(xmldocument: IXMLDocument): Boolean; override;

    /// <summary>
    /// Parses the ZUGFeRD invoice from the given stream.
    ///
    /// Make sure that the stream is open, otherwise an IllegalStreamException exception is thrown.
    /// Important: the stream will not be closed by this function.
    /// </summary>
    /// <param name="stream"></param>
    /// <returns>The parsed ZUGFeRD invoice</returns>
    function Load(stream: TStream): TZUGFeRDInvoiceDescriptor; override;

    function Load(xmldocument : IXMLDocument): TZUGFeRDInvoiceDescriptor; override;
  end;

implementation

uses intf.ZUGFeRDXMLUtils, intf.ZUGFeRDHelper, intf.ZUGFeRDDataTypeReader, intf.ZUGFeRDPaymentTermsType,
  intf.ZUGFeRDLineStatusReasonCodes, intf.ZUGFeRDLineStatusCodes,
  intf.ZUGFeRDIncludedReferencedProduct, intf.ZUGFeRDTransportmodeCodes, intf.ZUGFeRDTradeDeliveryTermCodes,
  intf.ZUGFeRDDateTypeCodes;

{ TZUGFeRDInvoiceDescriptor23CIIReader }

function TZUGFeRDInvoiceDescriptor23CIIReader.GetValidURIs : TArray<string>;
begin
  Result := TArray<string>.Create(
    'urn:cen.eu:en16931:2017#conformant#urn:factur-x.eu:1p0:extended', // Factur-X 1.03 EXTENDED
    'urn:cen.eu:en16931:2017',  // Profil EN 16931 (COMFORT)
    'urn:cen.eu:en16931:2017#compliant#urn:factur-x.eu:1p0:basic', // BASIC
    'urn:factur-x.eu:1p0:basicwl', // BASIC WL
    'urn:factur-x.eu:1p0:minimum', // MINIMUM
    'urn:cen.eu:en16931:2017#compliant#urn:xoev-de:kosit:standard:xrechnung_1.2', // XRechnung 1.2
    'urn:cen.eu:en16931:2017#compliant#urn:xoev-de:kosit:standard:xrechnung_2.0', // XRechnung 2.0
    'urn:cen.eu:en16931:2017#compliant#urn:xoev-de:kosit:standard:xrechnung_2.1', // XRechnung 2.1
    'urn:cen.eu:en16931:2017#compliant#urn:xoev-de:kosit:standard:xrechnung_2.2', // XRechnung 2.2
    'urn:cen.eu:en16931:2017#compliant#urn:xoev-de:kosit:standard:xrechnung_2.3', // XRechnung 2.3
    'urn:cen.eu:en16931:2017#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0', // XRechnung 3.0
    //special case in xrechnung testsuite:
    'urn:cen.eu:en16931:2017#compliant#urn:xeinkauf.de:kosit:xrechnung_3.0#conformant#urn:xeinkauf.de:kosit:extension:xrechnung_3.0',
    'urn.cpro.gouv.fr:1p0:ereporting' //Factur-X E-reporting
  );
end;

function TZUGFeRDInvoiceDescriptor23CIIReader.IsReadableByThisReaderVersion(
  stream: TStream): Boolean;
begin
  Result := IsReadableByThisReaderVersion(stream, GetValidURIs);
end;

function TZUGFeRDInvoiceDescriptor23CIIReader.IsReadableByThisReaderVersion(
  xmldocument: IXMLDocument): Boolean;
begin
  Result := IsReadableByThisReaderVersion(xmldocument, GetValidURIs);
end;

function TZUGFeRDInvoiceDescriptor23CIIReader.Load(stream: TStream): TZUGFeRDInvoiceDescriptor;
var
  xml : IXMLDocument;
begin
  if Stream = nil then
    raise TZUGFeRDIllegalStreamException.Create('Cannot read from stream');

  xml := NewXMLDocument;
  try
    xml.LoadFromStream(stream,TXMLEncodingType.xetUTF_8);
    xml.Active := True;
    Result := Load(xml);
  finally
    xml := nil;
  end;
end;

function TZUGFeRDInvoiceDescriptor23CIIReader.Load(xmldocument : IXMLDocument): TZUGFeRDInvoiceDescriptor;
var
  doc : IXMLDOMDocument2;
  node : IXMLDOMNode;
  nodes : IXMLDOMNodeList;
  i : Integer;
  id, schemeID: string;
begin
  doc := TZUGFeRDXmlHelper.PrepareDocumentForXPathQuerys(xmldocument);

  //XmlNamespaceManager nsmgr = _GenerateNamespaceManagerFromNode(doc.DocumentElement);

  Result := TZUGFeRDInvoiceDescriptor.Create;

  Result.IsTest := XMLUtils._nodeAsBool(doc.documentElement,'//*[local-name()="ExchangedDocumentContext"]/ram:TestIndicator', false);
  Result.BusinessProcess := XMLUtils._nodeAsString(doc.DocumentElement, '//*[local-name()="BusinessProcessSpecifiedDocumentContextParameter"]/ram:ID');//, nsmgr),
  Result.Profile := TZUGFeRDProfileExtensions.FromString(XMLUtils._nodeAsString(doc.DocumentElement, '//ram:GuidelineSpecifiedDocumentContextParameter/ram:ID'));//, nsmgr)),
  Result.Name := XMLUtils._nodeAsString(doc.DocumentElement, '//*[local-name()="ExchangedDocument"]/ram:Name');
  Result.Type_ := TZUGFeRDInvoiceTypeExtensions.FromString(XMLUtils._nodeAsString(doc.DocumentElement, '//*[local-name()="ExchangedDocument"]/ram:TypeCode'));//, nsmgr)),
  Result.InvoiceNo := XMLUtils._nodeAsString(doc.DocumentElement, '//*[local-name()="ExchangedDocument"]/ram:ID');//, nsmgr),
  Result.InvoiceDate := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//*[local-name()="ExchangedDocument"]/ram:IssueDateTime/udt:DateTimeString');//", nsmgr)

  nodes := doc.selectNodes('//*[local-name()="ExchangedDocument"]/ram:IncludedNote');
  for i := 0 to nodes.length-1 do
  begin
    var content : String := XMLUtils._nodeAsString(nodes[i], './/ram:Content');
    var _subjectCode : String := XMLUtils._nodeAsString(nodes[i], './/ram:SubjectCode');
    var subjectCode : TZUGFeRDSubjectCodes := TZUGFeRDSubjectCodesExtensions.FromString(_subjectCode);
    var contentCode : TZUGFeRDContentCodes := TZUGFeRDContentCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:ContentCode'));
    Result.AddNote(content, subjectCode, contentCode);
  end;

  Result.ReferenceOrderNo := XMLUtils._nodeAsString(doc, '//ram:ApplicableHeaderTradeAgreement/ram:BuyerReference');

  Result.Seller := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty');

  if doc.selectSingleNode('//ram:SellerTradeParty/ram:URIUniversalCommunication') <> nil then
  begin
    id := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:SellerTradeParty/ram:URIUniversalCommunication/ram:URIID');
    schemeID := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:SellerTradeParty/ram:URIUniversalCommunication/ram:URIID/@schemeID');

    var eas : TZUGFeRDElectronicAddressSchemeIdentifiers :=
       TZUGFeRDElectronicAddressSchemeIdentifiersExtensions.FromString(schemeID);

    if (eas <> TZUGFeRDElectronicAddressSchemeIdentifiers.Unknown) then
      Result.SetSellerElectronicAddress(id, eas);
  end;

  nodes := doc.selectNodes('//ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty/ram:SpecifiedTaxRegistration');
  for i := 0 to nodes.length-1 do
  begin
    id := XMLUtils._nodeAsString(nodes[i], './/ram:ID');
    schemeID := XMLUtils._nodeAsString(nodes[i], './/ram:ID/@schemeID');
    Result.AddSellerTaxRegistration(id, TZUGFeRDTaxRegistrationSchemeIDExtensions.FromString(schemeID));
  end;

  if (doc.selectSingleNode('//ram:SellerTradeParty/ram:DefinedTradeContact') <> nil) then
  begin
    Result.SellerContact := TZUGFeRDContact.Create;
    Result.SellerContact.Name := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:SellerTradeParty/ram:DefinedTradeContact/ram:PersonName');
    Result.SellerContact.OrgUnit := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:SellerTradeParty/ram:DefinedTradeContact/ram:DepartmentName');
    Result.SellerContact.PhoneNo := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:SellerTradeParty/ram:DefinedTradeContact/ram:TelephoneUniversalCommunication/ram:CompleteNumber');
    Result.SellerContact.FaxNo := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:SellerTradeParty/ram:DefinedTradeContact/ram:FaxUniversalCommunication/ram:CompleteNumber');
    Result.SellerContact.EmailAddress := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:SellerTradeParty/ram:DefinedTradeContact/ram:EmailURIUniversalCommunication/ram:URIID');
  end;

  Result.Buyer := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:BuyerTradeParty');

  if (doc.SelectSingleNode('//ram:BuyerTradeParty/ram:URIUniversalCommunication') <> nil) then
  begin
    id := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:BuyerTradeParty/ram:URIUniversalCommunication/ram:URIID');
    schemeID := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:BuyerTradeParty/ram:URIUniversalCommunication/ram:URIID/@schemeID');

    var eas : TZUGFeRDElectronicAddressSchemeIdentifiers := TZUGFeRDElectronicAddressSchemeIdentifiersExtensions.FromString(schemeID);

    if (eas <> TZUGFeRDElectronicAddressSchemeIdentifiers.Unknown) then
      Result.SetBuyerElectronicAddress(id, eas);
  end;

  nodes := doc.selectNodes('//ram:ApplicableHeaderTradeAgreement/ram:BuyerTradeParty/ram:SpecifiedTaxRegistration');
  for i := 0 to nodes.length-1 do
  begin
    id := XMLUtils._nodeAsString(nodes[i], './/ram:ID');
    schemeID := XMLUtils._nodeAsString(nodes[i], './/ram:ID/@schemeID');
    Result.AddBuyerTaxRegistration(id, TZUGFeRDTaxRegistrationSchemeIDExtensions.FromString(schemeID));
  end;

  if (doc.SelectSingleNode('//ram:BuyerTradeParty/ram:DefinedTradeContact') <> nil) then
  begin
    Result.BuyerContact := TZUGFeRDContact.Create;
    Result.SetBuyerContact(
      XMLUtils._nodeAsString(doc.DocumentElement, '//ram:BuyerTradeParty/ram:DefinedTradeContact/ram:PersonName'),
      XMLUtils._nodeAsString(doc.DocumentElement, '//ram:BuyerTradeParty/ram:DefinedTradeContact/ram:DepartmentName'),
      XMLUtils._nodeAsString(doc.DocumentElement, '//ram:BuyerTradeParty/ram:DefinedTradeContact/ram:EmailURIUniversalCommunication/ram:URIID'),
      XMLUtils._nodeAsString(doc.DocumentElement, '//ram:BuyerTradeParty/ram:DefinedTradeContact/ram:TelephoneUniversalCommunication/ram:CompleteNumber'),
      XMLUtils._nodeAsString(doc.DocumentElement, '//ram:BuyerTradeParty/ram:DefinedTradeContact/ram:FaxUniversalCommunication/ram:CompleteNumber')
    );
  end;

  // TODO: SalesAgentTradeParty, Detaillierte Informationen über den Handelsvertreter, BG-X-49
  // TODO: BuyerTaxRepresentativeTradeParty Detaillierte Informationen über den Steuerbevollmächtigten des Käufers, BG-X-54

  // SellerTaxRepresentativeTradeParty STEUERBEVOLLMÄCHTIGTER DES VERKÄUFERS, BG-11
  Result.SellerTaxRepresentative := _nodeAsParty(doc.DocumentElement,
    '//ram:ApplicableHeaderTradeAgreement/ram:SellerTaxRepresentativeTradeParty');

  nodes := doc.SelectNodes('//ram:ApplicableHeaderTradeAgreement/ram:SellerTaxRepresentativeTradeParty/ram:SpecifiedTaxRegistration');
  for i := 0 to nodes.Length - 1 do

  begin
      id := XmlUtils._nodeAsString(nodes[i], './/ram:ID');
      schemeID := XmlUtils._nodeAsString(nodes[i], './/ram:ID/@schemeID');

      Result.AddSellerTaxRepresentativeTaxRegistration(id, TZUGFeRDTaxRegistrationSchemeIDExtensions.FromString(schemeID));
  end;

  // TODO: ProductEndUserTradeParty Detailinformationen zum abweichenden Endverbraucher, BG-X-18

  var deliveryCodeStr := XmlUtils._nodeAsString(doc.DocumentElement,
    '//ram:ApplicableHeaderTradeAgreement/ram:ApplicableTradeDeliveryTerms/ram:DeliveryTypeCode');
  if not string.IsNullOrWhiteSpace(deliveryCodeStr) then
  begin
      var tradeCode := TZUGFeRDTradeDeliveryTermCodesExtensions.FromString(deliveryCodeStr);
      if (tradeCode <> nil) then
        Result.ApplicableTradeDeliveryTermsCode := tradeCode;
  end;

  //Get all referenced and embedded documents (BG-24)
  nodes := doc.SelectNodes('.//ram:ApplicableHeaderTradeAgreement/ram:AdditionalReferencedDocument');
  for i := 0 to nodes.length-1 do
  begin
    Result.AdditionalReferencedDocuments.Add(_readAdditionalReferencedDocument(nodes[i]));
  end;

  //Read TransportModeCodes --> BT-X-152
  var NodeName :=
    '//ram:ApplicableHeaderTradeDelivery/ram:RelatedSupplyChainConsignment/ram:SpecifiedLogisticsTransportMovement/ram:ModeCode';
  if XmlUtils._nodeExists(doc, NodeName) then
    Result.TransportMode := TZUGFeRDTransportModeCodesExtensions.FromString(XmlUtils._nodeAsString(doc.DocumentElement, NodeName));

  Result.ShipTo := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:ShipToTradeParty');
  Result.ShipToContact := _nodeAsContact(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:ShipToTradeParty/ram:DefinedTradeContact');
  Result.UltimateShipTo := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:UltimateShipToTradeParty');
  Result.UltimateShipToContact := _nodeAsContact(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:UltimateShipToTradeParty/ram:DefinedTradeContact');
  Result.ShipFrom := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:ShipFromTradeParty');
  Result.ActualDeliveryDate:= DataTypeReader.ReadFormattedIssueDateTime(doc.DocumentElement,
    '//ram:ApplicableHeaderTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime');

  // BT-X-66-00
  nodes := doc.SelectNodes('//ram:ApplicableHeaderTradeDelivery/ram:ShipToTradeParty/ram:SpecifiedTaxRegistration');
  for i := 0 to nodes.Length - 1 do
  begin
    id := XmlUtils._nodeAsString(nodes[i], './/ram:ID');
    schemeID := XmlUtils._nodeAsString(nodes[i], './/ram:ID/@schemeID');
    Result.AddShipToTaxRegistration(id, TZUGFeRDTaxRegistrationSchemeIDExtensions.FromString(schemeID));
  end;


  var _despatchAdviceNo : String := XMLUtils._nodeAsString(doc.DocumentElement,
    '//ram:ApplicableHeaderTradeDelivery/ram:DespatchAdviceReferencedDocument/ram:IssuerAssignedID');
  var _despatchAdviceDate: ZUGFeRDNullable<TDateTime> := XMLUtils._nodeAsDateTime(doc.documentElement,
    '//ram:ApplicableHeaderTradeDelivery/ram:DespatchAdviceReferencedDocument/ram:FormattedIssueDateTime/udt:DateTimeString');

  if not (_despatchAdviceDate.HasValue) then
  begin
    _despatchAdviceDate := XMLUtils._nodeAsDateTime(doc.DocumentElement,
      '//ram:ApplicableHeaderTradeDelivery/ram:DespatchAdviceReferencedDocument/ram:FormattedIssueDateTime');
  end;

  if ((_despatchAdviceDate.HasValue) or (_despatchAdviceNo <> '')) then
  begin
//    Result.DespatchAdviceReferencedDocument := TZUGFeRDDespatchAdviceReferencedDocument.Create;
    Result.SetDespatchAdviceReferencedDocument(_despatchAdviceNo, _despatchAdviceDate);
  end;

  var _deliveryNoteNo : String := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:IssuerAssignedID');
  var _deliveryNoteDate : ZUGFeRDNullable<TDateTime> := DataTypeReader.ReadFormattedIssueDateTime(doc.DocumentElement,
    '//ram:ApplicableHeaderTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:IssueDateTime');

  if not _deliveryNoteDate.HasValue then
  begin
    _deliveryNoteDate := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:IssueDateTime');
  end;

  if ((_deliveryNoteDate.HasValue) or (_deliveryNoteNo <> '')) then
  begin
    Result.DeliveryNoteReferencedDocument := TZUGFeRDDeliveryNoteReferencedDocument.Create;
    Result.SetDeliveryNoteReferenceDocument(_deliveryNoteNo,_deliveryNoteDate);
  end;

  Result.Invoicee := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:InvoiceeTradeParty');
  //BT-X-242-00
  nodes := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:InvoiceeTradeParty/ram:SpecifiedTaxRegistration');
  for i := 0 to nodes.Length - 1 do
  begin
    id := XmlUtils._nodeAsString(nodes[i], './/ram:ID');
    schemeID := XmlUtils._nodeAsString(nodes[i], './/ram:ID/@schemeID');
    Result.AddInvoiceeTaxRegistration(id, TZUGFeRDTaxRegistrationSchemeIDExtensions.FromString(schemeID));
  end;

  Result.Invoicer := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:InvoicerTradeParty');
  Result.Payee := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:PayeeTradeParty');

  Result.PaymentReference := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:PaymentReference');
  Result.Currency :=  TZUGFeRDCurrencyCodesExtensions.FromString(XMLUtils._nodeAsString(doc.DocumentElement,
    '//ram:ApplicableHeaderTradeSettlement/ram:InvoiceCurrencyCode'));
  Result.SellerReferenceNo := XMLUtils._nodeAsString(doc.DocumentElement,
    '//ram:ApplicableHeaderTradeSettlement/ram:InvoiceIssuerReference');

  var optionalTaxCurrency := TZUGFeRDCurrencyCodesExtensions.FromString(XMLUtils._nodeAsString(doc.DocumentElement,
    '//ram:ApplicableHeaderTradeSettlement/ram:TaxCurrencyCode')); // BT-6
  if (optionalTaxCurrency <> TZUGFeRDCurrencyCodes.Unknown) then
    Result.TaxCurrency := optionalTaxCurrency;

  // TODO: Multiple SpecifiedTradeSettlementPaymentMeans can exist for each account/institution (with different SEPA?)
  var _tempPaymentMeans : TZUGFeRDPaymentMeans := TZUGFeRDPaymentMeans.Create;
  _tempPaymentMeans.TypeCode := TZUGFeRDPaymentMeansTypeCodesExtensions.FromString(XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:TypeCode'));
  _tempPaymentMeans.Information := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:Information');
  _tempPaymentMeans.SEPACreditorIdentifier := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:CreditorReferenceID');
  _tempPaymentMeans.SEPAMandateReference := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:SpecifiedTradePaymentTerms/ram:DirectDebitMandateID');

  var financialCardId : String := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:ApplicableTradeSettlementFinancialCard/ram:ID');
  var financialCardCardholderName : String := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:ApplicableTradeSettlementFinancialCard/ram:CardholderName');

  if ((financialCardId <> '') or (financialCardCardholderName <> '')) then
  begin
    _tempPaymentMeans.FinancialCard := TZUGFeRDFinancialCard.Create;
    _tempPaymentMeans.FinancialCard.Id := financialCardId;
    _tempPaymentMeans.FinancialCard.CardholderName := financialCardCardholderName;
  end;

  Result.PaymentMeans := _tempPaymentMeans;

  //TODO udt:DateTimeString
  Result.BillingPeriodStart := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:BillingSpecifiedPeriod/ram:StartDateTime');
  Result.BillingPeriodEnd := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:BillingSpecifiedPeriod/ram:EndDateTime');

  var creditorFinancialAccountNodes : IXMLDOMNodeList := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayeePartyCreditorFinancialAccount');
  var creditorFinancialInstitutions : IXMLDOMNodeList := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayeeSpecifiedCreditorFinancialInstitution');

  var numberOfAccounts : Integer := System.Math.Min(creditorFinancialAccountNodes.Length,
    creditorFinancialInstitutions.Length);
  for i := 0 to numberOfAccounts-1 do
  begin
    Result.AddCreditorFinancialAccount(
      XmlUtils._nodeAsString(creditorFinancialAccountNodes[i], './/ram:IBANID'),
      XmlUtils._nodeAsString(creditorFinancialInstitutions[i], './/ram:BICID'),
      XmlUtils._nodeAsString(creditorFinancialAccountNodes[i], './/ram:ProprietaryID'),
      XmlUtils._nodeAsString(creditorFinancialInstitutions[i], './/ram:GermanBankleitzahlID'),
      XmlUtils._nodeAsString(creditorFinancialInstitutions[i], './/ram:Name'),
      XmlUtils._nodeAsString(creditorFinancialAccountNodes[i], './/ram:AccountName')
    )
  end;

  var specifiedTradeSettlementPaymentMeansNodes : IXMLDOMNodeList := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans');
  for i := 0 to specifiedTradeSettlementPaymentMeansNodes.length-1 do
  begin
      var payerPartyDebtorFinancialAccountNode : IXMLDOMNode := specifiedTradeSettlementPaymentMeansNodes[i].selectSingleNode('ram:PayerPartyDebtorFinancialAccount');

      if (payerPartyDebtorFinancialAccountNode = nil) then
        continue;

      var _account : TZUGFeRDBankAccount := TZUGFeRDBankAccount.Create;
      _account.ID := XMLUtils._nodeAsString(payerPartyDebtorFinancialAccountNode, './/ram:ProprietaryID');
      _account.IBAN := XMLUtils._nodeAsString(payerPartyDebtorFinancialAccountNode, './/ram:IBANID');
      _account.Bankleitzahl := XMLUtils._nodeAsString(payerPartyDebtorFinancialAccountNode, './/ram:GermanBankleitzahlID');
      _account.BankName := XMLUtils._nodeAsString(payerPartyDebtorFinancialAccountNode, './/ram:Name');

      var payerSpecifiedDebtorFinancialInstitutionNode : IXMLDOMNode := specifiedTradeSettlementPaymentMeansNodes[i].SelectSingleNode('ram:PayerSpecifiedDebtorFinancialInstitution');
      if (payerSpecifiedDebtorFinancialInstitutionNode <> nil) then
          _account.BIC := XMLUtils._nodeAsString(payerPartyDebtorFinancialAccountNode, './/ram:BICID');

      Result.DebitorBankAccounts.Add(_account);
  end;

  nodes := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax');
  for i := 0 to nodes.length-1 do
  begin
      var basisAmount: Currency := XMLUtils._nodeAsDecimal(nodes[i], './/ram:BasisAmount', TZUGFeRDNullableParam<Currency>.Create(0));
      var percent: Currency :=  XMLUtils._nodeAsDecimal(nodes[i], './/ram:RateApplicablePercent', TZUGFeRDNullableParam<Currency>.Create(0));
      var taxAmount: Currency := XmlUtils._nodeAsDecimal(nodes[i], './/ram:CalculatedAmount', TZUGFeRDNullableParam<Currency>.Create(0));
      var typeCode: TZUGFeRDTaxTypes := TZUGFeRDTaxTypesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:TypeCode'));
      var categoryCode :=  TZUGFeRDNullableParam<TZUGFeRDTaxCategoryCodes>.Create(
         TZUGFeRDTaxCategoryCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:CategoryCode')));
      var allowanceChargeBasisAmount := XMLUtils._nodeAsDecimal(nodes[i], './/ram:AllowanceChargeBasisAmount');
      var exemptionReasonCode := TZUGFeRDTaxExemptionReasonCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:ExemptionReasonCode'));
      var  exemptionReason: string := XMLUtils._nodeAsString(nodes[i], './/ram:ExemptionReason');
      var lineTotalBasisAmount := XMLUtils._nodeAsDecimal(nodes[i], './/ram:LineTotalBasisAmount');

    var tradetax := Result.AddApplicableTradeTax(basisAmount, percent, taxAmount, typeCode, categoryCode,
      allowanceChargeBasisAmount, exemptionReasonCode, exemptionReason, lineTotalBasisAmount);

    tradetax.SetTaxPointDate(
      XMLUtils._nodeAsDateTime(nodes[i], './/ram:TaxPointDate/udt:DateString'),
     TZUGFeRDDateTypeCodesExtensions.FromString(XMLUtils._nodeAsstring(nodes[i], './/ram:DueDateTypeCode')));
  end;

  nodes := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeAllowanceCharge');
  for i := 0 to nodes.length-1 do
  begin
    Result.AddTradeAllowanceCharge(not XMLUtils._nodeAsBool(nodes[i], './/ram:ChargeIndicator'), // wichtig: das not (!) beachten
                                   XMLUtils._nodeAsDecimal(nodes[i], './/ram:BasisAmount', TZUGFeRDNullableParam<Currency>.Create(0)),
                                   Result.Currency,
                                   XMLUtils._nodeAsDecimal(nodes[i], './/ram:ActualAmount', TZUGFeRDNullableParam<Currency>.Create(0)),
                                   XMLUtils._nodeAsDecimal(nodes[i], './/ram:CalculationPercent', TZUGFeRDNullableParam<Currency>.Create(0)),
                                   XMLUtils._nodeAsString(nodes[i], './/ram:Reason'),
                                   TZUGFeRDTaxTypesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:CategoryTradeTax/ram:TypeCode')),
                                   TZUGFeRDTaxCategoryCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:CategoryTradeTax/ram:CategoryCode')),
                                   XMLUtils._nodeAsDecimal(nodes[i], './/ram:CategoryTradeTax/ram:RateApplicablePercent', TZUGFeRDNullableParam<Currency>.Create(0)),
                                   TZUGFeRDAllowanceReasonCodesExtensions.FromString(XmlUtils._nodeAsString(nodes[i], './ram:ReasonCode'))
                                  );
  end;

  nodes := doc.SelectNodes('//ram:SpecifiedLogisticsServiceCharge');
  for i := 0 to nodes.length-1 do
  begin
    Result.AddLogisticsServiceCharge(XMLUtils._nodeAsDecimal(nodes[i], './/ram:AppliedAmount', TZUGFeRDNullableParam<Currency>.Create(0)),
                                     XMLUtils._nodeAsString(nodes[i], './/ram:Description'),
                                     TZUGFeRDTaxTypesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:AppliedTradeTax/ram:TypeCode')),
                                     TZUGFeRDTaxCategoryCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:AppliedTradeTax/ram:CategoryCode')),
                                     XMLUtils._nodeAsDecimal(nodes[i], './/ram:AppliedTradeTax/ram:RateApplicablePercent', TZUGFeRDNullableParam<Currency>.Create(0)));
  end;

  nodes := doc.DocumentElement.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:InvoiceReferencedDocument');
  for i := 0 to nodes.length - 1 do
    Result.AddInvoiceReferencedDocument(
      XMLUtils._nodeAsString(nodes[i], './ram:IssuerAssignedID'),
      XMLUtils._nodeAsDateTime(nodes[i], './ram:FormattedIssueDateTime')
    );

  nodes := doc.SelectNodes('//ram:SpecifiedTradePaymentTerms');
  for i := 0 to nodes.length-1 do
  begin
    var discountPercent := XmlUtils._NodeAsDecimal(nodes[i], './/ram:ApplicableTradePaymentDiscountTerms/ram:CalculationPercent', nil);

    var discountDueDays: ZUGFeRDNullable<Integer> := nil;
    if (TZUGFeRDQuantityCodes.DAY = TZUGFeRDQuantityCodesExtensions.FromString(XmlUtils._nodeAsString(nodes[i],
      './/ram:ApplicableTradePaymentDiscountTerms/ram:BasisPeriodMeasure/@unitCode'))) then
      discountDueDays := XmlUtils._nodeAsInt(nodes[i], './/ram:ApplicableTradePaymentDiscountTerms/ram:BasisPeriodMeasure');

    var discountMaturityDate := XmlUtils._nodeAsDateTime(nodes[i],
      './/ram:ApplicableTradePaymentDiscountTerms/ram:BasisDateTime/udt:DateTimeString'); //BT-X-282-0
    var discountBaseAmount := XmlUtils._nodeAsDecimal(nodes[i], './/ram:ApplicableTradePaymentDiscountTerms/ram:BasisAmount');
    var discountActualAmount := XmlUtils._nodeAsDecimal(nodes[i], './/ram:ApplicableTradePaymentDiscountTerms/ram:ActualDiscountAmount');
    var penaltyPercent := XmlUtils._nodeAsDecimal(nodes[i], './/ram:ApplicableTradePaymentPenaltyTerms/ram:CalculationPercent');

    var penaltyDueDays: ZUGFeRDNullable<Integer> := nil;
    if (TZUGFeRDQuantityCodes.DAY = TZUGFeRDQuantityCodesExtensions.FromString(XmlUtils._nodeAsString(nodes[i],
      './/ram:ApplicableTradePaymentPenaltyTerms/ram:BasisPeriodMeasure/@unitCode'))) then
      penaltyDueDays := XmlUtils._nodeAsInt(nodes[i], './/ram:ApplicableTradePaymentPenaltyTerms/ram:BasisPeriodMeasure');

    var penaltyMaturityDate := XmlUtils._nodeAsDateTime(nodes[i], './/ram:ApplicableTradePaymentPenaltyTerms/ram:BasisDateTime/udt:DateTimeString'); // BT-X-276-0
    var penaltyBaseAmount := XmlUtils._nodeAsDecimal(nodes[i], './/ram:ApplicableTradePaymentPenaltyTerms/ram:BasisAmount');
    var penaltyActualAmount := XmlUtils._nodeAsDecimal(nodes[i], './/ram:ApplicableTradePaymentDiscountTerms/ram:ActualPenaltyAmount');

    var paymentTermsType: ZUGFeRDNullable<TZUGFeRDPaymentTermsType> := nil;
    if discountPercent.HasValue then
      paymentTermsType := TZUGFeRDPaymentTermsType.Skonto
    else if penaltyPercent.HasValue then
      paymentTermsType := TZUGFeRDPaymentTermsType.Verzug;

    if discountDueDays = nil then
      discountDueDays := penaltyDueDays;
    if discountPercent = nil then
      discountPercent := penaltyPercent;
    if discountBaseAmount = nil then
      discountBaseAmount := penaltyBaseAmount;
    if discountActualAmount = nil then
      discountActualAmount := penaltyActualAmount;
    if discountMaturityDate = nil then
      discountMaturityDate := penaltyMaturityDate;

    result.AddTradePaymentTerms(
      XmlUtils._NodeAsString(nodes[i], './/ram:Description'),
      XmlUtils._NodeAsDateTime(nodes[i], './/ram:DueDateDateTime'),
      paymentTermsType, {TZUGFeRDNullableParam<TZUGFeRDPaymentTermsType>.Create(paymentTermsType.GetValueOrDefault),}
      discountDueDays, //discountDueDays.GetValueOrDefault(penaltyDueDays),
      discountPercent, //TZUGFeRDNullableParam<Currency>.Create(discountPercent.GetValueOrDefault(penaltyPercent)),
      discountBaseAmount,
      discountActualAmount,
      discountMaturityDate);//TZUGFeRDNullable
  end;

  Result.LineTotalAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:LineTotalAmount', TZUGFeRDNullableParam<Currency>.Create(0));
  Result.ChargeTotalAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:ChargeTotalAmount', nil);
  Result.AllowanceTotalAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:AllowanceTotalAmount', nil);
  Result.TaxBasisAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxBasisTotalAmount', nil);
  Result.TaxTotalAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxTotalAmount', TZUGFeRDNullableParam<Currency>.Create(0));
  Result.GrandTotalAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:GrandTotalAmount',TZUGFeRDNullableParam<Currency>.Create(0));
  Result.RoundingAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:RoundingAmount', TZUGFeRDNullableParam<Currency>.Create(0));
  Result.TotalPrepaidAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TotalPrepaidAmount', nil);
  Result.DuePayableAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:DuePayableAmount', TZUGFeRDNullableParam<Currency>.Create(0));

  nodes := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:ReceivableSpecifiedTradeAccountingAccount');
  for i := 0 to nodes.length-1 do
  begin
    var item : TZUGFeRDReceivableSpecifiedTradeAccountingAccount :=
      TZUGFeRDReceivableSpecifiedTradeAccountingAccount.Create;
    item.TradeAccountID := XMLUtils._nodeAsString(nodes[i], './/ram:ID');
    item.TradeAccountTypeCode := TZUGFeRDAccountingAccountTypeCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:TypeCode'));
    Result.ReceivableSpecifiedTradeAccountingAccounts.Add(item);
  end;

  Result.OrderDate:= DataTypeReader.ReadFormattedIssueDateTime(doc.DocumentElement,
    '//ram:ApplicableHeaderTradeAgreement/ram:BuyerOrderReferencedDocument/ram:FormattedIssueDateTime');
  Result.OrderNo := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:BuyerOrderReferencedDocument/ram:IssuerAssignedID');

  // Read SellerOrderReferencedDocument
  node := doc.SelectSingleNode('//ram:ApplicableHeaderTradeAgreement/ram:SellerOrderReferencedDocument');
  if node <> nil then
  begin
    Result.SellerOrderReferencedDocument := TZUGFeRDSellerOrderReferencedDocument.Create;
    Result.SellerOrderReferencedDocument.ID := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:SellerOrderReferencedDocument/ram:IssuerAssignedID');
    Result.SellerOrderReferencedDocument.IssueDateTime:= DataTypeReader.ReadFormattedIssueDateTime(doc.DocumentElement,
      '//ram:ApplicableHeaderTradeAgreement/ram:SellerOrderReferencedDocument/ram:FormattedIssueDateTime');
  end;

  // Read ContractReferencedDocument
  if (doc.SelectSingleNode('//ram:ApplicableHeaderTradeAgreement/ram:ContractReferencedDocument') <> nil) then
  begin
    Result.ContractReferencedDocument := TZUGFeRDContractReferencedDocument.Create;
    Result.ContractReferencedDocument.ID := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:ContractReferencedDocument/ram:IssuerAssignedID');
    var dt := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:ContractReferencedDocument/ram:FormattedIssueDateTime');
    if dt.HasValue then
      Result.ContractReferencedDocument.IssueDateTime:= dt;
  end;

  Result.SpecifiedProcuringProject := TZUGFeRDSpecifiedProcuringProject.Create;
  Result.SpecifiedProcuringProject.ID := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:SpecifiedProcuringProject/ram:ID');
  Result.SpecifiedProcuringProject.Name := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:SpecifiedProcuringProject/ram:Name');

  nodes := doc.SelectNodes('//ram:IncludedSupplyChainTradeLineItem');
  for i := 0 to nodes.length-1 do
    Result.TradeLineItems.Add(_parseTradeLineItem(nodes[i]));
end;

function TZUGFeRDInvoiceDescriptor23CIIReader._readAdditionalReferencedDocument(
  a_oXmlNode: IXmlDomNode): TZUGFeRDAdditionalReferencedDocument;
begin
  var strBase64BinaryData : String := XMLUtils._nodeAsString(a_oXmlNode, 'ram:AttachmentBinaryObject');
  Result := TZUGFeRDAdditionalReferencedDocument.Create(false);
  Result.ID := XMLUtils._nodeAsString(a_oXmlNode, 'ram:IssuerAssignedID');
  Result.TypeCode := TZUGFeRDAdditionalReferencedDocumentTypeCodeExtensions.FromString(XMLUtils._nodeAsString(a_oXmlNode, 'ram:TypeCode'));
  Result.Name := XMLUtils._nodeAsString(a_oXmlNode, 'ram:Name');
  Result.IssueDateTime:= DataTypeReader.ReadFormattedIssueDateTime(a_oXmlNode, 'ram:FormattedIssueDateTime');
  if strBase64BinaryData <> '' then
  begin
    Result.AttachmentBinaryObject := TMemoryStream.Create;
    var strBase64BinaryDataBytes : TBytes := TNetEncoding.Base64String.DecodeStringToBytes(strBase64BinaryData);
    Result.AttachmentBinaryObject.Write(strBase64BinaryDataBytes,Length(strBase64BinaryDataBytes));
  end;
  Result.Filename := XMLUtils._nodeAsString(a_oXmlNode, 'ram:AttachmentBinaryObject/@filename');
  Result.ReferenceTypeCode := TZUGFeRDReferenceTypeCodesExtensions.FromString(XMLUtils._nodeAsString(a_oXmlNode, 'ram:ReferenceTypeCode'));
  Result.URIID := XmlUtils._nodeAsString(a_oXmlNode, 'ram:URIID');
  Result.LineID := XmlUtils._NodeAsString(a_oXMLnode, 'ram:LineID');
end;

function TZUGFeRDInvoiceDescriptor23CIIReader._nodeAsContact(basenode: IXmlDomNode;
  const xpath: string): TZUGFeRDContact;
var
  node : IXmlDomNode;
begin
  Result := nil;
  if (baseNode = nil) then
    exit;

  node := baseNode.SelectSingleNode(xpath);
  if (node = nil) then
    exit;

  Result := TZUGFeRDContact.Create;
  Result.Name := XmlUtils._nodeAsString(node, './ram:PersonName');
  Result.OrgUnit := XmlUtils._nodeAsString(node, './ram:DepartmentName');
  Result.PhoneNo := XmlUtils._nodeAsString(node, './ram:TelephoneUniversalCommunication/ram:CompleteNumber');
  Result.FaxNo := XmlUtils._nodeAsString(node, './ram:FaxUniversalCommunication/ram:CompleteNumber');
  Result.EmailAddress := XmlUtils._nodeAsString(node, './ram:EmailURIUniversalCommunication/ram:URIID');
end;

function TZUGFeRDInvoiceDescriptor23CIIReader._nodeAsLegalOrganization(
  basenode: IXmlDomNode; const xpath: string) : TZUGFeRDLegalOrganization;
var
  node : IXmlDomNode;
begin
  Result := nil;
  if (baseNode = nil) then
    exit;
  node := baseNode.SelectSingleNode(xpath);
  if (node = nil) then
    exit;

  Result := TZUGFeRDLegalOrganization.CreateWithParams(
               TZUGFeRDGlobalIDSchemeIdentifiersExtensions.FromString(XMLUtils._nodeAsString(node, 'ram:ID/@schemeID')),
               XMLUtils._nodeAsString(node, 'ram:ID'),
               XMLUtils._nodeAsString(node, 'ram:TradingBusinessName'));
end;

function TZUGFeRDInvoiceDescriptor23CIIReader._nodeAsParty(basenode: IXmlDomNode;
  const xpath: string) : TZUGFeRDParty;
var
  node : IXmlDomNode;
  lineOne,lineTwo : String;
begin
  Result := nil;
  if (baseNode = nil) then
    exit;

  node := baseNode.SelectSingleNode(xpath);
  if (node = nil) then
    exit;

  Result := TZUGFeRDParty.Create;
  Result.ID.ID := XMLUtils._nodeAsString(node, './ram:ID');
  Result.ID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiersExtensions.FromString(XMLUtils._nodeAsString(node, './ram:ID/@schemeID'));
  Result.GlobalID.ID := XMLUtils._nodeAsString(node, './ram:GlobalID');
  Result.GlobalID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiersExtensions.FromString(XMLUtils._nodeAsString(node, './ram:GlobalID/@schemeID'));

  Result.Name := XMLUtils._nodeAsString(node, './ram:Name');
  Result.Description := XMLUtils._nodeAsString(node, './ram:Description'); // BT-33 Seller only
  Result.Postcode := XMLUtils._nodeAsString(node, './ram:PostalTradeAddress/ram:PostcodeCode');
  Result.City := XMLUtils._nodeAsString(node, './ram:PostalTradeAddress/ram:CityName');
  Result.Country := TZUGFeRDCountryCodesExtensions.FromString(XMLUtils._nodeAsString(node,
    './ram:PostalTradeAddress/ram:CountryID'));
  Result.SpecifiedLegalOrganization := _nodeAsLegalOrganization(node, './ram:SpecifiedLegalOrganization');

  lineOne := XMLUtils._nodeAsString(node, './ram:PostalTradeAddress/ram:LineOne');
  lineTwo := XMLUtils._nodeAsString(node, './ram:PostalTradeAddress/ram:LineTwo');

  if (not lineTwo.IsEmpty) then
  begin
    Result.ContactName := lineOne;
    Result.Street := lineTwo;
  end else
  begin
    Result.Street := lineOne;
    Result.ContactName := '';
  end;

  Result.AddressLine3 := XMLUtils._nodeAsString(node, './ram:PostalTradeAddress/ram:LineThree');
  Result.CountrySubdivisionName := XMLUtils._nodeAsString(node, './ram:PostalTradeAddress/ram:CountrySubDivisionName');
end;

function TZUGFeRDInvoiceDescriptor23CIIReader._parseTradeLineItem(
  tradeLineItem: IXmlDomNode): TZUGFeRDTradeLineItem;
var
  nodes : IXMLDOMNodeList;
  i : Integer;
begin
  Result := nil;

  if (tradeLineItem = nil) then
    exit;

  var lineId := XmlUtils._nodeAsString(tradeLineItem, './/ram:AssociatedDocumentLineDocument/ram:LineID', String.Empty);
  var parentLineId := XmlUtils._nodeAsString(tradeLineItem, './/ram:AssociatedDocumentLineDocument/ram:ParentLineID', String.Empty);

  var lineStatusCode := TZUGFeRDLineStatusCodesExtensions.FromString(
    XmlUtils._nodeAsString(tradeLineItem, './/ram:AssociatedDocumentLineDocument/ram:LineStatusCode'));
  var lineStatusReasonCode := TZUGFeRDLineStatusReasonCodesExtensions.FromString(
    XmlUtils._nodeAsString(tradeLineItem, './/ram:AssociatedDocumentLineDocument/ram:LineStatusReasonCode'));

  Result := TZUGFeRDTradeLineItem.Create(lineID);

  Result.GlobalID.ID := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:GlobalID');
  Result.GlobalID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiersExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:GlobalID/@schemeID'));
  Result.SellerAssignedID := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:SellerAssignedID');
  Result.BuyerAssignedID := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:BuyerAssignedID');
  Result.Name := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:Name');
  Result.Description := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:Description');
  Result.UnitQuantity:= XMLUtils._nodeAsDouble(tradeLineItem, './/ram:BasisQuantity');
  Result.BilledQuantity := XMLUtils._nodeAsDecimal(tradeLineItem, './/ram:BilledQuantity', TZUGFeRDNullableParam<Currency>.Create(0));
  Result.ShipTo := _nodeAsParty(tradeLineItem, './/ram:SpecifiedLineTradeDelivery/ram:ShipToTradeParty');
  Result.UltimateShipTo := _nodeAsParty(tradeLineItem,
    './/ram:SpecifiedLineTradeDelivery/ram:UltimateShipToTradeParty');
  Result.ChargeFreeQuantity := XMLUtils._nodeAsDouble(tradeLineItem, './/ram:ChargeFreeQuantity');
  Result.PackageQuantity := XMLUtils._nodeAsDouble(tradeLineItem, './/ram:PackageQuantity');
  Result.LineTotalAmount:= XMLUtils._nodeAsDouble(tradeLineItem, './/ram:LineTotalAmount');
  Result.TaxCategoryCode := TZUGFeRDTaxCategoryCodesExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem, './/ram:ApplicableTradeTax/ram:CategoryCode'));
  Result.TaxType := TZUGFeRDTaxTypesExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem, './/ram:ApplicableTradeTax/ram:TypeCode'));
  Result.TaxPercent := XMLUtils._nodeAsDecimal(tradeLineItem, './/ram:ApplicableTradeTax/ram:RateApplicablePercent', TZUGFeRDNullableParam<Currency>.Create(0));
  Result.TaxExemptionReasonCode := TZUGFeRDTaxExemptionReasonCodesExtensions.FromString(XmlUtils._nodeAsString(
    tradeLineItem, './/ram:ApplicableTradeTax/ram:ExemptionReasonCode'));
  Result.TaxExemptionReason := XmlUtils._nodeAsString(tradeLineItem, './/ram:ApplicableTradeTax/ram:ExemptionReason');
  Result.NetUnitPrice:= XMLUtils._nodeAsDouble(tradeLineItem, './/ram:NetPriceProductTradePrice/ram:ChargeAmount');
  Result.GrossUnitPrice:= XMLUtils._nodeAsDouble(tradeLineItem, './/ram:GrossPriceProductTradePrice/ram:ChargeAmount');
  Result.UnitCode := TZUGFeRDQuantityCodesExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem,
    './/ram:BilledQuantity/@unitCode'));
  Result.ChargeFreeUnitCode := TZUGFeRDQuantityCodesExtensions.FromString(XmlUtils._nodeAsString(tradeLineItem,
    './/ram:ChargeFreeQuantity/@unitCode'));
  Result.PackageUnitCode := TZUGFeRDQuantityCodesExtensions.FromString(XmlUtils._nodeAsString(tradeLineItem,
    './/ram:PackageQuantity/@unitCode'));

  Result.BillingPeriodStart := XMLUtils._nodeAsDateTime(tradeLineItem, './/ram:BillingSpecifiedPeriod/ram:StartDateTime/udt:DateTimeString');
  Result.BillingPeriodEnd := XMLUtils._nodeAsDateTime(tradeLineItem, './/ram:BillingSpecifiedPeriod/ram:EndDateTime/udt:DateTimeString');

  if not String.IsNullOrWhiteSpace(parentLineId) then
    Result.SetParentLineId(parentLineId);

  if lineStatusCode.HasValue and lineStatusReasonCode.HasValue then
    Result.SetLineStatus(lineStatusCode.Value, lineStatusReasonCode.Value);

  nodes := tradeLineItem.SelectNodes('.//ram:SpecifiedTradeProduct/ram:ApplicableProductCharacteristic');
  for i := 0 to nodes.length-1 do
  begin
    var apcItem : TZUGFeRDApplicableProductCharacteristic := TZUGFeRDApplicableProductCharacteristic.Create;
    apcItem.Description := XMLUtils._nodeAsString(nodes[i], './/ram:Description');
    apcItem.Value := XMLUtils._nodeAsString(nodes[i], './/ram:Value');
    Result.ApplicableProductCharacteristics.Add(apcItem);
  end;

  nodes := tradeLineItem.SelectNodes('.//ram:SpecifiedTradeProduct/ram:IncludedReferencedProduct');
  for i := 0 to nodes.Length - 1 do
  begin
    var unitCode := XmlUtils._nodeAsString(nodes[i], './/ram:UnitQuantity/@unitCode');
    var incRef := TZUGFeRDIncludedReferencedProduct.Create;
    incRef.Name := XmlUtils._nodeAsString(nodes[i], './/ram:Name');
    incRef.UnitQuantity := XmlUtils._nodeAsDouble(nodes[i], './/ram:UnitQuantity', nil);
    if not unitCode.IsEmpty then
      incRef.UnitCode := TZUGFeRDQuantityCodesExtensions.FromString(unitCode)
    else
      incRef.UnitCode := nil;
    Result.IncludedReferencedProducts.Add(incRef);
  end;

  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument') <> nil) then
  begin
    Result.BuyerOrderReferencedDocument := TZUGFeRDBuyerOrderReferencedDocument.Create;
    Result.BuyerOrderReferencedDocument.ID := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument/ram:IssuerAssignedID');
    Result.BuyerOrderReferencedDocument.IssueDateTime:= DataTypeReader.ReadFormattedIssueDateTime(tradeLineItem,
      './/ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument/ram:FormattedIssueDateTime');
    Result.BuyerOrderReferencedDocument.LineID := XmlUtils._nodeAsString(tradeLineItem,
      './/ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument/ram:LineID');

  end;

  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument') <> nil) then
  begin
    Result.ContractReferencedDocument := TZUGFeRDContractReferencedDocument.Create;
    Result.ContractReferencedDocument.ID := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument/ram:IssuerAssignedID');
    var crdt := XMLUtils._nodeAsDateTime(tradeLineItem, './/ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString');
    if crdt.HasValue then
      Result.ContractReferencedDocument.IssueDateTime:= XMLUtils._nodeAsDateTime(tradeLineItem, './/ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString');
  end;

  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeSettlement') <> nil) then
  begin
    nodes := tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeSettlement').ChildNodes;
    for i := 0 to nodes.length-1 do
    begin
      if SameText(nodes[i].nodeName,'ram:ApplicableTradeTax') then
      begin
        //TODO
      end else
      if SameText(nodes[i].nodeName,'ram:BillingSpecifiedPeriod') then
      begin
        //TODO
      end else
      if SameText(nodes[i].nodeName,'ram:SpecifiedTradeAllowanceCharge') then
      begin
        var chargeIndicator : Boolean := XMLUtils._nodeAsBool(nodes[i], './ram:ChargeIndicator/udt:Indicator');
        var basisAmount := XMLUtils._nodeAsDecimal(nodes[i], './ram:BasisAmount', TZUGFeRDNullableParam<Currency>.Create(0));
        var basisAmountCurrency : String := XMLUtils._nodeAsString(nodes[i], './ram:BasisAmount/@currencyID');
        var actualAmount : Currency := XMLUtils._nodeAsDecimal(nodes[i], './ram:ActualAmount', TZUGFeRDNullableParam<Currency>.Create(0));
        var reason : String := XMLUtils._nodeAsString(nodes[i], './ram:Reason');
        var chargePercentage := XMLUtils._nodeAsDecimal(nodes[i], './ram:CalculationPercent', nil);
        var reasonCode: string := XMLUtils._nodeAsString(nodes[i], './ram:ReasonCode');

        Result.AddSpecifiedTradeAllowanceCharge(not chargeIndicator, // wichtig: das not beachten
                                        TZUGFeRDCurrencyCodesExtensions.FromString(basisAmountCurrency),
                                        basisAmount,
                                        actualAmount,
                                        chargePercentage,
                                        reason,
                                        TZUGFeRDAllowanceReasonCodesExtensions.FromString(reasonCode)
                                        );
      end else
      if SameText(nodes[i].nodeName,'ram:SpecifiedTradeSettlementLineMonetarySummation') then
      begin
        //TODO
      end else
      if SameText(nodes[i].nodeName,'ram:AdditionalReferencedDocument') then
      begin
       Result.AdditionalReferencedDocuments.Add(_readAdditionalReferencedDocument(nodes[i]));
      end else
      if SameText(nodes[i].nodeName,'ram:ReceivableSpecifiedTradeAccountingAccount') then
      begin
        var rstaaItem : TZUGFeRDReceivableSpecifiedTradeAccountingAccount :=
          TZUGFeRDReceivableSpecifiedTradeAccountingAccount.Create;
        rstaaItem.TradeAccountID := XMLUtils._nodeAsString(nodes[i], './/ram:ID');
        rstaaItem.TradeAccountTypeCode := TZUGFeRDAccountingAccountTypeCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:TypeCode'));
        Result.ReceivableSpecifiedTradeAccountingAccounts.Add(rstaaItem);
      end;
    end;
  end;

  if (tradeLineItem.SelectSingleNode('.//ram:AssociatedDocumentLineDocument') <> nil) then
  begin
    nodes := tradeLineItem.SelectNodes('.//ram:AssociatedDocumentLineDocument/ram:IncludedNote');
    for i := 0 to nodes.length-1 do
    begin
      var noteItem : TZUGFeRDNote := TZUGFeRDNote.Create(
          XMLUtils._nodeAsString(nodes[i], './/ram:Content'),
          TZUGFeRDSubjectCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:SubjectCode')),
          TZUGFeRDContentCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:ContentCode'))
        );
      Result.AssociatedDocument.Notes.Add(noteItem);
    end;
  end;

  nodes := tradeLineItem.SelectNodes('.//ram:SpecifiedLineTradeAgreement/ram:GrossPriceProductTradePrice/ram:AppliedTradeAllowanceCharge');
  for i := 0 to nodes.length-1 do
  begin

    var chargeIndicator : Boolean := XMLUtils._nodeAsBool(nodes[i], './ram:ChargeIndicator/udt:Indicator');
    var basisAmount := XMLUtils._nodeAsDecimal(nodes[i], './ram:BasisAmount', TZUGFeRDNullableParam<Currency>.Create(0));
    var basisAmountCurrency : String := XMLUtils._nodeAsString(nodes[i], './ram:BasisAmount/@currencyID');
    var actualAmount : Currency := XMLUtils._nodeAsDecimal(nodes[i], './ram:ActualAmount', TZUGFeRDNullableParam<Currency>.Create(0));
    var reason : String := XMLUtils._nodeAsString(nodes[i], './ram:Reason');
    var chargePercentage := XMLUtils._nodeAsDecimal(nodes[i], './ram:CalculationPercent', nil);

    Result.AddTradeAllowanceCharge(not chargeIndicator, // wichtig: das not beachten
                                    TZUGFeRDCurrencyCodesExtensions.FromString(basisAmountCurrency),
                                    basisAmount,
                                    actualAmount,
                                    chargePercentage,
                                    reason);
  end;

  if (Result.UnitCode = TZUGFeRDQuantityCodes.Unknown) then
  begin
    // UnitCode alternativ aus BilledQuantity extrahieren
    Result.UnitCode := TZUGFeRDQuantityCodesExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem, './/ram:BilledQuantity/@unitCode'));
  end;

  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:IssuerAssignedID') <> nil) then
  begin
    Result.DeliveryNoteReferencedDocument := TZUGFeRDDeliveryNoteReferencedDocument.Create;
    Result.DeliveryNoteReferencedDocument.ID := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedLineTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:IssuerAssignedID');
    Result.DeliveryNoteReferencedDocument.IssueDateTime:= XMLUtils._nodeAsDateTime(tradeLineItem, './/ram:SpecifiedLineTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString');
  end;

  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime') <> nil) then
  begin
    Result.ActualDeliveryDate:= XMLUtils._nodeAsDateTime(tradeLineItem, './/ram:SpecifiedLineTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString');
  end;

  //if (tradeLineItem.SelectSingleNode(".//ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument/ram:IssuerAssignedID", nsmgr) != null)
  //{
  //    item.ContractReferencedDocument = new ContractReferencedDocument()
  //    {
  //        ID = XMLUtils._nodeAsString(tradeLineItem, ".//ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument/ram:IssuerAssignedID", nsmgr),
  //        IssueDateTime = XMLUtils._nodeAsDateTime(tradeLineItem, ".//ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString", nsmgr),
  //    };
  //}

  nodes := TradeLineItem.SelectNodes('.//ram:DesignatedProductClassification');
  for i := 0 to nodes.length - 1 do
  begin
    var className := XMLUtils._nodeAsString(nodes[i], './/ram:ClassName');
    var classCode := XMLUtils._nodeAsString(nodes[i], './/ram:ClassCode');
    var listID := TZUGFeRDDesignatedProductClassificationCodesExtensions.FromString(
      XMLUtils._nodeAsString(nodes[i], './/ram:ClassCode/@listID'));
    var listVersionID :=  XMLUtils._nodeAsString(nodes[i], './/ram:ClassCode/@listVersionID');
    result.AddDesignatedProductClassification(listID, listVersionID, classCode, className);
  end;

  if (tradeLineItem.SelectSingleNode('.//ram:OriginTradeCountry//ram:ID') <> nil) then
    result.OriginTradeCountry := TZUGFeRDCountryCodesExtensions.FromString(XmlUtils._nodeAsString(tradeLineItem, './/ram:OriginTradeCountry//ram:ID'));
end;

end.
