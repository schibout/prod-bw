/*
* @author: Henri Saslawsky
* @date: 16/12/20202
* @description: Trigger to check that when changing a VIAchat
*/

trigger VIAchat_Trigger on VIAchat__c (before insert, before update, before delete,
                                                     after insert,  after update,  after delete) {
 if (!VIUtils.ByPassTrigger()){  

     if (Trigger.isBefore) {
         if (Trigger.isDelete) {      
             // is it possible to delete the line ?
         } else if (Trigger.isInsert) {
             // is it possible to insert the line ?
             VI01_VIAchat.Load_period(trigger.new);
             VI01_VIAchat.Compute_Value(trigger.new);
         } else if (Trigger.isupdate) {
             // is it possible to update the line ?
             VI01_VIAchat.Load_period(trigger.new);
             VI01_VIAchat.Compute_Value(trigger.new);
         }
     }
     if (Trigger.isAfter) {
         list<id>ListidAff = new list<id>();         
         if (Trigger.isDelete) {      
             ListidAff= VI01_VIAchat.ReProcess_LA(trigger.old);
         } else if (Trigger.isInsert) {
             ListidAff= VI01_VIAchat.ReProcess_LA(trigger.new);
         } else if (Trigger.isupdate) {
             ListidAff= VI01_VIAchat.ReProcess_LA(trigger.new);
         }
     } 
 }
 
}