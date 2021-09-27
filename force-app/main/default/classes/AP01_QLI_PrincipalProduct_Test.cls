@isTest
public class AP01_QLI_PrincipalProduct_Test {
    
    public static testMethod void test_OrderBeforeInsert()  { 
        
        user API=[SELECT USER_ByPassRegleValidation__c 
                  FROM user 
                  WHERE lastName=:label.API
                  LIMIT 1];
        API.USER_ByPassRegleValidation__c=true;
        
        update API;
        
        System.runAs(API){
            Account newAccount=new Account(Name='Test Account',
                                           ShippingCity='Lebanon',
                                           ShippingPostalCode='123',
                                           ACC_SIREN__c='abcdrftdo',
                                           ACC_Entite_BW__c = '3');
            insert newAccount;
            
            opportunity newOpportunity=new opportunity();
            newOpportunity.name='Test Opportunity';
            newOpportunity.closedate=Date.today() + 10;
            newOpportunity.stageName='Qualification';
            newOpportunity.OPP_Special_Project__c = FALSE;
            newOpportunity.OPP_Domaine__c = Label.Chaudieres;
            newOpportunity.AccountId = newAccount.id;
            insert newOpportunity;
            
            Id StandardPricebookID = Test.getStandardPricebookId();
            Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
            
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
                                     status='4',
                                     DEV_NumCommandeClient__c='123',
                                     pricebook2Id=StandardPricebookID);
            insert Newquote;
            
            QuoteLineItem qutlineitemtest = new QuoteLineItem ();
            qutlineitemtest = new QuoteLineItem(QuoteId = Newquote.id , Quantity = 3.00  ,UnitPrice = 12 , PricebookEntryId = newPricebookEntry.id);
            qutlineitemtest.ELD_MainProduct__c = true;
            
            QuoteLineItem qutlineitemtest2 = new QuoteLineItem ();
            qutlineitemtest2 = new QuoteLineItem(QuoteId = Newquote.id , Quantity = 3.00  ,UnitPrice = 12 , PricebookEntryId = newPricebookEntry.id);
            qutlineitemtest2.ELD_MainProduct__c = false;
            
            list<Quotelineitem> newlist = new list<Quotelineitem>();
            newlist.add(qutlineitemtest);
            newlist.add(qutlineitemtest2);
            test.startTest();
           insert newlist;
            test.stopTest();
           delete qutlineitemtest2;
            
        }
    }
}