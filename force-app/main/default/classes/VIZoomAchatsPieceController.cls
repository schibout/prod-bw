public class VIZoomAchatsPieceController {

    public String Valeur{get;set;}    
    public String Prov{get;set;}        
    public String SortOrder {get;set;}
    public string SortOrderPrevious { get; set; }
    Public string Sens { get; set; }   
    Public String num_cde { get; set; }     
    Public String num_aff { get; set; }     

    Public Date StartExercise { get; set; }     
    
    public list<VIAchat__c> ListAchat { get; set; }  
    public list<Ligne> ListLigne { get; set; }  

    Public Class Ligne{
        public string ref_achat  {get;set;}
        public string num_fac  {get;set;}        
        public string num_cde  {get;set;}                
        public date Date_achat  {get;set;}
        public date Date_de_comptabilisation {get;set;}
        public string nom_du_fournisseur  {get;set;}
        public string des_commande  {get;set;}
        public decimal Commande  {get;set;}                
        public string Commande_conv  {get;set;}                        
        public decimal Comptabilise  {get;set;}                
        public string Comptabilise_conv  {get;set;}                        
        

        public Ligne(string ra, string nuf,string ncd, date da,date dc1,  string nf,string dc, decimal com, decimal cpt) {
            ref_achat = ra ;
            num_fac = nuf ; 
            num_cde = ncd ;             
            Date_achat = da ;
            Date_de_comptabilisation = dc1 ; 
            nom_du_fournisseur = nf ;
            des_commande = dc ;            
            Commande = com ; 
            Commande_conv = VIUtils.conv_number_thousand(com,2) ;             
            Comptabilise = com ; 
            Comptabilise_conv = VIUtils.conv_number_thousand(cpt,2) ;             
        }
    }


    
    public VIZoomAchatsPieceController() {
        Prov ='Sans Prov';
        
        num_cde = System.currentPageReference().getParameters().get('ref');
        num_aff = System.currentPageReference().getParameters().get('aff');        
        
        Valeur='Debours';
                
        
        SortByRefAchat();

    }

    public void ReadAchat() {
        if(num_cde==null ) {
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
        
        ListAchat = [SELECT Date__c ,CurrencyIsoCode, name,Date_de_comptabilisation__c, affaire__r.entite_bw__c,affaire__r.name,
                            centre_section__r.name, type_depense__r.name, Periode_comptable__r.name ,                          
                            Nom_du_fournisseur__c ,Description_de_la_commande__c ,origine__c, num_frn__c, num_cde__c,num_fac__c,
                            CommandeD__c,CommandeI_E__c,CommandeC_E__c,
                            CommandeD_E__c,CommandeI__c,CommandeC__c,                     
                            ComptabiliseD__c,ComptabiliseI__c,ComptabiliseC__c,
                            ComptabiliseD_E__c,ComptabiliseI_E__c,ComptabiliseC_E__c                     
                       FROM VIAchat__c
                      WHERE num_cde__c =:num_cde
                        AND affaire__r.name=:num_aff];

        VIPeriode__c PeriodeOuverte= [SELECT id,date_de_debut__c, date_de_fin__c, entite_bw__c
                                        FROM VIPeriode__c
                                       WHERE statut__c=:VIConstant.PERIODE_OUVERTE
                                         AND entite_bw__c=:listAchat[0].affaire__r.Entite_BW__c];
        
        StartExercise=date.newinstance(PeriodeOuverte.date_de_debut__c.year(),1,1);
        if(listAchat[0].affaire__r.name.left(1)!='9')
            StartExercise=date.newinstance(1999,1,1);
        
        system.debug('start exercise '+StartExercise);
        
        ListLigne  =new list<Ligne>(); 
            
        for(VIAchat__c ac : ListAchat) {
            
            if(ac.date__c<StartExercise) 
                continue; 
            
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
            
            
            ListLigne.add(new ligne(ac.name, ac.num_fac__c, ac.num_cde__c,ac.date__c, ac.Date_de_comptabilisation__c, ac.Nom_du_fournisseur__c ,ac.Description_de_la_commande__c ,
                      commande,
                      comptabilise ));
            
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
            if(ac.date__c<StartExercise) 
                continue; 
            
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
            if(ac.date__c<StartExercise) 
                continue; 
            
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

            string url ;
            if(ac.date__c==null || ac.num_fac__c==null) {
                url=ac.num_fac__c;
            } else {
                url = '\\\\SBRE17\\PdfFactures\\' ; 
                if(ac.date__c.year()!=system.today().year()) {
                    url=url+ac.date__c.year()+'\\';
                }   
                url = url+ac.num_fac__c.split(' ')[0]+'.pdf' ; 
                url='<a href=\"'+url+'">'+ac.num_fac__c+'</a>';
            }
            ListLigne.add(new ligne(ac.name, url,ac.num_cde__c, ac.date__c, ac.Date_de_comptabilisation__c, ac.Nom_du_fournisseur__c ,ac.Description_de_la_commande__c ,
                      commande,
                      comptabilise ));
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

    
}