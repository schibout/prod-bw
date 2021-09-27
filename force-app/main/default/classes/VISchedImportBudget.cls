/*
*
*  We have to launch the import files 
*
*  for running by hand : 
 VISchedImportBudget v = new VISchedImportBudget();
 v.execute(null);
*
*  for running every hour at xx:16
     VISchedImportBudget m = new VISchedImportBudget();
     String sch = '0 16 * * * ?';
     String jobID = system.schedule('VISchedImportBudget', sch, m);
*
*
*/
global class VISchedImportBudget implements Schedulable,Database.Batchable<sObject>,Database.Stateful{

    Global double num_record = 0;
    Global String IDLog ='';    
    Global Map<string, VICentre_Section__c>MapCentre = new Map<string, VICentre_Section__c>();
    Global Map<string, VIType_de_depense__c>MapDepense = new Map<string, VIType_de_depense__c>();
    
    
    private string AffaireAGenerer; 
    private boolean Enchaine ;
    private boolean toute ;
    
     public VISchedImportBudget(String Param1,Boolean Param2,Boolean Param3 ) {
        AffaireAGenerer = Param1;        
        Enchaine = Param2;                
        toute = Param3;                
     }

    
    global Database.QueryLocator start(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VISchedImportBudget','4 Running','','Start ');

        for(VIType_de_depense__c td : [Select name, id from VIType_de_depense__c]) {
            MapDepense.put(td.name.left(3), td);
        }
        for(VICentre_Section__c cs : [Select name, id from VICentre_Section__c]) {
            MapCentre.put(cs.name.Left(3), cs);
        }
                                               
        string query = 'SELECT id,codeAffaire__c, codecentre__c,codechapitre__c, codeSousChapitre__c , ';
        query = query+'        DatePublication__c , Import_Status__c  ,mntEur__c    , nbrHeures__c  ,    ';
        query = query+'        Nom_frn__c  , num_frn__c   ,typeDepense__c,typeEvenement__c,avenant__c     ';        
        query = query+'   FROM Int_budget__c ';
        query = query+'   WHERE codeaffaire__c!=null ';
        if(!toute)
            query = query+'     AND (Import_Status__c =\'1\' or Import_Status__c =null) ';

        query = query+'     AND (codeAffaire__c Like \''+AffaireAGenerer+'%\')  ';
        query = query+' ORDER BY codeAffaire__c desc   ';
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Int_budget__c> scope){
        num_record = 0;
        Map<string, VIAvenant__c>MapAvenant      = new Map<string, VIAvenant__c>();
        Map<string, VIAffaire__c>MapAffaire      = new Map<string, VIAffaire__c>();
        Map<string, VILigne_budget__c>MapBudget  = new Map<string, VILigne_budget__c>();
        

        List<string>ListIDAffaire = new List<string>();
                
        for(Int_budget__c bud:scope) {
            num_record = num_record+1;
            ListIDAffaire.add(bud.codeAffaire__c);
        }       

        for(VIAvenant__c ave : [SELECT id, name ,affaire__r.name, code_avenant__c, Annulation_complete__c 
                                  FROM VIAvenant__c 
                                 WHERE affaire__r.name in :ListIDAffaire]) {
            MapAvenant.put(ave.affaire__r.name+'-'+ave.code_Avenant__c, ave);
        }

        for(VIAffaire__c aff : [SELECT id, name ,Date_ouverture_affaire__c ,date_max_mouvement__c
                                  FROM VIAffaire__c 
                                 WHERE name in :ListIDAffaire]) {
            MapAffaire.put(aff.name, aff);
        }
        for(VILigne_budget__c bud : [SELECT id, name ,Centre_Section__r.name,type_de_depense__r.name,
                                            avenant__r.code_Avenant__c, avenant__r.affaire__r.name,
                                            Heures__c,debours__c
                                       FROM VILigne_budget__c 
                                      WHERE avenant__r.affaire__r.name in :ListIDAffaire]) {
            string key = bud.avenant__r.affaire__r.name+'-'+bud.avenant__r.code_Avenant__c+'-'+bud.Centre_Section__r.name.left(3)+'-'+bud.type_de_depense__r.name.left(3);                              
            MapBudget.put(key, bud);
        }

        List<VIAvenant__c>ListUpdateAve = new List<VIAvenant__c>();
        
        for(Int_budget__c bud:scope) {
            system.debug(' affaire en cours '+bud.codeaffaire__c);
            VILigne_budget__c budget = new VILigne_budget__c();
            string code_avenant ; 
            if( bud.typeEvenement__c==null) {
                if(bud.avenant__c=='0') {
                    code_avenant='CI';
                } else {
                    code_avenant='AV';
                }
            } else {
                code_avenant = bud.typeEvenement__c;                 
            }

            if(code_avenant!='CI')
                code_avenant=code_avenant+'-'+bud.avenant__c;

            string key = bud.codeaffaire__c+'-'+code_avenant+'-'+bud.codecentre__c+'-'+(bud.typeDepense__c+' ').left(3);
            if(!MapBudget.containskey(key)) {
            
                if(!MapAvenant.containskey(bud.codeaffaire__c+'-'+code_avenant)) {
                   if(MapAffaire.containskey(bud.codeaffaire__c)) {
                       VIAffaire__c aff=MapAffaire.get(bud.codeaffaire__c);
                    
                       if(aff.date_max_mouvement__c<bud.DatePublication__c)
                           aff.date_max_mouvement__c=bud.DatePublication__c;

                        date d1 ;
                        if(bud.DatePublication__c==null) {
                            d1= aff.Date_ouverture_affaire__c ;
                        } else {
                            d1=bud.DatePublication__c;
                        }
                    
                        VIAvenant__c ave =new VIAvenant__c (affaire__c=aff.id,
                                                    code_avenant__c=code_avenant,    
                                                    date__c=d1,
                                                    Statut_avenant__c =VIConstant.AVENANT_PREVU);
                        insert ave ; 
                        ListUpdateAve.add(ave);
                        MapAvenant.put(bud.codeaffaire__c+'-'+code_avenant, ave);

                    }      

                } 
                if(!MapAvenant.containskey(bud.codeaffaire__c+'-'+code_avenant)) {
                    VIUtils.LogWrite('VISchedImportBudget','3 Error','','code avenant inconnu '+bud.codeaffaire__c+'-'+code_avenant);
                    continue ; 
                }
                    
                    
                budget.avenant__c=MapAvenant.get(bud.codeaffaire__c+'-'+code_avenant).id;
                    

                if(!MapCentre.containskey(bud.codecentre__c)) {
                    VIUtils.LogWrite('VISchedImportBudget','3 Error','','code centre inconnu '+bud.codecentre__c+' '+bud.id);
                    continue ; 
                }
                if(!MapDepense.containskey((bud.typeDepense__c+' ').left(3))) {
                    VIUtils.LogWrite('VISchedImportBudget','3 Error','','code depense inconnu '+bud.typeDepense__c+' '+bud.id);
                    continue ; 
                }

                budget.Centre_Section__c =MapCentre.get(bud.codecentre__c).id;
                budget.type_de_depense__c= MapDepense.get((bud.typeDepense__c+' ').left(3)).id;
            } else {
                 budget=MapBudget.get(key);
            }

            // si on est sur une annulation complète, on laisse tomber la ligne budget car elle a déjà été annulé complètement
            if(MapAvenant.get(bud.codeaffaire__c+'-'+code_avenant).Annulation_complete__c==true ) {
                bud.Import_Status__c='2';
                continue ; 
            }

            if((bud.typeDepense__c+' ').left(3)=='MO ')
                budget.Heures__c =bud.nbrHeures__c;

            budget.Debours__c  =bud.mntEur__c;  

            bud.Import_Status__c='2';
            
            MapBudget.put(key,budget) ;

        }
        upsert MapBudget.Values();
        update MapAffaire.values() ;
        update scope ; 
        for(VIAvenant__c ave:ListUpdateAve) {
            ave.Statut_avenant__c =VIConstant.AVENANT_EN_COURS;
        }
        update ListUpdateAve;
        
    }

    global void finish(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VISchedImportBudget','1 Normal',IDLog,'End '+num_record);
        if(enchaine)
            Database.executeBatch(new VISchedImportFacture(AffaireAGenerer, enchaine, toute),VISchedImportFacture.NBR_LOT());
        
    }

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VISchedImportBudget(AffaireAGenerer, enchaine, toute),VISchedImportBudget.NBR_LOT());
    }

    public static  integer NBR_LOT () {
         VIParametres__c param = VIParametres__c.getInstance(UserInfo.getUserId()); 
         integer i ; 
         if(param.Sans_Calcul_de_PRI__c) {
             i=20 ;
         } else {
             i=20;    
         }
         return i;
    }

    
     
}