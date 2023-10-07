/*
* @author: Myriam ANTOUN
* @date: 9/18/2019
* @description: Test the inserted or updated Opportunity.
*/

@isTest
public class AP01_Opportunity_Test {
    
    /*
* @author: Myriam ANTOUN
* @date: 9/18/2019
* @description: Create a User, Account, Contact and Opportunity in order to test insertion and update of the Opportnity.
*/

    public static testMethod void oppErrorMSgTest (){
        
        user API = [SELECT USER_ByPassRegleValidation__c 
                    FROM user 
                    WHERE lastName=:label.API
                    LIMIT 1];        
        API.USER_ByPassRegleValidation__c = true;        
        update API;        
        System.runAs(API) {       
            
            Account newAccount = new Account (Name = 'Test Account 1', ShippingCity = 'Lebanon', 
                                              ShippingPostalCode = '123', ACC_SIREN__c = '123456789');
            insert newAccount;
            
            Contact newContact1 = new Contact (AccountId = newAccount.id, FirstName = 'FirstName1',
                                               LastName = 'lastName1', Email = 'test1@test.com');
            insert newContact1;
            
            Contact newContact2 = new Contact (AccountId = newAccount.id, FirstName = 'FirstName2',
                                               LastName = 'lastName2', Email = 'test2@test.com');
            insert newContact2;
            
            
            Opportunity newOpportunity = new Opportunity (AccountId = newAccount.Id, name = 'Test Opportunity For Update Quote',
                                                          closedate = Date.today() + 10, stageName = 'Fermée Gagnée', OPP_Contact__c = newContact1.id);
            
            
            test.startTest();
            try {  
                insert newOpportunity;
                newOpportunity.OPP_Contact__c = newContact2.Id;
                update newOpportunity;
            }             
            catch(DmlException e) {
                System.debug('Error' + e.getMessage());
            }            
            test.stopTest();
        }
    }
}