public class AP01_Account{
 
  public static void updateTechTalendExportDevis(List<Account> newAccounts)
      {
      
        Set<Id> accountset = new Set<Id>();
        
     
        for (Account acc : newAccounts) {
          accountset.add(acc.Id); 
        }
       
        //list <Quote> ListQuotes = new List <Quote>();
      Opportunity [] ListOpportunites=new Opportunity[]{};  
      Quote [] ListQuotes=new Quote[]{};
      Quote [] ListQuotesToUpdate=new Quote[]{};    
        

       
        
        map <Id, Account> mapAccountToOpportunities = 
        new map <Id, Account>([Select Id, 
                                   (Select Id
                                   From Opportunities where (StageName = 'Fermée Gagnée'))
                              From Account
                              where Id in :accountset]); 

       system.debug ('mapAccountToOpportunities :'+ mapAccountToOpportunities );
       
       
        map <Id, Opportunity> mapOpportunityToQuotes = 
        new map <Id, Opportunity>([Select Id, (Select Tech_Talend_Export_Devis__c 
        From Quotes where (Tech_Talend_Export_Devis__c = False AND Status = '3' AND (DEV_TypeDeDevis__c = '1' OR DEV_TypeDeDevis__c = '3'))) 
        From Opportunity where (StageName = 'Fermée Gagnée' AND AccountId in :newAccounts)]);
       system.debug ('mapOpportunityToQuotes:'+ mapOpportunityToQuotes);
            
    
      if (mapAccountToOpportunities.values().size()>0) {
       system.debug ('mapAccountToOpportunities.values():'+ mapAccountToOpportunities.values());
       
        for(Account acc : mapAccountToOpportunities.values()) {
         ListOpportunites = acc.Opportunities;
          system.debug ('ListOpportunites :'+ ListOpportunites);
           
       
         for(Opportunity opp : ListOpportunites ) {
         Opportunity oppEncours = mapOpportunityToQuotes.get(opp.Id);
         
           ListQuotes = oppEncours.Quotes;
           system.debug ('ListQuotes :'+ ListQuotes );
           
            for (Quote qu : ListQuotes) 
            {
             qu.Tech_Talend_Export_Devis__c = True;
             system.debug ('qu.Tech_Talend_Export_Devis__c:'+ qu.Tech_Talend_Export_Devis__c);
             ListQuotesToUpdate.add(qu);
           }
         } 
        }
     
       }
       if (ListQuotesToUpdate.size() >0) {     
       update ListQuotesToUpdate;  
        }
      }
   }