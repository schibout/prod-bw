@isTest
public class VIInsertDataTest_test {


    static testmethod void VIInsertDataTest1_test() {
        VIInsertDataTest.VIInsertData_EUR_Affaire();
        VIInsertDataTest.VIInsertData_Achat();    
        VIInsertDataTest.VIInsertData_Facture();
        VIInsertDataTest.VIInsertData_Pointage();
        VIInsertDataTest.VIInsertData_ligne_comptable();
    }
    static testmethod void VIInsertDataTest2_test() {    
        VIInsertDataTest.VIInsertData_GBP_Avenant();
        VIInsertDataTest.VIInsertData_Avenant();        
        
    }
    static testmethod void VIInsertDataTest3_test() {    
        VIInsertDataTest.VIInsertData_GBP_Avenant();
        VIInsertDataTest.VIInsertData_Avenant_sans_update();
        
    }

}