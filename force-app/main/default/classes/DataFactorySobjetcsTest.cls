@isTest
public class DataFactorySobjetcsTest {

    @IsTest
    static void methodName(){
        User contextuser = DataFactorySobjetcs.getApiUser();
        Test.startTest();
        System.runAs(contextuser){
        
            List<Account> accountList = DataFactorySobjetcs.getAccounts();
            for (Account acct : accountList) {
                System.debug(acct.name);
            }
            System.assertEquals('TEST_1', accountList[0].name,'Premier test Account ne passe pas ');
            System.assertEquals('TEST_2', accountList[1].name,'Premier test Account  ne passe pas ');
            List<Opportunity> opportunityList = DataFactorySobjetcs.getOpportunitys();
             for (Opportunity oppy : opportunityList) {
                System.debug(oppy.Description);
            }
            System.assertEquals('TEST_1', opportunityList[0].Description,'Premier test Opportunity ne passe pas ');
            System.assertEquals('TEST_2', opportunityList[1].Description,'Premier test Opportunity ne passe pas ');
            
            //List<Order> OrderList = DataFactorySobjetcs.getOrders();
            /*System.assertEquals('TEST_1', OrderList[0].Name,'Premier test Order ne passe pas ');
            System.assertEquals('TEST_2', OrderList[1].Name,'Premier test Order ne passe pas ');
          */
            List<Product2> Product2List = DataFactorySobjetcs.getProduct2s();
            for (Product2 oppy : Product2List) {
                System.debug(oppy.Name);
            }
            /*System.assertEquals('TEST_1', Product2List[0].Name,'Premier test Product2 ne passe pas ');
            System.assertEquals('TEST_2', Product2List[1].Name,'Premier test Product2 ne passe pas ');
            
            List<Quote> QuoteList = DataFactorySobjetcs.getQuotes();
            for (Quote oppy : QuoteList) {
                System.debug(oppy.Name);
            }
            System.assertEquals('TEST_1', QuoteList[0].Name,'Premier test Quote ne passe pas ');
            System.assertEquals('TEST_2', QuoteList[1].Name,'Premier test Quote ne passe pas ');*/
        Test.stopTest();
        
    }
}
    
}