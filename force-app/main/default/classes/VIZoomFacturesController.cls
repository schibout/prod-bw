public class VIZoomFacturesController {

    public list<VIFacture__c> ListFacture { get; set; }  
    public String affID  { get; set; }   
    public String lamID  { get; set; }       
    public String Periode  { get; set; }   
    public VIAffaire__C affaire  { get; set; }
    public VILigne_d_affaire_mensuelle__c lam  { get; set; }    
    public list<Ligne> ListLigne { get; set; }  
    public double TotalEncaisse  { get; set; }  
    public string TotalEncaisse_conv  { get; set; }      
    public double TotalEncaisse_E  { get; set; }  
    public string TotalEncaisse_E_conv  { get; set; }      
    Public Date StartExercise { get; set; }   

    Public Class Ligne{
        public string num_facture  {get;set;}
        public date Date_facture  {get;set;}
        public date Date_echeance  {get;set;}        
        public decimal HT  {get;set;}
        public string HT_conv  {get;set;}                
        public decimal TTC  {get;set;}                
        public string TTC_conv  {get;set;}                        
        public decimal HT_E  {get;set;}                
        public string HT_E_conv  {get;set;}                        
        public decimal TTC_E  {get;set;}                
        public string TTC_E_conv  {get;set;}                        
        
        public Ligne(string nf, date df, date de,  decimal h1, decimal t1, decimal h_E, decimal T_E) {
            num_facture = nf ;
            Date_facture = df ;
            Date_echeance = de ;            
            HT = h1 ; 
            HT_conv = VIUtils.conv_number_thousand(h1,2) ;             
            TTC = t1 ; 
            TTC_conv = VIUtils.conv_number_thousand(t1,2) ;             
            HT_E = h_E ; 
            HT_E_conv = VIUtils.conv_number_thousand(h_E,2) ;             
            TTC_E = t_E ; 
            TTC_E_conv = VIUtils.conv_number_thousand(t_E,2) ;             
        }
    }
    

    public VIZoomFacturesController() {
        
        affID = System.currentPageReference().getParameters().get('aff');
        Periode = System.currentPageReference().getParameters().get('per');
        lamID = System.currentPageReference().getParameters().get('lam');        

        Lam = [SELECT id,
                      PV_Encaisse_HT__c ,
                      PV_Encaisse_HTE__c 
                 FROM VILigne_d_affaire_mensuelle__c  
                WHERE id=:lamid];
        
        Affaire= [select name,CurrencyIsoCode,Nom_affaire__c, entite_bw__c FROM VIaffaire__c where id=:affID]; 

        VIPeriode__c PeriodeOuverte= [SELECT id,date_de_debut__c, date_de_fin__c, entite_bw__c
                                        FROM VIPeriode__c
                                       WHERE statut__c=:VIConstant.PERIODE_OUVERTE
                                         AND entite_bw__c=:affaire.Entite_BW__c];
        
        StartExercise=date.newinstance(PeriodeOuverte.date_de_debut__c.year(),1,1);
        if(affaire.name.left(1)!='9')
            StartExercise=date.newinstance(2000,1,1);
        
        ReadFacture();
    }

    public void ReadFacture() {
        if(AffID==null ) {
            return;
        }
        
        ListFacture = [SELECT id, name , affaire__r.Nom_affaire__c,CurrencyIsoCode,
                              affaire__c, date__c, date_echeance__c,
                              Montant_HT__c,Montant_HTE__c,
                              Montant_TVA__c,Montant_TVAE__c,                                            
                              Montant_TTC__c,Montant_TTCE__c,  
                              Montant_paye__c,Montant_payeE__c                                                                                        
                         FROM VIFacture__c 
                        WHERE affaire__c=:affID
                          AND Periode_comptable__r.name<=:Periode
                          and date__c>=:startexercise
                          and type__c='FAC'
                     ORDER BY name desc  ];

        // Alors il ne faut afficher qu'une seule ligne si c'est la même facture
        Map<string, VIFacture__c>MapFacture = new Map<string, VIFacture__c>();
        for(VIFacture__c fac : ListFacture) {
            list<string>NumFac = fac.name.split('-');
            VIFacture__c fac1 = new VIFacture__c();
            if(!MapFacture.containskey(NumFac[0])) {
                Fac1=new VIFacture__c(name=NumFac[0],
                                      Montant_HT__c=0,Montant_HTE__c=0,
                                      Montant_TVA__c=0,Montant_TVAE__c=0,                                            
                                      Montant_TTC__c=0,Montant_TTCE__c=0,  
                                      Montant_paye__c=0,Montant_payeE__c=0);
                MapFacture.put(NumFac[0],Fac1);
            } else {
                Fac1=MapFacture.get(NumFac[0]);
            }
            if(fac1.Montant_HT__c !=null) {
                if(fac.date__c!=null)
                    fac1.date__c=fac.date__c;
                
                if(fac.date_echeance__c!=null)                
                    fac1.date_echeance__c=fac.date_echeance__c;
            }
            fac1.Montant_HT__c    = fac1.Montant_HT__c    + (fac.Montant_HT__c   ==null?0:fac.Montant_HT__c);
            fac1.Montant_HTE__c   = fac1.Montant_HTE__c   + (fac.Montant_HTE__c  ==null?0:fac.Montant_HTE__c);            
            fac1.Montant_TVA__c   = fac1.Montant_TVA__c   + (fac.Montant_TVA__c  ==null?0:fac.Montant_TVA__c);
            fac1.Montant_TVAE__c  = fac1.Montant_TVAE__c  + (fac.Montant_TVAE__c ==null?0:fac.Montant_TVAE__c);            
            fac1.Montant_TTC__c   = fac1.Montant_TTC__c   + (fac.Montant_TTC__c  ==null?0:fac.Montant_TTC__c);
            fac1.Montant_TTCE__c  = fac1.Montant_TTCE__c  + (fac.Montant_TTCE__c ==null?0:fac.Montant_TTCE__c);            
            fac1.Montant_Paye__c  = fac1.Montant_Paye__c  + (fac.Montant_Paye__c ==null?0:fac.Montant_Paye__c);
            fac1.Montant_PayeE__c = fac1.Montant_PayeE__c + (fac.Montant_PayeE__c==null?0:fac.Montant_payeE__c);            
        }
        TotalEncaisse_conv   =VIUtils.conv_number_thousand(lam.PV_Encaisse_HT__c,2) ; 
        TotalEncaisse_E_conv =VIutils.conv_number_thousand(lam.PV_Encaisse_HTE__c,2) ; 
        
        ListFacture = new List<VIfacture__c>();
        ListFacture = MapFacture.values();
        
        ViFacture__c FactureTotal = new ViFacture__c();
        Facturetotal.Name='Total';        
        Facturetotal.Montant_HT__c=0;
        Facturetotal.Montant_TVA__c=0 ;
        Facturetotal.Montant_TTC__c =0 ;
        Facturetotal.Montant_Paye__c =0 ;    
        Facturetotal.Montant_HTE__c =0 ;
        Facturetotal.Montant_TVAE__c =0 ;
        Facturetotal.Montant_TTCE__c =0 ;
        Facturetotal.Montant_PayeE__c =0 ;    
        For(ViFacture__c fac:ListFacture) {
            FactureTotal.Montant_HT__c = FactureTotal.Montant_HT__c      + (fac.Montant_HT__c==null ? 0   : fac.Montant_HT__c) ;
            FactureTotal.Montant_TVA__c = FactureTotal.Montant_TVA__c    + (fac.Montant_TVA__c==null ? 0  : fac.Montant_TVA__c) ;
            FactureTotal.Montant_TTC__c = FactureTotal.Montant_TTC__c    + (fac.Montant_TTC__c==null ? 0  : fac.Montant_TTC__c) ; 
            FactureTotal.Montant_Paye__c = FactureTotal.Montant_Paye__c  + (fac.Montant_Paye__c==null ? 0 : fac.Montant_Paye__c) ;        
            FactureTotal.Montant_HTE__c = FactureTotal.Montant_HTE__c      + (fac.Montant_HTE__c==null ? 0   : fac.Montant_HTE__c) ;
            FactureTotal.Montant_TVAE__c = FactureTotal.Montant_TVAE__c    + (fac.Montant_TVAE__c==null ? 0  : fac.Montant_TVAE__c) ;
            FactureTotal.Montant_TTCE__c = FactureTotal.Montant_TTCE__c    + (fac.Montant_TTCE__c==null ? 0  : fac.Montant_TTCE__c) ; 
            FactureTotal.Montant_PayeE__c = FactureTotal.Montant_PayeE__c  + (fac.Montant_PayeE__c==null ? 0 : fac.Montant_PayeE__c) ;        
        
        }
        ListFacture.add(FactureTotal);
        
        ListLigne = new List<Ligne>();        
        for(VIFacture__c fac:ListFacture) {
            ListLigne.add(new ligne(fac.name, fac.date__c, fac.date_echeance__c ,
                      fac.montant_HT__c,fac.montant_TTC__c,
                      fac.montant_HTE__c,fac.montant_TTCE__c));
        }
    }
    
}