/**
 * @description       : 
 * @author            : SCHIBOUT
 * @group             : 
 * @last modified on  : 29-09-2021
 * @last modified by  : SCHIBOUT
**/
global class BatchOrderVisionSynchro  implements Database.Batchable<sObject>,  Database.Stateful, Schedulable {
    global Database.QueryLocator start(Database.BatchableContext info){
        List<AsyncApexJob> previousJobList = [SELECT Id, CompletedDate  FROM AsyncApexJob WHERE ApexClass.Name ='BatchOrderVisionSynchro' 
                                    AND CompletedDate != null ORDER BY CompletedDate desc];
         Datetime previousRundate ;                            	
        if (previousJobList.size()> 0)   { previousRundate = previousJobList[0].CompletedDate ;}
        else {
            previousRundate = Date.today()-1 ; }
        // all accounts     
        /*return Database.getQueryLocator([SELECT Id,ord_visSousDomain__c,Ord_Domaine__c,ORD_SousDomaine__c ,ORD_BusinessUnit__c,Account.Acc_CodeSecteur__c
                                        ,Account.Acc_CodeAgence__c,Account.ACC_SecteurCommercial__c,Account.ACC_Region__c,ORD_Code_Secteur_Commercial__c
                                        ,ORD_Secteur_Commercial__c,ORD_Agence_Regionale_BW__c,ORD_Code_Agence_Regionale_BW__c
                                        FROM Order WHERE ORD_Code_Secteur_Commercial__c =null 
                                        OR ORD_Code_Agence_Regionale_BW__c =null 
                                        OR ORD_Agence_Regionale_BW__c = null
                                        OR ORD_Secteur_Commercial__c = null OR Ord_Domaine__c  = null OR ord_visSousDomain__c = null]);*/

        return Database.getQueryLocator([SELECT Id,ord_visSousDomain__c,Ord_Domaine__c,ORD_SousDomaine__c ,ORD_BusinessUnit__c,Account.Acc_CodeSecteur__c
                                        ,Account.Acc_CodeAgence__c,Account.ACC_SecteurCommercial__c,Account.ACC_Region__c,ORD_Code_Secteur_Commercial__c
                                        ,ORD_Secteur_Commercial__c,ORD_Agence_Regionale_BW__c,ORD_Code_Agence_Regionale_BW__c
                                        FROM Order WHERE LastModifiedDate >= :previousRundate ]);                                
    } 

    global void execute(Database.BatchableContext BC, List<Order> orderList){
        
       //Update Orders 
       List<Order> orderListToUpdate = new List<Order>();
       for(Order ord : orderList){                      
           
            Boolean addToList  = false ;
            if (ord.ord_visSousDomain__c != BwUtils.getTranscoVisionValue('Sous domaine',ord.ORD_SousDomaine__c) ) ord.ord_visSousDomain__c = BwUtils.getTranscoVisionValue('Sous domaine',ord.ORD_SousDomaine__c) ;
            if (ord.Ord_Domaine__c !=BwUtils.getTranscoVisionValue('BU',ord.ORD_BusinessUnit__c)) { ord.Ord_Domaine__c =BwUtils.getTranscoVisionValue('BU',ord.ORD_BusinessUnit__c);addToList = true ;}
            if (ord.ORD_Code_Secteur_Commercial__c != ord.Account.Acc_CodeSecteur__c){ ord.ORD_Code_Secteur_Commercial__c =ord.Account.Acc_CodeSecteur__c;addToList = true ;}
            if (ord.ORD_Secteur_Commercial__c != ord.Account.ACC_SecteurCommercial__c) { ord.ORD_Secteur_Commercial__c=ord.Account.ACC_SecteurCommercial__c;addToList = true ;}
            if (ord.ORD_Agence_Regionale_BW__c != ord.Account.ACC_Region__c) { ord.ORD_Agence_Regionale_BW__c=ord.Account.ACC_Region__c;addToList = true ;}
            if (ord.ORD_Code_Agence_Regionale_BW__c != ord.Account.Acc_CodeAgence__c){ ord.ORD_Code_Agence_Regionale_BW__c=ord.Account.Acc_CodeAgence__c;addToList = true ;}
            if (addToList) (orderListToUpdate.add(ord));

       }
       Database.update(orderListToUpdate, false);
    }
    
    global void finish(Database.BatchableContext BC){
            
    }

    global void execute(SchedulableContext sc) {
        BatchOrderVisionSynchro batch = new BatchOrderVisionSynchro();
        Database.executeBatch(batch);
    }

    global static void run(){
        BatchOrderVisionSynchro batch = new BatchOrderVisionSynchro();
        Database.executeBatch(batch);
    }
}