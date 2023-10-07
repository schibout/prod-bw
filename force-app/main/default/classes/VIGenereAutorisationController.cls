public class VIGenereAutorisationController {


    public string IDAffaire {get; set;}
    public VIaffaire__c Affaire {get; set;}
    private ApexPages.StandardController stdCtrl;
       
    public VIGenereAutorisationController(ApexPages.StandardController std) {        
        stdCtrl=std;
        IDaffaire= std.getId();

        system.debug('IDAffaire '+IDAffaire);
        
    }       

    public void  SupprimerTout() {
/*        
        list<VIAutorisation_depense__c>ListAut= [SELECT id 
                                                   FROM VIAutorisation_depense__c 
                                                  WHERE Code_Affaire__c=:IDAffaire ];
        delete ListAut;
*/        

    }

    public void  CreerOuvert() {   
        list<VIAutorisation_depense__c>ListAut= [SELECT id, Code_Affaire__c , sous_Chapitre__c,
                                                        Date_du_mouvement__c ,Etat_du_mouvement__c , Statut_autorisation_depense__c 
                                                   FROM VIAutorisation_depense__c 
                                                  WHERE Code_Affaire__c=:IDAffaire
                                                    AND Etat_du_mouvement__c ='Open'];
        list<VIAutorisation_depense__c>ListNewAut = new list<VIAutorisation_depense__c>();
        for(VIAutorisation_depense__c aut:ListAut) {
            VIAutorisation_depense__c NewAut = new VIAutorisation_depense__c(
                Code_Affaire__c = idaffaire,
                sous_Chapitre__c = aut.sous_chapitre__c,
                Date_du_mouvement__c = system.today(),
                Etat_du_mouvement__c ='Open', 
                Statut_autorisation_depense__c='20') ;
           ListNewAut.add(NewAut);
        }
        insert ListNewAut;
    }

    public void  CreerFerme() { 
        list<VIAutorisation_depense__c>ListAut= [SELECT id, Code_Affaire__c , sous_Chapitre__c,
                                                        Date_du_mouvement__c ,Etat_du_mouvement__c , Statut_autorisation_depense__c 
                                                   FROM VIAutorisation_depense__c 
                                                  WHERE Code_Affaire__c=:IDAffaire
                                                    AND Etat_du_mouvement__c ='Open'];
        list<VIAutorisation_depense__c>ListNewAut = new list<VIAutorisation_depense__c>();
        for(VIAutorisation_depense__c aut:ListAut) {
            VIAutorisation_depense__c NewAut = new VIAutorisation_depense__c(
                Code_Affaire__c = idaffaire,
                sous_Chapitre__c = aut.sous_chapitre__c,
                Date_du_mouvement__c = system.today(),
                Etat_du_mouvement__c ='Close', 
                Statut_autorisation_depense__c='20') ;
           ListNewAut.add(NewAut);
        }
        insert ListNewAut;
       
        
    }
    
}