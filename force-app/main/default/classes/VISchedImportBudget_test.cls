@isTest
public class VISchedImportBudget_test {

    static testmethod void VISchedImportBudget_test() {
    
        VIInsertDataTest.VIInsertData_EUR_Affaire();

        VIType_de_depense__c td = [select name from VIType_de_depense__c limit 1];
        VICentre_Section__c cs = [select name from VICentre_Section__c limit 1];
                
        Int_budget__c bud = new Int_budget__c (
                               codeAffaire__c='B80000',
                               codechapitre__c='00', 
                               codeSousChapitre__c='00',
                               codecentre__c=cs.name.left(3),
                               typeDepense__c=td.name.left(3), 
                               DatePublication__c  =System.today(), 
                               mntEur__c=1,
                               nbrHeures__c=1) ;
        insert bud;
        
        VISchedImportBudget v1 = new VISchedImportBudget('B80000',false,false);
        v1.execute(null);
    }
}