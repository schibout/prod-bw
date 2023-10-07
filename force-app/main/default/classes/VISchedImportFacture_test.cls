@isTest
public class VISchedImportFacture_test {

    static testmethod void VISchedImportFacture_test() {
    
        VIInsertDataTest.VIInsertData_EUR_Affaire();

        VICentre_Section__c cs = new VICentre_Section__c (name ='800');
        insert cs; 

        VICompte_General__c cg = new VICompte_General__c(name='700000', libelle__c='7000000');
        insert cg ; 
        
        int_Facture__c fac = new int_facture__c (
                               codeAffaire__c='B80000',
                               libelle__c='toto',
                               date_de_comptabilisation__c=System.today(),
                               Compte__c ='123' ,
                               Date__c =System.today(),
                               MtHT__c    =1,
                               type_enregistrement__c='FAC') ;
        insert fac;
        
        int_Facture__c fac1 = new int_facture__c (
                               codeAffaire__c='B80000',
                               libelle__c='toto',            
                               date_de_comptabilisation__c=System.today(),
                               Compte__c ='700000' ,
                               Date__c =System.today(),
                               MtHT__c    =1,
                               type_enregistrement__c='ECR') ;
        insert fac1;
        
        VISchedImportFacture v1 = new VISchedImportFacture('B80000',false,false);
        v1.execute(null);

    }
}