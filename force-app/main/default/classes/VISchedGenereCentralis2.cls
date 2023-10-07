/*
*
*  Calculation of centralisation 
*
*
*  for running by hand : 
 VISchedGenereCentralis2 v = new VISchedGenereCentralis2();
 v.execute(null);
*
*  for running every day at xx:22
     VISchedGenereCentralis2 m = new VISchedGenereCentralis2();
     String sch = '0 0 22 * * ?';
     String jobID = system.schedule('VISchedGenereCentralis2', sch, m);
*
*
*/
global class VISchedGenereCentralis2 implements Schedulable,Database.Batchable<sObject>,Database.Stateful{

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
        IDLog=VIUtils.LogWrite('VISchedGenereCentralis2','4 Running','','Start ');
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
/*
        Periode_derniere= [SELECT id,date_de_debut__c, date_de_fin__c, entite_bw__c
                            FROM VIPeriode__c
                           WHERE name='202105BW FRA'
                             AND entite_bw__c=:entite_bw];
 */       
        
        delete [select id from VICentralisation__c where source__c='VisionAC' and date__c=:Periode_Preouverte.date_de_debut__c];
        delete [select id from VICentralisation__c where source__c='VisionAC' and date__c=:Periode_ouverte.date_de_debut__c];
        delete [select id from VICentralisation__c where source__c='VisionAC' and date__c=:Periode_derniere.date_de_debut__c];
        
        string query = 'SELECT Affaire__c ,CompteGeneral__c , ComptabiliseD__c  , ';
        query = query+'        Periode_comptable__c     ';
        query = query+'   FROM VIAchat__c  ';
        query = query+'  WHERE (Periode_comptable__c =\''+Periode_PreOuverte.id+'\' or Periode_comptable__c =\''+Periode_Ouverte.id+'\' or Periode_comptable__c =\''+Periode_derniere.id+'\') ';
        query = query+'    and CompteGeneral__c not in (\'473000\' , \'920100\', \'911000\', \'915000\', \'916000\')  '; 

        query = query+'   Order by Affaire__c asc  ';     

        system.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<VIAchat__c > scope){

        for(VIAchat__c ac:scope) {
            if(ac.Periode_comptable__c==Periode_Derniere.id ) {
                if(!MapTotalDerniere.containskey(ac.CompteGeneral__c)) {
                    MapTotalDerniere.put(ac.CompteGeneral__c,0);
                }
                MapTotalDerniere.put(ac.CompteGeneral__c,MapTotalDerniere.get(ac.CompteGeneral__c) + ac.ComptabiliseD__c) ;             
            }
            if(ac.Periode_comptable__c==Periode_Ouverte.id) {
                if(!MapTotalOuverte.containskey(ac.CompteGeneral__c)) {
                    MapTotalOuverte.put(ac.CompteGeneral__c,0);
                }
                MapTotalOuverte.put(ac.CompteGeneral__c,MapTotalOuverte.get(ac.CompteGeneral__c) + ac.ComptabiliseD__c) ;             
            }
            if(ac.Periode_comptable__c==Periode_PreOuverte.id) {
                if(!MapTotalPreOuverte.containskey(ac.CompteGeneral__c)) {
                    MapTotalPreOuverte.put(ac.CompteGeneral__c,0);
                }
                MapTotalPreOuverte.put(ac.CompteGeneral__c,MapTotalPreOuverte.get(ac.CompteGeneral__c) + ac.ComptabiliseD__c) ;             
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
                 montant__c=MapTotalDerniere.get(s) * (-1),
                 source__c='VisionAC'
             );
            ListInsertCentralisation.add(c);
        }
        for(string s:MapTotalOuverte.keyset()) {
             string PRPV='' ;
             if(MapCompte.containskey(s)) {
                PRPV=MapCompte.get(s).Alimentation_PR_PV__c ;
             }
             VICentralisation__c c = new VICentralisation__c (
                 compte__c=s ,
                 PR_PV__c =PRPV,                 
                 date__c=periode_ouverte.date_de_debut__c,
                 montant__c=MapTotalOuverte.get(s) * (-1),
                 source__c='VisionAC'
             );
            ListInsertCentralisation.add(c);
        }
        for(string s:MapTotalPreOuverte.keyset()) {
             string PRPV='' ;
             if(MapCompte.containskey(s)) {
                PRPV=MapCompte.get(s).Alimentation_PR_PV__c ;
             }
             VICentralisation__c c = new VICentralisation__c (
                 compte__c=s ,
                 PR_PV__c =PRPV,                 
                 date__c=periode_Preouverte.date_de_debut__c,
                 montant__c=MapTotalPreOuverte.get(s) * (-1),
                 source__c='VisionAC'
             );
            ListInsertCentralisation.add(c);
        }
        insert ListInsertCentralisation ; 
        
        
        
        IDLog=VIUtils.LogWrite('VISchedGenereCentralis2','1 Normal',IDLog,'End '+num_record);
        Database.executeBatch(new VISchedGenereCentralis3(),VISchedGenereCentralis3.NBR_LOT()); 
        
    }

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VISchedGenereCentralis2(),NBR_LOT());
    }
    public static  integer NBR_LOT () {
         integer i=500 ; 
         return i;
    }

    
    
}