/**
 * @description       : 
 * @author            : SCHIBOUT
 * @group             : 
 * @last modified on  : 27-09-2021
 * @last modified by  : SCHIBOUT
**/
global class  INT_BatchOrderFromGPICFile  implements Database.Batchable<sObject>,  Database.Stateful, Schedulable{
    global Database.QueryLocator start(Database.BatchableContext info){
        
        return Database.getQueryLocator([SELECT Id,DateSaisie__c, ClientLivraison__c, Numero__c, TotalAPayer__c,  Etat__c, AdresseLiv__c, CodePostalLiv__c,
        VilleLiv__c,  CodePaysLiv__c, ClientPayeur__c,  TotalHorsTaxe__c,  DateLivDem__c,  NoOpportuniteSF__c, ReferenceClient__c, Affaire__c
        ,  DerDateBL__c, VolumeHeure__c, NumeroDevis__c, chargeAffaire__c  FROM GpicOordersInFiles__c ]);
    }
    
    global void finish(Database.BatchableContext BC){
    
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> fileDataList){

  /*      for (GpicOordersInFiles__c data : fileDataList) {

            
        }
*/

    }

    global void execute(SchedulableContext sc) {
        INT_BatchOrderFromGPICFile batch = new INT_BatchOrderFromGPICFile();
        Database.executeBatch(batch);
    }
    
    global static void run(){
        INT_BatchOrderFromGPICFile batch = new INT_BatchOrderFromGPICFile();
        Database.executeBatch(batch);
    }
}
