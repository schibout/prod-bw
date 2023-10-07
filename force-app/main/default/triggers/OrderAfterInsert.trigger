trigger OrderAfterInsert on Order (after insert) {
    
    list<order> listNewOrders=new list<order>();
    
    for(order newOrder:trigger.new){
        
        if(newOrder.statusCode==label.Draft
           && newOrder.quoteId!=null ){
               system.debug(newOrder.Account_Entit_BW__c == label.BW_ITA);
              system.debug(newOrder.Account_Entit_BW__c <> label.BW_ITA && newOrder.ORD_BusinessUnit__c != label.Services);
               if((newOrder.Account_Entit_BW__c <> label.BW_ITA && newOrder.ORD_BusinessUnit__c !=label.Services) || newOrder.Account_Entit_BW__c == label.BW_ITA) {
                   listNewOrders.add(newOrder);
               }
           }
    }
    
    if(listNewOrders.size()>0){
        
        AP02_Order.createOrderItem(listNewOrders);
    }
}