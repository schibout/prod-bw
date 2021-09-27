/*
* @author: Henri Saslawsky
* @description: 
*/

public class VI01_Affaire {

    public static boolean VerifDate (boolean test_date_ouverture, List <VIAffaire__c> listAff, Map <id,VIAffaire__c> MapAffOld ) { 

        boolean check =false ; 
                
        VIParametres__c param = VIParametres__c.getInstance(UserInfo.getUserId());  
             
        Map<string, VIPeriode__c>MapPeriodeOuverte= new Map<string, VIPeriode__c>();
        for(VIPeriode__c per:[SELECT date_de_debut__c, date_de_fin__c, entite_bw__c
                                FROM VIPeriode__c
                              WHERE statut__c=:VIConstant.PERIODE_OUVERTE ]) {
            MapPeriodeOuverte.put(per.entite_bw__c, per);
        }

        for(VIAffaire__c aff:listAff){
            if(aff.Date_de_SAV_previsionnelle__c <aff.Date_ouverture_affaire__c ) {
                aff.Date_de_SAV_previsionnelle__c =aff.Date_ouverture_affaire__c ;
            }
            if(aff.date_ouverture_affaire__c==null ) {
                aff.date_ouverture_affaire__c =aff.Date_de_livraison__c  ;
            }
            if(aff.date_max_mouvement__c<aff.Date_de_fin_de_garantie__c  ) {
                aff.date_max_mouvement__c=aff.Date_de_fin_de_garantie__c  ;
            }

            if(param.Sans_Calcul_de_PRI__c)
                continue ; 

            if(test_date_ouverture) {
                if(aff.date_ouverture_affaire__c<MapPeriodeOuverte.get(aff.entite_bw__c).date_de_debut__c) {
                    Aff.AddError(label.VIErreur007+' '+aff.date_ouverture_affaire__c);
                    check=true ; 
                }
            } 
            if(aff.date_ouverture_affaire__c>system.today().adddays(1)) {
                Aff.AddError(label.VIErreur015);
                check=true ; 
            }

            if(MapAffOld!=null) {
                if(MapAffOld.containskey(aff.id)) {
                    VIAffaire__c OldAff = MapAffOld.get(aff.id);
                    if(OldAff.date_de_sav_reelle__c==null && aff.date_de_sav_reelle__c!=null ) {
                        if(aff.date_de_sav_reelle__c!=MapPeriodeOuverte.get(aff.entite_bw__c).date_de_fin__c) {
                            Aff.AddError(label.VIErreur011);                    
                        }
                    }  
                    if(OldAff.date_de_sav_reelle__c!=null && aff.date_de_sav_reelle__c!=null && OldAff.date_de_sav_reelle__c!=aff.date_de_sav_reelle__c ) {
                            Aff.AddError(label.VIErreur012+' '+OldAff.date_de_sav_reelle__c+' '+aff.date_de_sav_reelle__c); 
                    }
                }
            }
        }        
        return check;
    }

    
/*
* @description: We need to create an open LAM for each affaire and for each month
* 
* @param: List of Affaire
* @return : void
* 
*/ 
    
    public static void Creation_lam (List <VIAffaire__c> listA) {

        // Let's fetch all the Affaire
        Map<id,string>MapAffaire           = new Map<id,string>();
        map<id,string>MapAffaireEntite_bw  = new map<id,string>();
        map<id,string>MapAffaireCurrency   = new map<id,string>();
        date date_minimum=null ; 
        date date_maximum=null ; 

        Map<String,string>MapEntite_bw = new Map<String,string>();
        for(VIEntiteBW__c entite_bw : [Select entite_bw__c,name FROM VIEntiteBW__C ] ) {
            MapEntite_bw.put(entite_bw.entite_bw__c,entite_bw.name);
        }
        
        for(VIAffaire__c a : listA) {
                
            MapAffaire.put(a.id,a.name);
            MapAffaireEntite_bw.put(a.id,MapEntite_bw.get(a.Entite_bw__c));
            MapAffaireCurrency.put(a.id,a.CurrencyIsoCode); 
            if(date_minimum==null || date_minimum>a.Date_ouverture_affaire__c)
                date_minimum=a.Date_ouverture_affaire__c ; 
                                                       
            if(date_maximum==null || date_maximum<a.date_de_sav_previsionnelle__c) 
                date_maximum=a.Date_de_sav_previsionnelle__c ; 
            if(a.date_de_fin_de_garantie__c!=null && date_maximum<a.date_de_fin_de_garantie__c) 
                date_maximum=a.date_de_fin_de_garantie__c ; 
            
        }
        if(date_maximum==null)
            date_maximum=date_minimum ;

        if(date_minimum==null  || date_minimum<=date.newinstance(2018,01,01) ) {
            date_minimum=date.newinstance(2018,01,01);
        }

        if(date_maximum==null  || date_maximum<date_minimum)
            date_maximum=date_minimum;
                
        date_minimum=date_minimum.addmonths(-1).toStartOfMonth();
        date_maximum=date_maximum.addmonths(+2).toStartOfMonth();        
        // At this stage, we have the minimum and the maximun date for each affaire. 
        // So we know wich LAM we need for each affaire
        
        
        Map<string,VIPeriode__c>MapPeriode = new Map<string,VIPeriode__c>();
        for (VIPeriode__c pe : [SELECT id, name,
                                       entite_bw__c,
                                       date_de_fin__c,
                                       Periode_comptable_precedente__r.name
                                  FROM VIPeriode__c
                                 WHERE date_de_debut__c>:date_minimum
                                   AND date_de_debut__c<=:date_maximum]) {
            MapPeriode.put(pe.name, pe);
        }

        
        map<string,VILigne_d_affaire_mensuelle__c>MapLAM = new map<String,VILigne_d_affaire_mensuelle__c>();
        for(VILigne_d_affaire_mensuelle__c lam : [SELECT id,name, CurrencyIsoCode, Affaire__c 
                                                    FROM VILigne_d_affaire_mensuelle__c
                                                   WHERE affaire__c in :MapAffaire.keyset()
                                                     AND periode_comptable__r.date_de_debut__c>:date_minimum
                                                     AND periode_comptable__r.date_de_debut__c<=:date_maximum]) {
            MapLAM.put(lam.name,lam) ;  
        }

        List<VILigne_d_affaire_mensuelle__c>ListNewLAM = new List<VILigne_d_affaire_mensuelle__c>();
        for(VIAffaire__c a : listA) {
            
            date_minimum=a.Date_ouverture_affaire__c ;
            date_maximum=a.Date_de_sav_previsionnelle__c ;
            if(a.date_de_fin_de_garantie__c>date_maximum) {
                date_maximum=a.date_de_fin_de_garantie__c;
            }

            if(date_minimum==null  || date_minimum<=date.newinstance(2018,01,01) ) {
                date_minimum=date.newinstance(2018,01,01);
            }
            if(date_maximum==null  || date_maximum<date_minimum)
                date_maximum=date_minimum;
            
            date_maximum=date_maximum.addmonths(1).toStartOfMonth() ;

            date d=date_minimum.toStartOfMonth() ; 
            while(d<date_maximum) {
                string key=a.name+'-'+string.valueof(d.Year())+string.valueof(d.month()).leftpad(2,'0')+MapAffaireEntite_bw.get(a.id) ;
                if(!MapLam.containskey(key)) {
                    VILigne_d_affaire_mensuelle__c LAM = new VILigne_d_affaire_mensuelle__c();
                    lam.name=key;
                    lam.affaire__c=a.id;
                    lam.Periode_comptable__c=MapPeriode.get(string.valueof(d.Year())+string.valueof(d.month()).leftpad(2,'0')+MapAffaireEntite_bw.get(a.id)).id ;
                    lam.CurrencyIsoCode=MapAffaireCurrency.get(a.id) ;
                    lam.Devis_Heure__c =0; 
                    lam.Devis_MontantD__c=0; 
                    lam.Devis_MontantI__c=0;
                    lam.Devis_MontantC__c=0;                                                       
                    lam.Devis_MontantD_E__c=0; 
                    lam.Devis_MontantI_E__c=0;
                    lam.Devis_MontantC_E__c=0; 
                    lam.engage_brut_arrete_Heure__c =0;
                    lam.engage_brut_arrete_MontantD__c=0; 
                    lam.engage_brut_arrete_MontantI__c=0;
                    lam.engage_brut_arrete_MontantC__c=0;                                                       
                    lam.engage_brut_arrete_MontantD_E__c=0; 
                    lam.engage_brut_arrete_MontantI_E__c=0;
                    lam.engage_brut_arrete_MontantC_E__c=0;                                                       
                    lam.Dont_comptabiliseD__c =0; 
                    lam.Dont_comptabiliseI__c =0;
                    lam.Dont_comptabiliseC__c =0;                                                       
                    lam.Dont_comptabiliseD_E__c =0; 
                    lam.Dont_comptabiliseI_E__c =0;
                    lam.Dont_comptabiliseC_E__c =0;                                                       
                    lam.Ecart_C_A_F_Heure__c =0; 
                    lam.Ecart_C_A_F_MontantD__c=0; 
                    lam.Ecart_C_A_F_MontantI__c =0; 
                    lam.Ecart_C_A_F_MontantC__c =0;                                                        
                    lam.Ecart_C_A_F_MontantD_E__c=0; 
                    lam.Ecart_C_A_F_MontantI_E__c =0; 
                    lam.Ecart_C_A_F_MontantC_E__c =0;  
                    lam.pv_facture__c=0;
                    lam.PV_FactureE__c=0;
                    lam.PV_EncaisseE__c=0;
                    lam.PV_EncaisseE__c=0;
                    ListNewLAM.add(LAM);
                }
                d=d.addmonths(1);
            }
        }        
        if(ListNewLAM.size()>0)
            insert ListNewLAM;

        // Let's update the field Ligne_d_affaire_mensuelle_precedente__c 
        MapLAM = new map<String,VILigne_d_affaire_mensuelle__c>();
        for(VILigne_d_affaire_mensuelle__c lam : [SELECT id,name, CurrencyIsoCode, Affaire__c ,Affaire__r.name,
                                                         Ligne_d_affaire_mensuelle_precedente__c,
                                                         periode_comptable__r.name
                                                    FROM VILigne_d_affaire_mensuelle__c
                                                   WHERE affaire__c in :MapAffaire.keyset()
                                                     AND periode_comptable__r.date_de_fin__c>=:date_minimum
                                                     AND periode_comptable__r.date_de_fin__c<=:date_maximum]) {
            MapLAM.put(lam.name,lam) ;  
        }

        List<VILigne_d_affaire_mensuelle__c>ListUpdateLAM = new List<VILigne_d_affaire_mensuelle__c>();
        for(VILigne_d_affaire_mensuelle__c lam : MapLAM.values()) {
            if(lam.Ligne_d_affaire_mensuelle_precedente__c==null) {
                string periode_current =  lam.periode_comptable__r.name;
                string periode_prec =null ; 
                if(MapPeriode.containskey(periode_current)) {
                    periode_prec=MapPeriode.get(periode_current).periode_comptable_precedente__r.name;
                    if(MapLam.containskey(lam.affaire__r.name+'-'+periode_prec)) {
                        lam.Ligne_d_affaire_mensuelle_precedente__c=MapLam.get(lam.affaire__r.name+'-'+periode_prec).id;
                        ListUpdateLAM.add(lam);
                    }
                }
            }
        }
        if(ListUpdateLAM.size()>0)
            update ListUpdateLAM;

        
    }   

    
    public static void Maj_Region_secteur (List <VIAffaire__c> listA) {
        Map<string, Order>MapOrder =new Map<string, Order>();
        List<string>ListIDOrder = new List<string>();
        for(VIAffaire__c a : listA) {
            ListIDOrder.add(a.Order__c );
        }   
        for(Order ord : [SELECT id ,ORD_Code_Agence_Regionale_BW__c , ORD_Code_Secteur_Commercial__c 
                           FROM Order
                           WHERE id in :ListIDorder ]) {
            MapOrder.put(ord.id,ord); 
        }

        for(VIAffaire__c a : listA) {
            if(MapOrder.containskey(a.Order__c)) {
                a.Agence_Regionale_BW_commande__c = MapOrder.get(a.order__c).ORD_Code_Agence_Regionale_BW__c;
                a.Secteur_commande__c             = MapOrder.get(a.order__c).ORD_Code_Secteur_Commercial__c ;
            } else {
                a.Agence_Regionale_BW_commande__c ='';
                a.Secteur_commande__c             ='';
            }
        }
    }
    
    
}