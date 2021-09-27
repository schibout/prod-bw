@isTest
public class VIZoomAchatsController_Test {

    static testmethod void VIZoomAchatsController_Test() {
    
        VIInsertDataTest.VIInsertData_GBP_Avenant();
        VIInsertDataTest.VIInsertData_achat();

        VILigne_d_affaire_mensuelle__c lam = [select id,affaire__r.name,periode_comptable__r.name from VILigne_d_affaire_mensuelle__c order  by periode_comptable__r.name desc LIMIT 1];
        VICentre_Section__c centre = [select id from VICentre_Section__c LIMIT 1];
        VIType_de_depense__c td = [select id from VIType_de_depense__c where name like 'GAR%' LIMIT 1];

        VIAchat__c ac= [select Affaire__r.name, Centre_Section__r.name,type_depense__r.name,  Periode_comptable__r.name from VIAchat__c];
        
        PageReference pageRef = Page.VIZoomHeuresEngagees; 
        test.setCurrentPageReference(pageRef);

        ApexPages.currentPage().getParameters().put('lam',lam.Id);
        ApexPages.currentPage().getParameters().put('centre',centre.Id);        
        ApexPages.currentPage().getParameters().put('td',td.Id);        

                
        VIZoomAchatsController testPage = new VIZoomAchatsController ();  
        testPAge.getValeurOptions();

        testpage.valeur='Industriel';
        testPage.SortByDate();

        testpage.valeur='Complet';        
        testPage.SortByNomFrn();
        
        testPage.sens='DESC';
        testPage.SortByDateComptabilisation();
        testPage.SortByDesc();
        testPage.MajProv();

//        VIAchat__c Ac= [select centre_section__c from VIAchat__c LIMIT 1];
//        ac.centre_section__c=cs1.id;
//        update ac ;
        
    }
}