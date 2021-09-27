@isTest
private class VIGenereAutorisationController_test {

    static testmethod void VIGenereAutorisationController_test() {
    
        VIInsertDataTest.VIInsertData_EUR_Affaire();
        
        VIAffaire__c aff = [select id from VIAffaire__c ];        
        ApexPages.StandardController sc = new ApexPages.StandardController(aff);

        VIGenereAutorisationController testaff = new VIGenereAutorisationController (sc);  

        
        PageReference pageRef = Page.VIGenereAutorisation; 
        pageRef.getParameters().put('id',aff.Id);       

         VIAutorisation_depense__c NewAut = new VIAutorisation_depense__c(
                Code_Affaire__c = aff.id,
                sous_Chapitre__c = '00-00',
                Date_du_mouvement__c = system.today(),
                Etat_du_mouvement__c ='Open', 
                Statut_autorisation_depense__c='20') ;
        insert NewAut ; 
   
        system.debug('on vient d inserer '+aff.id);
        
        testaff.CreerOuvert();        
        testaff.CreerFerme();                 
        testaff.SupprimerTout();        
    }
    
    
}