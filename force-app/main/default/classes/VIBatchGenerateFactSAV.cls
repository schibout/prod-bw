//
//   This batch generate the ecriture_comptable__C for invoice on Affaire closed
//  
//  
// 
/*  for running by hand : 
 VIBatchGenerateFactSAV v = new VIBatchGenerateFactSAV('','1' );
 v.execute(null);

*  for running every hour at xx:16
     VIBatchGenerateFactSAV m = new VIBatchGenerateFactSAV();
     String sch = '0 16 * * * ?';
     String jobID = system.schedule('VIBatchGenerateFactSAV', sch, m);
*/
global class VIBatchGenerateFactSAV implements Schedulable,Database.Batchable<sObject>, Database.Stateful  {

    Global double num_record = 0; 
    Global String IDLog ='';  
    Global String Statut_definitif ='';  
    Global Map<string,VIperiode__c>MapPeriode = new Map<string,VIperiode__c>();    
    Global Map<string,VIEntiteBW__c>Mapentite_bw = new Map<string,VIEntiteBW__c>();  
    Global Map<String, VICompte_general__c >MapCompteGeneral = new Map<String, VICompte_general__c>();
    Global Map<string, VIPays__c >MapPays = new Map<String, VIPays__c>();
    Global List<VILigne_d_affaire_mensuelle__c>ListLam = new List<VILigne_d_affaire_mensuelle__c>();       
    private boolean definitif ; 
    private string AffaireAGenerer; 
    private string Entite_bw ;
    
     public VIBatchGenerateFactSAV(String Param1,String Param2 ) {
        AffaireAGenerer = Param1;        
        Entite_bw = Param2;                
    }


    global Iterable<sObject> start(Database.BatchableContext BC) {

        
        for(VIPeriode__c per: [SELECT id,name, entite_bw__c, date_de_debut__c, date_de_fin__c 
                                 FROM VIPeriode__c
                               WHERE Statut__c=:VIConstant.PERIODE_OUVERTE
                                 AND Entite_bw__c=:Entite_bw]) {
            MapPeriode.put(per.entite_bw__c, per);
        }

        for(VICompte_general__c cg: [SELECT id,name, type_enregistrement__c
                                       FROM VICompte_general__c]) {
            MapCompteGeneral.put(cg.name, cg);
        }

        for(VIPays__c pays : [select name, UE__c from VIPays__C]) {
            MapPays.put(pays.name,pays);
        }

        for(VIEntiteBW__c Ebw: [SELECT id,name, ID_Affaire_location__c, Entite_bw__c,
                                    Compte_Client_Avancement_Local__c,  Compte_Client_Avancement_Groupe__c,
                                    Type_de_depense_Avancement__c, 
                                    Compte_Bilan_Garantie_Local__c,     Compte_Bilan_Garantie_Groupe__c,                             
                                    Compte_Charge_Garantie_Local__c,    Compte_Charge_Garantie_Groupe__c,
                                    Compte_Charge_Reprise_Garantie_Local__c , Compte_Charge_Reprise_Garantie_Groupe__c,
                                    Type_de_depense_garantie__c,
                                    Compte_loc_AMP_local__c,            Compte_loc_AMP_Groupe__c,
                                    Type_de_depense_AMP__c,
                                    Compte_loc_EMM_local__c,            Compte_loc_EMM_Groupe__c,
                                    Type_de_depense_EMM__c,                             
                                    Compte_loc_FOL_local__c,            Compte_loc_FOL_Groupe__c,
                                    Type_de_depense_FOL__c                             
                               FROM VIentiteBW__c 
                               WHERE Entite_bw__c=:Entite_bw]) {
            Mapentite_bw.put(Ebw.Entite_bw__c, Ebw);                                   
        }

        IDLog=VIUtils.LogWrite('VIBatchGenerateFactSAV','4 Running','','Start ');
        num_record = 0 ;

        string sAffaireAGenerer = AffaireAGenerer+'%';
        
        string query = 'SELECT id, name, affaire__c, affaire__r.name,affaire__r.entite_bw__c, compte__r.name, bu__c,sous_domaine__c,  ';
        query = query+'        affaire__r.Produit_SousDomaine__r.Compte__c, affaire__r.compte__r.billingCountryCode, ';
        query = query+'        date__c, date_de_comptabilisation__c, montant_ht__c, Facture_SAV_comptabilisee__c ';                
        query = query+'   FROM VIFacture__c ';
        query = query+'  WHERE Facture_SAV_traitee__c =true  ';
        if(!Test.isRunningTest() ) {
             query = query+'    AND Facture_sur_Affaire_SAV__c=true  '; 
             query = query+'    AND Periode_comptable__r.Statut__c =\''+VIConstant.PERIODE_OUVERTE+'\'';        
             query = query+'    AND Facture_SAV_comptabilisee__c =false  ';
        }
        query = query+'    AND affaire__r.entite_bw__c = \''+Entite_bw+'\'  ';

        query = query+'    AND affaire__r.name Like \''+sAffaireAGenerer+'\'  ';
        query = query+'   Order by affaire__r.name desc  ';        
        system.debug(query);
        return Database.getQueryLocator(query);

    }

    global void execute(Database.BatchableContext BC, List<VIfacture__c> scope) {

        list<VIligne_comptable__c>ListInsertEcriture = new list<VIligne_comptable__c>() ;
        list<VIFacture__c>ListUpsertFacture = new list<VIFacture__c>() ;
        Map<string,id>MapLAM = new Map<string,id>();
        list<id>ListIDAffaire = new list<id>();
        for(VIfacture__c fac:scope) {
            ListIDAffaire.add(fac.affaire__c) ;
        }
        for(VILigne_d_affaire_mensuelle__c lam : [SELECT id ,affaire__c
                                                    FROM VILigne_d_affaire_mensuelle__c 
                                                   WHERE Affaire__c in :ListIDAffaire
                                                     AND Periode_comptable_statut__c =:VIConstant.PERIODE_OUVERTE]){
            MapLam.put(lam.affaire__c, lam.id);
        }

        for(VIFacture__c fac:scope) {
            VIPeriode__c per = mapPeriode.get(fac.affaire__r.entite_bw__c) ;
            VIEntitebw__c entite_bw = Mapentite_bw.get(fac.affaire__r.entite_bw__c) ;
            
            string localisation='030';
            if(MapPays.containskey(fac.affaire__r.compte__r.billingCountryCode)) {
                if(fac.affaire__r.compte__r.billingCountryCode=='FR'){
                    localisation='000';
                } else {
                    if(MapPays.get(fac.affaire__r.compte__r.billingCountryCode).UE__c) {
                        localisation='020';
                   }
                }
            }            
            
            
                    VIligne_comptable__c ecFin1 = new VIligne_comptable__c(periode_comptable__c=per.id, 
                                                                 compte_comptable_groupe__c = entite_bw.Compte_Client_Avancement_Groupe__c,      
                                                                 comptecomptable_local__c = MapCompteGeneral.get(entite_bw.Compte_Client_Avancement_local__c).id, 
                                                                 chapitre__c='00',
                                                                 sous_chapitre__c='00-00',
                                                                 Type_de_depense__c=entite_bw.Type_de_depense_Avancement__c,                                                                           
                                                                 Date_ecriture__c =(fac.date__c==null ? fac.date_de_comptabilisation__c : fac.date__c),              
                                                                 Statut_ecriture_comptable__c = VIConstant.EC_A_PRENDRE,                                                                           
                                                                 affaire__c=fac.affaire__c,
                                                                 affaire_de_rattachement__c=fac.affaire__c,          
                                                                 libelle__c=VIConstant.EC_CA_SUR_AFFAIRE_EN_SAV,                                                                                 
                                                                 centre__c='800',
                                                                 ligne_affaire_mensuelle__c=MapLam.get(fac.affaire__c),
                                                                 type_ligne_comptable__c='FSA',          
                                                                 sens__c = 'D',
                                                                 montant__c=fac.montant_ht__c,
                                                                 type_enregistrement__c=MapCompteGeneral.get(entite_bw.Compte_Client_Avancement_local__c).type_enregistrement__c);
                    ListInsertEcriture.add(ecFin1);

                    VIligne_comptable__c ecFin2 = new VIligne_comptable__c(periode_comptable__c=per.id, 
                                                                 compte_comptable_groupe__c = fac.affaire__r.Produit_SousDomaine__r.Compte__c+localisation,      
                                                                 comptecomptable_local__c =MapCompteGeneral.get(fac.affaire__r.Produit_SousDomaine__r.Compte__c+localisation).id , 
                                                                 chapitre__c='00',
                                                                 sous_chapitre__c='00-00',
                                                                 Type_de_depense__c=entite_bw.Type_de_depense_Avancement__c,                                                                                                                                                      
                                                                 Date_ecriture__c =(fac.date__c==null ? fac.date_de_comptabilisation__c : fac.date__c),              
                                                                 Statut_ecriture_comptable__c = VIConstant.EC_A_PRENDRE,                                                                                                                                                      
                                                                 affaire__c=fac.affaire__c,
                                                                 affaire_de_rattachement__c=fac.affaire__c,                                                                                     
                                                                 libelle__c=VIConstant.EC_CA_SUR_AFFAIRE_EN_SAV,                                                                                 
                                                                 centre__c='800',
                                                                 ligne_affaire_mensuelle__c=MapLam.get(fac.affaire__c),
                                                                 type_ligne_comptable__c='FSA',          
                                                                 sens__c = 'C',
                                                                 montant__c=fac.montant_ht__c,
                                                                 type_enregistrement__c=MapCompteGeneral.get(fac.affaire__r.Produit_SousDomaine__r.Compte__c+localisation).type_enregistrement__c  );
                    ListInsertEcriture.add(ecFin2);            
            fac.Facture_SAV_comptabilisee__c=true;
        }

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
            if (lc.montant__c>0) {
                ListInsertEcriture1.add(lc);
            }
        }

        if(!Test.isRunningTest())
            insert ListInsertEcriture1;

        
        update scope ; 
        
    }   

    global void finish(Database.BatchableContext BC) {
        
        IDLog=VIUtils.LogWrite('VIBatchGenerateFactSAV','1 Normal',IDLog,'End '+num_record);


    }
    

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VIBatchGenerateFactSAV(AffaireAGenerer, Entite_bw),VIBatchGenerateFactSAV.NBR_LOT);

    }

    public static final integer NBR_LOT =200;    
    
}