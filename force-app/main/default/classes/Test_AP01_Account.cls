@isTest
public class Test_AP01_Account {
    
    public static testMethod void test_AccountAfterUpdate()  { 
        
        user API=[SELECT USER_ByPassRegleValidation__c 
                  FROM user 
                  WHERE lastName=:label.API
                  LIMIT 1];
        API.USER_ByPassRegleValidation__c=true;
        
        update API;
        
        System.runAs(API){
            
           Account newAccount=new Account(Name='Test Account For Update Quote',
                                           ShippingCity='Lebanon',
                                           ShippingPostalCode='123',
                                           RecordTypeId = '0120O000000kqhw',
                                           ACC_SIREN__c='123456789');
            insert newAccount;
            
            opportunity newOpportunity=new opportunity();
            newOpportunity.AccountId = newAccount.Id;
            newOpportunity.name='Test Opportunity For Update Quote';
            newOpportunity.closedate=Date.today() + 10;
            newOpportunity.stageName='Fermée Gagnée';
            insert newOpportunity;
            
            Id StandardPricebookID = Test.getStandardPricebookId();
            
            quote Newquote=new quote(Name='Test quote For Update Quote',
                                     opportunityId=newOpportunity.Id,
                                     status='3',
                                     DEV_TypeDeDevis__c = '1',
                                     DEV_NumCommandeClient__c='123',
                                     pricebook2Id=StandardPricebookID);
            insert Newquote;
            
         
           /* 
            list<order> listNewOrders=new list<order>();
            
            order newOrder1=new Order();
            newOrder1.AccountId=newAccount.Id;
            newOrder1.EffectiveDate=Date.today() + 10;
            newOrder1.status='3';
            newOrder1.quoteId=Newquote.Id;
            listNewOrders.add(newOrder1);
            
            order newOrder2=new Order();
            newOrder2.AccountId=newAccount.Id;
            newOrder2.EffectiveDate=Date.today() + 10;
            newOrder2.status='3';
            newOrder2.quoteId=Newquote.Id;
            listNewOrders.add(newOrder2);
            
            insert listNewOrders;
            
            order Orderpricebook=[SELECT pricebook2Id
                                  FROM order
                                  LIMIT 1]; 
            
            */
            
           test.startTest();
            
            newAccount.RecordTypeId = '0120O000000kqi1'; 
            update newAccount;
        
           test.stopTest();
           

            List <Quote> listNewQuotes=[SELECT Id, Tech_Talend_Export_Devis__c 
                                  FROM Quote
                                  where Id =: Newquote.Id
                                  LIMIT 1]; 
            
           system.assert(listNewQuotes[0].Tech_Talend_Export_Devis__c , True);
            
        }
    }
}