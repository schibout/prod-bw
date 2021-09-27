/*
*
*  Delete the VILigne_comptable__c in statut = 10 or 20 
*
*
*  for running by hand : 
      VIBatchDeleteLC v = new VIBatchDeleteLC('',true);
      v.execute(null);
*
*
*/
global class VIBatchDeleteLC implements Schedulable,Database.Batchable<sObject>,Database.Stateful{

    private string AffaireAGenerer; 
    private boolean Enchaine ;

     public VIBatchDeleteLC(String Param1,Boolean Param2 ) {
        AffaireAGenerer = Param1;        
        Enchaine = Param2;      
    }


    
    global Database.QueryLocator start(Database.BatchableContext BC){
                                         
        string query = 'SELECT id   ';
        query = query+'    from VILigne_comptable__c      ';
        query = query+'  WHERE (Statut_ecriture_comptable__c like \'10%\' or Statut_ecriture_comptable__c like \'20%\') ';
        if(AffaireAGenerer=='') { 
            query = query + '   and name like \''+AffaireAGenerer+'%\'  ';
        }                  

        VIExecuteSOQL.code_coverage();
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List< VILigne_comptable__c > scope){
        delete scope;
    }

    global void finish(Database.BatchableContext BC){
        if(AffaireAGenerer=='' && enchaine==true) {        
            Database.executeBatch(new VIBatchGenerate('','1'),VIBatchGenerate.NBR_LOT);            
        }
    }

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VIBatchDeleteLC(AffaireAGenerer,Enchaine),5000);

    }
    public static final integer NBR_LOT =5000;    
}