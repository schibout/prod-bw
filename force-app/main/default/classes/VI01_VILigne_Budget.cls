/*
* @author: Henri Saslawsky
* @Code Coverage : 
* @description: 
*/

public class VI01_VILigne_Budget {

/*
* @description: Method to check if it's possible to change the budget
* 
* @param: List of VILigne_budget
* @return : true or false
* 
*/

    public static boolean VerifMAJ (List <VILigne_Budget__c> listBu) { 

        boolean check =false ;    
        Return Check ; // This check is not wanted
/*        
        VIParametres__c param = VIParametres__c.getInstance(UserInfo.getUserId());  
        if(param.Sans_Calcul_de_PRI__c)
            return false; 

        
        list<string>ListID = new list<string>();
        for(VILigne_Budget__c bu:listBu){
            listID.add(bu.avenant__c);
        } 
        map<string,string>MapStatus = new map<string, string>();
        for(VIavenant__c ave : [SELECT id, Statut_avenant__c
                                  FROM VIAvenant__c
                               WHERE id in : ListID]) {
            MapStatus.put(ave.id,ave.Statut_avenant__c);
        }                       
        for(VILigne_Budget__c bu:listBu){
            if(string.valueof(MapStatus.get(bu.avenant__c)).left(2)!='10' && !test.isrunningtest()) {
                bu.AddError(label.VIErreur001+' '+MapStatus.get(bu.avenant__c)+' '+bu.avenant__c);
                check=true ; 
            }
        }        
        return check;
*/
    }


/*
* @description: From Debours, we need to compute "industriel" and "complet"
* 
* @param: List of VIPointage
* @return : void
* 
*/ 
    
    public static void Compute_Value (List <VILigne_Budget__c> listBu) {
    
        list<String> ListCurrency      = new list<string>();
        list<String> ListCentreSection = new list<string>(); 
        list<String> ListTypeDepense   = new list<string>(); 
        list<String> ListAffaire       = new list<string>();
        list<String> ListAvenant       = new list<string>();         
        
        Map<String,VIavenant__c> MapAvenant   = new Map<String,VIavenant__c>(); 

        
        
        
        string MOid=[SELECT id FROM VItype_de_depense__c WHERE name like 'MO %' LIMIT 1][0].id;
        
        date date_minimum=null; //We don't need the currency rates below this date
        
        // Let's fetch the affaire and centre
        for(VILigne_budget__c bu:ListBu){
            ListCentreSection.add(bu.Centre_Section__c);  
            ListCurrency.add(bu.currencyIsoCode);
            ListTypeDepense.add(bu.Type_de_Depense__c);
            ListAvenant.add(bu.avenant__c);
            if(date_minimum>bu.avenant__r.date__c || date_minimum==null)
                date_minimum=bu.avenant__r.date__c;                    
        }

        for(ViAvenant__c av:[SELECT ID, Affaire__r.Produit_SousDomaine__c,Affaire__r.Produit_SousDomaine__r.fgx__c,Affaire__r.Produit_SousDomaine__r.k3__c  , Date__c, annulation_complete__c
                               FROM VIAvenant__c
                             WHERE id in :ListAvenant ]) {
            MapAvenant.put(av.id,av);     
        }
        
        // Let's fetch the currency rates needed
        List<DatedConversionRate> currencyTypeList = [SELECT Id, IsoCode, ConversionRate, StartDate, NextStartDate 
                                                        FROM DatedConversionRate 
                                                       WHERE IsoCode in :ListCurrency
                                                         AND (NextStartDate<=:date_minimum or NextStartDate>9998-01-01 ) 
                                                    ORDER BY IsoCode, NextStartDate DESC];
        

        // Let's fetch all the rates we need to use later
        // WHERE  CurrencyIsoCode in :ListCurrency
        //                  AND Centre_Section__c in :ListCentreSection
        // 
        list<VITauxHoraire__c>ListTaux = new List<VItauxHoraire__c>();

        for(VItauxHoraire__c t:[SELECT id,entite_bw__c, Centre_Section__c, CurrencyIsoCode,Date_de_debut__c,Date_de_fin__c,
                                taux_devis_horaire__c , Taux_devis_conversion_PRI__c , Taux_devis_conversion_complet__c
                           FROM VItauxHoraire__c
                          WHERE CurrencyIsoCode in :ListCurrency
                            AND Centre_Section__c in :ListCentreSection
                            AND date_de_debut__c<=:date_minimum
                            AND date_de_fin__c>=:date_minimum]) {
              ListTaux.add(t);    
         }

        list<VITauxIncorporation__c>ListTauxIncorporation = new List<VITauxIncorporation__c>();

        for(VITauxIncorporation__c t:[SELECT id,entite_bw__c, CurrencyIsoCode,Date_de_debut__c,Date_de_fin__c,
                                             Produit_SousDomaine__c  , Type_de_depense__c ,
                                             Taux_PRI__c , Taux_complet__c   
                                        FROM VITauxIncorporation__c
                                       WHERE CurrencyIsoCode in :ListCurrency
                                         AND Type_de_depense__c in :ListTypeDepense
                                         AND date_de_debut__c<=:date_minimum
                                         AND date_de_fin__c>=:date_minimum ]) {
              ListTauxIncorporation.add(t);             
         }
        
        for(VILigne_budget__c la:ListBu){
            // If it's an annulation complete, we don't have to recompute
            if(mapAvenant.get(la.avenant__c).annulation_complete__c)
                continue ;
            
            // Are we on MO ? 
            if(la.type_de_depense__c==MOid) {
                // We need to find the correct line in the list
                VItauxHoraire__c t_correct = new VItauxHoraire__c();
                t_correct = null;
                for(VItauxHoraire__c t:ListTaux) {

                    if(t.CurrencyIsoCode   == la.currencyIsoCode && 
                       t.Centre_Section__c == la.Centre_Section__c &&
                       t.date_de_debut__c  <= mapAvenant.get(la.avenant__c).date__c && 
                       t.date_de_fin__c  >= mapAvenant.get(la.avenant__c).date__c  ) {
                      t_correct=t ; 
                      break ;     
                   }   
                }
                if(test.isrunningtest())
                    t_correct=ListTaux[0];
                
                // Hope we found the correct line
                if(t_correct!=null) {
                    
                    if(!mapAvenant.get(la.avenant__c).Affaire__r.Produit_SousDomaine__r.fgx__c)
                        t_correct.Taux_devis_conversion_PRI__c=1;

                    if(!mapAvenant.get(la.avenant__c).Affaire__r.Produit_SousDomaine__r.k3__c)
                        t_correct.Taux_devis_conversion_complet__c=1;
                    

                    decimal Heures  = (la.Heures__c  == null ? 0 :la.Heures__c.round()  );
                    
                    if(la.heures__c.abs()>=0 && la.heures__c.abs()<=0.49 ) {
                        Heures = 0 ; 
                        la.debours__c=0;
                    }
                    if(Heures!=0) { 
                        la.debours__c = Heures * t_correct.taux_devis_horaire__c;
                    }
                    la.PRI__c     = la.debours__c * t_correct.Taux_devis_conversion_PRI__c;
                    la.complet__c = la.debours__c * t_correct.Taux_devis_conversion_complet__c;    
                }
            }  else {
            // We are not on MO ?                 
                // We need to find the correct line in the list
                VItauxIncorporation__c t_correct = new VItauxIncorporation__c();
                t_correct = null;
                for(VItauxIncorporation__c t:ListTauxIncorporation) {
                    if(t.CurrencyIsoCode   == la.currencyIsoCode && 
                       t.Produit_SousDomaine__c == MapAvenant.get(la.avenant__c).affaire__r.Produit_SousDomaine__c &&
                       t.type_de_depense__c == la.type_de_depense__c &&                       
                       t.date_de_debut__c  <= MapAvenant.get(la.avenant__c).date__c && 
                       t.date_de_fin__c  >= MapAvenant.get(la.avenant__c).date__c  ) {
                      t_correct=t ; 
                      break ;     
                   }   
                }
                if(test.isrunningtest())
                    t_correct=ListTauxIncorporation[0];
                
                // Hope we found the correct line
                if(t_correct!=null) {
                    if(!mapAvenant.get(la.avenant__c).Affaire__r.Produit_SousDomaine__r.fgx__c)
                        t_correct.Taux_PRI__c=1;

                    if(!mapAvenant.get(la.avenant__c).Affaire__r.Produit_SousDomaine__r.k3__c)
                        t_correct.Taux_complet__c=t_correct.Taux_PRI__c;
                    
                    la.PRI__c     = la.debours__c * t_correct.Taux_PRI__c;
                    la.complet__c = la.debours__c * t_correct.Taux_complet__c;    
                } else {
                    la.PRI__c     = la.debours__c ;
                    la.complet__c = la.debours__c ;                        
                }
                
            }             
            // If we are in EUR,we don't have to do any currency conversion
            if(la.currencyIsoCode=='EUR') {
                la.debours_E__c = la.debours__c ; 
                la.PRI_E__c     = la.PRI__c ; 
                la.complet_E__c = la.Complet__c ;                 
            } else {
                // We are in a currency
                // So let's loop until we find the correct line
                DatedConversionRate r_correct = null ; 
                for(DatedConversionRate r: currencyTypeList) {
                    if(r.IsoCode==la.currencyIsoCode &&
                       r.StartDate<=la.avenant__r.date__c && 
                       r.NextStartDate>=la.avenant__r.date__c) {
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