//
//   This batch Close the open periode
//  
//  
// 
global class VIBatchCloture implements Database.Batchable<string>, Database.Stateful {

    private String strEntite_Bw;
    Private boolean Boolclosed ; 
    Global double num_record = 0; 
    Global String IDLog ='';    
    public VIParametres__c param ;


    public VIperiode__c PeriodeDerniere;    
    public VIperiode__c PeriodeOuverte;
    public VIperiode__c PeriodePreOuverte;    
    public VIperiode__c PeriodeFuture;        
    

    public VIBatchCloture(String strParam, Boolean BoolParam) {
        strEntite_Bw    = strParam;
        Boolclosed = BoolParam ;   // Do we have to close the periode comptable ? Or not ?     
    }

    global Iterable<String> start(Database.BatchableContext BC) {

        param=VIParametres__c.getInstance(UserInfo.getUserId());         
        
        PeriodeDerniere= [SELECT id,name, Entite_Bw__c, Statut__c, Saisie_ouverte__c  
                            FROM VIPeriode__c
                           WHERE entite_bw__c=:strEntite_Bw
                             AND Statut__c=:VIConstant.PERIODE_DERNIERE];

        PeriodeOuverte= [SELECT id,name, Entite_Bw__c, Statut__c, Saisie_ouverte__c  
                            FROM VIPeriode__c
                           WHERE Entite_Bw__c=:strEntite_Bw
                             AND Statut__c=:VIConstant.PERIODE_OUVERTE];

        PeriodePreOuverte= [SELECT id,name, Entite_Bw__c, Statut__c , Saisie_ouverte__c 
                            FROM VIPeriode__c
                           WHERE entite_bw__c=:strEntite_Bw
                             AND Statut__c=:VIConstant.PERIODE_PREOUVERTE];
        
        PeriodeFuture = [SELECT id,name, Statut__c, Saisie_ouverte__c  
                            FROM VIPeriode__c
                           WHERE name>:PeriodePreouverte.name
                             AND entite_bw__c=:strEntite_Bw
                             AND Statut__c=:VIConstant.PERIODE_FUTURE   
                        ORDER BY name  
                           LIMIT 1];

     
        List<VIAffaire__c>ListAffaire = [SELECT id, cycle_RAD__c, date_de_sav_reelle__c
                                           FROM VIAffaire__c
                                          WHERE Cycle_RAD__c=true 
                                            AND date_de_sav_reelle__c!=null];
        for(VIAffaire__c a : ListAffaire)  {
            a.Cycle_RAD__c =false;
        }   
        Update ListAffaire ; 
        
        
        // The query is build dynamicaly in order to get all the fields  
        //  AND affaire__r.Statut_affaire__c ='20 En cours' 
        List<string>ListId = new List<string>();       
        for(VIAffaire__c aff : [SELECT id 
                                  FROM VIaffaire__c  
                                 WHERE id  in (SELECT Affaire__c  
                                                 FROM VILigne_d_affaire_mensuelle__c 
                                                WHERE Periode_comptable__c=:PeriodeOuverte.id )])  { 
            listId.add(aff.id);
        }
        
        IDLog=VIUtils.LogWrite('VIBatchCloture','4 Running','','Start '+StrEntite_Bw);
        
        return ListId;
    }

    global void execute(Database.BatchableContext BC, List<string> scope) {
        
        
        if(Boolclosed) { 
            // We have to transfert the Ecart CAF from the previous month to the new one
            map<string,VIligne_affaire__c>mapLaOuverte = new map<string,VIligne_affaire__c>(); 
            map<string,VIligne_affaire__c>mapLaPreOuverte = new map<string,VIligne_affaire__c>();         
            for(ViLigne_affaire__c la:[SELECT id, Type_depense__c , centre_section__c,
                                          Ligne_d_affaire_mensuelle__r.affaire__c,
                                          Ligne_d_affaire_mensuelle__r.periode_comptable__c,
                                          Ligne_d_affaire_mensuelle__r.periode_comptable__r.statut__c,
                                          Ecart_C_A_F_Heure__c ,
                                          Ecart_C_A_F_MontantD__c , Ecart_C_A_F_MontantD_E__c ,
                                          Ecart_C_A_F_MontantI__c , Ecart_C_A_F_MontantI_E__c ,
                                          Ecart_C_A_F_MontantC__c , Ecart_C_A_F_MontantC_E__c                                    
                                     FROM VIligne_affaire__c
                                    WHERE Ligne_d_affaire_mensuelle__r.affaire__c in :scope
                                      AND (Ligne_d_affaire_mensuelle__r.periode_comptable__r.Statut__c=:VIConstant.PERIODE_OUVERTE
                                           OR Ligne_d_affaire_mensuelle__r.periode_comptable__r.Statut__c=:VIConstant.PERIODE_PREOUVERTE)]) {
                if(la.Ligne_d_affaire_mensuelle__r.periode_comptable__r.statut__c==VIConstant.PERIODE_OUVERTE) {                                   
                    maplaOuverte.put(la.Ligne_d_affaire_mensuelle__r.affaire__c+'/'+la.Type_depense__c+'/'+la.centre_section__c,la);                               
                }
                if(la.Ligne_d_affaire_mensuelle__r.periode_comptable__r.statut__c==VIConstant.PERIODE_PREOUVERTE) {                                   
                    maplaPreOuverte.put(la.Ligne_d_affaire_mensuelle__r.affaire__c+'/'+la.Type_depense__c+'/'+la.centre_section__c,la);                               
                }
            }
            list<VIAffaire__c>listLa = new list<VIAffaire__c>();
        
            for(VILigne_affaire__c la:MaplaPreOuverte.values()) {
                if(!MaplaOuverte.containskey(la.Ligne_d_affaire_mensuelle__r.affaire__c+'/'+la.Type_depense__c+'/'+la.centre_section__c))
                    continue ; 
                
                VILigne_affaire__c OldLa = MaplaOuverte.get(la.Ligne_d_affaire_mensuelle__r.affaire__c+'/'+la.Type_depense__c+'/'+la.centre_section__c);
                if(OldLa.Ecart_C_A_F_Heure__c!=0 && la.Ecart_C_A_F_Heure__c==0) {
                    la.Ecart_C_A_F_Heure__c = OldLa.Ecart_C_A_F_Heure__c;
                }
                if(OldLa.Ecart_C_A_F_MontantD__c!=0 && la.Ecart_C_A_F_MontantD__c==0) {
                    la.Ecart_C_A_F_MontantD__c = OldLa.Ecart_C_A_F_MontantD__c;
                    la.Ecart_C_A_F_MontantI__c = OldLa.Ecart_C_A_F_MontantI__c;
                    la.Ecart_C_A_F_MontantC__c = OldLa.Ecart_C_A_F_MontantC__c;                
                    la.Ecart_C_A_F_MontantD_E__c = OldLa.Ecart_C_A_F_MontantD_E__c;
                    la.Ecart_C_A_F_MontantI_E__c = OldLa.Ecart_C_A_F_MontantI_E__c;
                    la.Ecart_C_A_F_MontantC_E__c = OldLa.Ecart_C_A_F_MontantC_E__c;                
                }
            }
            upsert MaplaPreOuverte.values();
        }            
    }   

    global void finish(Database.BatchableContext BC) {
        if(BoolClosed) { 
            PeriodeDerniere.Statut__c=VIConstant.PERIODE_FERMEE; 
            PeriodeDerniere.Saisie_ouverte__c = false;            
            update PeriodeDerniere;
            PeriodeOuverte.Statut__c=VIConstant.PERIODE_DERNIERE; 
            PeriodeOuverte.Saisie_ouverte__c = true;
            update PeriodeOuverte;
            PeriodePreouverte.Statut__c=VIConstant.PERIODE_OUVERTE; 
            update PeriodePreouverte;
            PeriodeFuture.Statut__c=VIConstant.PERIODE_PREOUVERTE; 
            update PeriodeFuture;
            
            
        }
        
        IDLog=VIUtils.LogWrite('VIBatchCloture','1 Normal',IDLog,'End '+num_record);

    }
    
  public static  integer NBR_LOT () {
         VIParametres__c param=VIParametres__c.getInstance(UserInfo.getUserId());
         integer i ; 
         if(param.Sans_Calcul_de_PRI__c) {
             i=100 ;
         } else {
             i=4;    
         }
         return i;
    }    
    
}