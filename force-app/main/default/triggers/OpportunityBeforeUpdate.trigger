/*
* @author: Myriam ANTOUN
* @date: 9/18/2019
* @description: Trigger to check that when updateing the Opportunity's Contact, the Contact must be related to Opportunity's Account.
*/

trigger OpportunityBeforeUpdate on Opportunity (before update) {
    if (PAD.canTrigger('AP01_Opportunity')){
        List <Opportunity> oppList = new List <Opportunity> ();
        for (Opportunity opp : trigger.new){
            if (opp.OPP_Contact__c != (trigger.oldMap.get(Opp.id).OPP_Contact__c)){
                oppList.add (opp);
            }
            system.debug('oppList : '+ oppList);
        }        
        if (oppList.size() > 0){
         AP01_Opportunity.oppErrorMSg(oppList);
        }
    }
}