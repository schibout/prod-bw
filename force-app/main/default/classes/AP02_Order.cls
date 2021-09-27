public class AP02_Order {
    
    public static void createOrderItem(list<order> Orders){
        
        User APIUser=[SELECT id
                      FROM user
                      WHERE lastname=:label.API];
        
        set<Id> setQuoteIds=new set<Id>();
        
        if(userinfo.getuserid()==APIUser.Id){
            for(order newOrder:Orders){
                setQuoteIds.add(newOrder.quoteId);
            }
            
            list<OrderItem> listNewOrderItems=new list<OrderItem>();
            
            map<id,quote> mapQuotes=new map<id,quote>([SELECT Id, Pricebook2Id, (SELECT product2Id,quantity,unitPrice,PricebookentryId
                                                                  FROM quoteLineItems)
                                                       FROM quote
                                                       WHERE Id IN:setQuoteIds
                                                       AND Status=:label.Accepte]);
                                                       
            system.debug('mapQuotes: ' + mapQuotes);
            for(order newOrder:Orders){
                if(mapQuotes.containsKey(newOrder.quoteId)){
                    for(quoteLineItem newQuoteLineItem:mapQuotes.get(newOrder.quoteId).quoteLineItems){
                        
                        OrderItem newOrderItem= new OrderItem();
                        newOrderItem.OrderId = newOrder.Id;
                        newOrderItem.Product2Id = newQuoteLineItem.product2Id;
                        newOrderItem.quantity = newQuoteLineItem.quantity;
                        newOrderItem.UnitPrice = newQuoteLineItem.UnitPrice;
                        newOrderItem.PricebookentryId = newQuoteLineItem.PricebookentryId;
                        listNewOrderItems.add(newOrderItem);
                        
                    }
                }
            }
            if(listNewOrderItems.size()>0){
                
                insert listNewOrderItems;
            }
        }
    }
}