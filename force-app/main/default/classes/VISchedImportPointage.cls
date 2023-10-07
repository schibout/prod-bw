/*
*
*  We have to launch the import files 
*
*
*  for running by hand : 
 VISchedImportPointage v = new VISchedImportPointage();
 v.execute(null);
*
*  for running every hour at xx:16
     VISchedImportPointage m = new VISchedImportPointage();
     String sch = '0 16 * * * ?';
     String jobID = system.schedule('VISchedImportPointage', sch, m);
*
*
*/
global class VISchedImportPointage implements Schedulable,Database.Batchable<sObject>,Database.Stateful{

    Global double num_record = 0;
    Global String IDLog ='';    
    Global id PaysFr = null ; 
    Global Map<string, VICentre_Section__c>MapCentre = new Map<string, VICentre_Section__c>();
    Global Map<string, user>MapUser = new Map<string, user>();
    
    
    private string AffaireAGenerer; 
    private boolean Enchaine ;
    private boolean toute ;    
    
     public VISchedImportPointage(String Param1,Boolean Param2,Boolean Param3 ) {
        AffaireAGenerer = Param1;        
        Enchaine = Param2;                
        toute = Param3;                         
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VISchedImportPointage','4 Running','','Start ');

        for(user u : [Select name, id,NMatricule__c  from user]) {
            MapUser.put(u.NMatricule__c , u);
        }
        for(VICentre_Section__c cs : [Select name, id from VICentre_Section__c]) {
            MapCentre.put(cs.name.Left(3), cs);
        }
        
        
        PaysFr = [SELECT id from VIpays__c where name='FR'].id; 
                                         
        string query = 'SELECT codeAffaire__c, codecentre__c,codechapitre__c, codesousChapitre__c,Import_Status__c , ';
        query = query+'        Date__c, NbrHeures__c  ,Salarie__c, numero_unique__c,   ';
        query = query+'        Annee_ori__c, semaine_ori__c ,  ';
        query = query+'        montant__c, montant_frg__c  ,montant_frk__c    ';        
        query = query+'   FROM Int_pointage__c ';
        query = query+'   WHERE codeaffaire__c!=null ';
        
        if(!toute)
            query = query+'     AND (Import_Status__c =\'1\' or Import_Status__c =null) ';

        query = query+'     AND numero_unique__c!=null ';      
        query = query+'     AND NbrHeures__c!=null ';        
       // query = query+'     AND NbrHeures__c!=0 ';  
       
        
        query = query+'     AND (codeAffaire__c Like \''+AffaireAGenerer+'%\')  ';
        query = query+'   Order by codeaffaire__c desc  ';        

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Int_pointage__c> scope){
        num_record = 0;
        Map<string, VIAffaire__c>MapAffaire  = new Map<string, VIAffaire__c>();
        
        List<string>ListIDAffaire = new List<string>();
        List<string>ListNumero_unique = new List<string>();
        
        for(Int_pointage__c po:scope) {
            num_record = num_record+1;
            ListIDAffaire.add(po.codeAffaire__c);
            ListNumero_unique.add(po.numero_unique__c);            
        }       

        for(VIAffaire__c aff : [SELECT id,name, date_max_mouvement__c
                                  FROM VIAffaire__c 
                                 WHERE name in :ListIDAffaire]) {
            MapAffaire.put(aff.name, aff);
        }
        Map<string, VIPointage__c>MapNumeroUnique = new Map<string, VIPointage__c>();
        for(VIPointage__c po:[select id,numero_unique__c from VIPointage__c where numero_unique__c in:ListNumero_unique ]) {
            MapNumeroUnique.put(po.numero_unique__c,po) ;
        }
        
        
        list<VIPointage__c>listInsertPointage = new List<VIpointage__c>();
        for(Int_pointage__c po:scope) {
            system.debug(' on traite '+po.codeAffaire__c+' '+po.id);
            
            
            if(MapNumeroUnique.containskey(po.numero_unique__c)) {
                po.Import_Status__c='2';            
            } else {
            
                VIPointage__c Pointage = new VIPointage__c();
                if(MapAffaire.containskey(po.codeAffaire__c)) {
                    VIAffaire__c Affaire=MapAffaire.get(po.codeAffaire__c);
                    Pointage.affaire__c=Affaire.id;
                    
                    if(affaire.date_max_mouvement__c==null ||affaire.date_max_mouvement__c<po.date__c)
                        affaire.date_max_mouvement__c=po.date__c;
                    
                    if(!MapCentre.containskey(po.codecentre__c)) {
                        VIUtils.LogWrite('VISchedImportPointage','3 Error','','code centre inconnu '+po.codecentre__c+' '+po.id);
                        continue ; 
                    }
                    
                    Pointage.Centre_Section__c =MapCentre.get(po.codecentre__c).id;
                    Pointage.Annee_ori__c   =po.Annee_ori__c;
                    Pointage.semaine_ori__c =po.semaine_ori__c;
                    pointage.date_comptabilisation__c = po.date__c;

                    // Let's convert the year + number of week in a real date
                    if(po.semaine_ori__c!=null) {
                        integer i = integer.valueof(po.semaine_ori__c * 7) + 7;
                        Pointage.Date__c    = date.valueof(string.valueof(po.Annee_ori__c).left(4)+'-01-01 01:00:00').adddays(i).tostartofweek();
                    } else {
                        Pointage.Date__c    = po.date__c;
                    }

                    if(mapUser.containskey(po.salarie__c)) {
                        pointage.employe__c=mapUser.get(po.salarie__c).id;
                    } else {
                        VIUtils.LogWrite('VISchedImportPointage','3 Error','','code salarié inconnu '+po.salarie__c+' '+po.id);
                        continue ; 
                    }
                    
                    if(po.CodeChapitre__c!=null && po.Codesouschapitre__c!=null) {
                        Pointage.Sous_chapitre__c =('0'+po.CodeChapitre__c).right(2)+'-'+('0'+po.Codesouschapitre__c).right(2);
                    } else {
                        Pointage.Sous_chapitre__c ='00-00';
                    }
                    Pointage.Heures__c  =(po.NbrHeures__c==null ? 0 : po.NbrHeures__c)  ;
                    pointage.Debours__c =(po.montant__c==null ? 0 :po.montant__c);
                    pointage.Debours_E__c =(po.montant__c==null ? 0 :po.montant__c);                    
                    if(po.numero_unique__c.left(3)=='REP') {
                        pointage.PRI__c     =(po.montant_frg__c==null ? 0 :po.montant_frg__c) ;
                        pointage.Complet__c =(po.montant_frk__c==null ? 0 :po.montant_frk__c);   
                        pointage.PRI_E__c     =(po.montant_frg__c==null ? 0 :po.montant_frg__c) ;
                        pointage.Complet_E__c =(po.montant_frk__c==null ? 0 :po.montant_frk__c);   
                    } else {
                        pointage.PRI__c     =(po.montant__c==null ? 0 :po.montant__c) +(po.montant_frg__c==null ? 0 :po.montant_frg__c) ;
                        pointage.Complet__c =(po.montant__c==null ? 0 :po.montant__c) +(po.montant_frg__c==null ? 0 :po.montant_frg__c)+(po.montant_frk__c==null ? 0 :po.montant_frk__c);   
                    }
                    pointage.numero_unique__c = po.numero_unique__c;
                    listInsertPointage.add(Pointage);
                    MapNumeroUnique.put(po.numero_unique__c,null);
            
                } else {
                    VIUtils.LogWrite('VISchedImportPointage','3 Error','','code affaire inconnue '+po.codeAffaire__c+' '+po.id);
                }
                po.Import_Status__c='2';

            }    
        }
        update scope ; 
        update MapAffaire.values();
        insert listInsertPointage;        

    }

    global void finish(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VISchedImportPointage','1 Normal',IDLog,'End '+num_record);
        if(enchaine)
            Database.executeBatch(new VIBatchRegenerateLAM(AffaireAGenerer, enchaine), VIBatchRegenerateLAM.NBR_LOT());        
        
    }

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VISchedImportPointage(AffaireAGenerer, enchaine, toute),VISchedImportPointage.NBR_LOT());
    }

    public static  integer NBR_LOT () {
         VIParametres__c param = VIParametres__c.getInstance(UserInfo.getUserId()); 
         integer i ; 
         if(param.Sans_Calcul_de_PRI__c) {
             i=100 ;
         } else {
             i=5;    
         }
         return i;
    }

}