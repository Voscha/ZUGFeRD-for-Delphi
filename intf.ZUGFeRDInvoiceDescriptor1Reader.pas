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

unit intf.ZUGFeRDInvoiceDescriptor1Reader;

interface

uses
  System.SysUtils, System.Classes, System.DateUtils, System.Variants
  ,Xml.XMLDoc, Xml.XMLIntf
  ,Xml.Win.msxmldom, Winapi.MSXMLIntf, Winapi.msxml
  ,intf.ZUGFeRDXmlHelper
  ,intf.ZUGFeRDInvoiceDescriptorReader
  ,intf.ZUGFeRDInvoiceDescriptor
  ,intf.ZUGFeRDExceptions
  ,intf.ZUGFeRDTradeLineItem,intf.ZUGFeRDParty
  ,intf.ZUGFeRDProfile,intf.ZUGFeRDInvoiceTypes
  ,intf.ZUGFeRDSubjectCodes
  ,intf.ZUGFeRDGlobalID,intf.ZUGFeRDGlobalIDSchemeIdentifiers
  ,intf.ZUGFeRDCountryCodes
  ,intf.ZUGFeRDTaxRegistrationSchemeID
  ,intf.ZUGFeRDContact
  ,intf.ZUGFeRDDeliveryNoteReferencedDocument
  ,intf.ZUGFeRDCurrencyCodes
  ,intf.ZUGFeRDPaymentMeans,intf.ZUGFeRDPaymentMeansTypeCodes
  ,intf.ZUGFeRDBankAccount
  ,intf.ZUGFeRDTaxTypes,intf.ZUGFeRDTaxCategoryCodes
  ,intf.ZUGFeRDTaxExemptionReasonCodes
  ,intf.ZUGFeRDPaymentTerms
  ,intf.ZUGFeRDQuantityCodes
  ,intf.ZUGFeRDAssociatedDocument
  ,intf.ZUGFeRDNote
  ,intf.ZUGFeRDContentCodes
  ,intf.ZUGFeRDBuyerOrderReferencedDocument
  ,intf.ZUGFeRDReferenceTypeCodes
  ,intf.ZUGFeRDContractReferencedDocument
  ,intf.ZUGFeRDSpecialServiceDescriptionCodes
  ,intf.ZUGFeRDAllowanceOrChargeIdentificationCodes
  ;

type
  TZUGFeRDInvoiceDescriptor1Reader = class(TZUGFeRDInvoiceDescriptorReader)
  private
    function GetValidURIs : TArray<string>;
    function _parseTradeLineItem(tradeLineItem : IXmlDomNode) : TZUGFeRDTradeLineItem;
    function _nodeAsParty(basenode: IXmlDomNode; const xpath: string) : TZUGFeRDParty;
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

uses intf.ZUGFeRDXMLUtils, intf.ZUGFeRDHelper;

{ TZUGFeRDInvoiceDescriptor1Reader }

function TZUGFeRDInvoiceDescriptor1Reader.GetValidURIs : TArray<string>;
begin
  Result :=  TArray<string>.Create(
    'urn:ferd:invoice:1.0:basic',
    'urn:ferd:invoice:1.0:comfort',
    'urn:ferd:invoice:1.0:extended',
    'urn:ferd:CrossIndustryDocument:invoice:1p0:basic',
    'urn:ferd:CrossIndustryDocument:invoice:1p0:comfort',
    'urn:ferd:CrossIndustryDocument:invoice:1p0:extended'
  );
end;

function TZUGFeRDInvoiceDescriptor1Reader.IsReadableByThisReaderVersion(
  stream: TStream): Boolean;
begin
  Result := IsReadableByThisReaderVersion(stream, GetValidURIs);
end;

function TZUGFeRDInvoiceDescriptor1Reader.IsReadableByThisReaderVersion(
  xmldocument: IXMLDocument): Boolean;
begin
  Result := IsReadableByThisReaderVersion(xmldocument, GetValidURIs);
end;

function TZUGFeRDInvoiceDescriptor1Reader.Load(Stream: TStream): TZUGFeRDInvoiceDescriptor;
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

function TZUGFeRDInvoiceDescriptor1Reader.Load(xmldocument : IXMLDocument): TZUGFeRDInvoiceDescriptor;
var
  doc : IXMLDOMDocument2;
  nodes : IXMLDOMNodeList;
  i : Integer;
  id, schemeID: string;
begin
  doc := TZUGFeRDXmlHelper.PrepareDocumentForXPathQuerys(xmldocument);

  //XmlNamespaceManager nsmgr = _GenerateNamespaceManagerFromNode(doc.DocumentElement);

  Result := TZUGFeRDInvoiceDescriptor.Create;

  Result.IsTest := XMLUtils._nodeAsBool(doc.documentElement,'//*[local-name()="SpecifiedExchangedDocumentContext"]/ram:TestIndicator');
  Result.BusinessProcess := XMLUtils._nodeAsString(doc.DocumentElement, '//*[local-name()="BusinessProcessSpecifiedDocumentContextParameter"]/ram:ID');//, nsmgr),
  Result.Profile := TZUGFeRDProfileExtensions.FromString(XMLUtils._nodeAsString(doc.DocumentElement, '//ram:GuidelineSpecifiedDocumentContextParameter/ram:ID'));//, nsmgr)),
  Result.Name := XMLUtils._nodeAsString(doc.DocumentElement, '//*[local-name()="HeaderExchangedDocument"]/ram:Name');
  Result.Type_ := TZUGFeRDInvoiceTypeExtensions.FromString(XMLUtils._nodeAsString(doc.DocumentElement, '//*[local-name()="HeaderExchangedDocument"]/ram:TypeCode'));//, nsmgr)),
  Result.InvoiceNo := XMLUtils._nodeAsString(doc.DocumentElement, '//*[local-name()="HeaderExchangedDocument"]/ram:ID');//, nsmgr),
  Result.InvoiceDate := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//*[local-name()="HeaderExchangedDocument"]/ram:IssueDateTime/udt:DateTimeString');//", nsmgr)

  nodes := doc.selectNodes('//*[local-name()="HeaderExchangedDocument"]/ram:IncludedNote');
  for i := 0 to nodes.length-1 do
  begin
    var content : String := XMLUtils._nodeAsString(nodes[i], './/ram:Content');
    var _subjectCode : String := XMLUtils._nodeAsString(nodes[i], './/ram:SubjectCode');
    var subjectCode : TZUGFeRDSubjectCodes := TZUGFeRDSubjectCodesExtensions.FromString(_subjectCode);
    var contentCode : TZUGFeRDContentCodes := TZUGFeRDContentCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:ContentCode'));
    Result.AddNote(content, subjectCode, contentCode);
  end;

  Result.ReferenceOrderNo := XMLUtils._nodeAsString(doc, '//ram:ApplicableSupplyChainTradeAgreement/ram:BuyerReference');

  Result.Seller := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableSupplyChainTradeAgreement/ram:SellerTradeParty');

  nodes := doc.selectNodes('//ram:ApplicableSupplyChainTradeAgreement/ram:SellerTradeParty/ram:SpecifiedTaxRegistration');
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

  Result.Buyer := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableSupplyChainTradeAgreement/ram:BuyerTradeParty');

  nodes := doc.selectNodes('//ram:ApplicableSupplyChainTradeAgreement/ram:BuyerTradeParty/ram:SpecifiedTaxRegistration');
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

  Result.ShipTo := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableSupplyChainTradeDelivery/ram:ShipToTradeParty');
  Result.ShipFrom := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableSupplyChainTradeDelivery/ram:ShipFromTradeParty');
  Result.ActualDeliveryDate:=XMLUtils._nodeAsDateTime(doc.DocumentElement, '//ram:ApplicableSupplyChainTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString');

  var _deliveryNoteNo : String := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableSupplyChainTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:ID');
  var _deliveryNoteDate : ZUGFeRDNullable<TDateTime> :=
    XMLUtils._nodeAsDateTime(doc.DocumentElement, '//ram:ApplicableSupplyChainTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:IssueDateTime/udt:DateTimeString');

  if not _deliveryNoteDate.HasValue then
  begin
    _deliveryNoteDate := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//ram:ApplicableSupplyChainTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:IssueDateTime');
  end;

  if ((_deliveryNoteDate.HasValue) or (_deliveryNoteNo <> '')) then
  begin
    Result.DeliveryNoteReferencedDocument := TZUGFeRDDeliveryNoteReferencedDocument.Create;
    Result.SetDeliveryNoteReferenceDocument(_deliveryNoteNo,_deliveryNoteDate);
  end;

  Result.Invoicee := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableSupplyChainTradeSettlement/ram:InvoiceeTradeParty');
  Result.Payee := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableSupplyChainTradeSettlement/ram:PayeeTradeParty');

  Result.PaymentReference := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableSupplyChainTradeSettlement/ram:PaymentReference');
  Result.Currency :=  TZUGFeRDCurrencyCodesExtensions.FromString(XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableSupplyChainTradeSettlement/ram:InvoiceCurrencyCode'));

  // TODO: Multiple SpecifiedTradeSettlementPaymentMeans can exist for each account/institution (with different SEPA?)
  var _tempPaymentMeans : TZUGFeRDPaymentMeans := TZUGFeRDPaymentMeans.Create;
  _tempPaymentMeans.TypeCode := TZUGFeRDPaymentMeansTypeCodesExtensions.FromString(XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableSupplyChainTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:TypeCode'));
  _tempPaymentMeans.Information := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableSupplyChainTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:Information');
  _tempPaymentMeans.SEPACreditorIdentifier := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableSupplyChainTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:ID');

  Result.PaymentMeans := _tempPaymentMeans;

  //TODO udt:DateTimeString
  Result.BillingPeriodStart := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//ram:ApplicableSupplyChainTradeSettlement/ram:BillingSpecifiedPeriod/ram:StartDateTime');
  Result.BillingPeriodEnd := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//ram:ApplicableSupplyChainTradeSettlement/ram:BillingSpecifiedPeriod/ram:EndDateTime');
  //Result.BillingPeriodStart := XMLUtils._nodeAsDateTime(doc.DocumentElement, "//ram:ApplicableHeaderTradeSettlement/ram:BillingSpecifiedPeriod/ram:StartDateTime');
  //Result.BillingPeriodEnd := XMLUtils._nodeAsDateTime(doc.DocumentElement, "//ram:ApplicableHeaderTradeSettlement/ram:BillingSpecifiedPeriod/ram:EndDateTime');

  var creditorFinancialAccountNodes : IXMLDOMNodeList := doc.SelectNodes('//ram:ApplicableSupplyChainTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayeePartyCreditorFinancialAccount');
  var creditorFinancialInstitutions : IXMLDOMNodeList := doc.SelectNodes('//ram:ApplicableSupplyChainTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayeeSpecifiedCreditorFinancialInstitution');

  if (creditorFinancialAccountNodes.length = creditorFinancialInstitutions.length) then
  for i := 0 to creditorFinancialAccountNodes.length-1 do
  begin
    var _account : TZUGFeRDBankAccount := TZUGFeRDBankAccount.Create;
    _account.ID := XMLUtils._nodeAsString(creditorFinancialAccountNodes[i], './/ram:ProprietaryID');
    _account.IBAN := XMLUtils._nodeAsString(creditorFinancialAccountNodes[i], './/ram:IBANID');
    _account.BIC := XMLUtils._nodeAsString(creditorFinancialInstitutions[i], './/ram:BICID');
    _account.Bankleitzahl := XMLUtils._nodeAsString(creditorFinancialInstitutions[i], './/ram:GermanBankleitzahlID');
    _account.BankName := XMLUtils._nodeAsString(creditorFinancialInstitutions[i], './/ram:Name');
    _account.Name := XMLUtils._nodeAsString(creditorFinancialInstitutions[i], './/ram:AccountName');
    Result.CreditorBankAccounts.Add(_account);
  end;

  var debitorFinancialAccountNodes : IXMLDOMNodeList := doc.SelectNodes('//ram:ApplicableSupplyChainTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayerPartyDebtorFinancialAccount');
  var debitorFinancialInstitutions : IXMLDOMNodeList := doc.SelectNodes('//ram:ApplicableSupplyChainTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayerSpecifiedDebtorFinancialInstitution');

  //TODO Index prüfen in der Schleife, bei csharp stand 0 drin
  if (debitorFinancialAccountNodes.length = debitorFinancialInstitutions.length) then
  begin
    for i := 0 to debitorFinancialAccountNodes.length-1 do
    begin
      var _account : TZUGFeRDBankAccount := TZUGFeRDBankAccount.Create;
      _account.ID := XMLUtils._nodeAsString(debitorFinancialAccountNodes[i], './/ram:ProprietaryID');
      _account.IBAN := XMLUtils._nodeAsString(debitorFinancialAccountNodes[i], './/ram:IBANID');
      _account.BIC := XMLUtils._nodeAsString(debitorFinancialInstitutions[i], './/ram:BICID');
      _account.Bankleitzahl := XMLUtils._nodeAsString(debitorFinancialInstitutions[i], './/ram:GermanBankleitzahlID');
      _account.BankName := XMLUtils._nodeAsString(debitorFinancialInstitutions[i], './/ram:Name');
      Result.DebitorBankAccounts.Add(_account);
    end;
  end;

  nodes := doc.SelectNodes('//ram:ApplicableSupplyChainTradeSettlement/ram:ApplicableTradeTax');
  for i := 0 to nodes.length-1 do
  begin
    Result.AddApplicableTradeTax(XMLUtils._nodeAsDecimal(nodes[i], './/ram:BasisAmount', TZUGFeRDNullableParam<Currency>.Create(0)),
                                 XMLUtils._nodeAsDecimal(nodes[i], './/ram:ApplicablePercent', TZUGFeRDNullableParam<Currency>.Create(0)),
                                 TZUGFeRDTaxTypesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:TypeCode')),
                                 TZUGFeRDTaxCategoryCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:CategoryCode')));
  end;

  nodes := doc.SelectNodes('//ram:SpecifiedTradeAllowanceCharge');
  for i := 0 to nodes.length-1 do
  begin
    Result.AddTradeAllowanceCharge(not XMLUtils._nodeAsBool(nodes[i], './/ram:ChargeIndicator'), // wichtig: das not (!) beachten
                                   XMLUtils._nodeAsDecimal(nodes[i], './/ram:BasisAmount', TZUGFeRDNullableParam<Currency>.Create(0)),
                                   Result.Currency,
                                   XMLUtils._nodeAsDecimal(nodes[i], './/ram:ActualAmount', TZUGFeRDNullableParam<Currency>.Create(0)),
                                   XMLUtils._nodeAsString(nodes[i], './/ram:Reason'),
                                   TZUGFeRDTaxTypesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:CategoryTradeTax/ram:TypeCode')),
                                   TZUGFeRDTaxCategoryCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:CategoryTradeTax/ram:CategoryCode')),
                                   XMLUtils._nodeAsDecimal(nodes[i], './/ram:CategoryTradeTax/ram:ApplicablePercent', TZUGFeRDNullableParam<Currency>.Create(0)));
  end;

  nodes := doc.SelectNodes('//ram:SpecifiedLogisticsServiceCharge');
  for i := 0 to nodes.length-1 do
  begin
    Result.AddLogisticsServiceCharge(XMLUtils._nodeAsDecimal(nodes[i], './/ram:AppliedAmount', TZUGFeRDNullableParam<Currency>.Create(0)),
                                     XMLUtils._nodeAsString(nodes[i], './/ram:Description'),
                                     TZUGFeRDTaxTypesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:AppliedTradeTax/ram:TypeCode')),
                                     TZUGFeRDTaxCategoryCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:AppliedTradeTax/ram:CategoryCode')),
                                     XMLUtils._nodeAsDecimal(nodes[i], './/ram:AppliedTradeTax/ram:ApplicablePercent', TZUGFeRDNullableParam<Currency>.Create(0)));
  end;

  nodes := doc.SelectNodes('//ram:SpecifiedTradePaymentTerms');
  for i := 0 to nodes.length-1 do
  begin
    Result.AddTradePaymentTerms(XMLUtils._nodeAsString(nodes[i], './/ram:Description'),
      XmlUtils._nodeAsDateTime(nodes[i], './/ram:DueDateDateTime'));
  end;

  Result.LineTotalAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementMonetarySummation/ram:LineTotalAmount', TZUGFeRDNullableParam<Currency>.Create(0));
  Result.ChargeTotalAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementMonetarySummation/ram:ChargeTotalAmount', nil);
  Result.AllowanceTotalAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementMonetarySummation/ram:AllowanceTotalAmount', nil);
  Result.TaxBasisAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementMonetarySummation/ram:TaxBasisTotalAmount', nil);
  Result.TaxTotalAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementMonetarySummation/ram:TaxTotalAmount', TZUGFeRDNullableParam<Currency>.Create(0));
  Result.GrandTotalAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementMonetarySummation/ram:GrandTotalAmount', TZUGFeRDNullableParam<Currency>.Create(0));
  Result.RoundingAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:RoundingAmount', TZUGFeRDNullableParam<Currency>.Create(0));
  Result.TotalPrepaidAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementMonetarySummation/ram:TotalPrepaidAmount', nil);
  Result.DuePayableAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementMonetarySummation/ram:DuePayableAmount', TZUGFeRDNullableParam<Currency>.Create(0));

  if (doc.DocumentElement.SelectSingleNode('//ram:ApplicableSupplyChainTradeAgreement/ram:BuyerOrderReferencedDocument/ram:IssueDateTime/udt:DateTimeString') <> nil) then
    Result.OrderDate:= XMLUtils._nodeAsDateTime(doc.DocumentElement, '//ram:ApplicableSupplyChainTradeAgreement/ram:BuyerOrderReferencedDocument/ram:IssueDateTime/udt:DateTimeString')
  else
    Result.OrderDate:= XMLUtils._nodeAsDateTime(doc.DocumentElement, '//ram:ApplicableSupplyChainTradeAgreement/ram:BuyerOrderReferencedDocument/ram:IssueDateTime');
  Result.OrderNo := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableSupplyChainTradeAgreement/ram:BuyerOrderReferencedDocument/ram:ID');

  nodes := doc.SelectNodes('//ram:IncludedSupplyChainTradeLineItem');
  for i := 0 to nodes.length-1 do
    Result.TradeLineItems.Add(_parseTradeLineItem(nodes[i]));
end;

function TZUGFeRDInvoiceDescriptor1Reader._nodeAsParty(basenode: IXmlDomNode;
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
  Result.ID.ID := XMLUtils._nodeAsString(node, 'ram:ID');
  Result.ID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiers.Unknown;
  Result.GlobalID.ID := XMLUtils._nodeAsString(node, 'ram:GlobalID');
  Result.GlobalID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiersExtensions.FromString(XMLUtils._nodeAsString(node, 'ram:GlobalID/@schemeID'));
  Result.Name := XMLUtils._nodeAsString(node, 'ram:Name');
  Result.Description := XMLUtils._nodeAsString(node, 'ram:Description'); // BT-33 Seller only
  Result.Postcode := XMLUtils._nodeAsString(node, 'ram:PostalTradeAddress/ram:PostcodeCode');
  Result.City := XMLUtils._nodeAsString(node, 'ram:PostalTradeAddress/ram:CityName');
  Result.Country := TZUGFeRDCountryCodesExtensions.FromString(XMLUtils._nodeAsString(node, 'ram:PostalTradeAddress/ram:CountryID'));

  lineOne := XMLUtils._nodeAsString(node, 'ram:PostalTradeAddress/ram:LineOne');
  lineTwo := XMLUtils._nodeAsString(node, 'ram:PostalTradeAddress/ram:LineTwo');

  if (not lineTwo.IsEmpty) then
  begin
    Result.ContactName := lineOne;
    Result.Street := lineTwo;
  end else
  begin
    Result.Street := lineOne;
    Result.ContactName := '';
  end;
end;

function TZUGFeRDInvoiceDescriptor1Reader._parseTradeLineItem(
  tradeLineItem: IXmlDomNode): TZUGFeRDTradeLineItem;
var
  nodes : IXMLDOMNodeList;
  i : Integer;
begin
  Result := nil;

  if (tradeLineItem = nil) then
    exit;

  var lineId := XmlUtils._NodeAsString(tradeLineItem, './/ram:AssociatedDocumentLineDocument/ram:LineID', String.Empty);

  Result := TZUGFeRDTradeLineItem.Create(lineId);

  Result.GlobalID.ID := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:GlobalID');
  Result.GlobalID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiersExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:GlobalID/@schemeID'));
  Result.SellerAssignedID := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:SellerAssignedID');
  Result.BuyerAssignedID := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:BuyerAssignedID');
  Result.Name := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:Name');
  Result.Description := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:Description');
  Result.UnitQuantity:=XMLUtils._nodeAsDouble(tradeLineItem, './/ram:BasisQuantity', TZUGFeRDNullableParam<Double>.Create(1));
  Result.BilledQuantity := XMLUtils._nodeAsDecimal(tradeLineItem, './/ram:BilledQuantity', TZUGFeRDNullableParam<Currency>.Create(0));
  Result.PackageQuantity := XMLUtils._nodeAsDouble(tradeLineItem, './/ram:PackageQuantity', TZUGFeRDNullableParam<Double>.Create(0));
  Result.ChargeFreeQuantity := XMLUtils._nodeAsDouble(tradeLineItem, './/ram:ChargeFreeQuantity',TZUGFeRDNullableParam<Double>.Create(0));
//  Result.LineTotalAmount.SetValue(XMLUtils._nodeAsDecimal(tradeLineItem, './/ram:LineTotalAmount', 0));
  Result.LineTotalAmount:= XMLUtils._nodeAsDouble(tradeLineItem, './/ram:LineTotalAmount', TZUGFeRDNullableParam<Double>.Create(0));
  Result.TaxCategoryCode := TZUGFeRDTaxCategoryCodesExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem, './/ram:ApplicableTradeTax/ram:CategoryCode'));
  Result.TaxType := TZUGFeRDTaxTypesExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem, './/ram:ApplicableTradeTax/ram:TypeCode'));
  Result.TaxPercent := XMLUtils._nodeAsDecimal(tradeLineItem, './/ram:ApplicableTradeTax/ram:ApplicablePercent',TZUGFeRDNullableParam<Currency>.Create(0));
  Result.NetUnitPrice:= XMLUtils._nodeAsDecimal(tradeLineItem, './/ram:NetPriceProductTradePrice/ram:ChargeAmount',TZUGFeRDNullableParam<Currency>.Create(0));
  Result.GrossUnitPrice:= XMLUtils._nodeAsDecimal(tradeLineItem, './/ram:GrossPriceProductTradePrice/ram:ChargeAmount',TZUGFeRDNullableParam<Currency>.Create(0));
  Result.UnitCode := TZUGFeRDQuantityCodesExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem,
    './/ram:BilledQuantity/@unitCode'));
  Result.BillingPeriodStart:= XMLUtils._nodeAsDateTime(tradeLineItem, './/ram:BillingSpecifiedPeriod/ram:StartDateTime/udt:DateTimeString');
  Result.BillingPeriodEnd:= XMLUtils._nodeAsDateTime(tradeLineItem, './/ram:BillingSpecifiedPeriod/ram:EndDateTime/udt:DateTimeString');

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

  nodes := tradeLineItem.SelectNodes('.//ram:SpecifiedSupplyChainTradeAgreement/ram:GrossPriceProductTradePrice/ram:AppliedTradeAllowanceCharge');
  for i := 0 to nodes.length-1 do
  begin

    var chargeIndicator : Boolean := XMLUtils._nodeAsBool(nodes[i], './ram:ChargeIndicator/udt:Indicator');
    var basisAmount : Currency := XMLUtils._nodeAsDecimal(nodes[i], './ram:BasisAmount', TZUGFeRDNullableParam<Currency>.Create(0));
    var basisAmountCurrency : String := XMLUtils._nodeAsString(nodes[i], './ram:BasisAmount/@currencyID');
    var actualAmount : Currency := XMLUtils._nodeAsDecimal(nodes[i], './ram:ActualAmount', TZUGFeRDNullableParam<Currency>.Create(0));
    var actualAmountCurrency : String := XMLUtils._nodeAsString(nodes[i], './ram:ActualAmount/@currencyID');
    var reason : String := XMLUtils._nodeAsString(nodes[i], './ram:Reason');

    Result.AddTradeAllowanceCharge(not chargeIndicator, // wichtig: das not beachten
                                    TZUGFeRDCurrencyCodesExtensions.FromString(basisAmountCurrency),
                                    basisAmount,
                                    actualAmount,
                                    reason,
                                    TZUGFeRDSpecialServiceDescriptionCodes.Unknown,
                                    TZUGFeRDAllowanceOrChargeIdentificationCodes.Unknown);
  end;

  if (Result.UnitCode = TZUGFeRDQuantityCodes.Unknown) then
  begin
    // UnitCode alternativ aus BilledQuantity extrahieren
    Result.UnitCode := TZUGFeRDQuantityCodesExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem, './/ram:BilledQuantity/@unitCode'));
  end;

  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedSupplyChainTradeAgreement/ram:BuyerOrderReferencedDocument/ram:ID') <> nil) then
  begin
    Result.BuyerOrderReferencedDocument := TZUGFeRDBuyerOrderReferencedDocument.Create;
    Result.BuyerOrderReferencedDocument.ID := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedSupplyChainTradeAgreement/ram:BuyerOrderReferencedDocument/ram:ID');
    Result.BuyerOrderReferencedDocument.IssueDateTime:= XMLUtils._nodeAsDateTime(tradeLineItem, './/ram:SpecifiedSupplyChainTradeAgreement/ram:BuyerOrderReferencedDocument/ram:IssueDateTime');
    Result.BuyerOrderReferencedDocument.LineID := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedSupplyChainTradeAgreement/ram:BuyerOrderReferencedDocument/ram:LineID');
  end;

  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedSupplyChainTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:ID') <> nil) then
  begin
    Result.DeliveryNoteReferencedDocument := TZUGFeRDDeliveryNoteReferencedDocument.Create;
    Result.DeliveryNoteReferencedDocument.ID := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedSupplyChainTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:ID');
    Result.DeliveryNoteReferencedDocument.IssueDateTime:= XMLUtils._nodeAsDateTime(tradeLineItem, './/ram:SpecifiedSupplyChainTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:IssueDateTime');
  end;

  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedSupplyChainTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime') <> nil) then
  begin
    Result.ActualDeliveryDate:= XMLUtils._nodeAsDateTime(tradeLineItem, './/ram:SpecifiedSupplyChainTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString');
  end;

  //Get all referenced AND embedded documents
  nodes := tradeLineItem.SelectNodes('.//ram:SpecifiedSupplyChainTradeAgreement/ram:AdditionalReferencedDocument');
  for i := 0 to nodes.length-1 do
  begin
    Result.AddAdditionalReferencedDocument(
        XMLUtils._nodeAsString(nodes[i], 'ram:ID'),
        TZUGFeRDReferenceTypeCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], 'ram:ReferenceTypeCode')),
        XMLUtils._nodeAsDateTime(nodes[i], 'ram:IssueDateTime')
    );
  end;
end;

end.
