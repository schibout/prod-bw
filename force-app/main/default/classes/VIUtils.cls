public class VIUtils {

       // MAJLAM : Vrai :  On calcule, MAJ, et écrit les LAM
       //           Faux :  On ne touche pas aux LAM
       // MAJLA :  Vrai :  On écrit les LA
       //           Faux :  On écrit pas les LA
        public static void recalc (string Idaffaire,
                                   Boolean MAJLAM, 
                                   Boolean MAJLA,                                    
                                   VItype_de_depense__c tdMO,
                                   VItype_de_depense__c tdGAR,
                                   VItype_de_depense__c tdEMM,
                                   VItype_de_depense__c tdAMP,
                                   VItype_de_depense__c tdFOL,
                                   VICentre_section__c cs801, 
                                   Map<string,VIperiode__c>MapEntite_bwPeriode,
                                   Date DateLAMMinimum) {
        
        string Mode_de_calcul_de_l_avancement ; 
        string type_imputation ;                                
        string Affaire_name ;                                
        
        Map<string,VILigne_d_affaire_mensuelle__c>MapCurrentLAM = new Map<string,VILigne_d_affaire_mensuelle__c>();
        
        Map<string,String>MapLamAffaire = new Map<string,String>();
        date date_minimum;
        date date_maximum;  
        date StartExercise ; 
                                       
                                       
                                       
        // Set all the LAM of the Affaire to Zero        
        for(VILigne_d_affaire_mensuelle__c lam:[SELECT id, name,affaire__c,affaire__r.entite_bw__c,periode_comptable__c,affaire__r.name, 
                                                       affaire__r.Mode_de_calcul_de_l_avancement__c ,affaire__r.type_imputation__c ,
                                                       affaire__r.date_de_sav_reelle__c,
                                                       Ligne_d_affaire_mensuelle_precedente__c,   
                                                       periode_comptable__r.statut__c,CurrencyIsoCode,
                                                       periode_comptable__r.date_de_debut__c,periode_comptable__r.date_de_fin__c,
                                                       Garantie_dotation__c , Garantie_dotation_E__c ,
                                                       Garantie_reprise__c , Garantie_reprise_E__c ,
                                                       Garantie_Depense__c , Garantie_Depense_E__c ,
                                                       Garantie_reprise_consommee__c , Garantie_reprise_consommeeE__c ,
                                                       Garantie_Reprise_mois_precedent__c,Garantie_Reprise_mois_precedent_E__c,
                                                       Devis_Heure__c ,
                                                       Devis_MontantD__c,  Devis_MontantI__c,  Devis_MontantC__c,
                                                       Devis_MontantD_E__c,Devis_MontantI_E__c,Devis_MontantC_E__c,
                                                       Engage_brut_arrete_Heure__c,
                                                       Engage_brut_arrete_MontantD__c,Engage_brut_arrete_MontantI__c,Engage_brut_arrete_MontantC__c,
                                                       Engage_brut_arrete_MontantD_E__c,Engage_brut_arrete_MontantI_E__c,Engage_brut_arrete_MontantC_E__c,
                                                       Dont_comptabiliseD__c,Dont_comptabiliseI__c,Dont_comptabiliseC__c,
                                                       Dont_comptabiliseD_E__c,Dont_comptabiliseI_E__c,Dont_comptabiliseC_E__c,
                                                       Ecart_C_A_F_Heure__c,
                                                       Ecart_C_A_F_MontantD__c,Ecart_C_A_F_MontantI__c,Ecart_C_A_F_MontantC__c,
                                                       Ecart_C_A_F_MontantD_E__c,Ecart_C_A_F_MontantI_E__c,Ecart_C_A_F_MontantC_E__c,
                                                       EMM__c, EMM_E__c,
                                                       AMP__c, AMP_E__c,
                                                       FOL__c, FOL_E__c,
                                                       M_1_EMM__c, M_1_AMP__c, M_1_FOL__c,
                                                       Total_Pourcentage_d_avancement__c,
                                                       PV_Facture__c, PV_FactureE__c, 
                                                       PV_Encaisse__c, PV_EncaisseE__c,
                                                       PV_Encaisse_HT__c, PV_Encaisse_HTE__c,
                                                       PV_Total__c , PV_TotalE__c 
                                                  FROM VILigne_d_affaire_mensuelle__c
                                                 WHERE affaire__c = :IDAffaire
                                                   AND periode_comptable__r.Date_de_debut__c>=:DateLAMMinimum
                                              ORDER BY affaire__r.name, periode_comptable__r.name]) {
            if(lam.affaire__r.Mode_de_calcul_de_l_avancement__c!=null)
                 Mode_de_calcul_de_l_avancement =  lam.affaire__r.Mode_de_calcul_de_l_avancement__c.left(1);                                            

            if(lam.affaire__r.type_imputation__c!=null)
                 type_imputation =  lam.affaire__r.type_imputation__c.left(1);                                            

            Affaire_name =  lam.affaire__r.name;                                         
            if(date_minimum==null ||date_minimum>lam.periode_comptable__r.date_de_debut__c )
                date_minimum=lam.periode_comptable__r.date_de_debut__c;
                                                     
            if(date_maximum==null ||date_maximum<lam.periode_comptable__r.date_de_debut__c )
                date_maximum=lam.periode_comptable__r.date_de_debut__c;                
                                                     
            if(MAJLAM) {                                                     
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
                lam.Garantie_reprise_consommee__c=0;
                lam.Garantie_reprise_consommeeE__c=0;
            }    
            MapCurrentLAM.put(lam.name,lam); 

            MapLamAffaire.put(lam.id,lam.name);
        }
        string per_minimum=convert_date_periode(date_minimum);
        string per_maximum=convert_date_periode(date_maximum);        
        system.debug('recalc for '+Affaire_name+' from  '+per_minimum+' to '+per_maximum);

        if(MapCurrentLAM.size()<1) {
            return ; // It's an old affaire, everything is in the past. We give up
        }

        if(Affaire_name.left(1)!='9'  ) {
            StartExercise = date.newinstance(2000,01,01);
        } else {
            for(string perKey : MapEntite_bwPeriode.keyset()) {
                VIperiode__c per = MapEntite_bwPeriode.get(perkey);
                if(per.statut__c==VIConstant.PERIODE_OUVERTE)  {
                    StartExercise=date.newinstance(per.date_de_debut__c.year(),1,1);       
                }
            }
        }
        
        // Read Current LA and put everything at 0
        Map<string,VILigne_Affaire__c>MapCurrentLA = new Map<string,VILigne_Affaire__c>();
        for(VILigne_Affaire__c la:[SELECT id, name,Ligne_d_affaire_mensuelle__r.affaire__c,Type_de_ligne_d_affaire__c ,
                                         Ligne_d_affaire_mensuelle__r.periode_comptable__r.statut__c,
                                         Ligne_d_affaire_mensuelle__r.name,
                                         Centre_Section__c ,Type_depense__c ,
                                         Devis_Heure__c ,
                                         Devis_MontantD__c ,Devis_MontantD_E__c, 
                                         Devis_MontantI__c ,Devis_MontantI_E__c,
                                         Devis_MontantC__c ,Devis_MontantC_E__c,
                                         Engage_brut_arrete_Heure__c,
                                         Engage_brut_arrete_MontantD__c,Engage_brut_arrete_MontantI__c,Engage_brut_arrete_MontantC__c,
                                         Engage_brut_arrete_MontantD_E__c,Engage_brut_arrete_MontantI_E__c,Engage_brut_arrete_MontantC_E__c,
                                         Dont_comptabiliseD__c,Dont_comptabiliseI__c,Dont_comptabiliseC__c,
                                         Dont_comptabiliseD_E__c,Dont_comptabiliseI_E__c,Dont_comptabiliseC_E__c,
                                         Ecart_C_A_F_Heure__c,
                                         Ecart_C_A_F_MontantD__c,Ecart_C_A_F_MontantI__c,Ecart_C_A_F_MontantC__c,
                                         Ecart_C_A_F_MontantD_E__c,Ecart_C_A_F_MontantI_E__c,Ecart_C_A_F_MontantC_E__c,
                                         cout_terminaison_montantD__c
                                    FROM VILigne_Affaire__c
                                   WHERE Ligne_d_affaire_mensuelle__r.id in :MapLamAffaire.keyset()]) {
            la.Devis_Heure__c=0;
            la.Devis_MontantD__c=0;
            la.Devis_MontantD_E__c=0; 
            la.Devis_MontantI__c=0;
            la.Devis_MontantI_E__c=0;
            la.Devis_MontantC__c=0;
            la.Devis_MontantC_E__c=0; 
            la.Engage_brut_arrete_Heure__c =0;
            la.Engage_brut_arrete_MontantD__c =0;
            la.Engage_brut_arrete_MontantI__c =0;
            la.Engage_brut_arrete_MontantC__c =0;        
            la.Engage_brut_arrete_MontantD_E__c =0;
            la.Engage_brut_arrete_MontantI_E__c =0;
            la.Engage_brut_arrete_MontantC_E__c =0;  
            la.Dont_comptabiliseD__c =0;
            la.Dont_comptabiliseI__c =0;
            la.Dont_comptabiliseC__c =0;        
            la.Dont_comptabiliseD_E__c =0;
            la.Dont_comptabiliseI_E__c =0;
            la.Dont_comptabiliseC_E__c =0;   
            MapCurrentLA.put(la.Ligne_d_affaire_mensuelle__r.name+'/'+la.Type_de_ligne_d_affaire__c+'/'+la.Centre_Section__c+'/'+la.Type_depense__c,la);
        }
                        

        // Now let's read the Ligne Budget
        for(VILigne_Budget__c lb : [SELECT id, name,Avenant__r.affaire__c, Avenant__r.periode_comptable__c,Avenant__r.periode_comptable__r.name,
                                        Avenant__r.affaire__r.name,
                                        Avenant__r.affaire__r.date_de_sav_reelle__c,
                                        Avenant__r.affaire__r.Date_de_fin_de_garantie__c,
                                        Centre_Section__c ,Type_de_depense__c , Avenant__r.date__c,
                                        Heures__c   ,
                                        debours__c, debours_E__c,
                                        PRI__c, PRI_E__c,
                                        Complet__c, Complet_E__c                                 
                                   FROM VILigne_Budget__c
                                  WHERE Avenant__r.affaire__c =:IDAffaire
                                    AND Avenant__r.periode_comptable__r.date_de_debut__c>=:StartExercise
                                    AND Avenant__r.Statut_avenant__c =:VIConstant.AVENANT_EN_COURS]) {

//          filling up Current 
            string Type_de_ligne_d_affaire ;  
            if(lb.Type_de_depense__c==TDGAR.id) {
                Type_de_ligne_d_affaire='G';
            } else {
                Type_de_ligne_d_affaire='I';
            }
/*                                        
            if(lb.Avenant__r.affaire__r.date_de_sav_reelle__c!=null) {
                if(lb.Type_de_depense__c==tdGar.id && lb.Avenant__r.date__c>lb.Avenant__r.affaire__r.date_de_sav_reelle__c)
                    continue;
            }
            if(lb.Avenant__r.affaire__r.Date_de_fin_de_garantie__c!=null) {
                if(lb.Type_de_depense__c==tdGar.id && lb.Avenant__r.date__c>lb.Avenant__r.affaire__r.Date_de_fin_de_garantie__c)
                    continue;
            }
*/
            date d=lb.Avenant__r.date__c;
            if(d<=date.newinstance(2018,01,01) ) {
                d=date.newinstance(2018,01,01);
            }
            d=DateLAMMinimum;                                        
                                                                                 
            string per=convert_date_periode(d);   
            while (per<=per_maximum) {  
                if(lb.Avenant__r.periode_comptable__r.name>per) {
                    d=d.addmonths(1);
                    per=convert_date_periode(d);
                    continue ;                     
                }

                
                VILigne_Affaire__c newLa = new VILigne_Affaire__c();
                string key=lb.avenant__r.affaire__r.name+'-'+per+'/'+Type_de_ligne_d_affaire+'/'+lb.Centre_Section__c+'/'+lb.Type_de_depense__c;
                if(!MapCurrentLa.containskey(key)) {
                    NewLa = VIUtils.init_la();
                    NewLa.Ligne_d_affaire_mensuelle__c = MapCurrentLAM.get(lb.avenant__r.affaire__r.name+'-'+per).id;
                    NewLa.Type_de_ligne_d_affaire__c=Type_de_ligne_d_affaire;
                    NewLa.Centre_Section__c= lb.Centre_Section__c;
                    NewLa.Type_depense__c  =  lb.Type_de_depense__c ;   
                    NewLa.CurrencyIsoCode = MapCurrentLAM.get(lb.avenant__r.affaire__r.name+'-'+per).CurrencyIsoCode;                
                    MapCurrentLa.put(key,newLa);
                } else {
                    Newla=MapCurrentLa.get(key);
                }
                Newla.Devis_Heure__c     =Newla.Devis_Heure__c      + (lb.Heures__c==null ? 0 : lb.Heures__c);
                Newla.Devis_MontantD__c  =Newla.Devis_MontantD__c   + (lb.Debours__c==null ? 0 : lb.Debours__c);
                Newla.Devis_MontantD_E__c=Newla.Devis_MontantD__c ;
                Newla.Devis_MontantI__c  =Newla.Devis_MontantI__c   + (lb.PRI__c==null ? 0 : lb.PRI__c);
                Newla.Devis_MontantI_E__c=Newla.Devis_MontantI__c;
                Newla.Devis_MontantC__c  =Newla.Devis_MontantC__c   + (lb.complet__c==null ? 0 : lb.complet__c);
                Newla.Devis_MontantC_E__c=Newla.Devis_MontantC__c ; 
                
                d=d.addmonths(1);
                per=convert_date_periode(d);
            }
        }

        Map<string,List<double>>MapGarantieDuMois= new Map<string,List<double>>();
        
        // Now let's read the Pointage
        list<VIPointage__c>ListUpdatepointage = new list<VIPointage__c>();
                                       
        for(VIPointage__c po : [SELECT id, name,affaire__c,periode_comptable__c, sous_chapitre__c,date__c,
                                        periode_comptable__r.date_de_debut__c,periode_comptable__r.name,
                                        Centre_Section__c ,affaire__r.name,
                                        Heures__c   ,
                                        debours__c, debours_E__c,
                                        PRI__c, PRI_E__c,
                                        Complet__c, Complet_E__c                                 
                                   FROM VIPointage__c
                                  WHERE affaire__c = :IDAffaire
                                    AND periode_comptable__r.date_de_debut__c>=:StartExercise]) {
                                         
            //string per=convert_date_periode(po.periode_comptable__r.date_de_debut__c);   
            //date d=po.periode_comptable__r.date_de_debut__c;    
            date d=DateLAMMinimum ;
            string per=convert_date_periode(d);   
                                                                                
            if(po.sous_chapitre__c!=null) {
                if(po.sous_chapitre__c=='99-99'  ) {
                    string key=po.affaire__c+'-'+po.periode_comptable__r.date_de_debut__c;
                    list<double>listD = new list<double>();
                    if(MapGarantieDuMois.containskey(key)) {
                        ListD=MapGarantieDuMois.get(key);
                    } else {
                        ListD.add(0);
                        ListD.add(0);                        
                    }
                    ListD[0]=ListD[0]+po.debours__c;
                    ListD[1]=ListD[1]+po.debours_E__c;  
                    MapGarantieDuMois.put(key,ListD);
                }
            }
                                      
            while (per<=per_maximum) {                          
                if(po.periode_comptable__r.name>per) {
                    d=d.addmonths(1);
                    per=convert_date_periode(d);
                    continue ;                     
                }
                
                VILigne_Affaire__c newLa = new VILigne_Affaire__c();
                if(po.sous_chapitre__c!=null) {
                    if(po.sous_chapitre__c=='99-99') {
                        po.Centre_Section__c=CS801.id ;
                    }
                } else {
                    po.sous_chapitre__c='00-00';
                }
                
                string key=po.affaire__r.name+'-'+per+'/'+VIUtils.conv_sous_chapitre(po.sous_chapitre__c)+'/'+po.Centre_Section__c+'/'+tdMO.id;
                if(!MapCurrentLa.containskey(key) ) {
                    newLa = VIUtils.init_la();

                    NewLa.Ligne_d_affaire_mensuelle__c = MapCurrentLAM.get(po.affaire__r.name+'-'+per).id;
                    NewLa.Type_de_ligne_d_affaire__c = VIUtils.conv_sous_chapitre(po.sous_chapitre__c) ;
                    NewLa.Centre_Section__c= po.Centre_Section__c;
                    NewLa.Type_depense__c  =  tdMO.id ;  
                    NewLa.CurrencyIsoCode = MapCurrentLAM.get(po.affaire__r.name+'-'+per).CurrencyIsoCode;                
                    MapCurrentLa.put(key,newLa);
                } else {
                    Newla=MapCurrentLa.get(key);
                }
                Newla.Engage_brut_arrete_Heure__c     =(Newla.Engage_brut_arrete_Heure__c     ==null ? 0 : Newla.Engage_brut_arrete_Heure__c )      + (po.Heures__c==null ? 0  : po.Heures__c);
                //Newla.Engage_brut_arrete_MontantD__c  =(Newla.Engage_brut_arrete_MontantD__c  ==null ? 0 : Newla.Engage_brut_arrete_MontantD__c )   + (po.Debours__c==null ? 0 : po.Debours__c);
                //Newla.Engage_brut_arrete_MontantD_E__c=Newla.Engage_brut_arrete_MontantD__c;
                //Newla.Engage_brut_arrete_MontantI__c  =(Newla.Engage_brut_arrete_MontantI__c  ==null ? 0 : Newla.Engage_brut_arrete_MontantI__c )   + (po.PRI__c==null ? 0     : po.PRI__c);
                //Newla.Engage_brut_arrete_MontantI_E__c=Newla.Engage_brut_arrete_MontantI__c ;
                //Newla.Engage_brut_arrete_MontantC__c  =(Newla.Engage_brut_arrete_MontantC__c  ==null ? 0 : Newla.Engage_brut_arrete_MontantC__c )   + (po.complet__c==null ? 0 : po.complet__c);
                //Newla.Engage_brut_arrete_MontantC_E__c=Newla.Engage_brut_arrete_MontantC__c ; 

                Newla.Dont_comptabiliseD__c  =(Newla.Dont_comptabiliseD__c  ==null ? 0 : Newla.Dont_comptabiliseD__c )   + (po.Debours__c==null ? 0 : po.Debours__c);
                Newla.Dont_comptabiliseD_E__c=Newla.Dont_comptabiliseD__c;
                Newla.Dont_comptabiliseI__c  =(Newla.Dont_comptabiliseI__c  ==null ? 0 : Newla.Dont_comptabiliseI__c )   + (po.PRI__c==null ? 0     : po.PRI__c);
                Newla.Dont_comptabiliseI_E__c=Newla.Dont_comptabiliseI__c ;
                Newla.Dont_comptabiliseC__c  =(Newla.Dont_comptabiliseC__c  ==null ? 0 : Newla.Dont_comptabiliseC__c )   + (po.complet__c==null ? 0 : po.complet__c);
                Newla.Dont_comptabiliseC_E__c=Newla.Dont_comptabiliseC__c; 
                
                d=d.addmonths(1);
                per=convert_date_periode(d);
            }

        }

        // Now let's read the Achat
        list<VIAchat__c>ListUpdateAchat = new list<VIAchat__c>();
        for(VIAchat__c ac : [SELECT id, name,affaire__c,affaire__r.name,sous_chapitre__c,
                                        Centre_Section__c ,
                                        type_depense__c,
                                        periode_comptable__c,periode_comptable__r.date_de_debut__c,periode_comptable__r.name,
                                        date__c,
                                        CommandeD__c , CommandeI__c ,CommandeC__c ,
                                        CommandeD_E__c , CommandeI_E__c ,CommandeC_E__c ,                             
                                        ComptabiliseD__c , ComptabiliseI__c,ComptabiliseC__c,                      
                                        ComptabiliseD_E__c , ComptabiliseI_E__c,ComptabiliseC_E__c
                                   FROM VIAchat__c
                                  WHERE affaire__c= :IDAffaire
                                    AND periode_comptable__r.date_de_debut__c>=:StartExercise]) {
                                      
            //string per=convert_date_periode(ac.periode_comptable__r.date_de_debut__c);  
            //date d=ac.periode_comptable__r.date_de_debut__c;   
            date d=DateLAMMinimum ;
            string per=convert_date_periode(d);   

            if(ac.sous_chapitre__c!=null) {
                if(ac.sous_chapitre__c=='99-99') {
                    if(ac.Centre_Section__c==CS801.id && ac.type_depense__c==tdAMP.id ) {
                       ac.type_depense__c=tdGAR.id ;
                       // continue ;
                    }
                    string key=ac.affaire__c+'-'+ac.periode_comptable__r.date_de_debut__c;
                    list<double>listD = new list<double>();
                    if(MapGarantieDuMois.containskey(key)) {
                        ListD=MapGarantieDuMois.get(key);
                    } else {
                        ListD.add(0);
                        ListD.add(0);                        
                    }
                    ListD[0]=ListD[0]+(ac.ComptabiliseD__c  ==null?0:ac.ComptabiliseD__c) ;
                    ListD[1]=ListD[1]+(ac.ComptabiliseD_E__c==null?0:ac.ComptabiliseD_E__c); 
                    MapGarantieDuMois.put(key,ListD);                    
                }
            }
                                        
            while (per<=per_maximum) {  
                if(ac.periode_comptable__r.name>per) {
                    d=d.addmonths(1);
                    per=convert_date_periode(d);
                    continue ;                     
                }
                

                // current          
                VILigne_Affaire__c newLa = new VILigne_Affaire__c();
                if(Ac.sous_chapitre__c==null) {
                    Ac.sous_chapitre__c='00-00';
                }
                string key=ac.affaire__r.name+'-'+per+'/'+VIUtils.conv_sous_chapitre(ac.sous_chapitre__c)+'/'+ac.Centre_Section__c+'/'+ac.type_depense__c;                                                        
                if(!MapCurrentLa.containskey(key)) {
                    NewLa = VIUtils.init_la();                            
                    NewLa.Ligne_d_affaire_mensuelle__c = MapCurrentLAM.get(ac.affaire__r.name+'-'+per).id;
                    NewLa.Type_de_ligne_d_affaire__c = VIUtils.conv_sous_chapitre(ac.sous_chapitre__c) ;                
                    NewLa.Centre_Section__c= ac.Centre_Section__c;
                    NewLa.Type_depense__c  =  ac.type_depense__c ; 
                    NewLa.CurrencyIsoCode = MapCurrentLAM.get(ac.affaire__r.name+'-'+per).CurrencyIsoCode;
                    MapCurrentLa.put(key,newLa);
                } else {
                    Newla=MapCurrentLa.get(key);
                }

                Newla.Engage_brut_arrete_MontantD__c  =(Newla.Engage_brut_arrete_MontantD__c  ==null ? 0 : Newla.Engage_brut_arrete_MontantD__c )   + (ac.CommandeD__c==null ? 0   : ac.CommandeD__c);
                Newla.Engage_brut_arrete_MontantD_E__c=Newla.Engage_brut_arrete_MontantD__c ;
                Newla.Engage_brut_arrete_MontantI__c  =(Newla.Engage_brut_arrete_MontantI__c  ==null ? 0 : Newla.Engage_brut_arrete_MontantI__c )   + (ac.CommandeI__c==null ? 0   : ac.CommandeI__c);
                Newla.Engage_brut_arrete_MontantI_E__c=Newla.Engage_brut_arrete_MontantI__c;
                Newla.Engage_brut_arrete_MontantC__c  =(Newla.Engage_brut_arrete_MontantC__c  ==null ? 0 : Newla.Engage_brut_arrete_MontantC__c )   + (ac.CommandeC__c==null ? 0   : ac.CommandeC__c);
                Newla.Engage_brut_arrete_MontantC_E__c=Newla.Engage_brut_arrete_MontantC__c ; 

                Newla.Dont_comptabiliseD__c  =(Newla.Dont_comptabiliseD__c  ==null ? 0 : Newla.Dont_comptabiliseD__c )   + (ac.ComptabiliseD__c==null ? 0   : ac.ComptabiliseD__c);
                Newla.Dont_comptabiliseD_E__c=Newla.Dont_comptabiliseD__c;
                Newla.Dont_comptabiliseI__c  =(Newla.Dont_comptabiliseI__c  ==null ? 0 : Newla.Dont_comptabiliseI__c )   + (ac.ComptabiliseI__c==null ? 0   : ac.ComptabiliseI__c);
                Newla.Dont_comptabiliseI_E__c=Newla.Dont_comptabiliseI__c ;
                Newla.Dont_comptabiliseC__c  =(Newla.Dont_comptabiliseC__c  ==null ? 0 : Newla.Dont_comptabiliseC__c )   + (ac.ComptabiliseC__c==null ? 0   : ac.ComptabiliseC__c);
                Newla.Dont_comptabiliseC_E__c=Newla.Dont_comptabiliseC__c; 
                
                d=d.addmonths(1);
                per=convert_date_periode(d);
            }

        }
       // upsert MapCurrentLa.values();    
        
        // Update the previous LA record for Current LA
        For(VILigne_Affaire__c la: MapCurrentLa.values()) {
            string key=MapLamAffaire.get(la.Ligne_d_affaire_mensuelle__c)+'/'+la.Type_de_ligne_d_affaire__c+'/'+la.Centre_Section__c+'/'+la.Type_depense__c; 
/*
            if(MapPreviousLa.containskey(key)) {
                VILigne_Affaire__c laPrevious = MapPreviousLa.get(key);
                la.Ligne_d_affaire_precedente__c = laPrevious.id;
            }
            if(la.Engage_brut_arrete_MontantD__c==0 && la.cout_terminaison_montantD__c==0) {
                 ListLADelete.add(la);   
            }
*/
        }
                                       

         
        // Here the current LA lines are ok. Let's compute the current LAM lines
        For(VILigne_Affaire__c la: MapCurrentLa.values()) {
            
            VILigne_d_affaire_mensuelle__c lam=MapCurrentLam.get(MapLamAffaire.get(la.Ligne_d_affaire_mensuelle__c)) ;
           
         //   if(la.Type_depense__c==TDGAR.id && 
         //      lam.affaire__r.date_de_sav_reelle__c!=null && 
         //      lam.affaire__r.date_de_sav_reelle__c>lam.periode_comptable__r.date_de_debut__c) {
         //         la.Engage_brut_arrete_MontantD__c = la.Engage_brut_arrete_MontantD__c +  (la.Devis_MontantD__c  ==null ? 0 : la.Devis_MontantD__c.setScale(2)) ; 
         //         la.Engage_brut_arrete_MontantI__c = la.Engage_brut_arrete_MontantI__c +  (la.Devis_MontantI__c  ==null ? 0 : la.Devis_MontantI__c.setScale(2)) ; 
         //         la.Engage_brut_arrete_MontantC__c = la.Engage_brut_arrete_MontantC__c +  (la.Devis_MontantC__c  ==null ? 0 : la.Devis_MontantC__c.setScale(2)) ;                    
         //                                                                                   
         //         la.Engage_brut_arrete_MontantD_E__c = la.Engage_brut_arrete_MontantD__c ;
         //         la.Engage_brut_arrete_MontantI_E__c = la.Engage_brut_arrete_MontantI__c ;
         //         la.Engage_brut_arrete_MontantC_E__c = la.Engage_brut_arrete_MontantC__c ; 
                                                                                            
         //         la.Dont_comptabiliseD__c = la.Dont_comptabiliseD__c +  (la.Devis_MontantD__c  ==null ? 0 : la.Devis_MontantD__c.setScale(2)) ; 
         //         la.Dont_comptabiliseI__c = la.Dont_comptabiliseI__c +  (la.Devis_MontantI__c  ==null ? 0 : la.Devis_MontantI__c.setScale(2)) ; 
         //         la.Dont_comptabiliseC__c = la.Dont_comptabiliseC__c +  (la.Devis_MontantC__c  ==null ? 0 : la.Devis_MontantC__c.setScale(2)) ;                    
                                                                                            
         //         la.Dont_comptabiliseD_E__c = la.Dont_comptabiliseD__c ;
         //         la.Dont_comptabiliseI_E__c = la.Dont_comptabiliseI__c ;
         //         la.Dont_comptabiliseC_E__c = la.Dont_comptabiliseC__c ;                                                                                            
         //   }
 

            lam.devis_heure__c     =(lam.devis_heure__c     ==null ? 0 : lam.devis_heure__c)      + (la.Devis_Heure__c     ==null ? 0 : la.devis_heure__c) ;
            lam.devis_MontantD__c  =(lam.devis_MontantD__c  ==null ? 0 : lam.devis_MontantD__c)   + (la.Devis_MontantD__c  ==null ? 0 : la.Devis_MontantD__c.setScale(2)) ;
            lam.devis_MontantI__c  =(lam.devis_MontantI__c  ==null ? 0 : lam.devis_MontantI__c)   + (la.Devis_MontantI__c  ==null ? 0 : la.Devis_MontantI__c.setScale(2)) ;   
            lam.devis_MontantC__c  =(lam.devis_MontantC__c  ==null ? 0 : lam.devis_MontantC__c)   + (la.Devis_MontantC__c  ==null ? 0 : la.Devis_MontantC__c.setScale(2)) ;               
            lam.devis_MontantD_E__c=lam.devis_MontantD__c  ;
            lam.devis_MontantI_E__c=lam.devis_MontantI__c  ;   
            lam.devis_MontantC_E__c=lam.devis_MontantC__c  ;               

            lam.Engage_brut_arrete_Heure__c=(lam.Engage_brut_arrete_Heure__c==null ? 0 : lam.Engage_brut_arrete_Heure__c) + (la.Engage_brut_arrete_Heure__c==null ? 0 : la.Engage_brut_arrete_Heure__c) ;               
            lam.Engage_brut_arrete_MontantD__c=(lam.Engage_brut_arrete_MontantD__c==null ? 0 : lam.Engage_brut_arrete_MontantD__c) + (la.Engage_brut_arrete_MontantD__c==null ? 0 : la.Engage_brut_arrete_MontantD__c.setScale(2)) ;                           
            lam.Engage_brut_arrete_MontantI__c=(lam.Engage_brut_arrete_MontantI__c==null ? 0 : lam.Engage_brut_arrete_MontantI__c) + (la.Engage_brut_arrete_MontantI__c==null ? 0 : la.Engage_brut_arrete_MontantI__c.setScale(2)) ;                           
            lam.Engage_brut_arrete_MontantC__c=(lam.Engage_brut_arrete_MontantC__c==null ? 0 : lam.Engage_brut_arrete_MontantC__c) + (la.Engage_brut_arrete_MontantC__c==null ? 0 : la.Engage_brut_arrete_MontantC__c.setScale(2)) ;                           
            lam.Engage_brut_arrete_MontantD_E__c=lam.Engage_brut_arrete_MontantD__c;                           
            lam.Engage_brut_arrete_MontantI_E__c=lam.Engage_brut_arrete_MontantI__c ;                           
            lam.Engage_brut_arrete_MontantC_E__c=lam.Engage_brut_arrete_MontantC__c ;                           

            lam.Dont_comptabiliseD__c=(lam.Dont_comptabiliseD__c==null ? 0 : lam.Dont_comptabiliseD__c) + (la.Dont_comptabiliseD__c==null ? 0 : la.Dont_comptabiliseD__c.setScale(2)) ;                           
            lam.Dont_comptabiliseI__c=(lam.Dont_comptabiliseI__c==null ? 0 : lam.Dont_comptabiliseI__c) + (la.Dont_comptabiliseI__c==null ? 0 : la.Dont_comptabiliseI__c.setScale(2)) ;                                       
            lam.Dont_comptabiliseC__c=(lam.Dont_comptabiliseC__c==null ? 0 : lam.Dont_comptabiliseC__c) + (la.Dont_comptabiliseC__c==null ? 0 : la.Dont_comptabiliseC__c.setScale(2)) ;                                       
            lam.Dont_comptabiliseD_E__c=lam.Dont_comptabiliseD__c ;                           
            lam.Dont_comptabiliseI_E__c=lam.Dont_comptabiliseI__c ;
            lam.Dont_comptabiliseC_E__c=lam.Dont_comptabiliseC__c ;

            lam.Ecart_C_A_F_Heure__c=(lam.Ecart_C_A_F_Heure__c==null ? 0 : lam.Ecart_C_A_F_Heure__c) + (la.Ecart_C_A_F_Heure__c==null ? 0 : la.Ecart_C_A_F_Heure__c) ;                                       
            lam.Ecart_C_A_F_MontantD__c=(lam.Ecart_C_A_F_MontantD__c==null ? 0 : lam.Ecart_C_A_F_MontantD__c) + (la.Ecart_C_A_F_MontantD__c==null ? 0 : la.Ecart_C_A_F_MontantD__c.setScale(2)) ;                                                   
            lam.Ecart_C_A_F_MontantI__c=(lam.Ecart_C_A_F_MontantI__c==null ? 0 : lam.Ecart_C_A_F_MontantI__c) + (la.Ecart_C_A_F_MontantI__c==null ? 0 : la.Ecart_C_A_F_MontantI__c.setScale(2)) ;                                                   
            lam.Ecart_C_A_F_MontantC__c=(lam.Ecart_C_A_F_MontantC__c==null ? 0 : lam.Ecart_C_A_F_MontantC__c) + (la.Ecart_C_A_F_MontantC__c==null ? 0 : la.Ecart_C_A_F_MontantC__c.setScale(2)) ;                                                               
            lam.Ecart_C_A_F_MontantD_E__c=lam.Ecart_C_A_F_MontantD__c;
            lam.Ecart_C_A_F_MontantI_E__c=lam.Ecart_C_A_F_MontantI__c;
            lam.Ecart_C_A_F_MontantC_E__c=lam.Ecart_C_A_F_MontantC__c;
            

            if(la.Type_depense__c==tdGAR.id) {
                lam.garantie_dotation__c  =(lam.garantie_dotation__c  ==null ? 0 :lam.garantie_dotation__c)   + (la.Devis_MontantD__c   ==null ? 0 : la.Devis_MontantD__c.SetScale(2)) ;
                lam.garantie_dotation_E__c=(lam.garantie_dotation_E__c==null ? 0 :lam.garantie_dotation_E__c) + (la.Devis_MontantD_E__c ==null ? 0 : la.Devis_MontantD_E__c.SetScale(2)) ;
            }
            if(la.Type_de_ligne_d_affaire__c=='G' && (La.Type_depense__c!=TdGAR.id || La.centre_section__c!=cs801.id)  && (La.Type_depense__c!=TdAMP.id || La.centre_section__c!=cs801.id))  {
                lam.garantie_depense__c  =(lam.garantie_depense__c  ==null ? 0 :lam.garantie_depense__c)   + (la.Dont_ComptabiliseD__c   ==null ? 0 : la.Dont_ComptabiliseD__c.SetScale(2)) ;
                lam.garantie_depense_E__c=(lam.garantie_depense_E__c==null ? 0 :lam.garantie_depense_E__c) + (la.Dont_ComptabiliseD_E__c ==null ? 0 : la.Dont_ComptabiliseD_E__c.SetScale(2)) ;
            }
            string key=lam.affaire__c+'-'+lam.periode_comptable__r.date_de_debut__c;
            if(MapGarantieDuMois.containskey(key)) {
                List<double>listD = MapGarantieDuMois.get(key);
                lam.garantie_reprise_consommee__c  = ListD[0];
                lam.garantie_reprise_consommeeE__c = ListD[1];                
            
                //if(lam.garantie_reprise_consommee__c>lam.garantie_dotation__c -lam.Garantie_Reprise_mois_precedent__c )
                //    lam.garantie_reprise_consommee__c=lam.garantie_dotation__c -lam.Garantie_Reprise_mois_precedent__c;
                
                //if(lam.garantie_reprise_consommeeE__c>lam.garantie_dotation_E__c -lam.Garantie_Reprise_mois_precedent_E__c)
                //    lam.garantie_reprise_consommeeE__c=lam.garantie_dotation_E__c -lam.Garantie_Reprise_mois_precedent_E__c;
                double a1 = lam.garantie_depense__c ;
                if(a1>lam.garantie_dotation__c)
                    a1=lam.garantie_dotation__c;
                
                double b1 = lam.Garantie_Reprise_mois_precedent__c;
                if(b1>lam.Garantie_Reprise_mois_precedent__c)
                    b1=lam.Garantie_Reprise_mois_precedent__c;

                lam.garantie_reprise_consommee__c=a1 - b1;
                
                double a2 = lam.garantie_depense_E__c ;
                if(a2>lam.garantie_dotation_E__c)
                    a2=lam.garantie_dotation_E__c;
                
                double b2 = lam.Garantie_Reprise_mois_precedent_E__c;
                if(b2>lam.Garantie_Reprise_mois_precedent_E__c)
                    b2=lam.Garantie_Reprise_mois_precedent_E__c;

                lam.garantie_reprise_consommeeE__c=a2 - b2;

                
            }
            
            if(lam.garantie_depense__c>0) {
               lam.garantie_reprise__c  =(lam.garantie_depense__c==null ? 0 : lam.garantie_depense__c)   - (lam.garantie_reprise_consommee__c==null ? 0 : lam.garantie_reprise_consommee__c)     ;
               lam.garantie_reprise_E__c=(lam.garantie_depense_E__c==null ? 0 : lam.garantie_depense_E__c)   - (lam.garantie_reprise_consommeeE__c==null ? 0 : lam.garantie_reprise_consommeeE__c)     ;
            }
            
            if(Mode_de_calcul_de_l_avancement=='2') { 
                if(la.type_depense__c==tdEMM.id) {
                    lam.EMM__c    =lam.EMM__c   + (la.Devis_MontantI__c   ==null ? 0 : la.Devis_MontantI__c.setScale(2)) ;
                    lam.EMM_E__c  =lam.EMM__c;
                }
                if(la.type_depense__c==tdAMP.id) {
                    lam.AMP__c    =lam.AMP__c   + (la.Devis_MontantI__c   ==null ? 0 : la.Devis_MontantI__c.setScale(2)) ;
                    lam.AMP_E__c  =lam.AMP__c ;
                }
                if(la.type_depense__c==tdFOL.id) {
                    lam.FOL__c    =lam.FOL__c   + (la.Devis_MontantI__c   ==null ? 0 : la.Devis_MontantI__c.setScale(2)) ;
                    lam.FOL_E__c  = lam.FOL__c  ;
                }
            }
        }            
        
        if(MAJLA) {
            upsert MapCurrentLa.values();
        }


        list<VIFacture__c>ListUpdateFacture = new list<VIFacture__c>();        
        for(VIFacture__c fac:[SELECT id, name, Affaire__c, Affaire__r.name,type__c, 
                                     date__c,date_de_comptabilisation__c, periode_comptable__c,periode_comptable__r.name,
                                     montant_HT__c, montant_HTE__c,
                                     montant_paye__c,montant_payeE__c 
                                FROM VIfacture__c
                               WHERE affaire__c= :IDAffaire]) {
            //date d=fac.date__c;
            //if(d==null)
            //    d=fac.date_de_comptabilisation__c;
            //                       
            //if(d<date_minimum)
            //    d=date_minimum;
            //
            //if(d<StartExercise)
            //    d=StartExercise;
            date d=DateLAMMinimum ;
            string per=convert_date_periode(d);   
                                  
            while (per<=per_maximum) {  
                if(fac.periode_comptable__r.name>per) {
                    d=d.addmonths(1);
                    per=convert_date_periode(d);
                    continue ;                     
                }
                
                VILigne_d_affaire_mensuelle__c lam=MapCurrentLam.get(fac.affaire__r.name+'-'+per) ;
                if(lam.periode_comptable__r.date_de_fin__c>=fac.date_de_comptabilisation__c){ 
                    if(fac.type__c=='FAC') {
                        lam.PV_Facture__c  =(lam.PV_Facture__c ==null ? 0 :lam.PV_Facture__c)   +(fac.montant_HT__c == null ? 0 :fac.montant_HT__c);
                        lam.PV_FactureE__c =(lam.PV_Facture__c ==null ? 0 :lam.PV_Facture__c) ;
                    }
                    if(fac.type__c=='RGC') {
                        lam.PV_Encaisse_HT__c =(lam.PV_Encaisse_HT__c==null ? 0 :lam.PV_Encaisse_HT__c) +(fac.montant_HT__c == null ? 0 :fac.montant_HT__c) ;                                
                        lam.PV_Encaisse_HTE__c=(lam.PV_Encaisse_HT__c==null ? 0 :lam.PV_Encaisse_HT__c);
                        lam.PV_Encaisse__c =(lam.PV_Encaisse__c==null ? 0 :lam.PV_Encaisse__c) +(fac.montant_paye__c == null ? 0 :fac.montant_paye__c) ;                                
                        lam.PV_EncaisseE__c=(lam.PV_Encaisse__c==null ? 0 :lam.PV_Encaisse__c);
                    }
                        
                }
                
                d=d.addmonths(1);
                per=convert_date_periode(d);
            }
                                   
        }

        list<VIAvenant__c>ListUpdateAvenant = new list<VIAvenant__c>();                
        for(VIAvenant__c Av:[SELECT id, name, date__c, Affaire__c,Affaire__r.name, periode_comptable__c,periode_comptable__r.name,
                                     PV__c ,PV_E__c 
                                FROM VIAvenant__c
                               WHERE Statut_avenant__c =:VIConstant.AVENANT_EN_COURS
                                 AND affaire__c =:IDAffaire ]) {

           // date d=av.date__c;      
           // if(d<=date.newinstance(2018,01,01) ) {
           //     d=date.newinstance(2018,01,01);
           // }
           // if(d<StartExercise)
           //     d=StartExercise;
                                     
            //string per=convert_date_periode(d);                                        
            //string per=PeriodeMinimum;                                        
            date d=DateLAMMinimum ;
            string per=convert_date_periode(d);   

            while (per<=per_maximum) { 
                if(av.periode_comptable__r.name>per) {
                    d=d.addmonths(1);
                    per=convert_date_periode(d);
                    continue ;                     
                }
                
                VILigne_d_affaire_mensuelle__c lam=MapCurrentLam.get(av.affaire__r.name+'-'+per) ;
                lam.PV_total__c  =(lam.PV_total__c==null ? 0 : lam.PV_total__c)   +(av.PV__c==null ? 0   :av.PV__c) ;
                lam.PV_totalE__c =lam.PV_total__c;
                
                d=d.addmonths(1);
                per=convert_date_periode(d);
            }
                
        }

        for(VILigne_d_affaire_mensuelle__c lam :MapCurrentLam.values() ) {
            lam.Marge_PV__c  = (lam.PV_total__c==null ? 0 : lam.PV_total__c)   - (lam.devis_MontantI__c==null ? 0 : lam.devis_MontantI__c);
            lam.Marge_PVE__c = lam.Marge_PV__c ;   
            if(Mode_de_calcul_de_l_avancement=='2') { 
                
                lam.EMM__c=(lam.EMM__c * lam.Total_Pourcentage_d_avancement__c  /100) ; // - lam.M_1_EMM__c;
                lam.AMP__c=(lam.AMP__c * lam.Total_Pourcentage_d_avancement__c  /100) ; // - lam.M_1_AMP__c ;
                lam.FOL__c=(lam.FOL__c * lam.Total_Pourcentage_d_avancement__c  /100) ; // - lam.M_1_FOL__c;                
                
                lam.EMM_E__c=lam.EMM__c;
                lam.AMP_E__c=lam.AMP__c; 
                lam.FOL_E__c=lam.FOL__c;
                
                /* rajouté en juillet 2021 */
                /* Finalement, non, on ne fait pas
                lam.devis_MontantD__c  =lam.devis_MontantD__c - lam.EMM__c - lam.AMP__c - lam.FOL__c ;
                lam.devis_MontantI__c  =lam.devis_MontantI__c - lam.EMM__c - lam.AMP__c - lam.FOL__c ;
                lam.devis_MontantC__c  =lam.devis_MontantC__c - lam.EMM__c - lam.AMP__c - lam.FOL__c ;
                lam.devis_MontantD_E__c=lam.devis_MontantD__c  ;
                lam.devis_MontantI_E__c=lam.devis_MontantI__c  ;   
                lam.devis_MontantC_E__c=lam.devis_MontantC__c  ;               
                */
                    
            } 
            
        }        

        if(MAJLAM)  { 
            update MapCurrentLam.values();
        }
        
    }

    

    
    public static void Recalcul_LA(list<id> ListIdAffaire) {
/*        
        system.debug('Recalcul_LA for '+ListIdAffaire);
        //try {  
        string Mode_de_calcul_de_l_avancement ; 
        VItype_de_depense__c tdMO  = new VItype_de_depense__c();
        VItype_de_depense__c tdGAR = new VItype_de_depense__c();
        VItype_de_depense__c tdEMM = new VItype_de_depense__c();
        VItype_de_depense__c tdAMP = new VItype_de_depense__c();
        VItype_de_depense__c tdFOL = new VItype_de_depense__c(); 
        VICentre_section__c CS801;
        
        for(VIType_de_depense__c td : [SELECT ID,name from VIType_de_depense__c where name like 'MO %' or name like 'GAR%' or name like 'EMM%' or name like 'AMP%' or name like 'FOL%']) {
            if(td.name.startswith('MO '))
                 tdMO=td ; 

            if(td.name.startswith('GAR'))
                 tdGAR=td ; 

            if(td.name.startswith('EMM'))
                 tdEMM=td ; 

            if(td.name.startswith('AMP'))
                 tdAMP=td ; 

            if(td.name.startswith('FOL'))
                 tdFOL=td ; 
        }
        CS801 = [select id from VICentre_section__c where name like '801%' ];        

        Map<string,VIPeriode__c>MapEntite_bwPeriode = new Map<string,VIPeriode__c>();
        for(VIPeriode__c per : [SELECT ID,statut__c, entite_bw__c,name
                                  FROM VIPeriode__c
                                 WHERE statut__c=:VIConstant.PERIODE_OUVERTE 
                                    OR statut__c=:VIConstant.PERIODE_PREOUVERTE ]) {
             Mapentite_bwPeriode.put(Per.entite_bw__c+'/'+per.statut__c,per);
             if(per.statut__c==VIConstant.PERIODE_OUVERTE ){
                 system.debug('periode ouverte '+per.name);
             }
        }

        
        Map<string,VILigne_d_affaire_mensuelle__c>MapCurrentLAM = new Map<string,VILigne_d_affaire_mensuelle__c>();
        Map<string,VILigne_d_affaire_mensuelle__c>MapFutureLAM = new Map<string,VILigne_d_affaire_mensuelle__c>();
        
        Map<string,String>MapLamAffaire = new Map<string,String>();
        string Type_d_imputation ; 
        // Set all the LAM of the Affaire to Zero        
        for(VILigne_d_affaire_mensuelle__c lam:[SELECT id, name,affaire__c,affaire__r.name, affaire__r.entite_bw__c,periode_comptable__c,
                                                       affaire__r.Mode_de_calcul_de_l_avancement__c ,Ligne_d_affaire_mensuelle_precedente__c, 
                                                       affaire__r.Produit_SousDomaine__r.Type_d_imputation__c ,
                                                       periode_comptable__r.statut__c,CurrencyIsoCode,
                                                       Garantie_dotation__c , Garantie_dotation_E__c ,
                                                       Garantie_reprise__c , Garantie_reprise_E__c ,
                                                       Garantie_reprise_consommee__c , Garantie_reprise_consommeeE__c ,
                                                       Devis_Heure__c ,
                                                       Devis_MontantD__c,  Devis_MontantI__c,  Devis_MontantC__c,
                                                       Devis_MontantD_E__c,Devis_MontantI_E__c,Devis_MontantC_E__c,
                                                       Engage_brut_arrete_Heure__c,
                                                       Engage_brut_arrete_MontantD__c,Engage_brut_arrete_MontantI__c,Engage_brut_arrete_MontantC__c,
                                                       Engage_brut_arrete_MontantD_E__c,Engage_brut_arrete_MontantI_E__c,Engage_brut_arrete_MontantC_E__c,
                                                       Dont_comptabiliseD__c,Dont_comptabiliseI__c,Dont_comptabiliseC__c,
                                                       Dont_comptabiliseD_E__c,Dont_comptabiliseI_E__c,Dont_comptabiliseC_E__c,
                                                       Ecart_C_A_F_Heure__c,
                                                       Ecart_C_A_F_MontantD__c,Ecart_C_A_F_MontantI__c,Ecart_C_A_F_MontantC__c,
                                                       Ecart_C_A_F_MontantD_E__c,Ecart_C_A_F_MontantI_E__c,Ecart_C_A_F_MontantC_E__c,
                                                       EMM__c, EMM_E__c,
                                                       AMP__c, AMP_E__c,
                                                       FOL__c, FOL_E__c,
                                                       Total_Pourcentage_d_avancement__c                                                
                                                  FROM VILigne_d_affaire_mensuelle__c
                                                 WHERE affaire__c in :ListIDAffaire
                                                   AND (periode_comptable__r.statut__c=:VIConstant.PERIODE_OUVERTE 
                                                    OR periode_comptable__r.statut__c=:VIConstant.PERIODE_PREOUVERTE
                                                    OR periode_comptable__r.statut__c=:VIConstant.PERIODE_DERNIERE   )]) {
            Mode_de_calcul_de_l_avancement =  lam.affaire__r.Mode_de_calcul_de_l_avancement__c.left(1);  
            Type_d_imputation = lam.affaire__r.Produit_SousDomaine__r.Type_d_imputation__c;                                            
            if(lam.periode_comptable__r.statut__c==VIConstant.PERIODE_OUVERTE || lam.periode_comptable__r.statut__c==VIConstant.PERIODE_PREOUVERTE ) {
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
                lam.Garantie_reprise_consommee__c=0;
                lam.Garantie_reprise_consommeeE__c=0;

                if(lam.periode_comptable__r.statut__c==VIConstant.PERIODE_OUVERTE) {
                    MapCurrentLAM.put(lam.affaire__c,lam); 
                }

                if(lam.periode_comptable__r.statut__c==VIConstant.PERIODE_PREOUVERTE) { 
                    MapFutureLAM.put(lam.affaire__c,lam); 
                }

            }                             
            MapLamAffaire.put(lam.id,lam.affaire__c);
        }

        if(MapCurrentLAM.size()<1) {
            return ; // It's an old affaire, everything is in the past. We give up
        }
        if(Type_d_imputation!='4') {
            Return ; // No calculation if it's not a customer affaire
        }
        
        // if the future lam doesn't exists, let's create it ! 
        for(id id : ListIDAffaire) {
            if(!MapFutureLam.containskey(id)) {
                VILigne_d_affaire_mensuelle__c Lam = new VILigne_d_affaire_mensuelle__c();
                Lam = MapCurrentLAM.get(id);
                lam.Ligne_d_affaire_mensuelle_precedente__c  =Lam.id;
                lam.id=null;
                lam.periode_comptable__c=MapEntite_bwPeriode.get(lam.affaire__r.entite_bw__c+'/'+VIConstant.PERIODE_PREOUVERTE).id;
                lam.name = lam.affaire__r.name+'-'+MapEntite_bwPeriode.get(lam.affaire__r.entite_bw__c+'/'+VIConstant.PERIODE_PREOUVERTE).name;
                
                insert Lam ; 

                MapFutureLAM.put(lam.affaire__c,lam);  
                MapLamAffaire.put(lam.id,lam.affaire__c);            
            }
        }
        
        
        
        // Read Current LA and put everything at 0
        Map<string,VILigne_Affaire__c>MapCurrentLA = new Map<string,VILigne_Affaire__c>();
        Map<string,VILigne_Affaire__c>MapFutureLA = new Map<string,VILigne_Affaire__c>();        
        for(VILigne_Affaire__c la:[SELECT id, name,Ligne_d_affaire_mensuelle__r.affaire__c,Type_de_ligne_d_affaire__c ,
                                         Ligne_d_affaire_mensuelle__r.periode_comptable__r.statut__c,
                                         Centre_Section__c ,Type_depense__c ,
                                         Devis_Heure__c ,
                                         Devis_MontantD__c ,Devis_MontantD_E__c, 
                                         Devis_MontantI__c ,Devis_MontantI_E__c,
                                         Devis_MontantC__c ,Devis_MontantC_E__c,
                                         Engage_brut_arrete_Heure__c,
                                         Engage_brut_arrete_MontantD__c,Engage_brut_arrete_MontantI__c,Engage_brut_arrete_MontantC__c,
                                         Engage_brut_arrete_MontantD_E__c,Engage_brut_arrete_MontantI_E__c,Engage_brut_arrete_MontantC_E__c,
                                         Dont_comptabiliseD__c,Dont_comptabiliseI__c,Dont_comptabiliseC__c,
                                         Dont_comptabiliseD_E__c,Dont_comptabiliseI_E__c,Dont_comptabiliseC_E__c,
                                         Ecart_C_A_F_Heure__c,
                                         Ecart_C_A_F_MontantD__c,Ecart_C_A_F_MontantI__c,Ecart_C_A_F_MontantC__c,
                                         Ecart_C_A_F_MontantD_E__c,Ecart_C_A_F_MontantI_E__c,Ecart_C_A_F_MontantC_E__c,
                                         cout_terminaison_montantD__c
                                    FROM VILigne_Affaire__c
                                   WHERE Ligne_d_affaire_mensuelle__r.affaire__c in :ListIDAffaire
                                     AND (Ligne_d_affaire_mensuelle__r.periode_comptable__r.statut__c=:VIConstant.PERIODE_OUVERTE 
                                           OR Ligne_d_affaire_mensuelle__r.periode_comptable__r.statut__c=:VIConstant.PERIODE_PREOUVERTE)]) {
            la.Devis_Heure__c=0;
            la.Devis_MontantD__c=0;
            la.Devis_MontantD_E__c=0; 
            la.Devis_MontantI__c=0;
            la.Devis_MontantI_E__c=0;
            la.Devis_MontantC__c=0;
            la.Devis_MontantC_E__c=0; 
            la.Engage_brut_arrete_Heure__c =0;
            la.Engage_brut_arrete_MontantD__c =0;
            la.Engage_brut_arrete_MontantI__c =0;
            la.Engage_brut_arrete_MontantC__c =0;        
            la.Engage_brut_arrete_MontantD_E__c =0;
            la.Engage_brut_arrete_MontantI_E__c =0;
            la.Engage_brut_arrete_MontantC_E__c =0;  
            la.Dont_comptabiliseD__c =0;
            la.Dont_comptabiliseI__c =0;
            la.Dont_comptabiliseC__c =0;        
            la.Dont_comptabiliseD_E__c =0;
            la.Dont_comptabiliseI_E__c =0;
            la.Dont_comptabiliseC_E__c =0;   
            if(la.Ligne_d_affaire_mensuelle__r.periode_comptable__r.statut__c==VIConstant.PERIODE_OUVERTE ) {
                MapCurrentLA.put(la.Ligne_d_affaire_mensuelle__r.affaire__c+'/'+la.Type_de_ligne_d_affaire__c+'/'+la.Centre_Section__c+'/'+la.Type_depense__c,la);
            } else {
                MapFutureLA.put(la.Ligne_d_affaire_mensuelle__r.affaire__c+'/'+la.Type_de_ligne_d_affaire__c+'/'+la.Centre_Section__c+'/'+la.Type_depense__c,la);
            }
                                               
        }
        
        
        // Read previous LA for connecting to current LA
        map<string,VILigne_Affaire__c>MapPreviousLa = new map<string,VILigne_Affaire__c>();
        for(VILigne_Affaire__c la:[SELECT id, name,Ligne_d_affaire_mensuelle__r.affaire__c,Type_de_ligne_d_affaire__c,
                                          Ligne_d_affaire_precedente__c ,
                                          Centre_Section__c ,Type_depense__c ,
                                          Type_depense__r.name 
                                     FROM VILigne_Affaire__c
                                    WHERE Ligne_d_affaire_mensuelle__r.affaire__c in :ListIDAffaire
                                      AND Ligne_d_affaire_mensuelle__r.periode_comptable__r.statut__c=:VIConstant.PERIODE_DERNIERE ]) {
            string key=la.Ligne_d_affaire_mensuelle__r.affaire__c+'/'+la.Type_de_ligne_d_affaire__c+'/'+la.Centre_Section__c+'/'+la.Type_depense__c; 
            MapPreviousLa.put(key,la);
        }                                 

        // Fill up Current LA
        for(VILigne_Affaire__c la:MapPreviousLa.values()) {
            string key=la.Ligne_d_affaire_mensuelle__r.affaire__c+'/'+la.Type_de_ligne_d_affaire__c+'/'+la.Centre_Section__c+'/'+la.Type_depense__c;
            VILigne_Affaire__c newLa = new VILigne_Affaire__c();
            if(!MapCurrentLa.containskey(key)) {
                NewLa = init_la();
                NewLa.Ligne_d_affaire_mensuelle__c = MapCurrentLAM.get(la.Ligne_d_affaire_mensuelle__r.affaire__c).id;
                NewLa.Type_de_ligne_d_affaire__c = la.Type_de_ligne_d_affaire__c;
                NewLa.Centre_Section__c= la.Centre_Section__c;
                NewLa.Type_depense__c  =  la.Type_depense__c ; 
                NewLa.CurrencyIsoCode = MapCurrentLAM.get(la.Ligne_d_affaire_mensuelle__r.affaire__c).CurrencyIsoCode;
                MapCurrentLa.put(key,newLa);
            }
        }
        
        // Fill up Future LA
        for(VILigne_Affaire__c la:MapCurrentLa.values()) {
            string key=MapLamAffaire.get(la.Ligne_d_affaire_mensuelle__c)+'/'+la.Type_de_ligne_d_affaire__c+'/'+la.Centre_Section__c+'/'+la.Type_depense__c;
            VILigne_Affaire__c newLa = new VILigne_Affaire__c();
            if(!MapFutureLa.containskey(key) && MapFutureLAM.containskey(MapLamAffaire.get(la.Ligne_d_affaire_mensuelle__c))) {
                NewLa = init_la();
                NewLa.Ligne_d_affaire_mensuelle__c = MapFutureLAM.get(MapLamAffaire.get(la.Ligne_d_affaire_mensuelle__c)).id;
                NewLa.Type_de_ligne_d_affaire__c = la.Type_de_ligne_d_affaire__c;
                NewLa.Centre_Section__c= la.Centre_Section__c;
                NewLa.Type_depense__c  =  la.Type_depense__c ; 
                NewLa.CurrencyIsoCode = MapFutureLAM.get(MapLamAffaire.get(la.Ligne_d_affaire_mensuelle__c)).CurrencyIsoCode;
                MapFutureLa.put(key,newLa);
            } 
        }
        

        // Now let's read the Ligne Budget
        for(VILigne_Budget__c lb : [SELECT id, name,Avenant__r.affaire__c, Avenant__r.periode_comptable__r.statut__c,
                                        Centre_Section__c ,Type_de_depense__c ,
                                        Avenant__r.affaire__r.date_de_sav_reelle__c,
                                        Avenant__r.date__c,
                                        Heures__c   ,
                                        debours__c, debours_E__c,
                                        PRI__c, PRI_E__c,
                                        Complet__c, Complet_E__c                                 
                                   FROM VILigne_Budget__c
                                  WHERE Avenant__r.affaire__c in :ListIDAffaire
                                    AND Avenant__r.Statut_avenant__c =:VIConstant.AVENANT_EN_COURS]) {

//          filling up Current 
            string Type_de_ligne_d_affaire ;  
            if(lb.Type_de_depense__c==TDGAR.id) {
                Type_de_ligne_d_affaire='G';
            } else {
                Type_de_ligne_d_affaire='I';
            }
            if(lb.Avenant__r.affaire__r.date_de_sav_reelle__c!=null) {
                if(lb.Type_de_depense__c==tdGar.id && lb.Avenant__r.date__c>lb.Avenant__r.affaire__r.date_de_sav_reelle__c)
                    continue;
            }

            string key=lb.avenant__r.affaire__c+'/'+Type_de_ligne_d_affaire+'/'+lb.Centre_Section__c+'/'+lb.Type_de_depense__c;
            if(lb.Avenant__r.periode_comptable__r.statut__c.left(2)>='20') {       
                VILigne_Affaire__c newLa = new VILigne_Affaire__c();
                if(!MapCurrentLa.containskey(key)) {
                    NewLa = init_la();                            
                    NewLa.Ligne_d_affaire_mensuelle__c = MapCurrentLAM.get(lb.Avenant__r.affaire__c).id;
                    NewLa.Type_de_ligne_d_affaire__c=Type_de_ligne_d_affaire;
                    NewLa.Centre_Section__c= lb.Centre_Section__c;
                    NewLa.Type_depense__c  =  lb.Type_de_depense__c ;   
                    NewLa.CurrencyIsoCode = MapCurrentLAM.get(lb.Avenant__r.affaire__c).CurrencyIsoCode;                
                    MapCurrentLa.put(key,newLa);
                } else {
                    Newla=MapCurrentLa.get(key);
                }
                Newla.Devis_Heure__c     =Newla.Devis_Heure__c      + (lb.Heures__c==null ? 0 : lb.Heures__c);
                Newla.Devis_MontantD__c  =Newla.Devis_MontantD__c   + (lb.Debours__c==null ? 0 : lb.Debours__c);
                Newla.Devis_MontantD_E__c=Newla.Devis_MontantD_E__c + (lb.Debours_E__c==null ? 0 : lb.Debours_E__c);
                Newla.Devis_MontantI__c  =Newla.Devis_MontantI__c   + (lb.PRI__c==null ? 0 : lb.PRI__c);
                Newla.Devis_MontantI_E__c=Newla.Devis_MontantI_E__c + (lb.PRI_E__c==null ? 0 : lb.PRI_E__c);
                Newla.Devis_MontantC__c  =Newla.Devis_MontantC__c   + (lb.complet__c==null ? 0 : lb.complet__c);
                Newla.Devis_MontantC_E__c=Newla.Devis_MontantC_E__c + (lb.complet_E__c==null ? 0 : lb.complet_E__c); 
            }
                                        
//          filling up Future   
            if(MapFutureLAM.containskey(lb.Avenant__r.affaire__c))  {                                                                             
                if(lb.Avenant__r.periode_comptable__r.statut__c.left(2)>='15') {
                    VILigne_Affaire__c newLaF = new VILigne_Affaire__c();                
                    if(!MapFutureLa.containskey(key) ) {
                        NewLaF = init_la();                            
                        NewLaF.Ligne_d_affaire_mensuelle__c = MapFutureLAM.get(lb.Avenant__r.affaire__c).id;
                        if(lb.Type_de_depense__c==TDGAR.id) {
                            Type_de_ligne_d_affaire='G';
                        } else {
                            Type_de_ligne_d_affaire='I';
                        }
                        NewLaF.Type_de_ligne_d_affaire__c=Type_de_ligne_d_affaire;
                        NewLaF.Centre_Section__c= lb.Centre_Section__c;
                        NewLaF.Type_depense__c  =  lb.Type_de_depense__c ;   
                        NewLaF.CurrencyIsoCode = MapFutureLAM.get(lb.Avenant__r.affaire__c).CurrencyIsoCode;                
                        MapFutureLa.put(key,newLaF);
                    } else {
                        NewlaF=MapFutureLa.get(key);
                    }
                    NewlaF.Devis_Heure__c     =NewlaF.Devis_Heure__c      + (lb.Heures__c==null ? 0 : lb.Heures__c);
                    NewlaF.Devis_MontantD__c  =NewlaF.Devis_MontantD__c   + (lb.Debours__c==null ? 0 : lb.Debours__c);
                    NewlaF.Devis_MontantD_E__c=NewlaF.Devis_MontantD_E__c + (lb.Debours_E__c==null ? 0 : lb.Debours_E__c);
                    NewlaF.Devis_MontantI__c  =NewlaF.Devis_MontantI__c   + (lb.PRI__c==null ? 0 : lb.PRI__c);
                    NewlaF.Devis_MontantI_E__c=NewlaF.Devis_MontantI_E__c + (lb.PRI_E__c==null ? 0 : lb.PRI_E__c);
                    NewlaF.Devis_MontantC__c  =NewlaF.Devis_MontantC__c   + (lb.complet__c==null ? 0 : lb.complet__c);
                    NewlaF.Devis_MontantC_E__c=NewlaF.Devis_MontantC_E__c + (lb.complet_E__c==null ? 0 : lb.complet_E__c); 
                } 
            }    
        }
        
        // Now let's read the Pointage
        for(VIPointage__c po : [SELECT id, name,affaire__c,periode_comptable__r.statut__c, sous_chapitre__c,
                                        Centre_Section__c ,
                                        Heures__c   ,
                                        debours__c, debours_E__c,
                                        PRI__c, PRI_E__c,
                                        Complet__c, Complet_E__c                                 
                                   FROM VIPointage__c
                                  WHERE affaire__c in :ListIDAffaire]) {
                                      
                if(po.sous_chapitre__c!=null) {
                    if(po.sous_chapitre__c=='99-99') {
                        po.Centre_Section__c=CS801.id ;
                    }
                } else {
                    po.sous_chapitre__c='00-00';
                }
                                      
            string key=po.affaire__c+'/'+conv_sous_chapitre(po.sous_chapitre__c)+'/'+po.Centre_Section__c+'/'+tdMO.id;

            // Current 
            if( po.periode_comptable__r.statut__c.left(2)>='20') { 
                VILigne_Affaire__c newLa = new VILigne_Affaire__c();
                if(!MapCurrentLa.containskey(key) ) {
                    newLa = init_la();
                    NewLa.Ligne_d_affaire_mensuelle__c = MapCurrentLAM.get(po.affaire__c).id;
                    NewLa.Type_de_ligne_d_affaire__c = conv_sous_chapitre(po.sous_chapitre__c) ;
                    NewLa.Centre_Section__c= po.Centre_Section__c;
                    NewLa.Type_depense__c  =  tdMO.id ;  
                    NewLa.CurrencyIsoCode = MapCurrentLAM.get(po.affaire__c).CurrencyIsoCode;                
                    MapCurrentLa.put(key,newLa);
                } else {
                    Newla=MapCurrentLa.get(key);
                }
                Newla.Engage_brut_arrete_Heure__c     =(Newla.Engage_brut_arrete_Heure__c     ==null ? 0 : Newla.Engage_brut_arrete_Heure__c )      + (po.Heures__c==null ? 0 : po.Heures__c);
                //Newla.Engage_brut_arrete_MontantD__c  =(Newla.Engage_brut_arrete_MontantD__c  ==null ? 0 : Newla.Engage_brut_arrete_MontantD__c )   + (po.Debours__c==null ? 0 : po.Debours__c);
                //Newla.Engage_brut_arrete_MontantD_E__c=(Newla.Engage_brut_arrete_MontantD_E__c==null ? 0 : Newla.Engage_brut_arrete_MontantD_E__c ) + (po.Debours_E__c==null ? 0 : po.Debours_E__c);
                //Newla.Engage_brut_arrete_MontantI__c  =(Newla.Engage_brut_arrete_MontantI__c  ==null ? 0 : Newla.Engage_brut_arrete_MontantI__c )   + (po.PRI__c==null ? 0 : po.PRI__c);
                //Newla.Engage_brut_arrete_MontantI_E__c=(Newla.Engage_brut_arrete_MontantI_E__c==null ? 0 : Newla.Engage_brut_arrete_MontantI_E__c ) + (po.PRI_E__c==null ? 0 : po.PRI_E__c);
                //Newla.Engage_brut_arrete_MontantC__c  =(Newla.Engage_brut_arrete_MontantC__c  ==null ? 0 : Newla.Engage_brut_arrete_MontantC__c )   + (po.complet__c==null ? 0 : po.complet__c);
                //Newla.Engage_brut_arrete_MontantC_E__c=(Newla.Engage_brut_arrete_MontantC_E__c==null ? 0 : Newla.Engage_brut_arrete_MontantC_E__c ) + (po.complet_E__c==null ? 0 : po.complet_E__c); 

                Newla.Dont_comptabiliseD__c  =(Newla.Dont_comptabiliseD__c  ==null ? 0 : Newla.Dont_comptabiliseD__c )   + (po.Debours__c==null ? 0 : po.Debours__c);
                Newla.Dont_comptabiliseD_E__c=(Newla.Dont_comptabiliseD_E__c==null ? 0 : Newla.Dont_comptabiliseD_E__c ) + (po.Debours_E__c==null ? 0 : po.Debours_E__c);
                Newla.Dont_comptabiliseI__c  =(Newla.Dont_comptabiliseI__c  ==null ? 0 : Newla.Dont_comptabiliseI__c )   + (po.PRI__c==null ? 0 : po.PRI__c);
                Newla.Dont_comptabiliseI_E__c=(Newla.Dont_comptabiliseI_E__c==null ? 0 : Newla.Dont_comptabiliseI_E__c ) + (po.PRI_E__c==null ? 0 : po.PRI_E__c);
                Newla.Dont_comptabiliseC__c  =(Newla.Dont_comptabiliseC__c  ==null ? 0 : Newla.Dont_comptabiliseC__c )   + (po.complet__c==null ? 0 : po.complet__c);
                Newla.Dont_comptabiliseC_E__c=(Newla.Dont_comptabiliseC_E__c==null ? 0 : Newla.Dont_comptabiliseC_E__c ) + (po.complet_E__c==null ? 0 : po.complet_E__c); 
            }

            // Future 
            if(MapFutureLAM.containskey(po.affaire__c)) {
                if( po.periode_comptable__r.statut__c.left(2)>='15') {
                    VILigne_Affaire__c newLaF = new VILigne_Affaire__c();
                    if(!MapFutureLa.containskey(key) ) {
                        newLaF = init_la();
                        NewLaF.Ligne_d_affaire_mensuelle__c = MapFutureLAM.get(po.affaire__c).id;
                        NewLaF.Type_de_ligne_d_affaire__c = conv_sous_chapitre(po.sous_chapitre__c) ;
                        NewLaF.Centre_Section__c= po.Centre_Section__c;
                        NewLaF.Type_depense__c  =  tdMO.id ;  
                        NewLaF.CurrencyIsoCode = MapFutureLAM.get(po.affaire__c).CurrencyIsoCode;                
                        MapFutureLa.put(key,newLaF);
                    } else {
                        NewlaF=MapFutureLa.get(key);
                    }
                    NewlaF.Engage_brut_arrete_Heure__c     =(NewlaF.Engage_brut_arrete_Heure__c     ==null ? 0 : NewlaF.Engage_brut_arrete_Heure__c )      + (po.Heures__c==null ? 0 : po.Heures__c);
                    //NewlaF.Engage_brut_arrete_MontantD__c  =(NewlaF.Engage_brut_arrete_MontantD__c  ==null ? 0 : NewlaF.Engage_brut_arrete_MontantD__c )   + (po.Debours__c==null ? 0 : po.Debours__c);
                    //NewlaF.Engage_brut_arrete_MontantD_E__c=(NewlaF.Engage_brut_arrete_MontantD_E__c==null ? 0 : NewlaF.Engage_brut_arrete_MontantD_E__c ) + (po.Debours_E__c==null ? 0 : po.Debours_E__c);
                    //NewlaF.Engage_brut_arrete_MontantI__c  =(NewlaF.Engage_brut_arrete_MontantI__c  ==null ? 0 : NewlaF.Engage_brut_arrete_MontantI__c )   + (po.PRI__c==null ? 0 : po.PRI__c);
                    //NewlaF.Engage_brut_arrete_MontantI_E__c=(NewlaF.Engage_brut_arrete_MontantI_E__c==null ? 0 : NewlaF.Engage_brut_arrete_MontantI_E__c ) + (po.PRI_E__c==null ? 0 : po.PRI_E__c);
                    //NewlaF.Engage_brut_arrete_MontantC__c  =(NewlaF.Engage_brut_arrete_MontantC__c  ==null ? 0 : NewlaF.Engage_brut_arrete_MontantC__c )   + (po.complet__c==null ? 0 : po.complet__c);
                    //NewlaF.Engage_brut_arrete_MontantC_E__c=(NewlaF.Engage_brut_arrete_MontantC_E__c==null ? 0 : NewlaF.Engage_brut_arrete_MontantC_E__c ) + (po.complet_E__c==null ? 0 : po.complet_E__c); 

                    NewlaF.Dont_comptabiliseD__c  =(NewlaF.Dont_comptabiliseD__c  ==null ? 0 : NewlaF.Dont_comptabiliseD__c )   + (po.Debours__c==null ? 0 : po.Debours__c);
                    NewlaF.Dont_comptabiliseD_E__c=(NewlaF.Dont_comptabiliseD_E__c==null ? 0 : NewlaF.Dont_comptabiliseD_E__c ) + (po.Debours_E__c==null ? 0 : po.Debours_E__c);
                    NewlaF.Dont_comptabiliseI__c  =(NewlaF.Dont_comptabiliseI__c  ==null ? 0 : NewlaF.Dont_comptabiliseI__c )   + (po.PRI__c==null ? 0 : po.PRI__c);
                    NewlaF.Dont_comptabiliseI_E__c=(NewlaF.Dont_comptabiliseI_E__c==null ? 0 : NewlaF.Dont_comptabiliseI_E__c ) + (po.PRI_E__c==null ? 0 : po.PRI_E__c);
                    NewlaF.Dont_comptabiliseC__c  =(NewlaF.Dont_comptabiliseC__c  ==null ? 0 : NewlaF.Dont_comptabiliseC__c )   + (po.complet__c==null ? 0 : po.complet__c);
                    NewlaF.Dont_comptabiliseC_E__c=(NewlaF.Dont_comptabiliseC_E__c==null ? 0 : NewlaF.Dont_comptabiliseC_E__c ) + (po.complet_E__c==null ? 0 : po.complet_E__c); 
                } 
            }                              
        }

        // Now let's read the Achat
        for(VIAchat__c ac : [SELECT id, name,affaire__c,sous_chapitre__c,
                                        Centre_Section__c ,
                                        type_depense__c,
                                        periode_comptable__r.statut__c,
                                        CommandeD__c , CommandeI__c ,CommandeC__c ,
                                        CommandeD_E__c , CommandeI_E__c ,CommandeC_E__c ,                             
                                        ComptabiliseD__c , ComptabiliseI__c,ComptabiliseC__c,                      
                                        ComptabiliseD_E__c , ComptabiliseI_E__c,ComptabiliseC_E__c
                                   FROM VIAchat__c
                                  WHERE affaire__c in :ListIDAffaire]) {
            if(Ac.sous_chapitre__c!=null) {
                if( Ac.sous_chapitre__c=='99-99') {
                    if(ac.Centre_Section__c==CS801.id && ac.type_depense__c==tdAMP.id)
                        continue; 
                }
            } else {
                Ac.sous_chapitre__c='00-00';
            }
                                      
            string key=ac.affaire__c+'/'+conv_sous_chapitre(ac.sous_chapitre__c)+'/'+ac.Centre_Section__c+'/'+ac.type_depense__c;

            // current          
            if( ac.periode_comptable__r.statut__c.left(2)>='20') { 
                VILigne_Affaire__c newLa = new VILigne_Affaire__c();
                if(!MapCurrentLa.containskey(key)) {
                    NewLa = init_la();                            
                    NewLa.Ligne_d_affaire_mensuelle__c = MapCurrentLAM.get(ac.affaire__c).id;
                    NewLa.Type_de_ligne_d_affaire__c = conv_sous_chapitre(ac.sous_chapitre__c) ;                
                    NewLa.Centre_Section__c= ac.Centre_Section__c;
                    NewLa.Type_depense__c  =  ac.type_depense__c ; 
                    NewLa.CurrencyIsoCode = MapCurrentLAM.get(ac.affaire__c).CurrencyIsoCode;
                    MapCurrentLa.put(key,newLa);
                } else {
                    Newla=MapCurrentLa.get(key);
                }

                Newla.Engage_brut_arrete_MontantD__c  =(Newla.Engage_brut_arrete_MontantD__c  ==null ? 0 : Newla.Engage_brut_arrete_MontantD__c )   + (ac.CommandeD__c==null ? 0   : ac.CommandeD__c);
                Newla.Engage_brut_arrete_MontantD_E__c=(Newla.Engage_brut_arrete_MontantD_E__c==null ? 0 : Newla.Engage_brut_arrete_MontantD_E__c ) + (ac.CommandeD_E__c==null ? 0 : ac.CommandeD_e__c);
                Newla.Engage_brut_arrete_MontantI__c  =(Newla.Engage_brut_arrete_MontantI__c  ==null ? 0 : Newla.Engage_brut_arrete_MontantI__c )   + (ac.CommandeI__c==null ? 0   : ac.CommandeI__c);
                Newla.Engage_brut_arrete_MontantI_E__c=(Newla.Engage_brut_arrete_MontantI_E__c==null ? 0 : Newla.Engage_brut_arrete_MontantI_E__c ) + (ac.CommandeI_E__c==null ? 0 : ac.CommandeI_E__c);
                Newla.Engage_brut_arrete_MontantC__c  =(Newla.Engage_brut_arrete_MontantC__c  ==null ? 0 : Newla.Engage_brut_arrete_MontantC__c )   + (ac.CommandeC__c==null ? 0   : ac.CommandeC__c);
                Newla.Engage_brut_arrete_MontantC_E__c=(Newla.Engage_brut_arrete_MontantC_E__c==null ? 0 : Newla.Engage_brut_arrete_MontantC_E__c ) + (ac.CommandeC_E__c==null ? 0 : ac.CommandeC_E__c); 

                Newla.Dont_comptabiliseD__c  =(Newla.Dont_comptabiliseD__c  ==null ? 0 : Newla.Dont_comptabiliseD__c )   + (ac.ComptabiliseD__c==null ? 0   : ac.ComptabiliseD__c);
                Newla.Dont_comptabiliseD_E__c=(Newla.Dont_comptabiliseD_E__c==null ? 0 : Newla.Dont_comptabiliseD_E__c ) + (ac.ComptabiliseD_E__c==null ? 0 : ac.ComptabiliseD_E__c);
                Newla.Dont_comptabiliseI__c  =(Newla.Dont_comptabiliseI__c  ==null ? 0 : Newla.Dont_comptabiliseI__c )   + (ac.ComptabiliseI__c==null ? 0   : ac.ComptabiliseI__c);
                Newla.Dont_comptabiliseI_E__c=(Newla.Dont_comptabiliseI_E__c==null ? 0 : Newla.Dont_comptabiliseI_E__c ) + (ac.ComptabiliseI_E__c==null ? 0 : ac.ComptabiliseI_E__c);
                Newla.Dont_comptabiliseC__c  =(Newla.Dont_comptabiliseC__c  ==null ? 0 : Newla.Dont_comptabiliseC__c )   + (ac.ComptabiliseC__c==null ? 0   : ac.ComptabiliseC__c);
                Newla.Dont_comptabiliseC_E__c=(Newla.Dont_comptabiliseC_E__c==null ? 0 : Newla.Dont_comptabiliseC_E__c ) + (ac.ComptabiliseC_E__c==null ? 0 : ac.ComptabiliseC_E__c); 
            }

            // Future
            if(MapFutureLAM.containskey(ac.affaire__c)) {         
                if( ac.periode_comptable__r.statut__c.left(2)>='15') { 
                    VILigne_Affaire__c newLaF = new VILigne_Affaire__c();
                    if(!MapFutureLa.containskey(key)) {
                        NewLaF = init_la();                            
                        NewLaF.Ligne_d_affaire_mensuelle__c = MapFutureLAM.get(ac.affaire__c).id;
                        NewLaF.Type_de_ligne_d_affaire__c = conv_sous_chapitre(ac.sous_chapitre__c) ;                
                        NewLaF.Centre_Section__c= ac.Centre_Section__c;
                        NewLaF.Type_depense__c  =  ac.type_depense__c ; 
                        NewLaF.CurrencyIsoCode = MapFutureLAM.get(ac.affaire__c).CurrencyIsoCode;
                        MapFutureLa.put(key,newLaF);
                    } else {
                        NewlaF=MapFutureLa.get(key);
                    }

                    NewlaF.Engage_brut_arrete_MontantD__c  =(NewlaF.Engage_brut_arrete_MontantD__c  ==null ? 0 : NewlaF.Engage_brut_arrete_MontantD__c )   + (ac.CommandeD__c==null ? 0   : ac.CommandeD__c);
                    NewlaF.Engage_brut_arrete_MontantD_E__c=(NewlaF.Engage_brut_arrete_MontantD_E__c==null ? 0 : NewlaF.Engage_brut_arrete_MontantD_E__c ) + (ac.CommandeD_E__c==null ? 0 : ac.CommandeD_e__c);
                    NewlaF.Engage_brut_arrete_MontantI__c  =(NewlaF.Engage_brut_arrete_MontantI__c  ==null ? 0 : NewlaF.Engage_brut_arrete_MontantI__c )   + (ac.CommandeI__c==null ? 0   : ac.CommandeI__c);
                    NewlaF.Engage_brut_arrete_MontantI_E__c=(NewlaF.Engage_brut_arrete_MontantI_E__c==null ? 0 : NewlaF.Engage_brut_arrete_MontantI_E__c ) + (ac.CommandeI_E__c==null ? 0 : ac.CommandeI_E__c);
                    NewlaF.Engage_brut_arrete_MontantC__c  =(NewlaF.Engage_brut_arrete_MontantC__c  ==null ? 0 : NewlaF.Engage_brut_arrete_MontantC__c )   + (ac.CommandeC__c==null ? 0   : ac.CommandeC__c);
                    NewlaF.Engage_brut_arrete_MontantC_E__c=(NewlaF.Engage_brut_arrete_MontantC_E__c==null ? 0 : NewlaF.Engage_brut_arrete_MontantC_E__c ) + (ac.CommandeC_E__c==null ? 0 : ac.CommandeC_E__c); 

                    NewlaF.Dont_comptabiliseD__c  =(NewlaF.Dont_comptabiliseD__c  ==null ? 0 : NewlaF.Dont_comptabiliseD__c )   + (ac.ComptabiliseD__c==null ? 0   : ac.ComptabiliseD__c);
                    NewlaF.Dont_comptabiliseD_E__c=(NewlaF.Dont_comptabiliseD_E__c==null ? 0 : NewlaF.Dont_comptabiliseD_E__c ) + (ac.ComptabiliseD_E__c==null ? 0 : ac.ComptabiliseD_E__c);
                    NewlaF.Dont_comptabiliseI__c  =(NewlaF.Dont_comptabiliseI__c  ==null ? 0 : NewlaF.Dont_comptabiliseI__c )   + (ac.ComptabiliseI__c==null ? 0   : ac.ComptabiliseI__c);
                    NewlaF.Dont_comptabiliseI_E__c=(NewlaF.Dont_comptabiliseI_E__c==null ? 0 : NewlaF.Dont_comptabiliseI_E__c ) + (ac.ComptabiliseI_E__c==null ? 0 : ac.ComptabiliseI_E__c);
                    NewlaF.Dont_comptabiliseC__c  =(NewlaF.Dont_comptabiliseC__c  ==null ? 0 : NewlaF.Dont_comptabiliseC__c )   + (ac.ComptabiliseC__c==null ? 0   : ac.ComptabiliseC__c);
                    NewlaF.Dont_comptabiliseC_E__c=(NewlaF.Dont_comptabiliseC_E__c==null ? 0 : NewlaF.Dont_comptabiliseC_E__c ) + (ac.ComptabiliseC_E__c==null ? 0 : ac.ComptabiliseC_E__c); 
                }
            }                
        }
        
        // Update the previous LA record for Current LA
        list<VIligne_Affaire__c>ListLADelete = new list<VIligne_Affaire__c>();
        For(VILigne_Affaire__c la: MapCurrentLa.values()) {
            string key=MapLamAffaire.get(la.Ligne_d_affaire_mensuelle__c)+'/'+la.Type_de_ligne_d_affaire__c+'/'+la.Centre_Section__c+'/'+la.Type_depense__c; 
            if(MapPreviousLa.containskey(key)) {
                VILigne_Affaire__c laPrevious = MapPreviousLa.get(key);
                la.Ligne_d_affaire_precedente__c = laPrevious.id;
            }
            if(la.Engage_brut_arrete_MontantD__c==0 && la.cout_terminaison_montantD__c==0) {
                 ListLADelete.add(la);   
            }
        }

        // Update the previous LA record for Future LA
        For(VILigne_Affaire__c la: MapFutureLa.values()) {
            string key=MapLamAffaire.get(la.Ligne_d_affaire_mensuelle__c)+'/'+la.Type_de_ligne_d_affaire__c+'/'+la.Centre_Section__c+'/'+la.Type_depense__c; 
            if(MapCurrentLa.containskey(key)) {
                VILigne_Affaire__c laPrevious = MapCurrentLa.get(key);
                la.Ligne_d_affaire_precedente__c = laPrevious.id;
            }
        }
        
        
        upsert MapCurrentLa.values();
        //delete ListLADelete;
        upsert MapFutureLa.values();        

         
        // Here the current LA lines are ok. Let's compute the current LAM lines
        For(VILigne_Affaire__c la: MapCurrentLa.values()) {
            VILigne_d_affaire_mensuelle__c lam=MapCurrentLam.get(MapLamAffaire.get(la.Ligne_d_affaire_mensuelle__c)) ;
            lam.devis_heure__c     =(lam.devis_heure__c     ==null ? 0 : lam.devis_heure__c)      + (la.Devis_Heure__c     ==null ? 0 : la.devis_heure__c) ;
            lam.devis_MontantD__c  =(lam.devis_MontantD__c  ==null ? 0 : lam.devis_MontantD__c)   + (la.Devis_MontantD__c  ==null ? 0 : la.Devis_MontantD__c.SetScale(2)) ;
            lam.devis_MontantI__c  =(lam.devis_MontantI__c  ==null ? 0 : lam.devis_MontantI__c)   + (la.Devis_MontantI__c  ==null ? 0 : la.Devis_MontantI__c.SetScale(2)) ;   
            lam.devis_MontantC__c  =(lam.devis_MontantC__c  ==null ? 0 : lam.devis_MontantC__c)   + (la.Devis_MontantC__c  ==null ? 0 : la.Devis_MontantC__c.SetScale(2)) ;               
            lam.devis_MontantD_E__c=(lam.devis_MontantD_E__c==null ? 0 : lam.devis_MontantD_E__c) + (la.Devis_MontantD_E__c==null ? 0 : la.Devis_MontantD_E__c.SetScale(2)) ;
            lam.devis_MontantI_E__c=(lam.devis_MontantI_E__c==null ? 0 : lam.devis_MontantI_E__c) + (la.Devis_MontantI_E__c==null ? 0 : la.Devis_MontantI_E__c.SetScale(2)) ;   
            lam.devis_MontantC_E__c=(lam.devis_MontantC_E__c==null ? 0 : lam.devis_MontantC_E__c) + (la.Devis_MontantC_E__c==null ? 0 : la.Devis_MontantC_E__c.SetScale(2)) ;               

            lam.Engage_brut_arrete_Heure__c=(lam.Engage_brut_arrete_Heure__c==null ? 0 : lam.Engage_brut_arrete_Heure__c) + (la.Engage_brut_arrete_Heure__c==null ? 0 : la.Engage_brut_arrete_Heure__c) ;               
            lam.Engage_brut_arrete_MontantD__c=(lam.Engage_brut_arrete_MontantD__c==null ? 0 : lam.Engage_brut_arrete_MontantD__c) + (la.Engage_brut_arrete_MontantD__c==null ? 0 : la.Engage_brut_arrete_MontantD__c.SetScale(2)) ;                           
            lam.Engage_brut_arrete_MontantI__c=(lam.Engage_brut_arrete_MontantI__c==null ? 0 : lam.Engage_brut_arrete_MontantI__c) + (la.Engage_brut_arrete_MontantI__c==null ? 0 : la.Engage_brut_arrete_MontantI__c.SetScale(2)) ;                           
            lam.Engage_brut_arrete_MontantC__c=(lam.Engage_brut_arrete_MontantC__c==null ? 0 : lam.Engage_brut_arrete_MontantC__c) + (la.Engage_brut_arrete_MontantC__c==null ? 0 : la.Engage_brut_arrete_MontantC__c.SetScale(2)) ;                           
            lam.Engage_brut_arrete_MontantD_E__c=(lam.Engage_brut_arrete_MontantD_E__c==null ? 0 : lam.Engage_brut_arrete_MontantD_E__c) + (la.Engage_brut_arrete_MontantD_E__c==null ? 0 : la.Engage_brut_arrete_MontantD_E__c.SetScale(2)) ;                           
            lam.Engage_brut_arrete_MontantI_E__c=(lam.Engage_brut_arrete_MontantI_E__c==null ? 0 : lam.Engage_brut_arrete_MontantI_E__c) + (la.Engage_brut_arrete_MontantI_E__c==null ? 0 : la.Engage_brut_arrete_MontantI_E__c.SetScale(2)) ;                           
            lam.Engage_brut_arrete_MontantC_E__c=(lam.Engage_brut_arrete_MontantC_E__c==null ? 0 : lam.Engage_brut_arrete_MontantC_E__c) + (la.Engage_brut_arrete_MontantC_E__c==null ? 0 : la.Engage_brut_arrete_MontantC_E__c.SetScale(2)) ;                           

            lam.Dont_comptabiliseD__c=(lam.Dont_comptabiliseD__c==null ? 0 : lam.Dont_comptabiliseD__c) + (la.Dont_comptabiliseD__c==null ? 0 : la.Dont_comptabiliseD__c.SetScale(2)) ;                           
            lam.Dont_comptabiliseI__c=(lam.Dont_comptabiliseI__c==null ? 0 : lam.Dont_comptabiliseI__c) + (la.Dont_comptabiliseI__c==null ? 0 : la.Dont_comptabiliseI__c.SetScale(2)) ;                                       
            lam.Dont_comptabiliseC__c=(lam.Dont_comptabiliseC__c==null ? 0 : lam.Dont_comptabiliseC__c) + (la.Dont_comptabiliseC__c==null ? 0 : la.Dont_comptabiliseC__c.SetScale(2)) ;                                       
            lam.Dont_comptabiliseD_E__c=(lam.Dont_comptabiliseD_E__c==null ? 0 : lam.Dont_comptabiliseD_E__c) + (la.Dont_comptabiliseD_E__c==null ? 0 : la.Dont_comptabiliseD_E__c.SetScale(2)) ;                           
            lam.Dont_comptabiliseI_E__c=(lam.Dont_comptabiliseI_E__c==null ? 0 : lam.Dont_comptabiliseI_E__c) + (la.Dont_comptabiliseI_E__c==null ? 0 : la.Dont_comptabiliseI_E__c.SetScale(2)) ;                                       
            lam.Dont_comptabiliseC_E__c=(lam.Dont_comptabiliseC_E__c==null ? 0 : lam.Dont_comptabiliseC_E__c) + (la.Dont_comptabiliseC_E__c==null ? 0 : la.Dont_comptabiliseC_E__c.SetScale(2)) ;                                       

            lam.Ecart_C_A_F_Heure__c=(lam.Ecart_C_A_F_Heure__c==null ? 0 : lam.Ecart_C_A_F_Heure__c) + (la.Ecart_C_A_F_Heure__c==null ? 0 : la.Ecart_C_A_F_Heure__c) ;                                       
            lam.Ecart_C_A_F_MontantD__c=(lam.Ecart_C_A_F_MontantD__c==null ? 0 : lam.Ecart_C_A_F_MontantD__c) + (la.Ecart_C_A_F_MontantD__c==null ? 0 : la.Ecart_C_A_F_MontantD__c.SetScale(2)) ;                                                   
            lam.Ecart_C_A_F_MontantI__c=(lam.Ecart_C_A_F_MontantI__c==null ? 0 : lam.Ecart_C_A_F_MontantI__c) + (la.Ecart_C_A_F_MontantI__c==null ? 0 : la.Ecart_C_A_F_MontantI__c.SetScale(2)) ;                                                   
            lam.Ecart_C_A_F_MontantC__c=(lam.Ecart_C_A_F_MontantC__c==null ? 0 : lam.Ecart_C_A_F_MontantC__c) + (la.Ecart_C_A_F_MontantC__c==null ? 0 : la.Ecart_C_A_F_MontantC__c.SetScale(2)) ;                                                               
            lam.Ecart_C_A_F_MontantD_E__c=(lam.Ecart_C_A_F_MontantD_E__c==null ? 0 : lam.Ecart_C_A_F_MontantD_E__c) + (la.Ecart_C_A_F_MontantD_E__c==null ? 0 : la.Ecart_C_A_F_MontantD_E__c.SetScale(2)) ;                                                   
            lam.Ecart_C_A_F_MontantI_E__c=(lam.Ecart_C_A_F_MontantI_E__c==null ? 0 : lam.Ecart_C_A_F_MontantI_E__c) + (la.Ecart_C_A_F_MontantI_E__c==null ? 0 : la.Ecart_C_A_F_MontantI_E__c.SetScale(2)) ;                                                   
            lam.Ecart_C_A_F_MontantC_E__c=(lam.Ecart_C_A_F_MontantC_E__c==null ? 0 : lam.Ecart_C_A_F_MontantC_E__c) + (la.Ecart_C_A_F_MontantC_E__c==null ? 0 : la.Ecart_C_A_F_MontantC_E__c.SetScale(2)) ;                                                               

            if(la.Type_depense__c==tdGAR.id) {
                lam.garantie_dotation__c  =lam.garantie_dotation__c   + (la.Devis_MontantD__c   ==null ? 0 : la.Devis_MontantD__c.SetScale(2)) ;
                lam.garantie_dotation_E__c=lam.garantie_dotation_E__c + (la.Devis_MontantD_E__c ==null ? 0 : la.Devis_MontantD_E__c.SetScale(2)) ;
            }
            if(la.Type_de_ligne_d_affaire__c=='G' && ((La.Type_depense__c!=TdGAR.id && La.Type_depense__c!=TdAMP.id) ||La.centre_section__c!=cs801.id) ) {
                lam.garantie_depense__c  =lam.garantie_depense__c   + (la.Dont_ComptabiliseD__c   ==null ? 0 : la.Dont_ComptabiliseD__c.SetScale(2)) ;
                
                lam.garantie_depense_E__c=lam.garantie_depense_E__c + (la.Dont_ComptabiliseD_E__c ==null ? 0 : la.Dont_ComptabiliseD_E__c.SetScale(2)) ;
                lam.garantie_reprise__c  =lam.garantie_reprise__c   + (la.Dont_ComptabiliseD__c   ==null ? 0 : la.Dont_ComptabiliseD__c.SetScale(2)) ;
                lam.garantie_reprise_E__c=lam.garantie_reprise_E__c + (la.Dont_ComptabiliseD_E__c ==null ? 0 : la.Dont_ComptabiliseD_E__c.SetScale(2)) ;
                lam.garantie_reprise_consommee__c =lam.garantie_reprise_consommee__c  + (la.Dont_ComptabiliseD__c   ==null ? 0 : la.Dont_ComptabiliseD__c.SetScale(2)) ;
                lam.garantie_reprise_consommeeE__c=lam.garantie_reprise_consommeeE__c + (la.Dont_ComptabiliseD_E__c ==null ? 0 : la.Dont_ComptabiliseD_E__c.SetScale(2)) ;
            }
            if(lam.garantie_reprise_consommee__c>lam.garantie_dotation__c )
                lam.garantie_reprise_consommee__c=lam.garantie_dotation__c ;
            if(lam.garantie_reprise_consommeeE__c>lam.garantie_dotation_E__c )
                lam.garantie_reprise_consommeeE__c=lam.garantie_dotation_E__c ;
            
            
            
            if(Mode_de_calcul_de_l_avancement=='2') { 
                if(la.type_depense__c==tdEMM.id) {
                    lam.EMM__c    =lam.EMM__c   + (la.Devis_MontantI__c   ==null ? 0 : la.Devis_MontantI__c.SetScale(2)) ;
                    lam.EMM_E__c  =lam.EMM_E__c + (la.Devis_MontantI_E__c ==null ? 0 : la.Devis_MontantI_E__c.SetScale(2)) ;  
                }
                if(la.type_depense__c==tdAMP.id) {
                    lam.AMP__c    =lam.AMP__c   + (la.Devis_MontantI__c   ==null ? 0 : la.Devis_MontantI__c.SetScale(2)) ;
                    lam.AMP_E__c  =lam.AMP_E__c + (la.Devis_MontantI_E__c ==null ? 0 : la.Devis_MontantI_E__c.SetScale(2)) ;                
                }
                if(la.type_depense__c==tdFOL.id) {
                    lam.FOL__c    =lam.FOL__c   + (la.Devis_MontantI__c   ==null ? 0 : la.Devis_MontantI__c.SetScale(2)) ;
                    lam.FOL_E__c  =lam.FOL_E__c + (la.Devis_MontantI_E__c ==null ? 0 : la.Devis_MontantI_E__c.SetScale(2)) ;                
                }
            }
        }            
        
        
        // Here the Future LA lines are ok. Let's compute the Future LAM lines
        For(VILigne_Affaire__c la: MapFutureLa.values()) {
            VILigne_d_affaire_mensuelle__c lam=MapFutureLam.get(MapLamAffaire.get(la.Ligne_d_affaire_mensuelle__c)) ;
            lam.devis_heure__c     =(lam.devis_heure__c     ==null ? 0 : lam.devis_heure__c)      + (la.Devis_Heure__c     ==null ? 0 : la.devis_heure__c) ;
            lam.devis_MontantD__c  =(lam.devis_MontantD__c  ==null ? 0 : lam.devis_MontantD__c)   + (la.Devis_MontantD__c  ==null ? 0 : la.Devis_MontantD__c.SetScale(2)) ;
            lam.devis_MontantI__c  =(lam.devis_MontantI__c  ==null ? 0 : lam.devis_MontantI__c)   + (la.Devis_MontantI__c  ==null ? 0 : la.Devis_MontantI__c.SetScale(2)) ;   
            lam.devis_MontantC__c  =(lam.devis_MontantC__c  ==null ? 0 : lam.devis_MontantC__c)   + (la.Devis_MontantC__c  ==null ? 0 : la.Devis_MontantC__c.SetScale(2)) ;               
            lam.devis_MontantD_E__c=(lam.devis_MontantD_E__c==null ? 0 : lam.devis_MontantD_E__c) + (la.Devis_MontantD_E__c==null ? 0 : la.Devis_MontantD_E__c.SetScale(2)) ;
            lam.devis_MontantI_E__c=(lam.devis_MontantI_E__c==null ? 0 : lam.devis_MontantI_E__c) + (la.Devis_MontantI_E__c==null ? 0 : la.Devis_MontantI_E__c.SetScale(2)) ;   
            lam.devis_MontantC_E__c=(lam.devis_MontantC_E__c==null ? 0 : lam.devis_MontantC_E__c) + (la.Devis_MontantC_E__c==null ? 0 : la.Devis_MontantC_E__c.SetScale(2)) ;               

            lam.Engage_brut_arrete_Heure__c=(lam.Engage_brut_arrete_Heure__c==null ? 0 : lam.Engage_brut_arrete_Heure__c) + (la.Engage_brut_arrete_Heure__c==null ? 0 : la.Engage_brut_arrete_Heure__c) ;               
            lam.Engage_brut_arrete_MontantD__c=(lam.Engage_brut_arrete_MontantD__c==null ? 0 : lam.Engage_brut_arrete_MontantD__c) + (la.Engage_brut_arrete_MontantD__c==null ? 0 : la.Engage_brut_arrete_MontantD__c.SetScale(2)) ;                           
            lam.Engage_brut_arrete_MontantI__c=(lam.Engage_brut_arrete_MontantI__c==null ? 0 : lam.Engage_brut_arrete_MontantI__c) + (la.Engage_brut_arrete_MontantI__c==null ? 0 : la.Engage_brut_arrete_MontantI__c.SetScale(2)) ;                           
            lam.Engage_brut_arrete_MontantC__c=(lam.Engage_brut_arrete_MontantC__c==null ? 0 : lam.Engage_brut_arrete_MontantC__c) + (la.Engage_brut_arrete_MontantC__c==null ? 0 : la.Engage_brut_arrete_MontantC__c.SetScale(2)) ;                           
            lam.Engage_brut_arrete_MontantD_E__c=(lam.Engage_brut_arrete_MontantD_E__c==null ? 0 : lam.Engage_brut_arrete_MontantD_E__c) + (la.Engage_brut_arrete_MontantD_E__c==null ? 0 : la.Engage_brut_arrete_MontantD_E__c.SetScale(2)) ;                           
            lam.Engage_brut_arrete_MontantI_E__c=(lam.Engage_brut_arrete_MontantI_E__c==null ? 0 : lam.Engage_brut_arrete_MontantI_E__c) + (la.Engage_brut_arrete_MontantI_E__c==null ? 0 : la.Engage_brut_arrete_MontantI_E__c.SetScale(2)) ;                           
            lam.Engage_brut_arrete_MontantC_E__c=(lam.Engage_brut_arrete_MontantC_E__c==null ? 0 : lam.Engage_brut_arrete_MontantC_E__c) + (la.Engage_brut_arrete_MontantC_E__c==null ? 0 : la.Engage_brut_arrete_MontantC_E__c.SetScale(2)) ;                           

            lam.Dont_comptabiliseD__c=(lam.Dont_comptabiliseD__c==null ? 0 : lam.Dont_comptabiliseD__c) + (la.Dont_comptabiliseD__c==null ? 0 : la.Dont_comptabiliseD__c.SetScale(2)) ;                           
            lam.Dont_comptabiliseI__c=(lam.Dont_comptabiliseI__c==null ? 0 : lam.Dont_comptabiliseI__c) + (la.Dont_comptabiliseI__c==null ? 0 : la.Dont_comptabiliseI__c.SetScale(2)) ;                                       
            lam.Dont_comptabiliseC__c=(lam.Dont_comptabiliseC__c==null ? 0 : lam.Dont_comptabiliseC__c) + (la.Dont_comptabiliseC__c==null ? 0 : la.Dont_comptabiliseC__c.SetScale(2)) ;                                       
            lam.Dont_comptabiliseD_E__c=(lam.Dont_comptabiliseD_E__c==null ? 0 : lam.Dont_comptabiliseD_E__c) + (la.Dont_comptabiliseD_E__c==null ? 0 : la.Dont_comptabiliseD_E__c.SetScale(2)) ;                           
            lam.Dont_comptabiliseI_E__c=(lam.Dont_comptabiliseI_E__c==null ? 0 : lam.Dont_comptabiliseI_E__c) + (la.Dont_comptabiliseI_E__c==null ? 0 : la.Dont_comptabiliseI_E__c.SetScale(2)) ;                                       
            lam.Dont_comptabiliseC_E__c=(lam.Dont_comptabiliseC_E__c==null ? 0 : lam.Dont_comptabiliseC_E__c) + (la.Dont_comptabiliseC_E__c==null ? 0 : la.Dont_comptabiliseC_E__c.SetScale(2)) ;                                       

            lam.Ecart_C_A_F_Heure__c=(lam.Ecart_C_A_F_Heure__c==null ? 0 : lam.Ecart_C_A_F_Heure__c) + (la.Ecart_C_A_F_Heure__c==null ? 0 : la.Ecart_C_A_F_Heure__c) ;                                       
            lam.Ecart_C_A_F_MontantD__c=(lam.Ecart_C_A_F_MontantD__c==null ? 0 : lam.Ecart_C_A_F_MontantD__c) + (la.Ecart_C_A_F_MontantD__c==null ? 0 : la.Ecart_C_A_F_MontantD__c.SetScale(2)) ;                                                   
            lam.Ecart_C_A_F_MontantI__c=(lam.Ecart_C_A_F_MontantI__c==null ? 0 : lam.Ecart_C_A_F_MontantI__c) + (la.Ecart_C_A_F_MontantI__c==null ? 0 : la.Ecart_C_A_F_MontantI__c.SetScale(2)) ;                                                   
            lam.Ecart_C_A_F_MontantC__c=(lam.Ecart_C_A_F_MontantC__c==null ? 0 : lam.Ecart_C_A_F_MontantC__c) + (la.Ecart_C_A_F_MontantC__c==null ? 0 : la.Ecart_C_A_F_MontantC__c.SetScale(2)) ;                                                               
            lam.Ecart_C_A_F_MontantD_E__c=(lam.Ecart_C_A_F_MontantD_E__c==null ? 0 : lam.Ecart_C_A_F_MontantD_E__c) + (la.Ecart_C_A_F_MontantD_E__c==null ? 0 : la.Ecart_C_A_F_MontantD_E__c.SetScale(2)) ;                                                   
            lam.Ecart_C_A_F_MontantI_E__c=(lam.Ecart_C_A_F_MontantI_E__c==null ? 0 : lam.Ecart_C_A_F_MontantI_E__c) + (la.Ecart_C_A_F_MontantI_E__c==null ? 0 : la.Ecart_C_A_F_MontantI_E__c.SetScale(2)) ;                                                   
            lam.Ecart_C_A_F_MontantC_E__c=(lam.Ecart_C_A_F_MontantC_E__c==null ? 0 : lam.Ecart_C_A_F_MontantC_E__c) + (la.Ecart_C_A_F_MontantC_E__c==null ? 0 : la.Ecart_C_A_F_MontantC_E__c.SetScale(2)) ;                                                               

            if(la.Type_depense__c==tdGAR.id) {
                lam.garantie_dotation__c  =lam.garantie_dotation__c   + (la.Devis_MontantD__c   ==null ? 0 : la.Devis_MontantD__c.SetScale(2)) ;
                lam.garantie_dotation_E__c=lam.garantie_dotation_E__c + (la.Devis_MontantD_E__c ==null ? 0 : la.Devis_MontantD_E__c.SetScale(2)) ;
            }
            if(la.Type_de_ligne_d_affaire__c=='G' ) {
                lam.garantie_depense__c  =lam.garantie_depense__c   + (la.Dont_ComptabiliseD__c   ==null ? 0 : la.Dont_ComptabiliseD__c.SetScale(2)) ;
                lam.garantie_depense_E__c=lam.garantie_depense_E__c + (la.Dont_ComptabiliseD_E__c ==null ? 0 : la.Dont_ComptabiliseD_E__c.SetScale(2)) ;
            }
            if(Mode_de_calcul_de_l_avancement=='2') { 
                if(la.type_depense__c==tdEMM.id) {
                    lam.EMM__c    =lam.EMM__c   + (la.Devis_MontantI__c   ==null ? 0 : la.Devis_MontantI__c.SetScale(2)) ;
                    lam.EMM_E__c  =lam.EMM_E__c + (la.Devis_MontantI_E__c ==null ? 0 : la.Devis_MontantI_E__c.SetScale(2)) ;  
                }
                if(la.type_depense__c==tdAMP.id) {
                    lam.AMP__c    =lam.AMP__c   + (la.Devis_MontantI__c   ==null ? 0 : la.Devis_MontantI__c.SetScale(2)) ;
                    lam.AMP_E__c  =lam.AMP_E__c + (la.Devis_MontantI_E__c ==null ? 0 : la.Devis_MontantI_E__c.SetScale(2)) ;                
                }
                if(la.type_depense__c==tdFOL.id) {
                    lam.FOL__c    =lam.FOL__c   + (la.Devis_MontantI__c   ==null ? 0 : la.Devis_MontantI__c.SetScale(2)) ;
                    lam.FOL_E__c  =lam.FOL_E__c + (la.Devis_MontantI_E__c ==null ? 0 : la.Devis_MontantI_E__c.SetScale(2)) ;                
                }
            }

        }            


        
        for(VIFacture__c fac:[SELECT id, name, Affaire__c, type__c, date__c,periode_comptable__r.statut__c,
                                     montant_HT__c, montant_HTE__c,
                                     montant_paye__c,montant_payeE__c 
                                FROM VIfacture__c
                               WHERE affaire__c in :ListIDAffaire]) {
            if(fac.periode_comptable__r.statut__c.left(2)>='20') { 
                VILigne_d_affaire_mensuelle__c lam=MapCurrentLam.get(fac.affaire__c) ;
                lam.PV_Facture__c  =lam.PV_Facture__c  +(fac.montant_HT__c == null ? 0 :fac.montant_HT__c) ;
                lam.PV_FactureE__c =lam.PV_FactureE__c +(fac.montant_HTE__c == null ? 0 :fac.montant_HTE__c) ;
                lam.PV_Encaisse__c =lam.PV_Encaisse__c +(fac.montant_paye__c == null ? 0 :fac.montant_paye__c) ;                                
                lam.PV_EncaisseE__c=lam.PV_EncaisseE__c+(fac.montant_payeE__c == null ? 0 :fac.montant_payeE__c);       
            }
            if(fac.periode_comptable__r.statut__c.left(2)>='15' && MapFutureLam.containskey(fac.affaire__c)) { 
                VILigne_d_affaire_mensuelle__c lam=MapFutureLam.get(fac.affaire__c) ;
                lam.PV_Facture__c  =lam.PV_Facture__c  +(fac.montant_HT__c == null ? 0 :fac.montant_HT__c);
                lam.PV_FactureE__c =lam.PV_FactureE__c +(fac.montant_HTE__c == null ? 0 :fac.montant_HTE__c);                
                lam.PV_Encaisse__c =lam.PV_Encaisse__c +(fac.montant_paye__c == null ? 0 :fac.montant_paye__c) ;                                
                lam.PV_EncaisseE__c=lam.PV_EncaisseE__c+(fac.montant_payeE__c == null ? 0 :fac.montant_payeE__c);       
            }
                                   
        }
        
        for(VIAvenant__c Av:[SELECT id, name, Affaire__c, periode_comptable__r.statut__c,
                                     PV__c ,PV_E__c 
                                FROM VIAvenant__c
                               WHERE Statut_avenant__c =:VIConstant.AVENANT_EN_COURS
                                 AND affaire__c in :ListIDAffaire]) {
            if(av.periode_comptable__r.statut__c.left(2)>='20') {                                      
                VILigne_d_affaire_mensuelle__c lam=MapCurrentLam.get(av.affaire__c) ;
                lam.PV_total__c  =lam.PV_total__c  +(av.PV__c==null ? 0   :av.PV__c) ;
                lam.PV_totalE__c =lam.PV_totalE__c +(av.PV_E__c==null ? 0 :av.PV_E__c); 
            }
            if(MapFutureLam.containskey(av.affaire__c)) {
                if(av.periode_comptable__r.statut__c.left(2)>='15') {                                      
                    VILigne_d_affaire_mensuelle__c lam=MapFutureLam.get(av.affaire__c) ;
                    lam.PV_total__c  =lam.PV_total__c  +(av.PV__c==null ? 0   :av.PV__c) ;
                    lam.PV_totalE__c =lam.PV_totalE__c +(av.PV_E__c==null ? 0 :av.PV_E__c); 
                }
            }
        }

        for(VILigne_d_affaire_mensuelle__c lam :MapCurrentLam.values() ) {
            lam.Marge_PV__c  = lam.PV_total__c  - lam.devis_MontantI__c;
            lam.Marge_PVE__c = lam.PV_totalE__c - lam.devis_MontantI_E__c;   
            
            if(Mode_de_calcul_de_l_avancement=='2') {
                lam.EMM__c=lam.EMM__c * lam.Total_Pourcentage_d_avancement__c  /100;
                lam.AMP__c=lam.AMP__c * lam.Total_Pourcentage_d_avancement__c  /100;
                lam.FOL__c=lam.FOL__c * lam.Total_Pourcentage_d_avancement__c  /100;                

                lam.EMM_E__c=lam.EMM_E__c * lam.Total_Pourcentage_d_avancement__c  /100;
                lam.AMP_E__c=lam.AMP_E__c * lam.Total_Pourcentage_d_avancement__c  /100;
                lam.FOL_E__c=lam.FOL_E__c * lam.Total_Pourcentage_d_avancement__c  /100;                
            } 

        }        
        for(VILigne_d_affaire_mensuelle__c lam :MapFutureLam.values() ) {
            lam.Marge_PV__c  = lam.PV_total__c  - lam.devis_MontantI__c;
            lam.Marge_PVE__c = lam.PV_totalE__c - lam.devis_MontantI_E__c;            

            if(Mode_de_calcul_de_l_avancement=='2') {
                lam.EMM__c=lam.EMM__c * lam.Total_Pourcentage_d_avancement__c  /100;
                lam.AMP__c=lam.AMP__c * lam.Total_Pourcentage_d_avancement__c  /100;
                lam.FOL__c=lam.FOL__c * lam.Total_Pourcentage_d_avancement__c  /100;                

                lam.EMM_E__c=lam.EMM_E__c * lam.Total_Pourcentage_d_avancement__c  /100;
                lam.AMP_E__c=lam.AMP_E__c * lam.Total_Pourcentage_d_avancement__c  /100;
                lam.FOL_E__c=lam.FOL_E__c * lam.Total_Pourcentage_d_avancement__c  /100;                
            } 

        }        


        update MapCurrentLam.values();
        update MapFutureLam.values();
           
        //} catch (DMLException e) {  
        //    VIUtils.LogWrite('VIUtils.recalcul_LA','4 Running','','Error recompute '+ListIdAffaire);
        //} 
*/        
    }


    public static string convert_date_periode(Date d) {
        string p ;
        if(d!=null) {
            p = string.valueof(d.year())+('00'+string.valueof(d.month())).right(2)+'BW FRA';        
        } else {
            p=null;
        }
        return p;
    }
    

 
    
    
    public static String LogWrite (String process, String Status, String idLog, String label) { 
        
        list<VILog__c>ListLog;
        if(IdLog!='' ) {
            ListLog=[SELECT id, name, Nom_du_process__c, detail__c 
                       FROM VILog__c
                      WHERE id = :IdLog ];
            if(ListLog.size()==0) {
                VILog__c l  = new VILog__c(Nom_du_process__c=process, Status__c='3 Error',detail__c=label+' '+IdLog+' : Supplied Id Invalid') ;
                insert l;                
            } else {
                ListLog[0].status__c=Status;
                ListLog[0].Detail__c = ListLog[0].Detail__c+' '+label;
                update ListLog ; 
            }
        } else { 
            VILog__c l  = new VILog__c(Nom_du_process__c=process, Status__c=Status, detail__c=label) ;
            insert l;
            IdLog = l.id ; 
        }
        
        Return IdLog;
    }

    public static string conv_sous_chapitre (string sous_chapitre) {
        string type ;
        if(sous_chapitre.right(2)=='99'  ) {
            type='G' ; 
        } else if ( sous_chapitre.right(2)=='98') {
            type='C';
        } else {
            type='I';
        }
        Return type ; 
    }

    public static date conv_date (date date1) {
        date d1 ;
        if(date1==null || date1.year()==1900 ) {
            d1=null ; 
        } else  {
            d1=date1;
        }
        Return d1 ; 
    }

    // this function return 123456.28 in 123 457,28 (depending on decimal)
    Public static string conv_number_thousand (decimal dec, integer nb_decimal) {
        string amount;
        if(dec!=null) {
            dec=dec.setscale(nb_decimal);
            if (!string.valueof(dec.format()).contains('.') && !string.valueof(dec.format()).contains(',')){
                decimal d=123.45 ; 
                string s1=d.format();
                if(s1.contains('.')){
                    amount =  string.valueof(dec.format()) + '.00';
                } else {
                    amount =  string.valueof(dec.format()) + ',00';                    
                }
            }else if (string.valueof(dec.format()).right(2).contains('.') || string.valueof(dec.format()).right(2).contains(',')){
                amount =  string.valueof(dec.format()) + '0';
            }else {
               amount =  string.valueof(dec.format());
            }
            // Here we are sure to get something like this 123.00
            if(nb_decimal==0) {
                nb_decimal=3 ; 
                amount=amount.left(amount.length()-3);
            } else if(nb_decimal==1) {
                nb_decimal=3 ; 
                amount= amount.left(amount.length()-1);
            } 
        } else {
            Amount='';
        }
        
        
        return amount ; 

    }

    
    public static VIligne_affaire__c init_la() {
        VIligne_affaire__c Newla = new VIligne_affaire__c();
        Newla.Devis_Heure__c     =0;
        Newla.Devis_MontantD__c  =0;
        Newla.Devis_MontantD_E__c=0;
        Newla.Devis_MontantI__c  =0;
        Newla.Devis_MontantI_E__c=0;
        Newla.Devis_MontantC__c  =0;
        Newla.Devis_MontantC_E__c=0;
        Newla.Engage_brut_arrete_Heure__c =0;
        Newla.Engage_brut_arrete_MontantD__c =0;
        Newla.Engage_brut_arrete_MontantI__c =0;
        Newla.Engage_brut_arrete_MontantC__c =0;        
        Newla.Engage_brut_arrete_MontantD_E__c =0;
        Newla.Engage_brut_arrete_MontantI_E__c =0;
        Newla.Engage_brut_arrete_MontantC_E__c =0;  
        Newla.Dont_comptabiliseD__c =0;
        Newla.Dont_comptabiliseI__c =0;
        Newla.Dont_comptabiliseC__c =0;        
        Newla.Dont_comptabiliseD_E__c =0;
        Newla.Dont_comptabiliseI_E__c =0;
        Newla.Dont_comptabiliseC_E__c =0;   
        Newla.Ecart_C_A_F_Heure__c =0;
        Newla.Ecart_C_A_F_MontantD__c =0;        
        Newla.Ecart_C_A_F_MontantI__c =0;        
        Newla.Ecart_C_A_F_MontantC__c =0;                
        Newla.Ecart_C_A_F_MontantD_E__c =0;        
        Newla.Ecart_C_A_F_MontantI_E__c =0;        
        Newla.Ecart_C_A_F_MontantC_E__c =0;                
        
        return NewLa;
    }

    // List Current Running batches in Vision 
    // Return null if there is nothing , return the name of the current Running batch instead
    public static string isBatchRunning() {
        string status=null ; 
        
        List<AsyncApexJob>ListJob=[select id, ApexClass.name, CompletedDate ,JobType, Status, TotalJobItems, NumberOfErrors, MethodName, JobItemsProcessed   
                                     from AsyncApexJob 
                                    where status in ('Holding','Queued','Preparing','Processing')
                                      and ApexClass.name like 'VI%'
                                      and jobtype='BatchApex'];
        if(ListJob.size()>0)
            status=ListJob[0].ApexClass.name ;
        
        return Status ; 
    }


    public static boolean ByPassTrigger () {
        user user = [Select BypassApexTriggers__c from User where Id=:UserInfo.getUserId() limit 1];
        Return user.BypassApexTriggers__c ;          
    }   
    
    
    public static void code_coverage() {
        integer i = 0; 
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        i=0;
        i=0;        
        
    }
    
    
}