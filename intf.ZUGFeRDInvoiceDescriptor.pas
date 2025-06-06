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

unit intf.ZUGFeRDInvoiceDescriptor;

interface

uses
  System.SysUtils,System.Classes,System.Generics.Collections,
  System.Generics.Defaults,Xml.XMLIntf,
  intf.ZUGFeRDAdditionalReferencedDocument,
  intf.ZUGFeRDDeliveryNoteReferencedDocument,
  intf.ZUGFeRDAccountingAccountTypeCodes,
  intf.ZUGFeRDAssociatedDocument,
  intf.ZUGFeRDContractReferencedDocument,
  intf.ZUGFeRDSpecifiedProcuringProject,
  intf.ZUGFeRDParty,
  intf.ZUGFeRDQuantityCodes,
  intf.ZUGFeRDPaymentMeansTypeCodes,
  intf.ZUGFeRDAdditionalReferencedDocumentTypeCodes,
  intf.ZUGFeRDReferenceTypeCodes,
  intf.ZUGFeRDGlobalID,intf.ZUGFeRDGlobalIDSchemeIdentifiers,
  intf.ZUGFeRDTaxRegistration,
  intf.ZUGFeRDTaxRegistrationSchemeID,
  intf.ZUGFeRDTaxTypes,
  intf.ZUGFeRDTaxCategoryCodes,
  intf.ZUGFeRDTaxExemptionReasonCodes,
  intf.ZUGFeRDContact,
  intf.ZUGFeRDNote,
  intf.ZUGFeRDCurrencyCodes,
  intf.ZUGFeRDProfile,
  intf.ZUGFeRDInvoiceTypes,
  intf.ZUGFeRDTradeLineItem,
  intf.ZUGFeRDTax,
  intf.ZUGFeRDServiceCharge,
  intf.ZUGFeRDTradeAllowanceCharge,
  intf.ZUGFeRDPaymentTerms,
  intf.ZUGFeRDInvoiceReferencedDocument,
  intf.ZUGFeRDBankAccount,
  intf.ZUGFeRDReceivableSpecifiedTradeAccountingAccount,
  intf.ZUGFeRDPaymentMeans,
  intf.ZUGFeRDSellerOrderReferencedDocument,
  intf.ZUGFeRDHelper,
  intf.ZUGFeRDVersion,
  intf.ZUGFeRDExceptions,
  intf.ZUGFeRDSubjectCodes,
  intf.ZUGFeRDContentCodes,
  intf.ZUGFeRDCountryCodes,
  intf.ZUGFeRDLegalOrganization,
  intf.ZUGFeRDElectronicAddress,
  intf.ZUGFeRDElectronicAddressSchemeIdentifiers,
  intf.ZUGFeRDDespatchAdviceReferencedDocument,
  intf.ZUGFeRDSpecialServiceDescriptionCodes,
  intf.ZUGFeRDAllowanceOrChargeIdentificationCodes,
  intf.ZUGFeRDFormats,
  intf.ZUGFeRDPaymentTermsType,
  intf.ZUGFeRDTransportmodeCodes,
  intf.ZUGFeRDTradeDeliveryTermCodes,
  intf.ZUGFeRDAllowanceReasonCodes
  ;

type
  /// <summary>
  /// Represents a ZUGFeRD/ Factur-X invoice
  /// </summary>
  TZUGFeRDInvoiceDescriptor = class
  private
    FInvoiceNo: string;
    FInvoiceDate: ZUGFeRDNullable<TDateTime>;
    FPaymentReference: string;
    FOrderNo: string;
    FOrderDate: ZUGFeRDNullable<TDateTime>;
    FAdditionalReferencedDocuments: TObjectList<TZUGFeRDAdditionalReferencedDocument>;
    FDeliveryNoteReferencedDocument: TZUGFeRDDeliveryNoteReferencedDocument;
    FActualDeliveryDate: ZUGFeRDNullable<TDateTime>;
    FContractReferencedDocument: TZUGFeRDContractReferencedDocument;
    FSpecifiedProcuringProject: TZUGFeRDSpecifiedProcuringProject;
    FCurrency: TZUGFeRDCurrencyCodes;
    FBuyer: TZUGFeRDParty;
    FBuyerContact: TZUGFeRDContact;
    FBuyerTaxRegistration: TObjectList<TZUGFeRDTaxRegistration>;
    FShipToTaxRegistration: TObjectList<TZUGFeRDTaxRegistration>;
    FBuyerElectronicAddress: TZUGFeRDElectronicAddress;
    FSeller: TZUGFeRDParty;
    FSellerContact: TZUGFeRDContact;
    FSellerTaxRegistration: TObjectList<TZUGFeRDTaxRegistration>;
    FInvoiceeTaxRegistration: TObjectList<TZUGFeRDTaxRegistration>;
    FSellerTaxRepresentativeTaxRegistration: TObjectList<TZUGFeRDTaxRegistration>;
    FSellerElectronicAddress: TZUGFeRDElectronicAddress;
    FInvoicee: TZUGFeRDParty;
    FShipTo: TZUGFeRDParty;
    FPayee: TZUGFeRDParty;
    FShipFrom: TZUGFeRDParty;
    FShipToContact: TZUGFeRDContact;
    FUltimateShipToContact: TZUGFeRDContact;
    FUltimateShipTo: TZUGFeRDParty;
    FNotes: TObjectList<TZUGFeRDNote>;
    FBusinessProcess: string;
    FIsTest: Boolean;
    FProfile: TZUGFeRDProfile;
    FType: TZUGFeRDInvoiceType;
    FReferenceOrderNo: string;
    FTradeLineItems: TObjectList<TZUGFeRDTradeLineItem>;
    FLineTotalAmount: ZUGFeRDNullable<Currency>;
    FChargeTotalAmount: ZUGFeRDNullable<Currency>;
    FAllowanceTotalAmount: ZUGFeRDNullable<Currency>;
    FTaxBasisAmount: ZUGFeRDNullable<Currency>;
    FTaxTotalAmount: ZUGFeRDNullable<Currency>;
    FGrandTotalAmount: ZUGFeRDNullable<Currency>;
    FTotalPrepaidAmount: ZUGFeRDNullable<Currency>;
    FRoundingAmount: ZUGFeRDNullable<Currency>;
    FDuePayableAmount: ZUGFeRDNullable<Currency>;
    FTaxes: TObjectList<TZUGFeRDTax>;
    FServiceCharges: TObjectList<TZUGFeRDServiceCharge>;
    FTradeAllowanceCharges: TObjectList<TZUGFeRDTradeAllowanceCharge>;
    FPaymentTermsList: TObjectList<TZUGFeRDPaymentTerms>;
    FInvoiceReferencedDocuments: TObjectList<TZUGFeRDInvoiceReferencedDocument>;
    FReceivableSpecifiedTradeAccountingAccounts: TObjectList<TZUGFeRDReceivableSpecifiedTradeAccountingAccount>;
    FCreditorBankAccounts: TObjectList<TZUGFeRDBankAccount>;
    FDebitorBankAccounts: TObjectList<TZUGFeRDBankAccount>;
    FPaymentMeans: TZUGFeRDPaymentMeans;
    FBillingPeriodStart: ZUGFeRDNullable<TDateTime>;
    FBillingPeriodEnd: ZUGFeRDNullable<TDateTime>;
    FSellerOrderReferencedDocument: TZUGFeRDSellerOrderReferencedDocument;
    FDespatchAdviceReferencedDocument: TZUGFeRDDespatchAdviceReferencedDocument;
    FName: string;
    FTaxCurrency: ZUGFeRDNullable<TZUGFeRDCurrencyCodes>;
    FSellerReferenceNo: string;
    FInvoicer: TZUGFeRDParty;
    FSellerTaxRepresentative: TZUGFeRDParty;
    FTransportMode: ZUGFeRDNullable<TZUGFeRDTransportModeCodes>;
    FApplicableTradeDeliveryTermsCode:ZUGFeRDNullable<TZUGFeRDTradeDeliveryTermCodes>;
    procedure SetInvoicerParty(const Value: TZUGFeRDParty);
    procedure SetSellerParty(const Value: TZUGFeRDParty);
    procedure SetInvoiceeParty(const Value: TZUGFeRDParty);
    procedure SetBuyerParty(const Value: TZUGFeRDParty);
    procedure SetSellerTaxRepresentative(const Value: TZUGFeRDParty);
    procedure SetShipTo(const Value: TZUGFeRDParty);
    procedure SetUltimateShipTo(const Value: TZUGFeRDParty);
    procedure SetUltimateShipToContact(const Value: TZUGFeRDContact);
    procedure SetShipToContact(const Value: TZUGFeRDContact);
    function GetAnyCreditorFinancialAccount: Boolean;
    function GetAnyDebitorFinancialAcoount: Boolean;
    function GetAnyApplicableTradeTaxes: Boolean;
  public
    /// <summary>
    /// Invoice Number
    /// </summary>
    property InvoiceNo: string read FInvoiceNo write FInvoiceNo;

    /// <summary>
    /// Invoice date
    /// </summary>
    property InvoiceDate: ZUGFeRDNullable<TDateTime> read FInvoiceDate write FInvoiceDate;

    /// <summary>
    /// A textual value used to establish a link between the payment and the invoice, issued by the seller.
    /// </summary>
    property PaymentReference: string read FPaymentReference write FPaymentReference;

    /// <summary>
    /// Order Id
    /// </summary>
    property OrderNo: string read FOrderNo write FOrderNo;

    /// <summary>
    /// Order date
    /// </summary>
    property OrderDate: ZUGFeRDNullable<TDateTime> read FOrderDate write FOrderDate;

    /// <summary>
    /// Details of an additional document reference
    ///
    /// A new reference document is added by AddAdditionalReferenceDocument()
    /// </summary>
    property AdditionalReferencedDocuments: TObjectList<TZUGFeRDAdditionalReferencedDocument> read FAdditionalReferencedDocuments;

    /// <summary>
    /// Detailed information about the corresponding despatch advice
    /// </summary>
    property DespatchAdviceReferencedDocument : TZUGFeRDDespatchAdviceReferencedDocument read FDespatchAdviceReferencedDocument write FDespatchAdviceReferencedDocument;

    /// <summary>
    /// Detailed information about the corresponding delivery note
    /// </summary>
    property DeliveryNoteReferencedDocument: TZUGFeRDDeliveryNoteReferencedDocument read FDeliveryNoteReferencedDocument write FDeliveryNoteReferencedDocument;

    /// <summary>
    /// Actual delivery date
    /// </summary>
    property ActualDeliveryDate: ZUGFeRDNullable<TDateTime> read FActualDeliveryDate write FActualDeliveryDate;

    /// <summary>
    /// Detailed information on the associated contract
    ///
    /// BT-12
    /// </summary>
    property ContractReferencedDocument: TZUGFeRDContractReferencedDocument read FContractReferencedDocument write FContractReferencedDocument;

    /// <summary>
    /// Details about a project reference
    /// </summary>
    property SpecifiedProcuringProject: TZUGFeRDSpecifiedProcuringProject read FSpecifiedProcuringProject write FSpecifiedProcuringProject;

    /// <summary>
    /// Currency of the invoice
    /// </summary>
    property Currency: TZUGFeRDCurrencyCodes read FCurrency write FCurrency;

		/// <summary>
		/// The VAT total amount expressed in the accounting currency accepted or
    /// required in the country of the seller.
    ///
    /// Note: Shall be used in combination with the invoice total VAT amount
    /// in accounting currency (BT-111), if the VAT accounting currency code
    /// differs from the invoice currency code.
    ///
    /// In normal invoicing scenarios, leave this property empty!
    ///
    /// The lists of valid currencies are
    /// registered with the ISO 4217 Maintenance Agency „Codes for the
    /// representation of currencies and funds”. Please refer to Article 230
    /// of the Council Directive 2006/112/EC [2] for further information.
    ///
    /// BT-6
		/// </summary>
		property TaxCurrency: ZUGFeRDNullable<TZUGFeRDCurrencyCodes> read FTaxCurrency write FTaxCurrency;
    /// <summary>
    /// Information about the buyer
    /// </summary>
    property Buyer: TZUGFeRDParty read FBuyer write SetBuyerParty;

    /// <summary>
    /// Buyer contact information
    ///
    /// A group of business terms providing contact information relevant for the buyer.
    /// </summary>
    property BuyerContact: TZUGFeRDContact read FBuyerContact write FBuyerContact;

    property BuyerTaxRegistration: TObjectList<TZUGFeRDTaxRegistration> read FBuyerTaxRegistration;
    property BuyerElectronicAddress : TZUGFeRDElectronicAddress read FBuyerElectronicAddress;
    property Seller: TZUGFeRDParty read FSeller write SetSellerParty;
    property SellerContact: TZUGFeRDContact read FSellerContact write FSellerContact;
    property SellerTaxRegistration: TObjectList<TZUGFeRDTaxRegistration> read FSellerTaxRegistration;
    property SellerElectronicAddress : TZUGFeRDElectronicAddress read FSellerElectronicAddress;

		/// <summary>
		/// Given seller reference number for routing purposes after biliteral agreement
    ///
    /// This field seems not to be used in common scenarios.
		/// </summary>
		property SellerReferenceNo: string read FSellerReferenceNo write FSellerReferenceNo;

    /// <summary>
    /// A group of business terms providing information about the Seller's tax representative.
    /// BG-11
    /// </summary>
    property SellerTaxRepresentative: TZUGFeRDParty read FSellerTaxRepresentative write SetSellerTaxRepresentative;

    /// <summary>
    /// List of tax registration numbers for the seller.
    ///
    /// BT-63
    /// </summary>
    property SellerTaxRepresentativeTaxRegistration: TObjectList<TZUGFeRDTaxRegistration> read
       FSellerTaxRepresentativeTaxRegistration;

    /// <summary>
    /// This party is optional and only relevant for Extended profile
    /// </summary>
    property Invoicee: TZUGFeRDParty read FInvoicee write SetInvoiceeParty;

    /// <summary>
    ///     Detailed information on tax information
    ///     BT-X-242-00
    /// </summary>
    property InvoiceeTaxRegistration: TObjectList<TZUGFeRDTaxRegistration> read FInvoiceeTaxRegistration;

		/// <summary>
		/// This party is optional and only relevant for Extended profile.
    ///
    /// It seems to be used under rate condition only.
		/// </summary>
		property Invoicer: TZUGFeRDParty read FInvoicer write SetInvoicerParty;

    /// <summary>
    /// This party is optional and only relevant for Extended profile
    /// </summary>
    property ShipTo: TZUGFeRDParty read FShipTo write SetShipTo;

    /// <summary>
    ///     Detailed information on tax information of the goods recipient
    ///     BT-X-66-00
    /// </summary>
    property ShipToTaxRegistration: TObjectList<TZUGFeRDTaxRegistration> read FShipToTaxRegistration;

    /// <summary>
    /// Detailed contact information of the recipient
    /// BG-X-26
    /// </summary>
    property ShipToContact: TZUGFeRDContact read FShipToContact write SetShipToContact;

    /// <summary>
    /// This party is optional and only relevant for Extended profile
    /// </summary>
    property UltimateShipTo: TZUGFeRDParty read FUltimateShipTo write SetUltimateShipTo;

    /// <summary>
    /// Detailed contact information of the final goods recipient
    /// BG-X-11
    /// </summary>
    property UltimateShipToContact: TZUGFeRDContact read FUltimateShipToContact write SetUltimateShipToContact;

    /// <summary>
    /// This party is optional and only relevant for Extended profile
    /// </summary>
    property Payee: TZUGFeRDParty read FPayee write FPayee;

    /// <summary>
    /// This party is optional and only relevant for Extended profile
    /// </summary>
    property ShipFrom: TZUGFeRDParty read FShipFrom write FShipFrom;

    /// <summary>
    /// Free text on header level
    /// </summary>
    property Notes: TObjectList<TZUGFeRDNote> read FNotes;

    /// <summary>
    /// Description: Identifies the context of a business process where the transaction is taking place,
    /// thus allowing the buyer to process the invoice in an appropriate manner.
    ///
    /// Note: These data make it possible to define the purpose of the settlement(invoice of the authorised person,
    /// contractual partner, subcontractor, settlement document for a building contract etc.).
    ///
    /// BT-23
    /// </summary>
    property BusinessProcess: string read FBusinessProcess write FBusinessProcess;

    /// <summary>
    /// The Indicator type may be used when implementing a new system in order to mark the invoice as „trial invoice“.
    /// </summary>
    property IsTest: Boolean read FIsTest write FIsTest;

    /// <summary>
    /// Representation of information that should be used for the document.
    ///
    /// As the library can be used to both write ZUGFeRD files and read ZUGFeRD files, the profile serves two purposes:
    /// It indicates the profile that was used to write the ZUGFeRD file that was loaded or the profile that is to be used when
    /// the document is saved.
    /// </summary>
    property Profile: TZUGFeRDProfile read FProfile write FProfile default TZUGFeRDProfile.Basic;

    /// <summary>
    /// Document name (free text)
    /// </summary>
    property Name: string read FName write FName;

    /// <summary>
    /// Indicates the type of the document, if it represents an invoice, a credit note or one of the available 'sub types'
    /// </summary>
    property Type_: TZUGFeRDInvoiceType read FType write FType default TZUGFeRDInvoiceType.Invoice;

    /// <summary>
    /// The identifier is defined by the buyer (e.g. contact ID, department, office ID, project code), but provided by the seller in the invoice.
    /// In France it needs to be filled with 999, if not available.
    ///
    /// BT-10
    /// </summary>
    property ReferenceOrderNo: string read FReferenceOrderNo write FReferenceOrderNo;

    /// <summary>
    /// An aggregation of business terms containing information about individual invoice positions
    /// </summary>
    property TradeLineItems: TObjectList<TZUGFeRDTradeLineItem> read FTradeLineItems;

    /// <summary>
    /// Sum of all invoice line net amounts in the invoice
    /// </summary>
    property LineTotalAmount: ZUGFeRDNullable<Currency> read FLineTotalAmount write FLineTotalAmount;

    /// <summary>
    /// Sum of all surcharges on document level in the invoice
    ///
    /// Surcharges on line level are included in the invoice line net amount which is summed up into the sum of invoice line net amount.
    /// </summary>
    property ChargeTotalAmount: ZUGFeRDNullable<Currency> read FChargeTotalAmount write FChargeTotalAmount;

    /// <summary>
    /// Sum of discounts on document level in the invoice
    ///
    /// Discounts on line level are included in the invoice line net amount which is summed up into the sum of invoice line net amount.
    /// </summary>
    property AllowanceTotalAmount: ZUGFeRDNullable<Currency> read FAllowanceTotalAmount write FAllowanceTotalAmount;

    /// <summary>
    /// The total amount of the invoice without VAT.
    ///
    /// The invoice total amount without VAT is the sum of invoice line net amount minus sum of discounts on document level plus sum of surcharges on document level.
    /// </summary>
    property TaxBasisAmount: ZUGFeRDNullable<Currency> read FTaxBasisAmount write FTaxBasisAmount;

    /// <summary>
    /// The total VAT amount for the invoice.
    /// The VAT total amount expressed in the accounting currency accepted or required in the country of the seller
    ///
    /// To be used when the VAT accounting currency (BT-6) differs from the Invoice currency code (BT-5) in accordance
    /// with article 230 of Directive 2006/112 / EC on VAT. The VAT amount in accounting currency is not used
    /// in the calculation of the Invoice totals..
    /// </summary>
    property TaxTotalAmount: ZUGFeRDNullable<Currency> read FTaxTotalAmount write FTaxTotalAmount;

    /// <summary>
    /// Invoice total amount with VAT
    ///
    /// The invoice total amount with VAT is the invoice without VAT plus the invoice total VAT amount.
    /// </summary>
    property GrandTotalAmount: ZUGFeRDNullable<Currency> read FGrandTotalAmount write FGrandTotalAmount;

    /// <summary>
    /// Sum of amount paid in advance
    ///
    /// This amount is subtracted from the invoice total amount with VAT to calculate the amount due for payment.
    /// </summary>
    property TotalPrepaidAmount: ZUGFeRDNullable<Currency> read FTotalPrepaidAmount write FTotalPrepaidAmount;

    /// <summary>
    /// The amount to be added to the invoice total to round the amount to be paid.
    /// </summary>
    property RoundingAmount: ZUGFeRDNullable<Currency> read FRoundingAmount write FRoundingAmount;

    /// <summary>
    /// The outstanding amount that is requested to be paid.
    ///
    /// This amount is the invoice total amount with VAT minus the paid amount that has
    /// been paid in advance. The amount is zero in case of a fully paid invoice.
    /// The amount may be negative; in that case the seller owes the amount to the buyer.
    /// </summary>
    property DuePayableAmount: ZUGFeRDNullable<Currency> read FDuePayableAmount write FDuePayableAmount;

    /// <summary>
    /// A group of business terms providing information about VAT breakdown by different categories, rates and exemption reasons
    /// </summary>
    property Taxes: TObjectList<TZUGFeRDTax> read FTaxes;

    /// <summary>
    /// Transport and packaging costs
    /// </summary>
    property ServiceCharges: TObjectList<TZUGFeRDServiceCharge> read FServiceCharges;

    /// <summary>
    /// Detailed information on discounts and charges.
    /// This field is marked as private now, please use GetTradeAllowanceCharges() to retrieve all trade allowance charges
    /// </summary>
    property TradeAllowanceCharges: TObjectList<TZUGFeRDTradeAllowanceCharge> read FTradeAllowanceCharges;

    /// <summary>
    /// Detailed information about payment terms
    /// </summary>
    ///
//    property PaymentTerms: TZUGFeRDPaymentTerms read FPaymentTerms write FPaymentTerms;
    property PaymentTermsList: TObjectList<TZUGFeRDPaymentTerms> read FPaymentTermsList;

    /// <summary>
    /// Retrieves all preceding invoice references
    /// </summary>
    /// <returns></returns>
    property InvoiceReferencedDocuments: TObjectList<TZUGFeRDInvoiceReferencedDocument> read FInvoiceReferencedDocuments;

    /// <summary>
    /// Detailed information about the accounting reference
    /// </summary>
    property ReceivableSpecifiedTradeAccountingAccounts: TObjectList<TZUGFeRDReceivableSpecifiedTradeAccountingAccount> read FReceivableSpecifiedTradeAccountingAccounts;

    /// <summary>
    /// Credit Transfer
    ///
    /// A group of business terms to specify credit transfer payments
    /// </summary>
    property CreditorBankAccounts: TObjectList<TZUGFeRDBankAccount> read FCreditorBankAccounts;

    /// <summary>
    /// Buyer bank information
    /// </summary>
    property DebitorBankAccounts: TObjectList<TZUGFeRDBankAccount> read FDebitorBankAccounts;

    /// <summary>
    /// Payment instructions
    ///
    /// /// If various accounts for credit transfers shall be transferred, the element
    /// SpecifiedTradeSettlementPaymentMeans can be repeated for each account. The code
    /// for the type of payment within the element typecode (BT-81) should therefore not
    /// differ within the repetitions.
    /// </summary>
    property PaymentMeans: TZUGFeRDPaymentMeans read FPaymentMeans write FPaymentMeans;

    /// <summary>
    /// Detailed information about the invoicing period, start date
    /// </summary>
    property BillingPeriodStart: ZUGFeRDNullable<TDateTime> read FBillingPeriodStart write FBillingPeriodStart;

    /// <summary>
    /// Detailed information about the invoicing period, end date
    /// </summary>
    property BillingPeriodEnd: ZUGFeRDNullable<TDateTime> read FBillingPeriodEnd write FBillingPeriodEnd;

    /// <summary>
    /// Code for trade delivery terms / Detailangaben zu den Lieferbedingungen, BT-X-22
    /// </summary>
    property ApplicableTradeDeliveryTermsCode: ZUGFeRDNullable<TZUGFeRDTradeDeliveryTermCodes>
      read FApplicableTradeDeliveryTermsCode write FApplicableTradeDeliveryTermsCode;

    /// <summary>
    /// Details about the associated order confirmation (BT-14).
    /// This is optional and can be used in Profiles Comfort and Extended.
    /// If you add a SellerOrderReferencedDocument you must set the property "ID".
    /// The property "IssueDateTime" is optional an only used in profile "Extended"
    /// </summary>
    property SellerOrderReferencedDocument: TZUGFeRDSellerOrderReferencedDocument read FSellerOrderReferencedDocument write FSellerOrderReferencedDocument;

    /// <summary>
    /// The code specifying the mode, such as air, sea, rail, road or inland waterway, for this logistics transport movement.
    /// BG-X-24 --> BT-X-152
    /// </summary>
    property TransportMode: ZUGFeRDNullable<TZUGFeRDTransportModeCodes> read FTransportMode write FTransportMode;

    /// <summary>
    /// Checks if any creditor financial accounts exist
    ///
    /// BG-17
    /// </summary>
    /// <returns>True if creditor financial accounts exist, false otherwise</returns>
    property AnyCreditorFinancialAccount: Boolean read GetAnyCreditorFinancialAccount;

    /// <summary>
    /// Checks if any debitor financial accounts exist
    /// </summary>
    /// <returns>True if debitor financial accounts exist, false otherwise</returns>
    property AnyDebitorFinancialAccount: Boolean read GetAnyDebitorFinancialAcoount;

    /// <summary>
    /// Checks if any trade taxes are defined
    ///
    /// BG-23
    /// </summary>
    /// <returns>True if trade taxes exist, false otherwise</returns>
    property AnyApplicableTradeTaxes: Boolean read GetAnyApplicableTradeTaxes;

  public
    constructor Create;
    destructor Destroy; override;

    /// <summary>
    /// Gets the ZUGFeRD version of a ZUGFeRD invoice that is passed via filename
    /// </summary>
    /// <param name="filename">Stream where to read the ZUGFeRD invoice</param>
    /// <returns>ZUGFeRD version of the invoice that was passed to the function</returns>
    class function GetVersion(const filename: string): TZUGFeRDVersion; overload;

    /// <summary>
    /// Gets the ZUGFeRD version of a ZUGFeRD invoice that is passed via stream
    ///
    /// </summary>
    /// <param name="stream">Stream where to read the ZUGFeRD invoice</param>
    /// <returns>ZUGFeRD version of the invoice that was passed to the function</returns>
    class function GetVersion(const stream: TStream): TZUGFeRDVersion; overload;

    /// <summary>
    /// Loads a ZUGFeRD invoice from a stream.
    ///
    /// Please make sure that the stream is open, otherwise this call will raise an IllegalStreamException.
    ///
    /// Important: the stream will not be closed by this function, make sure to close it by yourself!
    ///
    /// </summary>
    /// <param name="stream">Stream where to read the ZUGFeRD invoice</param>
    /// <returns></returns>
    class function Load(stream: TStream): TZUGFeRDInvoiceDescriptor; overload;

    /// <summary>
    /// Loads a ZUGFeRD invoice from a file.
    ///
    /// Please make sure that the file is exists, otherwise this call will raise a FileNotFoundException.
    /// </summary>
    /// <param name="filename">Name of the ZUGFeRD invoice file</param>
    /// <returns></returns>
    class function Load(filename: String): TZUGFeRDInvoiceDescriptor; overload;

    class function Load(xmldocument : IXMLDocument): TZUGFeRDInvoiceDescriptor; overload;

    /// <summary>
    /// Initializes a new invoice object and returns it.
    /// </summary>
    /// <param name="invoiceNo">Invoice number</param>
    /// <param name="invoiceDate">Invoice date</param>
    /// <param name="currency">Currency</param>
    /// <param name="invoiceNoAsReference">Remittance information</param>
    /// <returns></returns>
    class function CreateInvoice(const invoiceNo: string; invoiceDate: TDateTime;
                               currency: TZUGFeRDCurrencyCodes;
                               const invoiceNoAsReference: string = ''): TZUGFeRDInvoiceDescriptor;

    procedure AddNote(const note: string; subjectCode: TZUGFeRDSubjectCodes = TZUGFeRDSubjectCodes.Unknown; contentCode: TZUGFeRDContentCodes = TZUGFeRDContentCodes.Unknown);

    procedure SetBuyer(const name, postcode, city, street: string; country: TZUGFeRDCountryCodes; const id: string = '';
                     globalID: TZUGFeRDGlobalID = nil; const receiver: string = ''; legalOrganization: TZUGFeRDLegalOrganization = nil);

    procedure SetSeller(const name, postcode, city, street: string; country: TZUGFeRDCountryCodes; const id: string = '';
                     globalID: TZUGFeRDGlobalID = nil; legalOrganization: TZUGFeRDLegalOrganization = nil;
                     description: string = '');

    procedure SetSellerContact(const name: string = ''; const orgunit: string = '';
  const emailAddress: string = ''; const phoneno: string = ''; const faxno: string = '');

    procedure SetBuyerContact(const name: string; const orgunit: string = '';
  const emailAddress: string = ''; const phoneno: string = ''; const faxno: string = '');

    /// <summary>
    /// Sets the SpecifiedProcuringProject
    /// </summary>
    /// <param name="id">ProjectId</param>
    /// <param name="name">ProjectName</param>
    procedure SetSpecifiedProcuringProject(const id, name: string);

    procedure AddBuyerTaxRegistration(const no: string; const schemeID: TZUGFeRDTaxRegistrationSchemeID);

    procedure AddSellerTaxRegistration(const no: string; const schemeID: TZUGFeRDTaxRegistrationSchemeID);

    /// <summary>
    /// Adds a tax registration number for the seller's tax representative.
    ///
    /// BT-11
    /// </summary>
    /// <param name="no">The tax registration number.</param>
    /// <param name="schemeID">The tax registration scheme identifier.</param>
    procedure AddSellerTaxRepresentativeTaxRegistration(const no: string; const schemeID: TZUGFeRDTaxRegistrationSchemeID);

    /// Adds a tax registration number for the ship to trade party.
    ///
    /// BT-X-66-00
    /// </summary>
    /// <param name="no">The tax registration number.</param>
    /// <param name="schemeID">The tax registration scheme identifier.</param>
    procedure   AddShipToTaxRegistration(const no: string; const schemeID: TZUGFeRDTaxRegistrationSchemeID);

    /// <summary>
    /// Adds a tax registration number for the invoicee party.
    /// BT-X-242-00
    /// </summary>
    /// <param name="no">The tax registration number.</param>
    /// <param name="schemeID">The tax registration scheme identifier.</param>
    procedure AddInvoiceeTaxRegistration(const no: string; const schemeID: TZUGFeRDTaxRegistrationSchemeID);

    /// <summary>
    /// Sets the Buyer Electronic Address for Peppol
    /// </summary>
    /// <param name="address">Peppol Address</param>
    /// <param name="electronicAddressSchemeID">ElectronicAddressSchemeIdentifier</param>
    procedure SetBuyerElectronicAddress(address : string; electronicAddressSchemeID : TZUGFeRDElectronicAddressSchemeIdentifiers);

    /// <summary>
    /// Sets the Seller Electronic Address for Peppol
    /// </summary>
    /// <param name="address">Peppol Address</param>
    /// <param name="electronicAddressSchemeID">ElectronicAddressSchemeIdentifier</param>
    procedure SetSellerElectronicAddress(address : string; electronicAddressSchemeID : TZUGFeRDElectronicAddressSchemeIdentifiers);

    /// <summary>
    /// Add an additional reference document
    /// </summary>
    /// <param name="id">Document number such as delivery note no or credit memo no</param>
    /// <param name="typeCode"></param>
    /// <param name="issueDateTime">Document Date</param>
    /// <param name="name"></param>
    /// <param name="referenceTypeCode">Type of the referenced document</param>
    /// <param name="attachmentBinaryObject"></param>
    /// <param name="filename"></param>
    /// <param name="uriID">Optional URI identifier</param>    ///
    procedure AddAdditionalReferencedDocument(const id: string;
      const typeCode: TZUGFeRDAdditionalReferencedDocumentTypeCode;
      const issueDateTime: IZUGFeRDNullableParam<TDateTime> = nil; const name: string = '';
      const referenceTypeCode: IZUGFeRDNullableParam<TZUGFeRDReferenceTypeCodes> = nil;
      const attachmentBinaryObject: TMemoryStream = nil; const filename: string = '';
      const uriID: string = '');

    /// <summary>
    /// Sets details of the associated order
    /// </summary>
    /// <param name="orderNo"></param>
    /// <param name="orderDate"></param>
    procedure SetBuyerOrderReferenceDocument(const orderNo: string; const orderDate: TDateTime = 0);

    /// <summary>
    /// Sets detailed information about the corresponding despatch advice
    /// </summary>
    /// <param name="deliveryNoteNo"></param>
    /// <param name="deliveryNoteDate"></param>
    procedure SetDespatchAdviceReferencedDocument(despatchAdviceNo : String;
      despatchAdviceDate: IZUGFeRDNullableParam<TDateTime> = nil);

    /// <summary>
    /// Sets detailed information about the corresponding delivery note
    /// </summary>
    /// <param name="deliveryNoteNo"></param>
    /// <param name="deliveryNoteDate"></param>
    procedure SetDeliveryNoteReferenceDocument(const deliveryNoteNo: string;
      const deliveryNoteDate: IZUGFeRDNullableParam<TDateTime> = nil);

    /// <summary>
    /// Sets detailed information about the corresponding contract
    /// </summary>
    /// <param name="contractNo">Contract number</param>
    /// <param name="contractDate">Date of the contract</param>
    procedure SetContractReferencedDocument(const contractNo: string;
      const contractDate: IZUGFeRDNullableParam<TDateTime> = nil);

    /// <summary>
    /// The logistics service charge (ram:SpecifiedLogisticsServiceCharge) is part of the ZUGFeRD specification.
    /// Please note that it is not part of the XRechnung specification, thus, everything passed to this function will not
    /// be written when writing XRechnung format.
    ///
    /// You might use AddTradeAllowanceCharge() instead.
    /// </summary>
    procedure AddLogisticsServiceCharge(const amount: Currency; const description: string; const taxTypeCode: TZUGFeRDTaxTypes; const taxCategoryCode: TZUGFeRDTaxCategoryCodes; const taxPercent: Currency);

    /// <summary>
    /// Adds an allowance or charge on document level.
    ///
    /// BG-27
    /// Allowance represents a discount whereas charge represents a surcharge.
    /// </summary>
    /// <param name="isDiscount">True if this is a discount, false if it's a charge</param>
    /// <param name="basisAmount">Base amount for calculation</param>
    /// <param name="currency">Currency code</param>
    /// <param name="actualAmount">Actual amount of allowance/charge</param>
    /// <param name="reason">Reason for allowance/charge</param>
    /// <param name="taxTypeCode">Type of tax</param>
    /// <param name="taxCategoryCode">Tax category</param>
    /// <param name="taxPercent">Tax percentage</param>
    /// <param name="reasonCode">Optional reason code</param>
    procedure AddTradeAllowanceCharge(const isDiscount: Boolean;
             const basisAmount: IZUGFeRDNullableParam<Currency>;
             const currency: TZUGFeRDCurrencyCodes;
             const actualAmount: Currency; const reason: string;
             const taxTypeCode: TZUGFeRDTaxTypes;
             const taxCategoryCode: TZUGFeRDTaxCategoryCodes;
             const taxPercent: Currency;
             const reasonCode: TZUGFeRDAllowanceReasonCodes = TZUGFeRDAllowanceReasonCodes.Unknown); overload;

    /// <summary>
    /// Adds an allowance or charge on document level.
    ///
    /// Allowance represents a discount whereas charge represents a surcharge.
    /// </summary>
    /// <param name="isDiscount">Marks if the allowance charge is a discount. Please note that in contrary to this function, the xml file indicated a surcharge, not a discount (value will be inverted)</param>
    /// <param name="basisAmount">Base amount (basis of allowance)</param>
    /// <param name="currency">Curency of the allowance</param>
    /// <param name="actualAmount">Actual allowance charge amount</param>
    /// <param name="chargePercentage">Actual allowance charge percentage</param>
    /// <param name="reason">Reason for the allowance</param>
    /// <param name="taxTypeCode">VAT type code for document level allowance/ charge</param>
    /// <param name="taxCategoryCode">VAT type code for document level allowance/ charge</param>
    /// <param name="taxPercent">VAT rate for the allowance</param>
    /// <param name="reasonCode">Reason code for the allowance</param>
    procedure AddTradeAllowanceCharge(const isDiscount: Boolean;
             const basisAmount: ZUGFeRDNullableCurrency;
             const currency: TZUGFeRDCurrencyCodes;
             const actualAmount: Currency; const chargePercentage : ZUGFeRDNullableCurrency;
             const reason: string;
             const taxTypeCode: TZUGFeRDTaxTypes;
             const taxCategoryCode: TZUGFeRDTaxCategoryCodes;
             const taxPercent: Currency;
             const reasonCode: TZUGFeRDAllowanceReasonCodes = TZUGFeRDAllowanceReasonCodes.Unknown); overload;

    /// <summary>
    /// Set Information about Preceding Invoice. Please note that all versions prior
    /// ZUGFeRD 2.3 and UBL only allow one of such reference.
    /// </summary>
    /// <param name="id">Preceding InvoiceNo</param>
    /// <param name="IssueDateTime">Preceding Invoice Date</param>
    procedure AddInvoiceReferencedDocument(const id: string; const IssueDateTime: TDateTime = 0);

    /// <summary>
    /// Detailinformationen zu Belegsummen
    /// </summary>
    /// <param name="lineTotalAmount">Gesamtbetrag der Positionen</param>
    /// <param name="chargeTotalAmount">Gesamtbetrag der Zuschläge</param>
    /// <param name="allowanceTotalAmount">Gesamtbetrag der Abschläge</param>
    /// <param name="taxBasisAmount">Basisbetrag der Steuerberechnung</param>
    /// <param name="taxTotalAmount">Steuergesamtbetrag</param>
    /// <param name="grandTotalAmount">Bruttosumme</param>
    /// <param name="totalPrepaidAmount">Anzahlungsbetrag</param>
    /// <param name="duePayableAmount">Zahlbetrag</param>
    /// <param name="roundingAmount">RoundingAmount / Rundungsbetrag, profile COMFORT and EXTENDED</param>
    procedure SetTotals(
      const aLineTotalAmount: IZUGFeRDNullableParam<Currency> = nil;
      const aChargeTotalAmount: IZUGFeRDNullableParam<Currency> = nil;
      const aAllowanceTotalAmount: IZUGFeRDNullableParam<Currency> = nil;
      const aTaxBasisAmount: IZUGFeRDNullableParam<Currency> = nil;
      const aTaxTotalAmount: IZUGFeRDNullableParam<Currency> = nil;
      const aGrandTotalAmount: IZUGFeRDNullableParam<Currency> = nil;
      const aTotalPrepaidAmount: IZUGFeRDNullableParam<Currency> = nil;
      const aDuePayableAmount: IZUGFeRDNullableParam<Currency> = nil;
      const aRoundingAmount: IZUGFeRDNullableParam<Currency> = nil
    );

    /// <summary>
    /// Add information about VAT and apply to the invoice line items for goods and services on the invoice.
    ///
    /// This tax is added per VAT/ tax rate.
    ///
    /// BG-23
    /// </summary>
    /// <param name="basisAmount">Base amount for tax calculation</param>
    /// <param name="percent">Tax percentage rate</param>
    /// <param name="taxAmount">Calculated tax amount</param>
    /// <param name="typeCode">Type of tax</param>
    /// <param name="categoryCode">Tax category</param>
    /// <param name="allowanceChargeBasisAmount">Base amount for allowances/charges</param>
    /// <param name="exemptionReasonCode">Tax exemption reason code</param>
    /// <param name="exemptionReason">Tax exemption reason text</param>
    /// <param name="lineTotalBasisAmount">Line total base amount for tax calculation</param>
    function AddApplicableTradeTax(
      const basisAmount: Currency;
      const percent: Currency;
      const taxAmount: Currency;
      const typeCode: TZUGFeRDTaxTypes;
      const categoryCode: IZUGFeRDNullableParam<TZUGFeRDTaxCategoryCodes> = nil;
      const allowanceChargeBasisAmount: IZUGFeRDNullableParam<Currency> = nil;
      const exemptionReasonCode: IZUGFeRDNullableParam<TZUGFeRDTaxExemptionReasonCodes> = nil;
      const exemptionReason: string = '';
      const lineTotalBasisAmount: IZUGFeRDNullableParam<Currency> = nil): TZUGFeRDTax;

    /// <summary>
    /// Saves the descriptor object into a stream.
    ///
    /// The stream position will be reset to the original position after writing is finished.
    /// This allows easy further processing of the stream.
    /// </summary>
    /// <param name="stream">The stream where the data should be saved to.</param>
    /// <param name="version">The ZUGFeRD version you want to use. Defaults to version 1.</param>
    /// <param name="profile">The ZUGFeRD profile you want to use. Defaults to Basic.</param>
    /// <param name="format">The format of the target file that may be CII or UBL</param>
    procedure Save(const stream: TStream; const version: TZUGFeRDVersion = TZUGFeRDVersion.Version1;
      const profile: TZUGFeRDProfile = TZUGFeRDProfile.Basic; const format: TZUGFeRDFormats = TZUGFeRDFormats.CII); overload;

    /// <summary>
    /// Saves the descriptor object into a file with given name.
    /// </summary>
    /// <param name="filename">The filename where the data should be saved to.</param>
    /// <param name="version">The ZUGFeRD version you want to use. Defaults to version 1.</param>
    /// <param name="profile">The ZUGFeRD profile you want to use. Defaults to Basic.</param>
    /// <param name="format">The format of the target file that may be CII or UBL</param>
    procedure Save(const filename: string; const version: TZUGFeRDVersion = TZUGFeRDVersion.Version1;
      const profile: TZUGFeRDProfile = TZUGFeRDProfile.Basic; const format: TZUGFeRDFormats = TZUGFeRDFormats.CII); overload;

    /// <summary>
    /// Adds a new comment as a dedicated line of the invoice.
    ///
    /// The line id is generated automatically
    /// </summary>
    /// <param name="comment"></param>
    procedure AddTradeLineCommentItem(const comment: string); overload;

    /// <summary>
    /// Adds a new comment as a dedicated line of the invoice.
    ///
    /// The line id is passed as a parameter
    /// </summary>
    /// <param name="lineID"></param>
    /// <param name="comment"></param>
    procedure AddTradeLineCommentItem(const lineID: string; const comment: string); overload;

    /// <summary>
    /// Adds a new line to the invoice. The line id is generated automatically.
    ///
    /// Please note that this function returns the new trade line item object that you might use
    /// in your code to add more detailed information to the trade line item.
    /// </summary>
    /// <param name="name"></param>
    /// <param name="description"></param>
    /// <param name="unitCode"></param>
    /// <param name="unitQuantity"></param>
    /// <param name="grossUnitPrice"></param>
    /// <param name="netUnitPrice"></param>
    /// <param name="billedQuantity"></param>
    /// <param name="lineTotalAmount">net total including discounts and surcharges. This parameter is optional. If it is not filled, the line total amount is automatically calculated based on netUnitPrice and billedQuantity</param>
    /// <param name="taxType"></param>
    /// <param name="categoryCode"></param>
    /// <param name="taxPercent"></param>
    /// <param name="comment"></param>
    /// <param name="id"></param>
    /// <param name="sellerAssignedID"></param>
    /// <param name="buyerAssignedID"></param>
    /// <param name="deliveryNoteID"></param>
    /// <param name="deliveryNoteDate"></param>
    /// <param name="buyerOrderLineID">Buyer's order line reference</param>
    /// <param name="buyerOrderID"></param>
    /// <param name="buyerOrderDate"></param>
    /// <param name="billingPeriodStart"></param>
    /// <param name="billingPeriodEnd"></param>
    /// <returns>Returns the instance of the trade line item. You might use this object to add details such as trade allowance charges</returns>
    /// <returns></returns>
    function AddTradeLineItem(const name: string; const description: string;
                  const unitCode: TZUGFeRDQuantityCodes = TZUGFeRDQuantityCodes.Unknown; const unitQuantity: IZUGFeRDNullableParam<Double> = nil;
                  const grossUnitPrice: IZUGFeRDNullableParam<Double> = nil; const netUnitPrice: IZUGFeRDNullableParam<Double> = nil; const billedQuantity: Double = 0; const lineTotalAmount : Currency = 0;
                  const taxType: TZUGFeRDTaxTypes = TZUGFeRDTaxTypes.Unknown; const categoryCode: TZUGFeRDTaxCategoryCodes = TZUGFeRDTaxCategoryCodes.Unknown; const taxPercent: Double = 0;
                  const comment: string = ''; const id: TZUGFeRDGlobalID = nil; const sellerAssignedID: string = '';
                  const buyerAssignedID: string = ''; const deliveryNoteID: string = ''; const deliveryNoteDate: IZUGFeRDNullableParam<TDateTime> = nil;
                  const buyerOrderLineID: string = ''; const buyerOrderID: string = ''; const buyerOrderDate: IZUGFeRDNullableParam<TDateTime> = nil; const billingPeriodStart: IZUGFeRDNullableParam<TDateTime> = nil;
                  const billingPeriodEnd: IZUGFeRDNullableParam<TDateTime> = nil): TZUGFeRDTradeLineItem; overload;


    /// <summary>
    /// Adds a new line to the invoice. The line id is passed as a parameter.
    /// </summary>
    function AddTradeLineItem(const lineID: string; const name: string; const description: string;
                  const unitCode: TZUGFeRDQuantityCodes = TZUGFeRDQuantityCodes.Unknown; const unitQuantity: IZUGFeRDNullableParam<Double> = nil;
                  const grossUnitPrice: IZUGFeRDNullableParam<Double> = nil; const netUnitPrice: IZUGFeRDNullableParam<Double> = nil; const billedQuantity: Double = 0; const lineTotalAmount : Currency = 0;
                  const taxType: TZUGFeRDTaxTypes = TZUGFeRDTaxTypes.Unknown; const categoryCode: TZUGFeRDTaxCategoryCodes = TZUGFeRDTaxCategoryCodes.Unknown; const taxPercent: Double = 0;
                  const comment: string = ''; const id: TZUGFeRDGlobalID = nil; const sellerAssignedID: string = ''; const buyerAssignedID: string = '';
                  const deliveryNoteID: string = ''; const deliveryNoteDate: IZUGFeRDNullableParam<TDateTime> = nil; const buyerOrderLineID: string = '';
                  const buyerOrderID: string = ''; const buyerOrderDate: IZUGFeRDNullableParam<TDateTime> = nil; const billingPeriodStart: IZUGFeRDNullableParam<TDateTime> = nil;
                  const billingPeriodEnd: IZUGFeRDNullableParam<TDateTime> = nil): TZUGFeRDTradeLineItem; overload;

    procedure SetPaymentMeans(paymentCode: TZUGFeRDPaymentMeansTypeCodes; const information: string = '';
                  const identifikationsnummer: string = ''; const mandatsnummer: string = '');

    /// <summary>
    ///     Sets up the payment means for SEPA direct debit.
    /// </summary>
    procedure SetPaymentMeansSepaDirectDebit(const sepaCreditorIdentifier: string;
      const sepaMandateReference: string; const information: string = '');

    /// <summary>
    ///     Sets up the payment means for payment via financial card.
    /// </summary>
    procedure SetPaymentMeansFinancialCard(const financialCardId: string;
      const financialCardCardholder: string; const information: string = '');

    /// <summary>
    /// Adds a group of business terms to specify credit transfer payments
    /// </summary>
    /// <param name="iban">IBAN</param>
    /// <param name="bic">BIC</param>
    /// <param name="id">Optional: old German bank account no</param>
    /// <param name="bankleitzahl">Optional: old German Bankleitzahl</param>
    /// <param name="bankName">Optional: old German bank name</param>
    /// <param name="name">Optional: bank account name</param>
    procedure AddCreditorFinancialAccount(const iban: string; const bic: string; const id: string = '';
      const bankleitzahl: string = ''; const bankName: string = ''; const name: string = '');


    procedure AddDebitorFinancialAccount(const iban: string; const bic: string; const id: string = '';
      const bankleitzahl: string = ''; const bankName: string = '');

    procedure AddReceivableSpecifiedTradeAccountingAccount(const AccountID: string); overload;

    procedure AddReceivableSpecifiedTradeAccountingAccount(const AccountID: string;
      const AccountTypeCode: TZUGFeRDAccountingAccountTypeCodes); overload;

    /// <summary>
    /// Clears the current trade payment terms and sets the initial payment terms
    /// </summary>
    /// <param name="description"></param>
    /// <param name="dueDate"></param>
    procedure SetTradePaymentTerms(const description: string; dueDate: IZUGFeRDNullableParam<TDateTime> = nil); deprecated;

    /// <summary>
    /// Adds payment terms to the invoice
    ///
    /// BT-20
    /// </summary>
    /// <param name="description">Description of payment terms</param>
    /// <param name="dueDate">Due date for payment</param>
    /// <param name="paymentTermsType">Type of payment terms</param>
    /// <param name="dueDays">Number of days until payment is due</param>
    /// <param name="percentage">Optional percentage</param>
    /// <param name="baseAmount">Optional base amount</param>
    /// <param name="actualAmount">Optional actual amount</param>
    /// <param name="maturityDate"></param>
    procedure AddTradePaymentTerms(
      const description: string;
      dueDate: IZUGFeRDNullableParam<TDateTime> = nil;
      paymentTermsType: IZUGFeRDNullableParam<TZUGFeRDPaymentTermsType> = nil;
      dueDays: IZUGFeRDNullableParam<Integer> = nil;
      percentage: IZUGFeRDNullableParam<Currency> = nil;
      baseAmount: IZUGFeRDNullableParam<Currency> = nil;
      actualAmount: IZUGFeRDNullableParam<Currency> = nil;
      maturityDate: IZUGFerDNullableParam<TDateTime> = nil
      );
  private
    function _getNextLineId: string;
  end;

implementation

uses
  intf.ZUGFeRDInvoiceDescriptorReader,intf.ZUGFeRDInvoiceDescriptorWriter,
  intf.ZUGFeRDInvoiceDescriptor1Reader,intf.ZUGFeRDInvoiceDescriptor1Writer,
  intf.ZUGFeRDInvoiceDescriptor20Reader,intf.ZUGFeRDInvoiceDescriptor20Writer,
  intf.ZUGFeRDInvoiceDescriptor23CIIReader,intf.ZUGFeRDInvoiceDescriptor23Writer,
  intf.ZUGFeRDInvoiceDescriptor22UblReader
  ;

{ TZUGFeRDInvoiceDescriptor }

constructor TZUGFeRDInvoiceDescriptor.Create;
begin
  FAdditionalReferencedDocuments := TObjectList<TZUGFeRDAdditionalReferencedDocument>.Create;
  FDespatchAdviceReferencedDocument := nil;
  FDeliveryNoteReferencedDocument:= nil;//TZUGFeRDDeliveryNoteReferencedDocument.Create;
  FContractReferencedDocument    := nil;//TZUGFeRDContractReferencedDocument.Create;
  FSpecifiedProcuringProject     := nil;//TZUGFeRDSpecifiedProcuringProject.Create;
  FBuyer                         := nil;//TZUGFeRDParty.Create;
  FBuyerContact                  := nil;//TZUGFeRDContact.Create;
  FBuyerTaxRegistration          := TObjectList<TZUGFeRDTaxRegistration>.Create;
  FShipToTaxRegistration         := TObjectList<TZUGFeRDTaxRegistration>.Create;
  FBuyerElectronicAddress        := TZUGFeRDElectronicAddress.Create;
  FSeller                        := nil;//TZUGFeRDParty.Create;
  FSellerContact                 := nil;//TZUGFeRDContact.Create;
  FSellerTaxRegistration         := TObjectList<TZUGFeRDTaxRegistration>.Create;
  FInvoiceeTaxRegistration       := TObjectList<TZUGFeRDTaxRegistration>.Create;
  FSellerTaxRepresentativeTaxRegistration := TObjectList<TZUGFeRDTaxRegistration>.Create;
  FSellerElectronicAddress       := TZUGFeRDElectronicAddress.Create;
  FInvoicer                      := nil;
  FInvoicee                      := nil;//TZUGFeRDParty.Create;
  FShipTo                        := nil;//TZUGFeRDParty.Create;
  FPayee                         := nil;//TZUGFeRDParty.Create;
  FShipFrom                      := nil;//TZUGFeRDParty.Create;
  FNotes                         := TObjectList<TZUGFeRDNote>.Create;
  FTradeLineItems                := TObjectList<TZUGFeRDTradeLineItem>.Create;
  FTaxes                         := TObjectList<TZUGFeRDTax>.Create;
  FServiceCharges                := TObjectList<TZUGFeRDServiceCharge>.Create;
  FTradeAllowanceCharges         := TObjectList<TZUGFeRDTradeAllowanceCharge>.Create;
  FPaymentTermsList              := TObjectList<TZUGFeRDPaymentTerms>.Create;
  FInvoiceReferencedDocuments     := TObjectList<TZUGFeRDInvoiceReferencedDocument>.Create;
  FReceivableSpecifiedTradeAccountingAccounts:= TObjectList<TZUGFeRDReceivableSpecifiedTradeAccountingAccount>.Create;
  FCreditorBankAccounts          := TObjectList<TZUGFeRDBankAccount>.Create;
  FDebitorBankAccounts           := TObjectList<TZUGFeRDBankAccount>.Create;
  FPaymentMeans                  := nil;//TZUGFeRDPaymentMeans.Create;
  FSellerOrderReferencedDocument := nil;//TZUGFeRDSellerOrderReferencedDocument.Create;
  FSellerTaxRepresentative       := nil;

  //Default values:
  FProfile := TZUGFeRDProfile.Unknown;
  FType := TZUGFeRDInvoiceType.Invoice;
  FSellerReferenceNo := '';
  FTaxCurrency := nil;
end;

destructor TZUGFeRDInvoiceDescriptor.Destroy;
begin
  if Assigned(FAdditionalReferencedDocuments ) then begin FAdditionalReferencedDocuments.Free; FAdditionalReferencedDocuments  := nil; end;
  if Assigned(FDespatchAdviceReferencedDocument) then begin FDespatchAdviceReferencedDocument.Free; FDespatchAdviceReferencedDocument := nil; end;
  if Assigned(FDeliveryNoteReferencedDocument) then begin FDeliveryNoteReferencedDocument.Free; FDeliveryNoteReferencedDocument := nil; end;
  if Assigned(FContractReferencedDocument    ) then begin FContractReferencedDocument.Free; FContractReferencedDocument     := nil; end;
  if Assigned(FSpecifiedProcuringProject     ) then begin FSpecifiedProcuringProject.Free; FSpecifiedProcuringProject      := nil; end;
  if Assigned(FBuyer                         ) then begin FBuyer.Free; FBuyer                          := nil; end;
  if Assigned(FBuyerContact                  ) then begin FBuyerContact.Free; FBuyerContact                   := nil; end;
  if Assigned(FBuyerTaxRegistration          ) then begin FBuyerTaxRegistration.Free; FBuyerTaxRegistration           := nil; end;
  if Assigned(FShipToTaxRegistration         ) then begin FShipToTaxRegistration.Free; FShipToTaxRegistration           := nil; end;
  if Assigned(FBuyerElectronicAddress        ) then begin FBuyerElectronicAddress        .Free; FBuyerElectronicAddress         := nil; end;
  if Assigned(FSeller                        ) then begin FSeller.Free; FSeller                         := nil; end;
  if Assigned(FInvoicer                      ) then begin FInvoicer.Free; FInvoicer                     := nil; end;
  if Assigned(FSellerContact                 ) then begin FSellerContact.Free; FSellerContact                  := nil; end;
  if Assigned(FSellerTaxRegistration         ) then begin FSellerTaxRegistration.Free; FSellerTaxRegistration          := nil; end;
  if Assigned(FInvoiceeTaxRegistration       ) then begin FInvoiceeTaxRegistration.Free; FInvoiceeTaxRegistration          := nil; end;
  if Assigned(FSellerTaxRepresentativeTaxRegistration) then begin FSellerTaxRepresentativeTaxRegistration.Free; FSellerTaxRepresentativeTaxRegistration:= nil; end;
  if Assigned(FSellerElectronicAddress       ) then begin FSellerElectronicAddress       .Free; FSellerElectronicAddress        := nil; end;
  if Assigned(FInvoicee                      ) then begin FInvoicee.Free; FInvoicee                       := nil; end;
  if Assigned(FShipTo                        ) then begin FShipTo.Free; FShipTo                         := nil; end;
  if Assigned(FUltimateShipTo                ) then begin FUltimateShipTo.Free; FUltimateShipTo         := nil; end;
  if Assigned(FUltimateShipToContact         ) then begin FUltimateShipToContact.Free; FUltimateShipToContact  := nil; end;
  if Assigned(FShipToContact                 ) then begin FShipToContact.Free; FShipToContact  := nil; end;
  if Assigned(FPayee                         ) then begin FPayee.Free; FPayee                          := nil; end;
  if Assigned(FShipFrom                      ) then begin FShipFrom.Free; FShipFrom                       := nil; end;
  if Assigned(FNotes                         ) then begin FNotes.Free; FNotes                          := nil; end;
  if Assigned(FTradeLineItems                ) then begin FTradeLineItems.Free; FTradeLineItems                 := nil; end;
  if Assigned(FTaxes                         ) then begin FTaxes.Free; FTaxes                          := nil; end;
  if Assigned(FServiceCharges                ) then begin FServiceCharges.Free; FServiceCharges                 := nil; end;
  if Assigned(FTradeAllowanceCharges         ) then begin FTradeAllowanceCharges.Free; FTradeAllowanceCharges          := nil; end;
  if Assigned(FPaymentTermsList              ) then begin FPaymentTermsList.Free; FPaymentTermsList                   := nil; end;
  if Assigned(FInvoiceReferencedDocuments    ) then begin FInvoiceReferencedDocuments.Free; FInvoiceReferencedDocuments      := nil; end;
  if Assigned(FReceivableSpecifiedTradeAccountingAccounts) then begin FReceivableSpecifiedTradeAccountingAccounts.Free; FReceivableSpecifiedTradeAccountingAccounts := nil; end;
  if Assigned(FCreditorBankAccounts         ) then begin FCreditorBankAccounts.Free; FCreditorBankAccounts          := nil; end;
  if Assigned(FDebitorBankAccounts          ) then begin FDebitorBankAccounts.Free; FDebitorBankAccounts           := nil; end;
  if Assigned(FPaymentMeans                 ) then begin FPaymentMeans.Free; FPaymentMeans                  := nil; end;
  if Assigned(FSellerOrderReferencedDocument) then begin FSellerOrderReferencedDocument.Free; FSellerOrderReferencedDocument := nil; end;
  if Assigned(FSellerTaxRepresentative      ) then begin FSellerTaxRepresentative.Free; FSellerTaxRepresentative := nil; end;
  inherited;
end;

class function TZUGFeRDInvoiceDescriptor.GetVersion(const filename: string): TZUGFeRDVersion;
var
  reader: TZUGFeRDInvoiceDescriptorReader;
begin
  reader := TZUGFeRDInvoiceDescriptor1Reader.Create;
  try
    if reader.IsReadableByThisReaderVersion(filename) then
    begin
      Result := TZUGFeRDVersion.Version1;
      Exit;
    end;
  finally
    reader.Free;
  end;

  reader := TZUGFeRDInvoiceDescriptor22UBLReader.Create;
  try
    if reader.IsReadableByThisReaderVersion(filename) then
    begin
      Result := TZUGFeRDVersion.Version23;
      Exit;
    end;
  finally
    reader.Free;
  end;

  reader := TZUGFeRDInvoiceDescriptor23CIIReader.Create;
  try
    if reader.IsReadableByThisReaderVersion(filename) then
    begin
      Result := TZUGFeRDVersion.Version23;
      Exit;
    end;
  finally
    reader.Free;
  end;

  reader := TZUGFeRDInvoiceDescriptor20Reader.Create;
  try
    if reader.IsReadableByThisReaderVersion(filename) then
    begin
      Result := TZUGFeRDVersion.Version20;
      Exit;
    end;
  finally
    reader.Free;
  end;

  raise TZUGFeRDUnsupportedException.Create('No ZUGFeRD invoice reader was able to parse this file "' + filename + '"!');
end;

function TZUGFeRDInvoiceDescriptor.GetAnyApplicableTradeTaxes: Boolean;
begin
  result := assigned(FTaxes) and (FTaxes.Count > 0);
end;

function TZUGFeRDInvoiceDescriptor.GetAnyCreditorFinancialAccount: Boolean;
begin
  result := assigned(FCreditorBankAccounts) and (FCreditorBankAccounts.Count > 0);
end;

function TZUGFeRDInvoiceDescriptor.GetAnyDebitorFinancialAcoount: Boolean;
begin
  result := assigned(FDebitorBankAccounts) and (FDebitorBankAccounts.Count > 0);
end;

class function TZUGFeRDInvoiceDescriptor.GetVersion(
  const stream: TStream): TZUGFeRDVersion;
var
  reader: TZUGFeRDInvoiceDescriptorReader;
begin
  reader := TZUGFeRDInvoiceDescriptor1Reader.Create;
  try
    if reader.IsReadableByThisReaderVersion(stream) then
    begin
      Result := TZUGFeRDVersion.Version1;
      Exit;
    end;
  finally
    reader.Free;
  end;

  reader := TZUGFeRDInvoiceDescriptor22UBLReader.Create;
  try
    if reader.IsReadableByThisReaderVersion(stream) then
    begin
      Result := TZUGFeRDVersion.Version23;
      Exit;
    end;
  finally
    reader.Free;
  end;

  reader := TZUGFeRDInvoiceDescriptor23CIIReader.Create;
  try
    if reader.IsReadableByThisReaderVersion(stream) then
    begin
      Result := TZUGFeRDVersion.Version23;
      Exit;
    end;
  finally
    reader.Free;
  end;

  reader := TZUGFeRDInvoiceDescriptor20Reader.Create;
  try
    if reader.IsReadableByThisReaderVersion(stream) then
    begin
      Result := TZUGFeRDVersion.Version20;
      Exit;
    end;
  finally
    reader.Free;
  end;

  raise TZUGFeRDUnsupportedException.Create('No ZUGFeRD invoice reader was able to parse this stream!');
end;

class function TZUGFeRDInvoiceDescriptor.Load(stream: TStream): TZUGFeRDInvoiceDescriptor;
var
  reader: TZUGFeRDInvoiceDescriptorReader;
begin
  reader := TZUGFeRDInvoiceDescriptor1Reader.Create;
  try
    if reader.IsReadableByThisReaderVersion(stream) then
    begin
      Result := reader.Load(stream);
      exit;
    end;
  finally
    reader.Free;
  end;

  reader := TZUGFeRDInvoiceDescriptor22UBLReader.Create;
  try
    if reader.IsReadableByThisReaderVersion(stream) then
    begin
      Result := reader.Load(stream);
      exit;
    end;
  finally
    reader.Free;
  end;

  reader := TZUGFeRDInvoiceDescriptor23CIIReader.Create;
  try
    if reader.IsReadableByThisReaderVersion(stream) then
    begin
      Result := reader.Load(stream);
      exit;
    end;
  finally
    reader.Free;
  end;

  reader := TZUGFeRDInvoiceDescriptor20Reader.Create;
  try
    if reader.IsReadableByThisReaderVersion(stream) then
    begin
      Result := reader.Load(stream);
      exit;
    end;
  finally
    reader.Free;
  end;

  raise TZUGFeRDUnsupportedException.Create('No ZUGFeRD invoice reader was able to parse this stream!');
end;

class function TZUGFeRDInvoiceDescriptor.Load(filename: string): TZUGFeRDInvoiceDescriptor;
var
  reader: TZUGFeRDInvoiceDescriptorReader;
begin
  reader := TZUGFeRDInvoiceDescriptor1Reader.Create;
  try
    if reader.IsReadableByThisReaderVersion(filename) then
    begin
      Result := reader.Load(filename);
      exit;
    end;
  finally
    reader.Free;
  end;

  reader := TZUGFeRDInvoiceDescriptor22UBLReader.Create;
  try
    if reader.IsReadableByThisReaderVersion(filename) then
    begin
      Result := reader.Load(filename);
      exit;
    end;
  finally
    reader.Free;
  end;

  reader := TZUGFeRDInvoiceDescriptor23CIIReader.Create;
  try
    if reader.IsReadableByThisReaderVersion(filename) then
    begin
      Result := reader.Load(filename);
      exit;
    end;
  finally
    reader.Free;
  end;

  reader := TZUGFeRDInvoiceDescriptor20Reader.Create;
  try
    if reader.IsReadableByThisReaderVersion(filename) then
    begin
      Result := reader.Load(filename);
      exit;
    end;
  finally
    reader.Free;
  end;

  raise TZUGFeRDUnsupportedException.CreateFmt('No ZUGFeRD invoice reader was able to parse this file ''%s''!', [filename]);
end;

class function TZUGFeRDInvoiceDescriptor.Load(xmldocument : IXMLDocument): TZUGFeRDInvoiceDescriptor;
var
  reader: TZUGFeRDInvoiceDescriptorReader;
begin
  reader := TZUGFeRDInvoiceDescriptor1Reader.Create;
  try
    if reader.IsReadableByThisReaderVersion(xmldocument) then
    begin
      Result := reader.Load(xmldocument);
      exit;
    end;
  finally
    reader.Free;
  end;

  reader := TZUGFeRDInvoiceDescriptor22UBLReader.Create;
  try
    if reader.IsReadableByThisReaderVersion(xmldocument) then
    begin
      Result := reader.Load(xmldocument);
      exit;
    end;
  finally
    reader.Free;
  end;

  reader := TZUGFeRDInvoiceDescriptor23CIIReader.Create;
  try
    if reader.IsReadableByThisReaderVersion(xmldocument) then
    begin
      Result := reader.Load(xmldocument);
      exit;
    end;
  finally
    reader.Free;
  end;

  reader := TZUGFeRDInvoiceDescriptor20Reader.Create;
  try
    if reader.IsReadableByThisReaderVersion(xmldocument) then
    begin
      Result := reader.Load(xmldocument);
      exit;
    end;
  finally
    reader.Free;
  end;

  raise TZUGFeRDUnsupportedException.Create('No ZUGFeRD invoice reader was able to parse this xml document');
end;

class function TZUGFeRDInvoiceDescriptor.CreateInvoice(const invoiceNo: string; invoiceDate: TDateTime;
  currency: TZUGFeRDCurrencyCodes; const invoiceNoAsReference: string = ''): TZUGFeRDInvoiceDescriptor;
begin
  Result := TZUGFeRDInvoiceDescriptor.Create;
  Result.InvoiceDate := invoiceDate;
  Result.InvoiceNo := invoiceNo;
  Result.Currency := currency;
  Result.PaymentReference := invoiceNoAsReference;
end;

procedure TZUGFeRDInvoiceDescriptor.AddNote(const note: string;
  subjectCode: TZUGFeRDSubjectCodes = TZUGFeRDSubjectCodes.Unknown;
  contentCode: TZUGFeRDContentCodes = TZUGFeRDContentCodes.Unknown);
begin
  //TODO prüfen:
  //ST1, ST2, ST3 nur mit AAK
  //EEV, WEB, VEV nur mit AAJ

  FNotes.Add(TZUGFeRDNote.Create(note, subjectCode, contentCode));
end;

procedure TZUGFeRDInvoiceDescriptor.SetBuyer(const name, postcode, city, street: string;
  country: TZUGFeRDCountryCodes; const id: string = '';
  globalID: TZUGFeRDGlobalID = nil; const receiver: string = '';
  legalOrganization: TZUGFeRDLegalOrganization = nil);
begin
  if Assigned(FBuyer) then
    FBuyer.Free;
  FBuyer := TZUGFeRDParty.Create;

  FBuyer.ID.ID := id;
  FBuyer.ID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiers.Unknown;
  FBuyer.Name := name;
  FBuyer.Postcode := postcode;
  FBuyer.ContactName := receiver;
  FBuyer.City := city;
  FBuyer.Street := street;
  FBuyer.Country := country;
  FBuyer.GlobalID := globalID;
  FBuyer.SpecifiedLegalOrganization := legalOrganization;
end;

procedure TZUGFeRDInvoiceDescriptor.SetSeller(const name, postcode, city, street: string;
  country: TZUGFeRDCountryCodes; const id: string = '';
  globalID: TZUGFeRDGlobalID = nil;
  legalOrganization: TZUGFeRDLegalOrganization = nil;
  description: string = '');
begin
  if Assigned(FSeller) then
    FSeller.Free;
  FSeller := TZUGFeRDParty.Create;
  FSeller.ID.ID := id;
  FSeller.ID.SchemeID := TZUGFeRDGlobalIDSchemeIdentifiers.Unknown;
  FSeller.Name := name;
  FSeller.Postcode := postcode;
  FSeller.City := city;
  FSeller.Street := street;
  FSeller.Country := country;
  FSeller.GlobalID := globalID;
  FSeller.SpecifiedLegalOrganization := legalOrganization;
  FSeller.Description := description;
end;

procedure TZUGFeRDInvoiceDescriptor.SetSellerContact(const name: string = ''; const orgunit: string = '';
  const emailAddress: string = ''; const phoneno: string = ''; const faxno: string = '');
begin
  if Assigned(FSellerContact) then
    FSellerContact.Free;
  FSellerContact := TZUGFeRDContact.Create;

  FSellerContact.Name := name;
  FSellerContact.OrgUnit := orgunit;
  FSellerContact.EmailAddress := emailAddress;
  FSellerContact.PhoneNo := phoneno;
  FSellerContact.FaxNo := faxno;
end;

procedure TZUGFeRDInvoiceDescriptor.SetBuyerContact(const name: string; const orgunit: string = '';
  const emailAddress: string = ''; const phoneno: string = ''; const faxno: string = '');
begin
  if Assigned(FBuyerContact) then
    FBuyerContact.Free;
  FBuyerContact := TZUGFeRDContact.Create;

  FBuyerContact.Name := name;
  FBuyerContact.OrgUnit := orgunit;
  FBuyerContact.EmailAddress := emailAddress;
  FBuyerContact.PhoneNo := phoneno;
  FBuyerContact.FaxNo := faxno;
end;

procedure TZUGFeRDInvoiceDescriptor.SetSpecifiedProcuringProject(const id, name: string);
begin
  if Assigned(FSpecifiedProcuringProject) then
    FSpecifiedProcuringProject.Free;
  FSpecifiedProcuringProject := TZUGFeRDSpecifiedProcuringProject.Create;
  FSpecifiedProcuringProject.ID := id;
  FSpecifiedProcuringProject.Name := name;
end;

procedure TZUGFeRDInvoiceDescriptor.AddBuyerTaxRegistration(const no: string; const schemeID: TZUGFeRDTaxRegistrationSchemeID);
begin
  FBuyerTaxRegistration.Add(TZUGFeRDTaxRegistration.Create);
  FBuyerTaxRegistration[BuyerTaxRegistration.Count - 1].No := no;
  FBuyerTaxRegistration[BuyerTaxRegistration.Count - 1].SchemeID := schemeID;
end;

procedure TZUGFeRDInvoiceDescriptor.AddSellerTaxRegistration(const no: string; const schemeID: TZUGFeRDTaxRegistrationSchemeID);
begin
  FSellerTaxRegistration.Add(TZUGFeRDTaxRegistration.Create);
  FSellerTaxRegistration[SellerTaxRegistration.Count - 1].No := no;
  FSellerTaxRegistration[SellerTaxRegistration.Count - 1].SchemeID := schemeID;
end;

procedure TZUGFeRDInvoiceDescriptor.AddSellerTaxRepresentativeTaxRegistration(const no: string;
  const schemeID: TZUGFeRDTaxRegistrationSchemeID);
begin
  FSellerTaxRepresentativeTaxRegistration.Add(TZUGFeRDTaxRegistration.Create);
  FSellerTaxRepresentativeTaxRegistration[SellerTaxRepresentativeTaxRegistration.Count - 1].No := no;
  FSellerTaxRepresentativeTaxRegistration[SellerTaxRepresentativeTaxRegistration.Count - 1].SchemeID := schemeID;
end;

procedure TZUGFeRDInvoiceDescriptor.AddShipToTaxRegistration(const no: string;
  const schemeID: TZUGFeRDTaxRegistrationSchemeID);
begin
  FShipToTaxRegistration.Add(TZUGFeRDTaxRegistration.create);
  FShipToTaxRegistration[FShipToTaxRegistration.Count - 1].No := no;
  FShipToTaxRegistration[FShipToTaxRegistration.Count - 1].SchemeID := schemeID;
end;

procedure TZUGFeRDInvoiceDescriptor.SetBuyerElectronicAddress(address : string; electronicAddressSchemeID : TZUGFeRDElectronicAddressSchemeIdentifiers);
begin
  FBuyerElectronicAddress.Address := address;
  FBuyerElectronicAddress.ElectronicAddressSchemeID := electronicAddressSchemeID;
end;

procedure TZUGFeRDInvoiceDescriptor.SetSellerElectronicAddress(address : string; electronicAddressSchemeID : TZUGFeRDElectronicAddressSchemeIdentifiers);
begin
  FSellerElectronicAddress.Address := address;
  FSellerElectronicAddress.ElectronicAddressSchemeID := electronicAddressSchemeID;
end;

procedure TZUGFeRDInvoiceDescriptor.SetSellerParty(const Value: TZUGFeRDParty);
begin
  if assigned(FSeller) then
    FSeller.Free;
  FSeller := Value;
end;

procedure TZUGFeRDInvoiceDescriptor.SetSellerTaxRepresentative(const Value: TZUGFeRDParty);
begin
  if assigned(FSellerTaxRepresentative) then
    FSellerTaxRepresentative.Free;
  FSellerTaxRepresentative := Value;
end;

procedure TZUGFeRDInvoiceDescriptor.SetShipTo(const Value: TZUGFeRDParty);
begin
  if assigned(FShipTo) then
    FShipTo.Free;
  FShipTo := Value;
end;

procedure TZUGFeRDInvoiceDescriptor.SetShipToContact(const Value: TZUGFeRDContact);
begin
  if assigned(FShipToContact) then
    FShipToContact.Free;
  FShipToContact := Value;
end;

procedure TZUGFeRDInvoiceDescriptor.AddAdditionalReferencedDocument(const id: string;
  const typeCode: TZUGFeRDAdditionalReferencedDocumentTypeCode;
  const issueDateTime: IZUGFeRDNullableParam<TDateTime>; const name: string;
  const referenceTypeCode: IZUGFeRDNullableParam<TZUGFeRDReferenceTypeCodes>;
  const attachmentBinaryObject: TMemoryStream; const filename, uriID: string);
begin
  FAdditionalReferencedDocuments.Add(TZUGFeRDAdditionalReferencedDocument.Create(false));
  FAdditionalReferencedDocuments[AdditionalReferencedDocuments.Count - 1].ID := id;
  FAdditionalReferencedDocuments[AdditionalReferencedDocuments.Count - 1].TypeCode := typeCode;
  FAdditionalReferencedDocuments[AdditionalReferencedDocuments.Count - 1].IssueDateTime:= issueDateTime;
  FAdditionalReferencedDocuments[AdditionalReferencedDocuments.Count - 1].Name := name;
  FAdditionalReferencedDocuments[AdditionalReferencedDocuments.Count - 1].ReferenceTypeCode := referenceTypeCode;
  FAdditionalReferencedDocuments[AdditionalReferencedDocuments.Count - 1].AttachmentBinaryObject := attachmentBinaryObject;
  FAdditionalReferencedDocuments[AdditionalReferencedDocuments.Count - 1].Filename := filename;
  FAdditionalReferencedDocuments[AdditionalReferencedDocuments.Count - 1].URIID := uriID;
end;

procedure TZUGFeRDInvoiceDescriptor.SetBuyerOrderReferenceDocument(const orderNo: string; const orderDate: TDateTime = 0);
begin
  FOrderNo := orderNo;
  if orderDate < 100 then
    FOrderDate:= Nil
  else
    FOrderDate:= orderDate;
end;

procedure TZUGFeRDInvoiceDescriptor.SetBuyerParty(const Value: TZUGFeRDParty);
begin
  if assigned(FBuyer) then
    FBuyer.Free;
  FBuyer := Value;
end;

procedure TZUGFeRDInvoiceDescriptor.SetDeliveryNoteReferenceDocument(const deliveryNoteNo: string;
  const deliveryNoteDate: IZUGFeRDNullableParam<TDateTime>);
begin
  if Assigned(FDeliveryNoteReferencedDocument) then
    FDeliveryNoteReferencedDocument.Free;
  FDeliveryNoteReferencedDocument := TZUGFeRDDeliveryNoteReferencedDocument.Create;

  FDeliveryNoteReferencedDocument.ID := deliveryNoteNo;
  FDeliveryNoteReferencedDocument.IssueDateTime:= deliveryNoteDate;
end;

procedure TZUGFeRDInvoiceDescriptor.SetDespatchAdviceReferencedDocument(
  despatchAdviceNo: String; despatchAdviceDate: IZUGFeRDNullableParam<TDateTime>);
begin
  if Assigned(FDespatchAdviceReferencedDocument) then
    FDespatchAdviceReferencedDocument.Free;
  FDespatchAdviceReferencedDocument := TZUGFeRDDespatchAdviceReferencedDocument.Create;

  FDespatchAdviceReferencedDocument.ID := despatchAdviceNo;
  FDespatchAdviceReferencedDocument.IssueDateTime:= despatchAdviceDate;
end;

procedure TZUGFeRDInvoiceDescriptor.SetContractReferencedDocument(const contractNo: string;
  const contractDate: IZUGFeRDNullableParam<TDateTime>);
begin
  if Assigned(FContractReferencedDocument) then
    FContractReferencedDocument.Free;
  FContractReferencedDocument := TZUGFeRDContractReferencedDocument.Create;

  FContractReferencedDocument.ID := contractNo; //TODO memeak
  FContractReferencedDocument.IssueDateTime:= contractDate;
end;

procedure TZUGFeRDInvoiceDescriptor.AddLogisticsServiceCharge(const amount: Currency; const description: string; const taxTypeCode: TZUGFeRDTaxTypes; const taxCategoryCode: TZUGFeRDTaxCategoryCodes; const taxPercent: Currency);
var
  serviceCharge: TZUGFeRDServiceCharge;
begin
  serviceCharge := TZUGFeRDServiceCharge.Create;
  serviceCharge.Description := description;
  serviceCharge.Amount := amount;
  serviceCharge.Tax.CategoryCode := taxCategoryCode;
  serviceCharge.Tax.TypeCode := taxTypeCode;
  serviceCharge.Tax.Percent := taxPercent;
  FServiceCharges.Add(serviceCharge);
end;

procedure TZUGFeRDInvoiceDescriptor.AddTradeAllowanceCharge(const isDiscount: Boolean;
             const basisAmount: IZUGFeRDNullableParam<Currency>;
             const currency: TZUGFeRDCurrencyCodes;
             const actualAmount: Currency; const reason: string;
             const taxTypeCode: TZUGFeRDTaxTypes;
             const taxCategoryCode: TZUGFeRDTaxCategoryCodes;
             const taxPercent: Currency;
             const reasonCode: TZUGFeRDAllowanceReasonCodes);
var
  tradeAllowanceCharge: TZUGFeRDTradeAllowanceCharge;
begin
  tradeAllowanceCharge := TZUGFeRDTradeAllowanceCharge.Create;
  tradeAllowanceCharge.ChargeIndicator := not isDiscount;
  tradeAllowanceCharge.Reason := reason;
  tradeAllowanceCharge.ReasonCode := reasonCode;
  tradeAllowanceCharge.BasisAmount := basisAmount;
  tradeAllowanceCharge.ActualAmount := actualAmount;
  tradeAllowanceCharge.Currency := currency;
  tradeAllowanceCharge.Amount := actualAmount;
  tradeAllowanceCharge.ChargePercentage := nil;
  tradeAllowanceCharge.Tax.CategoryCode := taxCategoryCode;
  tradeAllowanceCharge.Tax.TypeCode := taxTypeCode;
  tradeAllowanceCharge.Tax.Percent := taxPercent;
  FTradeAllowanceCharges.Add(tradeAllowanceCharge);
end;

procedure TZUGFeRDInvoiceDescriptor.AddTradeAllowanceCharge(const isDiscount: Boolean;
             const basisAmount: ZUGFeRDNullableCurrency; const currency: TZUGFeRDCurrencyCodes;
             const actualAmount: Currency; const chargePercentage : ZUGFeRDNullableCurrency;
             const reason: string;
             const taxTypeCode: TZUGFeRDTaxTypes;
             const taxCategoryCode: TZUGFeRDTaxCategoryCodes;
             const taxPercent: Currency;
             const reasonCode: TZUGFeRDAllowanceReasonCodes);
var
  tradeAllowanceCharge: TZUGFeRDTradeAllowanceCharge;
begin
  tradeAllowanceCharge := TZUGFeRDTradeAllowanceCharge.Create;
  tradeAllowanceCharge.ChargeIndicator := not isDiscount;
  tradeAllowanceCharge.Reason := reason;
  tradeAllowanceCharge.ReasonCode := reasonCode;
  tradeAllowanceCharge.BasisAmount := basisAmount;
  tradeAllowanceCharge.ActualAmount := actualAmount;
  tradeAllowanceCharge.Currency := currency;
  tradeAllowanceCharge.Amount := actualAmount;
  tradeAllowanceCharge.ChargePercentage := chargePercentage;
  tradeAllowanceCharge.Tax.CategoryCode := taxCategoryCode;
  tradeAllowanceCharge.Tax.TypeCode := taxTypeCode;
  tradeAllowanceCharge.Tax.Percent := taxPercent;
  FTradeAllowanceCharges.Add(tradeAllowanceCharge);
end;

procedure TZUGFeRDInvoiceDescriptor.SetInvoiceeParty(const Value: TZUGFeRDParty);
begin
  if assigned(FInvoicee) then
    FInvoicee.Free;
  FInvoicee := Value;
end;

procedure TZUGFeRDInvoiceDescriptor.AddInvoiceeTaxRegistration(const no: string;
  const schemeID: TZUGFeRDTaxRegistrationSchemeID);
begin
  FInvoiceeTaxRegistration.Add(TZUGFeRDTaxRegistration.create);
  FInvoiceeTaxRegistration[FInvoiceeTaxRegistration.Count - 1].No := no;
  FInvoiceeTaxRegistration[FInvoiceeTaxRegistration.Count - 1].SchemeID := schemeID;
end;

procedure TZUGFeRDInvoiceDescriptor.AddInvoiceReferencedDocument(const id: string; const IssueDateTime: TDateTime = 0);
begin
  FInvoiceReferencedDocuments.Add(TZUGFeRDInvoiceReferencedDocument.CreateWithParams(id, IssueDateTime));
end;

procedure TZUGFeRDInvoiceDescriptor.SetInvoicerParty(const Value: TZUGFeRDParty);
begin
  if assigned(FInvoicer) then
    FInvoicer.Free;
  FInvoicer := Value;
end;

procedure TZUGFeRDInvoiceDescriptor.SetTotals(const aLineTotalAmount, aChargeTotalAmount,
      aAllowanceTotalAmount, aTaxBasisAmount, aTaxTotalAmount, aGrandTotalAmount,
      aTotalPrepaidAmount, aDuePayableAmount, aRoundingAmount: IZUGFeRDNullableParam<Currency>);
begin
  LineTotalAmount:= aLineTotalAmount;
  ChargeTotalAmount:= aChargeTotalAmount;
  AllowanceTotalAmount:= aAllowanceTotalAmount;
  TaxBasisAmount:= aTaxBasisAmount;
  TaxTotalAmount:= aTaxTotalAmount;
  GrandTotalAmount:= aGrandTotalAmount;
  TotalPrepaidAmount:= aTotalPrepaidAmount;
  DuePayableAmount:= aDuePayableAmount;
  RoundingAmount:= aRoundingAmount;
end;

procedure TZUGFeRDInvoiceDescriptor.SetTradePaymentTerms(const description: string;
  dueDate: IZUGFeRDNullableParam<TDateTime>);
begin
  FPaymentTermsList.Clear();
  AddTradePaymentTerms(description, dueDate);
end;

procedure TZUGFeRDInvoiceDescriptor.SetUltimateShipTo(const Value: TZUGFeRDParty);
begin
  if assigned(FUltimateShipTo) then
    FUltimateShipTo.Free;
  FUltimateShipTo := Value;
end;

procedure TZUGFeRDInvoiceDescriptor.SetUltimateShipToContact(const Value: TZUGFeRDContact);
begin
  if assigned(FUltimateShipToContact) then
    FUltimateShipToContact.Free;
  FUltimateShipToContact := Value;
end;

function TZUGFeRDInvoiceDescriptor.AddApplicableTradeTax(
      const basisAmount: Currency;
      const percent: Currency;
      const taxAmount: Currency;
      const typeCode: TZUGFeRDTaxTypes;
      const categoryCode: IZUGFeRDNullableParam<TZUGFeRDTaxCategoryCodes>;
      const allowanceChargeBasisAmount: IZUGFeRDNullableParam<Currency>;
      const exemptionReasonCode: IZUGFeRDNullableParam<TZUGFeRDTaxExemptionReasonCodes>;
      const exemptionReason: string;
      const lineTotalBasisAmount: IZUGFeRDNullableParam<Currency>): TZUGFeRDTax;
var
  tax: TZUGFeRDTax;
begin
  tax := TZUGFeRDTax.Create;
  tax.BasisAmount := basisAmount;
  tax.TaxAmount := taxAmount;
  tax.Percent := percent;
  tax.TypeCode := typeCode;
  tax.AllowanceChargeBasisAmount := allowanceChargeBasisAmount;
  tax.ExemptionReasonCode := exemptionReasonCode;
  tax.ExemptionReason := exemptionReason;
  tax.LineTotalBasisAmount := lineTotalBasisAmount;

  if (categoryCode <> nil) and (categoryCode.Value <> TZUGFeRDTaxCategoryCodes.Unknown) then
    tax.CategoryCode := categoryCode;

  Taxes.Add(tax);
  result := tax;
end;

procedure TZUGFeRDInvoiceDescriptor.Save(const stream: TStream;
  const version: TZUGFeRDVersion = TZUGFeRDVersion.Version1;
  const profile: TZUGFeRDProfile = TZUGFeRDProfile.Basic;
  const format: TZUGFeRDFormats = TZUGFeRDFormats.CII);
var
  writer: TZUGFeRDInvoiceDescriptorWriter;
begin
  self.Profile := profile;

  case version of
    TZUGFeRDVersion.Version1:
      writer := TZUGFeRDInvoiceDescriptor1Writer.Create;
    TZUGFeRDVersion.Version20:
      writer := TZUGFeRDInvoiceDescriptor20Writer.Create;
    TZUGFeRDVersion.Version23:
      writer := TZUGFeRDInvoiceDescriptor23Writer.Create;
    else
      raise TZUGFeRDUnsupportedException.Create('New ZUGFeRDVersion defined but not implemented!');
  end;
  try
    writer.Save(Self, stream, format);
  finally
    writer.Free;
  end;
end;

procedure TZUGFeRDInvoiceDescriptor.Save(const filename: string; const version: TZUGFeRDVersion = TZUGFeRDVersion.Version1;
  const profile: TZUGFeRDProfile = TZUGFeRDProfile.Basic; const format: TZUGFeRDFormats = TZUGFeRDFormats.CII);
var
  writer: TZUGFeRDInvoiceDescriptorWriter;
begin
  self.Profile := profile;

  case version of
    TZUGFeRDVersion.Version1:
      writer := TZUGFeRDInvoiceDescriptor1Writer.Create;
    TZUGFeRDVersion.Version20:
      writer := TZUGFeRDInvoiceDescriptor20Writer.Create;
    TZUGFeRDVersion.Version23:
      writer := TZUGFeRDInvoiceDescriptor23Writer.Create;
    else
      raise TZUGFeRDUnsupportedException.Create('New ZUGFeRDVersion defined but not implemented!');
  end;
  try
    writer.Save(Self, filename, format);
  finally
    writer.Free;
  end;
end;

procedure TZUGFeRDInvoiceDescriptor.AddTradeLineCommentItem(const comment: string);
begin
  AddTradeLineCommentItem(_getNextLineId(), comment);
end;

procedure TZUGFeRDInvoiceDescriptor.AddTradeLineCommentItem(const lineID: string; const comment: string);
var
  item: TZUGFeRDTradeLineItem;
begin
  if (lineID.IsEmpty) then
    raise TZUGFeRDArgumentException.Create('LineID cannot be Null or Empty')
  else
  begin
    for var i : Integer := 0 to TradeLineItems.Count-1 do
    if (TradeLineItems[i].AssociatedDocument <> nil) then
    if SameText(TradeLineItems[i].AssociatedDocument.LineID,lineID) then
      raise TZUGFeRDArgumentException.Create('LineID must be unique');
  end;

  item := TZUGFeRDTradeLineItem.Create(lineID);
  item.GrossUnitPrice:= 0;
  item.NetUnitPrice:= 0;
  item.BilledQuantity := 0;
  item.UnitCode := TZUGFeRDQuantityCodes.C62;
  item.TaxCategoryCode := TZUGFeRDTaxCategoryCodes.O;

  item.AssociatedDocument.Notes.Add(
    TZUGFeRDNote.Create(comment,
                        TZUGFeRDSubjectCodes.Unknown,
                        TZUGFeRDContentCodes.Unknown
    )
  );

  TradeLineItems.Add(item);
end;

function TZUGFeRDInvoiceDescriptor.AddTradeLineItem(const name: string;
  const description: string;
  const unitCode: TZUGFeRDQuantityCodes = TZUGFeRDQuantityCodes.Unknown;
  const unitQuantity: IZUGFeRDNullableParam<Double> = nil;
  const grossUnitPrice: IZUGFeRDNullableParam<Double> = nil;
  const netUnitPrice: IZUGFeRDNullableParam<Double> = nil;
  const billedQuantity: Double = 0;
  const lineTotalAmount: Currency = 0;
  const taxType: TZUGFeRDTaxTypes = TZUGFeRDTaxTypes.Unknown;
  const categoryCode: TZUGFeRDTaxCategoryCodes = TZUGFeRDTaxCategoryCodes.Unknown;
  const taxPercent: Double = 0;
  const comment: string = '';
  const id: TZUGFeRDGlobalID = nil;
  const sellerAssignedID: string = '';
  const buyerAssignedID: string = '';
  const deliveryNoteID: string = '';
  const deliveryNoteDate: IZUGFeRDNullableParam<TDateTime> = nil;
  const buyerOrderLineID: string = '';
  const buyerOrderID: string = '';
  const buyerOrderDate: IZUGFeRDNullableParam<TDateTime> = nil;
  const billingPeriodStart: IZUGFeRDNullableParam<TDateTime> = nil;
  const billingPeriodEnd: IZUGFeRDNullableParam<TDateTime> = nil): TZUGFeRDTradeLineItem;
begin
  Result := AddTradeLineItem(_getNextLineId(), name, description, unitCode,
    unitQuantity, grossUnitPrice, netUnitPrice, billedQuantity, lineTotalAmount,
    taxType, categoryCode, taxPercent, comment, id, sellerAssignedID,
    buyerAssignedID, deliveryNoteID, deliveryNoteDate, buyerOrderLineID, buyerOrderID,
    buyerOrderDate, billingPeriodStart, billingPeriodEnd);
end;

function TZUGFeRDInvoiceDescriptor.AddTradeLineItem(const lineID: string;
  const name: string; const description: string;
  const unitCode: TZUGFeRDQuantityCodes = TZUGFeRDQuantityCodes.Unknown;
  const unitQuantity: IZUGFeRDNullableParam<Double> = nil;
  const grossUnitPrice: IZUGFeRDNullableParam<Double> = nil;
  const netUnitPrice: IZUGFeRDNullableParam<Double> = nil;
  const billedQuantity: Double = 0;
  const lineTotalAmount: Currency = 0;
  const taxType: TZUGFeRDTaxTypes = TZUGFeRDTaxTypes.Unknown;
  const categoryCode: TZUGFeRDTaxCategoryCodes = TZUGFeRDTaxCategoryCodes.Unknown;
  const taxPercent: Double = 0;
  const comment: string = '';
  const id: TZUGFeRDGlobalID = nil;
  const sellerAssignedID: string = '';
  const buyerAssignedID: string = '';
  const deliveryNoteID: string = '';
  const deliveryNoteDate: IZUGFeRDNullableParam<TDateTime> = nil;
  const buyerOrderLineID: string = '';
  const buyerOrderID: string = '';
  const buyerOrderDate: IZUGFeRDNullableParam<TDateTime> = nil;
  const billingPeriodStart: IZUGFeRDNullableParam<TDateTime> = nil;
  const billingPeriodEnd: IZUGFeRDNullableParam<TDateTime> = nil): TZUGFeRDTradeLineItem;
var
  newItem: TZUGFeRDTradeLineItem;
begin
  if (lineID.IsEmpty) then
    raise TZUGFeRDArgumentException.Create('LineID cannot be Null or Empty')
  else
  begin
    for var i : Integer := 0 to TradeLineItems.Count-1 do
    if (TradeLineItems[i].AssociatedDocument <> nil) then
    if SameText(TradeLineItems[i].AssociatedDocument.LineID,lineID) then
      raise TZUGFeRDArgumentException.Create('LineID must be unique');
  end;

  newItem := TZUGFeRDTradeLineItem.Create(lineID);
  newItem.GlobalID.Free; newItem.GlobalID := id;
  newItem.SellerAssignedID := sellerAssignedID;
  newItem.BuyerAssignedID := buyerAssignedID;
  newItem.Name := name;
  newItem.Description := description;
  newItem.UnitCode := unitCode;
  newItem.UnitQuantity := unitQuantity;
  newItem.GrossUnitPrice := grossUnitPrice;
  newItem.NetUnitPrice := netUnitPrice;
  newItem.BilledQuantity := billedQuantity;
  if lineTotalAmount <> 0.0 then
    newItem.LineTotalAmount:= LineTotalAmount;

  newItem.TaxType := taxType;
  newItem.TaxCategoryCode := categoryCode;
  newItem.TaxPercent := taxPercent;
  newItem.BillingPeriodStart:= billingPeriodStart;
  newItem.BillingPeriodEnd:= billingPeriodEnd;
  if (not comment.IsEmpty) then
  newItem.AssociatedDocument.Notes.Add(
    TZUGFeRDNote.Create(comment,
                        TZUGFeRDSubjectCodes.Unknown,
                        TZUGFeRDContentCodes.Unknown
    )
  );
  if (not deliveryNoteID.IsEmpty) or (deliveryNoteDate <> Nil) then
    newItem.SetDeliveryNoteReferencedDocument(deliveryNoteID,deliveryNoteDate);

  if (not String.IsNullOrWhiteSpace(buyerOrderLineID) or (buyerOrderDate <> nil)  or  not String.IsNullOrWhiteSpace(buyerOrderID)) then
    newItem.SetOrderReferencedDocument(buyerOrderID, buyerOrderDate, buyerOrderLineID);

  TradeLineItems.Add(newItem);

  Result := newItem;
end;

procedure TZUGFeRDInvoiceDescriptor.AddTradePaymentTerms(const description: string;
  dueDate: IZUGFeRDNullableParam<TDateTime>;
  paymentTermsType: IZUGFeRDNullableParam<TZUGFeRDPaymentTermsType>;
  dueDays: IZUGFeRDNullableParam<Integer>; percentage, baseAmount: IZUGFeRDNullableParam<Currency>;
  actualAmount: IZUGFeRDNullableParam<Currency>; maturityDate: IZUGFerDNullableParam<TDateTime>);
begin
  var PaymentTerms := TZUGFeRDPaymentTerms.Create;
  PaymentTerms.Description := description;
  PaymentTerms.DueDate := dueDate;
  PaymentTerms.PaymentTermsType := paymentTermsType;
  PaymentTerms.DueDays := dueDays;
  PaymentTerms.Percentage := percentage;
  PaymentTerms.BaseAmount := baseAmount;
  PaymentTerms.ActualAmount := actualAmount;
  PaymentTerms.MaturityDate := maturityDate;
  FPaymentTermsList.Add(PaymentTerms);
end;

procedure TZUGFeRDInvoiceDescriptor.SetPaymentMeans(paymentCode: TZUGFeRDPaymentMeansTypeCodes;
  const information: string = '';
  const identifikationsnummer: string = ''; const mandatsnummer: string = '');
begin
  if Self.PaymentMeans = nil then Self.PaymentMeans := TZUGFeRDPaymentMeans.Create;

  Self.PaymentMeans.TypeCode := paymentCode;
  Self.PaymentMeans.Information := information;
  Self.PaymentMeans.SEPACreditorIdentifier := identifikationsnummer;
  Self.PaymentMeans.SEPAMandateReference := mandatsnummer;
end;

procedure TZUGFeRDInvoiceDescriptor.SetPaymentMeansSepaDirectDebit(const sepaCreditorIdentifier: string;
      const sepaMandateReference: string; const information: string = '');
begin
  if Self.PaymentMeans = nil then Self.PaymentMeans := TZUGFeRDPaymentMeans.Create;

  Self.PaymentMeans.TypeCode := TZUGFeRDPaymentMeansTypeCodes.SEPADirectDebit;
  Self.PaymentMeans.Information := information;
  Self.PaymentMeans.SEPACreditorIdentifier := sepaCreditorIdentifier;
  Self.PaymentMeans.SEPAMandateReference := sepaMandateReference;
end;

procedure TZUGFeRDInvoiceDescriptor.SetPaymentMeansFinancialCard(const financialCardId: string;
  const financialCardCardholder: string; const information: string = '');
begin
  if Self.PaymentMeans = nil then Self.PaymentMeans := TZUGFeRDPaymentMeans.Create;

  PaymentMeans.TypeCode := TZUGFeRDPaymentMeansTypeCodes.SEPADirectDebit;
  PaymentMeans.Information := information;
  PaymentMeans.FinancialCard.Id := financialCardId;
  PaymentMeans.FinancialCard.CardholderName := financialCardCardholder;
end;

procedure TZUGFeRDInvoiceDescriptor.AddCreditorFinancialAccount(const iban: string; const bic: string; const id: string = '';
  const bankleitzahl: string = ''; const bankName: string = ''; const name: string = '');
var
  newItem : TZUGFeRDBankAccount;
begin
  newItem := TZUGFeRDBankAccount.Create;
  newItem.ID := id;
  newItem.IBAN := iban;
  newItem.BIC := bic;
  newItem.Bankleitzahl := bankleitzahl;
  newItem.BankName := bankName;
  newItem.Name := name;
  CreditorBankAccounts.Add(newItem);
end;

procedure TZUGFeRDInvoiceDescriptor.AddDebitorFinancialAccount(const iban: string; const bic: string; const id: string = '';
  const bankleitzahl: string = ''; const bankName: string = '');
var
  newItem : TZUGFeRDBankAccount;
begin
  newItem := TZUGFeRDBankAccount.Create;
  newItem.ID := id;
  newItem.IBAN := iban;
  newItem.BIC := bic;
  newItem.Bankleitzahl := bankleitzahl;
  newItem.BankName := bankName;
  DebitorBankAccounts.Add(newItem);
end;

procedure TZUGFeRDInvoiceDescriptor.AddReceivableSpecifiedTradeAccountingAccount(const AccountID: string);
begin
  AddReceivableSpecifiedTradeAccountingAccount(AccountID, TZUGFeRDAccountingAccountTypeCodes.Unknown);
end;

procedure TZUGFeRDInvoiceDescriptor.AddReceivableSpecifiedTradeAccountingAccount(const AccountID: string;
  const AccountTypeCode: TZUGFeRDAccountingAccountTypeCodes);
var
  newItem : TZUGFeRDReceivableSpecifiedTradeAccountingAccount;
begin
  newItem := TZUGFeRDReceivableSpecifiedTradeAccountingAccount.Create;
  newItem.TradeAccountID := AccountID;
  newItem.TradeAccountTypeCode := AccountTypeCode;

  ReceivableSpecifiedTradeAccountingAccounts.Add(newItem);
end;

function TZUGFeRDInvoiceDescriptor._getNextLineId: string;
var
  highestLineId,i: Integer;
begin
  highestLineId := 0;

  for i := 0 to TradeLineItems.Count-1 do
  if TradeLineItems[i].AssociatedDocument <> nil then
  begin
    if StrToIntDef(TradeLineItems[i].AssociatedDocument.LineID,0) > highestLineId then
      highestLineId := StrToIntDef(TradeLineItems[i].AssociatedDocument.LineID,0);
  end;

  Result := (highestLineId + 1).ToString;
end;

end.
