@isTest
public class VIBatchDeleteLC_test {
    static testmethod void VIBatchDeleteLC_test() {   
        
      VIInsertDataTest.VIInsertData_EUR_Affaire();  
      VIInsertDataTest.VIInsertData_ligne_comptable();
      list<VILigne_comptable__c>ListLc = [SELECT id,CompteComptable_local__c,Statut_ecriture_comptable__c  FROM VILigne_comptable__c];
      for(VILigne_comptable__c lc : ListLc) {
            lc.Statut_ecriture_comptable__c='10';
      }
      update listLc ; 

      VIBatchDeleteLC v = new VIBatchDeleteLC('',false);
      v.execute(null);
    }
}