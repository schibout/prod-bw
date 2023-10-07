trigger OrderBeforeInsert on Order (before insert) {
    list<order> listNewOrders=new list<order>();
    
    for(order newOrder:trigger.new){
        if((newOrder.status==label.En_cours
            ||newOrder.status==label.Facturee
            ||newOrder.status==label.Reglee)
           && newOrder.quoteId!= null)
        {
            if((newOrder.Account_Entit_BW__c <> label.BW_ITA && newOrder.ORD_BusinessUnit__c != label.Services) || newOrder.Account_Entit_BW__c == label.BW_ITA) {
            listNewOrders.add(newOrder);
            }
            
        }
    }
    if(listNewOrders.size()>0){
        AP01_Order.createOrderItem(listNewOrders);
        
    }
}