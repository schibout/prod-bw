@isTest
public class BatchAccountVisionSynchroTest {
		@IsTest
 		static void methodName(){
        user API=[SELECT USER_ByPassRegleValidation__c, USER_ByPassProcessBuilder__c
        FROM user 
        WHERE lastName=:label.API
        LIMIT 1];

        API.USER_ByPassRegleValidation__c=true;
        API.USER_ByPassProcessBuilder__c = true;

        update API;
        Test.startTest();
        System.runAs(API){
        
        System.debug('Setup data'+getPicklistValues('Account','ACC_Region__c'));
        //List<Account> acctList = Test.loadData(Account.sObjectType, 'Account');
        Account newAccount=new Account(Name='BatchAccountVisionSynchroTest',
        ShippingCity='Lebanon',
        ACC_Entite_BW__c='1',
        ShippingPostalCode='123',
		RecordTypeId = '0120O000000kqi1',
		ACC_SecteurCommercial__c='1',
        ACC_Region__c = '1',
        ACC_SIREN__c='123456789');
        insert newAccount;
        
        List<Account> acctListResult =[SELECT Name FROM Account WHERE Name LIKE 'BatchAccountVisionSynchroTest'];
        System.assertEquals(1, acctListResult.size() , 'Not Good' );

        List<BwTranscodification__c> transcoList = new List<BwTranscodification__c>();
        transcoList.add(new BwTranscodification__c(DataType__c='Sous domaine',MbApi__c='36',VsApi__c='LOC'));
        transcoList.add(new BwTranscodification__c(DataType__c='BU',MbApi__c='36',VsApi__c='LOC'));
        transcoList.add(new BwTranscodification__c(DataType__c='Agence Régionale',MbApi__c='1',VsApi__c='LOC'));
        transcoList.add(new BwTranscodification__c(DataType__c='Secteur',MbApi__c='1',VsApi__c='LOC'));
        Database.insert(transcoList,false);
		System.assertEquals(4, transcoList.size() , 'BwTranscodification__c Not Good' );
    
        BatchAccountVisionSynchro.run();
        /*List<Account> acctList1 =[SELECT Id,ACC_SecteurCommercial__c,Acc_CodeSecteur__c,Acc_CodeAgence__c,ACC_Region__c  FROM Account WHERE Name LIKE 'BatchAccountVisionSynchroTest'];
        
        system.assertEquals (acctList1.size() , 1,'Not Equals Test Methode');
        For(Account acct :acctList1) {
         System.assertEquals('LOC', acct.Acc_CodeSecteur__c,'Code secteur');
         System.assertEquals('LOC', acct.Acc_CodeAgence__c,'Code region');
        }*/

    }
}
     /**
   * 
   */
        public static List<String> getPicklistValues(String objectApiName,String fieldName){ 

            List<String> lstPickvals=new List<String>();
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectApiName);//From the Object Api name retrieving the SObject
            Sobject objectName = targetType.newSObject();
            Schema.sObjectType sobjectType = objectName.getSObjectType(); //grab the sobject that was passed
            Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap(); //get a map of fields for the passed sobject
            List<Schema.PicklistEntry> pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
            for (Schema.PicklistEntry a : pickListValues) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }

        return lstPickvals;
        }
}