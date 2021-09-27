trigger QuoteLineItemBeforeAllEvents on QuoteLineItem (after insert , after update , after delete) {
    List<QuoteLineItem> ListNewQuoteLineItem= new List<QuoteLineItem>();
    if(Trigger.isDelete)
    {
        AP01_QLI_PrincipalProduct.CheckQLI( trigger.oldmap);   
    }
    else
    {
        AP01_QLI_PrincipalProduct.CheckQLI( trigger.newmap);
        for(QuoteLineItem newQLI:Trigger.new)
        {
            if(newQLI.EntiteBW__c!=null && newQLI.EntiteBW__c==Label.BW_ITA)
            {
                ListNewQuoteLineItem.add(newQLI);                
            }
        }
    }
    if(ListNewQuoteLineItem!=null && ListNewQuoteLineItem.size()>0)
    {
           AP01_QLI_PrincipalProduct.AddErrorTableTransco(ListNewQuoteLineItem);
    }
    
}