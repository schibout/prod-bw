public class VIZoomAchatsController {

    public String Valeur{get;set;}    
    public String Prov{get;set;}        
    public String SortOrder {get;set;}
    public string SortOrderPrevious { get; set; }
    Public string Sens { get; set; }   
    Public Date StartExercise { get; set; }   
    
    public VILigne_d_affaire_mensuelle__c  lam { get; set; }
    public VICentre_Section__c  centre { get; set; }  
    public VIType_de_depense__c td { get; set; }      
    public VIType_de_depense__c tdAMP { get; set; }      
    public VIType_de_depense__c tdGAR { get; set; }      

    public list<VIAchat__c> ListAchat { get; set; }  
    public list<Ligne> ListLigne { get; set; }  

    Public Class Ligne{
        public string ref_achat  {get;set;}
        public string num_fac  {get;set;}        
        public string sous_chapitre  {get;set;}        
        public date Date_achat  {get;set;}
        public date Date_de_comptabilisation {get;set;}
        public string nom_du_fournisseur  {get;set;}
        public string des_commande  {get;set;}
        public decimal Commande  {get;set;}                
        public string Commande_conv  {get;set;}                        
        public decimal Comptabilise  {get;set;}                
        public string Comptabilise_conv  {get;set;}                        
        public boolean plusieurs_factures {get;set;}                        

        public Ligne(string ra, string nuf, string schap, date da,date dc1,  string nf,string dc, decimal com, decimal cpt, boolean plus) {
            ref_achat = ra ;
            num_fac = nuf ; 
            sous_chapitre = schap ; 
            Date_achat = da ;
            Date_de_comptabilisation = dc1 ; 
            nom_du_fournisseur = nf ;
            des_commande = dc ;            
            Commande = com ; 
            Commande_conv = VIUtils.conv_number_thousand(com,2) ;             
            Comptabilise = com ; 
            Comptabilise_conv = VIUtils.conv_number_thousand(cpt,2) ;        
            plusieurs_factures = plus ; 
        }
    }


    
    public VIZoomAchatsController() {
        lam= null;
        centre = null;
        td= null;
        tdAMP= null;
        tdGAR= null;

        
        String lamID = System.currentPageReference().getParameters().get('lam');
        list<VILigne_d_affaire_mensuelle__c>Listlam = [SELECT id, name , periode_comptable__r.date_de_fin__c , 
                                                              affaire__r.Nom_affaire__c,CurrencyIsoCode,
                                                              affaire__r.Name,Periode_comptable__r.name,
                                                              affaire__c, affaire__r.Entite_BW__c 
                                                         FROM VILigne_d_affaire_mensuelle__c 
                                                        WHERE id=:lamID ];
        if(listlam.size()==1) {
            lam=ListLam[0];
        }


        VIPeriode__c PeriodeOuverte= [SELECT id,date_de_debut__c, date_de_fin__c, entite_bw__c
                                        FROM VIPeriode__c
                                       WHERE statut__c=:VIConstant.PERIODE_OUVERTE
                                         AND entite_bw__c=:lam.affaire__r.Entite_BW__c];
        
        StartExercise=date.newinstance(PeriodeOuverte.date_de_debut__c.year(),1,1);
        if(lam.affaire__r.name.left(1)!='9')
            StartExercise=date.newinstance(1900,1,1);

     
        
        String CentreID = System.currentPageReference().getParameters().get('Centre');    
        list<VICentre_Section__c>ListCentre = [SELECT id, name
                                                 FROM VICentre_Section__c 
                                                WHERE id=:CentreID];
        if(ListCentre.size()==1) {
            centre=ListCentre[0];
        }

        String tdID = System.currentPageReference().getParameters().get('td');    
        list<VIType_de_depense__c>ListType_de_depense = [SELECT id, name
                                                 FROM VIType_de_depense__c 
                                                WHERE id=:tdID];
        if(ListType_de_depense.size()==1) {
            td=ListType_de_depense[0];
        }
        
        for(VIType_de_depense__c t :[SELECT id, name
                                       FROM VIType_de_depense__c 
                                      WHERE NAME like 'AMP%'  or NAME like 'GAR%'] ) {
            if(t.name.startswith('AMP'))   
                tdAMP = t ; 
            if(t.name.startswith('GAR'))   
                tdGAR = t ; 
        
        }

        Valeur='Debours';
        
        if(td.name.startswith('EMM') || td.name.startswith('AMP') || 
           td.name.startswith('FOL') || td.name.startswith('DMR') || 
           td.name.startswith('PFG') || td.name.startswith('MAT') ||
           td.name.startswith('GAR') ) {
            Prov ='Avec Prov';
        } else {
            Prov ='Sans Prov';            
        }

        SortOrder='DateComptabilisation';        
        SortOrderPrevious='DateComptabilisation';                
        Sens='ASC';
        SortByDateComptabilisation();

    }

    Public Void MajProv() {
        SortOrder='DateComptabilisation';        
        SortOrderPrevious='DateComptabilisation';                
        Sens='ASC';
        ReadAchat()  ;     
    }
    
    
    public void ReadAchat() {
        
        if(lam==null || centre==null|| td==null) {
            return;
        }
        system.debug('Sens avant '+sens);
        system.debug('Sort '+SortOrder+' '+SortOrderPrevious);
        if(SortOrder==SortOrderPrevious){
            if(Sens=='ASC') {
                Sens='DESC';
            } else {
                Sens='ASC';
            } 
        } else {
            Sens='DESC';
        }
        
        system.debug('Sens après '+sens);
        // Three small requests instead of a big one for saving time
        // The "where" clause is removed for saving time
        
        if(valeur=='Debours') {
            ListAchat = [SELECT Date__c ,CurrencyIsoCode, name,Date_de_comptabilisation__c, Sous_chapitre__c ,
                            centre_section__c, type_depense__c, Periode_comptable__r.name , 
                            Nom_du_fournisseur__c ,Description_de_la_commande__c ,origine__c, num_frn__c, num_cde__c, num_fac__c,
                            CommandeD__c,
                            ComptabiliseD__c
                       FROM VIAchat__c
                      WHERE Affaire__c =:lam.affaire__c ];
                //       AND Centre_Section__c =:centre.id
                //       AND type_depense__c =:td.id 
                //       AND Periode_comptable__r.name <=:lam.Periode_comptable__r.name];       
        } else if(valeur=='Industriel') {
            ListAchat = [SELECT Date__c ,CurrencyIsoCode, name,Date_de_comptabilisation__c, Sous_chapitre__c ,
                            centre_section__c, type_depense__c, Periode_comptable__r.name ,                          
                            Nom_du_fournisseur__c ,Description_de_la_commande__c ,origine__c, num_frn__c, num_cde__c,num_fac__c,
                            CommandeI__c,
                            ComptabiliseI__c
                       FROM VIAchat__c
                      WHERE Affaire__c =:lam.affaire__c  ];
               //        AND Centre_Section__c =:centre.id
               //        AND type_depense__c =:td.id 
               //        AND Periode_comptable__r.name <=:lam.Periode_comptable__r.name];       
        } if(valeur=='Complet') {
            ListAchat = [SELECT Date__c ,CurrencyIsoCode, name,Date_de_comptabilisation__c, Sous_chapitre__c ,
                            centre_section__c, type_depense__c, Periode_comptable__r.name ,                          
                            Nom_du_fournisseur__c ,Description_de_la_commande__c ,origine__c, num_frn__c, num_cde__c,num_fac__c,
                            CommandeC__c,
                            ComptabiliseC__c
                       FROM VIAchat__c
                      WHERE Affaire__c =:lam.affaire__c ];
                //       AND Centre_Section__c =:centre.id
                //       AND type_depense__c =:td.id 
                //       AND Periode_comptable__r.name <=:lam.Periode_comptable__r.name];       
        }  
            
        
        SortOrderPrevious=SortOrder;
        
        // Alors il ne faut afficher qu'une seule ligne si c'est la même référence achat
        Map<string, VIAchat__c>MapAchat = new Map<string, VIAchat__c>();
        Map<string,string>MapNumCde = new Map<string,string>();
        for(VIAchat__c ach : ListAchat) {
            if(ach.Date__c<StartExercise)
                continue ; 
            if(ach.Centre_Section__c !=centre.id)
                continue ; 

            if(ach.type_depense__c ==td.id) {
                // nothing
            } else if (ach.type_depense__c==tdAMP.id && td.id==tdGAR.id)  {
               // nothing 
            } else {
                continue ; 
            }
            
            
            if(ach.Periode_comptable__r.name >lam.Periode_comptable__r.name)
                continue ;
            if(prov=='Sans Prov') {
                if(ach.num_cde__c==null)
                    continue ; 
                if(!ach.num_cde__c.startswith('GWB') && !ach.num_cde__c.startswith('GWL'))
                    continue;
            }
            if(ach.num_cde__c!=null && (ach.num_cde__c.startswith('GWB') || ach.num_cde__c.startswith('GWL'))) {
                if(!MapNumCde.containskey(ach.num_cde__c)) {
                    MapNumCde.put(ach.num_cde__c,'');
                }
            }

            
            list<string>NumAch = ach.name.split('-');
            VIAchat__c ach1 = new VIAchat__c();
            string key ; 
            if(ach.num_cde__c!=null) {
                key=ach.num_cde__c;
            } else {
                key=NumAch[2] ;                
            }
            
            if(!MapAchat.containskey(key)) {
                ach1=new VIAchat__c(name=key,Sous_chapitre__c =ach.Sous_chapitre__c ,
                                      Nom_du_fournisseur__c=ach.Nom_du_fournisseur__c ,Description_de_la_commande__c=ach.Description_de_la_commande__c ,
                                      commandeD__c=0      ,commandeI__c=0      , commandeC__c=0,
                                      commandeD_E__c=0    ,commandeI_E__c=0    , commandeC_E__c=0,                                         
                                      ComptabiliseD__c=0  ,ComptabiliseI__c=0  , ComptabiliseC__c=0,                                           
                                      ComptabiliseD_E__c=0,ComptabiliseI_E__c=0, ComptabiliseC_E__c=0 );
                MapAchat.put(key,Ach1);
            } else {
                Ach1=MapAchat.get(key);

            }
            if(ach.origine__c=='SQL-SERVER-Facture-Fournisseur') {
                if(ach.Date_de_comptabilisation__c!=null)                
                    ach1.Date_de_comptabilisation__c=ach.Date_de_comptabilisation__c ;

                if(ach.Date__c!=null)                
                    ach1.Date__c=ach.Date__c ;

            } else {
                if(ach.Date_de_comptabilisation__c!=null)
                    ach1.Date_de_comptabilisation__c=ach.Date_de_comptabilisation__c ;                

                if(ach.Date__c!=null)                
                    ach1.Date__c=ach.Date__c ;
            }            
            if(ach.Sous_chapitre__c !=null )
                ach1.Sous_chapitre__c=ach.Sous_chapitre__c;
            
            if(ach.num_fac__c!=null)
                ach1.num_fac__c = ach.num_fac__c ; 
            
            if(ach.Description_de_la_commande__c!=null && ach.Description_de_la_commande__c!=key )
                ach1.Description_de_la_commande__c = ach.Description_de_la_commande__c ;

            if(ach.Nom_du_fournisseur__c!=null)
                ach1.Nom_du_fournisseur__c = ach.Nom_du_fournisseur__c ;

            if(valeur=='Debours') {
                ach1.commandeD__c        = ach1.commandeD__c        + (ach.commandeD__c       ==null?0:ach.commandeD__c);
                ach1.ComptabiliseD__c    = ach1.ComptabiliseD__c    + (ach.ComptabiliseD__c   ==null?0:ach.ComptabiliseD__c);
            }

            if(valeur=='Industriel') {            
                ach1.commandeI__c        = ach1.commandeI__c        + (ach.commandeI__c       ==null?0:ach.commandeI__c);            
                ach1.ComptabiliseI__c    = ach1.ComptabiliseI__c    + (ach.ComptabiliseI__c   ==null?0:ach.ComptabiliseI__c);                
            }

            if(valeur=='Complet') {                        
                ach1.commandeC__c        = ach1.commandeC__c        + (ach.commandeC__c       ==null?0:ach.commandeC__c);                        
                ach1.ComptabiliseC__c    = ach1.ComptabiliseC__c    + (ach.ComptabiliseC__c   ==null?0:ach.ComptabiliseC__c);
            }

        }
        ListAchat = new List<VIAchat__c>();
        list<string>ListSort = new list<string>();
        for(string l:MapAchat.keyset() ) {
            VIAchat__c ac=MapAchat.get(l);
            if(SortOrder=='RefAchat') {
                ListSort.add(ac.name+';'+l);
            } else if(SortOrder=='Num_fac') {
                ListSort.add(ac.num_fac__c+';'+l);
            } else if(SortOrder=='Date') {
                ListSort.add(string.valueof(ac.date__c)+';'+l);
            } else if(SortOrder=='DateComptabilisation') {
                ListSort.add(string.valueof(ac.Date_de_comptabilisation__c)+';'+l);                
            } else if(SortOrder=='NomFrn') {
                ListSort.add(ac.Nom_du_fournisseur__c+';'+l);
            } else if(SortOrder=='Desc') {
                ListSort.add(ac.Description_de_la_commande__c+';'+l);                
            } 
        }
        listSort.sort();
        List<String> finalList = new List<String>();
        if(sens=='DESC') {
            for(Integer i = listSort.size()-1; i>=0;i--) {
                 finalList.add(listSort.get(i));
            }
        } else {
            for(string s:listSort) {
                FinalList.add(s);
            }            
        }
        
        for(string l1 :FinalList) {
           list<string>l2 = l1.split(';');
           ListAchat.add(MapAchat.get(l2[1]));
        }
        
        for(VIAchat__c Ac:[SELECT id ,num_cde__c, num_fac__c
                             FROM VIAchat__c
                            WHERE num_cde__c in :MapNumCde.keyset()]) {
             string s = MapNumCde.get(ac.num_cde__c);
             if(ac.num_fac__c==null) 
                 continue; 
                                  
             if(!s.contains(ac.num_fac__c.split(' ')[0])) {
                 s=s +' / '+ac.num_fac__c.split(' ')[0];
             }
             MapNumCde.put(ac.num_cde__c,s);
        }
        
        
        VIAchat__c AchatTotal = new VIAchat__c();
        AchatTotal.commandeD__c = 0; 
        AchatTotal.commandeI__c = 0; 
        AchatTotal.commandeC__c = 0;         
        AchatTotal.commandeD_E__c = 0; 
        AchatTotal.commandeI_E__c = 0; 
        AchatTotal.commandeC_E__c = 0;         
        AchatTotal.ComptabiliseD__c = 0; 
        AchatTotal.ComptabiliseI__c = 0; 
        AchatTotal.ComptabiliseC__c = 0;         
        AchatTotal.ComptabiliseD_E__c = 0; 
        AchatTotal.ComptabiliseI_E__c = 0; 
        AchatTotal.ComptabiliseC_E__c = 0;         
        AchatTotal.name ='Total ';
        
        for(VIAchat__C ac : ListAchat) {
            
            AchatTotal.CommandeD__c = AchatTotal.CommandeD__c  + (ac.CommandeD__c==null ? 0 : ac.CommandeD__c) ;
            AchatTotal.CommandeI__c = AchatTotal.CommandeI__c  + (ac.CommandeI__c==null ? 0 : ac.CommandeI__c);
            AchatTotal.CommandeC__c = AchatTotal.CommandeC__c  + (ac.CommandeC__c==null ? 0 : ac.CommandeC__c);

            AchatTotal.CommandeD_E__c = AchatTotal.CommandeD_E__c  + (ac.CommandeD_E__c==null ? 0 : ac.CommandeD_E__c);
            AchatTotal.CommandeI_E__c = AchatTotal.CommandeI_E__c  + (ac.CommandeI_E__c==null ? 0 : ac.CommandeI_E__c);
            AchatTotal.CommandeC_E__c = AchatTotal.CommandeC_E__c  + (ac.CommandeC_E__c==null ? 0 : ac.CommandeC_E__c);

            AchatTotal.ComptabiliseD__c = AchatTotal.ComptabiliseD__c  + (ac.ComptabiliseD__c==null ? 0 : ac.ComptabiliseD__c);
            AchatTotal.ComptabiliseI__c = AchatTotal.ComptabiliseI__c  + (ac.ComptabiliseI__c==null ? 0 : ac.ComptabiliseI__c);
            AchatTotal.ComptabiliseC__c = AchatTotal.ComptabiliseC__c  + (ac.ComptabiliseC__c==null ? 0 : ac.ComptabiliseC__c);

            AchatTotal.ComptabiliseD_E__c = AchatTotal.ComptabiliseD_E__c  + (ac.ComptabiliseD_E__c==null ? 0 : ac.ComptabiliseD_E__c);
            AchatTotal.ComptabiliseI_E__c = AchatTotal.ComptabiliseI_E__c  + (ac.ComptabiliseI_E__c==null ? 0 : ac.ComptabiliseI_E__c);
            AchatTotal.ComptabiliseC_E__c = AchatTotal.ComptabiliseC_E__c  + (ac.ComptabiliseC_E__c==null ? 0 : ac.ComptabiliseC_E__c);

        }
        listAchat.add(AchatTotal);
        ListLigne = new List<Ligne>();
        
        for(VIAchat__c ac:listAchat) {
            double commande = 0;
            double comptabilise = 0;
            if(valeur=='Debours') {
                commande    =ac.CommandeD__c;
                comptabilise=ac.comptabiliseD__c;                
            } else if (valeur=='Industriel') {
                commande    =ac.CommandeI__c;
                comptabilise=ac.comptabiliseI__c;                
            } else if (valeur=='Complet') {
                commande    =ac.CommandeC__c;
                comptabilise=ac.comptabiliseC__c;                
            }
            
            boolean b =false ;
            if(MapNumCde.containskey(ac.name)) {
                if(MapNumCde.get(ac.name).countmatches('/')>1)
                    b=true;
            }
            ListLigne.add(new ligne(ac.name, ac.num_fac__c,ac.Sous_chapitre__c, ac.date__c, ac.Date_de_comptabilisation__c, ac.Nom_du_fournisseur__c ,ac.Description_de_la_commande__c ,
                      commande,
                      comptabilise,b ));
        }
    }
    public void SortByRefAchat() {
        SortOrder='RefAchat';
        ReadAchat();
    }
    public void SortByNum_fac() {
        SortOrder='Num_fac';
        ReadAchat();
    }
    public void SortByDate() {
        SortOrder='Date';
        ReadAchat();
    }
    public void SortByDateComptabilisation() {
        SortOrder='DateComptabilisation';
        ReadAchat();
    }
    public void SortByNomFrn() {
        SortOrder='NomFrn';
        ReadAchat();
    }
    public void SortByDesc() {
        SortOrder='Desc';
        ReadAchat();
    }

    public List<SelectOption> getValeurOptions() 
    {
            List<SelectOption> ValeurOptions = new List<SelectOption>();        
             
            ValeurOptions.add(new SelectOption('Debours','Debours'));
            ValeurOptions.add(new SelectOption('Industriel','Industriel'));
            ValeurOptions.add(new SelectOption('Complet','Complet'));
  
            return ValeurOptions;
    }

    public List<SelectOption> getProvOptions() 
    {
            List<SelectOption> ProvOptions = new List<SelectOption>();        
             
            ProvOptions.add(new SelectOption('Avec Prov','Avec Prov'));
            ProvOptions.add(new SelectOption('Sans Prov','Sans Prov'));
  
            return ProvOptions;
    }
    
}