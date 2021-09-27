@isTest
public class VIZoomHeuresEngageesController_Test {

    static testmethod void VIZoomHeuresEngageesController_Test() {
    
        VIInsertDataTest.VIInsertData_EUR_Affaire();

        VIInsertDataTest.VIInsertData_Pointage();

        VILigne_d_affaire_mensuelle__c lam = [select id from VILigne_d_affaire_mensuelle__c LIMIT 1];
        VICentre_Section__c centre = [select id from VICentre_Section__c LIMIT 1];
        
        PageReference pageRef = Page.VIZoomHeuresEngagees; 
        test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('lam',lam.Id);
        ApexPages.currentPage().getParameters().put('centre',centre.Id);        
                
        VIZoomHeuresEngageesController testPage = new VIZoomHeuresEngageesController ();  
        
        testPage.SortBySalarie();
        testPage.SortBydate();
        testPage.SOQL_verif();
        testPage.getValeurOptions();
    }
}