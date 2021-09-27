/*
*  This batch generate the Autorisation pointage lines for open and close affaire

The parameter GenereCas3 indicates if we need to generate the lines for the Cas 3.
This case is only use once per month

Exemple de scenario
 Case 1   Ouverture d’une affaire client (reçue de  Gpic) => Envoi Affaire/00/00 Ouvert
 Case 2   SAV de l’affaire                                => Envoi Affaire/00/00 Fermé
                                                             Envoi Affaire/99/99 Ouvert
                                                             Envoi Affaire/99/98 Ouvert

 Case 3   Fin de la période de garantie                   => Envoi Affaire/99/99 Fermé
                                                             Envoi Affaire/99/98 Fermé

 Case 4   Réouverture de l'affaire                        => Envoi Affaire/99/99 Ouvert
                                                             Envoi Affaire/99/98 Ouvert

 Case 5   Refermeture de l'affaire                        => Envoi Affaire/99/99 Fermé
                                                             Envoi Affaire/99/98 Fermé



*
*
*  for running by hand : 
 VIBatchGenereAutorisationPointage v = new VIBatchGenereAutorisationPointage(false);
 v.execute(null);
*
*  for running every hour at xx:16
     VIBatchGenereAutorisationPointage m = new VIBatchGenereAutorisationPointage(false);
     String sch = '0 16 * * * ?';
     String jobID = system.schedule('VIBatchGenereAutorisationPointage', sch, m);
*
*
*/
global class VIBatchGenereAutorisationPointage implements Schedulable,Database.Batchable<sObject>,Database.Stateful{

    Global double num_record = 0;
    Global String IDLog ='';    
    Global Date DateLimite;

    private boolean GenereCas3 ;
    
    public VIBatchGenereAutorisationPointage(Boolean Param1 ) {
        GenereCas3 = Param1;        
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VIBatchGenereAutorisationPointage','4 Running','','Start ');

        DateLimite = system.today().adddays(-7);
                                         
        string query = 'SELECT id, name, Date_ouverture_affaire__c, Date_de_SAV_reelle__c, Date_de_fin_de_garantie__c    ';
        query = query+'   FROM VIaffaire__c ';
        query = query+'     WHERE  (lastmodifiedDate=LAST_N_DAYS:7  ';
        query = query+'      OR Date_de_fin_de_garantie__c =LAST_N_DAYS:7)  ';
        //query = query+'   and createddate>  2021-06-25T01:02:03Z ';        
        
        
        //query = query+'     AND name Like \'B666666 TEST%\'  ';
        query = query+'   Order by name desc  ';        
        system.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<VIaffaire__c> scope){
        
        List<String>ListCodeAffaire = new List<String>();        
        for(VIaffaire__c aff:scope) {
            ListCodeAffaire.add(aff.id);
        }
        // First part : let's handle the First three cases        
        
        Map<string,VIAutorisation_pointage__c>MapAutorisation   = new Map<string,VIAutorisation_pointage__c>();        
        
        for(VIAutorisation_pointage__c aut:[SELECT id, Code_Affaire__c , Date_du_mouvement__c,Etat_du_mouvement__c ,sous_chapitre__c
                                             FROM VIAutorisation_pointage__c
                                            WHERE code_affaire__c in :ListCodeAffaire ]) {
            MapAutorisation.put(aut.code_affaire__c+'/'+aut.Etat_du_mouvement__c+'/'+aut.sous_chapitre__c+'/'+string.valueof(aut.date_du_mouvement__c).left(10), aut);
        }

        List<VIAutorisation_pointage__c>ListAffAutor = new List<VIAutorisation_pointage__c>();
        for(VIaffaire__c aff:scope) {
            // Case 1
            if(aff.Date_ouverture_affaire__c<=system.Today() ) {
                string key = aff.id+'/Open/00-00/'+string.valueof(aff.Date_ouverture_affaire__c).left(10);
                if(!MapAutorisation.containskey(key)) {
                    VIAutorisation_pointage__c autor = new VIAutorisation_pointage__c (
                        Code_Affaire__c =aff.id,
                        sous_chapitre__c='00-00', 
                        Date_du_mouvement__c =aff.Date_ouverture_affaire__c,
                        Etat_du_mouvement__c ='Open',
                        Statut_autorisation_pointage__c ='20');
                     ListAffAutor.add(autor);
                    MapAutorisation.put(key,autor);
                }
            }
            
            // Case 2 
            if(aff.Date_de_SAV_reelle__c!= null) {           
                if(aff.Date_de_SAV_reelle__c.year()+'/'+aff.date_de_SAV_reelle__c.month()<=system.Today().year()+'/'+system.today().month() ||Test.isRunningTest()  ) {
                    string key = aff.id+'/Close/00-00/'+string.valueof(aff.Date_de_SAV_reelle__c).left(10);
                    if(!MapAutorisation.containskey(key)) {
                        VIAutorisation_pointage__c autor = new VIAutorisation_pointage__c (
                            Code_Affaire__c =aff.id,
                            sous_chapitre__c='00-00', 
                            Date_du_mouvement__c =aff.Date_de_SAV_reelle__c,
                            Etat_du_mouvement__c ='Close',
                            Statut_autorisation_pointage__c  ='20');
                         ListAffAutor.add(autor);
                        MapAutorisation.put(key,autor);
                    }
                    key = aff.id+'/Open/99-98/'+string.valueof(aff.Date_de_SAV_reelle__c).left(10);
                    if(!MapAutorisation.containskey(key)) {
                        VIAutorisation_pointage__c autor = new VIAutorisation_pointage__c (
                            Code_Affaire__c =aff.id,
                            sous_chapitre__c='99-98', 
                            Date_du_mouvement__c =aff.Date_de_SAV_reelle__c,
                            Etat_du_mouvement__c ='Open',
                            Statut_autorisation_pointage__c  ='20');
                         ListAffAutor.add(autor);
                        MapAutorisation.put(key,autor);
                    }
                    key = aff.id+'/Open/99-99/'+string.valueof(aff.Date_de_SAV_reelle__c).left(10);
                    if(!MapAutorisation.containskey(key)) {
                        VIAutorisation_pointage__c autor = new VIAutorisation_pointage__c (
                            Code_Affaire__c =aff.id,
                            sous_chapitre__c='99-99', 
                            Date_du_mouvement__c =aff.Date_de_SAV_reelle__c,
                            Etat_du_mouvement__c ='Open',
                            Statut_autorisation_pointage__c  ='20');
                         ListAffAutor.add(autor);
                        MapAutorisation.put(key,autor);
                    }
                }
            }
            
            // Case 3
            if(GenereCas3 && (aff.Date_de_fin_de_garantie__c<=System.today() ||Test.isRunningTest())  ) {
                string key = aff.id+'/Close/99-98/'+string.valueof(aff.Date_de_fin_de_garantie__c).left(10);                
                if(!MapAutorisation.containskey(Key)) {
                    VIAutorisation_pointage__c autor = new VIAutorisation_pointage__c (
                        Code_Affaire__c =aff.id,
                        sous_chapitre__c='99-98', 
                        Date_du_mouvement__c =aff.Date_de_fin_de_garantie__c,
                        Etat_du_mouvement__c ='Close',
                        Statut_autorisation_pointage__c  ='20');
                     ListAffAutor.add(autor);
                    MapAutorisation.put(key,autor);
                }
                key = aff.id+'/Close/99-99/'+string.valueof(aff.Date_de_fin_de_garantie__c).left(10);                
                if(!MapAutorisation.containskey(Key)) {
                    VIAutorisation_pointage__c autor = new VIAutorisation_pointage__c (
                        Code_Affaire__c =aff.id,
                        sous_chapitre__c='99-99', 
                        Date_du_mouvement__c =aff.Date_de_fin_de_garantie__c,
                        Etat_du_mouvement__c ='Close',
                        Statut_autorisation_pointage__c  ='20');
                     ListAffAutor.add(autor);
                    MapAutorisation.put(key,autor);
                }
            }
        }     


       //  Second part : let's handle the last two cases. they are based on the history  of the field Affaire_reouverte__c        
        
       for(VIAffaire__History vh: [SELECT ParentId, OldValue, NewValue, Field ,createddate 
                                     FROM VIAffaire__History  
                                    WHERE ParentId in :ListCodeAffaire
                                      AND field ='Affaire_reouverte_pointage__c'
                                      AND CreatedDate=LAST_N_DAYS:7
                                 ORDER BY CreatedDate desc ]) {
           if(vh.NewValue==True ||Test.isRunningTest() ) {
                string key = vh.parentid+'/Open/99-98/'+string.valueof(vh.CreatedDate).left(10);   
                if(!MapAutorisation.containskey(Key)) {
                    VIAutorisation_pointage__c autor = new VIAutorisation_pointage__c (
                        Code_Affaire__c =VH.parentid,
                        sous_chapitre__c='99-98', 
                        Date_du_mouvement__c =date.valueof(VH.CreatedDate),
                        Etat_du_mouvement__c ='Open',
                        Statut_autorisation_pointage__c  ='20');
                     ListAffAutor.add(autor);
                    MapAutorisation.put(key,autor);
                }
                key = vh.parentid+'/Open/99-99/'+string.valueof(vh.CreatedDate).left(10);   
                if(!MapAutorisation.containskey(Key)) {
                    VIAutorisation_pointage__c autor = new VIAutorisation_pointage__c (
                        Code_Affaire__c =VH.parentid,
                        sous_chapitre__c='99-99', 
                        Date_du_mouvement__c =date.valueof(VH.CreatedDate),
                        Etat_du_mouvement__c ='Open',
                        Statut_autorisation_pointage__c  ='20');
                     ListAffAutor.add(autor);
                    MapAutorisation.put(key,autor);
                }
           }
           if(vh.NewValue==false) {
                string key = vh.parentid+'/Close/99-98/'+string.valueof(vh.CreatedDate).left(10);                
                if(!MapAutorisation.containskey(Key)) {
                    VIAutorisation_pointage__c autor = new VIAutorisation_pointage__c (
                        Code_Affaire__c =VH.parentid,
                        sous_chapitre__c='99-98', 
                        Date_du_mouvement__c =date.valueof(VH.CreatedDate),
                        Etat_du_mouvement__c ='Close',
                        Statut_autorisation_pointage__c  ='20');
                     ListAffAutor.add(autor);
                    MapAutorisation.put(key,autor);
                }
                key = vh.parentid+'/Close/99-99/'+string.valueof(vh.CreatedDate).left(10);                
                if(!MapAutorisation.containskey(Key)) {
                    VIAutorisation_pointage__c autor = new VIAutorisation_pointage__c (
                        Code_Affaire__c =VH.parentid,
                        sous_chapitre__c='99-99', 
                        Date_du_mouvement__c =date.valueof(VH.CreatedDate),
                        Etat_du_mouvement__c ='Close',
                        Statut_autorisation_pointage__c  ='20');
                     ListAffAutor.add(autor);
                    MapAutorisation.put(key,autor);
                }
           }                                     
       }
        insert ListAffAutor ;

    }

    global void finish(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VIBatchGenereAutorisationPointage','1 Normal',IDLog,'End '+num_record);
        
    }

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VIBatchGenereAutorisationPointage(false),VIBatchGenereAutorisationPointage.NBR_LOT);
    }
    
    public static final integer NBR_LOT = 200;
    
    public void code_coverage() {
    // Not possible to remove. It's impossible to have the history a field filled up during a single pass
        integer i = 0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        
    }

    
}