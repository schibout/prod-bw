//
//   This batch recalculate the Currency Value of each line
//  
//  
/*

date d1=date.newinstance(2021,01,01);
date d2=date.newinstance(2021,05,31);
VIBatchReCalcPointage b = new VIBatchReCalcPointage(d1,d2);
database.executebatch(b,VIBatchReCalcPointage.nbr_lot());               
  
*/  
//  
// 
global class VIBatchReCalcPointage implements Database.Batchable<sObject>, Database.Stateful {

    private Date   DateDateMinimum;
    private Date   DateDateMaximum;
    private Date   DateDateReference;
    private ViPeriode__c periode  ; 

    Public Integer num_record = 0; 
    Global String IDLog ='';

    public VIBatchReCalcPointage(date DateParam2 ,date  DateParam3) {
        DateDateMinimum = DateParam2;        
        DateDateMaximum = DateParam3;                
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String     query='SELECT Id,affaire__c,Numero_unique__c,Centre_Section__c, ';
        query = query + '        date_comptabilisation__c, heures__c, ';
        query = query + '        sous_chapitre__c,Employe__c ,';
        query = query + '        debours__c,   PRI__c,   complet__c, ';
        query = query + '        debours_E__c, PRI_E__c, complet_E__c ';        
        query = query + '   FROM VIpointage__c ';
        query = query + '  WHERE (not numero_unique__c like \'REC%\')  ';
        //query = query + '    AND affaire__r.name=\'B87889\'    ' ;
        query = query + '    AND date_comptabilisation__c>='+string.valueof(DateDateMinimum) ;
        query = query + '    AND date_comptabilisation__c<='+string.valueof(DateDateMaximum) ;

 
        DateDateReference = DateDateMaximum.adddays(1);
        
        IDLog=VIUtils.LogWrite('VIBatchReCalcPointage','4 Running','','Start ');
        system.debug(query);
        
        Periode= [SELECT id,date_de_debut__c, date_de_fin__c, entite_bw__c
                    FROM VIPeriode__c
                   WHERE date_de_debut__c<=:DateDateMaximum
                     AND date_de_fin__c>=:DateDateMaximum
                     AND entite_bw__c='1'];

        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<VIpointage__c> scope) {
        Map<string, VIPointage__c>MapReference = new Map<string, VIPointage__c>();
        Map<string, VIPointage__c>MapUpsert    = new Map<string, VIPointage__c>();

        list<String>ListNumeroUnique = new list<String>();
        list<VIpointage__c>ListPointage = new list<VIpointage__c>();
        list<string>ListIdAffaire = new list<string>();
        for(VIPointage__c po:scope) {
            ListIdAffaire.add(po.affaire__c);
            ListNumeroUnique.add('REC'+po.numero_unique__c);
            // Let's save the previous value
            Vipointage__c NewPo = new VIpointage__c(Numero_unique__c = po.Numero_unique__c,
                                                    heures__c=po.heures__c,
                                                    debours__c  = po.debours__c,   PRI__c  =po.PRI__c,   complet__c  =po.complet__c,
                                                    debours_E__c= po.debours_E__c, PRI_E__c=po.PRI_E__c, complet_E__c=po.complet_E__c);
            
           
            MapReference.put(po.Numero_unique__c,NewPo); 

            // We add an A- because we want the change to be made
            po.numero_unique__c = 'A-'+po.numero_unique__c;
            po.date_comptabilisation__c=DateDateReference;
            ListPointage.add(po);
        }
        for(VIPointage__c po:[SELECT id, name,Numero_unique__c
                                FROM VIpointage__c
                               WHERE Numero_unique__c in :ListNumeroUnique]) {
            MapUpsert.put(po.Numero_unique__c,po); 
        }

        // Let's compute the new value
        VI01_VIPointage.Compute_Value(ListPointage);
        
        for(VIPointage__c po : ListPointage) {
            VIPointage__c NewPo ;
            po.numero_unique__c=po.numero_unique__c.ReplaceFirst('A-','REC');
            if(!MapUpsert.containskey(po.numero_unique__c)) {
                 NewPo = new VIPointage__c ( affaire__c = po.affaire__c, 
                                             Centre_Section__c = po.Centre_Section__c,
                                             numero_unique__c = po.numero_unique__c,
                                             date__c=DateDateReference,
                                             date_comptabilisation__c=DateDateReference,
                                             sous_chapitre__c= po.sous_chapitre__c,
                                             employe__c= po.employe__c,
	                                         debours__c = 0,   PRI__c=0,   complet__c=0,
                                             debours_E__c = 0, PRI_E__c=0, complet_E__c=0 ) ;
            } else {
                NewPo = MapUpsert.get(po.numero_unique__c);
                NewPo.date__c=DateDateReference;
                NewPo.date_comptabilisation__c=DateDateReference;
            }

            VIPointage__c OldPo = MapReference.get(po.numero_unique__c.replace('REC',''));
            NewPo.heures__c = 0 ;
            NewPo.debours__c = po.debours__c - OldPo.debours__c;
            NewPo.PRI__c     = po.PRI__c     - OldPo.PRI__c;    
            NewPo.complet__c = po.complet__c - OldPo.complet__c;            

            NewPo.debours_E__c = po.debours_E__c - OldPo.debours_E__c;
            NewPo.PRI_E__c     = po.PRI_E__c     - OldPo.PRI_E__c;    
            NewPo.complet_E__c = po.complet_E__c - OldPo.complet_E__c; 
            MapUpsert.put(po.numero_unique__c,NewPo);
        }
        upsert MapUpsert.values() ;
        for(VIPointage__c po:MapUpsert.values()) {
            po.date_comptabilisation__C=datedatemaximum;
            po.date__C=datedatemaximum;            
            po.Periode_comptable__c=periode.id; 
        }
        upsert MapUpsert.values() ;
        
        
        List<VIAffaire__c>ListUpdateAffaire = new List<VIAffaire__c>();
        for(VIAffaire__c aff:[SELECT id, date_max_mouvement__c 
                                FROM VIAffaire__c
                               WHERE id in :ListIDAffaire]) {
            if(aff.date_max_mouvement__c<DateDateMaximum) {
                aff.date_max_mouvement__c=DateDateMaximum;
                ListUpdateAffaire.add(aff);
            }                          
        }
        update ListUpdateAffaire;
        
        num_record = num_record + scope.size();
    }   

    global void finish(Database.BatchableContext BC) {
        IDLog=VIUtils.LogWrite('VIBatchReCalcPointage','1 Normal',IDLog,'nbr '+num_record);    

       // VIBatchReCalcAchat b = new VIBatchReCalcAchat(DateDateMinimum,datedatemaximum); 
       // database.executebatch(b,1);              
        
    }
    
    public static  integer NBR_LOT () {
         integer i=100 ; 
         return i;
    }
    
    
}