/*
*
*  Calculation of centralisation  
*
*
*  for running by hand : 
 VISchedGenereCentralis1 v = new VISchedGenereCentralis1();
 v.execute(null);
*
*  for running every day at xx:22
     VISchedGenereCentralis1 m = new VISchedGenereCentralis1();
     String sch = '0 0 22 * * ?';
     String jobID = system.schedule('VISchedGenereCentralis1', sch, m);
*
*
*/
global class VISchedGenereCentralis1 implements Schedulable,Database.Batchable<sObject>,Database.Stateful{

    Global double num_record = 0;
    Global String IDLog ='';   
    Global String entite_bw ='';
    Global Map<String, double>MapTotalDerniere = new Map<String, double>();
    Global Map<String, double>MapTotalOuverte = new Map<String, double>();
    Global Map<String, double>MapTotalPreOuverte = new Map<String, double>();    
    private VIPeriode__c Periode_derniere ;
    private VIPeriode__c Periode_Ouverte ;    
    private VIPeriode__c Periode_PreOuverte ;    
    
    Private Map<string, VICompte_general__c>MapCompte    = new Map<string, VICompte_general__c>();    
    
     
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VISchedGenereCentralis1','4 Running','','Start ');
        entite_bw='1';

        for(VICompte_general__c compte : [SELECT id, name , Alimentation_PR_PV__c 
                                            FROM  VICompte_general__c]) {
            MapCompte.put(compte.name, compte) ;
        }
        
        Periode_PreOuverte= [SELECT id,date_de_debut__c, date_de_fin__c, entite_bw__c
                            FROM VIPeriode__c
                           WHERE statut__c=:VIConstant.PERIODE_PREOUVERTE
                             AND entite_bw__c=:entite_bw];
        Periode_Ouverte= [SELECT id,date_de_debut__c, date_de_fin__c, entite_bw__c
                            FROM VIPeriode__c
                           WHERE statut__c=:VIConstant.PERIODE_OUVERTE
                             AND entite_bw__c=:entite_bw];
        Periode_derniere= [SELECT id,date_de_debut__c, date_de_fin__c, entite_bw__c
                            FROM VIPeriode__c
                           WHERE statut__c=:VIConstant.PERIODE_DERNIERE
                             AND entite_bw__c=:entite_bw];
        // le temps de tester 
/*        Periode_derniere= [SELECT id,date_de_debut__c, date_de_fin__c, entite_bw__c
                            FROM VIPeriode__c
                           WHERE name='202105BW FRA'
                             AND entite_bw__c=:entite_bw];
*/
        delete [select id from VICentralisation__c where source__c='VisionLC' and date__c=:Periode_Preouverte.date_de_debut__c];        
        delete [select id from VICentralisation__c where source__c='VisionLC' and date__c=:Periode_ouverte.date_de_debut__c];
        delete [select id from VICentralisation__c where source__c='VisionLC' and date__c=:Periode_derniere.date_de_debut__c];
        
        string query = 'SELECT Affaire__c ,Centre__c ,CompteComptable_local__r.name, Date_ecriture__c ,Montant_avec_signe__c , ';
        query = query+'        Periode_comptable__c     ';
        query = query+'   FROM VILigne_comptable__c  ';
        query = query+'  WHERE (Periode_comptable__c =\''+Periode_PreOuverte.id+'\' or Periode_comptable__c =\''+Periode_Ouverte.id+'\' or Periode_comptable__c =\''+Periode_derniere.id+'\') ';
        query = query+'    and Statut_ecriture_comptable__c in ( \'40\') ';   //\'10\',\'20\', \'30\',
        //query = query+'        and type_de_depense__c in ( \'AVT\') '; 
        if(!Test.isRunningTest())
            query = query+'    and CompteComptable_local__r.name!=\'473000\'  ';
        query = query+'   Order by Affaire__c asc  ';     

        system.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<VILigne_comptable__c > scope){

        for(VILigne_comptable__c lc:scope) {
            if(lc.Date_ecriture__c>=Periode_Derniere.date_de_debut__c && lc.Date_ecriture__c<=Periode_Derniere.date_de_fin__c) {
                if(!MapTotalDerniere.containskey(lc.CompteComptable_local__r.name)) {
                    MapTotalDerniere.put(lc.CompteComptable_local__r.name,0);
                }
                MapTotalDerniere.put(lc.CompteComptable_local__r.name,MapTotalDerniere.get(lc.CompteComptable_local__r.name) + lc.Montant_avec_signe__c) ;             
            }
            if(lc.Date_ecriture__c>=Periode_Ouverte.date_de_debut__c && lc.Date_ecriture__c<=Periode_Ouverte.date_de_fin__c) {
                if(!MapTotalOuverte.containskey(lc.CompteComptable_local__r.name)) {
                    MapTotalOuverte.put(lc.CompteComptable_local__r.name,0);
                }
                MapTotalOuverte.put(lc.CompteComptable_local__r.name,MapTotalOuverte.get(lc.CompteComptable_local__r.name) + lc.Montant_avec_signe__c) ;             
            }
            if(lc.Date_ecriture__c>=Periode_PreOuverte.date_de_debut__c && lc.Date_ecriture__c<=Periode_PreOuverte.date_de_fin__c) {
                if(!MapTotalPreOuverte.containskey(lc.CompteComptable_local__r.name)) {
                    MapTotalPreOuverte.put(lc.CompteComptable_local__r.name,0);
                }
                MapTotalPreOuverte.put(lc.CompteComptable_local__r.name,MapTotalPreOuverte.get(lc.CompteComptable_local__r.name) + lc.Montant_avec_signe__c) ;             
            }
        }
    }

    global void finish(Database.BatchableContext BC){
        list< VICentralisation__c >ListInsertCentralisation = new list< VICentralisation__c >();
        for(string s:MapTotalDerniere.keyset()) {
            
             string PRPV='' ;
             if(MapCompte.containskey(s)) {
                PRPV=MapCompte.get(s).Alimentation_PR_PV__c ;
             }
             double sens = - 1;
             if(PRPV=='PV')
                 sens=1; 

             VICentralisation__c c = new VICentralisation__c (
                 compte__c=s ,
                 PR_PV__c =PRPV,
                 date__c=periode_derniere.date_de_debut__c,
                 montant__c=MapTotalDerniere.get(s) * sens,
                 source__c='VisionLC'
             );
            ListInsertCentralisation.add(c);
        }
        for(string s:MapTotalOuverte.keyset()) {
             string PRPV='' ;
             if(MapCompte.containskey(s)) {
                PRPV=MapCompte.get(s).Alimentation_PR_PV__c ;
             }
             double sens = - 1;
             if(PRPV=='PV')
                 sens=1; 
            
             VICentralisation__c c = new VICentralisation__c (
                 compte__c=s ,
                 PR_PV__c =PRPV,                 
                 date__c=periode_ouverte.date_de_debut__c,
                 montant__c=MapTotalOuverte.get(s) * sens,
                 source__c='VisionLC'
             );
            ListInsertCentralisation.add(c);
        }
        for(string s:MapTotalPreOuverte.keyset()) {
             string PRPV='' ;
             if(MapCompte.containskey(s)) {
                PRPV=MapCompte.get(s).Alimentation_PR_PV__c ;
             }
             double sens = - 1;
             if(PRPV=='PV')
                 sens=1; 
            
             VICentralisation__c c = new VICentralisation__c (
                 compte__c=s ,
                 PR_PV__c =PRPV,                 
                 date__c=periode_Preouverte.date_de_debut__c,
                 montant__c=MapTotalpreOuverte.get(s) * sens,
                 source__c='VisionLC'
             );
            ListInsertCentralisation.add(c);
        }
        insert ListInsertCentralisation ; 
        
        
        
        IDLog=VIUtils.LogWrite('VISchedGenereCentralis1','1 Normal',IDLog,'End '+num_record);
        Database.executeBatch(new VISchedGenereCentralis2(),VISchedGenereCentralis2.NBR_LOT()); 
    }

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VISchedGenereCentralis1(),NBR_LOT()); // Il faut laisser 1 pour la 1ère fois
    }
    public static  integer NBR_LOT () {
         integer i=500 ; 
         return i;
    }

    
    
}