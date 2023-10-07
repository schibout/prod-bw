public class VIMajSavController {

    public List<VIPeriode__c >ListPeriode { get; set; }

    Public List<VILigne_d_affaire_mensuelle__c>ListLam {get; set;}
    Public List<VILigne_d_affaire_mensuelle__c>ListLam1 {get; set;}
    public Map<string, ViAffaire__c> MapAffaire = new Map<string, ViAffaire__c>();
    Map<string, date>MapEntite_bw = new Map<string, date>();

    ApexPages.StandardSetController mycon;
       
    public VIMajSavController(ApexPages.StandardSetController mycon) {        
        this.MyCon = Mycon;        
        //Mycon.setPageSize(Mycon.getResultSize());
        ListLam=Mycon.getSelected();
        List<id>ListId = new List<id>();
        for(VILigne_d_affaire_mensuelle__c lam:ListLam) {
            ListID.add(lam.id);
        }
        
        ListLam1 = new List<VILigne_d_affaire_mensuelle__c>();
        for(VILigne_d_affaire_mensuelle__c lam:[SELECT id, Nom_de_l_affaire__c, affaire__r.name, Affaire_a_fermer__c, affaire__c
                                                  FROM VILigne_d_affaire_mensuelle__c
                                                WHERE id in : ListID]) {
            lam.Affaire_a_fermer__c=true;                                                    
            ListLam1.add(lam);
       }
                
        for(VIPeriode__c per:[SELECT id, entite_bw__c, date_de_fin__c 
                                 FROM VIPeriode__c
                                WHERE Statut__c=:VIConstant.PERIODE_OUVERTE]) {
            MapEntite_bw.put(per.entite_bw__c,per.date_de_fin__c) ;
        }
        ListPeriode=[SELECT entite_bw__c, date_de_fin__c FROM VIperiode__c WHERE Statut__c=:VIConstant.PERIODE_OUVERTE ORDER BY entite_bw__c];        
        
    }       

    public PageReference  Enregistrer() {
        
        ListLam=Mycon.getselected();

        for(VILigne_d_affaire_mensuelle__c lam: ListLam1) {
            if(lam.Affaire_a_fermer__c) {
              MapAffaire.put(lam.affaire__c,null);
            }
        }
        for(VIaffaire__c aff: [SELECT id, date_de_sav_reelle__c, entite_bw__c
                                 FROM VIAffaire__c
                               WHERE id in :MapAffaire.keyset()]) {
            aff.date_de_sav_reelle__c = MapEntite_bw.get(aff.entite_bw__c);
            MapAffaire.put(aff.id,aff) ;
        }
        update MapAffaire.values();
        
        return mycon.cancel();
    }

}