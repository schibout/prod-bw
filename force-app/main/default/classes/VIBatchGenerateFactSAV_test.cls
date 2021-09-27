@isTest
public class VIBatchGenerateFactSAV_test {

    static testmethod void VIBatchGenerateFactSAV_test() {
    
        VIInsertDataTest.VIInsertData_EUR_Affaire();
        VIInsertDataTest.VIInsertData_Achat();
        VIInsertDataTest.VIInsertData_Facture();
        
        
        list<VIperiode__c>ListPeriode=[SELECT id,date_de_fin__c 
                                         FROM VIperiode__c 
                                       WHERE Statut__c =:VIConstant.PERIODE_OUVERTE
                                     ORDER BY NAME LIMIT 1];
        
        VICompte_general__c cc = new  VICompte_general__c  (name='7');
        insert cc ; 
        VICompte_general__c cc1 = new  VICompte_general__c  (name='null000');        
        insert cc1 ; 

                
        VIAffaire__c aff = [select id,Date_de_SAV_reelle__c from VIAffaire__c ] ;
        aff.Date_de_SAV_reelle__c = ListPeriode[0].date_de_fin__c;
        update aff; 

        VIfacture__c fac = [select id,Facture_SAV_traitee__c,Facture_SAV_comptabilisee__c,date__c,Facture_sur_Affaire_SAV__c  from VIfacture__c ] ;
        fac.date__c=aff.Date_de_SAV_reelle__c.adddays(1);
        fac.Facture_SAV_traitee__c = true;
        fac.Facture_SAV_comptabilisee__c =false;
        
        update fac; 
        
        
        
        VIBatchGenerateFactSAV b2 = new VIBatchGenerateFactSAV('','1'); 
        database.executebatch(b2,10);  
        
    }
}