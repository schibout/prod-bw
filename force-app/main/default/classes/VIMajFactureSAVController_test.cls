@isTest
public class VIMajFactureSAVController_test {

    static testmethod void VIMajFactureSAVController_test() {
    
        VIInsertDataTest.VIInsertData_EUR_Affaire();
        VIInsertDataTest.VIInsertData_Facture();

        list<VIfacture__c>Listfac = [select id, affaire__c from VIfacture__c ];

        Test.startTest();
        Test.setCurrentPage(Page.VIMajFactureSAV);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(Listfac);
        stdSetController.setSelected(Listfac);
        VIMajFactureSAVController ext = new VIMajFactureSAVController(stdSetController);
        ext.Enregistrer();
        
        Test.stopTest();
        
        
    }
}