@isTest
public class VIBatchGenereAutorisation_test {

    static testmethod void VIBatchGenereAutorisation_CAS1_test() {
    
        VIInsertDataTest.VIInsertData_GBP_Avenant();

        list<VIperiode__c>ListPeriode=[SELECT id,date_de_fin__c 
                                         FROM VIperiode__c 
                                       WHERE Statut__c =:VIConstant.PERIODE_OUVERTE
                                     ORDER BY NAME LIMIT 1];

        VIAffaire__c aff = [SELECT Date_de_SAV_reelle__c from VIAffaire__c];
        aff.Date_de_SAV_reelle__c = ListPeriode[0].date_de_fin__c;
        update aff ; 

        
        VIBatchGenereAutorisation v = new VIBatchGenereAutorisation(true);
        v.execute(null);

        aff.Affaire_reouverte__c=true;
        update aff; 
        Database.executeBatch(new VIBatchGenereAutorisation(true),VIBatchGenereAutorisation.NBR_LOT);
        
        v.code_coverage();
        
    }
  
    
}