trigger QuoteAfterUpdate on Quote (after update) {
    
    List<Quote> lstQuote = new List<Quote>();
    
    for(Quote devis : Trigger.new){
        if(devis.DEV_EntiteBW__c==Label.BW_ITA && devis.DEV_Ajout_Piece_Jointe__c == true && devis.DEV_Ajout_Piece_Jointe__c != trigger.oldMap.get(devis.Id).DEV_Ajout_Piece_Jointe__c && devis.DEV_Langue_doc_du_compte__c != null ){
            lstQuote.add(devis);
        }
    }
    
    if(lstQuote.size()> 0){
        AP01_Quote.CreateFichier(lstQuote);
    }

    AP01_Quote.updateDateLivraisonOppt(Trigger.new, trigger.oldMap);
}