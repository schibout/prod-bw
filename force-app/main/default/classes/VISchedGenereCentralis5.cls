/*
*
*  Calculation of centralisation 
*
*
*  for running by hand : 
 VISchedGenereCentralis5 v = new VISchedGenereCentralis5();
 v.execute(null);
*
*  for running every day at xx:22
     VISchedGenereCentralis5 m = new VISchedGenereCentralis5();
     String sch = '0 0 22 * * ?';
     String jobID = system.schedule('VISchedGenereCentralis5', sch, m);
*
*
*/
global class VISchedGenereCentralis5 implements Schedulable,Database.Batchable<sObject>,Database.Stateful{

    Global double num_record = 0;
    Global String IDLog ='';   
    Global String entite_bw ='';
    Global Map<date, double>MapTotalPreOuverteHeure = new Map<date, double>();
    Global Map<date, double>MapTotalPreOuverteDebours = new Map<date, double>();
    Global Map<date, double>MapTotalOuverteHeure = new Map<date, double>();
    Global Map<date, double>MapTotalOuverteDebours = new Map<date, double>();
    Global Map<date, double>MapTotalDerniereHeure = new Map<date, double>();
    Global Map<date, double>MapTotalDerniereDebours = new Map<date, double>();
    private VIPeriode__c Periode_PreOuverte ;
    private VIPeriode__c Periode_Ouverte ;
    private VIPeriode__c Periode_derniere ;
    
    
     
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VISchedGenereCentralis5','4 Running','','Start ');
        entite_bw='1';

        
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
        
        delete [select id from VICentralisation__c where source__c='VisionHeures' and date__c=:Periode_PreOuverte.date_de_debut__c];
        delete [select id from VICentralisation__c where source__c='VisionHeuresMontant' and date__c=:Periode_PreOuverte.date_de_debut__c];        
        delete [select id from VICentralisation__c where source__c='VisionHeures' and date__c=:Periode_Ouverte.date_de_debut__c];
        delete [select id from VICentralisation__c where source__c='VisionHeuresMontant' and date__c=:Periode_Ouverte.date_de_debut__c];        
        delete [select id from VICentralisation__c where source__c='VisionHeures' and date__c=:Periode_derniere.date_de_debut__c];
        delete [select id from VICentralisation__c where source__c='VisionHeuresMontant' and date__c=:Periode_derniere.date_de_debut__c];        
        
        string query = 'SELECT Affaire__c ,Date__c , Heures__c ,debours__c  , ';
        query = query+'        Periode_comptable__c,Periode_comptable__r.date_de_debut__c     ';
        query = query+'   FROM VIpointage__c  ';
        query = query+'  WHERE (Periode_comptable__c =\''+Periode_PreOuverte.id+'\' or Periode_comptable__c =\''+Periode_Ouverte.id+'\' or Periode_comptable__c =\''+Periode_derniere.id+'\') ';
        query = query+'   Order by Affaire__c asc  ';     

        system.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<VIpointage__c > scope){

        for(VIpointage__c po:scope) {
            if(po.Periode_comptable__c==Periode_Derniere.id ) {
                if(!MapTotalDerniereHeure.containskey(po.Periode_comptable__r.date_de_debut__c)) {
                    MapTotalDerniereHeure.put(po.Periode_comptable__r.date_de_debut__c,0);
                    MapTotalDerniereDebours.put(po.Periode_comptable__r.date_de_debut__c,0);                
                }
                MapTotalDerniereHeure.put(po.Periode_comptable__r.date_de_debut__c,MapTotalDerniereHeure.get(po.Periode_comptable__r.date_de_debut__c) + (po.heures__c==null ? 0 :po.heures__c)  );
                MapTotalDerniereDebours.put(po.Periode_comptable__r.date_de_debut__c,MapTotalDerniereDebours.get(po.Periode_comptable__r.date_de_debut__c) + (po.debours__c==null ? 0 :po.debours__c) );            
            }
            if(po.Periode_comptable__c==Periode_ouverte.id ) {
                if(!MapTotalouverteHeure.containskey(po.Periode_comptable__r.date_de_debut__c)) {
                    MapTotalouverteHeure.put(po.Periode_comptable__r.date_de_debut__c,0);
                    MapTotalouverteDebours.put(po.Periode_comptable__r.date_de_debut__c,0);                
                }
                MapTotalouverteHeure.put(po.Periode_comptable__r.date_de_debut__c,MapTotalouverteHeure.get(po.Periode_comptable__r.date_de_debut__c) + (po.heures__c==null ? 0 :po.heures__c)  );
                MapTotalouverteDebours.put(po.Periode_comptable__r.date_de_debut__c,MapTotalouverteDebours.get(po.Periode_comptable__r.date_de_debut__c) + (po.debours__c==null ? 0 :po.debours__c) );            
            }
            if(po.Periode_comptable__c==Periode_Preouverte.id ) {
                if(!MapTotalPreouverteHeure.containskey(po.Periode_comptable__r.date_de_debut__c)) {
                    MapTotalPreouverteHeure.put(po.Periode_comptable__r.date_de_debut__c,0);
                    MapTotalPreouverteDebours.put(po.Periode_comptable__r.date_de_debut__c,0);                
                }
                MapTotalPreouverteHeure.put(po.Periode_comptable__r.date_de_debut__c,MapTotalPreouverteHeure.get(po.Periode_comptable__r.date_de_debut__c) + (po.heures__c==null ? 0 :po.heures__c)  );
                MapTotalPreouverteDebours.put(po.Periode_comptable__r.date_de_debut__c,MapTotalPreouverteDebours.get(po.Periode_comptable__r.date_de_debut__c) + (po.debours__c==null ? 0 :po.debours__c) );            
            }
        }

    }

    global void finish(Database.BatchableContext BC){
        list< VICentralisation__c >ListInsertCentralisation = new list< VICentralisation__c >();
        for(date d:MapTotalDerniereHeure.keyset()) {
            
             VICentralisation__c c = new VICentralisation__c (
                 compte__c=null ,
                 PR_PV__c =null,
                 date__c=d,
                 montant__c=MapTotalDerniereHeure.get(d) *(-1),
                 source__c='VisionHeures'
             );
            ListInsertCentralisation.add(c);

            VICentralisation__c c1 = new VICentralisation__c (
                 compte__c=null ,
                 PR_PV__c =null,
                 date__c=d,
                 montant__c=MapTotalDerniereDebours.get(d) ,
                 source__c='VisionHeuresMontant'
             );
            //ListInsertCentralisation.add(c1);
        }
        for(date d:MapTotalOuverteHeure.keyset()) {
            
             VICentralisation__c c = new VICentralisation__c (
                 compte__c=null ,
                 PR_PV__c =null,
                 date__c=d,
                 montant__c=MapTotalOuverteHeure.get(d) *(-1),
                 source__c='VisionHeures'
             );
            ListInsertCentralisation.add(c);

            VICentralisation__c c1 = new VICentralisation__c (
                 compte__c=null ,
                 PR_PV__c =null,
                 date__c=d,
                 montant__c=MapTotalOuverteDebours.get(d),
                 source__c='VisionHeuresMontant'
             );
            //ListInsertCentralisation.add(c1);
        }
        for(date d:MapTotalPreOuverteHeure.keyset()) {
            
             VICentralisation__c c = new VICentralisation__c (
                 compte__c=null ,
                 PR_PV__c =null,
                 date__c=d,
                 montant__c=MapTotalPreOuverteHeure.get(d) *(-1),
                 source__c='VisionHeures'
             );
            ListInsertCentralisation.add(c);

            VICentralisation__c c1 = new VICentralisation__c (
                 compte__c=null ,
                 PR_PV__c =null,
                 date__c=d,
                 montant__c=MapTotalPreOuverteDebours.get(d),
                 source__c='VisionHeuresMontant'
             );
            //ListInsertCentralisation.add(c1);
        }
        insert ListInsertCentralisation ; 
                
        IDLog=VIUtils.LogWrite('VISchedGenereCentralis5','1 Normal',IDLog,'End '+num_record);
       // Database.executeBatch(new VIBatchCalcTDBGazelle('1'),VIBatchCalcTDBGazelle.NBR_LOT ) ; //VIBatchCalcTDBGazelle.NBR_LOT()); 
        
    }

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VISchedGenereCentralis5(),NBR_LOT());
    }
    public static  integer NBR_LOT () {
         integer i=500 ; 
         return i;
    }

    
    
}