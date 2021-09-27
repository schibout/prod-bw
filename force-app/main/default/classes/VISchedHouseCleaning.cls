/*
*
*  We have to delete the logs and the import files that are older than the retention days
*   We also check the consenstency of the periode table
*
*  for running by hand : 
      VISchedHouseCleaning v = new VISchedHouseCleaning();
      v.execute(null);
*
*  for running every day at 22:30
     VISchedHouseCleaning m = new VISchedHouseCleaning();
     String sch = '0 30 22 * * ?';
     String jobID = system.schedule('VISchedHouseCleaning', sch, m);
*
*
*/
global class VISchedHouseCleaning implements Schedulable,Database.Batchable<sObject>,Database.Stateful{

    Global double num_record = 0;
    Global String IDLog ='';    
    
    static final Integer MAX_RECORD = 9990 ;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VISchedHouseCleaning','4 Running','','Start ');
        
        // Check Affaire with a lot elements liés
        VIParametres__c param= [SELECT NB_elements_lies_max__c  
                                  FROM VIParametres__c
                                 WHERE not (name like 'VIParametres%')]; 
//        for(VIAffaire__c aff: [SELECT name, Nom_affaire__c , id
//                                 FROM VIAffaire__c
//                               WHERE Nb_elements_lies__c >:param.NB_elements_lies_max__c]) {
//            VIUtils.LogWrite('VISchedHouseCleaning','3 Error','','Cette affaire a trop d éléments liés '+aff.name+' '+aff.nom_affaire__c);
//        }

        
        // Check periode_comptable
        // We should have at least  1 open periode per country
        map<string, VIPeriode__c>MapPeriode = new  map<string, VIPeriode__c>();
        list<VIPeriode__c>ListPeriode = [SELECT id, name, entite_bw__c, statut__c, Date_de_debut__c , Date_de_fin__c,
                                                Periode_comptable_precedente__r.Date_de_fin__c
                                           FROM VIPeriode__c
                                       ORDER BY entite_bw__c, Date_de_debut__c];
        List<string>ListPeriodeKey = new list<string>();
        for(VIPeriode__c per : ListPeriode) {
            mapPeriode.put(Per.entite_bw__c+per.statut__c.left(2),per);
            listPeriodeKey.add(per.name);
        }
        for(VIEntiteBW__c entite_bw: [SELECT name from VIEntiteBW__c]) {
            if(!mapPeriode.containskey(entite_bw+'20')) {
                VIUtils.LogWrite('VISchedHouseCleaning','3 Error','',label.VIErreur006+' '+entite_bw.name);
            }
        }
        // Vérifier qu'il n'y a que des periodes fermées sous la période ouverte et que des périodes ouvertes au-delà
        // HENRI
                                         
        string query = 'SELECT Nb_jours_retention_import__c, Nb_jours_retention_logs__c ';
        query = query+'   FROM VIParametres__c ';
        query = query+'  WHERE not (name like \'VIParametres%\') ';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<VIParametres__c> scope){
        num_record = 0;
        
        decimal nb = scope[0].Nb_jours_retention_logs__c ; 
        date d = system.today() - integer.valueof(nb) ; 
        
        list<VILog__c>ListLog = [SELECT id 
                                  FROM VILog__c 
                                 WHERE lastModifiedDate<:d
                                 LIMIT :MAX_RECORD];
        num_record = ListLog.size();                                  
        delete ListLog ; 
        
        if(num_record<MAX_RECORD) {
            // delete another table
        }


    }

    global void finish(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VISchedHouseCleaning','1 Normal',IDLog,'End '+num_record);
        // Is there anything else to delete ? 
        if(num_record>MAX_RECORD-10) {
            VISchedHouseCleaning v = new VISchedHouseCleaning();
            v.execute(null);
        }
        
    }

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VISchedHouseCleaning(),10);

    }
}