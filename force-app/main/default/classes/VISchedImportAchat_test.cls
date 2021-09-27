@isTest
public class VISchedImportAchat_test {

    static testmethod void VISchedImportAchat_test() {
    
        VIInsertDataTest.VIInsertData_EUR_Affaire();

        VIType_de_depense__c td = [select name from VIType_de_depense__c limit 1];
        VICentre_Section__c cs = [select name from VICentre_Section__c limit 1];

        VIInsertDataTest.VIInsertData_Achat(); 
        
        int_achat__c ac = new int_achat__c (
                               codeAffaire__c='B80000',
                               codeCentre__c=cs.name.left(3) ,
                               codeChapitre__c='00',
                               codesousChapitre__c='00',            
                               Date__c =System.today(),
                               Mtcommande__c  =123,
                               Mtcompatabilise__c  =123,
                               TypeDeDepense__c =td.name.left(3)) ;
        insert ac;
        
        VISchedImportAchat v1 = new VISchedImportAchat('B80000',false,false);
        v1.execute(null);

    }
}