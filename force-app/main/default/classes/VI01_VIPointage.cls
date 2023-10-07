/*
* @author: Henri Saslawsky
* @description: 
*/

public class VI01_VIPointage {

/*
* @description: Method to fill up the Periode_comptable at the insert of the line
* 
* @param: List of VIPointage
* @return : void
* 
*/

    public static void Load_period (List <VIPointage__c> listPo) { 
        system.debug('entrée dans VI01_VIPointage.Load_period');

        VIParametres__c param = VIParametres__c.getInstance(UserInfo.getUserId());          
        
        // Let's load all the involved Affaire. 
        List<string>ListIdAffaire = new List<string>();
        date date_minimum=null ; 
        date date_maximum=null ; 
        
        for(VIPointage__c po:ListPo) {

            
            listIdAffaire.add(Po.affaire__c);
            date d1=po.date_comptabilisation__c ; 
            if(d1==null)
                d1=po.date__c;
                
         //   if(po.date_comptabilisation__c!=null)
         //       d1=po.date_comptabilisation__c;
            
            if(date_minimum==null || date_minimum>d1)
                date_minimum=d1 ; 
                                                       
            if(date_maximum==null || date_maximum<d1)
                date_maximum=d1 ; 
            
        }
        if(date_maximum==null)
            date_maximum=date_minimum ;

        if(date_minimum==null  || date_minimum<=date.newinstance(2018,01,01) ) {
            date_minimum=date.newinstance(2018,01,01);
        }

        if(date_maximum==null  || date_maximum<date_minimum)
            date_maximum=date_minimum;
        
        date_minimum=date_minimum.addmonths(-2).toStartOfMonth();
        date_maximum=date_maximum.addmonths(+2).toStartOfMonth();        

        Map<string,id>MapPeriodeOuverte = new Map<string,id>();

        // Let's load all the open periode
        map<string,VIPeriode__c>MapPeriode = new map<string,VIPeriode__c>();
        for(VIperiode__c pe :[SELECT id, name, tolabel(entite_bw__c),statut__c  
                                FROM VIperiode__c
                               WHERE (date_de_debut__c>:date_minimum
                                 AND date_de_fin__c<:date_maximum)
                                  OR statut__c =:VIConstant.PERIODE_OUVERTE]) {
            MapPeriode.put(pe.name,pe);
            if(pe.statut__c==VIConstant.PERIODE_OUVERTE)  {
                MapPeriodeOuverte.put(pe.entite_bw__c,pe.id);
            }                         
        }
        
        
        map<id, string>MapEntite_bw = new map<id, string>();
        map<id,list<Date>>MapDateAffaire = new map<id,list<Date>>();
        for(VIAffaire__c aff: [SELECT id, ToLabel(entite_bw__c), 
                                      date_ouverture_affaire__c,Date_de_SAV_reelle__c , Date_max_mouvement__c
                                  FROM VIAffaire__c
                                 WHERE id in :ListIdAffaire]) {
            MapEntite_bw.put(aff.id,aff.entite_bw__c);
            list<date>ListDate = new list<date>();
            ListDate.add(aff.date_ouverture_affaire__c) ;
            ListDate.add(aff.Date_de_SAV_reelle__c) ;                                     
            ListDate.add(aff.Date_max_mouvement__c) ;
            MapDateAffaire.put(aff.id,ListDate);
        }
        
        //Let's load
        for(VIPointage__c po:Listpo) {

            // On est sur les calculs rétroactifs. les lignes doivent rester sur la période précédente
            if((po.Numero_unique__c.left(3)=='REC') && po.periode_comptable__c!=null)
                continue;
            
                           
            date date_min = MapDateAffaire.get(po.affaire__c)[0];
            date date_sav = MapDateAffaire.get(po.affaire__c)[1];            
            date date_max = MapDateAffaire.get(po.affaire__c)[2];
            date d1=po.date_comptabilisation__c ; 
            if(d1==null)
                d1=po.date__c;


                
            if(d1<=date.newinstance(2018,01,01) ) {
                d1=date.newinstance(2018,01,01);
            }
            string key=string.valueof(d1.Year())+string.valueof(d1.month()).leftpad(2,'0')+MapEntite_bw.get(po.affaire__c) ;
            VIperiode__C per = MapPeriode.get(key);    
            po.periode_comptable__c= per.id;
            
/*            
            if(d1<date_min || d1>date_max) {
                po.AddError(label.VIErreur008+po.name+' '+d1);                
            } else  if(date_sav==null && d1<date_sav&& (po.Sous_chapitre__c=='98' ||po.Sous_chapitre__c=='99') ) {
                po.AddError(label.VIErreur009+po.name+' '+po.affaire__C);                
            } else if(date_sav!=null && po.date__c>date_sav && (po.Sous_chapitre__c=='00') ) {
                po.AddError(label.VIErreur010+po.name+' '+po.affaire__C);                
            } else {
                string key=string.valueof(d1.Year())+string.valueof(d1.month()).leftpad(2,'0')+MapEntite_bw.get(po.affaire__c) ;
                VIperiode__C per = MapPeriode.get(key);
                if(per.statut__c==VIConstant.PERIODE_FERMEE) {
                    po.periode_comptable__c= MapPeriodeOuverte.get(MapEntite_bw.get(po.affaire__c));
                } else {
                    po.periode_comptable__c= MapPeriode.get(key).id;
                }
            }
*/
        }

    }


    
/*
* @description: Method to compute the total on VILigne_affaire from VIPointage
* 
* @param: List of VIPointage
* @return : void
* 
*/
    public static list<id> ReProcess_LA (List <VIPointage__c> listPO) { 

        system.debug('entrée dans VI01_VIPointage.reprocess_la');
        Map<id,id>MapIDAff = new Map<id,id>();
        for(VIPointage__c Po : listPo) {
            MapIDAff.put(Po.affaire__c,Po.affaire__c);   // NE faire le recalcul que quand ça vaut le coup
        }

        return MapIDAff.values() ;
    }

/*
* @description: From Debours, we need to compute "industriel" and "complet"
* 
* @param: List of VIPointage
* @return : void
* 
*/ 
    
    public static void Compute_Value (List <VIPointage__c> listPO) {
        system.debug('entrée dans VI01_VIPointage.Compute_Value');        
        list<String> ListCentreSection = new list<string>(); 
        list<string> ListAffaire       = new list<string>(); 
        date date_minimum=null; //We don't need the currency rates below this date
        
        VIParametres__c param = VIParametres__c.getInstance(UserInfo.getUserId());  
        
        // Let's fetch the affaire and centre
        for(VIPointage__c po:ListPO){
            ListAffaire.add(po.affaire__c);
            ListCentreSection.add(po.Centre_Section__c);  
            date d1=po.date_comptabilisation__c ; 
            if(d1==null)
                d1=po.date__c;
            
            if(date_minimum==null || date_minimum>d1)
                date_minimum=d1 ; 
            
        }

        if(date_minimum==null  || date_minimum<=date.newinstance(2018,01,01) ) {
            date_minimum=date.newinstance(2018,01,01);
        }

        //date_minimum=date_minimum.addmonths(-2).toStartOfMonth();
        
        map<string,string>MapAffCurrency = new map<string,string>();
        map<string,boolean>MapAffFGX = new map<string,boolean>();
        map<string,boolean>MapAffK3 = new map<string,boolean>();        
        for(VIaffaire__c aff:[SELECT id, currencyIsoCode, Produit_SousDomaine__r.fgx__c, Produit_SousDomaine__r.k3__c
                                FROM VIaffaire__c
                               WHERE id in :ListAffaire]) {
            MapAffCurrency.put(aff.id,aff.currencyIsoCode);
            MapAffFGX.put(aff.id,aff.Produit_SousDomaine__r.fgx__c);
            MapAffK3.put(aff.id,aff.Produit_SousDomaine__r.k3__c);                                   
        }
        
        
        // Let's fetch the currency rates needed
        List<DatedConversionRate> currencyTypeList = [SELECT Id, IsoCode, ConversionRate, StartDate, NextStartDate 
                                                        FROM DatedConversionRate 
                                                       WHERE IsoCode in :MapAffCurrency.values()
                                                         AND (NextStartDate<=:date_minimum or NextStartDate>9998-01-01 ) 
                                                    ORDER BY IsoCode, NextStartDate DESC];
        

        // Let's fetch all the rates we need to use later
        // WHERE  CurrencyIsoCode in :ListCurrency
        //                  AND Centre_Section__c in :ListCentreSection
        // 
        list<VITauxHoraire__c>ListTaux = new List<VItauxHoraire__c>();
        for(VItauxHoraire__c t:[SELECT Centre_Section__c, CurrencyIsoCode,Date_de_debut__c,Date_de_fin__c,
                                taux_engage_horaire__c , Taux_engage_conversion_PRI__c , Taux_engage_conversion_complet__c
                           FROM VItauxHoraire__c
                          WHERE CurrencyIsoCode in :MapAffCurrency.values()
                            AND Centre_Section__c in :ListCentreSection
                            AND date_de_fin__c>=:date_minimum ]) {
              ListTaux.add(t);    
         }

        for(VIPointage__c la:ListPO){
            if(la.numero_unique__c.left(3)=='REP') 
                continue ; 
            if(la.numero_unique__c.left(3)=='REC') 
                continue ; 

                        
            // We need to find the correct line in the list
            VItauxHoraire__c t_correct = new VItauxHoraire__c();
            t_correct = null;
            for(VItauxHoraire__c t:ListTaux) {
                date d1=la.date_comptabilisation__c ; 
                if(d1==null)
                    d1=la.date__c;
                
                if(t.CurrencyIsoCode   == MapAffCurrency.get(la.affaire__c) && 
                   t.Centre_Section__c == la.Centre_Section__c &&
                   t.date_de_debut__c  <= d1 && 
                   t.date_de_fin__c  >= d1  ) {
                  t_correct=t ; 
                  break ;     
               }   
            }

            
            // Hope we found the correct line
            if(t_correct!=null) {
                // If we are in Garantie, the rate is 1
                Double tx_pri     = t_correct.Taux_engage_conversion_PRI__c;
                Double tx_complet = t_correct.Taux_engage_conversion_complet__c;                

                if(!MapAffFGX.get(la.affaire__c))
                     tx_pri=1;

                if(!MapAffK3.get(la.affaire__c)) 
                     tx_complet=tx_pri;
                    

                decimal Heures  = (la.Heures__c  == null ? 0 :la.Heures__c  );
                la.debours__c = Heures * t_correct.taux_engage_horaire__c.setscale(2);
                la.PRI__c     = (la.debours__c * tx_pri).setscale(2);
                la.complet__c = (la.debours__c * tx_complet).setscale(2);                
            }       
            // If we are in EUR,we don't have to do any currency conversion
            if(MapAffCurrency.get(la.affaire__c)=='EUR') {
                la.debours_E__c = la.debours__c ; 
                la.PRI_E__c     = la.PRI__c ; 
                la.complet_E__c = la.Complet__c ;                 
            } else {
                // We are in a currency
                // So let's loop until we find the correct line
                DatedConversionRate r_correct = null ; 
                for(DatedConversionRate r: currencyTypeList) {
                    if(r.IsoCode==MapAffCurrency.get(la.affaire__c) &&
                       r.StartDate<=la.date__c && 
                       r.NextStartDate>=la.date__c) {
                        r_correct = r;
                        break ; 
                    }
                }
                if(r_correct!=null) {
                    if(la.debours__c!=null) {
                        la.debours_E__c=(la.debours__c*(1/r_correct.ConversionRate)).SetScale(2);
                    }
                    if(la.PRI__c!=null) {
                        la.PRI_E__c=(la.PRI__c*(1/r_correct.ConversionRate)).SetScale(2);
                    }
                    if(la.complet__c!=null) {
                        la.complet_E__c=(la.complet__c*(1/r_correct.ConversionRate)).SetScale(2);
                    }
                }
            }
        }           
    }
}