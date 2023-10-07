//
//   This batch send the ecriture
//  
//  
// 
global class Batch_AccCaluculateRevenu implements Database.Batchable<sObject>,  Database.Stateful, Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext info){
     List<AsyncApexJob> previousJobList = [SELECT Id, CompletedDate  FROM AsyncApexJob WHERE ApexClass.Name ='Batch_AccCaluculateRevenu' 
                                    AND CompletedDate != null ORDER BY CompletedDate desc];
         Datetime previousRundate ;                            	
        if (previousJobList.size()> 0)   { previousRundate = previousJobList[0].CompletedDate ;}
        else {
            previousRundate = Date.today()-1 ; }

        return Database.getQueryLocator([SELECT Id, ACC_Revenu_n__c, ACC_revenu_n_1__c,ACC_revenu_n_2__c FROM Account WHERE LastModifiedDate >= :previousRundate ]);
    } 

global void execute(Database.BatchableContext BC, List<Account> accountList){

//UserInfo.USER_ByPassRegleValidation__c = true ;


Date  lowDate =date.valueOf(((System.now().year())-2)+'-01-01');
Map<Id, Account> accountMap = new Map<Id,Account>(accountList);
Set<Id> accountIds = accountMap.keySet();


List<Order> orderList = [SELECT TotalAmount,ORD_MontantHT_ERP__c, ORD_MontantERP__c,EffectiveDate,AccountId,ORD_SousDomaine__c,ORD_BusinessUnit__c  
                         FROM Order WHERE AccountId IN :accountIds  AND EffectiveDate >= :lowDate Order by AccountId ];
 Integer numberElement = orderList.size();
 Double revenu_n = 0 , revenu_n_1=0, revenu_n_2=0, erpAmount=0;
 Id currentAccountId =  null;
 Integer currentYear = System.Today().year();
 Integer  count = 0 ; 
 List<Account> accountListToUpdate = new List<Account>();
for (Order ord : orderList) {
    if (count == 0) currentAccountId = ord.AccountId ;
    if (ord.ORD_MontantHT_ERP__c !=null){erpAmount = ord.ORD_MontantHT_ERP__c ;} else{erpAmount =0 ;} 
    Account acct = (Account)accountMap.get(currentAccountId);
    if ((currentAccountId != ord.AccountId) && (count != numberElement-1)) {
		if ((acct.ACC_Revenu_n__c != revenu_n)||(acct.ACC_revenu_n_1__c != revenu_n_1 )||(acct.ACC_revenu_n_2__c != revenu_n_2 )) { 
			acct.ACC_Revenu_n__c = revenu_n ;
            acct.ACC_revenu_n_1__c = revenu_n_1 ;
            acct.ACC_revenu_n_2__c = revenu_n_2 ;
            accountListToUpdate.add(acct);
		}
        revenu_n = 0 ;  
        revenu_n_1 = 0 ;
        revenu_n_2 = 0 ;
        currentAccountId = ord.AccountId ;
    }
    
    if (ord.EffectiveDate.year() ==  currentYear) Revenu_n = Revenu_n  + erpAmount ;
    if (ord.EffectiveDate.year() ==  currentYear - 1) revenu_n_1 = revenu_n_1  + erpAmount ;
    if (ord.EffectiveDate.year() ==  currentYear - 2) revenu_n_2 = revenu_n_2  + erpAmount ; 
     
    if (count == numberElement-1) {
        acct = (Account)accountMap.get(ord.AccountId);
		if ((acct.ACC_Revenu_n__c != revenu_n)||(acct.ACC_revenu_n_1__c != revenu_n_1 )||(acct.ACC_revenu_n_2__c != revenu_n_2 )) { 
			if (acct.ACC_Revenu_n__c != Revenu_n )acct.ACC_Revenu_n__c = Revenu_n ;
			if (acct.ACC_revenu_n_1__c != revenu_n_1) acct.ACC_revenu_n_1__c = revenu_n_1;
			if (acct.ACC_revenu_n_2__c != revenu_n_2)acct.ACC_revenu_n_2__c = revenu_n_2 ;
			accountListToUpdate.add(acct);
		}
    }
  count++;
}
    Database.SaveResult[] srList = Database.update(accountListToUpdate, false);
}
global void finish(Database.BatchableContext BC){
    
}

global void execute(SchedulableContext sc) {
    Batch_AccCaluculateRevenu batch = new Batch_AccCaluculateRevenu();
    Database.executeBatch(batch);
}

global static void run(){
    Batch_AccCaluculateRevenu batch = new Batch_AccCaluculateRevenu();
    Database.executeBatch(batch);
}
}