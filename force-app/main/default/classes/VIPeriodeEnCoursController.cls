public with sharing class  VIPeriodeEnCoursController {

    public List<VIPeriode__c >ListPeriode { get; set; }
    
    public VIPeriodeEnCoursController() {
        ListPeriode=[SELECT ToLabel(Entite_BW__c),date_de_debut__c, name FROM VIperiode__c WHERE Statut__c=:VIConstant.PERIODE_OUVERTE ORDER BY Entite_BW__c];        
    }
    
}