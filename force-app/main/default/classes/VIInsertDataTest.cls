public class VIInsertDataTest {

    public static VIType_de_depense__c tdMO ; 
    public static VIType_de_depense__c tdGAR ; 
    public static VIType_de_depense__c tdODH ; 
    public static VIType_de_depense__c tdODS ;     
    public static VIType_de_depense__c tdODF ;         
    public static VIType_de_depense__c tdPFG ;     
    public static VIType_de_depense__c tdMAT ;         
    public static VIType_de_depense__c tdAMP ;         
    public static VIType_de_depense__c tdEMM ;     
    public static VIType_de_depense__c tdFOL ;         
    public static VIType_de_depense__c tdAVT ;         
    public static VISousDomaine__c sd ; 
    
    public static void VIInsertData_GBP_Avenant() {
         
         tdMO = new VIType_de_depense__c (name ='MO - Main');
         tdGAR = new VIType_de_depense__c (name ='GAR - Garantie');
         tdODH = new VIType_de_depense__c (name ='ODH - ');        
         tdODS = new VIType_de_depense__c (name ='ODS - ');                
         tdODF = new VIType_de_depense__c (name ='ODF - ');                
         tdPFG = new VIType_de_depense__c (name ='PFG - ');                        
         tdMAT = new VIType_de_depense__c (name ='MAT - ');                                
         tdAMP = new VIType_de_depense__c (name ='AMP - ');                
         tdEMM = new VIType_de_depense__c (name ='EMM - ');                        
         tdFOL = new VIType_de_depense__c (name ='FOL - ');                                
         tdAVT = new VIType_de_depense__c (name ='AVT - ');                                        
        list<VIType_de_depense__c>listTd = new list<VIType_de_depense__c>();
         listTd.add(tdMO);
         listTd.add(tdGAR);        
         listTd.add(tdODH);                
         listTd.add(tdODS);                
         listTd.add(tdODF);                
         listTd.add(tdPFG);                
         listTd.add(tdMAT);                
         listTd.add(tdAMP);                
         listTd.add(tdEMM);                
         listTd.add(tdFOL);    
         listTd.add(tdAVT);                       
         insert listTd ; 
        
         VICentre_Section__c cs = new VICentre_Section__c (name ='801');
         insert cs; 

         sd = new VISousDomaine__c (name='PRO',Code_fiche_affaire__c ='1 Clients -vision cumulée', Libelle_Domaine__c ='DIC', Mode_de_calcul_de_l_avancement__c ='1', Compte__c ='700', Type_d_imputation__c='4');
         insert sd;
        
         VICompte_General__c cg = new VICompte_General__c(name='700000', libelle__c='7000000');
         insert cg ; 
        
         VIpays__c p2 = new VIPays__c(name='UK', CurrencyIsoCode='GBP');
         insert p2;
         VIEntiteBW__c ebw = new VIEntiteBW__c(name='BW GBR', CurrencyIsoCode='GBP',entite_bw__c='2',ouvert__c=true,
                                      adresse_1__c='aa',nom_long__c='aa',
                                      Compte_Client_Avancement_Local__c='7',
                                      Compte_Client_Avancement_Groupe__c='7',
                                      Compte_Bilan_Garantie_Groupe__c ='7', Compte_Bilan_Garantie_Local__c='7',
                                      Compte_Charge_Garantie_Groupe__c ='7', Compte_Charge_Garantie_local__c='7',
                                      Compte_Charge_Reprise_Garantie_Groupe__c ='7', Compte_Charge_Reprise_Garantie_local__c='7',
                                      Compte_Loc_AMP_Groupe__c ='7', Compte_Loc_AMP_local__c='7',
                                      Compte_Loc_EMM_Groupe__c ='7', Compte_Loc_EMM_local__c='7',
                                      Compte_Loc_FOL_Groupe__c ='7', Compte_Loc_FOL_local__c='7',
                                      Type_de_depense_Avancement__c='AVT',Type_de_depense_Garantie__c='GAR');
         insert ebw;
                 
         VITauxHoraire__c tx = new VITauxHoraire__c (entite_bw__c='2',centre_section__c=cs.id,
                                       date_de_debut__c=system.today().adddays(-1000), 
                                       date_de_fin__c=system.today().adddays(1000),
                                       Taux_devis_conversion_Complet__c =1, Taux_devis_conversion_PRI__c=1,taux_devis_horaire__c=1, 
                                       Taux_engage_conversion_Complet__c =1, Taux_engage_conversion_PRI__c=1,taux_engage_horaire__c=1, 
                                       CurrencyIsoCode='GBP' );
         insert tx;

         VISchedCreatePeriode v = new VISchedCreatePeriode();
         v.execute(null);
    
         date d1 = system.today().addmonths(-1).toStartOfMonth();
         date d2 = system.today().addmonths(1);        
         list<VIPeriode__c>ListPeriode = [SELECT id, statut__c, date_de_debut__c, date_de_fin__c
                                           FROM VIPeriode__c
                                          where date_de_debut__c>=:d1 and
                                                date_de_debut__c<=:d2];

         for(VIPeriode__c per: ListPeriode) {
            if(per.date_de_debut__c<=system.today() && per.date_de_fin__c>=system.today()) {
                per.statut__c=VIConstant.PERIODE_OUVERTE ; 
            }
                

            if(per.date_de_debut__c<=d1 && per.date_de_fin__c>=d1) {
                per.statut__c=VIConstant.PERIODE_DERNIERE ; 
            }

            if(per.date_de_debut__c<=d2 && per.date_de_fin__c>=d2) {
                per.statut__c=VIConstant.PERIODE_PREOUVERTE ; 
            }
         }
         update ListPeriode ; 
                
        
         Account newAccount = new Account (Name = 'BABCOCK WANSON', ShippingCity = 'Lebanon', ShippingStreet = 'Lebanon',
                                              ShippingPostalCode = '123' , BillingStreet = 'Lebanon', BillingCity = 'Lebanon', 
                                              BillingPostalCode = '123', ACC_SIREN__c = '123456779');
         insert newAccount;
        
         VIAffaire__c aff= new VIAffaire__c(compte__c=newAccount.id,CurrencyIsoCode='GBP', name='B80000',
                                            entite_bw__c='2', Nom_affaire__c='test',
                                            Produit_SousDomaine__c =sd.id,
                                            Date_ouverture_affaire__c=System.today(),
                                            Date_de_SAV_previsionnelle__c=System.today().adddays(100));
         insert aff; 
         system.debug('VIInsertData1 After Aff');
        
         VILigne_d_affaire_mensuelle__c lam = [SELECT id FROM VILigne_d_affaire_mensuelle__c LIMIT 1];
         system.debug('VIInsertData1 After LAM');
        
         VIParametres__c param = new VIParametres__c(Nb_jours_retention_import__c=0, Nb_jours_retention_logs__c=0 );
         insert param;
        
    }

    public static void VIInsertData_EUR_Affaire() {
         
         tdMO = new VIType_de_depense__c (name ='MO - Main');
         tdGAR = new VIType_de_depense__c (name ='GAR - Garantie');
         tdODH = new VIType_de_depense__c (name ='ODH - ');        
         tdODS = new VIType_de_depense__c (name ='ODS - ');                
         tdODF = new VIType_de_depense__c (name ='ODF - ');                
         tdPFG = new VIType_de_depense__c (name ='PFG - ');                        
         tdMAT = new VIType_de_depense__c (name ='MAT - ');                                
         tdAMP = new VIType_de_depense__c (name ='AMP - ');                
         tdEMM = new VIType_de_depense__c (name ='EMM - ');                        
         tdFOL = new VIType_de_depense__c (name ='FOL - ');                                
         tdAVT = new VIType_de_depense__c (name ='AVT - ');                                        
         list<VIType_de_depense__c>listTd = new list<VIType_de_depense__c>();
         listTd.add(tdMO);
         listTd.add(tdGAR); 
         listTd.add(tdODH);                
         listTd.add(tdODS);                
         listTd.add(tdODF);                
         listTd.add(tdPFG);                
         listTd.add(tdMAT);                
         listTd.add(tdAMP);                
         listTd.add(tdEMM);                
         listTd.add(tdFOL); 
         listTd.add(tdAVT);                
        
         insert listTd ; 
         
         VICentre_Section__c cs = new VICentre_Section__c (name ='801');
         insert cs; 

         sd = new VISousDomaine__c (name='PRO',Code_fiche_affaire__c ='1 Clients -vision cumulée', Libelle_Domaine__c ='DIC', Mode_de_calcul_de_l_avancement__c ='1',Code_sous_domaine__c='PRE', Compte__c ='700',Type_d_imputation__c='4' );
         insert sd;
         VICompte_General__c cg = new VICompte_General__c(name='700000', libelle__c='7000000');
         insert cg ; 

         VIpays__c p2 = new VIPays__c(name='FR', CurrencyIsoCode='EUR');
         insert p2;
         VIentitebw__c ebw = new VIentitebw__c(name='BW FRA', CurrencyIsoCode='EUR',entite_bw__c='1',ouvert__c=true,
                                      adresse_1__c='aa',nom_long__c='aa',                                               
                                      Compte_Client_Avancement_Local__c='7',
                                      Compte_Client_Avancement_Groupe__c='7',
                                      Compte_Bilan_Garantie_Groupe__c ='7', Compte_Bilan_Garantie_Local__c='7',
                                      Compte_Charge_Garantie_Groupe__c ='7', Compte_Charge_Garantie_local__c='7',
                                      Compte_Charge_Reprise_Garantie_Groupe__c ='7', Compte_Charge_Reprise_Garantie_local__c='7',
                                      Compte_Loc_AMP_Groupe__c ='7', Compte_Loc_AMP_local__c='7',
                                      Compte_Loc_EMM_Groupe__c ='7', Compte_Loc_EMM_local__c='7',
                                      Compte_Loc_FOL_Groupe__c ='7', Compte_Loc_FOL_local__c='7',
                                      Type_de_depense_Avancement__c='AVT',Type_de_depense_Garantie__c='GAR');
         insert ebw;
                 
         VITauxHoraire__c tx = new VITauxHoraire__c (entite_bw__c='1',centre_section__c=cs.id,
                                       date_de_debut__c=system.today().adddays(-1000), 
                                       date_de_fin__c=system.today().adddays(1000),
                                       Taux_devis_conversion_Complet__c =1, Taux_devis_conversion_PRI__c=1,taux_devis_horaire__c=1, 
                                       Taux_engage_conversion_Complet__c =1, Taux_engage_conversion_PRI__c=1,taux_engage_horaire__c=1, 
                                       CurrencyIsoCode='EUR' );
         insert tx;

        
         VISchedCreatePeriode v = new VISchedCreatePeriode();
         v.execute(null);
    
         date d1 = system.today().addmonths(-1).toStartOfMonth();
         date d2 = system.today().addmonths(1);        
         list<VIPeriode__c>ListPeriode = [SELECT id, statut__c, date_de_debut__c, date_de_fin__c
                                           FROM VIPeriode__c
                                          where date_de_debut__c>=:d1 and
                                                date_de_debut__c<=:d2];

         for(VIPeriode__c per: ListPeriode) {
            if(per.date_de_debut__c<=system.today() && per.date_de_fin__c>=system.today()) {
                per.statut__c=VIConstant.PERIODE_OUVERTE ; 
            }
                

            if(per.date_de_debut__c<=d1 && per.date_de_fin__c>=d1) {
                per.statut__c=VIConstant.PERIODE_DERNIERE ; 
            }

            if(per.date_de_debut__c<=d2 && per.date_de_fin__c>=d2) {
                per.statut__c=VIConstant.PERIODE_PREOUVERTE ; 
            }
         }
         update ListPeriode ; 
        
        
         Account newAccount = new Account (Name = 'BABCOCK WANSON', ShippingCity = 'Lebanon', ShippingStreet = 'Lebanon',
                                              ShippingPostalCode = '123' , BillingStreet = 'Lebanon', BillingCity = 'Lebanon', 
                                              BillingPostalCode = '123', ACC_SIREN__c = '123456779',ACC_ERPIdFRA__c='123');
         insert newAccount;
        
         VIAffaire__c aff= new VIAffaire__c(compte__c=newAccount.id,CurrencyIsoCode='EUR',name='B80000',
                                            entite_bw__c='1', Nom_affaire__c='test',
                                            Produit_SousDomaine__c =sd.id,
                                            Date_ouverture_affaire__c=System.today(),
                                            Date_de_SAV_previsionnelle__c=System.today().adddays(100));
         insert aff; 
                  
         VILigne_d_affaire_mensuelle__c lam = [SELECT id FROM VILigne_d_affaire_mensuelle__c LIMIT 1 ];
                 
         VIParametres__c param = new VIParametres__c(Nb_jours_retention_import__c=0, Nb_jours_retention_logs__c=0 );
         insert param;   
    }

    public static void VIInsertData_Facture() {
         VIAffaire__c aff       = [SELECT id,compte__c,currencyisocode from VIAffaire__c LIMIT 1 ];  
         VICompte_general__c c473000 = new  VICompte_general__c  (name='473000');
         insert c473000 ;
         VIFacture__c fac = new VIFacture__c(compte__c=aff.compte__c, affaire__c=aff.id,date__c=system.today(),
                                             Date_echeance__c =system.today(), CurrencyIsoCode=aff.CurrencyIsoCode,
                                             Montant_HT__c=1,Montant_TVA__c=1,Montant_TTC__c=1,Montant_paye__c=1,
                                             Compte_general__c=c473000.id);
         insert fac;
         update fac;
    }

    public static void VIInsertData_Achat() {
         VICentre_section__c cs  = [SELECT id from VICentre_section__c LIMIT 1 ];        
         VIType_de_depense__c td = [SELECT id from VIType_de_depense__c where name like 'GAR%' LIMIT 1 ];
         VIAffaire__c aff        = [SELECT id,CurrencyIsoCode,entite_bw__c,name from VIAffaire__c LIMIT 1 ]; 
                 
         VITauxIncorporation__c tx = new VITauxIncorporation__c (entite_bw__c=aff.entite_bw__c,Type_de_depense__c=td.id,
                                       Produit_SousDomaine__c =sd.id,
                                       date_de_debut__c=system.today().adddays(-1000), 
                                       date_de_fin__c=system.today().adddays(1000),
                                       Taux_Complet__c =1, Taux_PRI__c=1,CurrencyIsoCode=aff.CurrencyIsoCode );
         insert tx;

         VIAchat__c ac = new VIAchat__c(affaire__c=aff.id,date__c=system.today().adddays(1),Centre_Section__c=cs.id,Type_depense__c=td.id,
                                        CommandeD__c =100, ComptabiliseD__c =100,
                                        CurrencyIsoCode=aff.CurrencyIsoCode, sous_chapitre__c='00-00',
                                        num_cde__c='GWB0001',
                                        origine__c='SQL-SERVER-Facture-Fournisseur',name=aff.name+'-F-'+'code');
         insert ac;
         update ac;
    }

    public static void VIInsertData_Pointage() {
         VICentre_section__c cs = [SELECT id from VICentre_section__c LIMIT 1 ];
         VIAffaire__c aff       = [SELECT id,CurrencyIsoCode from VIAffaire__c LIMIT 1 ];        
         VIPointage__c po= new VIPointage__c(affaire__c=aff.id,date__c=system.today(),date_comptabilisation__c=system.today(),heures__c=1, Centre_Section__c =cs.id, 
                                             CurrencyIsoCode=aff.CurrencyIsoCode,employe__c=UserInfo.getUserId(), numero_unique__c='AAAAA',
                                             sous_chapitre__c='00-00');
         insert po;
         update po;
    }

    public static void VIInsertData_ligne_comptable() {
         VIPeriode__c per_ouverte = [SELECT id from VIPeriode__c where statut__c=:VIConstant.PERIODE_OUVERTE ];
         VIPeriode__c per_preouverte = [SELECT id from VIPeriode__c where statut__c=:VIConstant.PERIODE_PREOUVERTE ];        
         VICentre_section__c cs = [SELECT id,name from VICentre_section__c LIMIT 1 ];
         VIAffaire__c aff       = [SELECT id,CurrencyIsoCode from VIAffaire__c LIMIT 1 ];   
         VICompte_General__c cg = [SELECT id,name from VICompte_General__c LIMIT 1 ];   
         VILigne_comptable__c lc= new VILigne_comptable__c(Affaire__c=aff.id ,Centre__c=cs.name ,CompteComptable_local__c=cg.id, Date_ecriture__c=system.today() ,Montant__c=1 ,
                                             sens__c='C' ,  Periode_comptable__c=per_ouverte.id ,Statut_ecriture_comptable__c='40'  );
         insert lc;

         VILigne_comptable__c lc1= new VILigne_comptable__c(Affaire__c=aff.id ,Centre__c=cs.name ,CompteComptable_local__c=cg.id, Date_ecriture__c=system.today().adddays(30) ,Montant__c=1 ,
                                             sens__c='C' ,  Periode_comptable__c=per_preouverte.id ,Statut_ecriture_comptable__c='40'  );

         insert lc1;        
    }
    
    
    public static void VIInsertData_Avenant() {
         VICentre_section__c cs = [SELECT id from VICentre_section__c LIMIT 1 ];
         VIAffaire__c aff       = [SELECT id,CurrencyIsoCode,entite_bw__c from VIAffaire__c LIMIT 1 ];        

        
         VITauxIncorporation__c tx = new VITauxIncorporation__c (entite_bw__c=aff.entite_bw__c,Type_de_depense__c=tdGAR.id,
                                       Produit_SousDomaine__c =sd.id,
                                       date_de_debut__c=system.today().adddays(-1000), 
                                       date_de_fin__c=system.today().adddays(1000),
                                       Taux_Complet__c =1, Taux_PRI__c=1,CurrencyIsoCode=aff.CurrencyIsoCode );
         insert tx;

        
         VIAvenant__c av = new VIAvenant__c(affaire__c=aff.id,date__c=system.today(),Statut_avenant__c =VIConstant.AVENANT_PREVU, currencyIsoCode=aff.CurrencyIsoCode);
         insert av;
        
         VILigne_budget__c lb = new VILigne_budget__c(Avenant__c=av.id,Centre_Section__c=cs.id,Type_de_depense__c=tdMO.id,heures__c=3, currencyIsoCode=aff.CurrencyIsoCode);
         VILigne_budget__c lb1 = new VILigne_budget__c(Avenant__c=av.id,Centre_Section__c=cs.id,Type_de_depense__c=tdGAR.id,Debours__c =3, currencyIsoCode=aff.CurrencyIsoCode);
         list<VILigne_budget__c>ListLb = new list<VILigne_budget__c>();
         ListLb.add(lb);
         ListLb.add(lb1);
         insert ListLb;        
         update lb;
         system.debug('VIInsertData1 After LB');

        
         av.Statut_avenant__c=VIConstant.AVENANT_EN_COURS;
         update av;
         system.debug('VIInsertData1 After Update Avenant');
    }
    public static void VIInsertData_Avenant_sans_update() {
         VICentre_section__c cs = [SELECT id from VICentre_section__c LIMIT 1 ];
         VIAffaire__c aff       = [SELECT id,CurrencyIsoCode,entite_bw__c from VIAffaire__c LIMIT 1 ];        

        
         VITauxIncorporation__c tx = new VITauxIncorporation__c (entite_bw__c=aff.entite_bw__c,Type_de_depense__c=tdGAR.id,
                                       Produit_SousDomaine__c =sd.id,
                                       date_de_debut__c=system.today().adddays(-1000), 
                                       date_de_fin__c=system.today().adddays(1000),
                                       Taux_Complet__c =1, Taux_PRI__c=1,CurrencyIsoCode=aff.CurrencyIsoCode );
         insert tx;

        
         VIAvenant__c av = new VIAvenant__c(code_avenant__c='AV-1',affaire__c=aff.id,date__c=system.today(),Statut_avenant__c =VIConstant.AVENANT_EN_COURS, currencyIsoCode=aff.CurrencyIsoCode);
         insert av;
        
         VILigne_budget__c lb = new VILigne_budget__c(Avenant__c=av.id,Centre_Section__c=cs.id,Type_de_depense__c=tdMO.id,heures__c=3, currencyIsoCode=aff.CurrencyIsoCode);
         VILigne_budget__c lb1 = new VILigne_budget__c(Avenant__c=av.id,Centre_Section__c=cs.id,Type_de_depense__c=tdGAR.id,Debours__c =3, currencyIsoCode=aff.CurrencyIsoCode);
         list<VILigne_budget__c>ListLb = new list<VILigne_budget__c>();
         ListLb.add(lb);
         ListLb.add(lb1);
         insert ListLb;        
    }

    
}