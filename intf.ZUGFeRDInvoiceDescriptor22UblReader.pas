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
  System.SysUtils, System.Classes, System.DateUtils, System.Math
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
    function _parseTradeLineItem(tradeLineItem : IXmlDomNode {nsmgr: XmlNamespaceManager = nil; }) : TZUGFeRDTradeLineItem;
    function _nodeAsLegalOrganization(basenode: IXmlDomNode; const xpath: string) : TZUGFeRDLegalOrganization;
    function _nodeAsParty(basenode: IXmlDomNode; const xpath: string) : TZUGFeRDParty;
    function _nodeAsAddressParty(baseNode: IXMLDomNode; const xpath: string) : TZUGFeRDParty;
    function _nodeAsBankAccount(baseNode: IXMLDomNode; const xpath: string): TZUGFeRDBankAccount;
    function _getAdditionalReferencedDocument(a_oXmlNode : IXmlDomNode) : TZUGFeRDAdditionalReferencedDocument;
    function _getUncefactTaxSchemeID(const schemeID: string) : TZUGFeRDTaxRegistrationSchemeID;
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

uses intf.ZUGFeRDDespatchAdviceReferencedDocument, System.Variants, intf.ZUGFeRDHelper,
  intf.ZUGFeRDDesignatedProductClassificationCodes, intf.ZUGFeRDXMLUtils;

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
  nodes : IXMLDOMNodeList;
  i : Integer;
  id, schemeID: string;
  TaxSchemeID: TZUGFeRDTaxRegistrationSchemeID;
begin
  doc := TZUGFeRDXmlHelper.PrepareDocumentForXPathQuerys(xmldocument);
  Result := TZUGFeRDInvoiceDescriptor.Create;

  Result.IsTest := XMLUtils._nodeAsBool(doc.DocumentElement, '//cbc:TestIndicator', false);
  Result.BusinessProcess := XMLUtils._nodeAsString(doc.DocumentElement, '//cbc:ProfileID');
  Result.Profile := TZUGFeRDProfile.XRechnung; //TZUGFeRDProfileExtensions.FromString(XMLUtils._nodeAsString(doc.DocumentElement, '//ram:GuidelineSpecifiedDocumentContextParameter/ram:ID'));//, nsmgr)),
  Result.Type_ := TZUGFeRDInvoiceTypeExtensions.FromString(XMLUtils._nodeAsString(doc.DocumentElement, '//cbc:InvoiceTypeCode'));
  Result.InvoiceNo := XMLUtils._nodeAsString(doc.DocumentElement, '//cbc:ID');
  Result.InvoiceDate := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//cbc:IssueDate');

  nodes := doc.DocumentElement.selectNodes('cbc:Note');
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
    TAXSchemeID := _getUncefactTaxSchemeID(XMLUtils._nodeAsString(nodes[i], './/cac:TaxScheme/cbc:ID'));
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
    TaxSchemeID := _getUncefactTaxSchemeID(XMLUtils._nodeAsString(nodes[i], './/cac:TaxScheme/cbc:ID'));
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


  var _despatchAdviceNo : String := XMLUtils._nodeAsString(doc.DocumentElement, '//cac:ApplicableHeaderTradeDelivery/cac:DespatchAdviceReferencedDocument/cbc:Id');
  var _despatchAdviceDate := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//cac:ApplicableHeaderTradeDelivery/cac:DespatchAdviceReferencedDocument/cbc:IssueDate');

  if ((_despatchAdviceDate.HasValue) or (_despatchAdviceNo <> '')) then
  begin
    Result.DespatchAdviceReferencedDocument := TZUGFeRDDespatchAdviceReferencedDocument.Create;
    Result.SetDespatchAdviceReferencedDocument(_despatchAdviceNo,_despatchAdviceDate);
  end;

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
    Result.AddApplicableTradeTax(XMLUtils._nodeAsDecimal(nodes[i], 'cbc:TaxableAmount'),
                                 XMLUtils._nodeAsDecimal(nodes[i], 'cac:TaxCategory/cbc:Percent'),
                                 TZUGFeRDTaxTypesExtensions.FromString(XMLUtils._nodeAsString(nodes[i],
                                  'cac:TaxCategory/cac:TaxScheme/cbc:ID')),
                                 TZUGFeRDTaxCategoryCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i],
                                  'cac:TaxCategory/cbc:ID')),
                                 nil,
                                 TZUGFeRDTaxExemptionReasonCodesExtensions.FromString(
                                  XMLUtils._nodeAsString(nodes[i], 'cac:TaxCategory/cbc:TaxExemptionReasonCode')),
                                 XMLUtils._nodeAsString(nodes[i], 'cac:TaxCategory/cbc:TaxExemptionReason'));
  end;

  nodes := doc.DocumentElement.SelectNodes('cac:AllowanceCharge');
  for i := 0 to nodes.length-1 do
  begin
    Result.AddTradeAllowanceCharge(not XMLUtils._nodeAsBool(nodes[i], './/cbc:ChargeIndicator'), // wichtig: das not (!) beachten
                                   XMLUtils._nodeAsDecimal(nodes[i], './/cbc:BaseAmount'),
                                   Result.Currency,
                                   XMLUtils._nodeAsDecimal(nodes[i], './/cbc:Amount'),
                                   XMLUtils._nodeAsString(nodes[i], './/cbc:AllowanceChargeReason'),
                                   TZUGFeRDTaxTypesExtensions.FromString(XMLUtils._nodeAsString(nodes[i],
                                    './/cac:TaxCategory/cac:TaxScheme/cbc:ID')),
                                   TZUGFeRDTaxCategoryCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i],
                                    './/cac:TaxCategory/cbc:ID')),
                                   XMLUtils._nodeAsDecimal(nodes[i], './/cac:TaxCategory/cbc:Percent'));
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

  Result.InvoiceReferencedDocument := TZUGFeRDInvoiceReferencedDocument.Create;
  Result.InvoiceReferencedDocument.ID := XMLUtils._nodeAsString(doc.DocumentElement, '//cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID');
  Result.InvoiceReferencedDocument.IssueDateTime := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//cac:BillingReference/cac:InvoiceDocumentReference/cbc:IssueDate');

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
  Result.OrderDate := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//cac:OrderReference/cbc:IssueDate');

  // Read SellerOrderReferencedDocument
  node := doc.SelectSingleNode('//cac:OrderReference/cbc:SalesOrderID');
  if node <> nil then
  begin
    Result.SellerOrderReferencedDocument := TZUGFeRDSellerOrderReferencedDocument.Create;
    Result.SellerOrderReferencedDocument.ID := XMLUtils._nodeAsString(doc.DocumentElement, '//cac:OrderReference/cbc:SalesOrderID');
    // TODO: Find value Result.SellerOrderReferencedDocument.IssueDateTime := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:SellerOrderReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString'));
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
    Result.AdditionalReferencedDocuments.Add(_getAdditionalReferencedDocument(nodes[i]));
  end;

  Result.SpecifiedProcuringProject := TZUGFeRDSpecifiedProcuringProject.Create;
  Result.SpecifiedProcuringProject.ID := XMLUtils._nodeAsString(doc.DocumentElement, '//cac:ProjectReference/cbc:ID');
  Result.SpecifiedProcuringProject.Name := ''; //TODO: Find value XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:SpecifiedProcuringProject/ram:Name');

  nodes := doc.SelectNodes('//cac:InvoiceLine');
  for i := 0 to nodes.length-1 do
    Result.TradeLineItems.Add(_parseTradeLineItem(nodes[i]));
end;

function TZUGFeRDInvoiceDescriptor22UBLReader._getAdditionalReferencedDocument(
  a_oXmlNode: IXmlDomNode): TZUGFeRDAdditionalReferencedDocument;
begin

  Result := TZUGFeRDAdditionalReferencedDocument.Create(false);
  Result.ID := XMLUtils._nodeAsString(a_oXmlNode, './/cbc:ID');
  Result.ReferenceTypeCode := TZUGFeRDReferenceTypeCodesExtensions.FromString(XMLUtils._nodeAsString(a_oXmlNode, './/cbc:ID/@schemeID'));
  Result.TypeCode := TZUGFeRDAdditionalReferencedDocumentTypeCodeExtensions.FromString(XMLUtils._nodeAsString(a_oXmlNode, './/cbc:DocumentTypeCode'));
  Result.Name := XMLUtils._nodeAsString(a_oXmlNode, './/cbc:DocumentType');

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

function TZUGFeRDInvoiceDescriptor22UBLReader._getUncefactTaxSchemeID(
  const schemeID: string): TZUGFeRDTaxRegistrationSchemeID;
begin
  if (schemeID.IsNullOrWhiteSpace(schemeID)) then
    exit(TZUGFeRDTaxRegistrationSchemeID.Unknown);

// Mandatory element.
// For Seller VAT identifier (BT-31), use value “VAT”,
// for the seller tax registration identifier (BT-32), use != "VAT"
  if schemeID.ToUpper = 'ID' then
    result := TZUGFeRDTaxRegistrationSchemeID.FC;
  if schemeID.ToUpper = 'VAT' then
    result := TZUGFeRDTaxRegistrationSchemeID.VA
  else
    result := TZUGFeRDTaxRegistrationSchemeID.FC
end;

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

function TZUGFeRDInvoiceDescriptor22UBLReader._parseTradeLineItem(
  tradeLineItem: IXmlDomNode): TZUGFeRDTradeLineItem;
var
  nodes : IXMLDOMNodeList;
  i : Integer;
begin
  Result := nil;

  if (tradeLineItem = nil) then
    exit;

  Result := TZUGFeRDTradeLineItem.Create;
(*
  // TODO: Find value //GlobalID = new GlobalID(default(GlobalIDSchemeIdentifiers).FromString(XMLUtils._nodeAsString(tradeLineItem, ".//ram:SpecifiedTradeProduct/ram:GlobalID/@schemeID", nsmgr)),
  //                          XMLUtils._nodeAsString(tradeLineItem, ".//ram:SpecifiedTradeProduct/ram:GlobalID", nsmgr)),
  Result.GlobalID.ID := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:GlobalID');
  Result.GlobalID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiersExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:GlobalID/@schemeID'));
*)
  Result.SellerAssignedID := XMLUtils._nodeAsString(tradeLineItem, './/cac:Item/cac:SellersItemIdentification/cbc:ID');
  Result.BuyerAssignedID := XMLUtils._nodeAsString(tradeLineItem, './/cac:Item/cac:BuyersItemIdentification/cbc:ID');
  Result.Name := XMLUtils._nodeAsString(tradeLineItem, './/cac:Item/cbc:Name');
  Result.Description := XMLUtils._nodeAsString(tradeLineItem, './/cac:Item/cbc:Description');
  Result.UnitQuantity := XMLUtils._nodeAsDouble(tradeLineItem, './/cac:Price/cbc:BaseQuantity', TZUGFeRDNullableParam<Double>.Create(1));
  Result.BilledQuantity := XMLUtils._nodeAsDouble(tradeLineItem, './/cbc:InvoicedQuantity', TZUGFeRDNullableParam<Double>.Create(0));
  Result.LineTotalAmount := XMLUtils._nodeAsDouble(tradeLineItem, './/cbc:LineExtensionAmount', TZUGFeRDNullableParam<Double>.Create(0));
  Result.TaxCategoryCode := TZUGFeRDTaxCategoryCodesExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem, './/cac:Item/cac:ClassifiedTaxCategory/cbc:ID'));
  Result.TaxType := TZUGFeRDTaxTypesExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem, './/cac:Item/cac:ClassifiedTaxCategory/cac:TaxScheme/cbc:ID'));
  Result.TaxPercent := XMLUtils._nodeAsDouble(tradeLineItem, './/cac:Item/cac:ClassifiedTaxCategory/cbc:Percent', TZUGFeRDNullableParam<Double>.Create(0));
  Result.NetUnitPrice := XMLUtils._NodeAsDecimal(tradeLineItem, './/cac:Price/cbc:PriceAmount', TZUGFeRDNullableParam<Currency>.Create(0));
  Result.GrossUnitPrice := 0; // TODO: Find value //GrossUnitPrice = XMLUtils._NodeAsDecimal(tradeLineItem, ".//ram:GrossPriceProductTradePrice/ram:ChargeAmount", nsmgr, 0).Value,
//  Result.GrossUnitPrice.SetValue(XMLUtils._NodeAsDecimal(tradeLineItem, './/ram:GrossPriceProductTradePrice/ram:ChargeAmount', 0));
  Result.UnitCode := TZUGFeRDQuantityCodesExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem, './/cbc:InvoicedQuantity/@unitCode'));
  Result.BillingPeriodStart := XMLUtils._nodeAsDateTime(tradeLineItem, './/cac:InvoicePeriod/cbc:StartDate');
  Result.BillingPeriodEnd := XMLUtils._nodeAsDateTime(tradeLineItem, './/cac:InvoicePeriod/cbc:EndDate');

  // Read ApplicableProductCharacteristic
  nodes := tradeLineItem.SelectNodes('.//cac:Item/cac:CommodityClassification');
  if nodes.Length > 0 then
  begin
    nodes := tradeLineItem.SelectNodes('.//cac:Item/cac:CommodityClassification/cac:ItemClassificationCode');
    for i := 0 to nodes.length - 1 do
    begin
      var code: TZUGFeRDDesignatedProductClassicficationCodes :=
      TZUGFeRDDesignatedProductClassicficationCodesExtensions.FromString(nodes[i].Text);
      result.AddDesignatedProductClassification(
              code,
              '', // no name in Peppol Billing!
              XMLUtils._nodeAsString(nodes[i], './@listID'),
              XMLUtils._nodeAsString(nodes[i], './@istVersionID')
              );
    end;
  end;
  // Read ApplicableProductCharacteristic
  nodes := tradeLineItem.SelectNodes('.//cac:Item/cac:AdditionalItemProperty');
  for i := 0 to nodes.length-1 do
  begin
    Result.ApplicableProductCharacteristics.Add(
      TZUGFeRDApplicableProductCharacteristic.CreateWithParams(
        XMLUtils._nodeAsString(nodes[i], './/cbc:Name'),
        XMLUtils._nodeAsString(nodes[i], './/cbc:Value')
      ));
  end;


// TODO: Find value //if (tradeLineItem.SelectSingleNode(".//ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument", nsmgr) != null)
//  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument') <> nil) then
//  begin
//    Result.BuyerOrderReferencedDocument := TZUGFeRDBuyerOrderReferencedDocument.Create;
//    Result.BuyerOrderReferencedDocument.ID := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument/ram:IssuerAssignedID');
//    Result.BuyerOrderReferencedDocument.IssueDateTime.SetValue(XMLUtils._nodeAsDateTime(tradeLineItem, './/ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString'));
//  end;
//
// TODO: Find value //if (tradeLineItem.SelectSingleNode(".//ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument", nsmgr) != null)
//  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument') <> nil) then
//  begin
//    Result.ContractReferencedDocument := TZUGFeRDContractReferencedDocument.Create;
//    Result.ContractReferencedDocument.ID := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument/ram:IssuerAssignedID');
//    Result.ContractReferencedDocument.IssueDateTime.SetValue(XMLUtils._nodeAsDateTime(tradeLineItem, './/ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString'));
//  end;
//
// TODO: Find value //if (tradeLineItem.SelectSingleNode(".//ram:SpecifiedLineTradeSettlement", nsmgr) != null)
//  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeSettlement') <> nil) then
//  begin
//    nodes := tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeSettlement').ChildNodes;
//    for i := 0 to nodes.length-1 do
//    begin
//      if SameText(nodes[i].nodeName,'ram:ApplicableTradeTax') then
//      begin
//        //TODO
//      end else
//      if SameText(nodes[i].nodeName,'ram:BillingSpecifiedPeriod') then
//      begin
//        //TODO
//      end else
//      if SameText(nodes[i].nodeName,'ram:SpecifiedTradeAllowanceCharge') then
//      begin
//        //TODO
//      end else
//      if SameText(nodes[i].nodeName,'ram:SpecifiedTradeSettlementLineMonetarySummation') then
//      begin
//        //TODO
//      end else
//      if SameText(nodes[i].nodeName,'ram:AdditionalReferencedDocument') then
//      begin
//        //TODO
//      end else
//      if SameText(nodes[i].nodeName,'ram:ReceivableSpecifiedTradeAccountingAccount') then
//      begin
//        var rstaaItem : TZUGFeRDReceivableSpecifiedTradeAccountingAccount :=
//          TZUGFeRDReceivableSpecifiedTradeAccountingAccount.Create;
//        rstaaItem.TradeAccountID := XMLUtils._nodeAsString(nodes[i], './/ram:ID');
//        rstaaItem.TradeAccountTypeCode := TZUGFeRDAccountingAccountTypeCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:TypeCode'));
//        Result.ReceivableSpecifiedTradeAccountingAccounts.Add(rstaaItem);
//      end;
//    end;
//  end;


  if (tradeLineItem.SelectSingleNode('.//cbc:ID') <> nil) then
  begin
    Result.AssociatedDocument := TZUGFeRDAssociatedDocument.Create(XMLUtils._nodeAsString(tradeLineItem, './/cbc:ID'));

    nodes := tradeLineItem.SelectNodes('.//cbc:Note');
    for i := 0 to nodes.length-1 do
    begin
      var noteItem : TZUGFeRDNote := TZUGFeRDNote.Create(
        nodes[i].Text,
        TZUGFeRDSubjectCodes.Unknown,
        TZUGFeRDContentCodes.Unknown);
      Result.AssociatedDocument.Notes.Add(noteItem);
    end;
  end;

  nodes := tradeLineItem.SelectNodes('.//cac:AllowanceCharge');
  for i := 0 to nodes.length-1 do
  begin
    var chargeIndicator : Boolean := XMLUtils._nodeAsBool(nodes[i], './cbc:ChargeIndicator');
    var basisAmount : Currency := XMLUtils._NodeAsDecimal(nodes[i], './cbc:BaseAmount', TZUGFeRDNullableParam<Currency>.Create(0));
    var basisAmountCurrency : String := XMLUtils._nodeAsString(nodes[i], './cbc:BaseAmount/@currencyID');
    var actualAmount : Currency := XMLUtils._NodeAsDecimal(nodes[i], './cbc:Amount', TZUGFeRDNullableParam<Currency>.Create(0));
    var actualAmountCurrency : String := XMLUtils._nodeAsString(nodes[i], './cbc:Amount/@currencyID');
    var reason : String := XMLUtils._nodeAsString(nodes[i], './cbc:AllowanceChargeReason');

    Result.AddTradeAllowanceCharge(not chargeIndicator, // wichtig: das not beachten
                                    TZUGFeRDCurrencyCodesExtensions.FromString(basisAmountCurrency),
                                    basisAmount,
                                    actualAmount,
                                    reason);
  end;

  if (Result.UnitCode = TZUGFeRDQuantityCodes.Unknown) then
  begin
    // UnitCode alternativ aus BilledQuantity extrahieren
    Result.UnitCode := TZUGFeRDQuantityCodesExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem, './/cbc:InvoicedQuantity/@unitCode'));
  end;

//TODO: Find value //if (tradeLineItem.SelectSingleNode(".//ram:SpecifiedLineTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:IssuerAssignedID", nsmgr) != null)
//  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:IssuerAssignedID') <> nil) then
//  begin
//    Result.DeliveryNoteReferencedDocument := TZUGFeRDDeliveryNoteReferencedDocument.Create;
//    Result.DeliveryNoteReferencedDocument.ID := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedLineTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:IssuerAssignedID');
//    Result.DeliveryNoteReferencedDocument.IssueDateTime.SetValue(XMLUtils._nodeAsDateTime(tradeLineItem, './/ram:SpecifiedLineTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString'));
//  end;
//
// TODO: Find value //if (tradeLineItem.SelectSingleNode(".//ram:SpecifiedLineTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime", nsmgr) != null)
//  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime') <> nil) then
//  begin
//    Result.ActualDeliveryDate.SetValue(XMLUtils._nodeAsDateTime(tradeLineItem, './/ram:SpecifiedLineTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString'));
//  end;
//
//  //if (tradeLineItem.SelectSingleNode(".//ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument/ram:IssuerAssignedID", nsmgr) != null)
//  //{
//  //    item.ContractReferencedDocument = new ContractReferencedDocument()
//  //    {
//  //        ID = XMLUtils._nodeAsString(tradeLineItem, ".//ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument/ram:IssuerAssignedID", nsmgr),
//  //        IssueDateTime = XMLUtils._nodeAsDateTime(tradeLineItem, ".//ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString", nsmgr),
//  //    };
//  //}
//
//  //Get all referenced AND embedded documents
//  nodes := tradeLineItem.SelectNodes('.//ram:SpecifiedLineTradeAgreement/ram:AdditionalReferencedDocument');
//  for i := 0 to nodes.length-1 do
//  begin
//    Result.AdditionalReferencedDocuments.Add(_getAdditionalReferencedDocument(nodes[i]));
//  end;
end;

end.
