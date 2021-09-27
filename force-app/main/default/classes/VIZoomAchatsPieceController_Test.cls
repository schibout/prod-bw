@isTest
public class VIZoomAchatsPieceController_Test {

    static testmethod void VIZoomAchatsController_Test() {
    
        VIInsertDataTest.VIInsertData_GBP_Avenant();
        VIInsertDataTest.VIInsertData_achat();

        VILigne_d_affaire_mensuelle__c lam = [select id,affaire__r.name,periode_comptable__r.name from VILigne_d_affaire_mensuelle__c order  by periode_comptable__r.name desc LIMIT 1];
        VICentre_Section__c centre = [select id from VICentre_Section__c LIMIT 1];
        VIType_de_depense__c td = [select id from VIType_de_depense__c where name like 'GAR%' LIMIT 1];

        VIAchat__c ac= [select Affaire__r.name, Centre_Section__r.name,type_depense__r.name,  Periode_comptable__r.name,num_cde__c from VIAchat__c];
        
        PageReference pageRef = Page.VIZoomAchats; 
        test.setCurrentPageReference(pageRef);

        ApexPages.currentPage().getParameters().put('ref',ac.num_cde__c);
        ApexPages.currentPage().getParameters().put('aff',ac.Affaire__r.name);        

                
        VIZoomAchatsPieceController testPage = new VIZoomAchatsPieceController ();  
        testPAge.getValeurOptions();

        testpage.valeur='Industriel';
        testPage.SortByDate();

        testpage.valeur='Complet';        
        testPage.SortByNomFrn();
        
        testPage.sens='DESC';
        testPage.SortByDateComptabilisation();
        testPage.SortByDesc();
        testPage.SortByRefAchat();
        testpage.SortByNum_fac();

//        VIAchat__c Ac= [select centre_section__c from VIAchat__c LIMIT 1];
//        ac.centre_section__c=cs1.id;
//        update ac ;
        
    }
}