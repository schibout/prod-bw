@isTest
public class VISchedImportAffaire_test {

    static testmethod void VISchedImportAffaire_test() {
    
        VIInsertDataTest.VIInsertData_EUR_Affaire();

        
        VIInsertDataTest.VIInsertData_Achat(); 
        string code_affaire='B80000';
        
        int_affaire__c aff = new int_affaire__c (Code_produit__c='PRE',
                               raisonSocialeClient__c='test',                  
                               codeAffaire__c='B80002',
                               codeClient__c='1234' ,
                               dateLivraison__c =System.today(),
                               DateMiseService__c =null,
                               dateOuvAffaire__c =System.today(),
                               DateReception__c =System.today(),
                               DateSortieVentePrev__c =System.today(),
                               libelleAffaire__c='aa',
                               lll_aff__c='aa', 
                               montantPv__c =123,
                               typeEvenement__c='CI',               
                               montantProvisionsGarantie__c =123) ;
        insert aff;

        int_affaire__c aff1 = new int_affaire__c (Code_produit__c='PRE',
                               raisonSocialeClient__c='test',                  
                               codeAffaire__c=code_affaire,
                               codeClient__c='1234' ,
                               dateLivraison__c =System.today(),
                               DateMiseService__c =null,
                               dateOuvAffaire__c =System.today(),
                               DateReception__c =System.today(),
                               DateSortieVentePrev__c =System.today(),
                               libelleAffaire__c='aa',
                               lll_aff__c='aa', 
                               montantPv__c =123,
                               typeEvenement__c='AV', 
                               NumAvCde__c='1',                  
                               montantProvisionsGarantie__c =123) ;
        insert aff1;
        
        VISchedImportAffaire v1 = new VISchedImportAffaire(code_affaire,false,true,1);
        v1.execute(null);

        VISchedImportAffaire v2 = new VISchedImportAffaire(code_affaire,false,true,1);
        v2.execute(null);

        VISchedImportAffaire v3 = new VISchedImportAffaire(code_affaire,false,true,1);
        v3.execute(null);

        VISchedImportAffaire v3a = new VISchedImportAffaire(code_affaire,false,true,1);
        v3a.execute(null);

        VIInsertDataTest.VIInsertData_Avenant();
        
        aff = [select flagannulation__c, import_status__c,typeevenement__c, NumAvCde__c from int_affaire__c where codeAffaire__c='B80000'];
        aff.flagannulation__c = true ; 
        aff.import_status__c='';
        aff.typeevenement__c='AV' ;
        aff.NumAvCde__c='2';
        update aff ; 

        VISchedImportAffaire v4 = new VISchedImportAffaire(code_affaire,false,true,1);
        v4.execute(null);
        
        v4.code_Coverage();
        
    }
}