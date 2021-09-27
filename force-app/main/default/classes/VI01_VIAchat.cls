/*
* @author: Henri Saslawsky
* @description: 
*/

public class VI01_VIAchat {
/*
* @description: Method to fill up the Periode_comptable at the insert of the line
* 
* @param: List of VIAchat
* @return : void
* 
*/

    public static void Load_period (List <VIAchat__c> listAc) { 
        // Let's load all thxe involved Affaire. 
        List<string>ListIdAffaire = new List<string>();
        date date_minimum=null ; 
        date date_maximum=null ; 
        
        VIParametres__c param = VIParametres__c.getInstance(UserInfo.getUserId());  
        
        for(VIAchat__c ac:ListAc) {
            listIdAffaire.add(ac.affaire__c);
            
            if(date_minimum==null || date_minimum>ac.Date__c)
                date_minimum=ac.Date__c ; 
                                                       
            if(date_maximum==null || date_maximum<ac.Date__c)
                date_maximum=ac.Date__c ; 
        }

        if(date_minimum<=date.newinstance(2018,01,01) ) {
            date_minimum=date.newinstance(2018,01,01);
        }
        if(date_maximum<date_minimum)
            date_maximum=date_minimum;
        
        date_minimum=date_minimum.addmonths(-1).toStartOfMonth();
        date_maximum=date_maximum.addmonths(+2).toStartOfMonth();        
        
        Map<string,id>MapPeriodeOuverte = new Map<string,id>();

        // Let's load all the open periode
        map<string,VIPeriode__c>MapPeriode = new map<string,VIPeriode__c>();
        for(VIperiode__c pe :[SELECT id, name, entite_bw__c,statut__c  
                                FROM VIperiode__c
                               WHERE (date_de_debut__c>=:date_minimum
                                 AND date_de_fin__c<=:date_maximum)
                                  OR statut__c =:VIConstant.PERIODE_OUVERTE]) {
            MapPeriode.put(pe.name,pe);
            if(pe.statut__c==VIConstant.PERIODE_OUVERTE)  {
                MapPeriodeOuverte.put(pe.entite_bw__c,pe.id);
            }                
        }
        
        
        map<id, string>Mapentite_bw = new map<id, string>();
        map<id,list<Date>>MapDateAffaire = new map<id,list<Date>>();
        for(VIAffaire__c aff: [SELECT id, tolabel(entite_bw__c), 
                                      date_ouverture_affaire__c,Date_de_SAV_reelle__c ,Date_de_fin_de_garantie__c
                                  FROM VIAffaire__c
                                 WHERE id in :ListIdAffaire]) {
            MapEntite_BW.put(aff.id,aff.entite_bw__c);
            list<date>ListDate = new list<date>();
            ListDate.add(aff.date_ouverture_affaire__c) ;
            ListDate.add(aff.Date_de_SAV_reelle__c) ;                                                                          
            ListDate.add(aff.Date_de_fin_de_garantie__c) ;
            MapDateAffaire.put(aff.id,ListDate);                                     
        }
        
        //Let's load
        for(VIAchat__c ac:ListAc) {
            date d = ac.date__c;
            if(d<=date.newinstance(2018,01,01) ) {
                d=date.newinstance(2018,01,01);
            }

            if(param.Sans_Calcul_de_PRI__c) {
                string key=string.valueof(d.Year())+string.valueof(d.month()).leftpad(2,'0')+MapEntite_bw.get(ac.affaire__c) ;                
                ac.periode_comptable__c= MapPeriode.get(key).id;
            } else {
                date date_min = MapDateAffaire.get(ac.affaire__c)[0];
                date date_sav = MapDateAffaire.get(ac.affaire__c)[1];                        
                date date_max = MapDateAffaire.get(ac.affaire__c)[2];
                if(d<date_min || d>date_max) {
                    ac.AddError(label.VIErreur008+ac.name+' '+ac.affaire__C);                
                } else  if(date_sav==null && (ac.Sous_chapitre__c=='98' ||ac.Sous_chapitre__c=='99') ) {
                    ac.AddError(label.VIErreur009+ac.name+' '+ac.affaire__C);                
                } else if(date_sav!=null && (ac.Sous_chapitre__c=='00') ) {
                    ac.AddError(label.VIErreur010+ac.name+' '+ac.affaire__C);                
                } else {
                    string key=string.valueof(d.Year())+string.valueof(d.month()).leftpad(2,'0')+MapEntite_bw.get(ac.affaire__c) ;
                    VIperiode__C per = MapPeriode.get(key);
                    if(per.statut__c==VIConstant.PERIODE_FERMEE) {
                        ac.periode_comptable__c= MapPeriodeOuverte.get(MapEntite_bw.get(ac.affaire__c));
                    } else {
                        ac.periode_comptable__c= MapPeriode.get(key).id;
                    }
                }
            }                
        }
    
    }

/*
* @description: Method to compute the total on VILigne_affaire from VIAchat
* 
* @param: List of VIAchat
* @return : void
* 
*/
    public static list<id> ReProcess_LA (List <VIAchat__c> listAc) { 

        system.debug('entrée dans reprocess_la');
        Map<id,id>MapIDAff = new Map<id,id>();
        for(VIAchat__c ac : listAc) {
            MapIDAff.put(ac.affaire__c,ac.affaire__c);   // NE faire le recalcul que quand ça vaut le coup
        }

        return MapIDAff.values() ;


    }

/*
* @description: From Debours, we need to compute "industriel" and "complet"
* 
* @param: List of VIAchat
* @return : void
* 
*/ 
    
    public static void Compute_Value (List <VIAchat__c> listAc) {
       
        list<String> ListCurrency         = new list<string>();
        list<String> ListIdAffaire        = new list<string>();         
        Map<String,string> MapSousDomaine = new Map<String,string>(); 
        Map<String,string> MapAffCurrency = new Map<String,string>(); 
        Map<String,string> MapAffEntite_BW= new Map<String,string>();         
        Map<String,boolean> MapAffFgx     = new Map<String,boolean>();                 
        Map<String,boolean> MapAffk3      = new Map<String,boolean>();                         
        
        date date_minimum=null; //We don't need the currency rates below this date
        
        
        // Let's fetch the affaire and centre
        for(VIAchat__c ac:ListAc){
            ListCurrency.add(ac.currencyIsoCode);
            ListIdAffaire.add(ac.affaire__c);
            if(date_minimum==null || ac.date__c<date_minimum) 
                date_minimum=ac.date__c ;
        }

        // Lets fetch the Sous-domaine
        for(VIAffaire__c aff: [SELECT id, name, Produit_SousDomaine__c,
                                      Produit_SousDomaine__r.fgx__c,Produit_SousDomaine__r.k3__c ,
                                      currencyIsoCode,entite_bw__c
                                 FROM VIAffaire__c
                               WHERE id in :ListIdAffaire ]) {
            MapSousDomaine.put(aff.id, aff.Produit_SousDomaine__c );
            MapAffCurrency.put(aff.id,aff.currencyIsoCode);
            MapAffEntite_bw.put(aff.id,aff.entite_bw__c);
            MapAffFgx.put(aff.id, aff.Produit_SousDomaine__r.fgx__c );
            MapAffk3.put(aff.id, aff.Produit_SousDomaine__r.k3__c );                                   
        }
        
        // Let's fetch the currency rates needed
        List<DatedConversionRate> currencyTypeList = [SELECT Id, IsoCode, ConversionRate, StartDate, NextStartDate 
                                                        FROM DatedConversionRate 
                                                       WHERE IsoCode in :ListCurrency
                                                         AND (NextStartDate<:date_minimum or NextStartDate>9998-01-01 ) 
                                                    ORDER BY IsoCode, NextStartDate DESC];
        
        // Let's fetch all the rates we need to use later
        // WHERE   AND CurrencyIsoCode in :ListCurrency
        //                  AND Centre_Section__c in :ListCentreSection
        // 
        list<VITauxIncorporation__c >ListTaux = new List<VITauxIncorporation__c >();

        for(VITauxIncorporation__c  t:[SELECT entite_bw__c,Produit_SousDomaine__c , type_de_depense__c, CurrencyIsoCode,Date_de_debut__c,Date_de_fin__c,
                                              Taux_PRI__c , Taux_complet__c
                                         FROM VITauxIncorporation__c 
                                        WHERE CurrencyIsoCode in :ListCurrency
                                          AND Produit_SousDomaine__c in :MapSousDomaine.values()
                                          AND date_de_debut__c<=:date_minimum
                                          AND date_de_fin__c>=:date_minimum ]) {
              ListTaux.add(t);             
         }

        for(VIAchat__c ac:ListAc){     
            if(ac.origine__c=='Contrepartie') {
                ac.CommandeD_E__c = ac.CommandeD__c ; 
                ac.CommandeI_E__c = ac.CommandeI__c ; 
                ac.CommandeC_E__c = ac.CommandeC__c ;                 
                ac.ComptabiliseD_E__c = ac.ComptabiliseD__c ; 
                ac.ComptabiliseI_E__c = ac.ComptabiliseI__c ; 
                ac.ComptabiliseC_E__c = ac.ComptabiliseC__c ;    
                continue ; 
            }
            
            // We need to find the correct line in the list
            VITauxIncorporation__c t_correct = new VITauxIncorporation__c();
            t_correct = null;
            for(VITauxIncorporation__c t:ListTaux) {
                
                if(t.entite_bw__c    == MapAffentite_bw.get(ac.affaire__c) && 
                   t.CurrencyIsoCode == MapAffCurrency.get(ac.affaire__c) && 
                   t.type_de_depense__c == ac.type_depense__c && 
                   t.Produit_SousDomaine__c == MapSousDomaine.get(ac.affaire__c) &&
                   t.date_de_debut__c  <= ac.date__c && 
                   t.date_de_fin__c    >= ac.date__c  ) {
                  t_correct=t ; 
                  break ;     
               }   
            }
                        
            // Hope we found the correct line
            if(t_correct!=null) {
                if(!MapAffFgx.get(ac.affaire__c))
                    t_correct.taux_PRI__c=1;

                if(!MapAffk3.get(ac.affaire__c))
                    t_correct.taux_complet__c=t_correct.taux_PRI__c;
                
                ac.CommandeI__c     = (ac.CommandeD__c==null ? 0:ac.CommandeD__c)          * t_correct.taux_PRI__c;
                ac.CommandeC__c     = (ac.CommandeD__c==null ? 0:ac.CommandeD__c)          * t_correct.taux_Complet__c;                
                ac.ComptabiliseI__c = (ac.ComptabiliseD__c==null ? 0:ac.ComptabiliseD__c)  * t_correct.taux_PRI__c;
                ac.ComptabiliseC__c = (ac.ComptabiliseD__c==null ? 0:ac.ComptabiliseD__c)  * t_correct.taux_Complet__c;                
            }  else {
                ac.CommandeI__c = ac.CommandeD__c ;
                ac.CommandeC__c = ac.CommandeD__c ;                
                ac.ComptabiliseI__c = ac.ComptabiliseD__c ;
                ac.ComptabiliseC__c = ac.ComptabiliseD__c ;                               
            } 

            // If we are in EUR,we don't have to do any currency conversion
            if(ac.currencyIsoCode=='EUR') {
                ac.CommandeD_E__c = ac.CommandeD__c ; 
                ac.CommandeI_E__c = ac.CommandeI__c ; 
                ac.CommandeC_E__c = ac.CommandeC__c ;                 
                ac.ComptabiliseD_E__c = ac.ComptabiliseD__c ; 
                ac.ComptabiliseI_E__c = ac.ComptabiliseI__c ; 
                ac.ComptabiliseC_E__c = ac.ComptabiliseC__c ;                 
            } else {
                // We are in a currency
                // So let's loop until we find the correct line
                DatedConversionRate r_correct = null ; 
                for(DatedConversionRate r: currencyTypeList) {
                    if(r.IsoCode==ac.currencyIsoCode &&
                       r.StartDate<=ac.date__c && 
                       r.NextStartDate>=ac.date__c) {
                        r_correct = r;
                        break ; 
                    }
                }
                if(r_correct!=null) {
                    if(ac.CommandeD__c!=null) {
                        ac.CommandeD_E__c=(ac.CommandeD__c*(1/r_correct.ConversionRate)).SetScale(2);
                        ac.CommandeI_E__c=(ac.CommandeI__c*(1/r_correct.ConversionRate)).SetScale(2);
                        ac.CommandeC_E__c=(ac.CommandeC__c*(1/r_correct.ConversionRate)).SetScale(2);
                    }
                    if(ac.ComptabiliseD__c!=null) {
                        ac.ComptabiliseD_E__c=(ac.ComptabiliseD__c*(1/r_correct.ConversionRate)).SetScale(2);
                        ac.ComptabiliseI_E__c=(ac.ComptabiliseI__c*(1/r_correct.ConversionRate)).SetScale(2);
                        ac.ComptabiliseC_E__c=(ac.ComptabiliseC__c*(1/r_correct.ConversionRate)).SetScale(2);
                    }
                }
            }
        }           
    }
}