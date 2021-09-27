public class VIEtatMensuelController {

    public String Valeur{get;set;}
    public String CurrencyType{get;set;}
    public VILigne_d_affaire_mensuelle__c lam {get;set;}  
    public string Total_CA_a_l_avancement_converti {get;set;}  
    public string SortOrder {get;set;}
    public string SortOrderPrevious {get;set;}
    public string sens {get; set;}
    public string Langage {get; set;}
    public Map<string,string> MapTypeDeDepense {get; set;}
    public Map<string,string> MapCentre {get; set;}
    public Map<string, VILigne_d_affaire_mensuelle__c>MapLam {get; set;}
    public VIAffaire__c aff {get; set;}
    public boolean IsControleurGestion {get; set;}
    public boolean IsChefDeProjet {get; set;}

    public boolean ValSav {get; set;}
    
    public VItype_de_depense__c tdMO  {get; set;}
    public VItype_de_depense__c tdGAR {get; set;}
    public VItype_de_depense__c tdEMM {get; set;}
    public VItype_de_depense__c tdAMP {get; set;}
    public VItype_de_depense__c tdFOL {get; set;}
    public VICentre_section__c CS801 {get; set;}
    public Map<string,VIperiode__c>MapEntite_bwPeriode {get; set;}    
    
    
    public id LigneMensuelleID {get;set;}
    public id affaireID ;
    
    public List<Ligne> ListLigne { get; set; }
    public Ligne LigneTotal { get; set; }    

    public CurrencyType ListCurrency { get; set; }
   
    public boolean Etat_affaire {get;set;}
    public id idPrecedent {get;set;}
    public id idSuivant {get;set;}
    
    private ApexPages.StandardController stdCtrl;
    
    map<id,VILigne_affaire__c>MapLA = new map<id,VILigne_affaire__c>();

    Public Total PiedTotal {get;set;}


    Public Class Ligne{
        public string id  {get;set;}
        public string type  {get;set;}
        public string centre_section  {get;set;}
        public string centre_section_id  {get;set;}
        public string Type_Depense  {get;set;}  
        public string Type_Depense_id  {get;set;}                
        public decimal Devis_Heure  {get;set;}  
        public decimal Devis_Montant  {get;set;} 
        public string Devis_Montant_conv  {get;set;}         
        public decimal Engage_brut_arrete_Heure  {get;set;}  
        public decimal Engage_brut_arrete_Montant  {get;set;}                
        public string Engage_brut_arrete_Montant_conv  {get;set;}                        
        public decimal Dont_comptabilise {get;set;}
        public string Dont_comptabilise_conv {get;set;}                        
        public decimal Ecart_C_A_F_Heure  {get;set;}  
        public decimal Ecart_C_A_F_Montant  {get;set;}                
        public string Ecart_C_A_F_Montant_conv  {get;set;}                
        public decimal Cout_terminaison_Heure  {get;set;}  
        public decimal Cout_terminaison_Montant  {get;set;}                
        public string Cout_terminaison_Montant_conv  {get;set;}                        
        public decimal Ecart_RAD_Heure  {get;set;}  
        public decimal Ecart_RAD_Montant  {get;set;}     
        public string Ecart_RAD_Montant_conv  {get;set;}     
        

        public Ligne(string c0, string ct,  string c1,string c1a, string c2,string c2a, decimal c3, decimal c4, decimal c5, decimal c6, decimal c7, decimal c8, decimal c9, decimal c10, decimal c11, decimal c12, decimal c13) {
            id = c0 ;
            type = ct ;
            centre_section = c1 ;
            centre_section_id = c1a ;            
            Type_Depense =c2;
            Type_Depense_id = c2a ;            
            Devis_Heure = c3;
            Devis_Montant = c4 ; 
            Devis_Montant_conv = VIUtils.conv_number_thousand(c4,0) ;             
            Engage_brut_arrete_Heure = c5 ; 
            Engage_brut_arrete_Montant = c6 ; 
            Engage_brut_arrete_Montant_conv = VIUtils.conv_number_thousand(c6,0) ;                         
            Dont_comptabilise = c7 ; 
            Dont_comptabilise_conv = VIUtils.conv_number_thousand(c7,0) ;                         
            Ecart_C_A_F_Heure = c8.setscale(0) ; 
            Ecart_C_A_F_Montant = c9.setscale(0) ; 
            Ecart_C_A_F_Montant_conv = VIUtils.conv_number_thousand(c9,0) ; 
            Cout_terminaison_Heure = c10; 
            Cout_terminaison_Montant = c11; 
            Cout_terminaison_Montant_conv = VIUtils.conv_number_thousand(c11,0) ; 
            Ecart_RAD_Heure = c12 ; 
            Ecart_RAD_Montant = c13 ;  
            Ecart_RAD_Montant_conv = VIUtils.conv_number_thousand(c13,0) ; 
        }
    }
    Public Class Total {
        public decimal PVA_T  {get;set;}  
        public string PVA_T_conv  {get;set;}  
        public decimal PVA_M  {get;set;}  
        public string PVA_M_conv  {get;set;}  
        public decimal PVA_P  {get;set;}  
        
        public decimal PVF_T  {get;set;}  
        public string PVF_T_conv  {get;set;}          
        public decimal PVF_M  {get;set;}  
        public string PVF_M_conv  {get;set;}          
        public decimal PVF_P  {get;set;}  
        
        public decimal PVE_T  {get;set;}  
        public string PVE_T_conv  {get;set;}  

        public decimal ECA_T  {get;set;}  
        public string ECA_T_conv  {get;set;}  
        public decimal ECA_M  {get;set;}  
        public string ECA_M_conv  {get;set;}          
        public decimal ECA_P  {get;set;}  

        public decimal PVT_T  {get;set;}  
        public string PVT_T_conv  {get;set;}          
        public decimal PVT_M  {get;set;}  
        public string PVT_M_conv  {get;set;}          
        public decimal PVT_P  {get;set;}  

        public decimal ERAD_T  {get;set;}  
        public string ERAD_T_conv  {get;set;}          
        public decimal ERAD_M  {get;set;}  
        public string ERAD_M_conv  {get;set;}          
        public decimal ERAD_P  {get;set;}  
        
        public Total(decimal c0,decimal c1,decimal c2,decimal c3, decimal c4, decimal c5, decimal c6, decimal c7, decimal c8, decimal c9, decimal c10, decimal c11, decimal c12, decimal c13, decimal c14, decimal c15) {
            PVA_T=c0;
            PVA_T_conv=VIUtils.conv_number_thousand(c0,0);            
            PVA_M=c1;            
            PVA_M_conv=VIUtils.conv_number_thousand(c1,0);                        
            PVA_P=c2; 
            
            PVF_T=c3;
            PVF_T_conv=VIUtils.conv_number_thousand(c3,0);            
            PVF_M=c4;            
            PVF_M_conv=VIUtils.conv_number_thousand(c4,0);                        
            PVF_P=c5;            
            
            PVE_T=c6;    
            PVE_T_conv=VIUtils.conv_number_thousand(c6,0);                
            
            ECA_T=c7;
            ECA_T_conv=VIUtils.conv_number_thousand(c7,0);            
            ECA_M=c8;
            ECA_M_conv=VIUtils.conv_number_thousand(c8,0);            
            ECA_P=c9;            
            
            PVT_T=c10;
            PVT_T_conv=VIUtils.conv_number_thousand(c10,0);            
            PVT_M=c11;            
            PVT_M_conv=VIUtils.conv_number_thousand(c11,0);                        
            PVT_P=c12; 
            
            ERAD_T=c13;
            ERAD_T_conv=VIUtils.conv_number_thousand(c13,0);            
            ERAD_M=c14;
            ERAD_M_conv=VIUtils.conv_number_thousand(c14,0);            
            ERAD_P=c15;   
        }
    }

    

    public  VIEtatMensuelController(ApexPages.StandardController std)
    {
        system.debug('step 10');
        stdCtrl=std;
        affaireID= std.getId();
        
        ValSav = false ; 
        
        LigneMensuelleID=null;
           
        Valeur = 'Debours';

        idPrecedent=null;
        idSuivant=null;                 
        SortOrder = 'Type_de_ligne_d_affaire__c ASC, type_depense__r.name, Centre_Section__r.cle_pour_le_tri__c' ;     
        Sens='ASC';

        Langage= UserInfo.getLanguage() ;
        if(Langage!='fr') {
            MapTypeDeDepense = new Map<string, string>();
            MapCentre = new Map<string, string>();            
            for(VIType_de_depense__c td : [SELECT ID, name, 
                                                  lib_en__c, lib_pl__c
                                             FROM VIType_de_depense__c]) {
                string lib ; 
                if(Langage=='pl') {
                    lib=td.lib_pl__c ;                                     
                } else {
                    lib=td.lib_en__c ;                                     
                }
                MapTypeDeDepense.put(td.name.left(3),lib);
            }
            for(VICentre_Section__c cs: [SELECT ID, name, 
                                                  lib_en__c, lib_pl__c
                                             FROM VICentre_Section__c]) {
                string lib ; 
                if(Langage=='pl') {
                    lib=cs.lib_pl__c ;                                     
                } else {
                    lib=cs.lib_en__c ;                                     
                }
                MapCentre.put(cs.name.left(3),lib);
            }
        }

        aff=[select date_de_derniere_revue__c, Date_de_SAV_previsionnelle__c ,Date_de_SAV_reelle__c ,
                    Date_de_livraison__c ,  Date_ouverture_affaire__c, name,
                    entite_bw__c, Etat_de_l_affaire__c , Chef_de_projet__c ,Date_de_fin_de_garantie__c
               FROM VIAffaire__c
              WHERE id=:affaireID];

        list<PermissionSetAssignment>ListPermissionSetAssignment = [SELECT Id FROM PermissionSetAssignment WHERE Assignee.id= :UserInfo.getUserId() and PermissionSet.Name='VI_Controle_de_gestion'];
        if(ListPermissionSetAssignment.size()>0) {
            IsControleurGestion=true;
        } else {
            IsControleurGestion=false;            
        }
        if(aff.Chef_de_projet__c==UserInfo.getUserId()) {
            IsChefDeProjet=true;
        } else {
            IsChefDeProjet=false;            
        }

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

        MapEntite_bwPeriode = new Map<string,VIperiode__c>();
        for(VIPeriode__c per : [SELECT ID,name, entite_bw__c, date_de_debut__c, date_de_fin__c  
                                  FROM VIPeriode__c
                                 WHERE entite_bw__c='1'  ]) {
             MapEntite_bwPeriode.put(per.name,per);
         }
        
        ReRead();
    }

    public void Chargement (){
       if(aff.Date_de_fin_de_garantie__c!=null && aff.Date_de_fin_de_garantie__c<system.today()) {
           VIUtils.recalc(affaireID,false, true, tdMO,tdGAR, tdEMM, tdAMP, tdFOl, cs801, MapEntite_bwPeriode,lam.Periode_comptable__r.date_de_debut__c );
       }
    }
    
    
    Public void ReRead() {   
        string LastLam = null;
        date LastLamDate = null ; 
        double LastLamNbrMois= 0;

        MapLam = new Map<string, VILigne_d_affaire_mensuelle__c>();
        //Periode_comptable__r.statut__c!=:VIConstant.PERIODE_FUTURE AND 
        for(VILigne_d_affaire_mensuelle__c lam:[SELECT id, periode_comptable__r.name,
                                                       name, CurrencyIsoCode, affaire__c, 
                                                       affaire__r.Date_de_derniere_revue__c,
                                                       Periode_comptable__r.statut__c,
                                                       Periode_comptable__r.date_de_debut__c,
                                                       Periode_comptable__r.Saisie_ouverte__c,
                                                       affaire__r.Date_de_SAV_reelle__c ,
                                                       Nom_de_l_affaire__c,
                                                       Ligne_d_affaire_mensuelle_precedente__c ,
                                                       Marge_PV__c,
                                                       Marge_PVE__c, 
                                                       PV_Total__c,
                                                       PV_TotalE__c,
                                                       PV_Facture__c,
                                                       PV_FactureE__c,
                                                       PV_Encaisse__c,               
                                                       PV_EncaisseE__c,  
                                                       PV_Encaisse_HT__c,               
                                                       PV_Encaisse_HTE__c,  
                                                       Ecart_RAD_Total__c ,
                                                       Ecart_RAD_TotalE__c, 
                                                       Devis_Heure__c,
                                                       Devis_MontantD__c,               
                                                       Devis_MontantD_E__c,
                                                       Devis_MontantI__c,               
                                                       Devis_MontantI_E__c,
                                                       Devis_MontantC__c,               
                                                       Devis_MontantC_E__c,
                                                       Engage_brut_arrete_Heure__c, 
                                                       Engage_brut_arrete_MontantD__c, 
                                                       Engage_brut_arrete_MontantD_E__c,                
                                                       Engage_brut_arrete_MontantI__c, 
                                                       Engage_brut_arrete_MontantI_E__c,                
                                                       Engage_brut_arrete_MontantC__c, 
                                                       Engage_brut_arrete_MontantC_E__c,                
                                                       Dont_comptabiliseD__c, 
                                                       Dont_comptabiliseD_E__c, 
                                                       Dont_comptabiliseI__c, 
                                                       Dont_comptabiliseI_E__c, 
                                                       Dont_comptabiliseC__c, 
                                                       Dont_comptabiliseC_E__c, 
 
                                                       Ecart_C_A_F_Heure__c, 
                                                       Ecart_C_A_F_MontantD__c,               
                                                       Ecart_C_A_F_MontantD_E__c,
                                                       Ecart_C_A_F_MontantI__c,               
                                                       Ecart_C_A_F_MontantI_E__c,
                                                       Ecart_C_A_F_MontantC__c,               
                                                       Ecart_C_A_F_MontantC_E__c,
                                                       Cout_terminaison_Heure__c,                
                                                       Cout_terminaison_MontantD__c, 
                                                       Cout_terminaison_MontantD_E__c , 
                                                       Cout_terminaison_MontantI__c, 
                                                       Cout_terminaison_MontantI_E__c , 
                                                       Cout_terminaison_MontantC__c, 
                                                       Cout_terminaison_MontantC_E__c , 
                                                       Ecart_RAD_Heure__c,               
                                                       Ecart_RAD_MontantD__c,
                                                       Ecart_RAD_MontantD_E__c,
                                                       Ecart_RAD_MontantI__c,
                                                       Ecart_RAD_MontantI_E__c,
                                                       Ecart_RAD_MontantC__c,
                                                       Ecart_RAD_MontantC_E__c,
                                                       Total_Pourcentage_d_avancement__c ,
                                                       Total_CA_a_l_avancement__c ,
                                                       affaire__r.Mode_de_calcul_de_l_avancement__c ,
                                                       garantie_dotation__c,
                                                       garantie_dotation_E__c,
                                                       garantie_reprise__c,               
                                                       garantie_reprise_E__c                                                
                                                  FROM VILigne_d_affaire_mensuelle__c
                                                 WHERE affaire__r.id=:affaireID
                                              ORDER BY name] ) {
            MapLam.put(lam.id,lam);
            if(LastLam==null || LastLamNbrMois > decimal.valueof(system.today().daysbetween(lam.Periode_comptable__r.date_de_debut__c)).abs()) {                                     
                LastLam=lam.id;
                LastLamDate = lam.Periode_comptable__r.date_de_debut__c;
                LastLamNbrMois = decimal.valueof(system.today().daysbetween(LastLamDate)).abs();
            } 
                                                
                                                  
            if(LigneMensuelleID==null && lam.Periode_comptable__r.statut__c==VIConstant.PERIODE_OUVERTE)
                LigneMensuelleID=lam.id;
        } 
        if(LigneMensuelleID==null)
            LigneMensuelleID=LastLam ;

        lam = MapLam.get(LigneMensuelleID);
        Total_CA_a_l_avancement_converti=VIUTils.conv_number_thousand(lam.Total_CA_a_l_avancement__c,0) ;             

        affaireID = lam.affaire__c;                             
        system.debug(' lam.Periode_comptable__r.saisie_ouverte__c '+lam.Periode_comptable__r.saisie_ouverte__c);
        if((lam.Periode_comptable__r.statut__c==VIConstant.PERIODE_OUVERTE || lam.Periode_comptable__r.statut__c==VIConstant.PERIODE_PREOUVERTE) 
             && lam.currencyIsoCode == CurrencyType
             && (IsChefDeProjet=true || IsControleurGestion)) {
            Etat_affaire = true ; 
        } else {
            Etat_affaire = false ; 
        }
        if(lam.affaire__r.Date_de_SAV_reelle__c!=null)
            Etat_affaire = false ; 

        system.debug(' Etat_affaire '+Etat_affaire);        
        CurrencyType=lam.CurrencyIsoCode ; 
        if(lam.Ligne_d_affaire_mensuelle_precedente__c!=null) {
            idPrecedent=lam.Ligne_d_affaire_mensuelle_precedente__c ;
        } else {
            idPrecedent=null;
        }
        
        list<VILigne_d_affaire_mensuelle__c> ListLamSuivante = [SELECT id 
                                                                  FROM VILigne_d_affaire_mensuelle__c
                                                                 WHERE Periode_comptable__r.statut__c!=:VIConstant.PERIODE_FUTURE
                                                                   AND Ligne_d_affaire_mensuelle_precedente__c=:LigneMensuelleID];
        if(ListLamSuivante.size()==1) {
            idSuivant=ListLamSuivante[0].id ;
        } else {
            idSuivant=null;
        }
        
        ListLigne = new List<Ligne>();
        MapLA = new map<id,VILigne_affaire__c> ();
        list<VILigne_affaire__c>ListLigneAffaire = new list<VILigne_affaire__c>();
        String query = 'SELECT Id, Name, Ligne_d_affaire_mensuelle__r.affaire__c,Type_de_ligne_d_affaire__c ,';
        query = query +'       Ligne_d_affaire_mensuelle__r.periode_comptable__r.name,';
        query = query +'       Centre_Section__r.name,';
        query = query +'       Centre_Section__r.id,';
        query = query +'       Type_depense__r.name,';
        query = query +'       Type_depense__r.id,';                                   
        query = query +'       Devis_Heure__c, ';
        query = query +'       Devis_MontantD__c,   Devis_MontantI__c,   Devis_MontantC__c,';
        query = query +'       Devis_MontantD_E__c, Devis_MontantI_E__c, Devis_MontantC_E__c,';
        query = query +'       Engage_brut_arrete_Heure__c, ';
        query = query +'       Engage_brut_arrete_MontantD__c,   Engage_brut_arrete_MontantI__c,  Engage_brut_arrete_MontantC__c,';
        query = query +'       Engage_brut_arrete_MontantD_E__c, Engage_brut_arrete_MontantI_E__c,Engage_brut_arrete_MontantC_E__c,';
        query = query +'       Dont_comptabiliseD__c,  Dont_comptabiliseI__c,  Dont_comptabiliseC__c,';
        query = query +'       Dont_comptabiliseD_E__c,Dont_comptabiliseI_E__c,Dont_comptabiliseC_E__c,';
        query = query +'       Ecart_C_A_F_Heure__c,';
        query = query +'       Ecart_C_A_F_MontantD__c,   Ecart_C_A_F_MontantI__c,  Ecart_C_A_F_MontantC__c,';
        query = query +'       Ecart_C_A_F_MontantD_E__c, Ecart_C_A_F_MontantI_E__c,Ecart_C_A_F_MontantC_E__c,';
        query = query +'       Cout_terminaison_Heure__c, ';
        query = query +'       Cout_terminaison_MontantD__c,   Cout_terminaison_MontantI__c,  Cout_terminaison_MontantC__c,';
        query = query +'       Cout_terminaison_MontantD_E__c, Cout_terminaison_MontantI_E__c,Cout_terminaison_MontantC_E__c,';
        query = query +'       Ecart_RAD_Heure__c,';
        query = query +'       Ecart_RAD_MontantD__c,  Ecart_RAD_MontantI__c,  Ecart_RAD_MontantC__c, ';        
        query = query +'       Ecart_RAD_MontantD_E__c,  Ecart_RAD_MontantI_E__c,  Ecart_RAD_MontantC_E__c ';                
        query = query +'  FROM VILigne_affaire__c ';
        query = query +' WHERE Ligne_d_affaire_mensuelle__r.affaire__c = \''+affaireId+'\'' ;
        query = query +'   AND Ligne_d_affaire_mensuelle__r.periode_comptable__r.name = \''+lam.periode_comptable__r.name +'\'';
        query = query +'   ORDER BY '+Sortorder ;
        
        query = query +' '+sens ; 
        ListLigneAffaire = Database.query(query) ;         
        SortOrderPrevious=SortOrder;

        for(VILigne_affaire__c l: ListLigneAffaire) {
           MapLa.put(l.id,l);
           if(CurrencyType!='EUR') {                                   
               if(Valeur=='Debours') {
                   ListLigne.add(new Ligne(l.id, l.Type_de_ligne_d_affaire__c,
                                           l.centre_section__r.name, l.centre_section__r.id,
                                           l.Type_depense__r.name,l.Type_depense__r.id,
                                           l.Devis_Heure__c,l.Devis_MontantD__c,
                                           l.Engage_brut_arrete_Heure__c, l.Engage_brut_arrete_MontantD__c,
                                           l.Dont_comptabiliseD__c,
                                           l.Ecart_C_A_F_Heure__c,l.Ecart_C_A_F_MontantD__c,
                                           l.Cout_terminaison_Heure__c, l.Cout_terminaison_MontantD__c,
                                           l.Ecart_RAD_Heure__c, l.Ecart_RAD_MontantD__c)) ; 
                   
                                      
               } else if (Valeur=='Industriel') {
                   ListLigne.add(new Ligne(l.id, l.Type_de_ligne_d_affaire__c, 
                                           l.centre_section__r.name,l.centre_section__r.id,
                                           l.Type_depense__r.name,l.Type_depense__r.id,
                                           l.Devis_Heure__c,l.Devis_MontantI__c,
                                           l.Engage_brut_arrete_Heure__c, l.Engage_brut_arrete_MontantI__c,
                                           l.Dont_comptabiliseI__c,
                                           l.Ecart_C_A_F_Heure__c,l.Ecart_C_A_F_MontantI__c,
                                           l.Cout_terminaison_Heure__c, l.Cout_terminaison_MontantI__c,
                                           l.Ecart_RAD_Heure__c, l.Ecart_RAD_MontantI__c)) ;  


               }  else if (Valeur=='Complet') {
                   ListLigne.add(new Ligne(l.id, l.Type_de_ligne_d_affaire__c, 
                                           l.centre_section__r.name, l.centre_section__r.id,
                                           l.Type_depense__r.name,l.Type_depense__r.id,
                                           l.Devis_Heure__c,l.Devis_MontantC__c,
                                           l.Engage_brut_arrete_Heure__c, l.Engage_brut_arrete_MontantC__c,
                                           l.Dont_comptabiliseC__c,
                                           l.Ecart_C_A_F_Heure__c,l.Ecart_C_A_F_MontantC__c,
                                           l.Cout_terminaison_Heure__c, l.Cout_terminaison_MontantC__c,
                                           l.Ecart_RAD_Heure__c, l.Ecart_RAD_MontantC__c)) ;  
                                      
               }                                 
           } else {
               if(Valeur=='Debours') {
                   ListLigne.add(new Ligne(l.id, l.Type_de_ligne_d_affaire__c, 
                                           l.centre_section__r.name, l.centre_section__r.id,
                                           l.Type_depense__r.name,l.Type_depense__r.id,
                                           l.Devis_Heure__c,l.Devis_MontantD_E__c,
                                           l.Engage_brut_arrete_Heure__c, l.Engage_brut_arrete_MontantD_E__c,
                                           l.Dont_comptabiliseD_E__c,
                                           l.Ecart_C_A_F_Heure__c,l.Ecart_C_A_F_MontantD_E__c,
                                           l.Cout_terminaison_Heure__c, l.Cout_terminaison_MontantD_E__c,
                                           l.Ecart_RAD_Heure__c, l.Ecart_RAD_MontantD__c)) ; 
                                      
               } else if (Valeur=='Industriel') {
                   ListLigne.add(new Ligne(l.id, l.Type_de_ligne_d_affaire__c, 
                                           l.centre_section__r.name, l.centre_section__r.id,
                                           l.Type_depense__r.name,l.Type_depense__r.id,
                                           l.Devis_Heure__c,l.Devis_MontantI_E__c,
                                           l.Engage_brut_arrete_Heure__c, l.Engage_brut_arrete_MontantI_E__c,
                                           l.Dont_comptabiliseI_E__c,
                                           l.Ecart_C_A_F_Heure__c,l.Ecart_C_A_F_MontantI_E__c,
                                           l.Cout_terminaison_Heure__c, l.Cout_terminaison_MontantI_E__c,
                                           l.Ecart_RAD_Heure__c, l.Ecart_RAD_MontantI_E__c)) ;  

               }  else if (Valeur=='Complet') {
                   ListLigne.add(new Ligne(l.id, l.Type_de_ligne_d_affaire__c, 
                                           l.centre_section__r.name, l.centre_section__r.id,
                                           l.Type_depense__r.name,l.Type_depense__r.id,
                                           l.Devis_Heure__c,l.Devis_MontantC_E__c,
                                           l.Engage_brut_arrete_Heure__c, l.Engage_brut_arrete_MontantC_E__c,
                                           l.Dont_comptabiliseC_E__c,
                                           l.Ecart_C_A_F_Heure__c,l.Ecart_C_A_F_MontantC_E__c,
                                           l.Cout_terminaison_Heure__c, l.Cout_terminaison_MontantC_E__c,
                                           l.Ecart_RAD_Heure__c, l.Ecart_RAD_MontantC_E__c)) ;  

               }                                 
           }                                 
       }

       if(Langage!='fr') {
           for(Ligne LL :ListLigne ){
               LL.centre_section =MapCentre.get(LL.Centre_Section.left(3));
               LL.Type_Depense   =MapTypeDeDepense.get(LL.type_Depense.left(3));
           }
       }
        
        
       LigneTotal = new Ligne('','','','','','',0,0,0,0,0,0,0,0,0,0,0);
       LigneTotal.devis_heure                = lam.devis_heure__c;        
       LigneTotal.Engage_brut_arrete_Heure   = lam.Engage_brut_arrete_Heure__c ; 
       LigneTotal.Ecart_C_A_F_Heure          = lam.Ecart_C_A_F_Heure__c ; 
       LigneTotal.Cout_terminaison_Heure     = lam.Cout_terminaison_Heure__c ; 
       LigneTotal.Ecart_RAD_Heure            = lam.Ecart_RAD_Heure__c ; 

        
        if(CurrencyType!='EUR') {
           if(Valeur=='Debours') { 
               LigneTotal.Devis_Montant              = lam.Devis_MontantD__c ; 
               LigneTotal.Engage_brut_arrete_Montant = lam.Engage_brut_arrete_MontantD__c ; 
               LigneTotal.Dont_comptabilise          = lam.Dont_comptabiliseD__c ; 
               LigneTotal.Ecart_C_A_F_Montant        = lam.Ecart_C_A_F_MontantD__c ; 
               LigneTotal.Cout_terminaison_Montant   = lam.Cout_terminaison_MontantD__c ; 
               LigneTotal.Ecart_RAD_Montant          = lam.Ecart_RAD_MontantD__c ;                         
           } else if(Valeur=='Industriel') {
               LigneTotal.Devis_Montant              = lam.Devis_MontantI__c ; 
               LigneTotal.Engage_brut_arrete_Montant = lam.Engage_brut_arrete_MontantI__c ; 
               LigneTotal.Dont_comptabilise          = lam.Dont_comptabiliseI__c ; 
               LigneTotal.Ecart_C_A_F_Montant        = lam.Ecart_C_A_F_MontantI__c ; 
               LigneTotal.Cout_terminaison_Montant   = lam.Cout_terminaison_MontantI__c ; 
               LigneTotal.Ecart_RAD_Montant          = lam.Ecart_RAD_MontantI__c ;                         
           } else if(Valeur=='Complet') {
               LigneTotal.Devis_Montant              = lam.Devis_MontantC__c ; 
               LigneTotal.Engage_brut_arrete_Montant = lam.Engage_brut_arrete_MontantC__c ; 
               LigneTotal.Dont_comptabilise          = lam.Dont_comptabiliseC__c ; 
               LigneTotal.Ecart_C_A_F_Montant        = lam.Ecart_C_A_F_MontantC__c ; 
               LigneTotal.Cout_terminaison_Montant   = lam.Cout_terminaison_MontantC__c ; 
               LigneTotal.Ecart_RAD_Montant          = lam.Ecart_RAD_MontantC__c ;                         
           }
       } else {
           if(Valeur=='Debours') { 
               LigneTotal.Devis_Montant              = lam.Devis_MontantD_E__c ; 
               LigneTotal.Engage_brut_arrete_Montant = lam.Engage_brut_arrete_MontantD_E__c ; 
               LigneTotal.Dont_comptabilise          = lam.Dont_comptabiliseD_E__c ; 
               LigneTotal.Ecart_C_A_F_Montant        = lam.Ecart_C_A_F_MontantD_E__c ; 
               LigneTotal.Cout_terminaison_Montant   = lam.Cout_terminaison_MontantD_E__c ; 
               LigneTotal.Ecart_RAD_Montant          = lam.Ecart_RAD_MontantD_E__c ;                         
           } else if(Valeur=='Industriel') {
               LigneTotal.Devis_Montant              = lam.Devis_MontantI_E__c ; 
               LigneTotal.Engage_brut_arrete_Montant = lam.Engage_brut_arrete_MontantI_E__c ; 
               LigneTotal.Dont_comptabilise          = lam.Dont_comptabiliseI_E__c ; 
               LigneTotal.Ecart_C_A_F_Montant        = lam.Ecart_C_A_F_MontantI_E__c ; 
               LigneTotal.Cout_terminaison_Montant   = lam.Cout_terminaison_MontantI_E__c ; 
               LigneTotal.Ecart_RAD_Montant          = lam.Ecart_RAD_MontantI_E__c ;                         
           } else if(Valeur=='Complet') {
               LigneTotal.Devis_Montant              = lam.Devis_MontantC_E__c ; 
               LigneTotal.Engage_brut_arrete_Montant = lam.Engage_brut_arrete_MontantC_E__c ; 
               LigneTotal.Dont_comptabilise          = lam.Dont_comptabiliseC_E__c ; 
               LigneTotal.Ecart_C_A_F_Montant        = lam.Ecart_C_A_F_MontantC_E__c ; 
               LigneTotal.Cout_terminaison_Montant   = lam.Cout_terminaison_MontantC_E__c ; 
               LigneTotal.Ecart_RAD_Montant          = lam.Ecart_RAD_MontantC_E__c ;                         
           }
       }

        // We need this for recompute the _conv fields
        LigneTotal = New Ligne('','','','','','',
                                LigneTotal.devis_heure,LigneTotal.Devis_Montant,
                                LigneTotal.Engage_brut_arrete_Heure,LigneTotal.Engage_brut_arrete_Montant, 
                                LigneTotal.Dont_comptabilise,
                                LigneTotal.Ecart_C_A_F_Heure,LigneTotal.Ecart_C_A_F_Montant, 
                                LigneTotal.Cout_terminaison_Heure,LigneTotal.Cout_terminaison_Montant,       
                                LigneTotal.Ecart_RAD_Heure,LigneTotal.Ecart_RAD_Montant
                              );
        
       if((lam.Periode_comptable__r.statut__c==VIConstant.PERIODE_OUVERTE || lam.Periode_comptable__r.statut__c==VIConstant.PERIODE_PREOUVERTE) && lam.currencyIsoCode == CurrencyType) {
            Etat_affaire = true ; 
       } else {
            Etat_affaire = false ; 
       }
       if(Valeur!='Debours') {
            Etat_affaire = false ;        
       }
       if(lam.affaire__r.Date_de_SAV_reelle__c!=null)
            Etat_affaire = false ; 

       if(lam.Periode_comptable__r.saisie_ouverte__c==false)
            Etat_affaire = false ;            
           
        Piedtotal = new total(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0) ;
        // First line of total
        if(CurrencyType!='EUR') {
            PiedTotal.PVA_T = lam.PV_Total__c;     
            PiedTotal.PVF_T = lam.PV_Facture__c ; 
            PiedTotal.PVE_T = lam.PV_Encaisse_HT__c ; 
            PiedTotal.PVT_T = lam.PV_Total__c; 
            PiedTotal.ERAD_T= lam.Ecart_RAD_Total__c; 
        } else {
            PiedTotal.PVA_T = lam.PV_TotalE__c;     
            PiedTotal.PVF_T = lam.PV_FactureE__c ; 
            PiedTotal.PVE_T = lam.PV_Encaisse_HTE__c ;
            PiedTotal.PVT_T = lam.PV_TotalE__c ;
            PiedTotal.ERAD_T= lam.Ecart_RAD_Total__c;             
        }

        // Second line of total
        if(CurrencyType!='EUR') {
            PiedTotal.PVA_M = (lam.PV_total__c==null ? 0  : lam.PV_total__c)   - LigneTotal.Devis_Montant   ;
            PiedTotal.PVF_M = (lam.PV_facture__c==null ? 0: lam.PV_facture__c) - LigneTotal.Dont_comptabilise    ;            
        } else {
            PiedTotal.PVA_M = (lam.PV_totalE__c==null ? 0  : lam.PV_totalE__c)   - LigneTotal.Devis_Montant   ;
            PiedTotal.PVF_M = (lam.PV_factureE__c==null ? 0: lam.PV_factureE__c) - LigneTotal.Dont_comptabilise    ;                        
        }
        PiedTotal.ECA_M = (LigneTotal.Ecart_C_A_F_Montant) * (-1);
        PiedTotal.PVT_M = (PiedTotal.PVT_T==null ? 0 : PiedTotal.PVT_T) - (LigneTotal.Cout_terminaison_Montant == null ? 0 : LigneTotal.Cout_terminaison_Montant); 
        PiedTotal.ERAD_M= PiedTotal.ERAD_T - LigneTotal.Ecart_RAD_Montant;             
        
        // third line of total
        if(PiedTotal.PVA_T!= null && PiedTotal.PVA_T!=0)
            PiedTotal.PVA_P = (PiedTotal.PVA_M / PiedTotal.PVA_T) * 100 ;

        if(PiedTotal.PVF_T!= null && PiedTotal.PVF_T!=0)
            PiedTotal.PVF_P = (PiedTotal.PVF_M / PiedTotal.PVF_T) * 100 ;        

        PiedTotal.ECA_P = LigneTotal.Ecart_C_A_F_Montant;

        if(PiedTotal.PVT_T!= null && PiedTotal.PVT_T!=0)
            PiedTotal.PVT_P = (PiedTotal.PVT_M / PiedTotal.PVT_T) * 100 ;

        if(PiedTotal.ERAD_T!= null && PiedTotal.ERAD_T!=0)
            PiedTotal.ERAD_P = (PiedTotal.ERAD_M / PiedTotal.ERAD_T) * 100 ;

        
        // We need this for recompute the _conv fields
        PiedTotal = new Total(PiedTotal.PVA_T, PiedTotal.PVA_M, PiedTotal.PVA_P, 
                              PiedTotal.PVF_T, PiedTotal.PVF_M, PiedTotal.PVF_P, 
                              PiedTotal.PVE_T, 
                              PiedTotal.ECA_T, PiedTotal.ECA_M, PiedTotal.ECA_P,                               
                              PiedTotal.PVT_T, PiedTotal.PVT_M, PiedTotal.PVT_P,                               
                              PiedTotal.ERAD_T, PiedTotal.ERAD_M, PiedTotal.ERAD_P);  
    }

    Public Void Suivant() {
        LigneMensuelleID=IDSuivant;
        ReRead();
    }

    Public Void Precedent() {
        LigneMensuelleID=IDPrecedent;
        ReRead();
    }
    
    Public void SaveData() {
        List<VILigne_affaire__c>ListLAUpdate = new List<VILigne_affaire__c>();
        for(Ligne l:ListLigne) {
            VIligne_affaire__c la = new VIligne_affaire__c();
            la = MapLA.get(l.id);
            if(l.Ecart_C_A_F_Heure!=null)
                la.Ecart_C_A_F_Heure__c=l.Ecart_C_A_F_Heure.setscale(0) ; 

            if(l.Ecart_C_A_F_Montant!=null) {
                la.Ecart_C_A_F_MontantD__c = l.Ecart_C_A_F_Montant.setscale(0) ;
            }
            
            ListLAUpdate.add(la);
        }
        Update ListLAUpdate;

        VIUtils.recalc(affaireID,true, false, tdMO,tdGAR, tdEMM, tdAMP, tdFOl, cs801, MapEntite_bwPeriode,lam.Periode_comptable__r.date_de_debut__c );

        try{
            aff.date_de_derniere_revue__c=system.today();
            update aff;
        } catch(DmlException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter value'));
        }
          
        ReRead();
    }

    public void SAV() {
        if(ValSav==true) { 
           VIPeriode__c per = [SELECT date_de_fin__c
                                 FROM VIPeriode__c
                                WHERE entite_bw__c = :aff.entite_bw__c
                                  AND Statut__c=:VIConstant.PERIODE_OUVERTE];
            aff.Date_de_SAV_reelle__c = per.date_de_fin__c;
            update aff;
        }
    }
    
    Public Void SortCentre() {
        SortOrder='Type_de_ligne_d_affaire__c ASC, Centre_Section__r.cle_pour_le_tri__c';        
        if(SortOrder==SortOrderPrevious){
            if(Sens=='ASC') {
                Sens='DESC';
            } else {
                Sens='ASC';
            } 
        } else {
            Sens='ASC';
        }        
        ReRead();       
    }

    Public Void SortDepense() {
        SortOrder='Type_de_ligne_d_affaire__c ASC, Type_depense__r.name';
        if(SortOrder==SortOrderPrevious){
            if(Sens=='ASC') {
                Sens='DESC';
            } else {
                Sens='ASC';
            } 
        } else {
            Sens='ASC';
        }        

        ReRead();       
    }
    
    public List<SelectOption> getValeurOptions() 
    {
            List<SelectOption> ValeurOptions = new List<SelectOption>();        
             
            ValeurOptions.add(new SelectOption('Debours','Debours'));
            ValeurOptions.add(new SelectOption('Industriel','Industriel'));
            ValeurOptions.add(new SelectOption('Complet','Complet'));
  
            return ValeurOptions;
    }

    public List<SelectOption> getCurrencyOptions() 
    {
            List<SelectOption> CurrencyOptions = new List<SelectOption>(); 
            if(lam.CurrencyIsoCode!='EUR') {
                CurrencyOptions.add(new SelectOption(lam.CurrencyIsoCode,lam.CurrencyIsoCode));
            }
            CurrencyOptions.add(new SelectOption('EUR','EUR'));
            return CurrencyOptions;
    }

    public List<SelectOption> getLAMOptions() 
    {
        List<SelectOption> LAMOptions = new List<SelectOption>(); 
        for(VILigne_d_affaire_mensuelle__c lam : MapLam.values()) {
            LAMOptions.add(new SelectOption( lam.id, lam.periode_comptable__r.name.left(6)));
        }    
        return LAMOptions;
    }

    public pageReference Refresh() {

        //PageReference RetPage = ApexPages.currentPage();
        String baseURL = '/lightning/r/VIAffaire__c/'+affaireID+'/view';
        PageReference  RetPAge = new PageReference(baseURL);
        RetPage.setRedirect(true);
       return RetPage; 
    }    
    
    public void SOQL_verif() {
    // This function is never used. It's just here to keep tracks of field used in the table
    // 
        List<VILigne_affaire__c> l=[SELECT Id, Name, Ligne_d_affaire_mensuelle__r.affaire__c,Ligne_d_affaire_mensuelle__r.periode_comptable__r.name,
                                    Centre_Section__r.name,
                                    Centre_Section__r.id,
                                    Type_depense__r.name,
                                    Type_depense__r.id,                                   
                                    Devis_Heure__c, 
                                    Devis_MontantD__c,   Devis_MontantI__c,   Devis_MontantC__c,
                                    Devis_MontantD_E__c, Devis_MontantI_E__c, Devis_MontantC_E__c,
                                    Engage_brut_arrete_Heure__c, 
                                    Engage_brut_arrete_MontantD__c,   Engage_brut_arrete_MontantI__c,  Engage_brut_arrete_MontantC__c,
                                    Engage_brut_arrete_MontantD_E__c, Engage_brut_arrete_MontantI_E__c,Engage_brut_arrete_MontantC_E__c,
                                    Dont_comptabiliseD__c,  Dont_comptabiliseI__c,  Dont_comptabiliseC__c,
                                    Dont_comptabiliseD_E__c,Dont_comptabiliseI_E__c,Dont_comptabiliseC_E__c,
                                    Ecart_C_A_F_Heure__c,
                                    Ecart_C_A_F_MontantD__c,   Ecart_C_A_F_MontantI__c,  Ecart_C_A_F_MontantC__c,
                                    Ecart_C_A_F_MontantD_E__c, Ecart_C_A_F_MontantI_E__c,Ecart_C_A_F_MontantC_E__c,
                                    Cout_terminaison_Heure__c, 
                                    Cout_terminaison_MontantD__c,   Cout_terminaison_MontantI__c,  Cout_terminaison_MontantC__c,
                                    Cout_terminaison_MontantD_E__c, Cout_terminaison_MontantI_E__c,Cout_terminaison_MontantC_E__c,
                                    Ecart_RAD_Heure__c, 
                                    Ecart_RAD_MontantD__c,   Ecart_RAD_MontantI__c,   Ecart_RAD_MontantC__c,
                                    Ecart_RAD_MontantD_E__c, Ecart_RAD_MontantI_E__c, Ecart_RAD_MontantC_E__c
                               FROM VILigne_affaire__c 
                           ORDER BY Ligne_d_affaire_mensuelle__r.periode_comptable__r.name,
                                    Centre_Section__r.name,
                                    Type_depense__r.name LIMIT 1];
    }
    
}