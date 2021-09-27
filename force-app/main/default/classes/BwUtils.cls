/**
 * @description       : 
 * @author            : SCHIBOUT
 * @group             : 
 * @last modified on  : 27-09-2021
 * @last modified by  : SCHIBOUT
**/
public with sharing class BwUtils {
    
    static List<BwTranscodification__c> transcoList = [SELECT Id, MbApi__c,dataType__c,VsApi__c FROM BwTranscodification__c];
    static List<VISousDomaine__c >  usedcutomerSegmentList = [SELECT Id, Code_BU__c, Code_API_Sous_domaine__c, use_cutomer_segment__c  
                                                              FROM VISousDomaine__c WHERE use_cutomer_segment__c   = true];
    /**
    * @description 
    * @author SCHIBOUT | 27-09-2021 
    * @param dataType 
    * @param lookupValue 
    * @return String 
    **/
    public static String getTranscoVisionValue(String dataType,String lookupValue ) {
        if ((dataType ==null )||(lookupValue ==null )) return null ;
        for (BwTranscodification__c transco : transcoList) {

            if ((transco.dataType__c == dataType ) && (transco.MbApi__c == lookupValue)) return transco.VsApi__c;
        }
        return null ;
    }

    /**
    * @description 
    * @author SCHIBOUT | 27-09-2021 
    * @param ord 
    * @return Boolean 
    **/
    public static Boolean usedcutomerSegment(Order ord ) {
        for (VISousDomaine__c visDom : usedcutomerSegmentList) {
            if ((ord.ORD_SousDomaine__c   == visDom.Code_API_Sous_domaine__c)||(ord.ORD_BusinessUnit__c  == visDom.Code_BU__c)) return true ;
        }
        return false ;
    }
    /**
    * @description 
    * @author SCHIBOUT | 27-09-2021 
    * @param numClientGpic 
    * @return Account 
    **/
    /*public static Account getSfAccount(String numClientGpic) {

        if( StringUtils.isEmpty(numClientGpic)) return null ;
        List<Account> acctList = [SELECT  Id, Name,AccountNumber  FROM Account WHERE ACC_ERPIdFRA__c  =:numClientGpic LIMIT 1];
        return acctList[0];

    }*/
}