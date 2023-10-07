/*
* @author: Henri Saslawsky
* @description: 
*/

public class VI01_Ligne_affaire {


/*
* @description: Method to check if it's possible to delete the Ligne d'affaire
* 
* @param: List of VILigne_affaire
* @return : true or false
* 
*/

    public static boolean CanDelete (List <VILigne_Affaire__c> listLa) { 

        system.debug('entrée dans VI01_Ligne_affaire.CanDelete');
        boolean check =false ;        
        VIParametres__c param = VIParametres__c.getInstance(UserInfo.getUserId()); 
        if(!param.Sans_Calcul_de_PRI__c) {                 
            for(VILigne_Affaire__c La:listLa){
                if(la.Cout_terminaison_MontantD__c!=0) {
                    la.AddError(label.VIErreur005);
                    check=true ; 
                }
            }
        }        
        return check;
    }
    

/*
* @description: Method to compute the total on VILigne_affaire from VIligne_affaire
* 
* @param: List of VILigne_affaire
* @return : void
* 
*/
    public static list<string> ReProcess_LA (List <VILigne_affaire__c> listLa, Map<id,VILigne_affaire__c> MapOldLa) { 

        system.debug('entrée dans VI01_Ligne_affaire.reprocess_la');
        Map<string,string>MapIDAff = new Map<string,string>();
        list<id>ListIDLAM = new List<id>();
        
        // We recompute the LAM only when the LA is deleted, or when the Ecart_C_A_F_MontantD__c is modified
        for(VILigne_affaire__c la : listLa) { 
            if(MapOldLa==null ) {
                ListIDLAM.add(la.ligne_d_affaire_mensuelle__c); 
            } else {
                VILigne_affaire__c oldLA = MapOldLa.get(la.ID);
                if(la.Ecart_C_A_F_MontantD__c != oldLA.Ecart_C_A_F_MontantD__c) {
                    ListIDLAM.add(la.ligne_d_affaire_mensuelle__c); 
                }
            }
        }
        for(VIligne_d_affaire_mensuelle__c lam : [SELECT affaire__r.name 
                                                    FROM VIligne_d_affaire_mensuelle__c
                                                  WHERE id in :ListIDLAM ]) {
            MapIDaff.put(lam.affaire__r.name,lam.affaire__r.name);
        } 
        return MapIDaff.values() ;
    }
    
    
    
/*
* @description: From Debours, we need to compute "industriel" and "complet"
* 
* @param: List of Ligne_affaire
* @return : void
* 
*/ 
    
    public static void Compute_Value (List <VILigne_affaire__c> listLA) {
        system.debug('entrée dans VI01_Ligne_affaire.Compute_Value');
        
        list<String> ListEntite_bw     = new list<string>();
        list<String> ListCurrency      = new list<string>();
        list<String> ListCentreSection = new list<string>(); 
        list<String> ListTypeDepense   = new list<string>(); 
        list<String> ListLAM       = new list<string>();         

        date date_minimum=system.today().addmonths(-5); //We don't need the currency rates below this date
        string MOid=[SELECT id FROM VItype_de_depense__c WHERE name like 'MO %' LIMIT 1][0].id;
        
        
        for(VILigne_affaire__c la:ListLA){
            ListEntite_bw.add(la.entite_bw__c);
            ListCurrency.add(la.CurrencyIsoCode);
            ListCentreSection.add(la.Centre_Section__c);  
            ListTypeDepense.add(la.Type_Depense__c);
            ListLAM.add(la.Ligne_d_affaire_mensuelle__c );
        }

        Map<string,VILigne_d_affaire_mensuelle__c >MapLam = new  Map<string,VILigne_d_affaire_mensuelle__c >();
        for(VILigne_d_affaire_mensuelle__c lam: [SELECT id, affaire__r.produit_sousdomaine__c,Periode_comptable__r.date_de_debut__c
                                                   FROM VILigne_d_affaire_mensuelle__c
                                                 WHERE id in:ListLAM]) {
            MapLam.put(lam.id,lam);                                             
        }
        
        
        // I can only modify the LA for the current period. So all the rates are the rates of the open period
        Map<string,date>MapDate = new Map<string,date>();
        for(VIPeriode__c per:[SELECT id,name, entite_bw__c, date_de_debut__c
                                   FROM VIPeriode__c
                                  WHERE entite_bw__c in :ListEntite_bw
                                    AND Statut__c=:VIConstant.PERIODE_OUVERTE]) {
            MapDate.put(per.entite_bw__c,per.date_de_debut__c);
        }     
        
        // Let's fetch the currency rates needed
        List<DatedConversionRate> currencyTypeList = [SELECT Id, IsoCode, ConversionRate, StartDate, NextStartDate 
                                                        FROM DatedConversionRate 
                                                       WHERE IsoCode in :ListCurrency
                                                         AND (NextStartDate<:date_minimum or NextStartDate>9998-01-01 ) 
                                                    ORDER BY IsoCode, NextStartDate DESC];
        

        // Let's fetch all the rates we need to use later
        // WHERE entite_bw__c in :Listentite_bw  AND CurrencyIsoCode in :ListCurrency
        //                  AND Centre_Section__c in :ListCentreSection
        // 
        list<VITauxHoraire__c>ListTaux = new List<VItauxHoraire__c>();
        for(VItauxHoraire__c t:[SELECT Centre_Section__c,entite_bw__c, CurrencyIsoCode,Date_de_debut__c,Date_de_fin__c,
                                       taux_devis_horaire__c , Taux_devis_conversion_PRI__c , Taux_devis_conversion_complet__c
                                  FROM VItauxHoraire__c
                                 WHERE centre_section__c in :ListCentreSection]) {
              ListTaux.add(t);             
         }

        list<VITauxIncorporation__c>ListTauxIncorporation = new List<VITauxIncorporation__c>();

        for(VITauxIncorporation__c t:[SELECT CurrencyIsoCode,Date_de_debut__c,Date_de_fin__c,
                                             Produit_SousDomaine__c  , Type_de_depense__c ,
                                             Taux_PRI__c , Taux_complet__c, entite_bw__c   
                                        FROM VITauxIncorporation__c
                                       WHERE CurrencyIsoCode in :ListCurrency
                                         AND Type_de_depense__c in :ListTypeDepense
                                         AND entite_bw__c in :ListEntite_bw
                                         AND date_de_debut__c<=:date_minimum
                                         AND date_de_fin__c>=:date_minimum ]) {
              ListTauxIncorporation.add(t);             
         }
        
        
        for(VILigne_affaire__c la:ListLA){

            if(la.type_depense__c==MOid) {
               // We need to find the correct line in the list
                VItauxHoraire__c t_correct = new VItauxHoraire__c();
                t_correct = null;
                for(VItauxHoraire__c t:ListTaux) {
                    if(t.CurrencyIsoCode   == la.CurrencyIsoCode && 
                       t.Centre_Section__c == la.Centre_Section__c   &&
                       t.date_de_debut__c  <= MapDate.get(la.entite_bw__c)	 && 
                       t.date_de_fin__c    >= MapDate.get(la.entite_bw__c)  ) {
                      t_correct=t ; 
                      break ;     
                   }   
                }
                // Hope we found the correct line
                if(t_correct!=null) {                
                    decimal nb_heure_ecart = (la.Ecart_C_A_F_Heure__c  == null ? 0 :la.Ecart_C_A_F_Heure__c  );
                    la.Ecart_C_A_F_MontantD__c  = nb_heure_ecart * t_correct.taux_devis_horaire__c ;
                    la.Ecart_C_A_F_MontantI__c  =la.Ecart_C_A_F_MontantD__c*t_correct.Taux_devis_conversion_PRI__c;
                    la.Ecart_C_A_F_MontantC__c  =la.Ecart_C_A_F_MontantD__c*t_correct.Taux_devis_conversion_Complet__c;                
                }    
            }  else {
                VItauxIncorporation__c t_correct = new VItauxIncorporation__c();
                t_correct = null;
                for(VItauxIncorporation__c t:ListTauxIncorporation) {
                    
                    if(t.entite_bw__c   == la.entite_bw__c	 && 
                       t.Produit_SousDomaine__c == MapLam.get(la.Ligne_d_affaire_mensuelle__c ).affaire__r.Produit_SousDomaine__c &&
                       t.type_de_depense__c == la.type_depense__c &&                       
                       t.date_de_debut__c  <= MapLam.get(la.Ligne_d_affaire_mensuelle__c).Periode_comptable__r.date_de_debut__c && 
                       t.date_de_fin__c  >= MapLam.get(la.Ligne_d_affaire_mensuelle__c).Periode_comptable__r.date_de_debut__c  ) {
                      t_correct=t ; 
                      break ;     
                   }   
                }
                // Hope we found the correct line
                if(t_correct!=null) {
                    la.Ecart_C_A_F_MontantI__c  =la.Ecart_C_A_F_MontantD__c*t_correct.Taux_PRI__c;
                    la.Ecart_C_A_F_MontantC__c  =la.Ecart_C_A_F_MontantD__c*t_correct.Taux_complet__c;                
                } else {
                    la.Ecart_C_A_F_MontantI__c  =la.Ecart_C_A_F_MontantD__c;
                    la.Ecart_C_A_F_MontantC__c  =la.Ecart_C_A_F_MontantD__c;                
                    
                }               
            }               
            // If we are in EUR,we don't have to do any currency conversion
            if(la.CurrencyIsoCode=='EUR') {
                la.Ecart_C_A_F_MontantD_E__c=la.Ecart_C_A_F_MontantD__c;                
                la.Ecart_C_A_F_MontantI_E__c=la.Ecart_C_A_F_MontantI__c;                
                la.Ecart_C_A_F_MontantC_E__c=la.Ecart_C_A_F_MontantC__c;                                
            } else {
                // We are in a currency
                // So let's loop until we find the correct line
                DatedConversionRate r_correct = null ; 
                for(DatedConversionRate r: currencyTypeList) {
                    if(r.IsoCode==la.CurrencyIsoCode &&  
                       r.StartDate<=MapDate.get(la.entite_bw__c) &&  
                       r.NextStartDate>=MapDate.get(la.entite_bw__c)) {
                        r_correct = r;
                        break ; 
                    }
                }
                if(r_correct!=null) {
                    if(la.Ecart_C_A_F_MontantD__c!=null) {
                        la.Ecart_C_A_F_MontantD_E__c=la.Ecart_C_A_F_MontantD__c*(1/r_correct.ConversionRate).SetScale(2);                
                        la.Ecart_C_A_F_MontantI_E__c=la.Ecart_C_A_F_MontantI__c*(1/r_correct.ConversionRate).SetScale(2);                
                        la.Ecart_C_A_F_MontantC_E__c=la.Ecart_C_A_F_MontantC__c*(1/r_correct.ConversionRate).SetScale(2);                                
                    }
                }
            }
        }  
    }
    
}