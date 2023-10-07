public class VIZoomBudgetController {

    public String Valeur{get;set;}    
    public string SortOrder { get; set; }
    public string SortOrderPrevious { get; set; }
    Public string Sens { get; set; }    
    public VILigne_d_affaire_mensuelle__c  lam { get; set; }
    public VICentre_Section__c  centre { get; set; }  
    public VItype_de_depense__c  td { get; set; }  

    public list<VIligne_budget__c> ListLigne_budget { get; set; }  
    public list<Ligne> ListLigne { get; set; }  
    Public Date StartExercise { get; set; }   
    

    Public Class Ligne{
        public string avenant  {get;set;}
        public date Date_avenant  {get;set;}
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
        

        public Ligne(string av, date da,   decimal h, decimal D, decimal I, decimal C, decimal D_E, decimal I_E, decimal C_E) {
            avenant = av ;
            Date_avenant = da ;
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
    
    public VIZoomBudgetController() {
        lam= null;
        centre = null;
        td = null ; 
        
        String lamID = System.currentPageReference().getParameters().get('lam');
        list<VILigne_d_affaire_mensuelle__c>Listlam = [SELECT id, name ,  affaire__r.Nom_affaire__c,affaire__r.Entite_BW__c,
                                                              CurrencyIsoCode, periode_comptable__r.date_de_fin__c,
                                                              affaire__c,Periode_comptable__r.name,affaire__r.Name
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
        
        String tdID = System.currentPageReference().getParameters().get('td');    
        list<VIType_de_depense__c>ListType_de_depense = [SELECT id, name
                                                 FROM VIType_de_depense__c 
                                                WHERE id=:tdID];
        if(ListType_de_depense.size()==1) {
            td=ListType_de_depense[0];
        }

        Valeur='Debours';
        SortByDate();
        ReadLigneBudget();
    }

    public void ReadLigneBudget() {
        if(lam==null || centre==null|| td==null) {
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

        String query = 'SELECT avenant__c,avenant__r.name, avenant__r.date__c, ';
        query = query +'       Centre_Section__r.name, type_de_depense__r.name,avenant__r.Code_avenant__c , ';
        query = query +'       CurrencyIsoCode, heures__c, ';
        query = query +'       debours__c, debours_E__c, ';
        query = query +'       PRI__c, PRI_E__c, ';
        query = query +'       complet__c, complet_E__c ';
        query = query +'  FROM VILigne_budget__c ';
        query = query +' WHERE Avenant__r.Affaire__c =\''+lam.affaire__c+'\' ';
        query = query +'   AND Centre_Section__c =\''+centre.id+'\' ';
        query = query +'   AND type_de_depense__c =\''+td.id+'\' ';
        query = query +'   AND avenant__r.Periode_comptable__r.name <=\''+lam.Periode_comptable__r.name+'\' '; 
        query = query +'   AND (not avenant__r.Statut_avenant__c like \'10\')  ';
        query = query +'   AND avenant__r.date__c>='+string.valueof(StartExercise).left(10);

        
        if(SortOrder=='Date') {
            query = query +' ORDER BY avenant__r.date__c ';
        } else if(SortOrder=='Avenant') {
            query = query +' ORDER BY avenant__r.name ';
        } 
        query = query +sens ; 
        ListLigne_budget = Database.query(query) ;         
        SortOrderPrevious=SortOrder;

        VILigne_budget__c BudgetTotal = new VILigne_budget__c();
        BudgetTotal.debours__c = 0;
        BudgetTotal.PRI__c = 0;
        BudgetTotal.complet__c = 0;        
        BudgetTotal.debours_E__c = 0;
        BudgetTotal.PRI_E__c = 0;
        BudgetTotal.complet_E__c = 0;        
        for(VILigne_budget__c p :ListLigne_budget) {
            BudgetTotal.Debours__c = BudgetTotal.Debours__c  + (p.debours__c==null ? 0 : p.debours__c) ;
            BudgetTotal.PRI__c     = BudgetTotal.PRI__c      + (p.PRI__c==null ? 0     : p.PRI__c) ;
            BudgetTotal.Complet__c = BudgetTotal.Complet__c  + (p.Complet__c==null ? 0 : p.Complet__c) ;            
            BudgetTotal.Debours_E__c = BudgetTotal.Debours_E__c  + (p.debours_E__c==null ? 0 : p.debours_E__c) ;
            BudgetTotal.PRI_E__c     = BudgetTotal.PRI_E__c      + (p.PRI_E__c==null ? 0     : p.PRI_E__c) ;
            BudgetTotal.Complet_E__c = BudgetTotal.Complet_E__c  + (p.Complet_E__c==null ? 0 : p.Complet_E__c) ;            
        }       
        ListLigne_budget.add(BudgetTotal);
        ListLigne = new List<Ligne>();
        for(VILigne_budget__c bu:ListLigne_budget) {
            ListLigne.add(new ligne(bu.avenant__r.code_avenant__c, bu.avenant__r.date__c, bu.heures__c ,
                      bu.debours__c,bu.pri__c,bu.Complet__c,
                      bu.debours_E__c,bu.pri_E__c,bu.Complet_E__c));
        }

        
        
    }
    
    public void SortByDate() {
        SortOrder='Date';
        ReadLigneBudget();
    }
    public void SortByAvenant() {
        SortOrder='Avenant';
        ReadLigneBudget();
    }

    public void SOQL_verif() {
        // This function is never used. It's just here to keep tracks of field used in the table
        // 

       list<VILigne_budget__c>ListBu = [SELECT avenant__c,avenant__r.name, avenant__r.date__c, 
                                   Centre_Section__r.name, type_de_depense__r.name, 
                                   CurrencyIsoCode, heures__c,
                                   debours__c, debours_E__c,
                                   PRI__c, PRI_E__c,
                                   complet__c, complet_E__c
                              FROM VILigne_budget__c
                             WHERE Avenant__r.Affaire__c =:lam.affaire__c
                               AND Centre_Section__c =:centre.id
                               AND type_de_depense__c =:td.id      
                               AND (not avenant__r.Statut_avenant__c like '10')
                         ORDER BY type_de_depense__r.name,avenant__r.date__c DESC];            

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