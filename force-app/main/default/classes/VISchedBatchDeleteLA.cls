/*
*
*  Delete all the ligne d'affaire after a number of days. We don't need the LA, LAM are enough
*
*
*  for running by hand : 
 VISchedBatchDeleteLA v = new VISchedBatchDeleteLA('',false);
 v.execute(null);
*
*
*/
global class VISchedBatchDeleteLA implements Schedulable,Database.Batchable<sObject>,Database.Stateful{

    private string AffaireAGenerer; 
    private boolean Enchaine ;
    
     public VISchedBatchDeleteLA(String Param1,Boolean Param2 ) {
        AffaireAGenerer = Param1;        
        Enchaine = Param2;                
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){        
        
        VIParametres__c param = VIParametres__c.getInstance(UserInfo.getUserId());  
        string d1 = string.valueof(system.today().adddays(integer.valueof(param.Nb_jours_conservation_LA__c) * (-1) )).left(10) ; 
        
        string query = 'SELECT id,Date_de_fin_de_garantie__c ';
        query = query+'   FROM VIaffaire__c   ';
        query = query+'  WHERE (name Like \''+AffaireAGenerer+'%\')  ';  
        if(!test.isrunningtest()) {
            query = query+'    and Date_de_fin_de_garantie__c<'+d1 ;  
        }
        query = query+'  order by name Desc  ';                
        system.debug(query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Viaffaire__c > scope){
        list<viLigne_affaire__c>listladelete = new list<viLigne_affaire__c>();
        map<string,VIaffaire__c>MapAffaire = new map<string,VIaffaire__c>();
        for(Viaffaire__c aff: scope) {
            MapAffaire.put(aff.id,aff);
        }
        for(viLigne_affaire__c la: [SELECT id
                                      FROM viLigne_affaire__c
                                     WHERE Ligne_d_affaire_mensuelle__r.affaire__c in :MapAffaire.keyset()
                                       AND Ecart_C_A_F_MontantD__c =0]) {
            listladelete.add(la);
        }
        delete listladelete;

    }

    global void finish(Database.BatchableContext BC){

    }

    global void execute(SchedulableContext scon) {
        Database.executeBatch(new VISchedBatchDeleteLA(AffaireAGenerer,Enchaine),VISchedBatchDeleteLA.NBR_LOT());
    }
    
    public static  integer NBR_LOT () {
         VIParametres__c param = VIParametres__c.getInstance(UserInfo.getUserId()); 
         integer i ; 
         if(param.Sans_Calcul_de_PRI__c) {
             i=40 ;
         } else {
             i=8;    
         }
         return i;
    }
    
}