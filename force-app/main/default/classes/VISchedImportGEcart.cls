/*
*
*  We have to launch the import files 
*
*
*  for running by hand : 
 VISchedImportGEcart v = new VISchedImportGEcart('',false,true);
 v.execute(null);
*
*  for running every hour at xx:16
     VISchedImportGEcart m = new  VISchedImportGEcart();
     String sch = '0 16 * * * ?';
     String jobID = system.schedule(' v', sch, m);
*
*
*/
global class VISchedImportGEcart implements Schedulable,Database.Batchable<sObject>,Database.Stateful{

    Global double num_record = 0;
    Global String IDLog ='';    
    Global Map<string, VICentre_section__c>MapCentre    = new Map<string, VICentre_section__c>();    
    Global Map<string, VIType_de_depense__c>MapDepense  = new Map<string, VIType_de_depense__c>(); 
    Global VIType_de_depense__c tdGAR ; 
    
    
    private string AffaireAGenerer; 
    private boolean Enchaine ;
    private boolean toute ;    
    private Date DateImport ;    
    
     public VISchedImportGEcart(String Param1,Boolean Param2,Boolean Param3,date param4 ) {
        AffaireAGenerer = Param1;        
        Enchaine = Param2;                
        toute = Param3; 
        dateImport = param4;
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VISchedImportGEcart','4 Running','','Start ');

        for(VICentre_section__c centre : [SELECT id, name 
                                            FROM  VICentre_section__c]) {
            MapCentre.put(centre.name.left(3), centre) ;
        }

        for(VIType_de_depense__c depense : [SELECT id, name 
                                              FROM  VIType_de_depense__c]) {
            MapDepense.put(depense.name.left(3), depense) ;
            if(depense.name.left(3)=='GAR') 
                tdGAR=depense ; 
                                                  
        }

        string query = 'SELECT code_Affaire__c, date__c, Centre__c ,Type_de_depense__c ,NB_heures__c ,Montant__c ,Import_Status__c  ';
        query = query+'   FROM int_gecart__c   ';
        query = query+'   WHERE code_affaire__c!=null ';

        if(!toute)
            query = query+'     AND (Import_Status__c =\'1\' or Import_Status__c =null) ';

        query = query+'     AND (code_Affaire__c Like \''+AffaireAGenerer+'%\')  ';
        query = query+'     AND (date__c = '+string.valueof(DateImport).left(10)+')  ';        
        query = query+'   Order by code_affaire__c desc  ';        

        system.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<int_gecart__c > scope){
        num_record = 0;
        list<string>ListErreur = new list<string>();
        list<string>ListIDAffaire = new list<string>();
        for(int_gecart__c  g:scope) {
            ListIDAffaire.add(g.code_affaire__c);
        }    
        map<string, VIligne_affaire__c>MapLa = new map<string, VIligne_affaire__c>();
        for(VIligne_affaire__c la:[SELECT id, name, Centre_Section__r.name , Type_depense__r.name ,
                                          Ecart_C_A_F_Heure__c ,Ecart_C_A_F_MontantD__c ,
                                          Ligne_d_affaire_mensuelle__r.affaire__r.name,
                                          Ligne_d_affaire_mensuelle__r.Periode_comptable__r.date_de_debut__c                                 
                                     FROM VIligne_affaire__c
                               WHERE Ligne_d_affaire_mensuelle__r.affaire__r.name in :ListIDAffaire]) {
            string td = (la.Type_depense__r.name+'   ').left(3);
            string key = la.Ligne_d_affaire_mensuelle__r.affaire__r.name+'-'+la.Centre_Section__r.name.left(3)+'-'+td+'-'+la.Ligne_d_affaire_mensuelle__r.Periode_comptable__r.date_de_debut__c ;
            MapLa.put(key,la); 
        }                       
        map<string, VIligne_d_affaire_mensuelle__c>MapLam = new map<string, VIligne_d_affaire_mensuelle__c>();
        for(VIligne_d_affaire_mensuelle__c lam:[SELECT id, name, 
                                                       Ecart_C_A_F_Heure__c ,Ecart_C_A_F_MontantD__c ,
                                                       affaire__r.name,
                                                       Periode_comptable__r.date_de_debut__c                                 
                                                  FROM VIligne_d_affaire_mensuelle__c
                                                 WHERE affaire__r.name in :ListIDAffaire]) {
            string key = lam.affaire__r.name+'-'+lam.Periode_comptable__r.date_de_debut__c ;
            MapLam.put(key,lam); 
        }                       

        for(int_gecart__c g:scope) {
            string key = g.code_affaire__c+'-'+g.Centre__c+'-'+(g.Type_de_depense__c+'   ').left(3)+'-'+g.date__c;
            if(MapLa.containskey(key)) {
                VIligne_affaire__c la = MapLa.get(key) ;
                la.Ecart_C_A_F_Heure__c      =(g.NB_heures__c==null ? 0 :g.NB_heures__c) ;
                la.Ecart_C_A_F_MontantD__c   =(g.montant__c==null   ? 0 :g.montant__c);
                la.Ecart_C_A_F_MontantD_E__c =(g.montant__c==null   ? 0 :g.montant__c);                
                
            } else {
                VIligne_affaire__c la = new VIligne_affaire__c();
                if(!MapLam.containskey(g.code_affaire__c+'-'+g.date__c)) {
                    listErreur.add('Ecart inconnu'+g.code_affaire__c+'-'+g.date__c);
                    continue ; 
                }
                VIligne_d_affaire_mensuelle__c lam = MapLam.get(g.code_affaire__c+'-'+g.date__c);
                la.Ligne_d_affaire_mensuelle__c=lam.id ;
                la.Centre_Section__c=MapCentre.get(g.Centre__c).id;

                string td = (g.Type_de_depense__c+'   ').left(3);
                la.Type_depense__c  =MapDepense.get(td).id;

                if(la.Type_depense__c==TDGAR.id) {
                    la.Type_de_ligne_d_affaire__c='G';
                } else {
                    la.Type_de_ligne_d_affaire__c='I';
                }

                la.Ecart_C_A_F_Heure__c      =(g.NB_heures__c==null ? 0 :g.NB_heures__c)  ;
                la.Ecart_C_A_F_MontantD__c   =(g.montant__c==null   ? 0 :g.montant__c);
                la.Ecart_C_A_F_MontantD_E__c =(g.montant__c==null   ? 0 :g.montant__c);                

                MapLa.put(key,la); 
            }
            g.Import_Status__c='2';
            
        }    
        upsert MapLa.values();     
        update scope ; 
        if(ListErreur.size()>0) {
            string s = string.join(ListErreur,'\n')+' ....'; 
            VIUtils.LogWrite('VISchedImportGEcart','3 Error',null,s);                
        }

    }

    global void finish(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VISchedImportGEcart','1 Normal',IDLog,'End '+num_record);
        //if(enchaine)
        //    Database.executeBatch(new VIBatchRegenerateLAM(AffaireAGenerer, enchaine), VIBatchRegenerateLAM.NBR_LOT());        
        
    }

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VISchedImportGEcart(AffaireAGenerer, enchaine, toute, DateImport),VISchedImportGEcart.NBR_LOT());
    }

    public static  integer NBR_LOT () {
         VIParametres__c param = VIParametres__c.getInstance(UserInfo.getUserId()); 
         integer i ; 
         if(param.Sans_Calcul_de_PRI__c) {
             i=500 ;
         } else {
             i=1;    
         }
         return i;
    }

}