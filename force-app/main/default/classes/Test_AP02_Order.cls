@isTest
public class Test_AP02_Order {
    
    public static testMethod void test_OrderBeforeInsert()  { 
        
        user API=[SELECT USER_ByPassRegleValidation__c, USER_ByPassProcessBuilder__c
                  FROM user 
                  WHERE lastName=:label.API
                  LIMIT 1];
        
        API.USER_ByPassRegleValidation__c=true;
        API.USER_ByPassProcessBuilder__c = true;
        
        update API;
        
        System.runAs(API){
            
            
            opportunity newOpportunity=new opportunity();
            newOpportunity.name='Test Opportunity';
            newOpportunity.closedate=Date.today() + 10;
            newOpportunity.stageName='Qualification';
            insert newOpportunity;
            
            
            Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true );
        	update standardPricebook;
            Id StandardPricebookID = Test.getStandardPricebookId();
            
            
            product2 newproduct2=new product2(Name='Test product',IsActive=true);
            insert newproduct2;
            
            PricebookEntry newPricebookEntry=new PricebookEntry(pricebook2Id=StandardPricebookID,
                                                                product2Id=newproduct2.Id,
                                                                unitPrice=200,
                                                                UnitePrixPar__c='Heure',
                                                                IsActive=true);
            insert newPricebookEntry;
            
            
            quote Newquote=new quote(Name='Test quote',
                                     opportunityId=newOpportunity.Id,
                                     status='3',
                                     DEV_NumCommandeClient__c='123',
                                     pricebook2Id=StandardPricebookID);
            insert Newquote;
            
            
            quoteLineItem newquoteLineItem=new quoteLineItem(product2Id=newproduct2.Id,
                                                             quantity=2,
                                                             quoteId=Newquote.Id,
                                                             pricebookentryId=newPricebookEntry.Id,
                                                             unitPrice=200);
            insert newquoteLineItem;
            
            
            Account newAccount=new Account(Name='Test Account');
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
            
            orderItem OrderItem=[SELECT OrderId,Product2Id,quantity,UnitPrice,PricebookentryId
                                 FROM orderItem
                                 LIMIT 1];
            
            
            system.assert(OrderItem.OrderId==listNewOrders[0].Id);
            system.assert(OrderItem.Product2Id == newquoteLineItem.product2Id);
            system.assert(OrderItem.quantity == newquoteLineItem.quantity);
            system.assert(OrderItem.UnitPrice == newquoteLineItem.UnitPrice);
            system.assert(OrderItem.PricebookentryId == newQuoteLineItem.PricebookentryId);
            
        }
    }
}