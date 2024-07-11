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
  ,Xml.XMLDoc, Xml.xmldom, Xml.XMLIntf,intf.ZUGFeRDMSXML2_TLB
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
  TZUGFeRDInvoiceDescriptor22UblReader = class(TZUGFeRDInvoiceDescriptorReader)
  private
    function GetValidURIs : TArray<string>;
    function _parseTradeLineItem(tradeLineItem : IXmlDomNode {nsmgr: XmlNamespaceManager = nil; }) : TZUGFeRDTradeLineItem;
    function _nodeAsLegalOrganization(basenode: IXmlDomNode; const xpath: string) : TZUGFeRDLegalOrganization;
    function _nodeAsParty(basenode: IXmlDomNode; const xpath: string) : TZUGFeRDParty;
    function _nodeAsAddressParty(baseNode: IXMLDomNode; const xpath: string) : TZUGFeRDParty;
    function _nodeAsBankAccount(baseNode: IXMLDomNode; const xpath: string): TZUGFeRDBankAccount;
    function _getAdditionalReferencedDocument(a_oXmlNode : IXmlDomNode) : TZUGFeRDAdditionalReferencedDocument;
    function _getUncefactTaxSchemeID(const schemeID: string) : TZUGFeRDTaxRegistrationSchemeID;
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

uses intf.ZUGFeRDDespatchAdviceReferencedDocument, System.Variants;

{ TZUGFeRDInvoiceDescriptor22UblReader }

function TZUGFeRDInvoiceDescriptor22UblReader.GetValidURIs : TArray<string>;
begin
  Result := TArray<string>.Create(
    'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2',
    'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2',
    'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2'
  );
end;

function TZUGFeRDInvoiceDescriptor22UblReader.IsReadableByThisReaderVersion(
  stream: TStream): Boolean;
begin
  Result := IsReadableByThisReaderVersion(stream, GetValidURIs);
end;

function TZUGFeRDInvoiceDescriptor22UblReader.IsReadableByThisReaderVersion(
  xmldocument : IXMLDocument): Boolean;
begin
  Result := IsReadableByThisReaderVersion(xmldocument, GetValidURIs);
end;

function TZUGFeRDInvoiceDescriptor22UblReader.Load(stream: TStream): TZUGFeRDInvoiceDescriptor;
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

function TZUGFeRDInvoiceDescriptor22UblReader.Load(
  xmldocument : IXMLDocument): TZUGFeRDInvoiceDescriptor;
var
  doc : IXMLDOMDocument2;
  node : IXMLDOMNode;
//  node,node2,node3,node4,nodeSupplyChainTradeTransaction,
//  nodeApplicableHeaderTradeAgreement : IXMLDOMNode;
  nodes : IXMLDOMNodeList;
  i : Integer;
begin
  doc := TZUGFeRDXmlHelper.PrepareDocumentForXPathQuerys(xmldocument);
  Result := TZUGFeRDInvoiceDescriptor.Create;

  Result.IsTest := False; // TODO: Find value //IsTest = _nodeAsBool(doc.DocumentElement, "//rsm:ExchangedDocumentContext/ram:TestIndicator/udt:Indicator", nsmgr),
  Result.BusinessProcess := _nodeAsString(doc.DocumentElement, '//cbc:ProfileID');
  Result.Profile := TZUGFeRDProfile.XRechnung; //TZUGFeRDProfileExtensions.FromString(_nodeAsString(doc.DocumentElement, '//ram:GuidelineSpecifiedDocumentContextParameter/ram:ID'));//, nsmgr)),
  Result.Type_ := TZUGFeRDInvoiceTypeExtensions.FromString(_nodeAsString(doc.DocumentElement, '//cbc:InvoiceTypeCode'));
  Result.InvoiceNo := _nodeAsString(doc.DocumentElement, '//cbc:ID');
  Result.InvoiceDate := _nodeAsDateTime(doc.DocumentElement, '//cbc:IssueDate');

  nodes := doc.selectNodes('/ubl:Invoice/cbc:Note');
  for i := 0 to nodes.length-1 do
  begin
    var content : String := _nodeAsString(nodes[i], '.');
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

  Result.ReferenceOrderNo := _nodeAsString(doc, '//cbc:BuyerReference');

  Result.Seller := _nodeAsParty(doc.DocumentElement, '//cac:AccountingSupplierParty/cac:Party');

  if doc.selectSingleNode('//cac:AccountingSupplierParty/cac:Party/cbc:EndpointID') <> nil then
  begin
    var id : String := _nodeAsString(doc.DocumentElement, '//cac:AccountingSupplierParty/cac:Party/cbc:EndpointID');
    var schemeID : String := _nodeAsString(doc.DocumentElement, '//cac:AccountingSupplierParty/cac:Party/cbc:EndpointID/@schemeID');

    var eas : TZUGFeRDElectronicAddressSchemeIdentifiers :=
       TZUGFeRDElectronicAddressSchemeIdentifiersExtensions.FromString(schemeID);

    if (eas <> TZUGFeRDElectronicAddressSchemeIdentifiers.Unknown) then
      Result.SetSellerElectronicAddress(id, eas);
  end;

  nodes := doc.selectNodes('//cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme');
  for i := 0 to nodes.length-1 do
  begin
    var id : String := _nodeAsString(nodes[i], './/cbc:CompanyID');
    var schemeID := _getUncefactTaxSchemeID(_nodeAsString(node, './/cac:TaxScheme/cbc:ID'));
    Result.AddSellerTaxRegistration(id, schemeID);
  end;

  if (doc.selectSingleNode('//cac:AccountingSupplierParty/cac:Party/cac:Contact') <> nil) then
  begin
    Result.SellerContact := TZUGFeRDContact.Create;
    Result.SellerContact.Name := _nodeAsString(doc.DocumentElement, '//cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Name');
    Result.SellerContact.OrgUnit := ''; //TODO: Find value //OrgUnit = _nodeAsString(doc.DocumentElement, "//cac:AccountingSupplierParty/cac:Party/ram:DefinedTradeContact/ram:DepartmentName", nsmgr),
    Result.SellerContact.PhoneNo := _nodeAsString(doc.DocumentElement, '//cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Telephone');
    Result.SellerContact.FaxNo := ''; // TODO: Find value //FaxNo = _nodeAsString(doc.DocumentElement, "//cac:AccountingSupplierParty/cac:Party/cac:Contact/", nsmgr),
    Result.SellerContact.EmailAddress := _nodeAsString(doc.DocumentElement, '//cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:ElectronicMail');
  end;

  Result.Buyer := _nodeAsParty(doc.DocumentElement, '//cac:AccountingCustomerParty/cac:Party');

  if (doc.SelectSingleNode('//cac:AccountingCustomerParty/cac:Party/cbc:EndpointID') <> nil) then
  begin
    var id : String := _nodeAsString(doc.DocumentElement, '//cac:AccountingCustomerParty/cac:Party/cbc:EndpointID');
    var schemeID : String := _nodeAsString(doc.DocumentElement, '//cac:AccountingCustomerParty/cac:Party/cbc:EndpointID/@schemeID');

    var eas : TZUGFeRDElectronicAddressSchemeIdentifiers := TZUGFeRDElectronicAddressSchemeIdentifiersExtensions.FromString(schemeID);

    if (eas <> TZUGFeRDElectronicAddressSchemeIdentifiers.Unknown) then
      Result.SetBuyerElectronicAddress(id, eas);
  end;

  nodes := doc.selectNodes('//cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme');
  for i := 0 to nodes.length-1 do
  begin
    var id : String := _nodeAsString(nodes[i], './/cbc:CompanyID');
    var schemeID := _getUncefactTaxSchemeID(_nodeAsString(node, './/cac:TaxScheme/cbc:ID'));
    Result.AddBuyerTaxRegistration(id, schemeID);
  end;

  if (doc.SelectSingleNode('//cac:AccountingCustomerParty/cac:Party/cac:Contact') <> nil) then
  begin
    Result.BuyerContact := TZUGFeRDContact.Create;
    Result.SetBuyerContact(
      _nodeAsString(doc.DocumentElement, ''),
      '', //TODO   _nodeAsString(doc.DocumentElement, '//ram:BuyerTradeParty/ram:DefinedTradeContact/ram:DepartmentName'),
      _nodeAsString(doc.DocumentElement, '//cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:ElectronicMail'),
      _nodeAsString(doc.DocumentElement, '//cac:AccountingCustomerParty/cac:Party/cac:Contact/cbc:Telephone'),
      '' //TODO _nodeAsString(doc.DocumentElement, '//ram:BuyerTradeParty/ram:DefinedTradeContact/ram:FaxUniversalCommunication/ram:CompleteNumber')
    );
  end;

  //Get all referenced and embedded documents (BG-24)
  nodes := doc.SelectNodes('//cac:AdditionalDocumentReference');
  for i := 0 to nodes.length-1 do
  begin
    Result.AdditionalReferencedDocuments.Add(_getAdditionalReferencedDocument(nodes[i]));
  end;

//  //-------------------------------------------------
//  // hzi: With old implementation only the first document has been read instead of all documents
//  //-------------------------------------------------
//  //if (doc.SelectSingleNode("//ram:AdditionalReferencedDocument') != null)
//  //{
//  //    string _issuerAssignedID := _nodeAsString(doc, "//ram:AdditionalReferencedDocument/ram:IssuerAssignedID');
//  //    string _typeCode := _nodeAsString(doc, "//ram:AdditionalReferencedDocument/ram:TypeCode');
//  //    string _referenceTypeCode := _nodeAsString(doc, "//ram:AdditionalReferencedDocument/ram:ReferenceTypeCode');
//  //    string _name := _nodeAsString(doc, "//ram:AdditionalReferencedDocument/ram:Name');
//  //    DateTime? _date := _nodeAsDateTime(doc.DocumentElement, "//ram:AdditionalReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString');
//
//  //    if (doc.SelectSingleNode("//ram:AdditionalReferencedDocument/ram:AttachmentBinaryObject') != null)
//  //    {
//  //        string _filename := _nodeAsString(doc, "//ram:AdditionalReferencedDocument/ram:AttachmentBinaryObject/@filename');
//  //        byte[] data := Convert.FromBase64String(_nodeAsString(doc, "//ram:AdditionalReferencedDocument/ram:AttachmentBinaryObject'));
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
          _nodeAsString(deliveryLocationNode, './/cbc:ID/@schemeID')), _nodeAsString(deliveryLocationNode, './/cbc:ID'));
        Result.ShipTo.Name := _nodeAsString(deliveryNode, './/cac:DeliveryParty/cac:PartyName/cbc:Name');
    end;
    Result.ActualDeliveryDate := _nodeAsDateTime(doc.DocumentElement, '//cac:Delivery/cbc:ActualDeliveryDate');
  end;

//TODO: Find value  Result.ShipTo := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:ShipToTradeParty');
//TODO: Find value  Result.ShipFrom := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:ShipFromTradeParty');
//TODO: Find value  Result.ActualDeliveryDate.SetValue(_nodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString'));


  var _despatchAdviceNo : String := _nodeAsString(doc.DocumentElement, '//cac:ApplicableHeaderTradeDelivery/cac:DespatchAdviceReferencedDocument/cbc:Id');
  var _despatchAdviceDate : TDateTime := _nodeAsDateTime(doc.DocumentElement, '//cac:ApplicableHeaderTradeDelivery/cac:DespatchAdviceReferencedDocument/cbc:IssueDate');

  if ((_despatchAdviceDate > 100) or (_despatchAdviceNo <> '')) then
  begin
    Result.DespatchAdviceReferencedDocument := TZUGFeRDDespatchAdviceReferencedDocument.Create;
    Result.SetDespatchAdviceReferencedDocument(_despatchAdviceNo,_despatchAdviceDate);
  end;

//TODO: Find value  Result.Invoicee := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:InvoiceeTradeParty');
  Result.Payee := _nodeAsParty(doc.DocumentElement, '//cac:PayeeParty');

  Result.PaymentReference := _nodeAsString(doc.DocumentElement, '//cac:PaymentMeans/cbc:PaymentID');
  Result.Currency :=  TZUGFeRDCurrencyCodesExtensions.FromString(
    _nodeAsString(doc.DocumentElement, '//cbc:DocumentCurrencyCode'));

// TODO: Multiple SpecifiedTradeSettlementPaymentMeans can exist for each account/institution (with different SEPA?)
  var _tempPaymentMeans : TZUGFeRDPaymentMeans := TZUGFeRDPaymentMeans.Create;
  _tempPaymentMeans.TypeCode := TZUGFeRDPaymentMeansTypeCodesExtensions.FromString(
    _nodeAsString(doc.DocumentElement, '//cac:PaymentMeans/cbc:PaymentMeansCode'));
  _tempPaymentMeans.Information := _nodeAsString(doc.DocumentElement,
    '//cac:PaymentMeans/cbc:PaymentMeansCode/@name');
  _tempPaymentMeans.SEPACreditorIdentifier := _nodeAsString(doc.DocumentElement,
    '//cac:AccountingSupplierParty/cac:Party/cac:PartyIdentification/cbc:ID[@schemeID=''SEPA'']');
  _tempPaymentMeans.SEPAMandateReference := _nodeAsString(doc.DocumentElement,
    '//cac:PaymentMeans/cac:PaymentMandate/cbc:ID');

  var financialCardId : String := _nodeAsString(doc.DocumentElement,
    '//cac:PaymentMeans/cac:CardAccount/cbc:PrimaryAccountNumberID');
  var financialCardCardholderName : String := _nodeAsString(doc.DocumentElement,
    '//cac:PaymentMeans/cac:CardAccount/cbc:HolderName');

  if ((financialCardId <> '') or (financialCardCardholderName <> '')) then
  begin
    _tempPaymentMeans.FinancialCard := TZUGFeRDFinancialCard.Create;
    _tempPaymentMeans.FinancialCard.Id := financialCardId;
    _tempPaymentMeans.FinancialCard.CardholderName := financialCardCardholderName;
  end;

  Result.PaymentMeans := _tempPaymentMeans;

  //TODO udt:DateTimeString
  Result.BillingPeriodStart := _nodeAsDateTime(doc.DocumentElement, '//cac:InvoicePeriod/cbc:StartDate');
  Result.BillingPeriodEnd := _nodeAsDateTime(doc.DocumentElement, '//cac:InvoicePeriod/cbc:EndDate');

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
    Result.AddApplicableTradeTax(_nodeAsDecimal(nodes[i], 'cbc:TaxableAmount', 0),
                                 _nodeAsDecimal(nodes[i], 'cac:TaxCategory/cbc:Percent', 0),
                                 TZUGFeRDTaxTypesExtensions.FromString(_nodeAsString(nodes[i],
                                  'cac:TaxCategory/cac:TaxScheme/cbc:ID')),
                                 TZUGFeRDTaxCategoryCodesExtensions.FromString(_nodeAsString(nodes[i],
                                  'cac:TaxCategory/cbc:ID')),
                                 0,
                                 TZUGFeRDTaxExemptionReasonCodesExtensions.FromString(
                                  _nodeAsString(nodes[i], 'cac:TaxCategory/cbc:TaxExemptionReasonCode')),
                                 _nodeAsString(nodes[i], 'cac:TaxCategory/cbc:TaxExemptionReason'));
  end;

  nodes := doc.SelectNodes('//cac:AllowanceCharge');
  for i := 0 to nodes.length-1 do
  begin
    Result.AddTradeAllowanceCharge(not _nodeAsBool(nodes[i], './/cbc:ChargeIndicator'), // wichtig: das not (!) beachten
                                   _nodeAsDecimal(nodes[i], './/cbc:BaseAmount', 0),
                                   Result.Currency,
                                   _nodeAsDecimal(nodes[i], './/cbc:Amount', 0),
                                   _nodeAsString(nodes[i], './/cbc:AllowanceChargeReason'),
                                   TZUGFeRDTaxTypesExtensions.FromString(_nodeAsString(nodes[i],
                                    './/cac:TaxCategory/cac:TaxScheme/cbc:ID')),
                                   TZUGFeRDTaxCategoryCodesExtensions.FromString(_nodeAsString(nodes[i],
                                    './/cac:TaxCategory/cbc:ID')),
                                   _nodeAsDecimal(nodes[i], './/cac:TaxCategory/cbc:Percent', 0));
  end;

// TODO: Find value
//  nodes := doc.SelectNodes('//ram:SpecifiedLogisticsServiceCharge');
//  for i := 0 to nodes.length-1 do
//  begin
//    Result.AddLogisticsServiceCharge(_nodeAsDecimal(nodes[i], './/ram:AppliedAmount', 0),
//                                     _nodeAsString(nodes[i], './/ram:Description'),
//                                     TZUGFeRDTaxTypesExtensions.FromString(_nodeAsString(nodes[i], './/ram:AppliedTradeTax/ram:TypeCode')),
//                                     TZUGFeRDTaxCategoryCodesExtensions.FromString(_nodeAsString(nodes[i], './/ram:AppliedTradeTax/ram:CategoryCode')),
//                                     _nodeAsDecimal(nodes[i], './/ram:AppliedTradeTax/ram:RateApplicablePercent', 0));
//  end;

  Result.InvoiceReferencedDocument := TZUGFeRDInvoiceReferencedDocument.Create;
  Result.InvoiceReferencedDocument.ID := _nodeAsString(doc.DocumentElement, '//cac:BillingReference/cac:InvoiceDocumentReference/cbc:ID');
  Result.InvoiceReferencedDocument.IssueDateTime := _nodeAsDateTime(doc.DocumentElement, '//cac:BillingReference/cac:InvoiceDocumentReference/cbc:IssueDate');

  var _PaymentTerms := TZUGFeRDPaymentTerms.Create;
  _PaymentTerms.Description := _nodeAsString(doc.DocumentElement, '//cac:PaymentTerms/cbc:Note');
  _PaymentTerms.DueDate := _nodeAsDateTime(doc.DocumentElement, '//cbc:DueDate');
  Result.PaymentTermsList.Add(_PaymentTerms);

  Result.LineTotalAmount := _nodeAsDecimal(doc.DocumentElement, '//cac:LegalMonetaryTotal/cbc:LineExtensionAmount', 0);
  Result.ChargeTotalAmount := _nodeAsDecimal(doc.DocumentElement, '//cac:LegalMonetaryTotal/cbc:ChargeTotalAmount', NULL);
  Result.AllowanceTotalAmount := _nodeAsDecimal(doc.DocumentElement, '//cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount', NULL);
  Result.TaxBasisAmount := _nodeAsDecimal(doc.DocumentElement, '//cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount', NULL);
  Result.TaxTotalAmount := _nodeAsDecimal(doc.DocumentElement, '//cac:TaxTotal/cbc:TaxAmount', 0);
  Result.GrandTotalAmount := _nodeAsDecimal(doc.DocumentElement, '//cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount', 0);
  Result.RoundingAmount := _nodeAsDecimal(doc.DocumentElement, '//cac:LegalMonetaryTotal/cbc:PayableRoundingAmount', 0);
  Result.TotalPrepaidAmount := _nodeAsDecimal(doc.DocumentElement, '//cac:LegalMonetaryTotal/cbc:PrepaidAmount', NULL);
  Result.DuePayableAmount := _nodeAsDecimal(doc.DocumentElement, '//cac:LegalMonetaryTotal/cbc:PayableAmount', 0);

//TODO: Find value   nodes := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:ReceivableSpecifiedTradeAccountingAccount');
//  for i := 0 to nodes.length-1 do
//  begin
//    var item : TZUGFeRDReceivableSpecifiedTradeAccountingAccount :=
//      TZUGFeRDReceivableSpecifiedTradeAccountingAccount.Create;
//    item.TradeAccountID := _nodeAsString(nodes[i], './/ram:ID');
//    item.TradeAccountTypeCode := TZUGFeRDAccountingAccountTypeCodesExtensions.FromString(_nodeAsString(nodes[i], './/ram:TypeCode'));
//    Result.ReceivableSpecifiedTradeAccountingAccounts.Add(item);
//  end;

// TODO: Find value  Result.OrderDate.SetValue(_nodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:BuyerOrderReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString'));
  Result.OrderNo := _nodeAsString(doc.DocumentElement, '//cac:OrderReference/cbc:ID');
  Result.OrderDate := _nodeAsDateTime(doc.DocumentElement, '//cac:OrderReference/cbc:IssueDate');

  // Read SellerOrderReferencedDocument
  node := doc.SelectSingleNode('//cac:OrderReference/cbc:SalesOrderID');
  if node <> nil then
  begin
    Result.SellerOrderReferencedDocument := TZUGFeRDSellerOrderReferencedDocument.Create;
    Result.SellerOrderReferencedDocument.ID := _nodeAsString(doc.DocumentElement, '//cac:OrderReference/cbc:SalesOrderID');
    // TODO: Find value Result.SellerOrderReferencedDocument.IssueDateTime := _nodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:SellerOrderReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString'));
  end;

  // Read ContractReferencedDocument
  if (doc.SelectSingleNode('//cac:ContractDocumentReference/cbc:ID') <> nil) then
  begin
    Result.ContractReferencedDocument := TZUGFeRDContractReferencedDocument.Create;
    Result.ContractReferencedDocument.ID := _nodeAsString(doc.DocumentElement, '//cac:ContractDocumentReference/cbc:ID');
    Result.ContractReferencedDocument.IssueDateTime := _nodeAsDateTime(doc.DocumentElement, '//cac:ContractDocumentReference/cbc:IssueDate');
  end;

  Result.SpecifiedProcuringProject := TZUGFeRDSpecifiedProcuringProject.Create;
  Result.SpecifiedProcuringProject.ID := _nodeAsString(doc.DocumentElement, '//cac:ProjectReference/cbc:ID');
  Result.SpecifiedProcuringProject.Name := ''; //TODO: Find value _nodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeAgreement/ram:SpecifiedProcuringProject/ram:Name');

  nodes := doc.SelectNodes('//cac:InvoiceLine');
  for i := 0 to nodes.length-1 do
    Result.TradeLineItems.Add(_parseTradeLineItem(nodes[i]));
end;

function TZUGFeRDInvoiceDescriptor22UblReader._getAdditionalReferencedDocument(
  a_oXmlNode: IXmlDomNode): TZUGFeRDAdditionalReferencedDocument;
var
  dt: TDateTime;
begin

  var strBase64BinaryData : String := _nodeAsString(a_oXmlNode, 'cac:Attachment/cbc:EmbeddedDocumentBinaryObject');
  Result := TZUGFeRDAdditionalReferencedDocument.Create(false);
  Result.ID := _nodeAsString(a_oXmlNode, 'cbc:ID');
  Result.TypeCode := TZUGFeRDAdditionalReferencedDocumentTypeCodeExtensions.FromString(_nodeAsString(a_oXmlNode, 'cbc:DocumentTypeCode'));
  Result.Name := _nodeAsString(a_oXmlNode, 'cbc:DocumentDescription');
  dt := _nodeAsDateTime(a_oXmlNode, 'cbc:IssueDate');
  if dt > 0 then
    Result.IssueDateTime := dt;
  if strBase64BinaryData <> '' then
  begin
    Result.Filename := _nodeAsString(a_oXmlNode, 'cac:Attachment/cbc:EmbeddedDocumentBinaryObject/@filename');
    Result.AttachmentBinaryObject := TMemoryStream.Create;
    var strBase64BinaryDataBytes : TBytes := TNetEncoding.Base64String.DecodeStringToBytes(strBase64BinaryData);
    Result.AttachmentBinaryObject.Write(strBase64BinaryDataBytes,Length(strBase64BinaryDataBytes));
  end;

//  Result.ReferenceTypeCode := TZUGFeRDReferenceTypeCodesExtensions.FromString(_nodeAsString(a_oXmlNode, 'ram:ReferenceTypeCode'));
end;

function TZUGFeRDInvoiceDescriptor22UblReader._getUncefactTaxSchemeID(
  const schemeID: string): TZUGFeRDTaxRegistrationSchemeID;
begin
  if (schemeID.IsNullOrWhiteSpace(schemeID)) then
    exit(TZUGFeRDTaxRegistrationSchemeID.Unknown);

  if schemeID.ToUpper = 'ID' then
    result := TZUGFeRDTaxRegistrationSchemeID.FC
  else if schemeID.ToUpper = 'VAT' then
    result := TZUGFeRDTaxRegistrationSchemeID.VA
  else
    result := TZUGFeRDTaxRegistrationSchemeIDExtensions.FromString(schemeID);
end;

function TZUGFeRDInvoiceDescriptor22UblReader._nodeAsAddressParty(baseNode: IXMLDomNode;
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
  retval.Street := _nodeAsString(node, 'cbc:StreetName');
  retval.AddressLine3 := _nodeAsString(node, 'cbc:AdditionalStreetName');
  retval.City := _nodeAsString(node, 'cbc:CityName');
  retval.Postcode := _nodeAsString(node, 'cbc:PostalZone');
  retval.CountrySubdivisionName := _nodeAsString(node, 'cbc:CountrySubentity');
  retval.Country := TZUGFeRDCountryCodesExtensions.FromString(_nodeAsString(node, 'cac:Country/cbc:IdentificationCode'));

  var addressLine2: string  := _nodeAsString(node, 'cac:AddressLine/cbc:Line');
  if not string.IsNullOrWhiteSpace(addressLine2) then
  begin
    if string.IsNullOrWhiteSpace(retval.AddressLine3) then
      retval.AddressLine3 := addressLine2
    else if not string.IsNullOrWhiteSpace(addressLine2) AND string.IsNullOrWhiteSpace(retval.ContactName) then
      retval.ContactName := addressLine2;
  end;
  result := retval;
end;

function TZUGFeRDInvoiceDescriptor22UblReader._nodeAsBankAccount(baseNode: IXMLDomNode;
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
  result.Name := _nodeAsString(node, 'cbc:Name');
  result.IBAN := _nodeAsString(node, 'cbc:ID');
  result.BIC := _nodeAsString(node, 'cac:FinancialInstitutionBranch/cbc:ID');
  result.ID := '';
end;

function TZUGFeRDInvoiceDescriptor22UblReader._nodeAsLegalOrganization(
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
               TZUGFeRDGlobalIDSchemeIdentifiersExtensions.FromString(
               _nodeAsString(node, 'cbc:CompanyID/@schemeID')),
               _nodeAsString(node, 'cbc:RegistrationName'));
end;

function TZUGFeRDInvoiceDescriptor22UblReader._nodeAsParty(basenode: IXmlDomNode;
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
    _nodeAsString(node, 'cac:PartyIdentification/cbc:ID/@schemeID')),
    _nodeAsString(node, 'cac:PartyIdentification/cbc:ID'));

  if id.SchemeID = TZUGFeRDGlobalIDSchemeIdentifiers.GLN then
  begin
    retval.ID := TZUGFeRDGlobalID.Create;
    retval.GlobalID := id;
  end
  else begin
    retval.ID := id;
    retval.GlobalID := TZUGFeRDGlobalID.Create;
  end;

  retval.Name := _nodeAsString(node, 'cac:PartyName/cbc:Name');
  retval.SpecifiedLegalOrganization := _nodeAsLegalOrganization(node, 'cac:PartyLegalEntity');

  if string.IsNullOrWhiteSpace(retval.Name) then
    retval.Name := _nodeAsString(node, 'cac:PartyLegalEntity/cbc:RegistrationName');


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

function TZUGFeRDInvoiceDescriptor22UblReader._parseTradeLineItem(
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
  // TODO: Find value //GlobalID = new GlobalID(default(GlobalIDSchemeIdentifiers).FromString(_nodeAsString(tradeLineItem, ".//ram:SpecifiedTradeProduct/ram:GlobalID/@schemeID", nsmgr)),
  //                          _nodeAsString(tradeLineItem, ".//ram:SpecifiedTradeProduct/ram:GlobalID", nsmgr)),
  Result.GlobalID.ID := _nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:GlobalID');
  Result.GlobalID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiersExtensions.FromString(_nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:GlobalID/@schemeID'));
*)
  Result.SellerAssignedID := _nodeAsString(tradeLineItem, './/cac:Item/cac:SellersItemIdentification/cbc:ID');
  Result.BuyerAssignedID := _nodeAsString(tradeLineItem, './/cac:Item/cac:BuyersItemIdentification/cbc:ID');
  Result.Name := _nodeAsString(tradeLineItem, './/cac:Item/cbc:Name');
  Result.Description := _nodeAsString(tradeLineItem, './/cac:Item/cbc:Description');
  Result.UnitQuantity := _nodeAsDouble(tradeLineItem, './/cac:Price/cbc:BaseQuantity', 1);
  Result.BilledQuantity := _nodeAsDouble(tradeLineItem, './/cbc:InvoicedQuantity', 0);
  Result.LineTotalAmount := _nodeAsDouble(tradeLineItem, './/cbc:LineExtensionAmount', 0);
  Result.TaxCategoryCode := TZUGFeRDTaxCategoryCodesExtensions.FromString(_nodeAsString(tradeLineItem, './/cac:Item/cac:ClassifiedTaxCategory/cbc:ID'));
  Result.TaxType := TZUGFeRDTaxTypesExtensions.FromString(_nodeAsString(tradeLineItem, './/cac:Item/cac:ClassifiedTaxCategory/cac:TaxScheme/cbc:ID'));
  Result.TaxPercent := _nodeAsDouble(tradeLineItem, './/cac:Item/cac:ClassifiedTaxCategory/cbc:Percent', 0);
  Result.NetUnitPrice := _nodeAsDecimal(tradeLineItem, './/cac:Price/cbc:PriceAmount', 0);
  Result.GrossUnitPrice := 0; // TODO: Find value //GrossUnitPrice = _nodeAsDecimal(tradeLineItem, ".//ram:GrossPriceProductTradePrice/ram:ChargeAmount", nsmgr, 0).Value,
//  Result.GrossUnitPrice.SetValue(_nodeAsDecimal(tradeLineItem, './/ram:GrossPriceProductTradePrice/ram:ChargeAmount', 0));
  Result.UnitCode := TZUGFeRDQuantityCodesExtensions.FromString(_nodeAsString(tradeLineItem, './/cbc:InvoicedQuantity/@unitCode'));
  Result.BillingPeriodStart := _nodeAsDateTime(tradeLineItem, './/cac:InvoicePeriod/cbc:StartDate');
  Result.BillingPeriodEnd := _nodeAsDateTime(tradeLineItem, './/cac:InvoicePeriod/cbc:EndDate');

 // TODO: Find value //if (tradeLineItem.SelectNodes(".//cac:Item/ram:ApplicableProductCharacteristic", nsmgr) != null)
//  nodes := tradeLineItem.SelectNodes('.//ram:SpecifiedTradeProduct/ram:ApplicableProductCharacteristic');
//  for i := 0 to nodes.length-1 do
//  begin
//    var apcItem : TZUGFeRDApplicableProductCharacteristic := TZUGFeRDApplicableProductCharacteristic.Create;
//    apcItem.Description := _nodeAsString(nodes[i], './/ram:Description');
//    apcItem.Value := _nodeAsString(nodes[i], './/ram:Value');
//    Result.ApplicableProductCharacteristics.Add(apcItem);
//  end;
//
// TODO: Find value //if (tradeLineItem.SelectSingleNode(".//ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument", nsmgr) != null)
//  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument') <> nil) then
//  begin
//    Result.BuyerOrderReferencedDocument := TZUGFeRDBuyerOrderReferencedDocument.Create;
//    Result.BuyerOrderReferencedDocument.ID := _nodeAsString(tradeLineItem, './/ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument/ram:IssuerAssignedID');
//    Result.BuyerOrderReferencedDocument.IssueDateTime.SetValue(_nodeAsDateTime(tradeLineItem, './/ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString'));
//  end;
//
// TODO: Find value //if (tradeLineItem.SelectSingleNode(".//ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument", nsmgr) != null)
//  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument') <> nil) then
//  begin
//    Result.ContractReferencedDocument := TZUGFeRDContractReferencedDocument.Create;
//    Result.ContractReferencedDocument.ID := _nodeAsString(tradeLineItem, './/ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument/ram:IssuerAssignedID');
//    Result.ContractReferencedDocument.IssueDateTime.SetValue(_nodeAsDateTime(tradeLineItem, './/ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString'));
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
//        rstaaItem.TradeAccountID := _nodeAsString(nodes[i], './/ram:ID');
//        rstaaItem.TradeAccountTypeCode := TZUGFeRDAccountingAccountTypeCodesExtensions.FromString(_nodeAsString(nodes[i], './/ram:TypeCode'));
//        Result.ReceivableSpecifiedTradeAccountingAccounts.Add(rstaaItem);
//      end;
//    end;
//  end;


  if (tradeLineItem.SelectSingleNode('.//cbc:ID') <> nil) then
  begin
    Result.AssociatedDocument := TZUGFeRDAssociatedDocument.Create(_nodeAsString(tradeLineItem, './/cbc:ID'));

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
    var chargeIndicator : Boolean := _nodeAsBool(nodes[i], '"./cbc:ChargeIndicator');
    var basisAmount : Currency := _nodeAsDecimal(nodes[i], './cbc:BaseAmount', 0);
    var basisAmountCurrency : String := _nodeAsString(nodes[i], './cbc:BaseAmount/@currencyID');
    var actualAmount : Currency := _nodeAsDecimal(nodes[i], './cbc:Amount', 0);
    var actualAmountCurrency : String := _nodeAsString(nodes[i], './cbc:Amount/@currencyID');
    var reason : String := _nodeAsString(nodes[i], './cbc:AllowanceChargeReason');

    Result.AddTradeAllowanceCharge(not chargeIndicator, // wichtig: das not beachten
                                    TZUGFeRDCurrencyCodesExtensions.FromString(basisAmountCurrency),
                                    basisAmount,
                                    actualAmount,
                                    reason);
  end;

  if (Result.UnitCode = TZUGFeRDQuantityCodes.Unknown) then
  begin
    // UnitCode alternativ aus BilledQuantity extrahieren
    Result.UnitCode := TZUGFeRDQuantityCodesExtensions.FromString(_nodeAsString(tradeLineItem, './/cbc:InvoicedQuantity/@unitCode'));
  end;

//TODO: Find value //if (tradeLineItem.SelectSingleNode(".//ram:SpecifiedLineTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:IssuerAssignedID", nsmgr) != null)
//  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:IssuerAssignedID') <> nil) then
//  begin
//    Result.DeliveryNoteReferencedDocument := TZUGFeRDDeliveryNoteReferencedDocument.Create;
//    Result.DeliveryNoteReferencedDocument.ID := _nodeAsString(tradeLineItem, './/ram:SpecifiedLineTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:IssuerAssignedID');
//    Result.DeliveryNoteReferencedDocument.IssueDateTime.SetValue(_nodeAsDateTime(tradeLineItem, './/ram:SpecifiedLineTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString'));
//  end;
//
// TODO: Find value //if (tradeLineItem.SelectSingleNode(".//ram:SpecifiedLineTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime", nsmgr) != null)
//  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime') <> nil) then
//  begin
//    Result.ActualDeliveryDate.SetValue(_nodeAsDateTime(tradeLineItem, './/ram:SpecifiedLineTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString'));
//  end;
//
//  //if (tradeLineItem.SelectSingleNode(".//ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument/ram:IssuerAssignedID", nsmgr) != null)
//  //{
//  //    item.ContractReferencedDocument = new ContractReferencedDocument()
//  //    {
//  //        ID = _nodeAsString(tradeLineItem, ".//ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument/ram:IssuerAssignedID", nsmgr),
//  //        IssueDateTime = _nodeAsDateTime(tradeLineItem, ".//ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument/ram:FormattedIssueDateTime/qdt:DateTimeString", nsmgr),
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
