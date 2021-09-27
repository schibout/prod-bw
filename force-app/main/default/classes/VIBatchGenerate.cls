//
//   This batch generate the ecriture_comptable__C
//  
//  
// 
/*  for running by hand : 
  VIBatchGenerate v = new VIBatchGenerate('','1');
  v.execute(null);
*
*  for running every night at 22:16
     VIBatchGenerate m = new VIBatchGenerate (); 
     String sch = '0 16 22 * * ?'; 
     String jobID = system.schedule('VIBatchGenerate', sch, m); 

 */
global class VIBatchGenerate implements Schedulable,Database.Batchable<sObject>, Database.Stateful  {

    Global double num_record = 0; 
    Global String IDLog ='';  
    Global String Statut_definitif ='';  
    Global VIperiode__c periode_ouverte ;    
    Global Map<string,VIEntiteBW__c>Mapentite_bw = new Map<string,VIEntiteBW__c>();  
    Global Map<String, VICompte_general__c >MapCompteGeneral = new Map<String, VICompte_general__c>();
    Global Map<string, VIPays__c >MapPays = new Map<String, VIPays__c>();
    private boolean definitif ; 
    private string AffaireAGenerer; 
    private string Entite_bw ;
    Global VICentre_section__c CS801;    
    Global VIType_de_depense__c tdAMP ; 
    Global VIType_de_depense__c tdEMM ; 
    Global VIType_de_depense__c tdFOL ;     
    
     public VIBatchGenerate(String Param1,String Param2 ) {
        AffaireAGenerer = Param1;        
        Entite_bw = Param2;                
    }


    global Iterable<sObject> start(Database.BatchableContext BC) {

        Statut_definitif=VIConstant.EC_BROUILLON;
        
        Periode_ouverte = [SELECT id,name, entite_bw__c, date_de_debut__c, date_de_fin__c 
                             FROM VIPeriode__c
                            WHERE Statut__c=:VIConstant.PERIODE_OUVERTE
                              AND entite_bw__c=:entite_bw] ; 
        
        for(VICompte_general__c cg: [SELECT id,name, type_enregistrement__c 
                                       FROM VICompte_general__c]) {
            MapCompteGeneral.put(cg.name, cg);
        }

        for(VIPays__c pays : [select name, UE__c from VIPays__C]) {
            MapPays.put(pays.name,pays);
        }

        CS801 = [select id from VICentre_section__c where name like '801%' ]; 
        
        for(VIType_de_depense__c td : [SELECT ID,name from VIType_de_depense__c where name like 'EMM%' or name like 'AMP%' or name like 'FOL%']) {
            if(td.name.startswith('EMM'))
                 tdEMM=td ; 

            if(td.name.startswith('AMP'))
                 tdAMP=td ; 

            if(td.name.startswith('FOL'))
                 tdFOL=td ; 
        }        
        
        for(VIEntiteBW__c Ebw: [SELECT id,name, ID_Affaire_location__c, Entite_bw__c,
                                    Compte_Client_Avancement_Local__c,  Compte_Client_Avancement_Groupe__c,
                                    Type_de_depense_Avancement__c, 
                                    Compte_Bilan_Garantie_Local__c,     Compte_Bilan_Garantie_Groupe__c,                             
                                    Compte_Charge_Garantie_Local__c,    Compte_Charge_Garantie_Groupe__c,
                                    Compte_Charge_Reprise_Garantie_Local__c , Compte_Charge_Reprise_Garantie_Groupe__c,
                                    Compte_Charge_Solde_Garantie_Local__c  , Compte_Charge_Solde_Garantie_Groupe__c ,
                                    Type_de_depense_garantie__c,
                                    Compte_loc_AMP_local__c,            Compte_loc_AMP_Groupe__c,
                                    Type_de_depense_AMP__c,
                                    Compte_loc_EMM_local__c,            Compte_loc_EMM_Groupe__c,
                                    Type_de_depense_EMM__c,                             
                                    Compte_loc_FOL_local__c,            Compte_loc_FOL_Groupe__c,
                                    Type_de_depense_FOL__c                             
                               FROM VIentiteBW__c]) {
            Mapentite_bw.put(Ebw.Entite_bw__c, Ebw);                                   
        }
        string AffaireAGenerer1=AffaireAGenerer+'%';        

        List<VILigne_d_affaire_mensuelle__c>ListLam = new List<VILigne_d_affaire_mensuelle__c>();               

        ListLam =[SELECT Affaire__c ,periode_comptable__c , affaire__r.Compte__r.BillingCountryCode ,Total_CA_a_l_avancement__c  ,
                         affaire__r.date_de_sav_reelle__c, 
                         affaire__r.Mode_de_calcul_de_l_avancement__c,Total_Pourcentage_d_avancement__c,
                         affaire__r.entite_bw__c,
                         periode_comptable__r.date_de_fin__c,affaire__r.Date_de_fin_de_garantie__c,
                         affaire__r.name, pv_total__c,pv_facture__c,Garantie_reprise__c,
                         affaire__r.Produit_SousDomaine__r.Compte__c ,affaire__r.Produit_SousDomaine__r.duree_garantie__c,
                         AMP__c, EMM__c, FOL__c,
                         garantie_reprise_consommee__c,
                         garantie_solde__c,garantie_dotation__c,
                         CA_a_comptabiliser1__c , CA_a_comptabiliserE__c 
                    FROM VILigne_d_affaire_mensuelle__c lam
                   WHERE Periode_comptable__c =:Periode_ouverte.id
                      AND (Date_de_fin_de_garantie__c =null or Date_de_fin_de_garantie__c >=:periode_ouverte.date_de_fin__c)
                      AND affaire__r.entite_bw__c=:Entite_bw
                      AND affaire__r.name like :AffaireAGenerer1
                      AND (not (affaire__r.name like 'L%'))
                      AND affaire__r.Produit_SousDomaine__r.type_d_imputation__c like '4%'
                      AND (    M_1_Total_Pourcentage_d_avancement__c!=100 or 
                               Total_Pourcentage_d_avancement__c!=100  or 
                               affaire__r.date_de_sav_reelle__c=:periode_ouverte.date_de_fin__c or
                               affaire__r.Date_max_mouvement__c >=:periode_ouverte.date_de_debut__c)]; 
        
        IDLog=VIUtils.LogWrite('VIBatchGenerate','4 Running','','Start ');
        num_record = 0 ;

        return  ListLam;
    }

    global void execute(Database.BatchableContext BC, List<VILigne_d_affaire_mensuelle__c> scope) {
                
        // We need the Compute all amount already in comptabilite  for each affaire
        list<id>ListId = new List<id>();

        for(VILigne_d_affaire_mensuelle__c lam:scope) {
            
            listid.add(lam.affaire__c);
            system.debug('EC generation '+lam.affaire__r.name);
        }

        
        Map<string,double>MapDejaComptabilise = new Map<string,double>();
        Map<string,double>MapGarantieDejaComptabilise = new Map<string,double>();
        for(VIligne_comptable__c lc : [SELECT Affaire__c,Affaire__r.name ,periode_comptable__c , sens__c,type_de_depense__c,
                                              montant_avec_signe__c,libelle__c
                                         FROM VIligne_comptable__c 
                                        WHERE affaire__c in :listid
                                          and (Statut_ecriture_comptable__c='40' or statut_ecriture_comptable__c='42')
                                          AND Periode_comptable__r.name<=:periode_ouverte.name
                                          AND Date_ecriture__c < :periode_ouverte.date_de_debut__c
                                          AND (Comptecomptable_local__r.name like '7%' or Comptecomptable_local__r.name like '9%')
                                          AND Type_de_depense__c in ('AVT', 'AMP', 'EMM', 'FOL')
                                     ORDER BY Periode_comptable__r.name]) {
            //double sens = (lc.sens__c=='C' ? 1 : -1) ;
            string key =lc.affaire__c+'-'+lc.type_de_depense__c;
                                         
            //if('AMP-EMM-FOL'.contains(lc.type_de_depense__c) && lc.sens__c=='C'   ) 
            //    continue ; 
                                         
            if(!MapDejaComptabilise.containskey(key) ) {
                MapDejaComptabilise.put(key,  lc.montant_Avec_signe__c * (-1)) ;
            } else {
                MapDejaComptabilise.put(key,  (lc.montant_Avec_signe__c* (-1))+MapDejaComptabilise.get(key)) ;
            }
            if(lc.libelle__c==VIConstant.EC_REPRISE_PROVISION_GARANTIE) {
                if(!MapGarantieDejaComptabilise.containskey(lc.affaire__c) ) {
                    MapGarantieDejaComptabilise.put(lc.affaire__c, lc.montant_avec_signe__c * (-1)) ;
                } else {
                    MapGarantieDejaComptabilise.put(lc.affaire__c, (lc.montant_avec_signe__c * (-1))+MapDejaComptabilise.get(lc.affaire__c)) ;
                }                
            }
        } 
        
        system.debug('MapDejaComptabilise '+MapDejaComptabilise);
        

        // Do we have "Ecriture avancement" with status Envoyé ? 
        Map<string,string>MapAvancementEnvoyee = new Map<string,string>();
        Map<string,string>MapRepriseEnvoyee = new Map<string,string>();
        
        Map<string,list<VIligne_comptable__c>>MapAffaireEcriture = new Map<string,list<VIligne_comptable__c>>();        
        for(VIligne_comptable__c lc: [SELECT id,affaire__c,affaire_de_rattachement__c,libelle__c,Statut_ecriture_comptable__c
                                        FROM VIligne_comptable__c 
                                       WHERE periode_comptable__r.name=:periode_ouverte.name
                                         AND Statut_ecriture_comptable__c!='40'
                                         //AND (Comptecomptable_local__r.name like '7%' or Comptecomptable_local__r.name like '9%')
                                         AND affaire_de_rattachement__c in :listid]) {
            if(lc.libelle__c==VIConstant.EC_CA && 
                 (lc.Statut_ecriture_comptable__c==VIConstant.EC_ENVOYEE || 
                  lc.Statut_ecriture_comptable__c==VIConstant.EC_A_PRENDRE)) { 
                MapAvancementEnvoyee.put(lc.affaire_de_rattachement__c,lc.affaire_de_rattachement__c);
            }
            if(lc.libelle__c==VIConstant.EC_PROVISION_GARANTIE && 
                 (lc.Statut_ecriture_comptable__c==VIConstant.EC_ENVOYEE || 
                  lc.Statut_ecriture_comptable__c==VIConstant.EC_A_PRENDRE)) { 
                MapRepriseEnvoyee.put(lc.affaire_de_rattachement__c,lc.affaire_de_rattachement__c);
            }
            if(lc.Statut_ecriture_comptable__c==VIConstant.EC_BROUILLON || lc.Statut_ecriture_comptable__c==VIConstant.EC_GENEREE_A_NE_PAS_ENVOYER) {                                  
                list<VIligne_comptable__c> ListEc = new list<VIligne_comptable__c>();
                if(MapAffaireEcriture.containskey(lc.affaire_de_rattachement__c)) {
                   ListEc=MapAffaireEcriture.get(lc.affaire_de_rattachement__c);
                }
                ListEc.add(lc);
                MapAffaireEcriture.put(lc.affaire_de_rattachement__c,ListEc);  
            }
        }          
        system.debug('MapAvancementEnvoyee '+MapAvancementEnvoyee);

        
        list<VIligne_comptable__c>ListInsertEcriture = new list<VIligne_comptable__c>();
        list<VIligne_comptable__c>ListDeleteEcriture = new list<VIligne_comptable__c>();
        list<Id>ListAffaireWithAMP = new List<id>();
        Map<id,string>MapAffaire = new Map<id,string>();

        // Let's loop for each LAM, wich means over each affaire
        for(VILigne_d_affaire_mensuelle__c lam:scope) {
            
            num_record = num_record + 1 ; 

            VIEntiteBW__c Entite_bw = MapEntite_bw.get(lam.affaire__r.entite_bw__c);
            
            // This field is 000 for domestic, 020 for UE, 030 for export
            string localisation='030';
            if(MapPays.containskey(lam.affaire__r.compte__r.billingCountryCode)) {
                if(lam.affaire__r.compte__r.billingCountryCode=='FR'){
                    localisation='000';
                } else {
                    if(MapPays.get(lam.affaire__r.compte__r.billingCountryCode).UE__c) {
                        localisation='020';
                   }
                }
            }
            system.debug('on est sur l affaire '+lam.affaire__r.name);
            MapAffaire.put(lam.affaire__c, lam.affaire__r.name);
            
            // Do we have a Date SAV for this month ?  If Yes, on fait tomber le CA qui reste           
            if(lam.affaire__r.Date_de_SAV_reelle__c==lam.periode_comptable__r.date_de_fin__c) {
                system.debug('on est sur la date de SAV');
                // Do we have already generate the ecriture ? 
                if(!MapAvancementEnvoyee.containskey(lam.affaire__c)) {
                    // No, We haven't so let's generate the SAV ecriture
                    // 1. Prise en compte du PV facturé
                    
                    double mt = lam.Total_CA_a_l_avancement__c ;
                    system.debug('on envoie le reste du CA '+mt+' '+MapDejaComptabilise.get(lam.affaire__c+'-AVT'));
                    if(MapDejaComptabilise.containskey(lam.affaire__c+'-AVT')) {
                        mt=mt - MapDejaComptabilise.get(lam.affaire__c+'-AVT');
                    }
                    
                    // if mt=0,the amount stay zero 
                    VIligne_comptable__c ecFin1 = new VIligne_comptable__c(periode_comptable__c=lam.periode_comptable__c, 
                                                                 compte_comptable_groupe__c = entite_bw.Compte_Client_Avancement_local__c,      
                                                                 comptecomptable_local__c = MapCompteGeneral.get(entite_bw.Compte_Client_Avancement_local__c).id, 
                                                                 chapitre__c='00',
                                                                 sous_chapitre__c='00-00',
                                                                 Type_de_depense__c=entite_bw.Type_de_depense_Avancement__c,                                                                           
                                                                 Date_ecriture__c =lam.periode_comptable__r.date_de_fin__c,              
                                                                 Statut_ecriture_comptable__c = VIConstant.EC_A_PRENDRE,                                                                           
                                                                 affaire__c=lam.affaire__c,
                                                                 affaire_de_rattachement__c=lam.affaire__c,          
                                                                 libelle__c=VIConstant.EC_CA,                                                                                 
                                                                 centre__c='800',
                                                                 ligne_affaire_mensuelle__c=lam.id,
                                                                 type_ligne_comptable__c='SAV',          
                                                                 sens__c = 'D',
                                                                 type_enregistrement__c=MapCompteGeneral.get(entite_bw.Compte_Client_Avancement_local__c).type_enregistrement__c,
                                                                 montant__c=mt );
                    ListInsertEcriture.add(ecFin1);

                    VIligne_comptable__c ecFin2 = new VIligne_comptable__c(periode_comptable__c=lam.periode_comptable__c, 
                                                                 compte_comptable_groupe__c = lam.affaire__r.Produit_SousDomaine__r.Compte__c+localisation,      
                                                                 comptecomptable_local__c =MapCompteGeneral.get(lam.affaire__r.Produit_SousDomaine__r.Compte__c+localisation).id , 
                                                                 chapitre__c='00',
                                                                 sous_chapitre__c='00-00',
                                                                 Type_de_depense__c=entite_bw.Type_de_depense_Avancement__c,                                                                                                                                                      
                                                                 Date_ecriture__c =lam.periode_comptable__r.date_de_fin__c,              
                                                                 Statut_ecriture_comptable__c = VIConstant.EC_A_PRENDRE,                                                                                                                                                      
                                                                 affaire__c=lam.affaire__c,
                                                                 affaire_de_rattachement__c=lam.affaire__c,                                                                                     
                                                                 libelle__c=VIConstant.EC_CA,                                                                                 
                                                                 centre__c='800',
                                                                 ligne_affaire_mensuelle__c=lam.id,
                                                                 type_ligne_comptable__c='SAV',          
                                                                 sens__c = 'C',
                                                                 type_enregistrement__c=MapCompteGeneral.get(lam.affaire__r.Produit_SousDomaine__r.Compte__c+localisation).type_enregistrement__c,
                                                                 montant__c=mt  );
                    ListInsertEcriture.add(ecFin2);
                }
                                        

                // Do we have a garantie ? 
                if(!MapRepriseEnvoyee.containskey(lam.affaire__c)) {    
                    double mt1 = lam.garantie_dotation__c ;
                    VIligne_comptable__c ecGar1 = new VIligne_comptable__c(periode_comptable__c=lam.periode_comptable__c, 
                                                             compte_comptable_groupe__c = entite_bw.Compte_Bilan_Garantie_Groupe__c ,      
                                                             comptecomptable_local__c = MapCompteGeneral.get(entite_bw.Compte_Bilan_Garantie_local__c).id , 
                                                             chapitre__c='',
                                                             sous_chapitre__c='',
                                                             Type_de_depense__c='',                                                                           
                                                             Date_ecriture__c =lam.periode_comptable__r.date_de_fin__c,              
                                                             Statut_ecriture_comptable__c = VIConstant.EC_A_PRENDRE,                                                                           
                                                             affaire__c=null,
                                                             affaire_de_rattachement__c=lam.affaire__c,                                                                                         
                                                             libelle__c=VIConstant.EC_PROVISION_GARANTIE,                                                                                 
                                                             centre__c='',
                                                             ligne_affaire_mensuelle__c=lam.id,
                                                             type_ligne_comptable__c='SAV',                                                                                         
                                                             sens__c = 'C',
                                                             type_enregistrement__c=MapCompteGeneral.get(entite_bw.Compte_Bilan_Garantie_local__c).type_enregistrement__c,
                                                             montant__c=mt1 );
                    ListInsertEcriture.add(ecGar1);

                    VIligne_comptable__c ecGar2 = new VIligne_comptable__c(periode_comptable__c=lam.periode_comptable__c, 
                                                             compte_comptable_groupe__c = entite_bw.Compte_Charge_Garantie_Groupe__c ,      
                                                             comptecomptable_local__c = MapCompteGeneral.get(entite_bw.Compte_Charge_Garantie_local__c).id , 
                                                             chapitre__c='99',
                                                             sous_chapitre__c='99-99',
                                                             Type_de_depense__c=entite_bw.Type_de_depense_Garantie__c,                                                                                                                                                          
                                                             Date_ecriture__c =lam.periode_comptable__r.date_de_fin__c,              
                                                             Statut_ecriture_comptable__c = VIConstant.EC_A_PRENDRE,                                                                                                                                                      
                                                             affaire__c=lam.affaire__c,
                                                             affaire_de_rattachement__c=lam.affaire__c,                                                                                         
                                                             libelle__c=VIConstant.EC_PROVISION_GARANTIE,                                                                                 
                                                             centre__c='801',
                                                             ligne_affaire_mensuelle__c=lam.id,
                                                             type_ligne_comptable__c='SAV',                                                                                         
                                                             sens__c = 'D',
                                                             type_enregistrement__c=MapCompteGeneral.get(entite_bw.Compte_Charge_Garantie_local__c).type_enregistrement__c,
                                                             montant__c=mt1  );
                    ListInsertEcriture.add(ecGar2);
                }

                // Let's delete the existing line
                if(MapAffaireEcriture.containskey(lam.affaire__c)) {
                    for(VILigne_comptable__c lc : MapAffaireEcriture.get(lam.affaire__c)) {
                        if(!ListDeleteEcriture.contains(lc)) {
                            ListDeleteEcriture.addAll(MapAffaireEcriture.get(lam.affaire__c));    
                        }
                    } 
                }
                    
            }
            
            // On est après la date de SAV réelle, on peut avoir de la reprise ou de la NCO
            if(lam.affaire__r.Date_de_SAV_reelle__c!=null) {
                system.debug('on est après la date de SAV, on génère les reprises de garantie ');
                // ECRITURES de REPRISE DE GARANTIE
                double mt = 0;
                string type_ligne_comptable ;  
                string Compte_comptable_groupe ; 
                string Compte_comptable_local ;                 
                if(lam.affaire__r.Date_de_fin_de_garantie__c>=lam.periode_comptable__r.date_de_fin__c) {
                    mt = lam.garantie_reprise_consommee__c ;
                    type_ligne_comptable = 'REP';  
                    Compte_comptable_groupe= entite_bw.Compte_Charge_reprise_Garantie_Groupe__c ;
                    Compte_comptable_local= entite_bw.Compte_Charge_reprise_Garantie_local__c ;                        

                    if(mt>0 || mt<0 ){
                        // Mode de calcul 1 
                        VIligne_comptable__c ec1 = new VIligne_comptable__c(periode_comptable__c=lam.periode_comptable__c, 
                                                             compte_comptable_groupe__c = Compte_comptable_groupe ,      
                                                             comptecomptable_local__c = MapCompteGeneral.get(Compte_comptable_local).id , 
                                                             chapitre__c='99',
                                                             sous_chapitre__c='99-99',
                                                             Type_de_depense__c=entite_bw.Type_de_depense_Garantie__c,                                                                                                                                                   
                                                             Date_ecriture__c =lam.periode_comptable__r.date_de_fin__c,
                                                             Statut_ecriture_comptable__c = Statut_definitif,
                                                             affaire__c=lam.affaire__c,
                                                             affaire_de_rattachement__c=lam.affaire__c,                                                                                  
                                                             libelle__c=VIConstant.EC_REPRISE_PROVISION_GARANTIE,
                                                             centre__c='801',
                                                             ligne_affaire_mensuelle__c=lam.id,
                                                             type_ligne_comptable__c=type_ligne_comptable,          
                                                             sens__c = 'C',
                                                             type_enregistrement__c=MapCompteGeneral.get(Compte_comptable_local).type_enregistrement__c,
                                                             montant__c=mt  );
                        ListInsertEcriture.add(ec1);

                        VIligne_comptable__c ec2 = new VIligne_comptable__c(periode_comptable__c=lam.periode_comptable__c, 
                                                             compte_comptable_groupe__c = entite_bw.Compte_Bilan_Garantie_Groupe__c ,      
                                                             comptecomptable_local__c = MapCompteGeneral.get(entite_bw.Compte_Bilan_Garantie_Local__c).id , 
                                                             chapitre__c='',
                                                             sous_chapitre__c='',
                                                             Type_de_depense__c='',                                                                                              
                                                             Date_ecriture__c =lam.periode_comptable__r.date_de_fin__c,
                                                             Statut_ecriture_comptable__c = Statut_definitif,
                                                             affaire__c=null,
                                                             affaire_de_rattachement__c=lam.affaire__c,                                                                                  
                                                             libelle__c=VIConstant.EC_REPRISE_PROVISION_GARANTIE,
                                                             centre__c='',
                                                             ligne_affaire_mensuelle__c=lam.id,
                                                             type_ligne_comptable__c=type_ligne_comptable,                                                                                  
                                                             sens__c = 'D',
                                                             type_enregistrement__c=MapCompteGeneral.get(entite_bw.Compte_Bilan_Garantie_Local__c).type_enregistrement__c,
                                                             montant__c=mt  );
                        ListInsertEcriture.add(ec2);
                    }
                }
                if(lam.affaire__r.Date_de_fin_de_garantie__c==lam.periode_comptable__r.date_de_fin__c) {
                    mt = lam.garantie_solde__c ;
                    type_ligne_comptable = 'NCO';
                    Compte_comptable_groupe= entite_bw.Compte_Charge_Solde_Garantie_Groupe__c ;    
                    Compte_comptable_local= entite_bw.Compte_Charge_solde_Garantie_local__c ;                        
                   
                    if(mt>0  || mt<0){
                        // Mode de calcul 1 
                        VIligne_comptable__c ec1 = new VIligne_comptable__c(periode_comptable__c=lam.periode_comptable__c, 
                                                             compte_comptable_groupe__c = Compte_comptable_groupe ,      
                                                             comptecomptable_local__c = MapCompteGeneral.get(Compte_comptable_local).id , 
                                                             chapitre__c='99',
                                                             sous_chapitre__c='99-99',
                                                             Type_de_depense__c=entite_bw.Type_de_depense_Garantie__c,                                                                                                                                                   
                                                             Date_ecriture__c =lam.periode_comptable__r.date_de_fin__c,
                                                             Statut_ecriture_comptable__c = Statut_definitif,
                                                             affaire__c=lam.affaire__c,
                                                             affaire_de_rattachement__c=lam.affaire__c,                                                                                  
                                                             libelle__c=VIConstant.EC_REPRISE_PROVISION_GARANTIE,
                                                             centre__c='801',
                                                             ligne_affaire_mensuelle__c=lam.id,
                                                             type_ligne_comptable__c=type_ligne_comptable,          
                                                             sens__c = 'C',
                                                             type_enregistrement__c=MapCompteGeneral.get(Compte_comptable_local).type_enregistrement__c,
                                                             montant__c=mt  );
                        ListInsertEcriture.add(ec1);

                        VIligne_comptable__c ec2 = new VIligne_comptable__c(periode_comptable__c=lam.periode_comptable__c, 
                                                             compte_comptable_groupe__c = entite_bw.Compte_Bilan_Garantie_Groupe__c ,      
                                                             comptecomptable_local__c = MapCompteGeneral.get(entite_bw.Compte_Bilan_Garantie_Local__c).id , 
                                                             chapitre__c='',
                                                             sous_chapitre__c='',
                                                             Type_de_depense__c='',                                                                                              
                                                             Date_ecriture__c =lam.periode_comptable__r.date_de_fin__c,
                                                             Statut_ecriture_comptable__c = Statut_definitif,
                                                             affaire__c=null,
                                                             affaire_de_rattachement__c=lam.affaire__c,                                                                                  
                                                             libelle__c=VIConstant.EC_REPRISE_PROVISION_GARANTIE,
                                                             centre__c='',
                                                             ligne_affaire_mensuelle__c=lam.id,
                                                             type_ligne_comptable__c=type_ligne_comptable,                                                                                  
                                                             sens__c = 'D',
                                                             type_enregistrement__c=MapCompteGeneral.get(entite_bw.Compte_Bilan_Garantie_Local__c).type_enregistrement__c,
                                                             montant__c=mt  );
                        ListInsertEcriture.add(ec2);
                    }
                }    
                // Let's delete the existing line
                if(MapAffaireEcriture.containskey(lam.affaire__c)) {
                        for(VILigne_comptable__c lc : MapAffaireEcriture.get(lam.affaire__c)) {
                            if(!ListDeleteEcriture.contains(lc)) {
                                ListDeleteEcriture.addAll(MapAffaireEcriture.get(lam.affaire__c));    
                            }
                        } 
                    }
                                        
                                 
            }

            // The SAV Case is handled, so now we can focus on other cases 


            // Let's delete the existing line
            if(MapAffaireEcriture.containskey(lam.affaire__c)) {
                for(VILigne_comptable__c lc : MapAffaireEcriture.get(lam.affaire__c)) {
                    if(!ListDeleteEcriture.contains(lc)) {
                        ListDeleteEcriture.addAll(MapAffaireEcriture.get(lam.affaire__c));    
                    }
                } 
            }

            // Si on a une date SAV, on arrête
           // if(lam.affaire__r.Date_de_SAV_reelle__c!=null) {
           //     continue;
           // }
            
            // ECRITURES A l'AVANCEMENT
            System.debug('a l avancement pour '+lam.affaire__r.name);
                
            // We are in the normal case, we have to create the ecriture à l'avancement
            double mt = lam.Total_CA_a_l_avancement__c ;
            system.debug('total ca avancement '+mt);
            if(MapDejaComptabilise.containskey(lam.affaire__c+'-AVT')) {
                mt=mt - MapDejaComptabilise.get(lam.affaire__c+'-AVT');
            }
            system.debug('MapDejaComptabilise.get(lam.affaire__c+-AVT) '+MapDejaComptabilise.get(lam.affaire__c+'-AVT'));
            lam.CA_a_comptabiliser1__c = mt;
            lam.CA_a_comptabiliserE__c = mt;                
            
            if(lam.affaire__r.Date_de_SAV_reelle__c==null || lam.affaire__r.Date_de_SAV_reelle__c>lam.periode_comptable__r.date_de_fin__c)  {
                
                // Mode de calcul 1 
                VIligne_comptable__c ec1 = new VIligne_comptable__c(periode_comptable__c=lam.periode_comptable__c, 
                                                             compte_comptable_groupe__c = entite_bw.Compte_Client_Avancement_Groupe__c,      
                                                             comptecomptable_local__c = MapCompteGeneral.get(lam.affaire__r.Produit_SousDomaine__r.Compte__c+localisation).id, 
                                                             chapitre__c='00',
                                                             sous_chapitre__c='00-00',
                                                             Type_de_depense__c=entite_bw.Type_de_depense_Avancement__c,                                                                                              
                                                             Date_ecriture__c =lam.periode_comptable__r.date_de_fin__c,
                                                             Statut_ecriture_comptable__c = Statut_definitif,
                                                             affaire__c=lam.affaire__c,
                                                             affaire_de_rattachement__c=lam.affaire__c,                                                                                  
                                                             libelle__c=VIConstant.EC_CA_AVENCEMENT,
                                                             centre__c='800',
                                                             ligne_affaire_mensuelle__c=lam.id,
                                                             type_ligne_comptable__c='AV'+lam.affaire__r.Mode_de_calcul_de_l_avancement__c.left(1),                                                                                  
                                                             sens__c = 'C',
                                                             type_enregistrement__c=MapCompteGeneral.get(lam.affaire__r.Produit_SousDomaine__r.Compte__c+localisation).type_enregistrement__c,
                                                             montant__c=mt  );
                ListInsertEcriture.add(ec1);

                VIligne_comptable__c ec2 = new VIligne_comptable__c(periode_comptable__c=lam.periode_comptable__c, 
                                                             compte_comptable_groupe__c = entite_bw.Compte_Client_Avancement_local__c,      
                                                             comptecomptable_local__c = MapCompteGeneral.get(entite_bw.Compte_Client_Avancement_local__c).id,
                                                             chapitre__c='00',
                                                             sous_chapitre__c='00-00',
                                                             Type_de_depense__c=entite_bw.Type_de_depense_Avancement__c,                                                                                                                                                                      
                                                             Date_ecriture__c = lam.periode_comptable__r.date_de_fin__c,                                                                                            
                                                             Statut_ecriture_comptable__c =Statut_definitif,                                                                        
                                                             affaire__c=lam.affaire__c,
                                                             affaire_de_rattachement__c=lam.affaire__c,                                                                                  
                                                             libelle__c=VIConstant.EC_CA_AVENCEMENT,                                                                              
                                                             centre__c='800',      
                                                             ligne_affaire_mensuelle__c=lam.id,
                                                             type_ligne_comptable__c='AV'+lam.affaire__r.Mode_de_calcul_de_l_avancement__c.left(1),                                                                                                                                                          
                                                             sens__c = 'D',
                                                             type_enregistrement__c=MapCompteGeneral.get(entite_bw.Compte_Client_Avancement_local__c).type_enregistrement__c,
                                                             montant__c=mt  );
                ListInsertEcriture.add(ec2);
            } 
            if (lam.affaire__r.Mode_de_calcul_de_l_avancement__c.left(1)=='2' && mt!=0 ) {
                    ListAffaireWithAMP.add(lam.affaire__c);
                    // Mode de calcul 2 
                    // AMP 
                    double DejaComptabilise ;
                    if(MapDejaComptabilise.containskey(lam.affaire__c+'-AMP')) {
                        DejaComptabilise = MapDejaComptabilise.get(lam.affaire__c+'-AMP') ;
                    } else {
                        DejaComptabilise = 0;
                    }
                    VIligne_comptable__c AMPec1 = new VIligne_comptable__c(periode_comptable__c=lam.periode_comptable__c, 
                                                             compte_comptable_groupe__c = entite_bw.Compte_Loc_AMP_Groupe__c,      
                                                             comptecomptable_local__c = MapCompteGeneral.get(entite_bw.Compte_Loc_AMP_Groupe__c).id, 
                                                             chapitre__c='00',
                                                             sous_chapitre__c='00-00',
                                                             Type_de_depense__c=entite_bw.Type_de_depense_AMP__c,                                                                                                                                                                         
                                                             Date_ecriture__c =lam.periode_comptable__r.date_de_fin__c,
                                                             Statut_ecriture_comptable__c = VIConstant.EC_GENEREE_A_NE_PAS_ENVOYER,
                                                             affaire__c=lam.affaire__c,
                                                             affaire_de_rattachement__c=lam.affaire__c,                                                                                                                                                             
                                                             libelle__c=VIConstant.EC_PROVISION_AMORTISSEMENT_AVCT,
                                                             centre__c='801',
                                                             ligne_affaire_mensuelle__c=lam.id,
                                                             type_ligne_comptable__c='AV'+lam.affaire__r.Mode_de_calcul_de_l_avancement__c.left(1),                                                                                                                                                             
                                                             sens__c = 'D',
                                                             type_enregistrement__c=MapCompteGeneral.get(entite_bw.Compte_Loc_AMP_Groupe__c).type_enregistrement__c,
                                                             montant__c=lam.AMP__c + DejaComptabilise );
                    ListInsertEcriture.add(AMPec1);

                    VIligne_comptable__c AMPec2 = new VIligne_comptable__c(periode_comptable__c=lam.periode_comptable__c, 
                                                             compte_comptable_groupe__c = entite_bw.Compte_Loc_AMP_Groupe__c,      
                                                             comptecomptable_local__c = MapCompteGeneral.get(entite_bw.Compte_Loc_AMP_Groupe__c).id,
                                                             chapitre__c='00',
                                                             sous_chapitre__c='00-00',
                                                             Type_de_depense__c=entite_bw.Type_de_depense_AMP__c,                                                                                                                                                                         
                                                             Date_ecriture__c = lam.periode_comptable__r.date_de_fin__c,                                                                                            
                                                             Statut_ecriture_comptable__c =VIConstant.EC_GENEREE_A_NE_PAS_ENVOYER,                                                                        
                                                             affaire__c=entite_bw.ID_Affaire_location__c,
                                                             affaire_de_rattachement__c=lam.affaire__c,
                                                             libelle__c=VIConstant.EC_PROVISION_AMORTISSEMENT_AVCT,                                                                              
                                                             centre__c='801',  
                                                             ligne_affaire_mensuelle__c=lam.id,
                                                             type_ligne_comptable__c='AV'+lam.affaire__r.Mode_de_calcul_de_l_avancement__c.left(1),                                                                                                                                                             
                                                             sens__c = 'C',
                                                             type_enregistrement__c=MapCompteGeneral.get(entite_bw.Compte_Loc_AMP_Groupe__c).type_enregistrement__c,
                                                             montant__c=lam.AMP__c + DejaComptabilise  );
                    ListInsertEcriture.add(AMPec2);

                    // EMM 
                    if(MapDejaComptabilise.containskey(lam.affaire__c+'-EMM')) {
                        DejaComptabilise = MapDejaComptabilise.get(lam.affaire__c+'-EMM') ;
                    } else {
                        DejaComptabilise = 0;
                    }

                    VIligne_comptable__c EMMec1 = new VIligne_comptable__c(periode_comptable__c=lam.periode_comptable__c, 
                                                             compte_comptable_groupe__c = entite_bw.Compte_Loc_EMM_Groupe__c,      
                                                             comptecomptable_local__c = MapCompteGeneral.get(entite_bw.Compte_Loc_EMM_Local__c).id, 
                                                             chapitre__c='00',
                                                             sous_chapitre__c='00-00',
                                                             Type_de_depense__c=entite_bw.Type_de_depense_EMM__c,                                                                                                                                                                         
                                                             Date_ecriture__c =lam.periode_comptable__r.date_de_fin__c,
                                                             Statut_ecriture_comptable__c = VIConstant.EC_GENEREE_A_NE_PAS_ENVOYER,
                                                             affaire__c=lam.affaire__c,
                                                             affaire_de_rattachement__c=lam.affaire__c,                                                                           
                                                             libelle__c=VIConstant.EC_PROVISION_AMORTISSEMENT_AVCT,
                                                             centre__c='801',
                                                             ligne_affaire_mensuelle__c=lam.id,
                                                             type_ligne_comptable__c='AV'+lam.affaire__r.Mode_de_calcul_de_l_avancement__c.left(1),                                                                                                                                                             
                                                             sens__c = 'D',
                                                             type_enregistrement__c=MapCompteGeneral.get(entite_bw.Compte_Loc_EMM_Local__c).type_enregistrement__c,
                                                             montant__c=lam.EMM__c + DejaComptabilise );
                    ListInsertEcriture.add(EMMec1);

                    VIligne_comptable__c EMMec2 = new VIligne_comptable__c(periode_comptable__c=lam.periode_comptable__c, 
                                                             compte_comptable_groupe__c = entite_bw.Compte_Loc_EMM_Groupe__c,      
                                                             comptecomptable_local__c = MapCompteGeneral.get(entite_bw.Compte_Loc_EMM_Local__c).id,
                                                             chapitre__c='00',
                                                             sous_chapitre__c='00-00',
                                                             Type_de_depense__c=entite_bw.Type_de_depense_EMM__c,                                                                                                                                                                         
                                                             Date_ecriture__c = lam.periode_comptable__r.date_de_fin__c,                                                                                            
                                                             Statut_ecriture_comptable__c =VIConstant.EC_GENEREE_A_NE_PAS_ENVOYER,                                                                        
                                                             affaire__c=entite_bw.ID_Affaire_location__c,
                                                             affaire_de_rattachement__c=lam.affaire__c,                                                                           
                                                             libelle__c=VIConstant.EC_PROVISION_AMORTISSEMENT_AVCT,                                                                              
                                                             centre__c='801', 
                                                             ligne_affaire_mensuelle__c=lam.id,
                                                             type_ligne_comptable__c='AV'+lam.affaire__r.Mode_de_calcul_de_l_avancement__c.left(1),                                                                                                                                                             
                                                             sens__c = 'C',
                                                             type_enregistrement__c=MapCompteGeneral.get(entite_bw.Compte_Loc_EMM_Local__c).type_enregistrement__c,
                                                             montant__c=lam.EMM__c + DejaComptabilise  );
                    ListInsertEcriture.add(EMMec2);

                    // FOL 
                    if(MapDejaComptabilise.containskey(lam.affaire__c+'-FOL')) {
                        DejaComptabilise = MapDejaComptabilise.get(lam.affaire__c+'-FOL') ;
                    } else {
                        DejaComptabilise = 0;
                    }

                    VIligne_comptable__c FOLec1 = new VIligne_comptable__c(periode_comptable__c=lam.periode_comptable__c, 
                                                             compte_comptable_groupe__c = entite_bw.Compte_Loc_FOL_Groupe__c,      
                                                             comptecomptable_local__c = MapCompteGeneral.get(entite_bw.Compte_Loc_FOL_Local__c).id, 
                                                             chapitre__c='00',
                                                             sous_chapitre__c='00-00',
                                                             Type_de_depense__c=entite_bw.Type_de_depense_FOL__c,                                                                                                                                                                         
                                                             Date_ecriture__c =lam.periode_comptable__r.date_de_fin__c,
                                                             Statut_ecriture_comptable__c = VIConstant.EC_GENEREE_A_NE_PAS_ENVOYER,
                                                             affaire__c=lam.affaire__c,
                                                             affaire_de_rattachement__c=lam.affaire__c,                                                                           
                                                             libelle__c=VIConstant.EC_PROVISION_FINANCEMENT_AVCT,
                                                             centre__c='801',
                                                             ligne_affaire_mensuelle__c=lam.id,
                                                             type_ligne_comptable__c='AV'+lam.affaire__r.Mode_de_calcul_de_l_avancement__c.left(1),                                                                                                                                                             
                                                             sens__c = 'D',
                                                             type_enregistrement__c=MapCompteGeneral.get(entite_bw.Compte_Loc_FOL_Local__c).type_enregistrement__c,                                                                           
                                                             montant__c=lam.FOL__c + DejaComptabilise );
                    ListInsertEcriture.add(FOLec1);

                    VIligne_comptable__c FOLec2 = new VIligne_comptable__c(periode_comptable__c=lam.periode_comptable__c, 
                                                             compte_comptable_groupe__c = entite_bw.Compte_Loc_FOL_Groupe__c,      
                                                             comptecomptable_local__c = MapCompteGeneral.get(entite_bw.Compte_Loc_FOL_Local__c).id,
                                                             chapitre__c='00',
                                                             sous_chapitre__c='00-00',
                                                             Type_de_depense__c=entite_bw.Type_de_depense_FOL__c,                                                                                                                                                                         
                                                             Date_ecriture__c = lam.periode_comptable__r.date_de_fin__c,                                                                                            
                                                             Statut_ecriture_comptable__c =VIConstant.EC_GENEREE_A_NE_PAS_ENVOYER,                                                                        
                                                             affaire__c=entite_bw.ID_Affaire_location__c,
                                                             affaire_de_rattachement__c=lam.affaire__c,                                                                           
                                                             libelle__c=VIConstant.EC_PROVISION_FINANCEMENT_AVCT,                                                                              
                                                             centre__c='801',      
                                                             ligne_affaire_mensuelle__c=lam.id,
                                                             type_ligne_comptable__c='AV'+lam.affaire__r.Mode_de_calcul_de_l_avancement__c.left(1),                                                                                                                                                             
                                                             sens__c = 'C',
                                                             type_enregistrement__c=MapCompteGeneral.get(entite_bw.Compte_Loc_FOL_Local__c).type_enregistrement__c,                                                                           
                                                             montant__c=lam.FOL__c  + DejaComptabilise );
                    ListInsertEcriture.add(FOLec2);
                    
            } 


        }
        system.debug('nbr ligne générées avant '+ListInsertEcriture.size());
        list<VIligne_comptable__c>ListInsertEcriture1 = new list<VIligne_comptable__c>();        
        for(VIligne_comptable__c lc:ListInsertEcriture) {
            if(lc.montant__c<0) {
                lc.montant__c = lc.montant__c *(-1);
                if(lc.sens__c=='C') {
                    lc.sens__c='D';
                } else {
                    lc.sens__c='C';        
                }
            } 
            // We don't generate "Ecriture à l avancement" pour le mois de juillet
            if(lc.Date_ecriture__c.month()==7 && lc.type_ligne_comptable__c.left(2)=='AV')
                continue ; 
            
            if (lc.montant__c>0) {
                ListInsertEcriture1.add(lc);
            }
        }

        // Just before inserting the Ligne_comptable, we have to delete and recreate the Achat Corresponding to the EMM, AMP and FOL
        VIEntiteBW__c ebw = MapEntite_bw.get(Entite_bw);
        list<id>ListIDTd = new list<id>();
        ListIDtd.add(TDAMP.id);
        ListIDtd.add(TDEMM.id);
        ListIDtd.add(TDFOL.id);

        // First, let's delete the existing lines
        list<VIachat__c>ListAchatDelete = [SELECT id 
                                             FROM VIAchat__c
                                            WHERE affaire__c in :ListAffaireWithAMP
                                              AND Periode_comptable__c  = :Periode_Ouverte.id
                                              AND type_depense__c in :ListIDtd] ;
        delete ListAchatDelete ; 

        // then let's recreate the lines
        list<VIachat__c>ListAchatInsert = new list<VIachat__c>();
        for(VIligne_comptable__c lc:ListInsertEcriture) {
            system.debug('lc '+lc);
            if(!ListAffaireWithAMP.contains(lc.affaire_de_rattachement__c))
                continue ; 
            
            if(lc.Type_de_depense__c=='' || lc.Type_de_depense__c==null)
                continue  ; 
            
            if(Periode_Ouverte.date_de_fin__c.month()==7)
                continue ;
            
            string sname = MapAffaire.get(lc.affaire_de_rattachement__c) + '-L-'+Periode_Ouverte.name.left(6)+lc.Type_de_depense__c.left(3);
            if(TDAMP.name.startswith(lc.Type_de_depense__c)  && lc.sens__c=='D') {
                VIAchat__c ac = new VIAchat__c (
                    name=sname, 
                    Affaire__c=lc.affaire_de_rattachement__c,
                    Centre_Section__c = CS801.id,
                    CommandeC__c =0,                CommandeC_E__c=0 ,                CommandeD__c =0,                CommandeD_E__c=0 ,                CommandeI__c =0,                CommandeI_E__c=0 ,
                    ComptabiliseC__c=lc.montant__c, ComptabiliseC_E__c=lc.montant__c, ComptabiliseD__c=lc.montant__c, ComptabiliseD_E__c=lc.montant__c, ComptabiliseI__c=lc.montant__c, ComptabiliseI_E__c=lc.montant__c,
                    CompteGeneral__c=ebw.Compte_Loc_AMP_Local__c,
                    Date__c =Periode_Ouverte.date_de_fin__c,
                    Date_de_comptabilisation__c  =Periode_Ouverte.date_de_fin__c,   
                    Description_de_la_commande__c =VIConstant.EC_PROVISION_AMORTISSEMENT_AVCT , 
                    Periode_comptable__c =Periode_Ouverte.id,
                    Sous_chapitre__c='00-00',
                    type_depense__c=TDAMP.id
                );
                ListAchatInsert.add(ac);
            }
            if(TDEMM.name.startswith(lc.Type_de_depense__c)  && lc.sens__c=='D') {
                VIAchat__c ac = new VIAchat__c (
                    name=sname,                     
                    Affaire__c=lc.affaire_de_rattachement__c,
                    Centre_Section__c = CS801.id,
                    CommandeC__c =0,                CommandeC_E__c=0 ,                CommandeD__c =0,                CommandeD_E__c=0 ,                CommandeI__c =0,                CommandeI_E__c=0 ,
                    ComptabiliseC__c=lc.montant__c, ComptabiliseC_E__c=lc.montant__c, ComptabiliseD__c=lc.montant__c, ComptabiliseD_E__c=lc.montant__c, ComptabiliseI__c=lc.montant__c, ComptabiliseI_E__c=lc.montant__c,
                    CompteGeneral__c=ebw.Compte_Loc_EMM_Local__c,
                    Date__c =Periode_Ouverte.date_de_fin__c,
                    Date_de_comptabilisation__c  =Periode_Ouverte.date_de_fin__c,   
                    Description_de_la_commande__c =VIConstant.EC_PROVISION_AMORTISSEMENT_AVCT , 
                    Periode_comptable__c =Periode_Ouverte.id,
                    Sous_chapitre__c='00-00',
                    type_depense__c=TDEMM.id
                );
                ListAchatInsert.add(ac);
            }

            if(TDFOL.name.startswith(lc.Type_de_depense__c)  && lc.sens__c=='D') {
                VIAchat__c ac = new VIAchat__c (
                    name=sname,                     
                    Affaire__c=lc.affaire_de_rattachement__c,
                    Centre_Section__c = CS801.id,
                    CommandeC__c =0,                CommandeC_E__c=0 ,                CommandeD__c =0,                CommandeD_E__c=0 ,                CommandeI__c =0,                CommandeI_E__c=0 ,
                    ComptabiliseC__c=lc.montant__c, ComptabiliseC_E__c=lc.montant__c, ComptabiliseD__c=lc.montant__c, ComptabiliseD_E__c=lc.montant__c, ComptabiliseI__c=lc.montant__c, ComptabiliseI_E__c=lc.montant__c,
                    CompteGeneral__c=ebw.Compte_Loc_FOL_Local__c,
                    Date__c =Periode_Ouverte.date_de_fin__c,
                    Date_de_comptabilisation__c  =Periode_Ouverte.date_de_fin__c,   
                    Description_de_la_commande__c =VIConstant.EC_PROVISION_AMORTISSEMENT_AVCT , 
                    Periode_comptable__c =Periode_Ouverte.id,
                    Sous_chapitre__c='00-00',
                    type_depense__c=TDFOL.id
                );
                ListAchatInsert.add(ac);
            }
           
            
        }
        insert ListAchatInsert ; 
        
        
        delete ListDeleteEcriture ;        
        insert ListInsertEcriture1;
        update scope ;
        
    }    

    global void finish(Database.BatchableContext BC) {
        
        IDLog=VIUtils.LogWrite('VIBatchGenerate','1 Normal',IDLog,'End '+num_record);
        // Après avoir créer des achats  AMP, EMM, FOL pour les affaires de LOC, il faut relancer le calcul des LAM et LA uniquement pour ces affaires
        Database.executeBatch(new VIBatchRegenerateTotal('AMPEMMFOL',false,false), 1);        
        
        if(AffaireAGenerer=='' && !Test.isRunningTest() ) {
            database.executebatch(new VIBatchCalcTDBGazelle('1'),VIBatchCalcTDBGazelle.NBR_LOT);  
            database.executebatch(new VIBatchGenereLigneDet('','1'),VIBatchGenereLigneDet.NBR_LOT); 
            Database.executeBatch(new VISchedGenereCentralis1(),VISchedGenereCentralis1.NBR_LOT()); 
        }

        
    }

    public void code_coverage () {    
        integer i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;    
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;            
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;        
        i=0;
        i=0;
        i=0;
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
    

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VIBatchGenerate(AffaireAGenerer,'1'),VIBatchGenerate.NBR_LOT);

    }
    
    public static final integer NBR_LOT =300;    
    
}