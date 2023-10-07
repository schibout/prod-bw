/*
*
*  We have to launch the ecritures de contrepartie
*
*
*  for running by hand : 
 VIBatchGenereLigneDet v = new VIBatchGenereLigneDet('','1','202103');
 v.execute(null);
*
*  for running every hour at xx:16
     VIBatchGenereLigneDet m = new VIBatchGenereLigneDet();
     String sch = '0 16 * * * ?';
     String jobID = system.schedule('VIBatchGenereLigneDet', sch, m);
*
*
*/
global class VIBatchGenereLigneDet implements Schedulable,Database.Batchable<sObject>,Database.Stateful{

    Global double num_record = 0;
    Global String IDLog ='';    
    Global Integer CurrentYear ; 
    private VIPeriode__c Periode ;
    private VIEntiteBW__c Ebw ; 
    
    private VIType_de_depense__c tdMo;
    private VIType_de_depense__c tdODH;    
    private VIType_de_depense__c tdODF;    
    private VIType_de_depense__c tdODS;    
    private VIType_de_depense__c tdPFG;        
    private VIType_de_depense__c tdMAT;        

    Private Map<string, list<decimal>>MapTotaux  = new Map<string, list<decimal>>();
    Private Map<string, VICentre_section__c>MapCentre    = new Map<string, VICentre_section__c>();    
    Private Map<string, VIType_de_depense__c>MapDepense  = new Map<string, VIType_de_depense__c>();        
    Private Map<string, VICentre_section__c>MapCentre3    = new Map<string, VICentre_section__c>();    
    Private Map<string, VIType_de_depense__c>MapDepense3  = new Map<string, VIType_de_depense__c>();        
    Private Map<string, VICompte_general__c>MapCompte    = new Map<string, VICompte_general__c>();    
    Private Map<String, VITauxIncorporation__c>MapTauxIncorporation = new Map<String,VITauxIncorporation__c>();
    
    private string AffaireAGenerer; 
    private String entite_bw ;    
    
     public VIBatchGenereLigneDet(String Param1,String Param2 ) {
        AffaireAGenerer = Param1;
        entite_bw = Param2 ; 
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VIBatchGenereLigneDet','4 Running','','Start ');
        
        Ebw=  [SELECT id,name, ID_Affaire_location__c, Entite_bw__c, CurrencyIsoCode,
                      Compte_loc_AMP_local__c,            Compte_loc_AMP_Groupe__c,
                      Compte_loc_EMM_local__c,            Compte_loc_EMM_Groupe__c,
                      Compte_loc_FOL_local__c,            Compte_loc_FOL_Groupe__c                            
                 FROM VIentiteBW__c
                WHERE entite_bw__c = :entite_bw];
        
        for(VICentre_section__c centre : [SELECT id, name 
                                            FROM  VICentre_section__c]) {
            MapCentre.put(centre.id, centre) ;
            MapCentre3.put(centre.name.left(3), centre) ;                                                
        }
        for(VIType_de_depense__c depense : [SELECT id, name 
                                              FROM  VIType_de_depense__c]) {
            MapDepense.put(depense.name, depense) ;
            MapDepense3.put(depense.name.left(3), depense) ;
                                                  
            if(depense.name.left(3)=='MO ') 
                tdMo=depense ; 
            if(depense.name.left(3)=='ODH') 
                tdODH=depense ; 
            if(depense.name.left(3)=='ODF') 
                tdODF=depense ; 
            if(depense.name.left(3)=='ODS') 
                tdODS=depense ; 
            if(depense.name.left(3)=='PFG') 
                tdPFG=depense ; 
            if(depense.name.left(3)=='MAT') 
                tdMAT=depense ; 
        }
        for(VICompte_general__c compte : [SELECT id, name 
                                            FROM  VICompte_general__c]) {
            MapCompte.put(compte.name, compte) ;
            
        }
        
        Periode= [SELECT id,date_de_debut__c, date_de_fin__c, entite_bw__c, name
                            FROM VIPeriode__c
                           WHERE statut__c=:VIConstant.PERIODE_OUVERTE
                             AND entite_bw__c=:entite_bw];

        entite_bw='1';



        for(VITauxIncorporation__c t:[SELECT id,entite_bw__c, CurrencyIsoCode,Date_de_debut__c,Date_de_fin__c,
                                             Produit_SousDomaine__c  , Type_de_depense__c ,
                                             Taux_PRI__c , Taux_complet__c   
                                        FROM VITauxIncorporation__c
                                       WHERE CurrencyIsoCode=:ebw.CurrencyIsoCode
                                         AND date_de_debut__c<=:periode.date_de_debut__c
                                         AND date_de_fin__c>=:periode.date_de_debut__c ]) {
              MapTauxIncorporation.put(t.Produit_SousDomaine__c+'/'+t.Type_de_depense__c,t);
         }
        
        
        
        
        // Delete previous existing lines
        list<VILigneDetaille__c>ListLD=[SELECT id 
                                          FROM VILigneDetaille__c
                                         WHERE affaire__r.type_imputation__c!='4'
                                           AND Periode_comptable__c=:Periode.id];
        delete ListLD ;
        
        
        string query = 'SELECT id, name,type_imputation__c,Date_de_fin_de_garantie__c,Produit_SousDomaine__c   ';        
        query = query+'   FROM VIaffaire__c  ';        
        query = query+'  WHERE (Date_de_fin_de_garantie__c >='+string.valueof(Periode.date_de_debut__c).left(10);
        query = query+'         or Date_de_fin_de_garantie__c=null ';      
        query = query+'         or Date_max_mouvement__c>='+string.valueof(Periode.date_de_debut__c).left(10)+')';              
    //    query = query+'  WHERE (Date_de_fin_de_garantie__c >=2021-01-01 or Date_de_fin_de_garantie__c=null) ';  
        if(AffaireAGenerer=='!9')  {
            query = query+'    AND (not (name Like \'9%\'))  ';              
        } else {
            query = query+'    AND name Like \''+AffaireAGenerer+'%\'  ';  
        }
        query = query+'    AND entite_bw__c =\''+entite_bw+'\'';
        //query = query+'    AND name=\'B89875\' ';
        query = query+' order by name asc ';
        
        system.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<VIaffaire__c> scope){
        list<VILigneDetaille__c >ListInsertLD = new list<VILigneDetaille__c >();
        list<id>ListidAffaire = new List<Id>();
        map<id,VIAffaire__c>MapAffaire = new map<id,VIAffaire__c>();

        
        
        for(VIaffaire__c aff : scope) {
            ListidAffaire.add(aff.id);
            MapAffaire.put(aff.id,aff);
        }
/***************************************
*
*       Traitement de pointage  
*
****************************************/
        for(VIPointage__c po:[SELECT id, name,affaire__c,affaire__r.name,
                                  Centre_Section__c,Centre_Section__r.name, Sous_chapitre__c ,
                                  Heures__c , debours__c, PRI__c, complet__c,Calcul_retroactif__c
                             FROM VIPointage__c
                            WHERE affaire__c in :listidAffaire
                             // AND Calcul_retroactif__c=false
                              AND Periode_comptable__r.id=:Periode.id]) {
            VIAffaire__c aff = MapAffaire.get(po.affaire__c);
            
            po.debours__c = po.debours__c.setscale(2);
            po.PRI__c     = po.PRI__c.setscale(2);
            po.complet__c = po.complet__c.setscale(2);                                  
                                  

            string Compte_general ; 
            //if(po.Calcul_retroactif__c) {
            //    compte_general=null;
            //} else {
                Compte_general=MapCompte.get('920100').id;
            //}
                                  
            if(aff.type_imputation__c=='4') {
                // Cas 1    
                VILigneDetaille__c EC = new VILigneDetaille__c (
                  type_de_depense__c=tdMo.id,
                  Sens__c='D',
                  Centre_Section__c =po.centre_section__c,
                  affaire__c=aff.id,
                  code_affaire__c=aff.name, 
                  nombre__c = po.Heures__c ,
                  debours__c=po.debours__c  ,
                  frais_generaux__c=po.Pri__c ,
                  K3__c=po.complet__c  ,
                  Compte_general__c=Compte_general,
                  Sous_Chapitre__c =po.Sous_chapitre__c,
                  cas__c=1,
                  Periode_comptable__c=Periode.id);
               ListInsertLD.add(EC);
               totalisation (po.centre_section__c+';'+tdODH.id,'920100', po.Heures__c , po.Debours__c , '930100', (po.pri__c - po.Debours__c),'940100', (po.complet__c - po.pri__c) );                
                

            }  else if(aff.type_imputation__c=='8') {
                // Cas 2   
                VILigneDetaille__c EC = new VILigneDetaille__c (
                  type_de_depense__c=tdMo.id,
                  Sens__c='D',
                  Centre_Section__c =po.centre_section__c,
                  affaire__c=aff.id,
                  code_affaire__c=aff.name, 
                  nombre__c = po.Heures__c ,
                  debours__c=po.debours__c  ,
                  frais_generaux__c=po.Pri__c ,
                  K3__c= po.pri__c, 
                  Compte_general__c=compte_general,
                  Sous_Chapitre__c =po.Sous_chapitre__c,
                  cas__c=2,
                  Periode_comptable__c=Periode.id);
               ListInsertLD.add(EC);
               totalisation (po.centre_section__c+';'+tdODH.id,'920100', po.Heures__c , po.Debours__c , '930100', (po.pri__c - po.Debours__c),'940100', (po.pri__c - po.pri__c) );                
                

            }  else if(aff.type_imputation__c=='1' || aff.type_imputation__c=='2' || aff.type_imputation__c=='3' ||
                       aff.type_imputation__c=='7' || aff.type_imputation__c=='9') {
                // Cas 3    
                           
                VILigneDetaille__c EC = new VILigneDetaille__c (
                  type_de_depense__c=tdMo.id,
                  Sens__c='D',
                  Centre_Section__c =po.centre_section__c,
                  affaire__c=aff.id,
                  code_affaire__c=aff.name, 
                  nombre__c = po.Heures__c ,
                  debours__c=po.debours__c  ,
                  frais_generaux__c=po.PRI__c ,
                  K3__c=po.complet__c,   // modifié le 12/7 po.PRI__c  , 
                  Compte_general__c=compte_general,
                  Sous_Chapitre__c =po.Sous_chapitre__c,
                  cas__c=3,
                  Periode_comptable__c=Periode.id);
               ListInsertLD.add(EC);
               totalisation (po.centre_section__c+';'+tdODH.id,'920100', po.Heures__c , po.Debours__c , '930100', (po.pri__c - po.Debours__c),'940100', (po.complet__c - po.pri__c) );                

            } else {
                VIUtils.LogWrite('VIBatchGenereLigneDet','3 Error','','ODH po inconnu '+po.id);                
            }   
        }
        

/***************************************
*
*       Traitement de Achat
*
****************************************/
        for(VIAchat__c ac:[SELECT id, name,affaire__c,CompteGeneral__c ,
                                  Centre_Section__c, type_depense__c,  Sous_chapitre__c ,
                                  ComptabiliseD__c, ComptabiliseI__c, ComptabiliseC__c  
                             FROM VIAchat__c
                            WHERE affaire__c in :listidAffaire
                              AND Periode_comptable__r.id=:Periode.id
                              AND ComptabiliseD__c!=0
                              AND (not (CompteGeneral__c Like '2%'))
                              AND Origine__c='SQL-SERVER-Facture-Fournisseur']) {
            VIAffaire__c aff = MapAffaire.get(ac.affaire__c);
                                  
            ac.ComptabiliseD__c = ac.ComptabiliseD__c.setscale(2) ;
            ac.ComptabiliseI__c = ac.ComptabiliseI__c.setscale(2) ;
            ac.ComptabiliseC__c = ac.ComptabiliseC__c.setscale(2) ;                                  
            if(true ) {   
                // Cas 4    
                VILigneDetaille__c EC = new VILigneDetaille__c (
                  type_de_depense__c=ac.type_depense__c,
                  Sens__c='D',
                  Centre_Section__c =ac.centre_section__c,
                  affaire__c=aff.id,
                  code_affaire__c=aff.name, 
                  nombre__c = 0 ,
                  debours__c=ac.ComptabiliseD__c  ,
                  frais_generaux__c=ac.ComptabiliseI__c,
                  K3__c=ac.ComptabiliseC__c  ,
                  Compte_general__c=MapCompte.get(ac.CompteGeneral__c ).id,
                  Sous_Chapitre__c =ac.Sous_Chapitre__c,
                  cas__c=4,
                  Periode_comptable__c=Periode.id);
               ListInsertLD.add(EC);
     
                          
               totalisation (ac.centre_section__c+';'+tdODf.id,'920100', 0 , 0 , '930200', (ac.ComptabiliseI__c - ac.ComptabiliseD__c),'940200', (ac.ComptabiliseC__c - ac.ComptabiliseI__c) );            
            } else {
             //   VIUtils.LogWrite('VIBatchGenereLigneDet','3 Error','','ODF Ac inconnu '+ac.id);                
            }     

            
                                  
        }
        
/***************************************
*
*       Traitement de Mvt_stock
*
****************************************/
        for(VIAchat__c ac:[SELECT id, name,affaire__c,CompteGeneral__c ,
                                  Centre_Section__c, type_depense__c, Sous_chapitre__c ,
                                  ComptabiliseD__c, ComptabiliseI__c, ComptabiliseC__c  
                             FROM VIAchat__c
                            WHERE affaire__c in :listidAffaire
                              AND Periode_comptable__r.id=:Periode.id
                              AND (not (CompteGeneral__c Like '2%')) 
                              AND Origine__c='Mvt_stock'    ]) {
            VIAffaire__c aff = MapAffaire.get(ac.affaire__c);
                                  
            ac.ComptabiliseD__c = ac.ComptabiliseD__c.setscale(2) ;
            ac.ComptabiliseI__c = ac.ComptabiliseI__c.setscale(2) ;
            ac.ComptabiliseC__c = ac.ComptabiliseC__c.setscale(2) ;                                  
                                  
            if(aff.type_imputation__c=='4' && ac.type_depense__c==tdMAT.id) {
                // Cas 5    
                VILigneDetaille__c EC = new VILigneDetaille__c (
                  type_de_depense__c=ac.type_depense__c,
                  Sens__c='D',
                  Centre_Section__c =ac.centre_section__c,
                  affaire__c=aff.id,
                  code_affaire__c=aff.name, 
                  nombre__c = 0 ,
                  debours__c=ac.ComptabiliseD__c  ,
                  frais_generaux__c=ac.ComptabiliseI__c,
                  K3__c=ac.ComptabiliseC__c  ,
                  Compte_general__c=MapCompte.get('903000' ).id,
                  Sous_Chapitre__c =ac.Sous_Chapitre__c,
                  cas__c=5,
                  Periode_comptable__c=Periode.id);
               ListInsertLD.add(EC);

                totalisation (ac.centre_section__c+';'+tdODS.id,'920100', 0 , 0 , '930300', (ac.ComptabiliseI__c - ac.ComptabiliseD__c),'940300', (ac.ComptabiliseC__c - ac.ComptabiliseI__c) );                                              
               

            } else  if(aff.type_imputation__c=='4' && ac.type_depense__c==tdPFG.id) {
                // Cas 6    
                system.debug(' cas 6 '+Ac);
                VILigneDetaille__c EC = new VILigneDetaille__c (
                  type_de_depense__c=ac.type_depense__c,
                  Sens__c='D',
                  Centre_Section__c =ac.centre_section__c,
                  affaire__c=aff.id,
                  code_affaire__c=aff.name, 
                  nombre__c = 0 ,
                  debours__c=ac.ComptabiliseD__c  ,
                  frais_generaux__c=ac.ComptabiliseI__c ,
                  K3__c=ac.ComptabiliseC__c  ,
                  Compte_general__c=MapCompte.get('903000' ).id,
                  Sous_Chapitre__c =ac.Sous_Chapitre__c,
                  cas__c=6,
                  Periode_comptable__c=Periode.id);
               ListInsertLD.add(EC);

                totalisation (ac.centre_section__c+';'+tdODS.id,'920100', 0 , 0 , '930300', (ac.ComptabiliseI__c - ac.ComptabiliseD__c),'940300', (ac.ComptabiliseC__c - ac.ComptabiliseI__c) );                                              
               
            } else  if((aff.type_imputation__c=='1' || aff.type_imputation__c=='2' || aff.type_imputation__c=='3' || 
                        aff.type_imputation__c=='7' || aff.type_imputation__c=='8' || aff.type_imputation__c=='9')&& ac.type_depense__c==tdPFG.id) {
                // Cas 7    
                VILigneDetaille__c EC = new VILigneDetaille__c (
                  type_de_depense__c=ac.type_depense__c,
                  Sens__c='D',
                  Centre_Section__c =ac.centre_section__c,
                  affaire__c=aff.id,
                  code_affaire__c=aff.name, 
                  nombre__c = 0 ,
                  debours__c=ac.ComptabiliseD__c  ,
                  frais_generaux__c=ac.ComptabiliseI__c, 
                  K3__c=ac.ComptabiliseC__c ,
                  Compte_general__c=MapCompte.get('903000' ).id,
                  Sous_Chapitre__c =ac.Sous_Chapitre__c,
                  cas__c=7,
                  Periode_comptable__c=Periode.id);
               ListInsertLD.add(EC);

                            
            } else  if((aff.type_imputation__c=='1' || aff.type_imputation__c=='2' || aff.type_imputation__c=='3' || 
                        aff.type_imputation__c=='7'  || aff.type_imputation__c=='9')&& ac.type_depense__c==tdMAT.id) {
                // Cas 8    
                VILigneDetaille__c EC = new VILigneDetaille__c (
                  type_de_depense__c=ac.type_depense__c,
                  Sens__c='D',
                  Centre_Section__c =ac.centre_section__c,
                  affaire__c=aff.id,
                  code_affaire__c=aff.name, 
                  nombre__c = 0 ,
                  debours__c=ac.ComptabiliseD__c  ,
                  frais_generaux__c=ac.ComptabiliseI__c, // Modifié le 12/7 ac.ComptabiliseD__c,
                  K3__c=ac.ComptabiliseC__c,   // modifié le 12/7 ac.ComptabiliseD__c ,
                  Compte_general__c=MapCompte.get('903000' ).id,
                  Sous_Chapitre__c =ac.Sous_Chapitre__c,
                  cas__c=8,
                  Periode_comptable__c=Periode.id);
               ListInsertLD.add(EC);
               

            }  else  if(aff.type_imputation__c=='8' && ac.type_depense__c==tdMAT.id) {
                // Cas 9    
                VILigneDetaille__c EC = new VILigneDetaille__c (
                  type_de_depense__c=ac.type_depense__c,
                  Sens__c='D',
                  Centre_Section__c =ac.centre_section__c,
                  affaire__c=aff.id,
                  code_affaire__c=aff.name, 
                  nombre__c = 0 ,
                  debours__c=ac.ComptabiliseD__c  ,
                  frais_generaux__c=ac.ComptabiliseI__c,
                  K3__c=ac.ComptabiliseC__c , 
                  Compte_general__c=MapCompte.get('903000' ).id,
                  Sous_Chapitre__c =ac.Sous_Chapitre__c,
                  cas__c=9,
                  Periode_comptable__c=Periode.id);
               ListInsertLD.add(EC);
               totalisation (ac.centre_section__c+';'+tdODS.id,'920100', 0 , 0 , '930300', (ac.ComptabiliseI__c - ac.ComptabiliseD__c),'940300', (ac.ComptabiliseC__c - ac.ComptabiliseI__c) );                                              
               
            } else {
               
            }  
        }
        
              
        
        // Delete previous existing lines
        list<VILigneDetaille__c>ListLD=[SELECT id 
                                          FROM VILigneDetaille__c
                                         WHERE affaire__c in :ListidAffaire 
                                          AND affaire__r.type_imputation__c='4'
                                          AND Periode_comptable__c=:Periode.id];
        delete ListLD ;

        // Bring back existing lines 
        
        // pour le mois en cours, on ne doit avoir que les écritures brouillon ou les écritures définitive mais pas les deux
        Map<id,string>MapAff = new Map<id,string>(); 
        list< VILigne_comptable__c >ListLC= [SELECT id, name, Affaire__c , Affaire__r.name,Affaire_de_rattachement__c ,
                                                    CompteComptable_local__c ,CompteComptable_local__r.name ,
                                                    Affaire__r.produit_sousdomaine__c, 
                                                    Affaire__r.produit_sousdomaine__r.name, 
                                                    Libelle__c,type_ligne_comptable__c,
                                                    centre__c,Type_de_depense__c ,
                                                    chapitre__c, Sous_Chapitre__c ,
                                                    sens__c,montant__c
                                               FROM VILigne_comptable__c 
                                              WHERE (Affaire_de_rattachement__c in :ListIDAffaire )
                                                AND Periode_comptable__c=:Periode.id       
                                                AND (not (CompteComptable_local__r.name Like '2%'))   
                                                AND (not (CompteComptable_local__r.name Like '4%'))                                                                        
                                                AND CompteComptable_local__c !=null
                                                AND (//statut_ecriture_comptable__c='10' or 
                                                     statut_ecriture_comptable__c='40' or 
                                                     statut_ecriture_comptable__c='42'  
                                                    // (statut_ecriture_comptable__c='20' and Type_ligne_comptable__c='FSA') or   
                                                    // (statut_ecriture_comptable__c='30' and Type_ligne_comptable__c='FSA')   
                                                    )];
        for(VILigne_comptable__c lc : ListLC) {
            if(lc.CompteComptable_local__r.name.left(1)=='4') {
                if(MapAff.containskey(lc.Affaire__c))
                    continue ; 
            
                MapAff.put(lc.Affaire__c,'');
            }
            
            lc.montant__c = lc.montant__c.setscale(2);
            string Centre =null;
            if(MapCentre3.containskey(lc.centre__c))
                centre=MapCentre3.get(lc.centre__c).id ;  

            string Depense =null;
            if(MapDepense3.containskey(lc.Type_de_depense__c))
                Depense=MapDepense3.get(lc.Type_de_depense__c).id ;  
            
            decimal PRI =0 ; 
            decimal PRC =0 ;     
            
            if(MapTauxIncorporation.containskey(lc.Affaire__r.produit_sousdomaine__c+'/'+depense)) {
                VITauxIncorporation__c tx = MapTauxIncorporation.get(lc.Affaire__r.produit_sousdomaine__c+'/'+depense);
                PRI = lc.montant__c *  tx.Taux_PRI__c ;
                PRC = lc.montant__c *  tx.Taux_complet__c ;
            }else{
                IDLog=VIUtils.LogWrite('VIBatchGenereLigneDet','3 Error','','Taux incorporation inconnu '+lc.Type_de_depense__c+'/'+lc.Affaire__r.produit_sousdomaine__r.name);
            }
            
            

            VILigneDetaille__c EC = new VILigneDetaille__c (
                  Sens__c=lc.sens__c,
                  affaire__c=lc.Affaire__c,
                  code_affaire__c=lc.affaire__r.name, 
                  Centre_Section__c = centre,
                  Type_de_depense__c = depense,
                  nombre__c = 0,
                  debours__c=lc.montant__c ,
                  frais_generaux__c=PRI   , 
                  K3__c=PRC  , 
                  Compte_general__c=lc.CompteComptable_local__c,
                  Sous_Chapitre__c =lc.sous_chapitre__c,
                  cas__c=10,
                  libelle__c=lc.libelle__c,
                  Periode_comptable__c=Periode.id);

            if(lc.sous_chapitre__c==null || lc.sous_chapitre__c=='00')
                EC.Sous_Chapitre__c ='00-00';
            
            if(MapDepense.containskey(lc.Type_de_depense__c)) {
                  EC.type_de_depense__c=MapDepense.get(lc.Type_de_depense__c).id;    
            }
            if(MapCentre.containskey(lc.centre__c)) {
                  EC.Centre_Section__c=MapCentre.get(lc.centre__c).id;            
            }
            
            ListInsertLD.add(EC);
        }
/*        
        // On vérifie si il n'y a pas des lignes de calcul rétroactif à rajouter.
        for(VIPointage__c po:[SELECT id, name,affaire__c,affaire__r.name,
                                  Centre_Section__c,Centre_Section__r.name, Sous_chapitre__c ,
                                  Heures__c , debours__c, PRI__c, complet__c
                             FROM VIPointage__c
                            WHERE affaire__c in :listidAffaire
                              AND Calcul_retroactif__c=true
                              AND date__c=:Periode.date_de_fin__c]) {
            VIAffaire__c aff = MapAffaire.get(po.affaire__c);
            
            po.debours__c = po.debours__c.setscale(2);
            po.PRI__c     = po.PRI__c.setscale(2);
            po.complet__c = po.complet__c.setscale(2);                                  
                                  
                                  
            VILigneDetaille__c EC = new VILigneDetaille__c (
                type_de_depense__c=tdMo.id,
                Sens__c='D',
                Centre_Section__c =po.centre_section__c,
                affaire__c=aff.id,
                code_affaire__c=aff.name, 
                nombre__c = po.Heures__c ,
                debours__c=po.debours__c  ,
                frais_generaux__c=po.Pri__c ,
                K3__c=po.complet__c  ,
                Compte_general__c=null,
                Sous_Chapitre__c ='00-00',
                cas__c=20,
                Periode_comptable__c=Periode.id);
             ListInsertLD.add(EC);

        }
*/        
        //------------------
         
        // On a toutes les lignes détailées éclatées par affaire. Il faut les cumuler
        map<string,VILigneDetaille__c>MapLD = new  map<string,VILigneDetaille__c>();
        list<VILigneDetaille__c >ListinsertLDNew = new list<VILigneDetaille__c >();        
        for(VILigneDetaille__c ld : ListInsertLD) {
            string key = ld.affaire__c+'/'+ld.Centre_Section__c+'/'+ld.type_de_depense__c+'/'+ld.Compte_general__c+'/'+ld.sous_chapitre__c+'/'+ld.cas__c;
            decimal sens = 1 ; 
            if(ld.sens__c=='C') { 
                sens=-1;
            }
            if((ld.Compte_general__r.name==ebw.Compte_loc_AMP_local__c ||
                ld.Compte_general__r.name==ebw.Compte_loc_EMM_local__c ||
                ld.Compte_general__r.name==ebw.Compte_loc_FOL_local__c) && ld.Affaire__r.name=='9751') {
                    sens=-1;
            }
            
            if(!MapLD.containskey(key)) {
                ld.debours__c       =ld.debours__c        *sens;
                ld.frais_generaux__c=ld.frais_generaux__c *sens;
                ld.K3__c            =ld.K3__c             *sens;                
                MapLd.put(key,ld);
            } else {
                VILigneDetaille__c ld1 = MapLd.get(key);
                ld1.nombre__c         = ld1.nombre__c         + ld.nombre__c ;
                ld1.debours__c        = ld1.debours__c        + (ld.debours__c * sens);                
                ld1.frais_generaux__c = ld1.frais_generaux__c + (ld.frais_generaux__c * sens) ;                
                ld1.K3__c             = ld1.K3__c             + (ld.K3__c  * sens);                
            }
        }
        for(string s : MapLd.keySet()) {
            VILigneDetaille__c ld =MapLd.get(s);
            ld.debours__c        = ld.debours__c.setScale(2);
            ld.frais_generaux__c = ld.frais_generaux__c.setScale(2);
            ld.K3__c             = ld.K3__c.setScale(2);            
            ListinsertLDNew.add(ld);
        }
        insert ListInsertLDNew;     
        
    }

    global void finish(Database.BatchableContext BC){


        list<string>ListCodeAffaire = new list<string>();
        for(string key : MapTotaux.keyset()) {
            list<string>LKey = key.split(';');
            ListCodeAffaire.add('9'+MapCentre.get(Lkey[0]).name.left(3));
        }

        Map<string,id>MapAffaire= new Map<string,id>();
        for(VIAffaire__c aff : [SELECT id, name 
                                  FROM VIAffaire__c 
                                 WHERE name in :ListCodeAffaire]) {
            MapAffaire.put(aff.name,aff.id);
        }

        list<VILigneDetaille__c >ListInsertLD1 = new list<VILigneDetaille__c >();
        list<VIAchat__c >ListInsertAchat = new list<VIAchat__c >();
        
        for(string key : MapTotaux.keyset()) {
            system.debug('key '+key);
            list<string>LKey = key.split(';');
            list<Decimal>ListD = new list<Decimal>();
            ListD = MapTotaux.get(key) ;
                string CodeAffaire = '9'+MapCentre.get(Lkey[0]).name.left(3);
            
                system.debug('Lkey[2]'+Lkey[2]);
                system.debug('MapCompte' +MapCompte.get(Lkey[2]));
            
                VILigneDetaille__c EC = new VILigneDetaille__c (
                    type_de_depense__c=Lkey[1],
                    affaire__c=MapAffaire.get(CodeAffaire),                    
                    Sens__c='C',
                    Centre_Section__c =Lkey[0],
                    code_affaire__c=CodeAffaire,
                    nombre__c = 0 ,
                    Sous_Chapitre__c ='00-00',
                    cas__c=0 ,
                    Periode_comptable__c=Periode.id,
                    compte_general__c=MapCompte.get(Lkey[2]).id,
                    debours__c=listD[1] * (-1),
                    frais_generaux__c=listD[2]  * (-1),
                    k3__c=listD[3]  * (-1));

            if(Lkey[2].startswith('92')) {
                EC.frais_generaux__c = listD[1] * (-1) ;
                EC.k3__c = listD[1] * (-1) ;                
            }
            if(Lkey[2].startswith('93')) {
                EC.k3__c = listD[2] * (-1) ;                
            }
            
            EC.debours__c        = EC.Debours__c.setScale(2);
            EC.frais_generaux__c = EC.frais_generaux__c.setScale(2);
            EC.k3__c             = EC.k3__c.setScale(2);            
            
                VIAchat__c ac = new VIAchat__c (  
                    name=periode.name+'-'+CodeAffaire+'-'+Lkey[1],
                    affaire__c=MapAffaire.get(CodeAffaire),                                        
                    centre_section__c=Lkey[0] ,
                    sous_chapitre__c='00-00',
                    Description_de_la_commande__c ='Contrepartie',
                    CommandeD__c=0,
                    ComptabiliseD__c =listD[1],
                    ComptabiliseI__c =listD[2],                    
                    ComptabiliseC__c =listD[3],                                        
                    CompteGeneral__c ='920100',
                    Date__c =periode.date_de_fin__c,
                    Date_de_comptabilisation__c  =periode.date_de_fin__c,  
                    Nom_du_fournisseur__c ='',
                    Num_cde__c ='',
                    Num_frn__c ='',
                    Num_fac__c ='',    
                    Origine__c='Contrepartie',
                    type_depense__c=Lkey[1],                    
                    TypeOda__c =''
                );
            
                if(EC.debours__c!=0 || EC.frais_generaux__c!=0 || EC.K3__c!=0 ) {
                    ListInsertLD1.add(EC);
                    ListInsertAchat.add(ac);                    
                }

                system.debug('ec '+ec);
                    
/*
            for(integer i=0; i<=2; i++) {
                if(i==0) {
                    EC.debours__c=listD[1] * (-1); 
                    EC.compte_general__c=MapCompte.get('920100').id;
                } else if(i==1) {
                    EC.frais_generaux__c=listD[2]  * (-1);
                    //EC.compte_general__c=MapCompte.get('930100').id;
                } else if(i==2) {
                    EC.k3__c=listD[3]  * (-1);
                    //EC.compte_general__c=MapCompte.get('940100').id;
                }  
                system.debug('ec '+ec);
                if(EC.debours__c!=0 || EC.frais_generaux__c!=0 || EC.K3__c!=0 )
                    ListInsertLD1.add(EC);
            }
*/
        }
        delete [SELECT id 
                  FROM Viachat__c 
                 WHERE periode_comptable__c=:Periode.id
                   AND Origine__c='Contrepartie'] ; 
        
        upsert ListInsertLD1;

        if(!test.isrunningtest())
            insert ListInsertAchat ;


        IDLog=VIUtils.LogWrite('VIBatchGenereLigneDet','1 Normal',IDLog,'End '+num_record);
        //Database.executeBatch(new VISchedGenereCentralis1(),VISchedGenereCentralis1.NBR_LOT()); 
        
    }

    global void execute(SchedulableContext scon) {
        //if(AffaireAGenerer=='') {
            //Database.executeBatch(new VIBatchGenereLigneDet('9',entite_bw),4);  
            //Database.executeBatch(new VIBatchGenereLigneDet('!9',entite_bw),VIBatchGenereLigneDet.NBR_LOT);              
        //} else {
            Database.executeBatch(new VIBatchGenereLigneDet(AffaireAGenerer,entite_bw),VIBatchGenereLigneDet.NBR_LOT);
        //} 
    }

    public static final integer NBR_LOT =300;   
    
    
    public void totalisation (string key,string cptD, decimal heures, decimal debours, string cptI, decimal PRI, string cptC, decimal complet ) {

        debours = debours.setScale(2);
        PRI     = PRI.setScale(2);
        complet = complet.setScale(2);
        
        if(cptD!=null) {
            list<decimal>ListTotauxD = new list<decimal>();
            string KeyD = key+';'+cptD ; 
            if(MapTotaux.containsKey(KeyD)) {
                ListTotauxD = MapTotaux.get(keyD) ;
            } else {
                ListTotauxD.add(0); 
                ListTotauxD.add(0); 
                ListTotauxD.add(0);                
                ListTotauxD.add(0);                               
            }
            ListTotauxD[0]=ListTotauxD[0]+(Heures==null  ? 0 : Heures) ;            
            ListTotauxD[1]=ListTotauxD[1]+(debours==null ? 0 :  debours); 
            ListTotauxD[2]=ListTotauxD[2] ; 
            ListTotauxD[3]=ListTotauxD[3];  
            MapTotaux.put(keyD,ListTotauxD);
        }

        if(cptI!=null) {        
            list<decimal>ListTotauxI = new list<decimal>();
            string KeyI = key+';'+cptI ;             
            if(MapTotaux.containsKey(keyI)) {
                ListTotauxI = MapTotaux.get(keyI) ;
            } else {
                ListTotauxI.add(0); 
                ListTotauxI.add(0); 
                ListTotauxI.add(0);                
                ListTotauxI.add(0);                               
            }    
            ListTotauxI[0]=ListTotauxI[0] ;            
            ListTotauxI[1]=ListTotauxI[1] ; 
            ListTotauxI[2]=ListTotauxI[2]+(PRI == null ? 0 : PRI) ; 
            ListTotauxI[3]=ListTotauxI[3];  
            MapTotaux.put(keyI,ListTotauxI);
        }

        if(cptC!=null) {                
            list<decimal>ListTotauxC = new list<decimal>();
            string KeyC = key+';'+cptC ;                         
            if(MapTotaux.containsKey(keyC)) {
                ListTotauxC = MapTotaux.get(keyC) ;
            } else {
                ListTotauxC.add(0); 
                ListTotauxC.add(0); 
                ListTotauxC.add(0);                
                ListTotauxC.add(0);                               
            }
            ListTotauxC[0]=ListTotauxC[0] ;            
            ListTotauxC[1]=ListTotauxC[1] ; 
            ListTotauxC[2]=ListTotauxC[2] ; 
            ListTotauxC[3]=ListTotauxC[3]+(complet==null ? 0 : complet);  
            MapTotaux.put(keyC,ListTotauxC);
        }    
    }
    
}