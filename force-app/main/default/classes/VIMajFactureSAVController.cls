public class VIMajFactureSAVController {

    public List<VIPeriode__c >ListPeriode { get; set; }

    Public List<VIFacture__c>ListFac {get; set;}
    Public List<VIFacture__c>ListFac1 {get; set;}
    public Map<string, ViAffaire__c> MapAffaire = new Map<string, ViAffaire__c>();
    Map<string, date>MapEntite_bw = new Map<string, date>();

    ApexPages.StandardSetController mycon;
       
    public VIMajFactureSAVController(ApexPages.StandardSetController mycon) {        
        this.MyCon = Mycon;        
        //Mycon.setPageSize(Mycon.getResultSize());
        ListFac=Mycon.getSelected();
        List<id>ListId = new List<id>();
        for(VIfacture__c fac:ListFac) {
            ListID.add(fac.id);
        }
        
        ListFac1 = new List<VIFacture__c>();
        for(VIFacture__c fac:[SELECT id, name, affaire__c, affaire__r.name, compte__r.name, bu__c,sous_domaine__c,
                                     Date_d_ouverture_d_affaire__c ,Date_de_SAV_reelle__c ,
                                     date__c, date_de_comptabilisation__c, montant_ht__c, Facture_SAV_traitee__c , Facture_SAV_Comptabilisee__c 
                                FROM VIFacture__c
                               WHERE id in : ListID]) {
            fac.Facture_SAV_traitee__c=true;                                                    
            Listfac1.add(fac);
       }
                
        for(VIPeriode__c per:[SELECT id, entite_bw__c, date_de_fin__c 
                                 FROM VIPeriode__c
                                WHERE Statut__c=:VIConstant.PERIODE_OUVERTE]) {
            MapEntite_bw.put(per.entite_bw__c,per.date_de_fin__c) ;
        }
        ListPeriode=[SELECT Tolabel(entite_bw__c), date_de_fin__c FROM VIperiode__c WHERE Statut__c=:VIConstant.PERIODE_OUVERTE ORDER BY entite_bw__c];        
        
    }       

    public PageReference  Enregistrer() {
        for(VIFacture__c fac:listfac1) {
            if(fac.Facture_SAV_Comptabilisee__c)
                fac.Facture_SAV_traitee__c=true;                                                    
        }
        
        update listfac1;
        if(!Test.isRunningTest() )
            Database.executeBatch(new VIBatchGenerateFactSAV('', '1'),VIBatchGenerateFactSAV.NBR_LOT);
        
        return mycon.cancel();
    }

}