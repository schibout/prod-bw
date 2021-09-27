//
//   This batch send the ecriture
//  
//  
// 
global class VIBatchEnvoiEcriture implements Database.Batchable<sObject>, Database.Stateful {

    private String  EcrituresAEnvoyer;
    private String  entite_bw;    
    Public Integer num_record = 0; 
    Global String IDLog ='';

    public VIBatchEnvoiEcriture(String Param1,String Param2 ) {
        EcrituresAEnvoyer = Param1;        
        entite_bw = Param2;                
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String     query='SELECT Id,affaire__c, Statut_ecriture_comptable__c ';
        query = query + '   FROM VILigne_comptable__c ';
        query = query + '  WHERE Statut_ecriture_comptable__c =\''+VIConstant.EC_BROUILLON+'\'';
        query = query + '    AND Affaire__r.entite_bw__c =\''+entite_bw+'\'';        
        if(EcrituresAEnvoyer=='Avancement') {
            query = query + '    AND (libelle__c=\''+VIConstant.EC_CA_AVENCEMENT+'\' ';
            query = query + '       OR libelle__c=\''+VIConstant.EC_PROVISION_AMORTISSEMENT_AVCT+'\' ';            
            query = query + '       OR libelle__c=\''+VIConstant.EC_PROVISION_FINANCEMENT_AVCT+'\') ';                        
        } else if (EcrituresAEnvoyer=='Reprise de garantie') {
            query = query + '    AND libelle__c=\''+VIConstant.EC_REPRISE_PROVISION_GARANTIE+'\'';            
        } else {
            query = query + '    AND 1=0 '; // We don't want to run the programm
        }
        system.debug(query);
        IDLog=VIUtils.LogWrite('VIBatchEnvoiEcriture','4 Running','','Start ');
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<VILigne_comptable__c> scope) {
        for(VILigne_comptable__c lc:scope) {
             lc.Statut_ecriture_comptable__c=VIConstant.EC_A_PRENDRE  ;
        }
        update scope;
        num_record = num_record + scope.size();
    }   

    global void finish(Database.BatchableContext BC) {
        IDLog=VIUtils.LogWrite('VIBatchEnvoiEcriture','1 Normal',IDLog,'nbr '+num_record);    
        
    }
    public static final integer NBR_LOT = 20;
    
}