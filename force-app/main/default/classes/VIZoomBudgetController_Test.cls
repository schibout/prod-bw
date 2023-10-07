@isTest
public class VIZoomBudgetController_Test {

    static testmethod void VIZoomBudgetController_Test() {
    
        VIInsertDataTest.VIInsertData_GBP_Avenant();
        VIInsertDataTest.VIInsertData_Avenant();

        VILigne_d_affaire_mensuelle__c lam = [select id from VILigne_d_affaire_mensuelle__c LIMIT 1];
        VICentre_Section__c centre = [select id from VICentre_Section__c LIMIT 1];
        VIType_de_depense__c td = [select id from VIType_de_depense__c LIMIT 1];
        
        
        PageReference pageRef = Page.VIZoomHeuresEngagees; 
        test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('lam',lam.Id);
        ApexPages.currentPage().getParameters().put('centre',centre.Id); 
        ApexPages.currentPage().getParameters().put('td',td.Id);        
        
                
        VIZoomBudgetController testPage = new VIZoomBudgetController ();  
        
        testPage.SortByAvenant(); 
        testPage.getValeurOptions();
      //  testPage.SortBydate();
      //  testPage.SOQL_verif();        
        
    }
}