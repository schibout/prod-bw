@isTest
public class VISchedHouseCleaning_Test {

    static testmethod void VISchedHouseCleaning_Test() {
    
        VIInsertDataTest.VIInsertData_GBP_Avenant();

        list<VILigne_affaire__c>ListLa = [SELECT id from VILigne_affaire__c];
        update ListLa;
        
        VISchedHouseCleaning v = new VISchedHouseCleaning();
        v.execute(null);
    }
}