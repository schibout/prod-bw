/*
*
*  Calculation of centralisation 
*
*
*  for running by hand : 
 VISchedGenereCentralis4 v = new VISchedGenereCentralis4();
 v.execute(null);
*
*  for running every day at xx:22
     VISchedGenereCentralis4 m = new VISchedGenereCentralis4();
     String sch = '0 0 22 * * ?';
     String jobID = system.schedule('VISchedGenereCentralis4', sch, m);
*
*
*/
global class VISchedGenereCentralis4 implements Schedulable,Database.Batchable<sObject>,Database.Stateful{

    Global double num_record = 0;
    Global String IDLog ='';   
    Global String entite_bw ='';
    Global Map<String, double>MapTotalDerniere = new Map<String, double>();
    Global Map<String, double>MapTotalOuverte = new Map<String, double>();
    Global Map<String, double>MapTotalPreOuverte = new Map<String, double>();
    private VIPeriode__c Periode_PreOuverte ;
    private VIPeriode__c Periode_Ouverte ;
    private VIPeriode__c Periode_derniere ;
    
    Private Map<string, VICompte_general__c>MapCompte    = new Map<string, VICompte_general__c>();    
    
     
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VISchedGenereCentralis4','4 Running','','Start ');
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
        
        delete [select id from VICentralisation__c where source__c='VisionECR' and date__c=:Periode_Preouverte.date_de_debut__c];
        delete [select id from VICentralisation__c where source__c='VisionECR' and date__c=:Periode_ouverte.date_de_debut__c];
        delete [select id from VICentralisation__c where source__c='VisionECR' and date__c=:Periode_derniere.date_de_debut__c];
        
        string query = 'SELECT Affaire__c ,CompteComptable_local__r.name , Montant_avec_signe__c   , ';
        query = query+'        Periode_comptable__c     ';
        query = query+'   FROM VILigne_Comptable__c  ';
        query = query+'  WHERE (Periode_comptable__c =\''+Periode_PreOuverte.id+'\' or Periode_comptable__c =\''+Periode_Ouverte.id+'\' or Periode_comptable__c =\''+Periode_derniere.id+'\') ';
        query = query+'    AND CompteComptable_local__r.name = \'473000\' ';
        query = query+'    AND Statut_ecriture_comptable__c in (  \'40\') ';  //\'10\',
        query = query+'    AND libelle__c != \'FAE LOC\'  ';          
        query = query+'   Order by Affaire__c asc  ';     

        system.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<VILigne_Comptable__c > scope){

        for(VILigne_Comptable__c lc:scope) {
            double mt = (lc.Montant_avec_signe__c==null ? 0 : lc.Montant_avec_signe__c);
            if(lc.Periode_comptable__c==Periode_Derniere.id ) {
                if(!MapTotalDerniere.containskey(lc.CompteComptable_local__r.name)) {
                    MapTotalDerniere.put(lc.CompteComptable_local__r.name,0);
                }
                MapTotalDerniere.put(lc.CompteComptable_local__r.name,MapTotalDerniere.get(lc.CompteComptable_local__r.name) + mt ) ;             
            }
            if(lc.Periode_comptable__c==Periode_Ouverte.id) {
                if(!MapTotalOuverte.containskey(lc.CompteComptable_local__r.name)) {
                    MapTotalOuverte.put(lc.CompteComptable_local__r.name,0);
                }
                MapTotalOuverte.put(lc.CompteComptable_local__r.name,MapTotalOuverte.get(lc.CompteComptable_local__r.name) + mt) ;             
            }
            if(lc.Periode_comptable__c==Periode_PreOuverte.id) {
                if(!MapTotalPreOuverte.containskey(lc.CompteComptable_local__r.name)) {
                    MapTotalPreOuverte.put(lc.CompteComptable_local__r.name,0);
                }
                MapTotalPreOuverte.put(lc.CompteComptable_local__r.name,MapTotalPreOuverte.get(lc.CompteComptable_local__r.name) + mt) ;             
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
             VICentralisation__c c = new VICentralisation__c (
                 compte__c=s ,
                 PR_PV__c =PRPV,
                 date__c=periode_derniere.date_de_debut__c,
                 montant__c=MapTotalDerniere.get(s) ,
                 source__c='VisionECR'
             );
            ListInsertCentralisation.add(c);
        }
        for(string s:MapTotalOuverte.keyset()) {
             string PRPV='' ;
             if(MapCompte.containskey(s)) {
                PRPV=MapCompte.get(s).Alimentation_PR_PV__c ;
             }
             VICentralisation__c c = new VICentralisation__c (
                 compte__c='473000' ,
                 PR_PV__c =PRPV,                 
                 date__c=periode_ouverte.date_de_debut__c,
                 montant__c=MapTotalOuverte.get(s) ,
                 source__c='VisionECR'
             );
            ListInsertCentralisation.add(c);
        }
        for(string s:MapTotalPreOuverte.keyset()) {
             string PRPV='' ;
             if(MapCompte.containskey(s)) {
                PRPV=MapCompte.get(s).Alimentation_PR_PV__c ;
             }
             VICentralisation__c c = new VICentralisation__c (
                 compte__c='473000' ,
                 PR_PV__c =PRPV,                 
                 date__c=periode_Preouverte.date_de_debut__c,
                 montant__c=MapTotalPreOuverte.get(s) ,
                 source__c='VisionECR'
             );
            ListInsertCentralisation.add(c);
        }
        insert ListInsertCentralisation ; 
                
        IDLog=VIUtils.LogWrite('VISchedGenereCentralis4','1 Normal',IDLog,'End '+num_record);
        Database.executeBatch(new VISchedGenereCentralis5(),VISchedGenereCentralis5.NBR_LOT()); 
        
    }

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VISchedGenereCentralis4(),NBR_LOT());
    }
    public static  integer NBR_LOT () {
         integer i=500 ; 
         return i;
    }

    
    
}