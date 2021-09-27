/*
* @author: Henri Saslawsky
* @description: 
*/

public class VI01_VIFacture {

    /*
* @description: Method to fill up the Periode_comptable at the insert of the line
* 
* @param: List of VIFacture
* @return : void
* 
*/

    public static void Load_period (List <VIFacture__c> listFa) { 
        // Let's load all thxe involved Affaire. 
        List<string>ListIdAffaire = new List<string>();
        date date_minimum=null ; 
        date date_maximum=null ; 

        VIParametres__c param = VIParametres__c.getInstance(UserInfo.getUserId());          
        
        for(VIFacture__c fa:ListFa) {
            listIdAffaire.add(fa.affaire__c);
            Date d1 = fa.date__c ; 

            if(d1==null)
                d1=fa.date_de_comptabilisation__c;
            
            if(d1<=date.newinstance(2018,01,01) ) {
               d1=date.newinstance(2018,01,01);
            }
            
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

        if(date_minimum>date.newinstance(2018,01,01))
            date_minimum=date_minimum.addmonths(-1).toStartOfMonth();
        
        date_maximum=date_maximum.addmonths(+2).toStartOfMonth();        

        Map<string,id>MapPeriodeOuverte = new Map<string,id>();

        // Let's load all the open periode
        map<string,VIPeriode__c>MapPeriode = new map<string,VIPeriode__c>();
        for(VIperiode__c pe :[SELECT id, name, toLabel(entite_bw__c),statut__c  
                                FROM VIperiode__c
                               WHERE (date_de_debut__c>=:date_minimum
                                 AND date_de_fin__c<=:date_maximum)
                                  OR statut__c =:VIConstant.PERIODE_OUVERTE]) {
            MapPeriode.put(pe.name,pe);
            if(pe.statut__c==VIConstant.PERIODE_OUVERTE)  {
                MapPeriodeOuverte.put(pe.entite_bw__c,pe.id);
            }                         
        }
        
        
        map<id, string>MapEntite_bw = new map<id, string>();
        map<id,list<Date>>MapDateAffaire = new map<id,list<Date>>();
        for(VIAffaire__c aff: [SELECT id, ToLabel(entite_bw__c), 
                                      date_ouverture_affaire__c,Date_de_fin_de_garantie__c,Date_de_SAV_previsionnelle__c
                                  FROM VIAffaire__c
                                 WHERE id in :ListIdAffaire]) {
            Mapentite_bw.put(aff.id,aff.entite_bw__c);
            list<date>ListDate = new list<date>();
            ListDate.add(aff.date_ouverture_affaire__c.adddays(-5)) ;
            if(aff.Date_de_fin_de_garantie__c!=null) {                         
                ListDate.add(aff.Date_de_fin_de_garantie__c.adddays(5)) ;
            } else {
                if(aff.Date_de_SAV_previsionnelle__c!=null) {
                    ListDate.add(aff.Date_de_SAV_previsionnelle__c.adddays(5)) ;                
                }
            }
            MapDateAffaire.put(aff.id,ListDate);
        }
        
        //Let's load
        for(VIFacture__c fa:ListFa) {
            Date d1 = fa.date__c ; 
            if(d1==null)
                d1=fa.date_de_comptabilisation__c;
            
            if(d1<=date.newinstance(2018,01,01) ) {
               d1=date.newinstance(2018,01,01);
            }
                                          
            string key=string.valueof(d1.Year())+string.valueof(d1.month()).leftpad(2,'0')+MapEntite_bw.get(fa.affaire__c) ;
            VIperiode__C per = MapPeriode.get(key);
          //  if(per.statut__c==VIConstant.PERIODE_FERMEE) {
          //          fa.periode_comptable__c= MapPeriodeOuverte.get(MapEntite_bw.get(fa.affaire__c));
          //  } else {
                    fa.periode_comptable__c= MapPeriode.get(key).id;
          //  }
        }
    }


/*
* @description: Compute the currency rate of the facture
* 
* @param: List of VIFacture
* @return : void
* 
*/ 
    
    public static void Compute_Value (List <VIFacture__c> listFa) {

        list<String> ListCurrency      = new list<string>();
                
        date date_minimum=null; //We don't need the currency rates below this date
        
        // Let's fetch the facture and 
        for(VIFacture__c fa:ListFa){
            ListCurrency.add(fa.currencyIsoCode);
            if(fa.date__c<date_minimum || date_minimum==null)
                date_minimum=fa.date__c;
        }
        
        // Let's fetch the currency rates needed
        List<DatedConversionRate> currencyTypeList = [SELECT Id, IsoCode, ConversionRate, StartDate, NextStartDate 
                                                        FROM DatedConversionRate 
                                                       WHERE IsoCode in :ListCurrency
                                                         AND (NextStartDate>:date_minimum or NextStartDate>9998-01-01 ) 
                                                    ORDER BY IsoCode, NextStartDate DESC];
        

        for(VIFacture__c fa:Listfa){
            
            // If we are in EUR,we don't have to do any currency conversion
            if(fa.currencyIsoCode=='EUR') {
                fa.Montant_HTE__c = fa.Montant_HT__c ; 
                fa.Montant_TVAE__c = fa.Montant_TVA__c ; 
                fa.Montant_TTCE__c = fa.Montant_TTC__c ; 
                fa.Montant_PayeE__c = fa.Montant_Paye__c ;                 
            } else {
                // We are in a currency
                // So let's loop until we find the correct line
                DatedConversionRate r_correct = null ; 
                for(DatedConversionRate r: currencyTypeList) {
                    if(r.IsoCode==fa.currencyIsoCode &&
                       r.StartDate<=fa.date__c && 
                       r.NextStartDate>=fa.date__c) {
                        r_correct = r;
                        break ; 
                    }
                }
                if(r_correct!=null) {
                    if(fa.Montant_HT__c!=null) {
                        fa.Montant_HTE__c=(fa.Montant_HT__c*(1/r_correct.ConversionRate)).SetScale(2);
                    }
                    if(fa.Montant_TVA__c!=null) {
                        fa.Montant_TVAE__c=(fa.Montant_TVA__c*(1/r_correct.ConversionRate)).SetScale(2);
                    }
                    if(fa.Montant_TTC__c!=null) {
                        fa.Montant_TTCE__c=(fa.Montant_TTC__c*(1/r_correct.ConversionRate)).SetScale(2);
                    }
                    if(fa.Montant_Paye__c!=null) {
                        fa.Montant_PayeE__c=(fa.Montant_Paye__c*(1/r_correct.ConversionRate)).SetScale(2);
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
    public static list<id> ReProcess_LA (List <VIFacture__c> listFac) { 

        system.debug('entrée dans reprocess_la');
        Map<id,id>MapIDAff = new Map<id,id>();
        for(VIfacture__c fac : listFac) {
            MapIDAff.put(fac.affaire__c,fac.affaire__c);   // NE faire le recalcul que quand ça vaut le coup
        }

        return MapIDAff.values() ;


    }


}