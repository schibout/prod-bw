//
//   This batch recalculate the Field Ligne_d_affaire_mens_exercice_precedent__c  on each LAM line
//  
//  
// 
/*  for running by hand : 
 VIBatchCalcLAMExerPrec v = new VIBatchCalcLAMExerPrec();
 database.executebatch(v,10);  

*
*  for running every hour at xx:16
     VIBatchCalcLAMExerPrec m = new VIBatchCalcLAMExerPrec();
     String sch = '0 16 * * * ?';
     String jobID = system.schedule('VIBatchCalcLAMExerPrec', sch, m);
*/

global class VIBatchCalcLAMExerPrec implements Database.Batchable<sObject>, Database.Stateful {

    Public Integer num_record = 0; 
    Global String IDLog ='';   
    Global date StartLastMonth ; 
    Global Integer CurrentYear ; 

    

    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        date d1= date.newinstance(system.today().year(),1,1);
        CurrentYear = system.today().year();
        d1 = d1.adddays(-1);
        StartLastMonth = date.newinstance(d1.year(),12,1);        
        
        String     query='SELECT Id,name,Date_ouverture_affaire__c ';
        query = query + '   FROM VIAffaire__c  ';
        query = query + '  WHERE Date_ouverture_affaire__c < '+string.valueof(d1)+' ' ;
        //query = query + '    AND name=\'9751TEST\' ' ;
        
        IDLog=VIUtils.LogWrite('VIBatchCalcLAMExerPrec','4 Running','','Start ');
        
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<VIAffaire__c> scope) {
        
        list<id>ListIdAffaire = new List<id>();
        for(VIAffaire__c aff:scope) {
             ListIdAffaire.add(aff.id);
        }
        Map<id,id>MapLAMDernExercice = new Map<id,id>();

        List<VILigne_d_affaire_mensuelle__c>ListLam = [SELECT id, affaire__c, Periode_comptable__r.date_de_debut__c, 
                                                              Ligne_d_affaire_mens_exercice_precedent__c 
                                                         FROM VILigne_d_affaire_mensuelle__c
                                                        WHERE affaire__c in :ListIdAffaire
                                                     ORDER by affaire__r.name,Periode_comptable__r.date_de_debut__c  ];
        
        for(VILigne_d_affaire_mensuelle__c  lam : ListLam) {
            if(lam.Periode_comptable__r.date_de_debut__c==StartLastMonth) {
                MapLAMDernExercice.put(lam.affaire__c, lam.id);
            }
        }
        for(VILigne_d_affaire_mensuelle__c  lam : ListLam) {
            if(lam.Periode_comptable__r.date_de_debut__c>StartLastMonth && 
               lam.Periode_comptable__r.date_de_debut__c.year() == CurrentYear ) {
                if(MapLAMDernExercice.containskey(lam.affaire__c)) {
                    lam.Ligne_d_affaire_mens_exercice_precedent__c=MapLAMDernExercice.get(lam.affaire__c);
                }
            }    
        }
        update ListLam ;         
        
        num_record = num_record + scope.size();
    }   

    global void finish(Database.BatchableContext BC) {
        IDLog=VIUtils.LogWrite('VIBatchCalcLAMExerPrec','1 Normal',IDLog,'nbr '+num_record);            
    }
}