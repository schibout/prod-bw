/**
* @description       : 
* @author            : SCHIBOUT
* @group             : 
* @last modified on  : 13-10-2021
* @last modified by  : SCHIBOUT
**/
public class DataFactorySobjetcs {
    
    
    /**
    * @description 
    * @author SCHIBOUT | 08-10-2021 
    * @param accountName 
    * @return Account 
    **/
    public static Account CreateSingleAccounts (String accountName, Boolean insertNow) { 
        
        Account newAccount=new Account(Name='BatchAccountVisionSynchroTest',
        ShippingCity='Lebanon',
        ACC_Entite_BW__c='1',
        ShippingPostalCode='123',
        RecordTypeId = '0120O000000kqi1',
        ACC_SecteurCommercial__c='1',
        ACC_Region__c = '1',
        ACC_SIREN__c='123456789');
        if (insertNow) insert newAccount;
        return newAccount;
    }
    
    public static List<HeaderGpicFile__c> getFileHerders() {
        
        //List<HeaderGpicFile__c> = System.Test.loadData(sobjectType, staticResourceName)
        return (System.Test.loadData(HeaderGpicFile__c.sObjectType, 'gpicFile'));
    }
    /**
    * @description 
    * @author SCHIBOUT | 11-10-2021 
    * @param AccountId 
    * @param closeDate 
    * @param stageName 
    * @param entryName 
    * @param insertNow 
    * @return Opportunity 
    **/
    public static Opportunity createSingleOppy(Id AccountId,Date closeDate,String stageName, String entryName, Boolean insertNow){
        opportunity Opp =new opportunity(AccountId = AccountId,
        closedate=closeDate,
        stageName=stageName,
        Name = entryName);
        if (insertNow) insert Opp;
        return Opp;                         
    }
    
    public static Opportunity createOppyWithAccount(String entryName, Boolean insertNow) {
        Account acct = CreateSingleAccounts(entryName, true);
        Opportunity oppy = createSingleOppy(acct.Id, Date.today() +30 , 'Qualification', entryName, insertNow);
        return Oppy ;
    }
    
    public static Order createSingleOrderWithOppyAndAccount(String entryName) {
        return null ;
    }
    
    public static User getRandomUser() {
        return [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
    }
    
    /**
    * @description 
    * @author SCHIBOUT | 08-10-2021 
    * @param objectApiName 
    * @param fieldName 
    * @return List<String> 
    **/
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
    public static List<Account> getAccounts () {
        
        return (System.Test.loadData(Account.sObjectType, 'Account'));
    }
    
    /**
    * @description 
    * @author SCHIBOUT | 12-10-2021 
    * @return List<Opportunity> 
    **/
    public static List<Opportunity> getOpportunitys () {
        
        return (System.Test.loadData(Opportunity.sObjectType, 'Opportunity'));
    }
    /**
    * 
    */
    public static List<Product2> getProduct2s () {
        
        return (System.Test.loadData(Product2.sObjectType, 'Product2'));
    }
    
    /**
    * @description 
    * @author SCHIBOUT | 12-10-2021 
    * @return User 
    **/
    public static User getApiUser() {
        
        User API=[SELECT Id, USER_ByPassRegleValidation__c, USER_ByPassProcessBuilder__c
        FROM User 
        WHERE lastName=:label.API
        LIMIT 1];
        API.USER_ByPassRegleValidation__c=true;
        API.USER_ByPassProcessBuilder__c = true;
        update API;
        return API;
        
    }   
    
    /**
    * @description 
    * @author SCHIBOUT | 12-10-2021 
    * @return Id 
    **/
    public static Id getPricebookId(){
        Pricebook2 standardPricebook = new Pricebook2(
        Id = Test.getStandardPricebookId(),
        IsActive = true );
        update standardPricebook;
        Id StandardPricebookID = Test.getStandardPricebookId();
        return StandardPricebookID ;       
    }
    
    /**
    * @description 
    * @author SCHIBOUT | 12-10-2021 
    * @param entryName 
    * @param insertNow 
    * @return Quote 
    **/
    public static Quote createSingleQuote(String entryName,Boolean insertNow) {
        Opportunity Oppy = createOppyWithAccount(entryName, true);
        Id StandardPricebookID = getPricebookId();
        Quote Newquote=new quote(Name=entryName,
        opportunityId=Oppy.Id,
        status='4',
        pricebook2Id=StandardPricebookID,
        DEV_Charg_daffaire__c=getRandomUser().Id
        );
        if (insertNow) insert Newquote;
        return Newquote ;                              
    }
    
    public static QuoteLineItem createQuoteLineItem (Id QuoteId, Decimal Quantity ,Boolean insertNow) {
        QuoteLineItem qutlineitemtest = new QuoteLineItem(QuoteId = QuoteId , Quantity = Quantity  ,UnitPrice = 12 , PricebookEntryId = createPricebookEntry(true).Id);
        if (insertNow) insert qutlineitemtest;
        return qutlineitemtest ;     
    }
    /**
    * 
    */
    public static Product2 createProduct(Boolean insertNow) {
        product2 newproduct2=new product2(Name='Test product',IsActive=true);
        if (insertNow) insert newproduct2;
        return newproduct2 ; 
    }
    
    public static PricebookEntry createPricebookEntry(Boolean insertNow) {
        PricebookEntry newPricebookEntry=new PricebookEntry(pricebook2Id=getPricebookId(),
        product2Id=createProduct(true).Id,
        unitPrice=200,
        UnitePrixPar__c='Heure',
        IsActive=true);
        if (insertNow) insert newPricebookEntry;
        return newPricebookEntry ; 
    }
    
    public static Order createSingleOrder(Quote qte,Boolean insertNow) {
        order newOrder=new Order();
        newOrder.EffectiveDate=Date.today() ;
        newOrder.ORD_MontantHT_ERP__c =200 ;
        newOrder.quoteId = qte.Id ;
        newOrder.AccountId=qte.AccountId ;
        newOrder.status='3';
        if (insertNow) insert newOrder;
        return newOrder ; 
        
    }
    
    public static Order createFullSingleOrder(String entryName,Boolean insertNow) {
        Quote qte = createSingleQuote(entryName, insertNow);
        QuoteLineItem qlte = createQuoteLineItem (qte.Id, 10 , insertNow);
        order newOrder=new Order();
        newOrder.EffectiveDate=Date.today() ;
        newOrder.ORD_MontantHT_ERP__c =200 ;
        newOrder.quoteId = qte.Id ;
        newOrder.AccountId=qte.AccountId ;
        newOrder.status='3';
        if (insertNow) insert newOrder;
        return newOrder ; 
        
    }
}