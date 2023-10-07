//
//   This batch recalculate the line of Tdb Gazelle
//  
//  
// 
/*  for running by hand : 
 VIBatchCalcTDBGazelle v = new VIBatchCalcTDBGazelle('1');
 database.executebatch(v,VIBatchCalcTDBGazelle.NBR_LOT);  

*
*  for running every hour at xx:16
     VIBatchCalcTDBGazelle m = new VIBatchCalcTDBGazelle('1');
     String sch = '0 16 * * * ?';
     String jobID = system.schedule('VIBatchCalcTDBGazelle', sch, m);
*/

global class VIBatchCalcTDBGazelle implements Database.Batchable<sObject>, Database.Stateful {

    Public Integer num_record = 0; 
    Global String IDLog ='';   
    Global date StartExercise ; 
    Global Integer CurrentYear ; 
    private string Entite_bw ;
    private VIPeriode__c PeriodeOuverte ;
    
     public VIBatchCalcTDBGazelle(String Param2 ) {
        Entite_bw = Param2;                
    }

    

    global Database.QueryLocator start(Database.BatchableContext BC) {

        PeriodeOuverte= [SELECT id,date_de_debut__c, date_de_fin__c, entite_bw__c,name
                           FROM VIPeriode__c
                          WHERE statut__c=:VIConstant.PERIODE_OUVERTE
                            AND entite_bw__c=:entite_bw];
        
        StartExercise=date.newinstance(PeriodeOuverte.date_de_debut__c.year(),1,1);
        
        
        String     query='SELECT Id,name,Date_ouverture_affaire__c,date_de_sav_reelle__c, date_max_mouvement__c, ';
        query = query + '        Backlog_Annee_1__c ,Marge_indus_Backlog_Annee_1__c   ';
        query = query + '   FROM VIAffaire__c  ';        
        query = query + '  WHERE Date_ouverture_affaire__c <='+string.valueof(PeriodeOuverte.date_de_fin__c).left(10) ;
        query = query + '    AND (Type_Imputation__c =\'4\' ) ' ; 
       // query = query + '    AND name in (\'B85837\') ';
        system.debug('query '+query); 
        IDLog=VIUtils.LogWrite('VIBatchCalcTDBGazelle','4 Running','','Start ');
        
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<VIAffaire__c> scope) {
        
        list<id>ListIdAffaire = new List<id>();
        list<id>ListIdAffaire1 = new List<id>();
        
        Date StartExercise=date.newinstance(PeriodeOuverte.date_de_debut__c.year(),1,1); 
        
        for(VIAffaire__c aff:scope) {
            ListIdAffaire.add(aff.id);

            if(aff.date_de_sav_reelle__c==null || aff.Backlog_Annee_1__c!=null || aff.Marge_indus_Backlog_Annee_1__c!=null || aff.date_de_sav_reelle__c>=StartExercise )
                ListIdAffaire1.add(aff.id);

        }

        delete [select id from VITdb_Gazelle__c  where affaire__c in :ListIdAffaire and Periode_comptable__c =:PeriodeOuverte.id];

        // We need to retrieve all the Pointage and Achat done during the exercice. If there is no, 
        // the affaire can be missed

        Map<string,ViPointage__c>MapPointage = new  Map<string,ViPointage__c>();
        for(VIpointage__c po:[SELECT affaire__c
                                 FROM VIPointage__c
                                WHERE affaire__c in :ListIdAffaire
                                  AND date_comptabilisation__c>=:StartExercise
                                  AND date_comptabilisation__c<=:PeriodeOuverte.date_de_fin__c]) {
            if(!MapPointage.containskey(po.affaire__c))
                MapPointage.put(po.affaire__c, po);
        }
        
        Map<string,ViAchat__c>MapAchat = new  Map<string,ViAchat__c>();
        for(VIAchat__c ac:[SELECT affaire__c
                             FROM VIAchat__c
                            WHERE affaire__c in :ListIdAffaire
                              AND date__c>=:StartExercise
                              AND date__c<=:PeriodeOuverte.date_de_fin__c]) {
            if(!MapAchat.containskey(ac.affaire__c))
                MapAchat.put(ac.affaire__c, ac);
        }
        
        Map<string,ViAvenant__c>MapAvenant = new  Map<string,ViAvenant__c>();
        Map<string,ViAvenant__c>MapAvenantAnnulation = new  Map<string,ViAvenant__c>();        
        for(VIAvenant__c av:[SELECT affaire__c, annulation_complete__c
                               FROM VIAvenant__c
                              WHERE affaire__c in :ListIdAffaire
                                AND date__c>=:StartExercise
                                AND date__c<=:PeriodeOuverte.date_de_fin__c
                                AND (PV__c!=0 OR Debours__c !=0	)]) {
            if(!MapAvenant.containskey(av.affaire__c))
                MapAvenant.put(av.affaire__c, av);
                                    
            if(av.annulation_complete__c)  
                MapAvenantAnnulation.put(av.affaire__c, av);

        }        
        
        Map<string,ViFacture__c>MapFacture = new  Map<string,ViFacture__c>();
        for(VIFacture__c fac:[SELECT affaire__c
                               FROM VIFacture__c
                              WHERE affaire__c in :ListIdAffaire
                                AND date__c>=:StartExercise
                                AND date__c<=:PeriodeOuverte.date_de_fin__c
                                AND type__c!='RGC']) {
            if(!MapFacture.containskey(fac.affaire__c))
                MapFacture.put(fac.affaire__c, fac);
        }
        
        Map<string,VILigne_comptable__c >MapLC = new  Map<string,VILigne_comptable__c >();
        for(VILigne_comptable__c  lc:[SELECT affaire__c
                                        FROM VILigne_comptable__c 
                                       WHERE affaire__c in :ListIdAffaire
                                         AND Date_ecriture__c >=:StartExercise
                                         AND Date_ecriture__c <=:PeriodeOuverte.date_de_fin__c]) {
            if(!MapLC.containskey(lc.affaire__c))
                MapLC.put(lc.affaire__c, lc);
        }
        
        
        for(string id:ListIdAffaire) {
             if(MapPointage.containskey(id) || MapAchat.containskey(id) || MapAvenant.containskey(id) || MapFacture.containskey(id) || MapLC.containskey(id) ) 
                 ListIdAffaire1.add(id);
        }


        
        map<Id, VITdb_Gazelle__c>MapTdb = new map<Id, VITdb_Gazelle__c>();
        Map<id,VIAffaire__c>MapAffaire = new Map<id,VIAffaire__c>();
        for(VIAffaire__c aff: [SELECT id, name, Backlog_Annee_1__c , Marge_indus_Backlog_Annee_1__c  ,date_de_sav_reelle__c
                                 FROM VIAffaire__c
                               WHERE id in :ListIDaffaire1]) {
            VITdb_Gazelle__c tdb = new VITdb_Gazelle__c (Affaire__c=aff.id,
                                                         Periode_comptable__c =PeriodeOuverte.id,
                                                         PV_Devis__c =0,
                                                         Marge_indus_devis__c =0,
                                                         Ajustement_Marge_indus__c=0,
                                                        CA_avancement_annee__c =0,
                                                        Marge_indus_avancement__c =0);
           MapTdb.put(aff.id,tdb) ;
           MapAffaire.put(aff.id,aff);
        }
        for(VIAvenant__c ave: [SELECT id, Affaire__c, PV__c , PRI__c 
                                 FROM VIAvenant__c
                                WHERE affaire__c in :ListIDaffaire1
                                  AND Statut_avenant__c=:VIConstant.AVENANT_EN_COURS
                                  AND Date__c>=:StartExercise
                                  AND date__c<=:PeriodeOuverte.date_de_fin__c
                                  AND (PV__c!=0 OR Debours__c !=0	)]) {
            VITdb_Gazelle__c tdb=MapTdb.get(ave.affaire__c);
            tdb.PV_Devis__c          = tdb.PV_Devis__c + (ave.PV__c==null ? 0 : ave.PV__c);
            MapTdb.put(ave.affaire__c,tdb) ;
        }

        // Ok, on les lit tous, mais on ne stocke que le dernier
        for(VILigne_d_affaire_mensuelle__c LAM:[ SELECT id, affaire__c,Ecart_C_A_F_MontantI__c, Total_CA_a_l_avancement__c , Marge_PV__c, Marge_compta__c ,
                                                        affaire__r.date_de_sav_reelle__c,
                                                        Periode_comptable__r.date_de_fin__c
                                                  FROM VILigne_d_affaire_mensuelle__c
                                                 WHERE affaire__c in :ListIDaffaire1
                                                   AND Periode_comptable__r.date_de_debut__c>=:StartExercise
                                                   AND Periode_comptable__r.date_de_debut__c<=:PeriodeOuverte.date_de_debut__c
                                                  order by affaire__c, Periode_comptable__r.date_de_debut__c asc ]) {

            VITdb_Gazelle__c tdb=MapTdb.get(LAM.affaire__c);
                                                      
            if(LAM.affaire__r.date_de_sav_reelle__c==null || LAM.affaire__r.date_de_sav_reelle__c>PeriodeOuverte.date_de_fin__c) {
                tdb.Ajustement_Marge_indus__c = (lam.Ecart_C_A_F_MontantI__c) * (-1);
            } else {
                tdb.Ajustement_Marge_indus__c = 0;                
            }

            tdb.CA_avancement_annee__c    =  lam.Total_CA_a_l_avancement__c ;
            tdb.Marge_indus_avancement__c = (lam.Marge_compta__c==null ?0 :lam.Marge_compta__c) ;
            
            tdb.Marge_indus_devis__c = (lam.Marge_PV__c==null ?0 :lam.Marge_PV__c) ;
            MapTdb.put(LAM.affaire__c,tdb) ;                                                    
       }

       // On enlève les valeurs au 31/12 de l année précédente 
       Date FinExercicePrecedent = StartExercise.adddays(-1);
        for(VILigne_d_affaire_mensuelle__c LAM:[ SELECT id, affaire__c,Ecart_C_A_F_MontantI__c, Total_CA_a_l_avancement__c , Marge_PV__c, Marge_compta__c,
                                                       Total_CA_a_l_avancement_20201231__c ,Dont_comptabiliseI__c
                                                  FROM VILigne_d_affaire_mensuelle__c
                                                 WHERE affaire__c in :ListIDaffaire1
                                                   AND Periode_comptable__r.date_de_fin__c=:FinExercicePrecedent
                                                  /* AND Periode_comptable__r.date_de_debut__c>=:StartExercise*/]) {
            VITdb_Gazelle__c tdb=MapTdb.get(LAM.affaire__c);
                                                      
           // if(lam.Total_CA_a_l_avancement_20201231__c!=null && lam.Total_CA_a_l_avancement_20201231__c!=0  ) {
                tdb.CA_avancement_annee__c    = tdb.CA_avancement_annee__c    - (lam.Total_CA_a_l_avancement_20201231__c ==null ? 0 :lam.Total_CA_a_l_avancement_20201231__c) ;                
           // } else {
           //     tdb.CA_avancement_annee__c    = tdb.CA_avancement_annee__c    - lam.Total_CA_a_l_avancement__c ;
           // }
                                                      
            if(tdb.Marge_indus_devis__c!=0)                                                           
                tdb.Marge_indus_devis__c      = tdb.Marge_indus_devis__c      - (lam.Marge_PV__c==null ?0 :lam.Marge_PV__c) ;

            tdb.Marge_indus_avancement__c= tdb.Marge_indus_avancement__c - ((lam.Total_CA_a_l_avancement_20201231__c==null ?0 :lam.Total_CA_a_l_avancement_20201231__c) - (lam.Dont_comptabiliseI__c==null ?0 :lam.Dont_comptabiliseI__c));
                                                      
            if(tdb.Ajustement_Marge_indus__c!=0)  { 
                tdb.Ajustement_Marge_indus__c = lam.Ecart_C_A_F_MontantI__c + tdb.Ajustement_Marge_indus__c ;
            }
                                                      
            MapTdb.put(LAM.affaire__c,tdb) ;                                                    
       }

       list<VITdb_Gazelle__c>ListTdbInsert = new  list<VITdb_Gazelle__c>();
       for(VITdb_Gazelle__c l :MapTdb.values()) {
           VIAffaire__c aff = MapAffaire.get(l.affaire__c) ; 
           double Backlog_Annee_1            =(aff.Backlog_Annee_1__c==null ? 0 : aff.Backlog_Annee_1__c);
           double Marge_indus_Backlog_Annee_1=(aff.Marge_indus_Backlog_Annee_1__c==null ? 0 : aff.Marge_indus_Backlog_Annee_1__c); 
           date date_de_sav_reelle = aff.date_de_sav_reelle__c ; 
           if(ListIdAffaire1.contains(aff.id) ||
              aff.date_de_sav_reelle__c>startexercise ||
              l.PV_Devis__c!=0 ||	 
              l.Marge_indus_devis__c!=0 || 
              l.Marge_indus_avancement__c!=0 ||               
              l.Ajustement_Marge_indus__c!=0 || 
              l.CA_avancement_annee__c!=0 || 
              l.Marge_indus_avancement__c!=0    || (Backlog_Annee_1!=0 || Marge_indus_Backlog_Annee_1!=0 ) ) {
                  if(MapAvenantAnnulation.containskey(l.affaire__c)) {
                      l.annulation_complete__c=true;
                  }

                  ListTdbInsert.add(l);
           }       
           
           
       }
       insert ListTdbInsert;
        
        
        num_record = num_record + scope.size();
    }   

    global void finish(Database.BatchableContext BC) {
        IDLog=VIUtils.LogWrite('VIBatchCalcTDBGazelle','1 Normal',IDLog,'nbr '+num_record);            
    }


    
    public static final integer NBR_LOT = 400;
    
}