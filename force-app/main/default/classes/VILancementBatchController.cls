public /*with sharing*/ class VILancementBatchController {

    public string Entite_bw { get; set; }
    public string Entite_bw1 { get; set; }

    public string PeriodeEntite_bw { get; set; }

    public date date_minimum { get; set; }
    public date date_maximum { get; set; }    
 
    public List<VIPeriode__c >ListPeriode { get; set; }
    public string EcrituresAEnvoyer { get; set; }  
    public string AffaireAGenerer { get; set; }      
    public string AffaireAGenerer1 { get; set; }  
    public List<AsyncApexJob>ListJob { get; set; }  
    public integer ListJobSize { get; set; }  

    
    
    public VILancementBatchController() {
        Date_minimum = system.today();
        Date_maximum = system.today();   
        ListPeriode=[SELECT tolabel(entite_bw__c), name FROM VIperiode__c WHERE Statut__c=:VIConstant.PERIODE_OUVERTE ORDER BY entite_bw__c];
        
        ListJob=[select id, ApexClass.name, CompletedDate ,JobType, Status, TotalJobItems, NumberOfErrors, MethodName, JobItemsProcessed, createddate	 
                   from AsyncApexJob 
                  where status in ('Holding','Queued','Preparing','Processing')
                    and ApexClass.name like 'VI%'
                    and jobtype='BatchApex'];
        ListJobSize = ListJob.size();
        
        
    }

    public void callBatchCloture(){
        list<VILigne_comptable__c >listLignes=[SELECT id 
                                                 FROM VILigne_comptable__c 
                                                WHERE Statut_ecriture_comptable__c =:VIConstant.EC_BROUILLON
                                                  AND Affaire_de_rattachement__r.entite_bw__c=:entite_bw];
        if(ListLignes.size()<0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.VIErreur013 ));
        } else {
            if(VIutils.isBatchRunning()==null || Test.isRunningTest()) {
                VIBatchCloture b = new VIBatchCloture(entite_bw,true); 
                database.executebatch(b,VIBatchCloture.NBR_LOT());       
            }  else {
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.VIErreur013 ));            
            }
        }
    }     

    public void callBatchGenerate(){
        if(VIutils.isBatchRunning()==null || Test.isRunningTest()) {
            VIBatchGenerate b = new VIBatchGenerate(AffaireAGenerer1, entite_bw1); 
            database.executebatch(b,VIBatchGenerate.NBR_LOT);  
        }  else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.VIErreur013 ));            
        }
    }     
    public void CallBatchCalcTDBGazelle(){
        if(VIutils.isBatchRunning()==null || Test.isRunningTest()) {        
            VIBatchCalcTDBGazelle b = new VIBatchCalcTDBGazelle(entite_bw); 
            database.executebatch(b,VIBatchCalcTDBGazelle.NBR_LOT);  
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.VIErreur013 ));            
        }
    }     


    public void callImportAffaire(){
        if(VIutils.isBatchRunning()==null || Test.isRunningTest()) {        
            VISchedImportAffaire v = new VISchedImportAffaire(AffaireAGenerer, true, false,1);
            v.execute(null);
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.VIErreur013 ));            
        }
    }     

    
    public void callBatchEnvoiEcriture(){
        if(VIutils.isBatchRunning()==null || Test.isRunningTest()) {        
            VIBatchEnvoiEcriture b = new VIBatchEnvoiEcriture(EcrituresAEnvoyer, entite_bw); 
            database.executebatch(b,VIBatchEnvoiEcriture.NBR_LOT);  
            
            if(EcrituresAEnvoyer=='Reprise de garantie') {
                Database.executeBatch(new VIBatchGenereAutorisation(true),VIBatchGenereAutorisation.NBR_LOT);
                Database.executeBatch(new VIBatchGenereAutorisationPointage(true),VIBatchGenereAutorisationPointage.NBR_LOT);
            }
            
            
            
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.VIErreur013 ));            
        }
    }     

    public PageReference callRecalcul(){
        PageReference pageRef = new PageReference('/lightning/n/Lancement_Batch');

        if (Date_minimum == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.VIErreur002 ));
            Return null;
        } else if (Date_maximum == null) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.VIErreur003));
            Return null;
        } else if (Date_maximum < Date_minimum) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.VIErreur003));
            Return null;
        } else {    
            if(VIutils.isBatchRunning()==null || Test.isRunningTest()) {            
                VIBatchReCalcPointage b = new VIBatchReCalcPointage(date_minimum,date_maximum); 
                database.executebatch(b,VIBatchReCalcPointage.nbr_lot());              
            } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.VIErreur013 ));            
        }
        }
        return pageRef;
         
    }     
        
   
    public List<SelectOption> getEntite_BWOptions()  {
            List<SelectOption> Entite_BWOptions = new List<SelectOption>();                
            for(VIentitebw__c c:[SELECT name, entite_bw__c FROM VIentitebw__c where ouvert__c= true ORDER BY name]) {
                entite_bwOptions.add(new SelectOption(c.entite_bw__c,c.name));
            }
            return Entite_BWOptions;
    }

       
    public List<SelectOption> getPeriodeEntite_BWOptions()  {
            List<SelectOption> PeriodeEntite_BWOptions = new List<SelectOption>();                
            for(VIperiode__c c:[SELECT name, id, Entite_BW__c, (select id from Ecritures_comptables__r where Statut_ecriture_comptable__c like '10%' or Statut_ecriture_comptable__c like '20%'   limit 10)  FROM VIperiode__c WHERE Statut__c=:VIConstant.PERIODE_OUVERTE ORDER BY Entite_BW__c]) {
                if(c.ecritures_comptables__r.size()==0)                
                    PeriodeEntite_BWOptions.add(new SelectOption(c.Entite_BW__c,c.name));
            }
            return PeriodeEntite_BWOptions;
    }

    
    

}