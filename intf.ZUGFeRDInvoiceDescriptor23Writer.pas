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

unit intf.ZUGFeRDInvoiceDescriptor23Writer;

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
  ,intf.ZUGFeRDTradeLineItem
  ,intf.ZUGFeRDTaxTypes
(*  ,intf.ZUGFeRDCurrencyCodes
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

  ,intf.ZUGFeRDTaxCategoryCodes

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
*)
  ,intf.ZUGFeRDFormats
  ,intf.ZUGFeRDInvoiceDescriptor23CIIWriter
  ,intf.ZUGFeRDInvoiceDescriptor22UBLWriter
  ;

type
  TZUGFeRDInvoiceDescriptor23Writer = class(TZUGFeRDInvoiceDescriptorWriter)
  private const
    ALL_PROFILES = [TZUGFeRDProfile.Minimum,
                    TZUGFeRDProfile.BasicWL,
                    TZUGFeRDProfile.Basic,
                    TZUGFeRDProfile.Comfort,
                    TZUGFeRDProfile.Extended,
                    TZUGFeRDProfile.XRechnung1,
                    TZUGFeRDProfile.XRechnung];
  public
    function Validate(_descriptor: TZUGFeRDInvoiceDescriptor; _throwExceptions: Boolean = True): Boolean; override;
    /// <summary>
    /// Saves the given invoice to the given stream.
    /// Make sure that the stream is open and writeable. Otherwise, an IllegalStreamException will be thron.
    /// </summary>
    /// <param name="_descriptor">The invoice object that should be saved</param>
    /// <param name="_stream">The target stream for saving the invoice</param>
    /// <param name="_format">Format of the target file</param>
    procedure Save(_descriptor: TZUGFeRDInvoiceDescriptor; _stream: TStream;
      _format: TZUGFeRDFormats = TZUGFeRDFormats.CII); override;
  end;

implementation

{ TZUGFeRDInvoiceDescriptor23Writer }

procedure TZUGFeRDInvoiceDescriptor23Writer.Save(
  _descriptor: TZUGFeRDInvoiceDescriptor; _stream: TStream; _format: TZUGFeRDFormats = TZUGFeRDFormats.CII);
var
  Writer: TZUGFeRDInvoiceDescriptorWriter;
begin
  case _format of
    TZUGFeRDFormats.UBL: Writer := TZUGFeRDInvoiceDescriptor22UBLWriter.create;
  else
    Writer := TZUGFeRDInvoiceDescriptor23CIIWriter.Create;
  end;
  try
    Writer.Save(_descriptor, _stream, _format);
  finally
    Writer.Free;
  end;
end;

function TZUGFeRDInvoiceDescriptor23Writer.Validate(
  _descriptor: TZUGFeRDInvoiceDescriptor; _throwExceptions: Boolean): Boolean;
begin
  Result := false;

  if (_descriptor.Profile = TZUGFeRDProfile.BasicWL) then
  begin
    if (_throwExceptions) then
      raise TZUGFeRDUnsupportedException.Create('Invalid TZUGFeRDProfile used for ZUGFeRD 2.0 invoice.')
    else
      exit;
  end;

  if (_descriptor.Profile <> TZUGFeRDProfile.Extended) then // check tax types, only extended TZUGFeRDProfile allows tax types other than vat
  begin
    for var l : TZUGFeRDTradeLineItem in _descriptor.TradeLineItems do
    if not ((l.TaxType = TZUGFeRDTaxTypes.Unknown) or
      (l.TaxType = TZUGFeRDTaxTypes.VAT)) then
    begin
      if (_throwExceptions) then
        raise TZUGFeRDUnsupportedException.Create('Tax types other than VAT only possible with extended TZUGFeRDProfile.')
      else
        exit;
    end;
  end;

  if (_descriptor.Profile in [TZUGFeRDProfile.XRechnung,TZUGFeRDProfile.XRechnung1]) then
  begin
    if (_descriptor.Seller <> nil) then
    begin
      if (_descriptor.SellerContact = nil) then
      begin
          if (_throwExceptions) then
            raise TZUGFeRDMissingDataException.Create('Seller contact (BG-6) required when seller is set (BR-DE-2).')
          else
            exit;
      end
      else
      begin
          if (_descriptor.SellerContact.EmailAddress = '') then
          begin
            if (_throwExceptions) then
              raise TZUGFeRDMissingDataException.Create('Seller contact email address (BT-43) is required (BR-DE-7).')
            else
              exit;
          end;
          if (_descriptor.SellerContact.PhoneNo = '') then
          begin
            if (_throwExceptions) then
                raise TZUGFeRDMissingDataException.Create('Seller contact phone no (BT-42) is required (BR-DE-6).')
            else
              exit;
          end;
          if (_descriptor.SellerContact.Name = '') and
             (_descriptor.SellerContact.OrgUnit = '') then
          begin
            if (_throwExceptions) then
              raise TZUGFeRDMissingDataException.Create('Seller contact point (name or org unit) no (BT-41) is required (BR-DE-5).')
            else
              exit;
          end;
      end;
    end;
  end;

  // BR-DE-17
  if not ((_descriptor.Type_ = TZUGFeRDInvoiceType.PartialInvoice) or
          (_descriptor.Type_ = TZUGFeRDInvoiceType.Invoice) or
          (_descriptor.Type_ = TZUGFeRDInvoiceType.Correction) or
          (_descriptor.Type_ = TZUGFeRDInvoiceType.SelfBilledInvoice) or
          (_descriptor.Type_ = TZUGFeRDInvoiceType.CreditNote) or
          (_descriptor.Type_ = TZUGFeRDInvoiceType.PartialConstructionInvoice) or
          (_descriptor.Type_ = TZUGFeRDInvoiceType.PartialFinalConstructionInvoice) or
          (_descriptor.Type_ = TZUGFeRDInvoiceType.FinalConstructionInvoice)) then
  begin
    if (_throwExceptions) then
      raise TZUGFeRDUnsupportedException.Create('Invoice type (BT-3) does not match requirements of BR-DE-17')
    else
      exit;
  end;

  Result := true;
end;

end.
