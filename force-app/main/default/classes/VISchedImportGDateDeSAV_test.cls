@isTest
public class VISchedImportGDateDeSAV_test {

    static testmethod void VISchedImportGDateDeSAV_test() {
    
 
        VIInsertDataTest.VIInsertData_EUR_Affaire();
        VIAffaire__c aff = [select id,name from VIaffaire__c LIMIT 1];

        list<VIperiode__c>ListPeriode=[SELECT id,date_de_fin__c ,date_de_debut__c
                                         FROM VIperiode__c 
                                       WHERE Statut__c =:VIConstant.PERIODE_OUVERTE
                                     ORDER BY NAME LIMIT 1];
        
        int_gdatedesav__c i = new int_gdatedesav__c(code_affaire__c=aff.name, date_de_sav__c=ListPeriode[0].date_de_fin__c);
        insert i;


        VIType_de_depense__c td = [select name from VIType_de_depense__c limit 1];
        VICentre_Section__c cs = [select name from VICentre_Section__c limit 1];
        
        int_gecart__c e = new int_gecart__c(code_affaire__c=aff.name,date__c=ListPeriode[0].date_de_debut__c,
                                            type_de_depense__c=td.name,
                                            centre__c=cs.name,
                                            montant__c=1);
        insert e; 
        
                
        VISchedImportGDateDeSAV v1 = new VISchedImportGDateDeSAV('B80000',false,false);
        v1.execute(null);

        VISchedImportGecart v2 = new VISchedImportGecart('B80000',false,false,ListPeriode[0].date_de_debut__c);
        v2.execute(null);

    }
}