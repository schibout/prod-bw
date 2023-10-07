/*
* @author: Myriam ANTOUN
* @date: 9/18/2019
* @description: Trigger to check that when inserting a new Opportunity, its Contact must be related to its Account.
*/

trigger OpportunityBeforeInsert on Opportunity (before insert) {
 if (PAD.canTrigger('AP01_Opportunity')){    
   AP01_Opportunity.OppErrorMSg(trigger.new);
 }
}