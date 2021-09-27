//
//   This batch recalculate the Currency Value of each line
//  
//  
// 
global class VIBatchReCalcAchat implements Database.Batchable<sObject>, Database.Stateful {

    private Date   DateDateMinimum;
    private Date   DateDateMaximum;
    Public Integer num_record = 0; 
    Global String IDLog ='';    

    public VIBatchReCalcAchat(date DateParam2 ,date  DateParam3) {
        DateDateMinimum = DateParam2;        
        DateDateMaximum = DateParam3;                
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String     query='SELECT Id,affaire__c ';
        query = query + '   FROM VIAchat__c ';
        query = query + '  WHERE date__c>='+string.valueof(DateDateMinimum) ;
        query = query + '    AND date__c<='+string.valueof(DateDateMaximum) ;
        
        IDLog=VIUtils.LogWrite('VIBatchReCalcAchat','4 Running','','Start ');
        
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<VIAchat__c> scope) {
        // Let's handle the Pointage Table 
        // Ok I know, it's not good to put an update in a loop, but we are not suppose to have a big number of lines
        for(VIAchat__c ac:scope) {
             update ac  ;
        }
        num_record = num_record + scope.size();
    }   

    global void finish(Database.BatchableContext BC) {
        IDLog=VIUtils.LogWrite('VIBatchReCalcAchat','1 Normal',IDLog,'nbr '+num_record);     

        VIBatchReCalcLA b = new VIBatchReCalcLA(DateDateMinimum,datedatemaximum); 
        database.executebatch(b,1);              
        
    }
}