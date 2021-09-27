@isTest 
public class VFE001_CloneQuoteQLI_Test {
    
    static testMethod void VFE001_CloneQuoteQLITest() {
        User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
        u.USER_ByPassRegleValidation__c=true;
        u.USER_EntiteBW__c=Label.BW_ITA;
        Update u;
        System.runAs(u) {
            Account newAccount = new Account (Name = 'Test Account 1', ShippingCity = 'Lebanon', 
                                              ShippingPostalCode = '123', ACC_SIREN__c = '123456789');
            newAccount.ACC_Entite_BW__c=Label.BW_ITA ;
            newAccount.ACC_Langue_Documentation__c='4';
            insert newAccount;
            opportunity newOpportunity=new opportunity();
            newOpportunity.name='Test Opportunity';
            newOpportunity.closedate=Date.today() + 10;
            newOpportunity.stageName='Qualification';
            newOpportunity.AccountId=newAccount.id;
            insert newOpportunity;
            product2 newproduct2=new product2(Name='Test product',IsActive=true);
            insert newproduct2;
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true );
            update standardPricebook;
            Id StandardPricebookID = Test.getStandardPricebookId();
            PricebookEntry newPricebookEntry=new PricebookEntry(pricebook2Id=StandardPricebookID,
                                                                product2Id=newproduct2.Id,
                                                                unitPrice=200,
                                                                UnitePrixPar__c='Heure',
                                                                IsActive=true);
            insert newPricebookEntry;
            quote Newquote=new quote(Name='Test quote',
                                     opportunityId=newOpportunity.Id,
                                     status='1',
                                     DEV_Ajout_Piece_Jointe__c=false,
                                     DEV_NumCommandeClient__c='123',
                                     DEV_Charg_daffaire__c = UserInfo.getUserId(),
                                     pricebook2Id=StandardPricebookID);
            insert Newquote;
            QuoteLineItem qutlineitemtest = new QuoteLineItem ();
            qutlineitemtest = new QuoteLineItem(QuoteId = Newquote.id , Quantity = 3.00  ,UnitPrice = 12 , PricebookEntryId = newPricebookEntry.id);
            //qutlineitemtest.ELD_MainProduct__c = true;
            insert qutlineitemtest;
            ApexPages.StandardController controller = new ApexPages.StandardController(Newquote);
            test.startTest();
            VFE001_CloneQuoteQLI vfe07 = new VFE001_CloneQuoteQLI(controller);
            vfe07.cloneQuoteWithQLI();
            test.stopTest();
        }
    }
    
}