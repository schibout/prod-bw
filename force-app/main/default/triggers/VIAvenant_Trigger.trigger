/*
* @author: Henri Saslawsky
* @date: 16/12/2020
* @description: Trigger to check that when changing a VIBudget_sur_affaire
*/

trigger VIAvenant_Trigger on VIAvenant__c (before insert, before update, before delete,
                                                     after insert,  after update,  after delete) {
 if (!VIUtils.ByPassTrigger()){  

     if (Trigger.isBefore) {
         if (Trigger.isDelete) {      
             // is it possible to delete the line ?
         } else if (Trigger.isInsert) {
             // is it possible to insert the line ?
             if(VI01_VIAvenant.Kind_of_user(trigger.new)) {
                 Return ; 
             }
             VI01_VIAvenant.Load_period(trigger.new); 
             VI01_VIAvenant.Compute_Value(trigger.new);
         } else if (Trigger.isupdate) {
             // is it possible to update the line ?
             VI01_VIAvenant.Load_period(trigger.new); 
             VI01_VIAvenant.Compute_Value(trigger.new);
         }
     }
     if (Trigger.isAfter) {
         list<id>ListidAff = new list<id>();
         if (Trigger.isDelete) {      
              ListidAff=VI01_VIAvenant.Reprocess_aff(trigger.old) ;
         } else if (Trigger.isInsert) {
              ListidAff=VI01_VIAvenant.Reprocess_aff(trigger.new) ;
         } else if (Trigger.isupdate) {
              ListidAff=VI01_VIAvenant.Reprocess_aff(trigger.new) ;
              VI01_VIAvenant.process_RAD(trigger.new,trigger.oldMap);
         }
     } 
 }
 
}