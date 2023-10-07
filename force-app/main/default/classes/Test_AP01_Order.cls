@isTest
public class Test_AP01_Order {
    
    public static testMethod void test_OrderBeforeInsert()  { 
        
        user API=[SELECT USER_ByPassRegleValidation__c 
                  FROM user 
                  WHERE lastName=:label.API
                  LIMIT 1];
        API.USER_ByPassRegleValidation__c=true;
        
        update API;
        
        System.runAs(API){
            
            opportunity newOpportunity=new opportunity();
            newOpportunity.name='Test Opportunity';
            newOpportunity.closedate=Date.today() + 10;
            newOpportunity.stageName='Qualification';
            insert newOpportunity;
            
            Id StandardPricebookID = Test.getStandardPricebookId();
            
            quote Newquote=new quote(Name='Test quote',
                                     opportunityId=newOpportunity.Id,
                                     status='3',
                                     DEV_NumCommandeClient__c='123',
                                     pricebook2Id=StandardPricebookID);
            insert Newquote;
            
            Account newAccount=new Account(Name='Test Account',
                                           ShippingCity='Lebanon',
                                           ShippingPostalCode='123',
                                           ACC_SIREN__c='abcdrftdo');
            insert newAccount;
            
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
            
            
            system.assert(Orderpricebook.pricebook2Id==Newquote.pricebook2Id);
            
        }
    }
}