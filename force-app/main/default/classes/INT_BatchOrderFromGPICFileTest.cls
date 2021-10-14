/**
* @description       : 
* @author            : SCHIBOUT
* @group             : 
* @last modified on  : 12-10-2021
* @last modified by  : SCHIBOUT
**/
@isTest
public with sharing class INT_BatchOrderFromGPICFileTest {
    private List<Quote> qteList = new List<Quote>();
    /*@TestSetup
    static void makeData(){
        
        List<HeaderGpicFile__c> headerFiles = DataFactorySobjetcs.getFileHerders();
        List<Quote> qteList = new List<Quote>();
        for (HeaderGpicFile__c fileDate : headerFiles) {
            System.debug(fileDate.NumeroDevis__c) ; 
            Quote qte = DataFactorySobjetcs.CreateSingleQuote('Gpic Test '+fileDate.NumeroDevis__c,false);
            qte.DEV_Tech_QuoteNumber_ExternalId__c = fileDate.NumeroDevis__c;
            qteList.add(qte);
        }
        insert (qteList) ;
    }*/
    
    @IsTest
    static void testOrderCreation(){
        User contextuser = DataFactorySobjetcs.getApiUser();
        Test.startTest();
        System.runAs(contextuser){
            
            List<Quote> qteList = getQuoteFromGpicFile();
            INT_BatchOrderFromGPICFile.run();
        }
        Test.stopTest();
        
    }
    
    @IsTest
    static void testAvenant(){
        
        User contextuser = DataFactorySobjetcs.getApiUser();
        Test.startTest();
        System.runAs(contextuser){
            List<Order> oderList = new List<Order>();
            List<Quote> qteList = getQuoteFromGpicFile();
            for (Quote qte : qteList) {
                DataFactorySobjetcs.createSingleOrder(qte, true);
                //oderList.add(DataFactorySobjetcs.createSingleOrder(qte, false));
            }
            //Database.SaveResult[] srList = Database.insert (oderList, false);
            // Iterate through each returned result
            /*for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully Order account. Account ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Order fields that affected this error: ' + err.getFields());
                    }
                }
            }*/
            INT_BatchOrderFromGPICFile.run();
        }
        Test.stopTest();
        
    }
    
    public static List<Quote> getQuoteFromGpicFile() {
        //insert Data
        List<HeaderGpicFile__c> headerFiles = DataFactorySobjetcs.getFileHerders();
        List<Quote> qteList = new List<Quote>();
        for (HeaderGpicFile__c fileDate : headerFiles) {
            Quote qte = DataFactorySobjetcs.CreateSingleQuote('Gpic Test '+fileDate.NumeroDevis__c,false);
            qte.DEV_Tech_QuoteNumber_ExternalId__c = fileDate.NumeroDevis__c;
            qte.DEV_NumCommandeClient__c=fileDate.ReferenceClient__c ;
            qteList.add(qte);
            System.debug(qte.DEV_Tech_QuoteNumber_ExternalId__c);
        }
        System.debug(qteList) ;
        insert (qteList) ;
        List<QuoteLineItem> qteLineList = new List<QuoteLineItem>();
        for (Quote qte : qteList) {
            qteLineList.add(DataFactorySobjetcs.createQuoteLineItem(qte.Id, 10,false));
        }
        insert (qteLineList);
        return qteList ;
    }
}
