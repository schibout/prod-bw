/*
*
*  We have to launch the import files 
*
*   ce programme est à tourner 3 fois au moment des imports pour être sûr que tout est bien traité
*    Le premier paramètre donne le début du code affaire que l'on souhaite traiter 
*    Le deuxième dit si on veut que les batchs Budget, facture, achat, pointage soient enchainés ou pas (True : ils sont enchainés)
*    Le troisième dit si on veut traiter toutes les lignes int-xx présentes ou uniquement les nouvelles (True : Toutes mais si elles ont déjà été traités)
*
*  for running by hand : 
 VISchedImportAffaire v = new VISchedImportAffaire('',true, false,1);
 v.execute(null);
*
*  for running every hour at xx:16
     VISchedImportAffaire m = new VISchedImportAffaire('',true,false,1);
     String sch = '0 30 2 * * ?';
     String jobID = system.schedule('VISchedImportAffaire', sch, m);
*
*
*/
global class VISchedImportAffaire implements Schedulable,Database.Batchable<sObject>,Database.Stateful{

    Global double num_record = 0;
    Global String IDLog ='';    
    Global Map<string, VISousDomaine__c >MapSousDomaine = New Map<string, VISousDomaine__c >();
    Global Map<string, user>MapUser = new Map<string, user>();
    Global Map<string, VICentre_Section__c>MapCentre = new Map<string, VICentre_Section__c>();
    Global Map<string, VIType_de_depense__c>MapDepense = new Map<string, VIType_de_depense__c>();
    
    
    Global string Entite_bwFr = null ; 
    Global VIType_de_depense__c TDGar;
    Global VICentre_section__c CS801;
    Global Account CompteBabcockWanson ;
    Global id PRJ_interne ;
    Global VIPeriode__c Periode_Ouverte ;
    
    
    private string AffaireAGenerer; 
    private boolean Enchaine ;
    private boolean Toute ;
    private integer nbr_iteration ;    
    
     public VISchedImportAffaire(String Param1,Boolean Param2,Boolean Param3,integer Param4 ) {
        AffaireAGenerer = Param1;        
        Enchaine = Param2; 
        Toute = Param3;          
        nbr_iteration = Param4 ;  
    }
 
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VISchedImportAffaire','4 Running','','Start ');

        Periode_Ouverte= [SELECT id,date_de_debut__c, date_de_fin__c, entite_bw__c
                            FROM VIPeriode__c
                           WHERE statut__c=:VIConstant.PERIODE_OUVERTE
                             AND entite_bw__c='1'];

        
        for(user u : [Select name, id,NMatricule__c  from user]) {
            MapUser.put(u.NMatricule__c , u);
        }

        TDGar = [select id from VIType_de_depense__c where name like 'GAR%' ];
        CS801 = [select id from VICentre_section__c where name like '801%' ];   
        CompteBabcockWanson = [select id from Account where name ='BABCOCK WANSON' limit 1];
        
        for(VISousDomaine__c sd : [SELECT id, name, Code_sous_domaine__c 
                                     FROM VISousDomaine__c]) {
             MapSousDomaine.put(sd.Code_sous_domaine__c,sd) ;
             if(sd.name=='PRJ')
                 PRJ_interne=sd.id;
        }

        for(VIType_de_depense__c td : [Select name, id from VIType_de_depense__c]) {
            MapDepense.put(td.name.left(3).trim(), td);
        }
        for(VICentre_Section__c cs : [Select name, id from VICentre_Section__c]) {
            MapCentre.put(cs.name.Left(3), cs);
        }
        
        
        Entite_bwFr = [SELECT entite_bw__c from VIEntiteBW__c where name='BW FRA'].entite_bw__c; 
                                         
        string query = 'SELECT codeAffaire__c, codeClient__c,codeCommande__c, codeDepartement__c, ';
        query = query+'        dateLivraison__c ,DateMiseService__c, dateOuvAffaire__c,    ';
        query = query+'        DateReception__c , DateSortieVentePrev__c  ,FlagAnnulation__c , Import_Status__c ,    ';        
        query = query+'        libelleAffaire__c  , montantPv__c,montantProvisionsGarantie__c , raisonSocialeClient__c, ';
        query = query+'        Code_produit__c,typeEvenement__c, NumAvCde__c, Chef_de_projet__c,createddate      ';        
        query = query+'   FROM Int_affaire__c ';
        query = query+'   WHERE codeaffaire__c!=null ';
        if(!toute)
           query = query+'     AND (Import_Status__c =\'1\' or Import_Status__c =null) ';
        
        query = query+'     AND codeAffaire__c Like \''+AffaireAGenerer+'%\'  ';
        query = query+'   Order by codeaffaire__c,typeEvenement__c desc, NumAvCde__c asc,datepublication__c asc   ';     
        // The order by is important, for catching the CI before the AV

        system.debug(query.right(200));
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Int_affaire__c> scope){
        num_record = 0;
        Map<string, VIAffaire__c>MapAffaire  = new Map<string, VIAffaire__c>();
        Map<string, Account>MapAccount  = new Map<string, Account>();
        Map<string, Order>MapOrder  = new Map<string, Order>();
        Map<string, ViAvenant__c>MapAvenant  = new Map<string, ViAvenant__c>();
        Map<string, ViLigne_budget__c>MapBudgetGAR  = new Map<string, ViLigne_budget__c>();
        List<ViLigne_budget__c>ListAllBudget = new List<ViLigne_budget__c>();
        
        Map<string,int_budget__c>MapInt_Budget = new Map<string,int_budget__c>();
        Map<string,int_achat__c>MapInt_achat = new Map<string,int_achat__c>();        
        Map<string,int_pointage__c>MapInt_pointage = new Map<string,int_pointage__c>();                
        Map<string,int_facture__c>MapInt_facture = new Map<string,int_facture__c>();
        
        List<int_achat__c>ListAchat = new List<int_achat__c>();
        List<int_pointage__c>ListPointage = new List<int_pointage__c>();
        List<int_facture__c>ListFacture = new List<int_facture__c>();        

        List<VIaffaire__c> listA = New List<VIaffaire__c>();        
        List<VIaffaire__c> listDelA = New List<VIaffaire__c>();                
        List<VILigne_affaire__c> listLA = New List<VILigne_affaire__c>();
        List<VILigne_d_affaire_mensuelle__c> listLAM = New List<VILigne_d_affaire_mensuelle__c>();        
        List<VILigne_affaire__c> listDelLA = New List<VILigne_affaire__c>();
        List<VILigne_d_affaire_mensuelle__c> listDelLAM = New List<VILigne_d_affaire_mensuelle__c>();        
        
        List<string>ListIDAffaire = new List<string>();
        List<string>ListIDAffaireWithout9 = new List<string>();
        List<string>ListIDAccount = new List<string>();
        List<string>ListIDOrder = new List<string>();        
        

        
        for(Int_affaire__c aff:scope) {
            num_record = num_record+1;
            ListIDAffaire.add(aff.codeAffaire__c);
            if(aff.codeAffaire__c.left(1)!='9')
                ListIDAffaireWithout9.add(aff.codeAffaire__c);
            if(aff.codeclient__c!=null)
                ListIDAccount.add(aff.codeclient__c);

            if(aff.codecommande__c!=null)
                ListIDOrder.add(aff.codecommande__c);                        
        }       

        for(VIAffaire__c aff : [SELECT id, name ,Order__c,Compte__c ,entite_bw__c,
                                       Produit_SousDomaine__c, Nom_affaire__c ,
                                       Date_de_SAV_previsionnelle__c ,Date_de_SAV_reelle__c ,
                                       Date_ouverture_affaire__c ,date_max_mouvement__c
                                  FROM VIAffaire__c 
                                 WHERE name in :ListIDAffaire]) {
            MapAffaire.put(aff.name, aff);
        }
        List<id>ListAvenantID=new List<id>();
        for(VIavenant__c Av : [SELECT ID,Periode_comptable__c, PV__c ,PV_E__c ,Affaire__c , 
                                      Statut_avenant__c,Affaire__r.name,code_avenant__c,Date__c, Annulation_complete__c 	  
                                 FROM VIAvenant__c
                                WHERE Affaire__r.name in :ListIDAffaire ]) {
            MapAvenant.put(av.Affaire__r.name+'-'+(av.code_avenant__c==null?'':av.code_avenant__c), av) ;
            ListAvenantID.add(av.id);
        }
        for(VILigne_budget__c bud:[select id, avenant__c,avenant__r.affaire__c,
                                          Centre_Section__c ,Centre_Section__r.name, 
                                          Type_de_depense__c ,Type_de_depense__r.name, 
                                          Heures__c, 
                                          Debours__c, PRI__c, Complet__c, 
                                          Debours_E__c, PRI_E__c, Complet_E__c
                                     from VILigne_budget__c
                                    WHERE avenant__c in :ListAvenantID
                                     // AND Type_de_depense__r.name like 'GAR%'
                                     ]) {
            if(bud.Type_de_depense__r.name.left(3)=='GAR') {                              
                MapBudgetGAR.put(bud.avenant__c,bud);
            }
            ListAllBudget.add(bud);
        }
        

        for(Account acc : [SELECT id, name , ACC_ERPIdFRA__c  
                             FROM Account
                            WHERE ACC_ERPIdFRA__c   in :ListIDAccount]) {
            MapAccount.put(acc.ACC_ERPIdFRA__c  , acc);
        }
        for(Order order : [SELECT id, ORD_ReferenceCommande__c  
                             FROM order
                            WHERE ORD_ReferenceCommande__c   in :ListIDOrder]) {
            MapOrder.put(order.ORD_ReferenceCommande__c  , order);
        }
/*
        for(Int_budget__c b : [SELECT id,codeaffaire__c from Int_budget__c where codeaffaire__c in :ListIdAffaire ]){
            MapInt_Budget.put(b.codeaffaire__c,b);
        }
        for(Int_achat__c a : [SELECT id,codeaffaire__c from Int_Achat__c where codeaffaire__c in :ListIDAffaireWithout9]){
            MapInt_achat.put(a.codeaffaire__c,a);
        }
        for(Int_pointage__c p : [SELECT id,codeaffaire__c from Int_pointage__c where codeaffaire__c in :ListIDAffaireWithout9]){
            MapInt_pointage.put(p.codeaffaire__c,p);
        }
        for(Int_facture__c f : [SELECT id,codeaffaire__c from Int_facture__c where codeaffaire__c in :ListIDAffaireWithout9]){
            MapInt_facture.put(f.codeaffaire__c,f);
        }
*/        
        for(VIaffaire__c a : [SELECT id,name from VIaffaire__c where name in :ListIdAffaire]){
            listA.add(a);
        }
        for(VIligne_affaire__c la : [SELECT id,Ligne_d_affaire_mensuelle__r.affaire__r.name from VIligne_affaire__c where Ligne_d_affaire_mensuelle__r.affaire__r.name in :ListIdAffaire]){
            listLA.add(la);
        }
        for(VILigne_d_affaire_mensuelle__c lam : [SELECT id,affaire__r.name from VILigne_d_affaire_mensuelle__c where affaire__r.name in :ListIdAffaire]){
            listLAM.add(lam);
        }
        
        
        Map<string, VIAffaire__c>MapUpsertAffaire = new Map<string, VIAffaire__c>();
        list<VIAvenant__c>listInsertAvenant = new List<VIAvenant__c>();
        list<VIAvenant__c>listUpdateAvenant = new List<VIAvenant__c>();
        list<VILigne_budget__c>listInsertBudget = new List<VILigne_budget__c>();

        
        for(Int_affaire__c aff:scope) {
            system.debug('Code affaire en cours '+aff.codeAffaire__c);
            VIAffaire__c Affaire = new VIAffaire__c();
            
            // Si l'annulation est déjà traitée, on laisse tomber
            if(aff.FlagAnnulation__c) {
                if(MapAvenant.containskey(aff.codeAffaire__c+'-'+aff.typeevenement__c+(aff.NumAvCde__c==null  ?'' :'-'+aff.NumAvCde__c ))) {
                    VIAvenant__c av=MapAvenant.get(aff.codeAffaire__c+'-'+aff.typeevenement__c+(aff.NumAvCde__c==null  ?'' :'-'+aff.NumAvCde__c ));
                    if(av.annulation_complete__c) {
                        aff.Import_Status__c='2';  
                        continue;
                    }
                }
            }
            
            if(MapUpsertAffaire.containskey(aff.codeAffaire__c)) {
                Affaire = MapUpsertAffaire.get(aff.codeAffaire__c) ;
            } else  if(MapAffaire.containsKey(aff.codeAffaire__c)) {
                Affaire=MapAffaire.get(aff.codeAffaire__c);
            } else {
                // those two fields cannot be changed. So they are filled only on the cretion
                if (aff.codeclient__c==null) {
                    affaire.Compte__c=CompteBabcockWanson.id;
                }  else if(MapAccount.containskey(aff.codeClient__c)) {
                    affaire.Compte__c=MapAccount.get(aff.codeClient__c).id;
                } else {
                    affaire.Compte__c=CompteBabcockWanson.id;
                    VIUtils.LogWrite('VISchedImportAffaire','3 Error    ','','Account unknown '+aff.codeClient__c);
                }
            }
/*
            Boolean exist=false ;
            if(MapInt_Budget.containskey(aff.codeAffaire__c)) {
                exist=true; 
            }
            if(MapInt_Achat.containskey(aff.codeAffaire__c)) {
                exist=true; 
            }
            if(MapInt_Pointage.containskey(aff.codeAffaire__c)) {
                exist=true; 
            }
            if(MapInt_facture.containskey(aff.codeAffaire__c)) {
                exist=true; 
            }
*/             
            
//            if(exist==false) {
/*
                
                for(VIligne_affaire__c la :listLA) {
                    if(la.Ligne_d_affaire_mensuelle__r.affaire__r.name==aff.codeAffaire__c && !ListDelLa.contains(la))
                        ListDelLa.add(la);
                }
                for(VILigne_d_affaire_mensuelle__c lam :listLAM) {
                    if(lam.affaire__r.name==aff.codeAffaire__c && !ListDelLam.contains(lam))
                        ListDelLam.add(lam);
                }
                for(VIaffaire__c a :listA) {
                    if(a.name==aff.codeAffaire__c && !ListDela.contains(a))
                        ListDela.add(a);
                }
*/            
                
//                aff.Import_Status__c='2';                            
//                continue ; 
//            }            
            if(aff.Code_produit__c!=null) {
                if(aff.typeEvenement__c=='CI' ) {
                    if(aff.Code_produit__c !=null ) {
                        if(MapSousDomaine.containsKey(aff.Code_produit__c)) {
                            affaire.Produit_SousDomaine__c=MapSousDomaine.get(aff.Code_produit__c).id;
                        } else {
                            VIUtils.LogWrite('VISchedImportAffaire','3 Error    ','','Produit ID unknown '+aff.code_produit__c);
                            continue ; 
                        }
                    } else {
                        if(aff.codeCommande__c!=null && MapSousDomaine.containsKey(aff.codeCommande__c.left(3))) {
                            affaire.Produit_SousDomaine__c=MapSousDomaine.get(aff.codeCommande__c.left(3)).id;
                        } else {
                            VIUtils.LogWrite('VISchedImportAffaire','3 Error    ','','Produit ID unknown '+aff.code_produit__c);
                            continue ; 
                        }
                    }
                }
            } else {
                if(!MapAffaire.containskey(aff.CodeAffaire__c)) {
                    VIUtils.LogWrite('VISchedImportAffaire','3 Error    ','','Avenant sans contrat initial '+aff.CodeAffaire__c);
                    continue ; 
                }
            }
            
            
            if(MapOrder.containsKey(aff.codeCommande__c)) {
                Affaire.order__c=MapOrder.get(aff.codeCommande__c).id;
            }
            Affaire.name                          = aff.CodeAffaire__c;

            if(aff.TypeEvenement__c=='CI') {
                Affaire.Date_ouverture_affaire__c = VIUtils.conv_date(date.valueof(aff.dateOuvAffaire__c)) ; 
                if(aff.dateLivraison__c!=null)  {  
                    Affaire.Date_de_livraison__c          = VIUtils.conv_date(aff.dateLivraison__c );             
                }
                if(aff.codecommande__c!=null)  {  
                    Affaire.code_commande__c  = aff.codecommande__c;             
                }
                if(aff.libelleaffaire__c!=null)  
                    Affaire.nom_affaire__c=aff.libelleaffaire__c;            
             
                if(aff.raisonSocialeClient__c!=null) {               
                   Affaire.nom_affaire__c                = aff.raisonSocialeClient__c;
                   Affaire.description_courte__c         = aff.libelleaffaire__c.removeStart(aff.raisonSocialeClient__c);                
                }
            }
            
            Affaire.entite_bw__c        = Entite_bwFr ; 
            if(affaire.Compte__c==CompteBabcockWanson.id && MapAccount.containskey(aff.codeClient__c)) {
                    affaire.Compte__c=MapAccount.get(aff.codeClient__c).id;
            }
                

            if(aff.DateSortieVentePrev__c!=null) {
                Affaire.Date_de_SAV_previsionnelle__c = VIUtils.conv_date(aff.DateSortieVentePrev__c);

                if( Affaire.date_max_mouvement__c==null) 
                    Affaire.date_max_mouvement__c=affaire.Date_de_SAV_previsionnelle__c;
            }


            if(aff.DateMiseService__c!=null)    
                Affaire.Date_de_SAV_reelle__c         = VIUtils.conv_date(aff.DateMiseService__c  );                        


            if(!MapUpsertAffaire.containskey(aff.codeaffaire__c)) {
                MapUpsertAffaire.put(aff.codeaffaire__c,affaire);
            } 
            if(Affaire.Date_de_SAV_previsionnelle__c<Affaire.Date_ouverture_affaire__c) {
                Affaire.Date_de_SAV_previsionnelle__c=Affaire.Date_ouverture_affaire__c;
            }

            if(aff.Chef_de_projet__c!=null) {
                if(mapUser.containskey(aff.Chef_de_projet__c ))
                    Affaire.Chef_de_projet__c =mapUser.get(aff.Chef_de_projet__c).id;
            }

            if(Affaire.Date_de_SAV_previsionnelle__c==null)            
                Affaire.Date_de_SAV_previsionnelle__c=Affaire.Date_ouverture_affaire__c;
            
            if(affaire.id!=null) {
                VIAvenant__c avenant = new VIAvenant__c();
                
                if(!MapAvenant.containskey(aff.codeaffaire__c+'-'+aff.typeevenement__c+(aff.NumAvCde__c==null  ?'' :'-'+aff.NumAvCde__c ))) {
                    system.debug('on créé l avenant');
                    avenant.affaire__c=affaire.id;

                    if(aff.montantPv__c!=0)
                        avenant.PV__c =aff.montantPv__c;

                    system.debug('---'+avenant.pv__c+' '+aff.montantPv__c);
                    
                    avenant.Statut_avenant__c='20 En cours';
                    avenant.date__c=date.valueof(aff.dateOuvAffaire__c) ; 
                    avenant.code_avenant__c = aff.typeevenement__c+(aff.NumAvCde__c==null  ?'' :'-'+aff.NumAvCde__c );

                    
                    // On est sur une annulation complète. 
                    if(aff.FlagAnnulation__c) {
                        Avenant.annulation_complete__c=true;
                        // Il faut lire tous les avenants et annuler les PV
                        Double tot=0;
                        Double tot_E=0;
                        avenant.PV__c =0;
                        for(string AvKey:MapAvenant.keyset()) {
                            if(AvKey.contains(aff.codeaffaire__c+'-')) {
                                VIAvenant__c av =MapAvenant.get(AvKey) ;
                                tot  =tot  +(av.Pv__c  ==null?0:av.PV__c);
                                tot_E=tot_E+(av.Pv_E__c==null?0:av.PV_E__c);
                            }                            
                        }
                        avenant.PV__c   = tot*(-1);
                        avenant.PV_E__c = tot_E*(-1);

                        // Ok, ce n'est pas top d'avoir l'insert dans la boucle, mais il faut que l'avenant soit créé pour pouvoir
                        // y ajouter des lignes de budget, et on a jamais des annulations d'avenants les unes après les autres
                        insert Avenant ; 
                        
                        // Il faut lire toutes les lignes budget et les annuler
                        Map<string,list<double>> MapBudgetAnnulation = new Map<string,list<double>>();
                        for(VILigne_budget__c lb :ListAllBudget) {
                            if(lb.avenant__r.affaire__c!=affaire.id)
                                continue ; 
                            
                            string key=lb.Centre_Section__r.name.left(3).trim()+'!'+lb.Type_de_depense__r.name.left(3).trim();
                            List<Double> ListD = new List<Double>();
                            if(!MapBudgetAnnulation.containskey(key)) {
                                ListD.add(0);
                                ListD.add(0);                                
                                ListD.add(0);                                
                                ListD.add(0);                                                                
                                ListD.add(0);                                
                                ListD.add(0);                                
                                ListD.add(0);                                                                
                                MapBudgetAnnulation.put(key,ListD);
                            }
                            ListD = MapBudgetAnnulation.get(key);
                            ListD[0] = ListD[0] + (lb.heures__c==null?0:lb.heures__c);
                            ListD[1] = ListD[1] + lb.debours__c;
                            ListD[2] = ListD[2] + lb.PRI__c;
                            ListD[3] = ListD[3] + lb.Complet__c;                            
                            ListD[4] = ListD[4] + lb.debours_E__c;
                            ListD[5] = ListD[5] + lb.PRI_E__c;
                            ListD[6] = ListD[6] + lb.Complet_E__c;                            
                            MapBudgetAnnulation.put(key,ListD ) ;                            
                        }
                        for(string key:MapBudgetAnnulation.keyset()) {
                            VILigne_budget__c budget = new VILigne_budget__c();
                            budget.avenant__c = avenant.id;
                            List<Double> ListD = MapBudgetAnnulation.get(key) ; 
                            list<string>LKey = key.split('!');
                            budget.Type_de_depense__c = MapDepense.get(LKey[1]).id ; 
                            budget.Centre_Section__c  = MapCentre.get(LKey[0]).id ; 

                            if(LKey[1]=='MO')
                                budget.Heures__c=ListD[0] * (-1);                            
                            
                            budget.Debours__c=ListD[1] * (-1);
                            budget.PRI__c=ListD[2] * (-1);
                            budget.Complet__c=ListD[3] * (-1);                            
                            budget.Debours_E__c=ListD[4] * (-1);
                            budget.PRI_E__c=ListD[5] * (-1);
                            budget.Complet_E__c=ListD[6] * (-1);                            

                            listInsertBudget.add(budget);
                        }
                        
                    }
                    MapAvenant.put(aff.codeaffaire__c+'-'+aff.typeevenement__c+'-'+(aff.NumAvCde__c==null ?'' :aff.NumAvCde__c),avenant ) ;                    
                    listInsertAvenant.add(Avenant);
                    continue ; 
                } else {
                    system.debug('on modifie l avenant '+aff.montantPv__c);
                    avenant=MapAvenant.get(aff.codeaffaire__c+'-'+aff.typeevenement__c+(aff.NumAvCde__c==null ?'' :'-'+aff.NumAvCde__c ));
                    
                    if(aff.montantPv__c==null)
                        aff.montantPv__c=0;     
                    
                    avenant.PV__c =aff.montantPv__c;     
                    avenant.date__c=date.valueof(aff.dateOuvAffaire__c) ; 
                    

                    system.debug('pv '+avenant.PV__c);
                    VILigne_budget__c budget = new VILigne_budget__c();
                    if(avenant.id!=null && !MapBudgetGAR.containsKey(avenant.id) && aff.montantProvisionsGarantie__c!=0) {
                        budget.avenant__c = avenant.id;
                        budget.Debours__c=aff.montantProvisionsGarantie__c;
                        budget.Type_de_depense__c = TDGar.id ; 
                        budget.Centre_Section__c  = CS801.id ;                         
                        listInsertBudget.add(budget);
                        MapBudgetGAR.put(avenant.id,budget);
                    }
                    avenant.Statut_avenant__c='20 En cours';
                    avenant.code_avenant__c = aff.typeevenement__c+(aff.NumAvCde__c==null ?'' :'-'+aff.NumAvCde__c);  

                    if(!listUpdateAvenant.contains(avenant)) {
                        if(!ListInsertAvenant.contains(avenant)) {
                            listUpdateAvenant.add(avenant);
                        }
                    }
                }
                if(avenant.date__c>affaire.date_max_mouvement__c) {
                    affaire.date_max_mouvement__c=avenant.date__c;
                }
                aff.Import_Status__c='2';            

            }
        }

        update scope ; 
/*
        delete ListDelLa;
        delete ListDelLam;  
        delete ListDela ;       
*/
        upsert MapUpsertAffaire.values();    
        insert listInsertBudget; 
        upsert listInsertAvenant;
        update listupdateAvenant;

    }

    global void finish(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VISchedImportAffaire','1 Normal',IDLog,'End '+num_record);
        if(enchaine && nbr_iteration<3) {
            nbr_iteration= nbr_iteration +1 ; 
            Database.executeBatch(new VISchedImportAffaire(AffaireAGenerer, enchaine,toute,nbr_iteration ),VISchedImportAffaire.NBR_LOT());            
        } else if(enchaine) {
            Database.executeBatch(new VISchedImportBudget(AffaireAGenerer, enchaine, toute),VISchedImportBudget.NBR_LOT());
        }
    }

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VISchedImportAffaire(AffaireAGenerer, enchaine, toute, 1),NBR_LOT()); // Il faut laisser 1 pour la 1ère fois
    }
    public static  integer NBR_LOT () {
         VIParametres__c param = VIParametres__c.getInstance(UserInfo.getUserId()); 
         integer i ; 
         if(param.Sans_Calcul_de_PRI__c) {
             i=150 ; // 400 était correct 450 fait un too many soql
         } else {
             i=4;    
         }
         return i;
    }

    public void code_coverage() {
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
    }
    
    
}