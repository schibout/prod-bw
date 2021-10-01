/**
 * @description       : 
 * @author            : SCHIBOUT
 * @group             : 
 * @last modified on  : 29-09-2021
 * @last modified by  : SCHIBOUT
**/
@IsTest
public  class BwUtilsTest {
    
    @IsTest
    static void methodName(){
        User contextuser = DataFactorySobjetcs.getApiUser();    
        Test.startTest();
        System.runAs(contextuser){
            BwTranscodification__c  trs =  new BwTranscodification__c();
            trs.dataType__c ='BU';
            trs.MbApi__c='MBTest';
            trs.VsApi__c='VsTest';
            insert trs;
            
            String CalculatedValue = BwUtils.getTranscoVisionValue(null,null );
            System.assertEquals(null, CalculatedValue,'Null not managed');
            CalculatedValue = BwUtils.getTranscoVisionValue('BU','MBTest' );
            System.assertEquals('VsTest', CalculatedValue,'Field Complete');
            CalculatedValue = BwUtils.getTranscoVisionValue('BU','DataNotFound' );
            System.assertEquals(null, CalculatedValue,'Data Not Found ');
        }
        Test.stopTest();
        
    }
}