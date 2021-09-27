public class AP01_Order {
    
    public static void createOrderItem(list<order> Orders){
        
        User APIUser=[SELECT id
                      FROM user
                      WHERE lastname=:label.API];
        
        set<Id> setQuoteIds=new set<Id>();
        
        if(userinfo.getuserid()==APIUser.Id){
            for(order newOrder:Orders){
                setQuoteIds.add(newOrder.quoteId);
            }
            
            map<id,quote> QuotesMap =new map<id,quote>([SELECT Pricebook2Id
                                                        FROM quote
                                                        WHERE Id IN:setQuoteIds
                                                        AND Status=:label.Accepte]);                                   
            
                for(order newOrder:Orders){
                    if(QuotesMap.get(newOrder.QuoteId) != null){
                    newOrder.pricebook2Id=QuotesMap.get(newOrder.QuoteId).pricebook2Id; 
                }
            }
        }
    }
}