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

unit intf.ZUGFeRDInvoiceDescriptor22UblReader;

interface

uses
  System.SysUtils, System.Classes, System.DateUtils, System.Math, System.Generics.Collections
  ,System.NetEncoding
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
  ;

type
  TZUGFeRDInvoiceDescriptor22UBLReader = class(TZUGFeRDInvoiceDescriptorReader)
  private
    function GetValidURIs : TArray<string>;
    function _parseTradeLineItem(tradeLineItem : IXmlDomNode; const parentLineID: string = ''):
      TList<TZUGFeRDTradeLineItem>;
    function _nodeAsLegalOrganization(basenode: IXmlDomNode; const xpath: string) : TZUGFeRDLegalOrganization;
    function _nodeAsParty(basenode: IXmlDomNode; const xpath: string) : TZUGFeRDParty;
    function _nodeAsAddressParty(baseNode: IXMLDomNode; const xpath: string) : TZUGFeRDParty;
    function _nodeAsBankAccount(baseNode: IXMLDomNode; const xpath: string): TZUGFeRDBankAccount;
    function _readAdditionalReferencedDocument(a_oXmlNode : IXmlDomNode) : TZUGFeRDAdditionalReferencedDocument;
//    function _getUncefactTaxSchemeID(const schemeID: string) : TZUGFeRDTaxRegistrationSchemeID;
    function _IsReadableByThisReaderVersion(stream: TStream; const validURIs: TArray<string>): Boolean; overload;
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

uses System.StrUtils, intf.ZUGFeRDDespatchAdviceReferencedDocument, System.Variants, intf.ZUGFeRDHelper,
  intf.ZUGFeRDDesignatedProductClassificationCodes, intf.ZUGFeRDXMLUtils,
  intf.UBLTaxRegistrationSchemeIDMapper, intf.ZUGFeRDAllowanceReasonCodes;

{ TZUGFeRDInvoiceDescriptor22UBLReader }

function TZUGFeRDInvoiceDescriptor22UBLReader.GetValidURIs : TArray<string>;
begin
  Result := TArray<string>.Create(
    'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2',
    'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2',
    'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2'
  );
end;

function TZUGFeRDInvoiceDescriptor22UBLReader.IsReadableByThisReaderVersion(
  stream: TStream): Boolean;
begin
  Result := _IsReadableByThisReaderVersion(stream, GetValidURIs);
end;

function TZUGFeRDInvoiceDescriptor22UBLReader.IsReadableByThisReaderVersion(
  xmldocument : IXMLDocument): Boolean;
begin
  Result := IsReadableByThisReaderVersion(xmldocument, GetValidURIs);
end;

function TZUGFeRDInvoiceDescriptor22UBLReader._IsReadableByThisReaderVersion(stream: TStream;
  const validURIs: TArray<string>): Boolean;
var
  oldStreamPosition: Int64;
  reader: TStreamReader;
  data: string;
  validURI: string;
begin
  Result := false;

  oldStreamPosition := stream.Position;
  stream.Position := 0;
  reader := TStreamReader.Create(stream, TEncoding.UTF8, True, 1024);
  try
    data := reader.ReadToEnd.Replace(' ', '').ToLower;
    for validURI in validURIs do
    begin
      if data.Contains(Format('="%s"', [validURI.ToLower])) then
      begin
        stream.Position := oldStreamPosition;
        Result := true;
        exit;
      end;
    end;
  finally
    reader.Free;
  end;

  stream.Position := oldStreamPosition;

(*

            long _oldStreamPosition = stream.Position;
            stream.Position = 0;
            using (StreamReader reader = new StreamReader(stream, Encoding.UTF8, true, 1024, true))
            {
                string data = reader.ReadToEnd().Replace(" ", "").ToLower();
                foreach (string validURI in validURIs)
                {
                    if (data.Contains(string.Format("=\"{0}\"", validURI.ToLower())))
                    {
                        stream.Position = _oldStreamPosition;
                        return true;
                    }
                }
            }

            stream.Position = _oldStreamPosition;
            return false;
*)
end;

function TZUGFeRDInvoiceDescriptor22UBLReader.Load(stream: TStream): TZUGFeRDInvoiceDescriptor;
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

function TZUGFeRDInvoiceDescriptor22UBLReader.Load(
  xmldocument : IXMLDocument): TZUGFeRDInvoiceDescriptor;
var
  doc : IXMLDOMDocument2;
  node : IXMLDOMNode;
  baseNode: IXMLDOMNode;
  nodes : IXMLDOMNodeList;
  i : Integer;
  id, schemeID: string;
  TaxSchemeID: TZUGFeRDTaxRegistrationSchemeID;
begin

  var firstPartOfDocument: string := LeftStr(xmlDocument.XML.Text, 1024);
  var isInvoice := True;

  if (firstPartOfDocument.IndexOf('<CreditNote') > -1) or
      (firstPartOfDocument.IndexOf('<ubl:CreditNote') > -1) or
        (firstPartOfDocument.IndexOf('<ns0:CreditNote') > -1) then
    isInvoice := False;

  if (isInvoice) then
    xmldocument.DocumentElement.DeclareNamespace('ubl',
      'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2')
  else
    xmldocument.DocumentElement.DeclareNamespace('ubl',
      'urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2');

  xmldocument.DocumentElement.DeclareNamespace('cac',
    'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2');
  xmldocument.DocumentElement.DeclareNamespace('cbc',
    'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2');

  doc := TZUGFeRDXmlHelper.PrepareDocumentForXPathQuerys(xmldocument);

  var typeSelector: string := '//cbc:InvoiceTypeCode';
  var tradeLineItemSelector: string := '//cac:InvoiceLine';

  if isInvoice then
  begin
    baseNode := doc.selectSingleNode('/ubl:Invoice');
    if baseNode = nil then
      baseNode := doc.selectSingleNode('/Invoice');
  end
  else begin
    typeSelector := '//cbc:CreditNoteTypeCode';
    tradeLineItemSelector := '//cac:CreditNoteLine';
    baseNode := doc.SelectSingleNode('/ubl:CreditNote');
    if (baseNode = nil) then
      baseNode := doc.SelectSingleNode('/CreditNote');
    if (baseNode = nil) then
      baseNode := doc.SelectSingleNode('ns0:CreditNote');
  end;

  Result := TZUGFeRDInvoiceDescriptor.Create;

  Result.IsTest := XMLUtils._nodeAsBool(doc.DocumentElement, '//cbc:TestIndicator', false);
  Result.BusinessProcess := XMLUtils._nodeAsString(doc.DocumentElement, '//cbc:ProfileID');
  Result.Profile := TZUGFeRDProfile.XRechnung; //TZUGFeRDProfileExtensions.FromString(XMLUtils._nodeAsString(doc.DocumentElement, '//ram:GuidelineSpecifiedDocumentContextParameter/ram:ID'));//, nsmgr)),
  Result.Type_ := TZUGFeRDInvoiceTypeExtensions.FromString(XMLUtils._nodeAsString(doc.DocumentElement, '//cbc:InvoiceTypeCode'));
  Result.InvoiceNo := XMLUtils._nodeAsString(doc.DocumentElement, '//cbc:ID');
  Result.InvoiceDate := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//cbc:IssueDate');
  Result.Type_ := TZUGFeRDInvoiceTypeExtensions.FromString(XMLUtils._nodeAsString(doc.DocumentElement, typeSelector));

  nodes := baseNode.selectNodes('cbc:Note');
  for i := 0 to nodes.length-1 do
  begin
    var content : String := XMLUtils._nodeAsString(nodes[i], '.');
    if content.IsNullOrWhiteSpace(content) then
      continue;
    var contentParts: TArray<string> := content.Split(['#'], TStringSplitOptions.ExcludeEmpty);
    var _subjectCode := '';
    if ((Length(contentParts) > 1) and (contentParts[0].Length = 3)) then
    begin
      _subjectCode := contentParts[0];
      content := contentParts[1];
    end;
    var subjectCode := TZUGFeRDSubjectCodesExtensions.FromString(_subjectCode);
    Result.AddNote(Content, subjectCode);
  end;

  Result.ReferenceOrderNo := XMLUtils._nodeAsString(doc, '//cbc:BuyerReference');

  Result.Seller := _nodeAsParty(doc.DocumentElement, '//cac:AccountingSupplierParty/cac:Party');

  if doc.selectSingleNode('//cac:AccountingSupplierParty/cac:Party/cbc:EndpointID') <> nil then
  begin
    id := XMLUtils._nodeAsString(doc.DocumentElement, '//cac:AccountingSupplierParty/cac:Party/cbc:EndpointID');
    schemeID := XMLUtils._nodeAsString(doc.DocumentElement, '//cac:AccountingSupplierParty/cac:Party/cbc:EndpointID/@schemeID');

    var eas : TZUGFeRDElectronicAddressSchemeIdentifiers :=
       TZUGFeRDElectronicAddressSchemeIdentifiersExtensions.FromString(schemeID);

    if (eas <> TZUGFeRDElectronicAddressSchemeIdentifiers.Unknown) then
      Result.SetSellerElectronicAddress(id, eas);
  end;

  nodes := doc.selectNodes('//cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme');
  for i := 0 to nodes.length-1 do
  begin
    id := XMLUtils._nodeAsString(nodes[i], './/cbc:CompanyID');
    TAXSchemeID :=
      TUBLTaxRegistrationSchemeIDMapper.Map(XmlUtils._NodeAsString(node, './/cac:TaxScheme/cbc:ID'));
    Result.AddSellerTaxRegistration(id, TaxSchemeID);
  end;

  if (doc.selectSingleNode('//cac:AccountingSupplierParty/cac:Party/cac:Contact') <> nil) then
  begin
    Result.SellerContact := TZUGFeRDContact.Create;
    Result.SellerContact.Name := XMLUtils._nodeAsString(doc.DocumentElement, '//cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Name');
    Result.SellerContact.OrgUnit := ''; //TODO: Find value //OrgUnit = XMLUtils._nodeAsString(doc.DocumentElement, "//cac:AccountingSupplierParty/cac:Party/ram:DefinedTradeContact/ram:DepartmentName", nsmgr),
    Result.SellerContact.PhoneNo := XMLUtils._nodeAsString(doc.DocumentElement, '//cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Telephone');
    Result.SellerContact.FaxNo := ''; // TODO: Find value //FaxNo = XMLUtils._nodeAsString(doc.DocumentElement, "//cac:AccountingSupplierParty/cac:Party/cac:Contact/", nsmgr),
    Result.SellerContact.EmailAddress := XMLUtils._nodeAsString(doc.DocumentElement, '//cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:ElectronicMail');
  end;

  Result.Buyer := _nodeAsParty(doc.DocumentElement, '//cac:AccountingCustomerParty/cac:Party');

  if (doc.SelectSingleNode('//cac:AccountingCustomerParty/cac:Party/cbc:EndpointID') <> nil) then
  begin
    id := XMLUtils._nodeAsString(doc.DocumentElement, '//cac:AccountingCustomerParty/cac:Party/cbc:EndpointID');
    schemeID := XMLUtils._nodeAsString(doc.DocumentElement, '//cac:AccountingCustomerParty/cac:Party/cbc:EndpointID/@schemeID');

    var eas : TZUGFeRDElectronicAddressSchemeIdentifiers := TZUGFeRDElectronicAddressSchemeIdentifiersExtensions.FromString(schemeID);

    if (eas <> TZUGFeRDElectronicAddressSchemeIdentifiers.Unknown) then
      Result.SetBuyerElectronicAddress(id, eas);
  end;

  nodes := doc.selectNodes('//cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme');
  for i := 0 to nodes.length-1 do
  begin
    id := XMLUtils._nodeAsString(nodes[i], './/cbc:CompanyID');
    TaxSchemeID :=
      TUBLTaxRegistrationSchemeIDMapper.Map(XmlUtils._NodeAsString(node, './/cac:TaxScheme/cbc:ID'));
    Result.AddBuyerTaxRegistration(id, TaxSchemeID);
  end;

  if (doc.SelectSingleNode('//cac:AccountingCustomerParty/cac:Party/cac:Contact') <> nil) then
  begin
    Result.BuyerContact := TZUGFeRDContact.Create;
    Result.SetBuyerContact(
      XMLUtils._nodeAsString(doc.DocumentElement, '//cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:Name'),
      '', //TODO   XMLUtils._nodeAsString(doc.DocumentElement, '//ram:BuyerTradeParty/ram:DefinedTradeContact/ram:DepartmentName'),
      XMLUtils._nodeAsString(doc.DocumentElement, '//cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:ElectronicMail'),
      XMLUtils._nodeAsString(doc.DocumentElement, '//cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:Telephone'),
      '' //TODO XMLUtils._nodeAsString(doc.DocumentElement, '//ram:BuyerTradeParty/ram:DefinedTradeContact/ram:FaxUniversalCommunication/ram:CompleteNumber')
    );
  end;

  Result.SellerTaxRepresentative := _nodeAsParty(doc.DocumentElement, '//cac:TaxRepresentativeParty/cac:Party');

//  //-------------------------------------------------
//  // hzi: With old implementation only the first document has been read instead of all documents
//  //-------------------------------------------------
//  //if (doc.SelectSingleNode("//ram:AdditionalReferencedDocument') != null)
//  //{
//  //    string _issuerAssignedID := XMLUtils._nodeAsString(doc, "//ram:AdditionalReferencedDocument/ram:IssuerAssignedID');
//  //    string _typeCode := XMLUtils._nodeAsString(doc, "//ram:AdditionalReferencedDocument/ram:TypeCode');
//  //    string _referenceTypeCode := XMLUtils._nodeAsString(doc, "//ram:AdditionalReferencedDocument/ram:ReferenceTypeCode');
//  //    string _name := XMLUtils._nodeAsString(doc, "//ram:AdditionalReferencedDocument/ram:Name');
//  //    DateTime? _date := XMLUtils._nodeAsDateTime(doc.DocumentElement, "//ram:AdditionalReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString');
//
//  //    if (doc.SelectSingleNode("//ram:AdditionalReferencedDocument/ram:AttachmentBinaryObject') != null)
//  //    {
//  //        string _filename := XMLUtils._nodeAsString(doc, "//ram:AdditionalReferencedDocument/ram:AttachmentBinaryObject/@filename');
//  //        byte[] data := Convert.FromBase64String(XMLUtils._nodeAsString(doc, "//ram:AdditionalReferencedDocument/ram:AttachmentBinaryObject'));
//
//  //        Result.AddAdditionalReferencedDocument(id: _issuerAssignedID,
//  //                                               typeCode: default(AdditionalReferencedDocumentTypeCode).FromString(_typeCode),
//  //                                               issueDateTime: _date,
//  //                                               referenceTypeCode: default(ReferenceTypeCodes).FromString(_referenceTypeCode),
//  //                                               name: _name,
//  //                                               attachmentBinaryObject: data,
//  //                                               filename: _filename);
//  //    }
//  //    else
//  //    {
//  //        Result.AddAdditionalReferencedDocument(id: _issuerAssignedID,
//  //                                               typeCode: default(AdditionalReferencedDocumentTypeCode).FromString(_typeCode),
//  //                                               issueDateTime: _date,
//  //                                               referenceTypeCode: default(ReferenceTypeCodes).FromString(_referenceTypeCode),
//  //                                               name: _name);
//  //    }
//  //}
//  //-------------------------------------------------

  var deliveryNode := doc.SelectSingleNode('//cac:Delivery');
  if deliveryNode <> nil then
  begin
    var deliveryLocationNode := deliveryNode.SelectSingleNode('//cac:DeliveryLocation');
    if (deliveryLocationNode <> nil) then
    begin
        Result.ShipTo := _nodeAsAddressParty(deliveryNode, './/cac:Address'); // ?? new Party();
        If Result.ShipTo = nil then
          Result.ShipTo := TZUGFeRDParty.Create;
        Result.ShipTo.GlobalID := TZUGFeRDGlobalID.Create;
        Result.ShipTo.ID := TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiersExtensions.FromString(
          XMLUtils._nodeAsString(deliveryLocationNode, './/cbc:ID/@schemeID')), XMLUtils._nodeAsString(deliveryLocationNode, './/cbc:ID'));
        Result.ShipTo.Name := XMLUtils._nodeAsString(deliveryNode, './/cac:DeliveryParty/cac:PartyName/cbc:Name');
    end;
    Result.ActualDeliveryDate := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//cac:Delivery/cbc:ActualDeliveryDate');
  end;

//TODO: Find value  Result.ShipTo := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:ShipToTradeParty');
//TODO: Find value  Result.ShipFrom := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:ShipFromTradeParty');
//TODO: Find value  Result.ActualDeliveryDate.SetValue(XMLUtils._nodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString'));

(*
  var _despatchAdviceNo : String := XMLUtils._nodeAsString(doc.DocumentElement, '//cac:ApplicableHeaderTradeDelivery/cac:DespatchAdviceReferencedDocument/cbc:Id');
  var _despatchAdviceDate := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//cac:ApplicableHeaderTradeDelivery/cac:DespatchAdviceReferencedDocument/cbc:IssueDate');

  if ((_despatchAdviceDate.HasValue) or (_despatchAdviceNo <> '')) then
  begin
    Result.DespatchAdviceReferencedDocument := TZUGFeRDDespatchAdviceReferencedDocument.Create;
    Result.SetDespatchAdviceReferencedDocument(_despatchAdviceNo,_despatchAdviceDate);
  end;
*)

//TODO: Find value  Result.Invoicee := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:InvoiceeTradeParty');
  Result.Payee := _nodeAsParty(doc.DocumentElement, '//cac:PayeeParty');

  Result.PaymentReference := XMLUtils._nodeAsString(doc.DocumentElement, '//cac:PaymentMeans/cbc:PaymentID');
  Result.Currency :=  TZUGFeRDCurrencyCodesExtensions.FromString(
    XMLUtils._nodeAsString(doc.DocumentElement, '//cbc:DocumentCurrencyCode'));

  var optionalTaxCurrency := TZUGFeRDCurrencyCodesExtensions.FromString(
    XMLUtils._nodeAsString(doc.DocumentElement, '//cbc:TaxCurrencyCode')); // BT-6
  if (optionalTaxCurrency <> TZUGFeRDCurrencyCodes.Unknown) then
    Result.TaxCurrency := optionalTaxCurrency;

// TODO: Multiple SpecifiedTradeSettlementPaymentMeans can exist for each account/institution (with different SEPA?)
  var _tempPaymentMeans : TZUGFeRDPaymentMeans := TZUGFeRDPaymentMeans.Create;
  _tempPaymentMeans.TypeCode := TZUGFeRDPaymentMeansTypeCodesExtensions.FromString(
    XMLUtils._nodeAsString(doc.DocumentElement, '//cac:PaymentMeans/cbc:PaymentMeansCode'));
  _tempPaymentMeans.Information := XMLUtils._nodeAsString(doc.DocumentElement,
    '//cac:PaymentMeans/cbc:PaymentMeansCode/@name');
  _tempPaymentMeans.SEPACreditorIdentifier := XMLUtils._nodeAsString(doc.DocumentElement,
    '//cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID=''SEPA'']');
  _tempPaymentMeans.SEPAMandateReference := XMLUtils._nodeAsString(doc.DocumentElement,
    '//cac:PaymentMeans/cac:PaymentMandate/cbc:ID');

  var financialCardId : String := XMLUtils._nodeAsString(doc.DocumentElement,
    '//cac:PaymentMeans/cac:CardAccount/cbc:PrimaryAccountNumberID');
  var financialCardCardholderName : String := XMLUtils._nodeAsString(doc.DocumentElement,
    '//cac:PaymentMeans/cac:CardAccount/cbc:HolderName');

  if ((financialCardId <> '') or (financialCardCardholderName <> '')) then
  begin
    _tempPaymentMeans.FinancialCard := TZUGFeRDFinancialCard.Create;
    _tempPaymentMeans.FinancialCard.Id := financialCardId;
    _tempPaymentMeans.FinancialCard.CardholderName := financialCardCardholderName;
  end;

  Result.PaymentMeans := _tempPaymentMeans;

  //TODO udt:DateTimeString
  Result.BillingPeriodStart := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//cac:InvoicePeriod/cbc:StartDate');
  Result.BillingPeriodEnd := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//cac:InvoicePeriod/cbc:EndDate');

  var creditorFinancialAccountNodes : IXMLDOMNodeList := doc.SelectNodes('//cac:PaymentMeans/cac:PayeeFinancialAccount');
  for i := 0 to creditorFinancialAccountNodes.Length - 1 do
    Result.CreditorBankAccounts.Add(_nodeAsBankAccount(creditorFinancialAccountNodes[i], '.'));

  var debitorFinancialAccountNodes : IXMLDOMNodeList := doc.SelectNodes(
    '//cac:PaymentMeans/cac:PaymentMandate/cac:PayerFinancialAccount');
  for i := 0 to debitorFinancialAccountNodes.Length - 1 do
    Result.DebitorBankAccounts.Add(_nodeAsBankAccount(debitorFinancialAccountNodes[i], '.'));

  nodes := doc.SelectNodes('//cac:TaxTotal/cac:TaxSubtotal');
  for i := 0 to nodes.length-1 do
  begin
    Result.AddApplicableTradeTax(
          XMLUtils._nodeAsDecimal(nodes[i], 'cbc:TaxableAmount'),
          XMLUtils._nodeAsDecimal(nodes[i], 'cac:TaxCategory/cbc:Percent'),
          XmlUtils._nodeAsDecimal(nodes[i], 'cbc:TaxAmount'),
          TZUGFeRDTaxTypesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], 'cac:TaxCategory/cac:TaxScheme/cbc:ID')),
          TZUGFeRDNullableParam<TZUGFeRDTaxCategoryCodes>.Create(
          TZUGFeRDTaxCategoryCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], 'cac:TaxCategory/cbc:ID'))),
          nil,
          TZUGFeRDTaxExemptionReasonCodesExtensions.FromString(
                  XMLUtils._nodeAsString(nodes[i], 'cac:TaxCategory/cbc:TaxExemptionReasonCode')),
          XMLUtils._nodeAsString(nodes[i], 'cac:TaxCategory/cbc:TaxExemptionReason')
          );
  end;

  nodes := doc.SelectNodes('//cac:AllowanceCharge');
  for i := 0 to nodes.length-1 do
  begin
    Result.AddTradeAllowanceCharge(not XMLUtils._nodeAsBool(nodes[i], './/cbc:ChargeIndicator', True), // wichtig: das not (!) beachten
                                   XMLUtils._nodeAsDecimal(nodes[i], './/cbc:BaseAmount',
                                    TZUGFeRDNullableParam<Currency>.Create(0)),
                                   Result.Currency,
                                   XMLUtils._nodeAsDecimal(nodes[i], './/cbc:Amount',
                                    TZUGFeRDNullableParam<Currency>.Create(0)),
                                   XMLUtils._nodeAsString(nodes[i], './/cbc:AllowanceChargeReason'),
                                   TZUGFeRDTaxTypesExtensions.FromString(XMLUtils._nodeAsString(nodes[i],
                                    './/cac:TaxCategory/cac:TaxScheme/cbc:ID')),
                                   TZUGFeRDTaxCategoryCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i],
                                    './/cac:TaxCategory/cbc:ID')),
                                   XMLUtils._nodeAsDecimal(nodes[i], './/cac:TaxCategory/cbc:Percent',
                                    TZUGFeRDNullableParam<Currency>.Create(0)),
                                   TZUGFeRDAllowanceReasonCodesExtensions.FromString(XmlUtils._nodeAsString(
                                    nodes[i], './cbc:AllowanceChargeReasonCode'))
                                    );
  end;

// TODO: Find value
//  nodes := doc.SelectNodes('//ram:SpecifiedLogisticsServiceCharge');
//  for i := 0 to nodes.length-1 do
//  begin
//    Result.AddLogisticsServiceCharge(_nodeAsDecimal(nodes[i], './/ram:AppliedAmount', 0),
//                                     XMLUtils._nodeAsString(nodes[i], './/ram:Description'),
//                                     TZUGFeRDTaxTypesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:AppliedTradeTax/ram:TypeCode')),
//                                     TZUGFeRDTaxCategoryCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:AppliedTradeTax/ram:CategoryCode')),
//                                     _nodeAsDecimal(nodes[i], './/ram:AppliedTradeTax/ram:RateApplicablePercent', 0));
//  end;

  nodes := doc.DocumentElement.SelectNodes('//cac:BillingReference/cac:InvoiceDocumentReference');
  for i := 0 to nodes.length - 1 do
  begin
    Result.AddInvoiceReferencedDocument(
      XMLUtils._nodeAsString(nodes[i], './cbc:ID'),
      XMLUtils._nodeAsDateTime(nodes[i], './cbc:IssueDate')
    );
    break; // only one occurrence allowed in UBL
  end;

  var despatchDocumentReferenceIdNode := baseNode.SelectSingleNode('./cac:DespatchDocumentReference/cbc:ID');
  if (despatchDocumentReferenceIdNode <> nil) then
    Result.SetDespatchAdviceReferencedDocument(despatchDocumentReferenceIdNode.Text);

  var _PaymentTerms := TZUGFeRDPaymentTerms.Create;
  _PaymentTerms.Description := XMLUtils._nodeAsString(doc.DocumentElement, '//cac:PaymentTerms/cbc:Note');
  _PaymentTerms.DueDate := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//cbc:DueDate');
  Result.PaymentTermsList.Add(_PaymentTerms);

  Result.LineTotalAmount := XMLUtils._nodeAsDecimal(doc.DocumentElement, '//cac:LegalMonetaryTotal/cbc:LineExtensionAmount',
    TZUGFeRDNullableParam<Currency>.Create(0));
  Result.ChargeTotalAmount := XMLUtils._nodeAsDecimal(doc.DocumentElement, '//cac:LegalMonetaryTotal/cbc:ChargeTotalAmount', nil);
  Result.AllowanceTotalAmount := XMLUtils._nodeAsDecimal(doc.DocumentElement, '//cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount', nil);
  Result.TaxBasisAmount := XMLUtils._NodeAsDecimal(doc.DocumentElement, '//cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount', nil);
  Result.TaxTotalAmount := XMLUtils._NodeAsDecimal(doc.DocumentElement, '//cac:TaxTotal/cbc:TaxAmount', TZUGFeRDNullableParam<Currency>.Create(0));
  Result.GrandTotalAmount := XMLUtils._NodeAsDecimal(doc.DocumentElement, '//cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount', TZUGFeRDNullableParam<Currency>.Create(0));
  Result.RoundingAmount := XMLUtils._NodeAsDecimal(doc.DocumentElement, '//cac:LegalMonetaryTotal/cbc:PayableRoundingAmount', TZUGFeRDNullableParam<Currency>.Create(0));
  Result.TotalPrepaidAmount := XMLUtils._NodeAsDecimal(doc.DocumentElement, '//cac:LegalMonetaryTotal/cbc:PrepaidAmount', nil);
  Result.DuePayableAmount := XMLUtils._NodeAsDecimal(doc.DocumentElement, '//cac:LegalMonetaryTotal/cbc:PayableAmount', TZUGFeRDNullableParam<Currency>.Create(0));

//TODO: Find value   nodes := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:ReceivableSpecifiedTradeAccountingAccount');
//  for i := 0 to nodes.length-1 do
//  begin
//    var item : TZUGFeRDReceivableSpecifiedTradeAccountingAccount :=
//      TZUGFeRDReceivableSpecifiedTradeAccountingAccount.Create;
//    item.TradeAccountID := XMLUtils._nodeAsString(nodes[i], './/ram:ID');
//    item.TradeAccountTypeCode := TZUGFeRDAccountingAccountTypeCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:TypeCode'));
//    Result.ReceivableSpecifiedTradeAccountingAccounts.Add(item);
//  end;

// TODO: Find value  Result.OrderDate.SetValue(XMLUtils._nodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:BuyerOrderReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString'));
  Result.OrderNo := XMLUtils._nodeAsString(doc.DocumentElement, '//cac:OrderReference/cbc:ID');
  //Result.OrderDate := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//cac:OrderReference/cbc:IssueDate');

  // Read SellerOrderReferencedDocument
  node := doc.SelectSingleNode('//cac:OrderReference/cbc:SalesOrderID');
  if node <> nil then
  begin
    Result.SellerOrderReferencedDocument := TZUGFeRDSellerOrderReferencedDocument.Create;
    Result.SellerOrderReferencedDocument.ID := XMLUtils._nodeAsString(doc.DocumentElement, '//cac:OrderReference/cbc:SalesOrderID');
    // unclear how to map
    //    IssueDateTime = XmlUtils.NodeAsDateTime(tradeLineItem, ".//ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString", nsmgr),
    //    LineID = XmlUtils.NodeAsString(tradeLineItem, ".//ram:SpecifiedSupplyChainTradeAgreement/ram:BuyerOrderReferencedDocument/ram:LineID", nsmgr),
  end;

  // Read ContractReferencedDocument
  if (doc.SelectSingleNode('//cac:ContractDocumentReference/cbc:ID') <> nil) then
  begin
    Result.ContractReferencedDocument := TZUGFeRDContractReferencedDocument.Create;
    Result.ContractReferencedDocument.ID := XMLUtils._nodeAsString(doc.DocumentElement, '//cac:ContractDocumentReference/cbc:ID');
    Result.ContractReferencedDocument.IssueDateTime := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//cac:ContractDocumentReference/cbc:IssueDate');
  end;

  nodes := doc.SelectNodes('//cac:AdditionalDocumentReference');
  for i := 0 to nodes.length - 1 do
  begin
    Result.AdditionalReferencedDocuments.Add(_readAdditionalReferencedDocument(nodes[i]));
  end;

  Result.SpecifiedProcuringProject := TZUGFeRDSpecifiedProcuringProject.Create;
  Result.SpecifiedProcuringProject.ID := XMLUtils._nodeAsString(doc.DocumentElement, '//cac:ProjectReference/cbc:ID');
  Result.SpecifiedProcuringProject.Name := ''; //TODO: Find value XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:SpecifiedProcuringProject/ram:Name');

  nodes := doc.SelectNodes(tradeLineItemSelector);
  for i := 0 to nodes.length-1 do
  begin
    var List := _parseTradeLineItem(nodes[i]);
    try
      for var Item in List do
        Result.TradeLineItems.Add(Item);
    finally
      List.Free;
    end;
  end;
end;

function TZUGFeRDInvoiceDescriptor22UBLReader._readAdditionalReferencedDocument(
  a_oXmlNode: IXmlDomNode): TZUGFeRDAdditionalReferencedDocument;
begin

  Result := TZUGFeRDAdditionalReferencedDocument.Create(false);
  Result.ID := XMLUtils._nodeAsString(a_oXmlNode, './/cbc:ID');
  Result.ReferenceTypeCode := TZUGFeRDReferenceTypeCodesExtensions.FromString(XMLUtils._nodeAsString(a_oXmlNode, './/cbc:ID/@schemeID'));
  Result.TypeCode := TZUGFeRDAdditionalReferencedDocumentTypeCodeExtensions.FromString(XMLUtils._nodeAsString(a_oXmlNode, './/cbc:DocumentTypeCode'));
  Result.Name := XMLUtils._nodeAsString(a_oXmlNode, './/cbc:DocumentDescription');

  var strBase64BinaryData : String := XMLUtils._nodeAsString(a_oXmlNode, './/cac:Attachment/cbc:EmbeddedDocumentBinaryObject');
  if strBase64BinaryData <> '' then
  begin
    Result.Filename := XMLUtils._nodeAsString(a_oXmlNode, './/cac:Attachment/cbc:EmbeddedDocumentBinaryObject/@filename');
    Result.AttachmentBinaryObject := TMemoryStream.Create;
    var strBase64BinaryDataBytes : TBytes := TNetEncoding.Base64String.DecodeStringToBytes(strBase64BinaryData);
    Result.AttachmentBinaryObject.Write(strBase64BinaryDataBytes,Length(strBase64BinaryDataBytes));
    Result.AttachmentBinaryObject.Position := 0;
  end;
end;

{
function TZUGFeRDInvoiceDescriptor22UBLReader._getUncefactTaxSchemeID(
  const schemeID: string): TZUGFeRDTaxRegistrationSchemeID;
begin
  if (schemeID.IsNullOrWhiteSpace(schemeID)) then
    exit(TZUGFeRDTaxRegistrationSchemeID.Unknown);

// Mandatory element.
// For Seller VAT identifier (BT-31), use value “VAT”,
// for the seller tax registration identifier (BT-32), use != "VAT"
  (*if schemeID.ToUpper = 'ID' then
    result := TZUGFeRDTaxRegistrationSchemeID.FC;*)
  if schemeID.ToUpper = 'VAT' then
    result := TZUGFeRDTaxRegistrationSchemeID.VA
  else
    result := TZUGFeRDTaxRegistrationSchemeID.FC
end;
}

function TZUGFeRDInvoiceDescriptor22UBLReader._nodeAsAddressParty(baseNode: IXMLDomNode;
  const xpath: string): TZUGFeRDParty;
var
  node : IXmlDomNode;
begin
  Result := nil;
  if (baseNode = nil) then
    exit;
  node := baseNode.SelectSingleNode(xpath);
  if (node = nil) then
    exit;


  var retval := TZUGFeRDParty.Create;
  retval.Street := XMLUtils._nodeAsString(node, 'cbc:StreetName');
  retval.AddressLine3 := XMLUtils._nodeAsString(node, 'cbc:AdditionalStreetName');
  retval.City := XMLUtils._nodeAsString(node, 'cbc:CityName');
  retval.Postcode := XMLUtils._nodeAsString(node, 'cbc:PostalZone');
  retval.CountrySubdivisionName := XMLUtils._nodeAsString(node, 'cbc:CountrySubentity');
  retval.Country := TZUGFeRDCountryCodesExtensions.FromString(XMLUtils._nodeAsString(node, 'cac:Country/cbc:IdentificationCode'));

  var addressLine2: string  := XMLUtils._nodeAsString(node, 'cac:AddressLine/cbc:Line');
  if not string.IsNullOrWhiteSpace(addressLine2) then
  begin
    if string.IsNullOrWhiteSpace(retval.AddressLine3) then
      retval.AddressLine3 := addressLine2
    else if not string.IsNullOrWhiteSpace(addressLine2) AND string.IsNullOrWhiteSpace(retval.ContactName) then
      retval.ContactName := addressLine2;
  end;
  result := retval;
end;

function TZUGFeRDInvoiceDescriptor22UBLReader._nodeAsBankAccount(baseNode: IXMLDomNode;
  const xpath: string): TZUGFeRDBankAccount;
var
  node: IXMLDomNode;
begin
  Result := nil;
  if basenode = nil then
    exit;
  node := baseNode.SelectSingleNode(xpath);
  if (node = nil) then
    exit;

  result := TZUGFeRDBankAccount.Create;
  result.Name := XMLUtils._nodeAsString(node, 'cbc:Name');
  result.IBAN := XMLUtils._nodeAsString(node, 'cbc:ID');
  result.BIC := XMLUtils._nodeAsString(node, 'cac:FinancialInstitutionBranch/cbc:ID');
  result.BankName := XMLUtils._nodeAsString(node, 'cac:FinancialInstitutionBranch/cbc:Name');
  result.ID := '';
end;

function TZUGFeRDInvoiceDescriptor22UBLReader._nodeAsLegalOrganization(
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
      TZUGFeRDGlobalIDSchemeIdentifiersExtensions.FromString(XMLUtils._nodeAsString(node, 'cbc:CompanyID/@schemeID')),
      XMLUtils._nodeAsString(node, 'cbc:CompanyID'),
      XMLUtils._nodeAsString(node, 'cbc:RegistrationName'));
end;

function TZUGFeRDInvoiceDescriptor22UBLReader._nodeAsParty(basenode: IXmlDomNode;
  const xpath: string) : TZUGFeRDParty;
var
  node : IXmlDomNode;
begin
  Result := nil;
  if (baseNode = nil) then
    exit;
  node := baseNode.SelectSingleNode(xpath);
  if (node = nil) then
    exit;


  var retval: TZUGFeRDParty := _nodeAsAddressParty(node, xpath + '/cac:PostalAddress');
  if retval = nil then
    retval := TZUGFeRDParty.Create;

  var id := TZUGFeRDGlobalID.CreateWithParams(TZUGFeRDGlobalIDSchemeIdentifiersExtensions.FromString(
    XMLUtils._nodeAsString(node, 'cac:PartyIdentification/cbc:ID/@schemeID')),
    XMLUtils._nodeAsString(node, 'cac:PartyIdentification/cbc:ID'));

  if id.SchemeID = TZUGFeRDGlobalIDSchemeIdentifiers.GLN then
  begin
    retval.ID := TZUGFeRDGlobalID.Create;
    retval.GlobalID := id;
  end
  else begin
    retval.ID := id;
    retval.GlobalID := TZUGFeRDGlobalID.Create;
  end;

  retval.Name := XMLUtils._nodeAsString(node, 'cac:PartyName/cbc:Name');
  retval.SpecifiedLegalOrganization := _nodeAsLegalOrganization(node, 'cac:PartyLegalEntity');

  if string.IsNullOrWhiteSpace(retval.Name) then
    retval.Name := XMLUtils._nodeAsString(node, 'cac:PartyLegalEntity/cbc:RegistrationName');

  if string.IsNullOrWhiteSpace(retval.Description) then
    retval.Description := XmlUtils._nodeAsString(node, 'cac:PartyLegalEntity/cbc:CompanyLegalForm');

  if string.IsNullOrWhiteSpace(retval.ContactName) then
    retval.ContactName := '';

  if string.IsNullOrEmpty(retval.AddressLine3) then
    retval.AddressLine3 := '';

  if string.IsNullOrEmpty(retval.CountrySubdivisionName) then
    retval.CountrySubdivisionName := '';

  if (string.IsNullOrEmpty(retval.City)) then
    retval.City := '';

  if (string.IsNullOrEmpty(retval.Postcode)) then
    retval.Postcode := '';

  if (string.IsNullOrEmpty(retval.Street)) then
    retval.Street := '';

  result := retval;
end;

function TZUGFeRDInvoiceDescriptor22UBLReader._parseTradeLineItem(tradeLineItem : IXmlDomNode;
  const parentLineID: string = ''): TList<TZUGFeRDTradeLineItem>;

var
  nodes : IXMLDOMNodeList;
  i : Integer;
  unitCode: TZUGFeRDQuantityCodes;
begin
  Result := nil;

  if (tradeLineItem = nil) then
    exit;

  result := TList<TZUGFeRDTradeLineItem>.create;

  var lineId := XmlUtils._NodeAsString(tradeLineItem, './/cbc:ID');
  var isInvoice := XmlUtils._NodeExists(tradeLineItem, './/cbc:InvoicedQuantity');
  var BilledQuantity: ZUGFeRDNullable<Currency> := nil;
  if isInvoice then
    BilledQuantity := XMLUtils._NodeasDecimal(TradeLineItem, './/cbc:InvoicedQuantity')
  else
    BilledQuantity := XMLUtils._NodeasDecimal(TradeLineItem, './/cbc:CreditedQuantity');
  if isInvoice then
    unitCode := TZUGFeRDQuantityCodesExtensions.FromString(XmlUtils._NodeAsString(TradeLineItem, './/cbc:InvoicedQuantity/@unitCode'))
  else
    unitCode := TZUGFeRDQuantityCodesExtensions.FromString(XmlUtils._NodeAsString(TradeLineItem, './/cbc:CreditedQuantity/@unitCode'));

  var Item := TZUGFerDTradeLineItem.Create(lineID);
  Item.GlobalID.ID :=  XMLUtils._nodeAsString(tradeLineItem, './cac:Item/cac:StandardItemIdentification/cbc:ID');
  Item.GlobalID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiersExtensions.FromString(
    XMLUtils._nodeAsString(tradeLineItem, './cac:Item/cac:StandardItemIdentification/cbc:ID/@schemeID'));
  Item.SellerAssignedID := XMLUtils._nodeAsString(tradeLineItem, './/cac:Item/cac:SellersItemIdentification/cbc:ID');
  Item.BuyerAssignedID := XMLUtils._nodeAsString(tradeLineItem, './/cac:Item/cac:BuyersItemIdentification/cbc:ID');
  Item.Name := XMLUtils._nodeAsString(tradeLineItem, './/cac:Item/cbc:Name');
  Item.Description := XMLUtils._nodeAsString(tradeLineItem, './/cac:Item/cbc:Description');
  Item.UnitQuantity := XMLUtils._nodeAsDouble(tradeLineItem, './/cac:Price/cbc:BaseQuantity', TZUGFeRDNullableParam<Double>.Create(1));
  if BilledQuantity.HasValue then
    Item.BilledQuantity := BilledQuantity.Value
  else
    Item.BilledQuantity := 0.00;
  Item.LineTotalAmount := XMLUtils._nodeAsDouble(tradeLineItem, './/cbc:LineExtensionAmount', TZUGFeRDNullableParam<Double>.Create(0));
  Item.TaxCategoryCode := TZUGFeRDTaxCategoryCodesExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem, './/cac:Item/cac:ClassifiedTaxCategory/cbc:ID'));
  Item.TaxType := TZUGFeRDTaxTypesExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem, './/cac:Item/cac:ClassifiedTaxCategory/cac:TaxScheme/cbc:ID'));
  Item.TaxPercent := XMLUtils._nodeAsDouble(tradeLineItem, './/cac:Item/cac:ClassifiedTaxCategory/cbc:Percent', TZUGFeRDNullableParam<Double>.Create(0));
  Item.NetUnitPrice := XMLUtils._NodeAsDouble(tradeLineItem, './/cac:Price/cbc:PriceAmount', TZUGFeRDNullableParam<Double>.Create(0));
  Item.GrossUnitPrice := 0; // TODO: Find value //GrossUnitPrice = XMLUtils._NodeAsDecimal(tradeLineItem, ".//ram:GrossPriceProductTradePrice/ram:ChargeAmount", nsmgr, 0).Value,
//  Result.GrossUnitPrice.SetValue(XMLUtils._NodeAsDecimal(tradeLineItem, './/ram:GrossPriceProductTradePrice/ram:ChargeAmount', 0));
  Item.UnitCode := unitCode;
  Item.BillingPeriodStart := XMLUtils._nodeAsDateTime(tradeLineItem, './/cac:InvoicePeriod/cbc:StartDate');
  Item.BillingPeriodEnd := XMLUtils._nodeAsDateTime(tradeLineItem, './/cac:InvoicePeriod/cbc:EndDate');

  if not string.IsNullOrWhiteSpace(parentLineId) then
      Item.SetParentLineId(parentLineId);

  // Read ApplicableProductCharacteristic
  nodes := tradeLineItem.SelectNodes('.//cac:Item/cac:CommodityClassification');
  if nodes.Length > 0 then
  begin
    nodes := tradeLineItem.SelectNodes('.//cac:Item/cac:CommodityClassification/cbc:ItemClassificationCode');
    for i := 0 to nodes.length - 1 do
    begin
      var ListID: TZUGFeRDDesignatedProductClassificationCodes :=
      TZUGFeRDDesignatedProductClassificationCodesExtensions.FromString(
        XmlUtils._nodeAsString(nodes[i], './@listID'));
      Item.AddDesignatedProductClassification(
              ListID, // no name in Peppol Billing!
              XMLUtils._nodeAsString(nodes[i], './@listVersionID'),
              nodes[i].Text,
              '');
    end;
  end;
  // Read ApplicableProductCharacteristic
  nodes := tradeLineItem.SelectNodes('.//cac:Item/cac:AdditionalItemProperty');
  for i := 0 to nodes.length-1 do
  begin
    Item.ApplicableProductCharacteristics.Add(
      TZUGFeRDApplicableProductCharacteristic.CreateWithParams(
        XMLUtils._nodeAsString(nodes[i], './/cbc:Name'),
        XMLUtils._nodeAsString(nodes[i], './/cbc:Value')
      ));
  end;


  // Read BuyerOrderReferencedDocument
  if (tradeLineItem.SelectSingleNode('cac:OrderLineReference') <> nil) then
  begin
    Item.BuyerOrderReferencedDocument := TZUGFeRDBuyerOrderReferencedDocument.Create;
    Item.BuyerOrderReferencedDocument.ID := XMLUtils._nodeAsString(tradeLineItem, './/cbc:IssuerAssignedID');
    Item.BuyerOrderReferencedDocument.IssueDateTime := XMLUtils._nodeAsDateTime(tradeLineItem,
      './/cac:FormattedIssueDateTime/cbc:DateTimeString');
    Item.BuyerOrderReferencedDocument.LineID := XmlUtils._nodeAsString(tradeLineItem, './/cbc:LineID');
  end;

  // Read AdditionalReferencedDocument
  nodes := tradeLineItem.selectNodes('//cac:DocumentReference');
  for i := 0 to nodes.Length - 1 do
  begin
    Item.AdditionalReferencedDocuments.Add(_readAdditionalReferencedDocument(nodes[i]));
  end;


  nodes := tradeLineItem.SelectNodes('.//cbc:Note');
  for i := 0 to nodes.length-1 do
  begin
    var noteItem : TZUGFeRDNote := TZUGFeRDNote.Create(
      nodes[i].Text,
      TZUGFeRDSubjectCodes.Unknown,
      TZUGFeRDContentCodes.Unknown);
    Item.AssociatedDocument.Notes.Add(noteItem);
  end;


  nodes := tradeLineItem.SelectNodes('.//cac:AllowanceCharge');
  for i := 0 to nodes.length-1 do
  begin
    var chargeIndicator : Boolean := XMLUtils._nodeAsBool(nodes[i], './cbc:ChargeIndicator');
    var basisAmount := XMLUtils._NodeAsDecimal(nodes[i], './cbc:BaseAmount', TZUGFeRDNullableParam<Currency>.Create(0));
    var basisAmountCurrency : String := XMLUtils._nodeAsString(nodes[i], './cbc:BaseAmount/@currencyID');
    var actualAmount : Currency := XMLUtils._NodeAsDecimal(nodes[i], './cbc:Amount', TZUGFeRDNullableParam<Currency>.Create(0));
    var reason : String := XMLUtils._nodeAsString(nodes[i], './cbc:AllowanceChargeReason');
    var reasonCode: string := XmlUtils._nodeAsString(nodes[i], './cbc:AllowanceChargeReasonCode');

    Item.AddTradeAllowanceCharge(not chargeIndicator, // wichtig: das not beachten
                                    TZUGFeRDCurrencyCodesExtensions.FromString(basisAmountCurrency),
                                    basisAmount,
                                    actualAmount,
                                    reason,
                                    TZUGFeRDAllowanceReasonCodesExtensions.FromString(reasonCode));
  end;

  if (Item.UnitCode = TZUGFeRDQuantityCodes.Unknown) then
  begin
    // UnitCode alternativ aus BilledQuantity extrahieren
    Item.UnitCode := TZUGFeRDQuantityCodesExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem, './/cbc:InvoicedQuantity/@unitCode'));
  end;

  //Add main item to result list
  result.Add(Item);

  //Find sub invoice lines recursively
  //Note that selectnodes also select the sub invoice line from other nodes
  nodes := tradeLineItem.SelectNodes('.//cac:SubInvoiceLine');
  for i := 0 to nodes.Length - 1 do
  begin
      var parseResultList := _parseTradeLineItem(nodes[i], Item.AssociatedDocument.LineID);
      try
        for var resultItem in parseResultList do
        begin
            //Don't add nodes that are already in the resultList
            if not TZUGFeRDHelper.Any<TZUGFeRDTradeLineItem>(result,
              function(Item: TZUGFeRDTradeLineItem): Boolean
              begin
                result := Item.AssociatedDocument.LineID = resultItem.AssociatedDocument.LineID;
              end) then
                result.Add(resultItem)
            else
              resultItem.free;
        end;
      finally
        parseResultList.Free;
      end;
  end;

end;

end.
