@isTest
public class VIZoomFacturesController_Test {

    static testmethod void VIZoomFacturesController_Test() {
    
        VIInsertDataTest.VIInsertData_GBP_Avenant();
        VIInsertDataTest.VIInsertData_Facture();
        
        VIFacture__c fac=[select type__C from VIFacture__c limit 1];
        fac.type__C='FAC';
        update fac;

        VIAffaire__c affaire = [select id from VIAffaire__c LIMIT 1];
        VILigne_d_affaire_mensuelle__c Lam = [SELECT id FROM VILigne_d_affaire_mensuelle__c Limit 1];
        
        PageReference pageRef = Page.VIZoomFactures; 
        test.setCurrentPageReference(pageRef);
        ApexPages.currentPage().getParameters().put('aff',affaire.Id);
        ApexPages.currentPage().getParameters().put('per','209901');
        ApexPages.currentPage().getParameters().put('lam',lam.id);
        

                
        VIZoomFacturesController testPage = new VIZoomFacturesController ();  
                
        
    }
}