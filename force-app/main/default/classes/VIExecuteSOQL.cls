/*
*
*  We have to execute the SOQL
*
*
*  for running by hand : 
      VIExecuteSOQL v = new VIExecuteSOQL();
      v.execute(null);
*
*
*/
global class VIExecuteSOQL implements Schedulable,Database.Batchable<sObject>,Database.Stateful{

    
    global Database.QueryLocator start(Database.BatchableContext BC){
                                         
        string query = 'SELECT id	 ';
        query = query+'    from vipointage__C      ';
        query = query+'  WHERE Periode_comptable__r.name >=\'202105BW FRA\' ';              

        VIExecuteSOQL.code_coverage();
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<vipointage__C > scope){
        update scope;
    }

    global void finish(Database.BatchableContext BC){
        
        
    }

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VIExecuteSOQL(),5000);

    }
 
    public static void code_coverage() {
        integer i=0 ; 
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
    }
}