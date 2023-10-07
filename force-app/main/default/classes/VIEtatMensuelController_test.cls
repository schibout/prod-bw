@isTest
private class VIEtatMensuelController_test {

    static testmethod void VIEtatMensuelControllerEUR_test() {
    
        VIInsertDataTest.VIInsertData_EUR_Affaire();
        VIInsertDataTest.VIInsertData_Achat();
        VIAffaire__c aff = [select id from VIAffaire__c LIMIT 1];

        list<id> ListAffid = new list<id>();
        listAffId.add(aff.id);
//        VIUtils.recalcul_LA(listAffId);
               
        String currentuserId = UserInfo.getUserId();
        User currentUserInfo = [select LanguageLocaleKey from User where Id = :UserInfo.getUserId()];
        currentUserInfo.LanguageLocaleKey = 'pt_BR';
        update currentUserInfo;        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(aff);
        VIEtatMensuelController testaff = new VIEtatMensuelController (sc);  
        
        PageReference pageRef = Page.VIEtatMensuel; 
        pageRef.getParameters().put('id',aff.Id);       

        testaff.Chargement();
        
        list<VILigne_d_affaire_mensuelle__c>ListLAM = [select currencyIsoCode from  VILigne_d_affaire_mensuelle__c];
        system.debug('ListLam '+ListLam);
        for(VILigne_d_affaire_mensuelle__c lam : ListLam) {
            lam.currencyIsoCode='EUR';
        }
        update ListLam;

        VIType_de_depense__c depense = [SELECT id, name 
                                              FROM  VIType_de_depense__c limit 1];
        VIcentre_section__c cs=[select id from VIcentre_section__c LIMIT 1 ];
        
        VILigne_affaire__c NewLa = VIUtils.init_la();
        NewLa.Ligne_d_affaire_mensuelle__c = ListLam[0].id;
        NewLa.Type_de_ligne_d_affaire__c = 'I';
        NewLa.Centre_Section__c= cs.id;
        NewLa.Type_depense__c  =  depense.id ; 
        insert NewLa ; 

        
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
        testaff.Refresh();        
        
//        testaff.Suivant();                
//        testaff.Precedent();                

    }


    static testmethod void VIEtatMensuelControllerGBP_Test() {
    
        VIInsertDataTest.VIInsertData_GBP_Avenant();
        VIInsertDataTest.VIInsertData_Achat();
        VIAffaire__c aff = [select id from VIAffaire__c LIMIT 1];

        list<id> ListAffid = new list<id>();
        listAffId.add(aff.id);

        ApexPages.StandardController sc = new ApexPages.StandardController(aff);
        VIEtatMensuelController testaff = new VIEtatMensuelController (sc);  
        
        PageReference pageRef = Page.VIEtatMensuel; 
        pageRef.getParameters().put('id',aff.Id);
        testaff.currencyType='GBP';
        Test.setCurrentPage(pageRef);

     //   testaff.Chargement();
        
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

        testaff.suivant();
        testaff.precedent();
        testaff.ValSav=true;
        testaff.sav();        
        
    }
    
    
}