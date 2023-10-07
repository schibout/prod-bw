@isTest
public class VIBatchCalcLAMExerPrec_test {

    static testmethod void VIBatchCalcLAMExerPrec_test() {
    
        VIInsertDataTest.VIInsertData_GBP_Avenant();
        List<VIperiode__c>ListPer =  [SELECT id, name, date_de_debut__c, date_de_fin__c, statut__c
                                      FROM VIPeriode__c];
        for(VIperiode__c per: ListPer) {
            per.statut__c=viConstant.PERIODE_OUVERTE ; 
        }
        update listPer; 
        
        VIAffaire__c aff =[select id,Date_ouverture_affaire__c from VIAffaire__c];
        aff.Date_ouverture_affaire__c=system.today().addyears(-1);
        update aff; 
        

        VIBatchCalcLAMExerPrec v = new VIBatchCalcLAMExerPrec();
        database.executebatch(v,10);  
        
    }
}