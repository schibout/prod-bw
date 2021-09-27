@isTest
public class VISchedImportPointage_test {

    static testmethod void VISchedImportPointage_test() {
    
        VIInsertDataTest.VIInsertData_EUR_Affaire();

        VIType_de_depense__c td = [select name from VIType_de_depense__c limit 1];
        VICentre_Section__c cs = [select name from VICentre_Section__c limit 1];

        VIInsertDataTest.VIInsertData_Achat(); 
        
        int_pointage__c po = new int_pointage__c (
                               codeAffaire__c='B80000',
                               codeCentre__c=cs.name.left(3) ,
                               codeChapitre__c='00',
                               codesousChapitre__c='00',            
                               Date__c =System.today(),
                               NbrHeures__c   =1,
                               salarie__c =null,
                               numero_unique__c='44',
                               semaine_ori__c = 1,
                               Annee_ori__c=System.today().year()) ;
        insert po;
        
        VISchedImportpointage v1 = new VISchedImportpointage('B80000',false,false);
        v1.execute(null);
        
        
        

    }
}