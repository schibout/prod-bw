public class VIZoomHeuresEngageesController {

    public String Valeur{get;set;}    
    public string SortOrder { get; set; }
    public string SortOrderPrevious { get; set; }
    Public string Sens { get; set; }
    public VILigne_d_affaire_mensuelle__c  lam { get; set; }
    public VICentre_Section__c  centre { get; set; }  
    public list<VIPointage__c> ListPointage { get; set; }  
    public list<Ligne> ListLigne { get; set; }  
    Public Date StartExercise { get; set; }   
    

    Public Class Ligne{
        public string salarie  {get;set;}
        public string Matricule  {get;set;}        
        public string Secteur_commercial  {get;set;}                
        public date Date_pointage  {get;set;}
        public date Date_Comptabilisation  {get;set;}
        public string Annee_semaine  {get;set;}
        public decimal heure  {get;set;}
        public string heure_conv  {get;set;}                
        public decimal Debours  {get;set;}                
        public string Debours_conv  {get;set;}                        
        public decimal PRI  {get;set;}                
        public string PRI_conv  {get;set;}                        
        public decimal Complet  {get;set;}                
        public string Complet_conv  {get;set;}                        
        public decimal Debours_E  {get;set;}                
        public string Debours_E_conv  {get;set;}                        
        public decimal PRI_E  {get;set;}                
        public string PRI_E_conv  {get;set;}                        
        public decimal Complet_E  {get;set;}                
        public string Complet_E_conv  {get;set;}                        
        

        public Ligne(string sal, string mat,string sc,date dp,date dc,string ase,   decimal h, decimal D, decimal I, decimal C, decimal D_E, decimal I_E, decimal C_E) {
            salarie = sal ;
            matricule = mat ;
            Secteur_commercial = sc ; 
            Date_pointage = dp ;
            Date_comptabilisation = dc ; 
            annee_semaine = ase ;             
            heure = h ; 
            heure_conv = VIUtils.conv_number_thousand(h,2) ;             
            Debours = d ; 
            debours_conv = VIUtils.conv_number_thousand(d,2) ;             
            pri = i ; 
            pri_conv = VIUtils.conv_number_thousand(i,2) ;             
            Complet = C ; 
            Complet_conv = VIUtils.conv_number_thousand(c,2) ;             
            Debours_E = d_E ; 
            debours_E_conv = VIUtils.conv_number_thousand(d_E,2) ;             
            pri_E = i_E ; 
            pri_E_conv = VIUtils.conv_number_thousand(i_E,2) ;             
            Complet_E = C_E ; 
            Complet_E_conv = VIUtils.conv_number_thousand(c_E,2) ;             
        }
    }
    
    public VIZoomHeuresEngageesController() {
        lam= null;
        centre = null;
        
        String lamID = System.currentPageReference().getParameters().get('lam');
        list<VILigne_d_affaire_mensuelle__c>Listlam = [SELECT id, name , periode_comptable__r.date_de_fin__c , affaire__r.Nom_affaire__c,CurrencyIsoCode,
                                                              affaire__c, affaire__r.name, Periode_comptable__r.name,affaire__r.Entite_BW__c
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
            StartExercise=date.newinstance(2000,1,1);
        
        String CentreID = System.currentPageReference().getParameters().get('Centre');    
        list<VICentre_Section__c>ListCentre = [SELECT id, name
                                                 FROM VICentre_Section__c 
                                                WHERE id=:CentreID];
        if(ListCentre.size()==1) {
            centre=ListCentre[0];
        }
        Valeur='Debours';
        Sens='ASC';
        SortOrder='E';
        SortOrderPrevious='S';
        SortByDateComptabilisation();
        ReadPointage();
    }

    public void ReadPointage() {
        if(lam==null || centre==null) {
            return;
        }
        if(SortOrder==SortOrderPrevious){
            if(Sens=='ASC') {
                Sens='DESC';
            } else {
                Sens='ASC';
            } 
        } else {
            Sens='ASC';
        }

        String query = 'SELECT employe__r.name, employe__r.NMatricule__c , ToLabel(employe__r.USER_SecteurCommercial__c)  , ';
        query = query +'       Date__c ,Date_comptabilisation__c , Annee_Ori__c , semaine_ori__c, heures__c, CurrencyIsoCode, ';
        query = query +'       debours__c, debours_E__c, ';
        query = query +'       PRI__c, PRI_E__c,';
        query = query +'       complet__c, complet_E__c ';
        query = query +'  FROM VIPointage__c ';
        query = query +' WHERE Affaire__c =\''+lam.affaire__c+'\' ';
        query = query +'   AND Centre_Section__c =\''+centre.id+'\' ';
        query = query +'   AND Periode_comptable__r.name <=\''+lam.Periode_comptable__r.name+'\' '; 
        query = query +'   AND date__c>='+string.valueof(StartExercise).left(10);
        
        system.debug(query.right(100));
        
        if(SortOrder=='Salarie') {
            query = query +' ORDER BY employe__r.lastname,employe__r.firstname  ';
        } else if(SortOrder=='Date') {
            query = query +' ORDER BY date__c ';
        } else if(SortOrder=='DateComptabilisation') {
            query = query +' ORDER BY Date_comptabilisation__c ';
        } 
        query = query +sens ; 
        ListPointage = Database.query(query) ;         
        SortOrderPrevious=SortOrder;
        
        VIPointage__c PointageTotal = new VIPointage__c();
        PointageTotal.heures__c = 0;
        PointageTotal.debours__c = 0;
        PointageTotal.PRI__c = 0;
        PointageTotal.complet__c = 0;        
        PointageTotal.debours_E__c = 0;
        PointageTotal.PRI_E__c = 0;
        PointageTotal.complet_E__c = 0;        
        for(VIPointage__c p :ListPointage) {
            PointageTotal.heures__c = PointageTotal.heures__c  + (p.heures__c==null ? 0 : p.heures__c) ;
            
            PointageTotal.Debours__c = PointageTotal.Debours__c  + (p.debours__c==null ? 0 : p.debours__c) ;
            PointageTotal.PRI__c     = PointageTotal.PRI__c      + (p.PRI__c==null ? 0     : p.PRI__c) ;
            PointageTotal.Complet__c = PointageTotal.Complet__c  + (p.Complet__c==null ? 0 : p.Complet__c) ;            
            PointageTotal.Debours_E__c = PointageTotal.Debours_E__c  + (p.debours_E__c==null ? 0 : p.debours_E__c) ;
            PointageTotal.PRI_E__c     = PointageTotal.PRI_E__c      + (p.PRI_E__c==null ? 0     : p.PRI_E__c) ;
            PointageTotal.Complet_E__c = PointageTotal.Complet_E__c  + (p.Complet_E__c==null ? 0 : p.Complet_E__c) ;            
        }       
        ListPointage.add(PointageTotal);
        ListLigne = new List<Ligne>();
        for(VIPointage__c po:listPointage) {
            string annee_semaine='' ; 
            if(po.Annee_Ori__c!=null) {
                annee_semaine = string.valueof(po.Annee_Ori__c)+'-'+('00'+string.valueof(po.semaine_Ori__c)).right(2)  ;
            }
            ListLigne.add(new ligne(po.employe__r.name,po.employe__r.NMatricule__c,po.employe__r.USER_SecteurCommercial__c,
                      po.date__c, po.Date_comptabilisation__c, Annee_semaine, po.heures__c ,
                      po.debours__c,po.pri__c,po.Complet__c,
                      po.debours_E__c,po.pri_E__c,po.Complet_E__c));
        }
        
    }
    
    public void SortBySalarie() {
        SortOrder='Salarie';
        ReadPointage();
    }

    public void SortByDate() {
        SortOrder='Date';
        ReadPointage();
    }
    public void SortByDateComptabilisation() {
        SortOrder='DateComptabilisation';
        ReadPointage();
    }

    public void SOQL_verif() {
        // This function is never used. It's just here to keep tracks of field used in the table
        // 
       list<VIPointage__c> ListPo = [SELECT employe__c, Date__c ,heures__c,CurrencyIsoCode,
                                            debours__c, debours_E__c,
                                            PRI__c, PRI_E__c,
                                            complet__c, complet_E__c
                                       FROM VIPointage__c
                                      WHERE Affaire__c =:lam.affaire__c
                                        AND Centre_Section__c =:centre.id
                                   ORDER BY date__c,employe__c DESC];
    }
    
    public List<SelectOption> getValeurOptions() 
    {
            List<SelectOption> ValeurOptions = new List<SelectOption>();        
             
            ValeurOptions.add(new SelectOption('Debours','Debours'));
            ValeurOptions.add(new SelectOption('Industriel','Industriel'));
            ValeurOptions.add(new SelectOption('Complet','Complet'));
  
            return ValeurOptions;
    }

    
}