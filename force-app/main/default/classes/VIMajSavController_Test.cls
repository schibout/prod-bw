@isTest
public class VIMajSavController_Test {

    static testmethod void VIMajSavController_Test() {
    
        VIInsertDataTest.VIInsertData_EUR_Affaire();

        list<VILigne_d_affaire_mensuelle__c>Listlam = [select id, affaire__c from VILigne_d_affaire_mensuelle__c ];

        Test.startTest();
        Test.setCurrentPage(Page.VIMajSav);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(Listlam);
        stdSetController.setSelected(Listlam);
        VIMajSavController ext = new VIMajSavController(stdSetController);
        ext.Enregistrer();
        
        Test.stopTest();
        
        
    }
}