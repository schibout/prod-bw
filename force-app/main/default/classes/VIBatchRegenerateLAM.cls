/*
 Database.executeBatch(new VIBatchRegenerateLAM('',false), VIBatchRegenerateLAM.nbr_lot());
*/
global class VIBatchRegenerateLAM implements Schedulable,Database.Batchable<sObject>,Database.Stateful{
    global Map<String,VIPeriode__c> MapEntite_bwPeriode = new  Map<String,VIPeriode__c>();  
    global Date  StartExercise ; 
    
    private string AffaireAGenerer; 
    private boolean Enchaine ;
    
     public VIBatchRegenerateLAM(String Param1,Boolean Param2 ) {
        AffaireAGenerer = Param1;        
        Enchaine = Param2;                
    }


    global Database.QueryLocator start(Database.BatchableContext BC){

        system.debug('debut VIBatchRegenerateLAM ');
        for(VIPeriode__c per : [SELECT ID,name, entite_bw__c, statut__c, date_de_debut__c, date_de_fin__c 
                                  FROM VIPeriode__c
                                 WHERE entite_bw__c='1'  ]) {
             MapEntite_bwPeriode.put(per.name,per);
             if(per.statut__c==VIConstant.PERIODE_OUVERTE)  {
                StartExercise=date.newinstance(per.date_de_debut__c.year(),1,1);       
             }
        }

        string query ='select id, name, Date_ouverture_affaire__c, ';
        query = query+'       Date_de_SAV_previsionnelle__c , Date_de_SAV_reelle__c , ';
        query = query+'       Date_de_fin_de_garantie__c ,date_de_livraison__c,date_max_mouvement__c,type_imputation__c ';
        query = query+'  FROM Viaffaire__c ';
        query = query+' WHERE (name like \''+AffaireAGenerer+'%\' ) ';
        query = query+'  order by Name desc ';
                                    
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Viaffaire__c > scope){
        
        Map<string,VILigne_d_affaire_mensuelle__c >MapLam = new Map<string,VILigne_d_affaire_mensuelle__c >();
        for(VILigne_d_affaire_mensuelle__c LAM : [select id, name
                                                    FROM VILigne_d_affaire_mensuelle__c
                                                   WHERE affaire__c in : scope]) {
            MapLam.put(LAM.name, LAM) ;
        }
        
        list<VILigne_d_affaire_mensuelle__c>listInsertLam = new list<VILigne_d_affaire_mensuelle__c>();
        list<VILigne_d_affaire_mensuelle__c>listupdateLam = new list<VILigne_d_affaire_mensuelle__c>();
        
        for(ViAffaire__c Aff : scope){ 
            
            
            date date_minimum= aff.Date_ouverture_affaire__c;
            date date_maximum= aff.Date_de_SAV_previsionnelle__c;
            if(aff.name.left(1)=='9') {
                date_minimum=StartExercise;
            } else if (aff.name.left(1)=='L' || aff.name.left(1)=='P' || aff.name.left(1)=='R' || aff.name.left(1)=='S' || aff.name.left(1)=='V') {
                date_minimum=date_minimum.addmonths(-2);
            }
                                  
            if(aff.Date_de_SAV_reelle__c>date_maximum)
                date_maximum=aff.Date_de_SAV_reelle__c;
                                  
            if(aff.Date_de_SAV_reelle__c==null)
                date_maximum=system.today();
                                  
            if(aff.Date_de_SAV_reelle__c>date_maximum)
                date_maximum=aff.Date_de_SAV_reelle__c;
                                  
            if(aff.Date_de_fin_de_garantie__c>date_maximum)
                date_maximum=aff.Date_de_fin_de_garantie__c;
                                  
            if(aff.Date_max_mouvement__c>date_maximum)
                date_maximum=aff.Date_max_mouvement__c;
                                  
            if(aff.date_de_livraison__c>date_maximum)
                date_maximum=aff.date_de_livraison__c;

            if(date_minimum<=date.newinstance(2018,01,01) ) {
                date_minimum=date.newinstance(2018,01,01);
            }
                                    
            if(date_maximum<date_minimum ) {
                date_maximum=date_minimum;
            }
            
            
            date d=date_minimum ; 

            system.debug('Affaire '+aff.name+' '+d+' '+date_maximum);
            string precedent ='';            
                
            while(d<=date_maximum) {
                string p = string.valueof(d.year())+('00'+string.valueof(d.month())).right(2)+'BW FRA';
                string p1 = aff.name+'-'+p; 
                if(!MapLam.containskey(p1)) {
                    VILigne_d_affaire_mensuelle__c lam = new VILigne_d_affaire_mensuelle__c();
                    lam.affaire__c = Aff.id ; 
                    lam.periode_comptable__c = MapEntite_BWPeriode.get(p).id;
                    lam.name = p1 ; 
                    lam.Garantie_dotation__c=0;
                    lam.Garantie_dotation_E__c=0;
                    lam.Garantie_reprise__c=0;
                    lam.Garantie_reprise_E__c=0;
                    lam.devis_heure__c=0;    
                    lam.devis_MontantD__c=0;
                    lam.devis_MontantI__c=0;               
                    lam.devis_MontantC__c=0;                               
                    lam.devis_MontantD_E__c=0;
                    lam.devis_MontantI_E__c=0;               
                    lam.devis_MontantC_E__c=0;                               
                    lam.Engage_brut_arrete_Heure__c =0;
                    lam.Engage_brut_arrete_MontantD__c =0;
                    lam.Engage_brut_arrete_MontantI__c =0;
                    lam.Engage_brut_arrete_MontantC__c =0;        
                    lam.Engage_brut_arrete_MontantD_E__c =0;
                    lam.Engage_brut_arrete_MontantI_E__c =0;
                    lam.Engage_brut_arrete_MontantC_E__c =0;  
                    lam.Dont_comptabiliseD__c =0;
                    lam.Dont_comptabiliseI__c =0;
                    lam.Dont_comptabiliseC__c =0;        
                    lam.Dont_comptabiliseD_E__c =0;
                    lam.Dont_comptabiliseI_E__c =0;
                    lam.Dont_comptabiliseC_E__c =0;   
                    lam.Ecart_C_A_F_Heure__c =0;
                    lam.Ecart_C_A_F_MontantD__c =0;        
                    lam.Ecart_C_A_F_MontantI__c =0;        
                    lam.Ecart_C_A_F_MontantC__c =0;                
                    lam.Ecart_C_A_F_MontantD_E__c =0;        
                    lam.Ecart_C_A_F_MontantI_E__c =0;        
                    lam.Ecart_C_A_F_MontantC_E__c =0;  

                    lam.PV_Total__c=0;
                    lam.PV_TotalE__c=0;                
                
                    lam.PV_Facture__c=0;
                    lam.PV_FactureE__c=0;                
                    lam.PV_Encaisse__c=0;                                
                    lam.PV_EncaisseE__c=0;                                                
                    lam.PV_Encaisse_HT__c=0;                                
                    lam.PV_Encaisse_HTE__c=0;                                                
                
                    lam.EMM__c=0;
                    lam.EMM_E__c=0;
                    lam.AMP__c=0;
                    lam.AMP_E__c=0;
                    lam.FOL__c=0;
                    lam.FOL_E__c=0;
                
                    lam.garantie_reprise__c=0;
                    lam.garantie_reprise_E__c=0;                
                    lam.garantie_dotation__c=0;                
                    lam.garantie_dotation_E__c=0;                
                    lam.garantie_depense__c=0;                
                    lam.garantie_depense_E__c=0;                                
 
                    MapLam.put(p1,lam);
                    listInsertLam.add(lam);
                } else {
                    VILigne_d_affaire_mensuelle__c lam =MapLam.get(p1) ; 
                    if(precedent!='') {
                        lam.Ligne_d_affaire_mensuelle_precedente__c = precedent;
                        listupdateLam.add(lam);
                    }
                    precedent=lam.id;
                }
                d=d.addmonths(1);
                d=date.newinstance(d.year(),d.month(),01);
            }
        }
        insert listInsertLam;
        update listupdateLam;
        
    }

    global void finish(Database.BatchableContext BC) {
        if(enchaine) {
            VIBatchRegenerateTotal v = new VIBatchRegenerateTotal(AffaireAGenerer,Enchaine,false);
            v.execute(null);
        }
    }

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VIBatchRegenerateLAM(AffaireAGenerer,Enchaine),VIBatchRegenerateLAM.NBR_LOT());
    }
    
    public static  integer NBR_LOT () {
         VIParametres__c param = VIParametres__c.getInstance(UserInfo.getUserId()); 
         integer i ; 
         if(param.Sans_Calcul_de_PRI__c) {
             i=200 ; 
         } else {
             i=200;    
         }
         return i;
    }


    
}