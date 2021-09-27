public class DataFactorySobjetcs {

   /**
    *  */ 
   public static List<Account> getAccounts () {

    return (System.Test.loadData(Account.sObjectType, 'Account'));
   }
   /**
    * 
   */
   /*public static List<Order> getOrders () {

    return (System.Test.loadData(Order.sObjectType, 'Order'));
   } 
   */
   /**
    * 
   */
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
    * 
    */
    /*public static List<Quote> getQuotes () {

        return (System.Test.loadData(Quote.sObjectType, 'Quote'));
       }
   */
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
}