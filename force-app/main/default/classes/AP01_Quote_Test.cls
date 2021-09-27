@isTest
public class AP01_Quote_Test {
    
    @isTest 
    static  void AddAttachment() {
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
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true );
        update standardPricebook;
        Id StandardPricebookID = Test.getStandardPricebookId();
        
        quote Newquote=new quote(Name='Test quote',
                                 opportunityId=newOpportunity.Id,
                                 status='1',
                                 DEV_Ajout_Piece_Jointe__c=false,
                                 DEV_NumCommandeClient__c='123',
                                 DEV_Charg_daffaire__c = UserInfo.getUserId(),
                                 pricebook2Id=StandardPricebookID);
        insert Newquote;
        
        
        quote Newquote3=new quote(Name='Test quote 3',
                                 opportunityId=newOpportunity.Id,
                                 status='2', 
                                 DEV_Ajout_Piece_Jointe__c=false,
                                 DEV_DelaisLivraison__c=22,
                                 DEV_Charg_daffaire__c = UserInfo.getUserId(),
                                 pricebook2Id=StandardPricebookID);
        insert Newquote3;
        
        //contentversion creation
        ContentVersion cv1 = new ContentVersion();
        cv1.title = 'Tariffe estero_ita'; 
        cv1.PathOnClient = 'Tariffe estero_ita.pdf';
        cv1.VersionData =Blob.valueOf('Unit Test Attachment Body');
        insert cv1;
        
        
        Quote NewQuote2 = [select id from quote where id =: Newquote.Id];
        NewQuote2.DEV_Ajout_Piece_Jointe__c=true; 
        update NewQuote2;
        
        List<Quote> lstQuote = new List<Quote>();
        
        Map<Id, Quote> oldmap = new Map<Id, Quote> (); 
        oldmap.put(Newquote3.Id, Newquote3);
        List<ContentDocumentLink> CheckCDL =[select id, LinkedEntity.id from ContentDocumentLink where LinkedEntity.id=:NewQuote2.id];
       // system.assertEquals(1, CheckCDL.size());
        Test.startTest();
        Newquote3.Status = '3'; 
       	update Newquote3;
        lstQuote.add(Newquote3);
        AP01_Quote.updateDateLivraisonOppt(lstQuote, oldmap);
        Test.stopTest();
    }
    }
}