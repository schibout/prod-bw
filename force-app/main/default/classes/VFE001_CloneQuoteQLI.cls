public class VFE001_CloneQuoteQLI{

    private Quote currentQuote {get;set;}
 
    public ID newQuoteId {get;set;} 
    public VFE001_CloneQuoteQLI(ApexPages.StandardController controller) {
  
   this.currentQuote = (Quote) controller.getRecord();
    } 
    public PageReference cloneQuoteWithQLI() {
 
         Savepoint sp = Database.setSavepoint();
         Quote newQuote;
         string StatusBloque = label.Erreur_ClonageDevis;
         try { 
             currentQuote = [ Select Id, Name , DEV_Devis_Original__c,OpportunityId, Pricebook2Id, ContactId, QuoteNumber, IsSyncing, ShippingHandling, Tax, Status, ExpirationDate, Description, Subtotal, TotalPrice, LineItemCount, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingStateCode, BillingCountryCode, BillingLatitude, BillingLongitude, BillingGeocodeAccuracy, BillingAddress, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, ShippingStateCode, ShippingCountryCode, ShippingLatitude, ShippingLongitude, ShippingGeocodeAccuracy, ShippingAddress, QuoteToStreet, QuoteToCity, QuoteToState, QuoteToPostalCode, QuoteToCountry, QuoteToStateCode, QuoteToCountryCode, QuoteToLatitude, QuoteToLongitude, QuoteToGeocodeAccuracy, QuoteToAddress, AdditionalStreet, AdditionalCity, AdditionalState, AdditionalPostalCode, AdditionalCountry, AdditionalStateCode, AdditionalCountryCode, AdditionalLatitude, AdditionalLongitude, AdditionalGeocodeAccuracy, AdditionalAddress, BillingName, ShippingName, QuoteToName, AdditionalName, Email, Phone, Fax, ContractId, AccountId, Discount, GrandTotal, CanCreateQuoteLineItems, Tech_Talend_Export_Devis__c, DEV_RemiseClient__c, DEV_DelaiDePaiement__c, OPP_Origine__c, DEV_DatePrevisionnelleMAD__c, DEV_DatePrevisionnelleDeTravaux__c, DEV_Type__c, DEV_DateDeRelance__c, Tech_TalendHistorique__c, DEV_ContactSuppleant__c, DEV_MotifDeRefus__c, DEV_NumCommandeClient__c, DEV_NumVersionGPIC__c, DEV_DateDeCreation__c, DEV_DateDeValidation__c, DEV_Montant__c, DEV_TypeDeDevis__c , DEV_NombreLignesDeDevis__c, TECH_DEV_NumCommandeLiee__c, Tech_AccountID__c, Nature__c, PrixTTC__c, Montant_TVA__c, Pourcentage_TVA__c, DEV_CommentaireDeRefus__c, DEV_RedacteurDeLOffre__c, DEV_Charg_daffaire__c, Attachment_Required__c, DEVDate_de_creation__c, DEV_Address_Compte_Livre__c, DEV_Ajout_Piece_Jointe__c, DEV_Code_Client__c, DEV_Compte_livre__c, DEV_Date_de_cr_ation__c, DEV_DelaisLivraison__c, DEV_DescrDelaisLivraison__c, DEV_INCOTERMS__c, DEV_Langue_doc_du_compte__c, DEV_Prix_total__c, DEV_Salutation_Contact__c, DEV_Societe__c, DEV_Tel_Propri_taire__c, DEV_Termes_Expedition__c, D_lai_de_Livraison__c, Language__c,  Tech_produitPrincipal__c, DEV_EntiteBW__c, DEV_Audit_Accepted_by__c, DEV_Audit_Accepted_date__c from Quote where id = :currentQuote.id];
             newQuote= currentQuote.clone(false,true,true,true);
             newQuote.name=currentQuote.name;
             newQuote.OpportunityId=currentQuote.OpportunityId;
             newQuote.DEV_Devis_Original__c=currentQuote.id;
             newQuote.Status=Label.Dev_Status_Cree;
             if(StatusBloque.contains(currentQuote.status)) 
             {
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,System.Label.VFE001_Clone_DevisAccepter));
            return null;
                 }
             else 
             {
                 insert newQuote;
             }
             // set the id of the new po created for testing
               newQuoteId = newQuote.id;
                  
             // copy over the line items - ONLY INCLUDE THE FIELDS YOU WANT TO CLONE
           List<QuoteLineItem> ListQLI= new List<QuoteLineItem>();
             for (QuoteLineItem QLI : [Select Id, LineNumber , QuoteId, PricebookEntryId, OpportunityLineItemId, Quantity, UnitPrice, Discount, Description, ServiceDate, Product2Id, SortOrder, ListPrice, Subtotal, TotalPrice, RemisePiece__c, ELD_Tech_Commande__c, PRD_ERPIdESP__c, PRD_ERPIdFRA__c, PRD_ERPIdGBR__c, PRD_ERPIdITA__c, PRD_ERPIdNLD__c, PRD_ERPIdPOL__c, PRD_ERPIdPRT__c, PRD_ERPIdUSA__c, ELD_Unite__c, ELD_Conditionnement__c, Main_d_oeuvre__c, DEV_Description__c,   ELD_Traduction__c, EntiteBW__c, SerieProduit__c  from QuoteLineItem where QuoteId = :currentQuote.id]) {
                  QuoteLineItem newQLI = QLI.clone(false, true, true, true);
                newQLI.QuoteId = newQuote.id; 
               
                  ListQLI.add(newQLI);
             }
             
             insert ListQLI;

         } catch (Exception e){ 
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
         }

        return new PageReference('/'+newQuote.id);
    }

}