global class   BatchAccountVisionSynchro   implements Database.Batchable<sObject>,  Database.Stateful, Schedulable {


    /**
     * 
     */
    global Database.QueryLocator start(Database.BatchableContext info){
        // all accounts 
		List<AsyncApexJob> previousJobList = [SELECT Id, CompletedDate  FROM AsyncApexJob WHERE ApexClass.Name ='BatchAccountVisionSynchro' 
                                    AND CompletedDate != null ORDER BY CompletedDate desc];
         Datetime previousRundate ;                            	
        if (previousJobList.size()> 0)   { previousRundate = previousJobList[0].CompletedDate ;}
        else {
            previousRundate = Date.today()-1 ; }



        return Database.getQueryLocator([SELECT Id,Acc_CodeSecteur__c,Acc_CodeAgence__c,ACC_SecteurCommercial__c,ACC_Region__c FROM Account WHERE LastModifiedDate >= :previousRundate ]);
    } 
/**
 * 
 */
    global void execute(Database.BatchableContext BC, List<Account> accountList){
        
       for (Account acct : accountList) {
        acct.Acc_CodeSecteur__c =BwUtils.getTranscoVisionValue('Secteur',acct.ACC_SecteurCommercial__c);
        acct.Acc_CodeAgence__c =BwUtils.getTranscoVisionValue('Agence Régionale',acct.ACC_Region__c);   
       } 
       Database.update(accountList, false);
    }
    
/**
 * 
 */

    global void finish(Database.BatchableContext BC){
            
    }
/**
 * 
 */
    global void execute(SchedulableContext sc) {
        BatchAccountVisionSynchro batch = new BatchAccountVisionSynchro();
        Database.executeBatch(batch);
    }
/**
 * 
 */
    global static void run(){
        BatchAccountVisionSynchro batch = new BatchAccountVisionSynchro();
        Database.executeBatch(batch);
    }
}