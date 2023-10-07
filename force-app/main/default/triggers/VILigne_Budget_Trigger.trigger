/*
* @author: Henri Saslawsky
* @date: 16/12/2020
* @description: Trigger to check that when changing a VIBudget_sur_affaire
*/

trigger VILigne_Budget_Trigger on VILigne_Budget__c (before insert, before update, before delete,
                                                     after insert,  after update,  after delete) {
 if (!VIUtils.ByPassTrigger()){  

     if (Trigger.isBefore) {
         if (Trigger.isDelete) {      
             // is it possible to delete the line ?
             VI01_VILigne_Budget.VerifMAJ(trigger.old);
         } else if (Trigger.isInsert) {
             // is it possible to insert the line ?
             if(!VI01_VILigne_Budget.VerifMAJ(trigger.new)) {
                 VI01_VILigne_Budget.Compute_Value(trigger.new);
             }
         } else if (Trigger.isupdate) {
             // is it possible to update the line ?
             if(!VI01_VILigne_Budget.VerifMAJ(trigger.new)) {
                 VI01_VILigne_Budget.Compute_Value(trigger.new);
             }
         }
     }
     if (Trigger.isAfter) {
         if (Trigger.isDelete) {      
             //
         } else if (Trigger.isInsert) {
             //
         } else if (Trigger.isupdate) {
             //
         }
     } 
 }
 
}