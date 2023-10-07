@isTest
public class VIBatchRegenerate_test {

    static testmethod void VIBatchRegenerateLAM_test() {
    
        VIInsertDataTest.VIInsertData_EUR_affaire();

        VICentre_section__c cs = [SELECT id from VICentre_section__c LIMIT 1 ];
        VIAffaire__c aff       = [SELECT id,name,CurrencyIsoCode,date_max_mouvement__c from VIAffaire__c LIMIT 1 ];        
        VIPointage__c po= new VIPointage__c(affaire__c=aff.id,date__c=system.today().addmonths(6),heures__c=1, Centre_Section__c =cs.id, 
                                             CurrencyIsoCode=aff.CurrencyIsoCode,employe__c=UserInfo.getUserId(),numero_unique__c='AAA',
                                             sous_chapitre__c='00-00');
        insert po;

        VIInsertDataTest.VIInsertData_Achat();
        
        list<VILigne_d_affaire_mensuelle__c>listLam=[select id from VILigne_d_affaire_mensuelle__c];
        delete ListLam;
        
        Database.executeBatch(new VIBatchRegenerateLAM(aff.name,false), 1);
        viutils.code_coverage(); 

    }

    static testmethod void VIBatchRegenerateTotal_test() {
    
        VIInsertDataTest.VIInsertData_EUR_affaire();

        VICentre_section__c cs = [SELECT id from VICentre_section__c LIMIT 1 ];
        VIAffaire__c aff       = [SELECT id,name,CurrencyIsoCode,date_max_mouvement__c from VIAffaire__c LIMIT 1 ];        
        VIPointage__c po= new VIPointage__c(affaire__c=aff.id,date__c=system.today().addmonths(6),heures__c=1, Centre_Section__c =cs.id, 
                                             CurrencyIsoCode=aff.CurrencyIsoCode,employe__c=UserInfo.getUserId(),numero_unique__c='AAA',
                                             sous_chapitre__c='00-00');
        insert po;

        VIInsertDataTest.VIInsertData_Achat();
        VIInsertDataTest.VIInsertData_Avenant_sans_update();
                 
        
        Database.executeBatch(new VIBatchRegenerateTotal(aff.name,false,false), 1);

    }

}