/*
*
*  We have to launch the import files 
*
*
*  for running by hand : 
 VISchedImportGDateDeSAV v = new VISchedImportGDateDeSAV('',false,true);
 v.execute(null);
*
*  for running every hour at xx:16
     VISchedImportGDateDeSAV m = new  VISchedImportGDateDeSAV();
     String sch = '0 16 * * * ?';
     String jobID = system.schedule(' v', sch, m);
*
*
*/
global class VISchedImportGDateDeSAV implements Schedulable,Database.Batchable<sObject>,Database.Stateful{

    Global double num_record = 0;
    Global String IDLog ='';    
    
    
    private string AffaireAGenerer; 
    private boolean Enchaine ;
    private boolean toute ;    
    
     public VISchedImportGDateDeSAV(String Param1,Boolean Param2,Boolean Param3 ) {
        AffaireAGenerer = Param1;        
        Enchaine = Param2;                
        toute = Param3;                         
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VISchedImportGDateDeSAV','4 Running','','Start ');

        string query = 'SELECT code_Affaire__c, date_de_sav__c,Import_Status__c  ';
        query = query+'   FROM int_gdatedesav__c  ';
        query = query+'   WHERE code_affaire__c!=null ';

        if(!toute)
            query = query+'     AND (Import_Status__c =\'1\' or Import_Status__c =null) ';

        query = query+'     AND (code_Affaire__c Like \''+AffaireAGenerer+'%\')  ';
        query = query+'   Order by code_affaire__c desc  ';        

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<int_gdatedesav__c> scope){
        num_record = 0;
        string Log = '' ;
        
        list<string>ListIDAffaire = new list<string>();
        for(int_gdatedesav__c g:scope) {
            ListIDAffaire.add(g.code_affaire__c);
        }    
        map<string, VIaffaire__c>MapAffaire = new map<string, VIaffaire__c>();
        for(VIAffaire__c aff:[SELECT id, name, date_de_sav_reelle__c, Date_ouverture_affaire__c 
                                FROM VIAffaire__c
                               WHERE name in :ListIDAffaire]) {
            MapAffaire.put(aff.name,aff); 
        }                       
        for(int_gdatedesav__c g:scope) {
            system.debug('Affaire en cours '+g.code_affaire__c);
            if(!MapAffaire.containskey(g.code_affaire__c) ) {
                Log= log + 'Code affaire inconnu '+g.code_affaire__c+'\r\n';
                continue ;
            }
            VIAffaire__c aff = MapAffaire.get(g.code_affaire__c);
            if(aff.Date_ouverture_affaire__c >g.date_de_sav__c) {
                aff.date_de_sav_reelle__c=aff.Date_ouverture_affaire__c.adddays(1);
            } else {
                aff.date_de_sav_reelle__c=g.date_de_sav__c;
            }
            g.Import_Status__c='2';
            
        }    
        update MapAffaire.values();     
        update scope ; 
        if(Log!='') {
            VIUtils.LogWrite('VISchedImportGDateDeSAV','3 error','',log);
        }

    }

    global void finish(Database.BatchableContext BC){
        IDLog=VIUtils.LogWrite('VISchedImportGDateDeSAV','1 Normal',IDLog,'End '+num_record);
        if(enchaine)
            Database.executeBatch(new VIBatchRegenerateLAM(AffaireAGenerer, enchaine), VIBatchRegenerateLAM.NBR_LOT());        
        
    }

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VISchedImportGDateDeSAV(AffaireAGenerer, enchaine, toute),VISchedImportGDateDeSAV.NBR_LOT());
    }

    public static  integer NBR_LOT () {
         VIParametres__c param = VIParametres__c.getInstance(UserInfo.getUserId()); 
         integer i ; 
         if(param.Sans_Calcul_de_PRI__c) {
             i=200 ;  // 200
         } else {
             i=2;    
         }
         return i;
    }

}