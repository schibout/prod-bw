/*
* @author: Henri Saslawsky
* @date: 16/12/2020
* @description: Trigger to check that when changing a VIAutorisation_depense
*/

trigger VIAutorisation_depense_Trigger on VIAutorisation_depense__c (before insert, before update, before delete,
                                                     after insert,  after update,  after delete) {
 if (!VIUtils.ByPassTrigger()){  

     if (Trigger.isBefore) {
         if (Trigger.isInsert || Trigger.isupdate) {
             // is it possible to insert the line ?
             VI01_VIAutorisation_depense.Load_libelle(trigger.new);
         }
     }
     
     //if (Trigger.isAfter) {
     //    if (Trigger.isDelete) {      
     //    } else if (Trigger.isInsert) {
     //    } else if (Trigger.isupdate) {
     //    }
     //} 
 }
 
}