/*
* @author: Henri Saslawsky
* @description: 
*/

public class VI01_VIAutorisation_depense {

/*
* @description: Method to fill up the libelle
* 
* @param: List of VI01_VIAutorisation_depense__c
* @return : void
* 
*/

    public static void Load_Libelle (List <VIAutorisation_depense__c> listAd) { 
        system.debug('entrée dans VI01_VIAutorisation_depense.Load_libelle');

        list<Schema.PicklistEntry> PicklistEntries = VIAutorisation_depense__c.sous_chapitre__c.getDescribe().getPicklistValues();
        map<String,String> MApToLabel = new map<String,String>();
        for (Schema.PicklistEntry pe : PicklistEntries){
            MapToLabel.put(pe.getValue(),pe.getLabel().right(pe.getLabel().length()-6));
        }        

        list<id>ListIdAffaire = new list<id>();
        for(VIAutorisation_depense__c ad:listAd) {
            ListIdAffaire.add(ad.Code_Affaire__c );
        }
        map<id,string>MapNomAffaire = new map<id,string>();
        for(VIAffaire__c Aff : [SELECT id, name, Code_commande_Nom_affaire__c 
                                  FROM VIAffaire__c
                                WHERE id in :ListIdAffaire]) {
            MapNomAffaire.put(aff.id, aff.Code_commande_Nom_affaire__c);
        }
        
        for(VIAutorisation_depense__c ad:listAd) {
            if(ad.libelle__c==null) {
                
                if(ad.sous_chapitre__c=='00-00') {
                    ad.libelle__c=MapNomAffaire.get(ad.Code_Affaire__c );
                } else {
                    ad.libelle__c=MapToLabel.get(ad.sous_chapitre__c);
                }
            }
        }
        
        
        
    }
}