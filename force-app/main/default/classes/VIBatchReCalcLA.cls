//
//   This batch recalculate the Currency Value of each line
//  
//  
// 
global class VIBatchReCalcLA implements Database.Batchable<sObject>, Database.Stateful {

    private Date   DateDateMinimum;
    private Date   DateDateMaximum;
    Public Integer num_record = 0; 
    Global String IDLog ='';    

    public VIBatchReCalcLA(date DateParam2 ,date  DateParam3) {
        DateDateMinimum = DateParam2;        
        DateDateMaximum = DateParam3;                
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String     query='SELECT Id ';
        query = query + '   FROM VILigne_affaire__c  ';
        query = query + '  WHERE Ligne_d_affaire_mensuelle__r.periode_comptable__r.date_de_debut__c>='+string.valueof(DateDateMinimum) ;
        query = query + '    AND Ligne_d_affaire_mensuelle__r.periode_comptable__r.date_de_debut__c<='+string.valueof(DateDateMaximum) ;
        
        IDLog=VIUtils.LogWrite('VIBatchReCalcLA','4 Running','','Start ');
        
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<VILigne_affaire__c> scope) {
        // Let's handle the VILigne_affaire__c Table 
        // Ok I know, it's not good to put an update in a loop, but we are not suppose to have a big number of lines
        for(VILigne_affaire__c la:scope) {
             update la  ;
        }
        num_record = num_record + scope.size();
    }   

    global void finish(Database.BatchableContext BC) {
        IDLog=VIUtils.LogWrite('VIBatchReCalcLA','1 Normal',IDLog,'nbr '+num_record);            
    }
}