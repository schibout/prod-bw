@isTest
private class VIAffaireTotalController_Test {

    static testmethod void VIAffaireTotalControllerEUR_Test() {
    
        VIInsertDataTest.VIInsertData_EUR_Affaire();
        VIInsertDataTest.VIInsertData_Achat();
        VIAffaire__c aff = [select id from VIAffaire__c LIMIT 1];

        list<id> ListAffid = new list<id>();
        listAffId.add(aff.id);
        VIUtils.recalcul_LA(listAffId);
               
        String currentuserId = UserInfo.getUserId();
        User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId()];
        currentUserInfo.LanguageLocaleKey = 'pt_BR';
        update currentUserInfo;        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aff);
        VIAffaireTotalController testaff = new VIAffaireTotalController (sc);  
        
        PageReference pageRef = Page.VIAffaireTotal; 
        pageRef.getParameters().put('id',aff.Id);       

        
        list<VILigne_d_affaire_mensuelle__c>ListLAM = [select currencyIsoCode from  VILigne_d_affaire_mensuelle__c];
        for(VILigne_d_affaire_mensuelle__c lam : ListLam) {
            lam.currencyIsoCode='EUR';
        }
        update ListLam;

        testaff.currencyType='EUR';
        Test.setCurrentPage(pageRef);
        testaff.saveData();
        testaff.getValeurOptions();
        testaff.getCurrencyOptions();    
        testaff.getLAMOptions();    

        testaff.currencyType='EUR';
        testaff.Valeur='Industriel';
        testaff.ReRead();

        testaff.Valeur='Complet';
        testaff.ReRead();

        testaff.Valeur='Debours';
        testaff.ReRead();

        testaff.SortCentre();
        testaff.SortDepense();        
        testaff.SOQL_verif();        
//        testaff.Suivant();                
//        testaff.Precedent();                

    }


    static testmethod void VIAffaireTotalControllerGBP_Test() {
    
        VIInsertDataTest.VIInsertData_GBP_Avenant();
        VIInsertDataTest.VIInsertData_Achat();
        VIAffaire__c aff = [select id from VIAffaire__c LIMIT 1];

        list<id> ListAffid = new list<id>();
        listAffId.add(aff.id);
        VIUtils.recalcul_LA(listAffId);


        ApexPages.StandardController sc = new ApexPages.StandardController(aff);
        VIAffaireTotalController testaff = new VIAffaireTotalController (sc);  
        
        PageReference pageRef = Page.VIAffaireTotal; 
        pageRef.getParameters().put('id',aff.Id);
        testaff.currencyType='GBP';
        Test.setCurrentPage(pageRef);
/*
        testaff.saveData();
        testaff.getValeurOptions();
        testaff.getCurrencyOptions();    
*/       
        testaff.Valeur='Industriel';
        testaff.ReRead();


        testaff.Valeur='Complet';
        testaff.ReRead();
        
        testaff.Valeur='Debours';
        testaff.ReRead();

        testaff.SortCentre();
        testaff.SortDepense();        
        testaff.SOQL_verif();        
        
    }
    
    
}