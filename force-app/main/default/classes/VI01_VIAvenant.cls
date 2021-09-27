/*
* @author: Henri Saslawsky
* @description: 
*/

public class VI01_VIAvenant {

/*
* @description: Method to fill up the Periode_comptable at the insert of the line
* 
* @param: List of VIAvenant
* @return : void
* 
*/

    public static void Load_period (List <VIAvenant__c> listAv) { 
        system.debug('Avenant Load_period');
        // Let's load all thxe involved Affaire. 
        List<string>ListIdAffaire = new List<string>();
        date date_minimum=null ; 
        date date_maximum=null ; 

        VIParametres__c param = VIParametres__c.getInstance(UserInfo.getUserId());  
        
        for(VIAvenant__c av:ListAv) {
            listIdAffaire.add(av.affaire__c);
            if(date_minimum==null || date_minimum>av.Date__c)
                date_minimum=av.Date__c ; 
                                                       
            if(date_maximum==null || date_maximum<av.Date__c)
                date_maximum=av.Date__c ; 
        }
        date_minimum=date_minimum.addmonths(-2).toStartOfMonth();
        date_maximum=date_maximum.addmonths(+2).toStartOfMonth();        
        date_maximum=system.today().addmonths(+2).toStartOfMonth();                
        
        Map<string,VIPeriode__c>MapPeriodeOuverte = new Map<string,VIPeriode__c>();

        // Let's load all the open periode
        map<string,VIPeriode__c>MapPeriode = new map<string,VIPeriode__c>();
        for(VIperiode__c pe :[SELECT id, name, tolabel(entite_bw__c),statut__c  
                                FROM VIperiode__c
                               WHERE (date_de_debut__c>=:date_minimum
                                 AND date_de_fin__c<=:date_maximum)
                                  OR statut__c =:VIConstant.PERIODE_OUVERTE
                            ORDER BY date_de_debut__c]) {
            MapPeriode.put(pe.name,pe);
            if(pe.statut__c==VIConstant.PERIODE_OUVERTE)  {
                MapPeriodeOuverte.put(pe.entite_bw__c,pe);  
            }                         
        }
        
        
        map<id, string>MapEntite_bw = new map<id, string>();
        map<id,list<Date>>MapDateAffaire = new map<id,list<Date>>();
        for(VIAffaire__c aff: [SELECT id, ToLabel(entite_bw__c), 
                                      date_ouverture_affaire__c,Date_de_fin_de_garantie__c,date_de_sav_reelle__c, Date_max_mouvement__c 
                                  FROM VIAffaire__c
                                 WHERE id in :ListIdAffaire]) {
            MapEntite_bw.put(aff.id,aff.entite_bw__c);
            list<date>ListDate = new list<date>();
            ListDate.add(aff.date_ouverture_affaire__c.addmonths(-1)) ;
            date date_max ;                          
            if(aff.Date_de_fin_de_garantie__c<aff.date_ouverture_affaire__c) {
                date_max = aff.date_ouverture_affaire__c ;                
            }  else {                        
                date_max = aff.Date_de_fin_de_garantie__c ;
            }
            if(date_max<aff.Date_max_mouvement__c)                         
                date_max = aff.Date_max_mouvement__c ;

            date_max=system.today().addmonths(+2).toStartOfMonth();                                           
            ListDate.add(date_max);
            ListDate.add(aff.date_de_sav_reelle__c);                         
                                     
            MapDateAffaire.put(aff.id,ListDate);
        }
        
        //Let's load
        for(VIAvenant__c av:ListAv) {
            date date_min = MapDateAffaire.get(av.affaire__c)[0];
            date date_max = MapDateAffaire.get(av.affaire__c)[1];
            date date_sav_reelle = MapDateAffaire.get(av.affaire__c)[2];
            
           system.debug(av.date__c + ' '+ date_min+ ' '+ date_max );
            if(av.date__c<date_min || av.date__c>date_max) {
                if(!param.Sans_Calcul_de_PRI__c)
                    av.AddError(label.VIErreur008+av.name+' '+av.affaire__C);                
            } else {
                string key=string.valueof(av.date__c.Year())+string.valueof(av.date__c.month()).leftpad(2,'0')+MapEntite_bw.get(av.affaire__c) ;
                VIperiode__C per = new VIperiode__C();
                if(MapPeriode.containskey(key)) {
                    av.periode_comptable__c= MapPeriode.get(key).id;
                } else {
                    if(av.date__c<date.newinstance(2018,01,01)) {
                        av.periode_comptable__c= MapPeriode.get('201801'+MapEntite_bw.get(av.affaire__c)).id;
                    } else {
                        av.periode_comptable__c= MapPeriodeOuverte.get(MapEntite_bw.get(av.affaire__c)).id;
                    } 
                }
            }
        }
    }


/*
* @description: From Debours, we need to compute "industriel" and "complet"
* 
* @param: List of VIPointage
* @return : void
* 
*/ 
    
    public static void Compute_Value (List <VIAvenant__c> listAv) {
        list<String> ListCurrency      = new list<string>();
        date date_minimum=null; //We don't need the currency rates below this date

                        
        
        // Let's fetch the affaire and centre
        for(VIAvenant__c av:ListAv){
            ListCurrency.add(av.currencyIsoCode);
            if(av.date__c==null || av.date__c<date_minimum) 
                date_minimum=av.date__c ;
        }

        
        // Let's fetch the currency rates needed
        List<DatedConversionRate> currencyTypeList = [SELECT Id, IsoCode, ConversionRate, StartDate, NextStartDate 
                                                        FROM DatedConversionRate 
                                                       WHERE IsoCode in :ListCurrency
                                                         AND (NextStartDate>:date_minimum or NextStartDate>9998-01-01 ) 
                                                    ORDER BY IsoCode, NextStartDate DESC];
        

        for(VIAvenant__c la:ListAv){
            if(la.date__c.year()<2021)
                continue; 
           
            // If we are in EUR,we don't have to do any currency conversion
            if(la.currencyIsoCode=='EUR') {
                la.PV_E__c = la.PV__c ; 
            } else {
                // We are in a currency
                // So let's loop until we find the correct line
                DatedConversionRate r_correct = null ; 
                for(DatedConversionRate r: currencyTypeList) {
                    if(r.IsoCode==la.currencyIsoCode &&
                       r.StartDate<=la.date__c && 
                       r.NextStartDate>=la.date__c) {
                        r_correct = r;
                        break ; 
                    }
                }
                if(r_correct!=null) {
                    if(la.PV__c!=null) {
                        la.PV_E__c=(la.PV__c*(1/r_correct.ConversionRate)).SetScale(2);
                    }
                }
            }
        }     
    } 
    
/*
* @description: From Avenant, we need to check (or not) the RAD field in Affaire
* 
* @param: List of VIAvenant old, new
* @return : void
* 
*/ 
    public static void process_RAD (List <VIAvenant__c> listNewAv,Map <id,VIAvenant__c> MapOldAv) { 

        system.debug('entrée dans process_RAD');
        List<string>ListIDAffaire = new List<string>();
        for(VIAvenant__c av :listNewAv) {
            ListIDAffaire.add(av.affaire__c);
        }
        Map<string, VIAffaire__c>MapAffaire = new Map<string, VIAffaire__c>();
        for(VIAffaire__c aff: [SELECT id , Cycle_RAD__c, Produit_SousDomaine__r.RAD__c,Produit_SousDomaine__r.Type_d_imputation__c 
                                 FROM VIAffaire__c
                                WHERE id in :ListIDAffaire ]) {
            MapAffaire.put(aff.id, aff)  ;
        }
        list<VIAffaire__c>ListUpdateAffaire = new list<VIAffaire__c>();
        for(VIAvenant__c av :listNewAv) {
            if(av.Statut_avenant__c==VIConstant.AVENANT_EN_COURS  && MapOldAv.get(av.Id).Statut_avenant__c==VIConstant.AVENANT_PREVU) {
                // it's a new avenant
                VIAffaire__C aff = MapAffaire.get(av.affaire__c);
                if( aff.Produit_SousDomaine__r.Type_d_imputation__c=='4' && 
                    aff.Produit_SousDomaine__r.RAD__c<av.PV__c ) {
                        aff.cycle_rad__c=true ;
                        ListUpdateAffaire.add(aff);
                }
                
            }
        }
        if(ListUpdateAffaire.size()>0)
            update ListUpdateAffaire;
        
        
        return  ;
    }    

    
    
    
/*
* @description: From Avenant, we need to recompute the Affaire linked
* 
* @param: List of VIAvenant
* @return : void
* 
*/ 
    public static list<id> ReProcess_Aff (List <VIAvenant__c> listAv) { 

        system.debug('entrée dans reprocess_aff');
        Map<id,id>MapIDAff = new Map<id,id>();
        for(VIAvenant__c av : listAv) {
            MapIDAff.put(av.affaire__c,av.affaire__c);   // NE faire le recalcul que quand ça vaut le coup
        }

        return MapIDAff.values() ;
    }    

/*
* @description: "Human users" cannot create avenant like AV* or CI
* 
* @param: List of VIAvenant
* @return : void
* 
*/ 
    public static boolean Kind_of_user (List <VIAvenant__c> listAv) { 
        system.debug('Avenant Kind_of_user');
        boolean check =false ; 
        
        List<PermissionSetAssignment> lstcurrentUserPerSet =    [   SELECT Id, PermissionSet.Name,AssigneeId
                                                                      FROM PermissionSetAssignment
                                                                     WHERE AssigneeId = :Userinfo.getUserId() ];
        boolean Admin=false ; 
        for (PermissionSetAssignment psa: lstcurrentUserPerSet) {
            if(psa.PermissionSet.Name.equals('VI_Admin')) {
                Admin = true;                
            }
        }        
        
        
        Map<string,VIavenant__c>MapAvenant = new Map<string,VIavenant__c>();
        list<id>ListIDAffaire = new list<id>();
        for(VIAvenant__c av:ListAv) {
            ListIDAffaire.add(av.affaire__c);
        }
        for(VIAvenant__c av:[SELECT Affaire__c, code_avenant__c 
                               FROM VIAvenant__c
                             WHERE Affaire__c in :ListIDAffaire ]) {
            MapAvenant.put(av.affaire__c+'/'+av.code_avenant__c,av);
        }
        
        for(VIAvenant__c av:ListAv) {
            if(!Admin && (av.code_avenant__c=='CI' || av.code_avenant__c.startswith('AV-'))) {
                av.AddError(label.VIErreur017+' '+av.code_avenant__c);
                check=true ; 
            }
            if(MapAvenant.containskey(av.affaire__c+'/'+av.code_avenant__c)) {
                av.AddError(label.VIErreur018+' '+av.code_avenant__c);
                check=true ; 
            }
        }

        return check; 
    }

    
}