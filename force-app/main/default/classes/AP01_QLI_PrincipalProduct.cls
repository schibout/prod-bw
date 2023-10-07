/*
* Class to check principal product and return error
* @author: Joyce Saidy
* @date: 18-09-2020
* @Test: AP01_QLI_PrincipalProduct_Test
*/
public class AP01_QLI_PrincipalProduct{
    
    public static void CheckQLI(Map<id,Quotelineitem> NewMapQLI)
    {
        
        Set<Id> SetIdQuotes = new Set<Id>();
        Map<id,id> MapOLIidByQuoteid = new  Map<id,id>();
        for(Quotelineitem qli : NewMapQLI.values())
        {
            SetIdQuotes.add(qli.quoteid);
            MapOLIidByQuoteid.put(qli.quoteid, qli.Id);
        }
        
        map <Id, quote> mapIDQuote =  new map <Id, quote>([SELECT id,Opportunity.OPP_Special_Project__c, Opportunity.OPP_Domaine__c, Opportunity.Account.ACC_Entite_BW__c, 
                                                           (select id , ELD_MainProduct__c from QuoteLineItems where ELD_MainProduct__c = True) 
                                                           from quote 
                                                           where Id in :SetIdQuotes
                                                           and Opportunity.OPP_Special_Project__c = FALSE
                                                           and Opportunity.Account.ACC_Entite_BW__c = :Label.BW_ITA
                                                           and( Opportunity.OPP_Domaine__c = :Label.Chaudieres 
                                                               or Opportunity.OPP_Domaine__c=: Label.Traitement_de_leau
                                                               or Opportunity.OPP_Domaine__c= :Label.Air)
                                                          ]); 
        
        if(mapIDQuote != null && mapIDQuote.size()>0)
        {
            For(quote Q : mapIDQuote.values())
            { 
                if(q.QuoteLineItems.size() == 0)
                {
                    NewMapQLI.get(MapOLIidByQuoteid.get(q.id)).addError(label.AP01_QLI_ErrorMsg1) ;
                }
                else if(q.QuoteLineItems.size() > 1)
                {
                    NewMapQLI.get(MapOLIidByQuoteid.get(q.id)).addError(label.AP01_QLI_ErrorMsg2) ; 
                }
            }
            
        }
        
        
    }
    public static void AddErrorTableTransco(List<Quotelineitem> ListNewQLI)
    {
        Map<String, String> tabletranscodagemap = new Map<String, String>();
        List<Table_de_transcodage__c> tabletranscodage = [SELECT Serie__c, Code__c
                                                          FROM Table_de_transcodage__c];
        
        //assign values in the Map<Serie,Code>
        for (Table_de_transcodage__c tb : tabletranscodage) 
        {
            tabletranscodagemap.put(tb.Serie__c, tb.Code__c);  
        }
       for(Quotelineitem NewQLI:ListNewQLI)
       {
          if (NewQLI.SerieProduit__c!=null && tabletranscodagemap.containsKey(NewQLI.SerieProduit__c) && tabletranscodagemap.get(NewQLI.SerieProduit__c)==null)
            { 
                NewQLI.addError(System.Label.Value_not_in_table_de_transcodage);
            }
       }
    }
}