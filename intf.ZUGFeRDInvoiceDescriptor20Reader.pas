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

unit intf.ZUGFeRDInvoiceDescriptor20Reader;

interface

uses
  System.SysUtils, System.Classes, System.DateUtils, System.Variants
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
  ,intf.ZUGFeRDGlobalID,intf.ZUGFeRDGlobalIDSchemeIdentifiers
  ,intf.ZUGFeRDCountryCodes
  ,intf.ZUGFeRDTaxRegistrationSchemeID
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
  ,intf.ZUGFeRDPaymentTerms
  ,intf.ZUGFeRDSellerOrderReferencedDocument
  ,intf.ZUGFeRDInvoiceReferencedDocument
  ,intf.ZUGFeRDQuantityCodes
  ,intf.ZUGFeRDApplicableProductCharacteristic
  ,intf.ZUGFeRDAssociatedDocument
  ,intf.ZUGFeRDNote
  ,intf.ZUGFeRDContentCodes
  ,intf.ZUGFeRDBuyerOrderReferencedDocument
  ,intf.ZUGFeRDContractReferencedDocument
  ,intf.ZUGFeRDSpecialServiceDescriptionCodes
  ,intf.ZUGFeRDAllowanceOrChargeIdentificationCodes
  ;

type
  TZUGFeRDInvoiceDescriptor20Reader = class(TZUGFeRDInvoiceDescriptorReader)
  private
    function GetValidURIs : TArray<string>;
    function _parseTradeLineItem(tradeLineItem : IXmlDomNode {nsmgr: XmlNamespaceManager := nil; }) : TZUGFeRDTradeLineItem;
    function _nodeAsParty(basenode: IXmlDomNode; const xpath: string) : TZUGFeRDParty;
    function _getAdditionalReferencedDocument(XmlNode : IXmlDomNode) : TZUGFeRDAdditionalReferencedDocument;
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
  intf.ZUGFeRDLineStatusCodes, intf.ZUGFeRDLineStatusReasonCodes, intf.ZUGFeRDIncludedReferencedProduct,
  intf.ZUGFeRDTradeDeliveryTermCodes, intf.ZUGFeRDDateTypeCodes;

{ TZUGFeRDInvoiceDescriptor20Reader }

function TZUGFeRDInvoiceDescriptor20Reader.GetValidURIs : TArray<string>;
begin
  Result := TArray<string>.Create(
    'urn:cen.eu:EN16931:2017#conformant#urn:zugferd.de:2p0:extended', // Profil EXTENDED
    'urn:cen.eu:EN16931:2017', // Profil EN 16931 (COMFORT)" +
    'urn:cen.eu:EN16931:2017#compliant#urn:zugferd.de:2p0:basic', // Profil BASIC
    'urn:zugferd.de:2p0:basicwl', // Profil BASIC WL
    'urn:zugferd.de:2p0:minimum' // Profil MINIMUM
  );
end;

function TZUGFeRDInvoiceDescriptor20Reader.IsReadableByThisReaderVersion(
  stream: TStream): Boolean;
begin
  Result := IsReadableByThisReaderVersion(stream, GetValidURIs);
end;

function TZUGFeRDInvoiceDescriptor20Reader.IsReadableByThisReaderVersion(
  xmldocument: IXMLDocument): Boolean;
begin
  Result := IsReadableByThisReaderVersion(xmldocument, GetValidURIs);
end;

function TZUGFeRDInvoiceDescriptor20Reader.Load(stream: TStream): TZUGFeRDInvoiceDescriptor;
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

function TZUGFeRDInvoiceDescriptor20Reader.Load(xmldocument : IXMLDocument): TZUGFeRDInvoiceDescriptor;
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

  //Get all referenced and embedded documents (BG-24)
  nodes := doc.SelectNodes('.//ram:ApplicableHeaderTradeAgreement/ram:AdditionalReferencedDocument');
  for i := 0 to nodes.length-1 do
  begin
    Result.AdditionalReferencedDocuments.Add(_getAdditionalReferencedDocument(nodes[i]));
  end;

  Result.ShipTo := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:ShipToTradeParty');
  Result.ShipFrom := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:ShipFromTradeParty');
  Result.ActualDeliveryDate:= XMLUtils._nodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString');

  var _deliveryNoteNo : String := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:IssuerAssignedID');
  var _deliveryNoteDate : ZUGFeRDNullable<TDateTime> := XMLUtils._nodeAsDateTime(doc.DocumentElement, '//ram:ApplicableHeaderTradeDelivery/ram:DeliveryNoteReferencedDocument/ram:IssueDateTime/udt:DateTimeString');

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
  Result.Payee := _nodeAsParty(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:PayeeTradeParty');

  Result.PaymentReference := XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:PaymentReference');
  Result.Currency :=  TZUGFeRDCurrencyCodesExtensions.FromString(XMLUtils._nodeAsString(doc.DocumentElement, '//ram:ApplicableHeaderTradeSettlement/ram:InvoiceCurrencyCode'));
  Result.SellerReferenceNo := XMLUtils._nodeAsString(doc.DocumentElement,
    '//ram:ApplicableHeaderTradeSettlement/ram:InvoiceIssuerReference');

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

  if (creditorFinancialAccountNodes.length = creditorFinancialInstitutions.length) then
  for i := 0 to creditorFinancialAccountNodes.length-1 do
  begin
    var _account : TZUGFeRDBankAccount := TZUGFeRDBankAccount.Create;
    _account.ID := XMLUtils._nodeAsString(creditorFinancialAccountNodes[i], './/ram:ProprietaryID');
    _account.IBAN := XMLUtils._nodeAsString(creditorFinancialAccountNodes[i], './/ram:IBANID');
    _account.Name := XMLUtils._nodeAsString(creditorFinancialAccountNodes[i], './/ram:AccountName');
    _account.BIC := XMLUtils._nodeAsString(creditorFinancialInstitutions[i], './/ram:BICID');
    _account.Bankleitzahl := XMLUtils._nodeAsString(creditorFinancialInstitutions[i], './/ram:GermanBankleitzahlID');
    _account.BankName := XMLUtils._nodeAsString(creditorFinancialInstitutions[i], './/ram:Name');
    Result.CreditorBankAccounts.Add(_account);
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

  //XmlNodeList debitorFinancialAccountNodes := doc.SelectNodes("//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayerPartyDebtorFinancialAccount');
  //XmlNodeList debitorFinancialInstitutions := doc.SelectNodes("//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementPaymentMeans/ram:PayerSpecifiedDebtorFinancialInstitution');

  //if (debitorFinancialAccountNodes.Count == debitorFinancialInstitutions.Count)
  //{
  //    for (int i := 0; i < debitorFinancialAccountNodes.Count; i++)
  //    {
  //        BankAccount _account := new BankAccount()
  //        {
  //            ID := XMLUtils._nodeAsString(debitorFinancialAccountNodes[0], ".//ram:ProprietaryID'),
  //            IBAN := XMLUtils._nodeAsString(debitorFinancialAccountNodes[0], ".//ram:IBANID'),
  //            BIC := XMLUtils._nodeAsString(debitorFinancialInstitutions[0], ".//ram:BICID'),
  //            Bankleitzahl := XMLUtils._nodeAsString(debitorFinancialInstitutions[0], ".//ram:GermanBankleitzahlID'),
  //            BankName := XMLUtils._nodeAsString(debitorFinancialInstitutions[0], ".//ram:Name'),
  //        };

  //        Result.DebitorBankAccounts.Add(_account);
  //    } // !for(i)
  //

  nodes := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:ApplicableTradeTax');
  for i := 0 to nodes.length-1 do
  begin
    Result.AddApplicableTradeTax(
      XMLUtils._nodeAsDecimal(nodes[i], './/ram:BasisAmount', TZUGFeRDNullableParam<Currency>.Create(0)),
      XMLUtils._nodeAsDecimal(nodes[i], './/ram:RateApplicablePercent',TZUGFeRDNullableParam<Currency>.Create(0)),
      XmlUtils._nodeAsDecimal(nodes[i], './/ram:CalculatedAmount', TZUGFeRDNullableParam<Currency>.Create(0)),
      TZUGFeRDTaxTypesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:TypeCode')),
      TZUGFeRDNullableParam<TZUGFeRDTaxCategoryCodes>.Create(
         TZUGFeRDTaxCategoryCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:CategoryCode'))),
      XMLUtils._nodeAsDecimal(nodes[i], './/ram:AllowanceChargeBasisAmount'),
      TZUGFeRDTaxExemptionReasonCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:ExemptionReasonCode')),
      XMLUtils._nodeAsString(nodes[i], './/ram:ExemptionReason'),
      XMLUtils._nodeAsDecimal(nodes[i], './/ram:LineTotalBasisAmount'))
      .SetTaxPointDate(XMLUtils._nodeAsDateTime(nodes[i], './/ram:TaxPointDate/udt:DateString'),
        TZUGFeRDDateTypeCodesExtensions.FromString(XMLUtils._nodeAsstring(nodes[i], './/ram:DueDateTypeCode')));
  end;

  nodes := doc.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeAllowanceCharge');
  for i := 0 to nodes.length-1 do
  begin
    Result.AddTradeAllowanceCharge(not XMLUtils._nodeAsBool(nodes[i], './/ram:ChargeIndicator'), // wichtig: das not (!) beachten
                                   XMLUtils._nodeAsDecimal(nodes[i], './/ram:BasisAmount',TZUGFeRDNullableParam<Currency>.Create(0)),
                                   Result.Currency,
                                   XMLUtils._nodeAsDecimal(nodes[i], './/ram:ActualAmount',TZUGFeRDNullableParam<Currency>.Create(0)),
                                   XMLUtils._nodeAsString(nodes[i], './/ram:Reason'),
                                   TZUGFeRDTaxTypesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:CategoryTradeTax/ram:TypeCode')),
                                   TZUGFeRDTaxCategoryCodesExtensions.FromString(XMLUtils._nodeAsString(nodes[i], './/ram:CategoryTradeTax/ram:CategoryCode')),
                                   XMLUtils._nodeAsDecimal(nodes[i], './/ram:CategoryTradeTax/ram:RateApplicablePercent', TZUGFeRDNullableParam<Currency>.Create(0)));
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

  nodes := doc.SelectNodes('//ram:SpecifiedTradePaymentTerms');
  for i := 0 to nodes.length-1 do
  begin
    var discountPercent := XmlUtils._NodeAsDecimal(nodes[i], './/ram:ApplicableTradePaymentDiscountTerms/ram:CalculationPercent', nil);
    var discountDueDays: ZUGFeRDNullable<Integer> := nil; // XmlUtils.NodeAsInt(node, ".//ram:ApplicableTradePaymentDiscountTerms/ram:BasisPeriodMeasure", nsmgr);
    var discountAmount := XmlUtils._NodeAsDecimal(nodes[i], './/ram:ApplicableTradePaymentDiscountTerms/ram:BasisAmount', nil);
    var penaltyPercent := XmlUtils._NodeAsDecimal(nodes[i], './/ram:ApplicableTradePaymentPenaltyTerms/ram:CalculationPercent', nil);
    var penaltyDueDays: ZUGFeRDNullable<Integer> := nil; // XmlUtils.NodeAsInt(node, ".//ram:ApplicableTradePaymentPenaltyTerms/ram:BasisPeriodMeasure", nsmgr);
    var penaltyAmount := XmlUtils._NodeAsDecimal(nodes[i], './/ram:ApplicableTradePaymentPenaltyTerms/ram:BasisAmount', nil);

    var paymentTermsType: ZUGFeRDNullable<TZUGFeRDPaymentTermsType> := nil;
    if discountPercent.HasValue then
      paymentTermsType := TZUGFeRDPaymentTermsType.Skonto
    else if penaltyPercent.HasValue then
      paymentTermsType := TZUGFeRDPaymentTermsType.Verzug;

    if discountDueDays = nil then
      discountDueDays := penaltyDueDays;
    if discountPercent = nil then
      discountPercent := penaltyPercent;
    if discountAmount = nil then
      discountAmount := penaltyAmount;

    result.AddTradePaymentTerms(
      XmlUtils._NodeAsString(nodes[i], './/ram:Description'),
      XmlUtils._NodeAsDateTime(nodes[i], './/ram:DueDateDateTime'),
      paymentTermsType, {TZUGFeRDNullableParam<TZUGFeRDPaymentTermsType>.Create(paymentTermsType.GetValueOrDefault),}
      discountDueDays, //discountDueDays.GetValueOrDefault(penaltyDueDays),
      discountPercent, //TZUGFeRDNullableParam<Currency>.Create(discountPercent.GetValueOrDefault(penaltyPercent)),
      discountAmount);//TZUGFeRDNullableParam<Currency>.Create(discountAmount.GetValueOrdefault(penaltyAmount)));
  end;

  Result.LineTotalAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:LineTotalAmount', TZUGFeRDNullableParam<Currency>.Create(0));
  Result.ChargeTotalAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:ChargeTotalAmount', nil);
  Result.AllowanceTotalAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:AllowanceTotalAmount', nil);
  Result.TaxBasisAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxBasisTotalAmount', nil);
  Result.TaxTotalAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxTotalAmount', TZUGFeRDNullableParam<Currency>.Create(0));
  Result.GrandTotalAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:GrandTotalAmount', TZUGFeRDNullableParam<Currency>.Create(0));
  Result.RoundingAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:RoundingAmount', TZUGFeRDNullableParam<Currency>.Create(0));
  Result.TotalPrepaidAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TotalPrepaidAmount', nil);
  Result.DuePayableAmount:= XMLUtils._nodeAsDecimal(doc.DocumentElement, '//ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:DuePayableAmount', TZUGFeRDNullableParam<Currency>.Create(0));

  // in this version we should only have on invoice referenced document but nevertheless...
  nodes := doc.DocumentElement.SelectNodes('//ram:ApplicableHeaderTradeSettlement/ram:InvoiceReferencedDocument');
  for i := 0 to nodes.length - 1 do
    Result.AddInvoiceReferencedDocument(
      XMLUtils._nodeAsString(nodes[i], './ram:IssuerAssignedID'),
      XMLUtils._nodeAsDateTime(nodes[i], './ram:FormattedIssueDateTime')
    );

  var buyerOrderReferencedDocumentNode := doc.SelectSingleNode(
    '//ram:ApplicableHeaderTradeAgreement/ram:BuyerOrderReferencedDocument');
  if (buyerOrderReferencedDocumentNode <> nil) then
  begin
    Result.OrderDate := DataTypeReader.ReadFormattedIssueDateTime(buyerOrderReferencedDocumentNode,
      'ram:FormattedIssueDateTime');
    Result.OrderNo := XmlUtils._nodeAsString(buyerOrderReferencedDocumentNode, 'ram:IssuerAssignedID');
  end;

  nodes := doc.SelectNodes('//ram:IncludedSupplyChainTradeLineItem');
  for i := 0 to nodes.length-1 do
    Result.TradeLineItems.Add(_parseTradeLineItem(nodes[i]));

  var deliveryCodeStr := XmlUtils._nodeAsString(doc.DocumentElement,
    '//ram:ApplicableHeaderTradeAgreement/ram:ApplicableTradeDeliveryTerms/ram:DeliveryTypeCode');
  if not string.IsNullOrWhiteSpace(deliveryCodeStr) then
  begin
    var tradeCode := TZUGFeRDTradeDeliveryTermCodesExtensions.FromString(deliveryCodeStr);
    if (tradeCode <> nil) then
      Result.ApplicableTradeDeliveryTermsCode := tradeCode;

  end;

  // Read SellerOrderReferencedDocument
  node := doc.SelectSingleNode('//ram:ApplicableHeaderTradeAgreement/ram:SellerOrderReferencedDocument');
  if node <> nil then
  begin
    Result.SellerOrderReferencedDocument := TZUGFeRDSellerOrderReferencedDocument.Create;
    Result.SellerOrderReferencedDocument.ID := XMLUtils._nodeAsString(node, 'ram:IssuerAssignedID');
    Result.SellerOrderReferencedDocument.IssueDateTime:= DataTypeReader.ReadFormattedIssueDateTime(node,
      'ram:FormattedIssueDateTime')
  end;
end;

function TZUGFeRDInvoiceDescriptor20Reader._getAdditionalReferencedDocument(
  XmlNode: IXmlDomNode): TZUGFeRDAdditionalReferencedDocument;
begin
  var strBase64BinaryData : String := XMLUtils._nodeAsString(XmlNode, 'ram:AttachmentBinaryObject');
  Result := TZUGFeRDAdditionalReferencedDocument.Create(false);
  Result.ID := XMLUtils._nodeAsString(XmlNode, 'ram:IssuerAssignedID');
  Result.TypeCode := TZUGFeRDAdditionalReferencedDocumentTypeCodeExtensions.FromString(
    XMLUtils._nodeAsString(XmlNode, 'ram:TypeCode'));
  Result.Name := XMLUtils._nodeAsString(XmlNode, 'ram:Name');
  Result.IssueDateTime:= DataTypeReader.ReadFormattedIssueDateTime(XmlNode, 'ram:FormattedIssueDateTime');
  if strBase64BinaryData <> '' then
  begin
    Result.AttachmentBinaryObject := TMemoryStream.Create;
    var strBase64BinaryDataBytes : TBytes := TNetEncoding.Base64String.DecodeStringToBytes(strBase64BinaryData);
    Result.AttachmentBinaryObject.Write(strBase64BinaryDataBytes,Length(strBase64BinaryDataBytes));
  end;
  Result.Filename := XMLUtils._nodeAsString(XmlNode, 'ram:AttachmentBinaryObject/@filename');
  Result.ReferenceTypeCode := TZUGFeRDReferenceTypeCodesExtensions.FromString(XMLUtils._nodeAsString(XmlNode, 'ram:ReferenceTypeCode'));
end;

function TZUGFeRDInvoiceDescriptor20Reader._nodeAsParty(basenode: IXmlDomNode;
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
  Result.AddressLine3 := XMLUtils._nodeAsString(node, 'ram:PostalTradeAddress/ram:LineThree');
  Result.CountrySubdivisionName := XMLUtils._nodeAsString(node, 'ram:PostalTradeAddress/ram:CountrySubDivisionName');
end;

function TZUGFeRDInvoiceDescriptor20Reader._parseTradeLineItem(
  tradeLineItem: IXmlDomNode): TZUGFeRDTradeLineItem;
var
  nodes : IXMLDOMNodeList;
  i : Integer;
begin
  Result := nil;

  if (tradeLineItem = nil) then
    exit;

  var lineId := XmlUtils._NodeAsString(tradeLineItem, './/ram:AssociatedDocumentLineDocument/ram:LineID',
    String.Empty);

   var lineStatusCode := TZUGFeRDLineStatusCodesExtensions.FromString(
    XmlUtils._nodeAsString(tradeLineItem, './/ram:AssociatedDocumentLineDocument/ram:LineStatusCode'));
  var lineStatusReasonCode := TZUGFeRDLineStatusReasonCodesExtensions.FromString(
    XmlUtils._nodeAsString(tradeLineItem, './/ram:AssociatedDocumentLineDocument/ram:LineStatusReasonCode'));

  Result := TZUGFeRDTradeLineItem.Create(lineId);

  Result.GlobalID.ID := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:GlobalID');
  Result.GlobalID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiersExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:GlobalID/@schemeID'));
  Result.SellerAssignedID := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:SellerAssignedID');
  Result.BuyerAssignedID := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:BuyerAssignedID');
  Result.Name := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:Name');
  Result.Description := XMLUtils._nodeAsString(tradeLineItem, './/ram:SpecifiedTradeProduct/ram:Description');
  Result.UnitQuantity:= XMLUtils._nodeAsDouble(tradeLineItem, './/ram:BasisQuantity', TZUGFeRDNullableParam<Double>.Create(1));
  Result.BilledQuantity := XMLUtils._nodeAsDouble(tradeLineItem, './/ram:BilledQuantity', TZUGFeRDNullableParam<Double>.Create(0));
  Result.PackageQuantity := XMLUtils._nodeAsDouble(tradeLineItem, './/ram:PackageQuantity', TZUGFeRDNullableParam<Double>.Create(0));
  Result.ChargeFreeQuantity := XMLUtils._nodeAsDouble(tradeLineItem, './/ram:ChargeFreeQuantity', TZUGFeRDNullableParam<Double>.Create(0));
  Result.LineTotalAmount:= XMLUtils._nodeAsDouble(tradeLineItem, './/ram:LineTotalAmount', TZUGFeRDNullableParam<Double>.Create(0));
  Result.TaxCategoryCode := TZUGFeRDTaxCategoryCodesExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem, './/ram:ApplicableTradeTax/ram:CategoryCode'));
  Result.TaxType := TZUGFeRDTaxTypesExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem, './/ram:ApplicableTradeTax/ram:TypeCode'));
  Result.TaxPercent := XMLUtils._nodeAsDecimal(tradeLineItem, './/ram:ApplicableTradeTax/ram:RateApplicablePercent', TZUGFeRDNullableParam<Currency>.Create(0));
  Result.NetUnitPrice:= XMLUtils._nodeAsDouble(tradeLineItem, './/ram:NetPriceProductTradePrice/ram:ChargeAmount', TZUGFeRDNullableParam<Double>.Create(0));
  Result.GrossUnitPrice:= XMLUtils._nodeAsDouble(tradeLineItem, './/ram:GrossPriceProductTradePrice/ram:ChargeAmount', TZUGFeRDNullableParam<Double>.Create(0));
  Result.UnitCode := TZUGFeRDQuantityCodesExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem,
    './/ram:BilledQuantity/@unitCode'));
  Result.BillingPeriodStart:= XMLUtils._nodeAsDateTime(tradeLineItem, './/ram:BillingSpecifiedPeriod/ram:StartDateTime/udt:DateTimeString');
  Result.BillingPeriodEnd:= XMLUtils._nodeAsDateTime(tradeLineItem, './/ram:BillingSpecifiedPeriod/ram:EndDateTime/udt:DateTimeString');

  if (lineStatusCode.HasValue and  lineStatusReasonCode.HasValue) then
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

      var unitCode: ZUGFeRDNullable<TZUGFeRDQuantityCodes> := nil;
      var unitCodeAsString := XmlUtils._nodeAsString(nodes[i], './/ram:UnitQuantity/@unitCode');

      if (not String.IsNullOrWhiteSpace(unitCodeAsString)) then
          unitCode := TZUGFeRDQuantityCodesExtensions.FromString(unitCodeAsString);


      var index := result.IncludedReferencedProducts.Add(TZUGFeRDIncludedReferencedProduct.Create);
      result.IncludedReferencedProducts[index].Name :=
        XmlUtils._nodeAsString(nodes[i], './/ram:Name');
      result.IncludedReferencedProducts[index].UnitQuantity :=
        XmlUtils._nodeAsDouble(nodes[i], './/ram:UnitQuantity');
      result.IncludedReferencedProducts[index].UnitCode := unitCode
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
    var basisAmount := XMLUtils._nodeAsDecimal(nodes[i], './ram:BasisAmount',TZUGFeRDNullableParam<Currency>.Create(0));
    var basisAmountCurrency : String := XMLUtils._nodeAsString(nodes[i], './ram:BasisAmount/@currencyID');
    var actualAmount : Currency := XMLUtils._nodeAsDecimal(nodes[i], './ram:ActualAmount', TZUGFeRDNullableParam<Currency>.Create(0));
    var reason : String := XMLUtils._nodeAsString(nodes[i], './ram:Reason');

    Result.AddTradeAllowanceCharge(not chargeIndicator, // wichtig: das not beachten
                                    TZUGFeRDCurrencyCodesExtensions.FromString(basisAmountCurrency),
                                    basisAmount,
                                    actualAmount,
                                    reason);
  end;

  if (Result.UnitCode = TZUGFeRDQuantityCodes.Unknown) then
  begin
    // UnitCode alternativ aus BilledQuantity extrahieren
    Result.UnitCode := TZUGFeRDQuantityCodesExtensions.FromString(XMLUtils._nodeAsString(tradeLineItem, './/ram:BilledQuantity/@unitCode'));
  end;

  var buyerOrderReferencedDocumentNode := tradeLineItem.SelectSingleNode(
    './/ram:SpecifiedLineTradeAgreement/ram:BuyerOrderReferencedDocument');
  if (buyerOrderReferencedDocumentNode <> nil) then
  begin
      Result.BuyerOrderReferencedDocument := TZUGFeRDBuyerOrderReferencedDocument.Create;
      Result.BuyerOrderReferencedDocument.ID := XMLUtils._nodeAsString(buyerOrderReferencedDocumentNode,
        'ram:IssuerAssignedID');
      Result.BuyerOrderReferencedDocument.IssueDateTime:=
        DataTypeReader.ReadFormattedIssueDateTime(buyerOrderReferencedDocumentNode, 'ram:FormattedIssueDateTime');
      Result.BuyerOrderReferencedDocument.LineID := XmlUtils._nodeAsString(buyerOrderReferencedDocumentNode,
        'ram:BuyerOrderReferencedDocument/ram:LineID');
  end;

  var deliveryNoteReferencedDocumentNode := tradeLineItem.SelectSingleNode(
    './/ram:SpecifiedLineTradeDelivery/ram:DeliveryNoteReferencedDocument');
  if (deliveryNoteReferencedDocumentNode <> nil) then
  begin
      Result.DeliveryNoteReferencedDocument := TZUGFeRDDeliveryNoteReferencedDocument.Create;
      Result.DeliveryNoteReferencedDocument.ID := XmlUtils._nodeAsString(deliveryNoteReferencedDocumentNode,
        'ram:IssuerAssignedID');
      Result.DeliveryNoteReferencedDocument.IssueDateTime :=
        DataTypeReader.ReadFormattedIssueDateTime(deliveryNoteReferencedDocumentNode, 'ram:FormattedIssueDateTime');

  end;


  if (tradeLineItem.SelectSingleNode('.//ram:SpecifiedLineTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime') <> nil) then
  begin
    Result.ActualDeliveryDate:= XMLUtils._nodeAsDateTime(tradeLineItem, './/ram:SpecifiedLineTradeDelivery/ram:ActualDeliverySupplyChainEvent/ram:OccurrenceDateTime/udt:DateTimeString');
  end;

  var contractReferencedDocument := tradeLineItem.SelectSingleNode(
    './/ram:SpecifiedLineTradeAgreement/ram:ContractReferencedDocument');
  if (contractReferencedDocument <> nil) then
  begin
    Result.ContractReferencedDocument := TZUGFeRDContractReferencedDocument.CreateWithParams(
        XmlUtils._nodeAsString(contractReferencedDocument, 'ram:IssuerAssignedID'),
        DataTypeReader.ReadFormattedIssueDateTime(contractReferencedDocument, 'ram:FormattedIssueDateTime')
      );
  end;

  //Get all referenced AND embedded documents
  nodes := tradeLineItem.SelectNodes('.//ram:SpecifiedLineTradeAgreement/ram:AdditionalReferencedDocument');
  for i := 0 to nodes.length-1 do
  begin
    Result.AdditionalReferencedDocuments.Add(_getAdditionalReferencedDocument(nodes[i]));
  end;
end;

end.
