@isTest
public class VIBatchGenerate_test {

    static testmethod void ViBatchGenerate_test() {
    
        VIInsertDataTest.VIInsertData_EUR_Affaire();
        VIInsertDataTest.VIInsertData_Achat();
        //VIInsertDataTest.VIInsertData_Pointage();
        VIInsertDataTest.VIInsertData_Facture();
        
        VISousDomaine__c sd = [select  Mode_de_calcul_de_l_avancement__c from VISousDomaine__c];
        sd.Mode_de_calcul_de_l_avancement__c='2';
        update sd ; 

        
        list<VIperiode__c>ListPeriode=[SELECT id,date_de_fin__c 
                                         FROM VIperiode__c 
                                       WHERE Statut__c =:VIConstant.PERIODE_OUVERTE
                                     ORDER BY NAME LIMIT 1];
        
        VICompte_general__c cc = new  VICompte_general__c  (name='7');
        insert cc ; 

        VIBatchGenerate b1 = new VIBatchGenerate('','1'); 
        database.executebatch(b1,10);  
                
        VIAffaire__c aff = [select id,Date_de_SAV_reelle__c from VIAffaire__c ] ;
        aff.Date_de_SAV_reelle__c = ListPeriode[0].date_de_fin__c;
        update aff; 

        VIBatchGenerate b2 = new VIBatchGenerate('','1'); 
        database.executebatch(b2,10);  
        
        b2.code_coverage();
        
/*      henri
        list<VILigne_Affaire__c>ListLa= [SELECT id, Cout_terminaison_MontantD__c, Engage_brut_arrete_MontantD__c,Ecart_C_A_F_MontantD__c   
                                           FROM VILigne_Affaire__c ] ;

        ListLa[0].Ecart_C_A_F_MontantD__c=1;
        update ListLa ; 
        System.assertEquals(2, listLa.size());
        System.assertEquals(101, listLa[0].Engage_brut_arrete_MontantD__c);
*/
        
    }
}