/*
*
*  Calculation of centralisation 
*
*
*  for running by hand : 
 VISchedGenereCentralis3 v = new VISchedGenereCentralis3();
 v.execute(null);
*
*  for running every day at xx:22
     VISchedGenereCentralis3 m = new VISchedGenereCentralis3();
     String sch = '0 0 22 * * ?';
     String jobID = system.schedule('VISchedGenereCentralis3', sch, m);
*
*
*/
global class VISchedGenereCentralis3 implements Schedulable,Database.Batchable<sObject>,Database.Stateful{

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
        IDLog=VIUtils.LogWrite('VISchedGenereCentralis3','4 Running','','Start ');
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
        
        delete [select id from VICentralisation__c where source__c='VisionFAC' and date__c=:Periode_Preouverte.date_de_debut__c];
        delete [select id from VICentralisation__c where source__c='VisionFAC' and date__c=:Periode_ouverte.date_de_debut__c];
        delete [select id from VICentralisation__c where source__c='VisionFAC' and date__c=:Periode_derniere.date_de_debut__c];
        
        string query = 'SELECT Affaire__c ,Compte_General__r.name , Montant_ht__c  , ';
        query = query+'        Periode_comptable__c     ';
        query = query+'   FROM VIfacture__c  ';
        query = query+'  WHERE (Periode_comptable__c =\''+Periode_PreOuverte.id+'\' or Periode_comptable__c =\''+Periode_Ouverte.id+'\' or Periode_comptable__c =\''+Periode_derniere.id+'\') ';
        query = query+'    AND Compte_general__r.name =\'473000\' ';
        //query = query+'    AND affaire__r.type_imputation__c =\'4\' ';        
        query = query+'   Order by Affaire__c asc  ';     

        system.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<VIfacture__c > scope){

        for(VIFacture__c fac:scope) {
            double mt = (fac.Montant_ht__c==null ? 0 : fac.Montant_ht__c);
            if(fac.Periode_comptable__c==Periode_Derniere.id ) {
                if(!MapTotalDerniere.containskey(fac.Compte_General__r.name)) {
                    MapTotalDerniere.put(fac.Compte_General__r.name,0);
                }
                MapTotalDerniere.put(fac.Compte_General__r.name,MapTotalDerniere.get(fac.Compte_General__r.name) + mt ) ;             
            }
            if(fac.Periode_comptable__c==Periode_Ouverte.id) {
                if(!MapTotalOuverte.containskey(fac.Compte_General__r.name)) {
                    MapTotalOuverte.put(fac.Compte_General__r.name,0);
                }
                MapTotalOuverte.put(fac.Compte_General__r.name,MapTotalOuverte.get(fac.Compte_General__r.name) + mt) ;             
            }
            if(fac.Periode_comptable__c==Periode_PreOuverte.id) {
                if(!MapTotalPreOuverte.containskey(fac.Compte_General__r.name)) {
                    MapTotalPreOuverte.put(fac.Compte_General__r.name,0);
                }
                MapTotalPreOuverte.put(fac.Compte_General__r.name,MapTotalPreOuverte.get(fac.Compte_General__r.name) + mt) ;             
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
                 source__c='VisionFAC'
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
                 source__c='VisionFAC'
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
                 source__c='VisionFAC'
             );
            ListInsertCentralisation.add(c);
        }
        insert ListInsertCentralisation ; 
                
        IDLog=VIUtils.LogWrite('VISchedGenereCentralis3','1 Normal',IDLog,'End '+num_record);
        Database.executeBatch(new VISchedGenereCentralis4(),VISchedGenereCentralis4.NBR_LOT()); 
        
    }

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VISchedGenereCentralis3(),NBR_LOT());
    }
    public static  integer NBR_LOT () {
         integer i=500 ; 
         return i;
    }

    
    
}