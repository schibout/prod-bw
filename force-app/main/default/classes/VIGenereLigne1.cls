/*
*
*  We have to launch the ecritures de contrepartie
*
*
*  for running by hand : 
 VIGenereLigne1 v = new VIGenereLigne1('B071995TEST','1');
 v.execute(null);
*
*  for running every hour at xx:16
     VIGenereLigne1 m = new VIGenereLigne1();
     String sch = '0 16 * * * ?';
     String jobID = system.schedule('VIGenereLigne1', sch, m);
*
*
*/
global class VIGenereLigne1 implements Schedulable,Database.Batchable<sObject>,Database.Stateful{

    Global double num_record = 0;
    Global String IDLog ='';    
    Global Integer CurrentYear ; 
    private VIPeriode__c Periode_Ouverte ;
    private VIPeriode__c Periode_derniere ;
    
    private VIType_de_depense__c tdMo;
    private VIType_de_depense__c tdODH;    
    private VIType_de_depense__c tdODF;    
    private VIType_de_depense__c tdODS;    
    private VIType_de_depense__c tdPFG;        
    private VIType_de_depense__c tdMAT;        

    Private Map<string, list<double>>MapTotaux  = new Map<string, list<double>>();
    Private Map<string, VICentre_section__c>MapCentre    = new Map<string, VICentre_section__c>();    
    Private Map<string, VIType_de_depense__c>MapDepense  = new Map<string, VIType_de_depense__c>();        
    Private Map<string, VICentre_section__c>MapCentre3    = new Map<string, VICentre_section__c>();    
    Private Map<string, VIType_de_depense__c>MapDepense3  = new Map<string, VIType_de_depense__c>();        
    Private Map<string, VICompte_general__c>MapCompte    = new Map<string, VICompte_general__c>();    
    
    private string AffaireAGenerer; 
    private String entite_bw ;    
    
     public VIGenereLigne1(String Param1,String Param2 ) {
        AffaireAGenerer = Param1;
        entite_bw = Param2 ; 
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VIGenereLigne1','4 Running','','Start ');

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
        
        Periode_Ouverte= [SELECT id,date_de_debut__c, date_de_fin__c, entite_bw__c
                            FROM VIPeriode__c
                           WHERE statut__c=:VIConstant.PERIODE_OUVERTE
                             AND entite_bw__c=:entite_bw];
        Periode_derniere= [SELECT id,date_de_debut__c, date_de_fin__c, entite_bw__c
                            FROM VIPeriode__c
                           WHERE statut__c=:VIConstant.PERIODE_DERNIERE
                             AND entite_bw__c=:entite_bw];

       if(Periode_Ouverte.date_de_debut__c.year()!=Periode_derniere.date_de_debut__c.year())  
           Periode_derniere=null ;

        entite_bw='1';
        
        string query = 'SELECT id, name,type_imputation__c,Date_de_fin_de_garantie__c   ';        
        query = query+'   FROM VIaffaire__c  ';        
        query = query+'  WHERE (Date_de_fin_de_garantie__c >='+string.valueof(Periode_Ouverte.date_de_debut__c).left(10)+' or Date_de_fin_de_garantie__c=null) ';      
        query = query+'    AND name Like \''+AffaireAGenerer+'%\'  ';  
        query = query+'    AND entite_bw__c =\''+entite_bw+'\'';
        //query = query+'    AND Produit_SousDomaine__r.name=\'LOC\'';
        
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
        for(VIPointage__c po:[SELECT id, name,affaire__c,
                                  Centre_Section__c, Sous_chapitre__c ,
                                  Heures__c , debours__c, PRI__c, complet__c
                             FROM VIPointage__c
                            WHERE affaire__c in :listidAffaire
                              AND Periode_comptable__r.id=:Periode_ouverte.id]) {
            VIAffaire__c aff = MapAffaire.get(po.affaire__c);
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
                  Compte_general__c=MapCompte.get('920100').id,
                  Sous_Chapitre__c ='00-00',
                  cas__c=1,
                  Periode_comptable__c=Periode_ouverte.id);
               ListInsertLD.add(EC);

            
               // On va totaliser dans la mapTotaux pour les écrire en pied
               list<double>ListTotaux = new list<double>();
                string key=po.centre_section__c+';'+tdODH.id;  // Centre et type
                if(MapTotaux.containsKey(key)) {
                    ListTotaux = MapTotaux.get(key) ;
                } else {
                    ListTotaux.add(0); 
                    ListTotaux.add(0); 
                    ListTotaux.add(0);                
                    ListTotaux.add(0);                               
                }
                ListTotaux[0]=ListTotaux[0]+po.Heures__c ;            
                ListTotaux[1]=ListTotaux[1]+po.Debours__c ;
                ListTotaux[2]=ListTotaux[2]+po.PRI__c ;
                ListTotaux[3]=ListTotaux[3]+po.Complet__c  ; 
                MapTotaux.put(key,ListTotaux);
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
                  K3__c=0  ,
                  Compte_general__c=MapCompte.get('920100').id,
                  Sous_Chapitre__c ='00-00',
                  cas__c=2,
                  Periode_comptable__c=Periode_ouverte.id);
               ListInsertLD.add(EC);

            
               // On va totaliser dans la mapTotaux pour les écrire en pied
               list<double>ListTotaux = new list<double>();
                string key=po.centre_section__c+';'+tdODH.id;  // Centre et type
                if(MapTotaux.containsKey(key)) {
                    ListTotaux = MapTotaux.get(key) ;
                } else {
                    ListTotaux.add(0); 
                    ListTotaux.add(0); 
                    ListTotaux.add(0);                
                    ListTotaux.add(0);                               
                }
                ListTotaux[0]=ListTotaux[0]+po.Heures__c ;            
                ListTotaux[1]=ListTotaux[1]+po.Debours__c ;
                ListTotaux[2]=ListTotaux[2]+po.PRI__c ;
                ListTotaux[3]=0  ; 
                MapTotaux.put(key,ListTotaux);

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
                  frais_generaux__c=0 ,
                  K3__c=0  ,
                  Compte_general__c=MapCompte.get('920100').id,
                  Sous_Chapitre__c ='00-00',
                  cas__c=3,
                  Periode_comptable__c=Periode_ouverte.id);
               ListInsertLD.add(EC);

            
               // On va totaliser dans la mapTotaux pour les écrire en pied
               list<double>ListTotaux = new list<double>();
                string key=po.centre_section__c+';'+tdODH.id;  // Centre et type
                if(MapTotaux.containsKey(key)) {
                    ListTotaux = MapTotaux.get(key) ;
                } else {
                    ListTotaux.add(0); 
                    ListTotaux.add(0); 
                    ListTotaux.add(0);                
                    ListTotaux.add(0);                               
                }
                ListTotaux[0]=ListTotaux[0]+po.Heures__c ;            
                ListTotaux[1]=ListTotaux[1]+po.Debours__c ;
                ListTotaux[2]=0 ;
                ListTotaux[3]=0  ; 
                MapTotaux.put(key,ListTotaux);

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
                              AND Periode_comptable__r.id=:Periode_ouverte.id
                              AND Origine__c='SQL-SERVER-Facture-Fournisseur']) {
            VIAffaire__c aff = MapAffaire.get(ac.affaire__c);
            if(aff.type_imputation__c=='4') {
                // Cas 4    
                system.debug('ac.CompteGeneral__c  '+ac.CompteGeneral__c );
                system.debug('MapCompte '+MapCompte);
                system.debug('Map '+MapCompte.get(ac.CompteGeneral__c ).id);
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
                  Periode_comptable__c=Periode_ouverte.id);
               ListInsertLD.add(EC);

            
               // On va totaliser dans la mapTotaux pour les écrire en pied
               list<double>ListTotaux = new list<double>();
                string key=ac.centre_section__c+';'+tdODf.id;  // Centre et type
                if(MapTotaux.containsKey(key)) {
                    ListTotaux = MapTotaux.get(key) ;
                } else {
                    ListTotaux.add(0); 
                    ListTotaux.add(0); 
                    ListTotaux.add(0);                
                    ListTotaux.add(0);                               
                }
                ListTotaux[0]=0 ;            
                ListTotaux[1]=ListTotaux[1]+ac.ComptabiliseD__c ;
                ListTotaux[2]=ListTotaux[2]+ac.ComptabiliseI__c ;
                ListTotaux[3]=ListTotaux[3]+ac.ComptabiliseC__c ; 
                MapTotaux.put(key,ListTotaux);
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
                              AND Periode_comptable__r.id=:Periode_ouverte.id
                              AND Origine__c='Mvt_stock']) {
            VIAffaire__c aff = MapAffaire.get(ac.affaire__c);
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
                  Periode_comptable__c=Periode_ouverte.id);
               ListInsertLD.add(EC);

            
               // On va totaliser dans la mapTotaux pour les écrire en pied
               list<double>ListTotaux = new list<double>();
                string key=ac.centre_section__c+';'+tdODS.id;  // Centre et type
                if(MapTotaux.containsKey(key)) {
                    ListTotaux = MapTotaux.get(key) ;
                } else {
                    ListTotaux.add(0); 
                    ListTotaux.add(0); 
                    ListTotaux.add(0);                
                    ListTotaux.add(0);                               
                }
                ListTotaux[0]=0 ;            
                ListTotaux[1]=0 ;
                ListTotaux[2]=ListTotaux[2]+ac.ComptabiliseI__c ;
                ListTotaux[3]=ListTotaux[3]+ac.ComptabiliseC__c ; 
                MapTotaux.put(key,ListTotaux);
            } else  if(aff.type_imputation__c=='4' && ac.type_depense__c==tdPFG.id) {
                // Cas 6    
                VILigneDetaille__c EC = new VILigneDetaille__c (
                  type_de_depense__c=ac.type_depense__c,
                  Sens__c='D',
                  Centre_Section__c =ac.centre_section__c,
                  affaire__c=aff.id,
                  code_affaire__c=aff.name, 
                  nombre__c = 0 ,
                  debours__c=ac.ComptabiliseD__c  ,
                  frais_generaux__c=0,
                  K3__c=ac.ComptabiliseC__c  ,
                  Compte_general__c=MapCompte.get('903000' ).id,
                  Sous_Chapitre__c =ac.Sous_Chapitre__c,
                  cas__c=6,
                  Periode_comptable__c=Periode_ouverte.id);
               ListInsertLD.add(EC);

            
               // On va totaliser dans la mapTotaux pour les écrire en pied
               list<double>ListTotaux = new list<double>();
                string key=ac.centre_section__c+';'+tdODS.id;  // Centre et type
                if(MapTotaux.containsKey(key)) {
                    ListTotaux = MapTotaux.get(key) ;
                } else {
                    ListTotaux.add(0); 
                    ListTotaux.add(0); 
                    ListTotaux.add(0);                
                    ListTotaux.add(0);                               
                }
                ListTotaux[0]=0 ;            
                ListTotaux[1]=0 ;
                ListTotaux[2]=0 ;
                ListTotaux[3]=ListTotaux[3]+ac.ComptabiliseC__c ; 
                MapTotaux.put(key,ListTotaux);

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
                  frais_generaux__c=0,
                  K3__c=ac.ComptabiliseC__c ,
                  Compte_general__c=MapCompte.get('903000' ).id,
                  Sous_Chapitre__c =ac.Sous_Chapitre__c,
                  cas__c=7,
                  Periode_comptable__c=Periode_ouverte.id);
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
                  frais_generaux__c=0,
                  K3__c=0 ,
                  Compte_general__c=MapCompte.get('903000' ).id,
                  Sous_Chapitre__c =ac.Sous_Chapitre__c,
                  cas__c=8,
                  Periode_comptable__c=Periode_ouverte.id);
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
                  K3__c=ac.ComptabiliseC__c  ,
                  Compte_general__c=MapCompte.get('903000' ).id,
                  Sous_Chapitre__c =ac.Sous_Chapitre__c,
                  cas__c=6,
                  Periode_comptable__c=Periode_ouverte.id);
               ListInsertLD.add(EC);

            
               // On va totaliser dans la mapTotaux pour les écrire en pied
               list<double>ListTotaux = new list<double>();
                string key=ac.centre_section__c+';'+tdODS.id;  // Centre et type
                if(MapTotaux.containsKey(key)) {
                    ListTotaux = MapTotaux.get(key) ;
                } else {
                    ListTotaux.add(0); 
                    ListTotaux.add(0); 
                    ListTotaux.add(0);                
                    ListTotaux.add(0);                               
                }
                ListTotaux[0]=0 ;            
                ListTotaux[1]=0 ;
                ListTotaux[2]=ListTotaux[2]+ac.ComptabiliseI__c ;
                ListTotaux[3]=ListTotaux[3]+ac.ComptabiliseC__c ; 
                MapTotaux.put(key,ListTotaux);

            }       
                                  
        }
        
              
        
        // Delete previous existing lines
        list<VILigneDetaille__c>ListLD=[SELECT id 
                                          FROM VILigneDetaille__c
                                         WHERE affaire__c in :ListidAffaire 
                                           AND Periode_comptable__c=:Periode_ouverte.id];
        delete ListLD ;

        // Bring back existing lines 
        list< VILigne_comptable__c >ListLC= [SELECT id, name, Affaire__c , Affaire__r.name,Affaire_de_rattachement__c ,
                                                    CompteComptable_local__c ,
                                                    Libelle__c,
                                                    centre__c,Type_de_depense__c ,
                                                    chapitre__c, Sous_Chapitre__c ,
                                                    sens__c,montant__c
                                               FROM VILigne_comptable__c 
                                              WHERE Affaire_de_rattachement__c in :ListIDAffaire
                                                AND Periode_comptable__c =:periode_ouverte.id
                                                AND statut_ecriture_comptable__c='40'];
        for(VILigne_comptable__c lc : ListLC) {
            string Centre =null;
            if(MapCentre3.containskey(lc.centre__c))
                centre=MapCentre3.get(lc.centre__c).id ;  

            string Depense =null;
            if(MapDepense3.containskey(lc.Type_de_depense__c))
                Depense=MapDepense3.get(lc.Type_de_depense__c).id ;  

            VILigneDetaille__c EC = new VILigneDetaille__c (
                  Sens__c=lc.sens__c,
                  affaire__c=lc.Affaire_de_rattachement__c,
                  code_affaire__c=lc.affaire__r.name, 
                  Centre_Section__c = centre,
                  Type_de_depense__c = depense,
                  nombre__c = 0,
                  debours__c=lc.montant__c  ,
                  frais_generaux__c=0   , 
                  K3__c=0  , 
                  Compte_general__c=lc.CompteComptable_local__c,
                  Sous_Chapitre__c =lc.sous_chapitre__c,
                  cas__c=10,
                  libelle__c=lc.libelle__c,
                  Periode_comptable__c=Periode_ouverte.id);

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
                
        insert ListInsertLD;     
        IDLog=VIUtils.LogWrite('VIGenereLigne1 zz '+ListInsertLD.size(),'1 Normal',null,'End '+num_record);
        
    }

    global void finish(Database.BatchableContext BC){

        // Delete previous existing lines
        list<VILigneDetaille__c>ListLD=[SELECT id 
                                          FROM VILigneDetaille__c
                                         WHERE affaire__c =null 
                                           AND Periode_comptable__c=:Periode_ouverte.id];
        delete ListLD ;


        list<VILigneDetaille__c >ListInsertLD1 = new list<VILigneDetaille__c >();
        
        for(string key : MapTotaux.keyset()) {
            list<string>LKey = key.split(';');
            list<double>ListD = new list<double>();
            ListD = MapTotaux.get(key) ;
            for(integer i=0; i<=2; i++) {
                VILigneDetaille__c EC = new VILigneDetaille__c (
                    type_de_depense__c=Lkey[1],
                    Sens__c='C',
                    Centre_Section__c =Lkey[0],
                    code_affaire__c='9'+MapCentre.get(Lkey[0]).name.left(3),
                    nombre__c = 0 ,
                    debours__c=0  ,
                    frais_generaux__c=0  , 
                    K3__c=0, 
                    Sous_Chapitre__c ='00-00',
                    cas__c=0 ,
                    Periode_comptable__c=Periode_ouverte.id);
                if(i==0) {
                    EC.debours__c=listD[1];
                    EC.compte_general__c=MapCompte.get('920100').id;
                } else if(i==1) {
                    EC.frais_generaux__c=listD[2];
                    EC.compte_general__c=MapCompte.get('930100').id;
                } else if(i==2) {
                    EC.k3__c=listD[3];
                    EC.compte_general__c=MapCompte.get('940100').id;
                }  

                if(EC.debours__c!=0 || EC.frais_generaux__c!=0 || EC.K3__c!=0 )
                    ListInsertLD1.add(EC);
            }
        }
        
        upsert ListInsertLD1;


        IDLog=VIUtils.LogWrite('VIGenereLigne1','1 Normal',IDLog,'End '+num_record);
    }

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VIGenereLigne1(AffaireAGenerer,entite_bw),VIGenereLigne1.NBR_LOT);
    }

    public static final integer NBR_LOT =100;    
    
}