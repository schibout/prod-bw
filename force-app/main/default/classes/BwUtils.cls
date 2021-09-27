public with sharing class BwUtils {
    
    static List<BwTranscodification__c> transcoList = [SELECT Id, MbApi__c,dataType__c,VsApi__c FROM BwTranscodification__c];
    public static String getTranscoVisionValue(String dataType,String lookupValue ) {
        if ((dataType ==null )||(lookupValue ==null )) return null ;
        for (BwTranscodification__c transco : transcoList) {

            if ((transco.dataType__c == dataType ) && (transco.MbApi__c == lookupValue)) return transco.VsApi__c;
        }
        return null ;
    }
}