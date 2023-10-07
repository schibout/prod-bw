/*
* @author: Myriam ANTOUN
* @date: 9/18/2019
* @Code Coverage : 92%
* @description: Class to pop an error message when inserting or updating a new Opportunity that has a Contact not related to the Account.
*/

public class AP01_Opportunity {
    /*
* @description: Method to check that when inserting or updating a new Opportunity, the Contact 
* on it must be associated to the Account on it. Otherwise, an error message shows up.
* @param: List of new Opportunities 
* @return : void
*/ 
    public static void oppErrorMSg (List <Opportunity> listNewOpps)
    { 
        Set <Id> accountIds = new Set <Id> ();        
        for (Opportunity iOpp : listNewOpps){
            accountIds.add(iOpp.accountid);
        }       
        
        List <String> accountContactNames = new List <String> ();
        for (AccountContactRelation iAccountContact : [SELECT Contact.name 
                                                       FROM AccountContactRelation
                                                       WHERE accountid IN:accountIds])
        {
            accountContactNames.add(iAccountContact.Contact.name);
        }
        
        for (Opportunity jOpp : listNewOpps){            
            if (jOpp.accountid != null){
                if (jOpp.ContactName__c!=null && !accountContactNames.contains(jOpp.ContactName__c)   ){
                    jOpp.contactid.addError(Label.Ap01_Opp_ErrorMsg);
                }               
            }
        }            
    }
}