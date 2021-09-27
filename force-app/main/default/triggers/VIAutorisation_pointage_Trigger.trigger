/*
* @author: Henri Saslawsky
* @date: 16/12/2020
* @description: Trigger to check that when changing a VIAutorisation_pointage
*/

trigger VIAutorisation_pointage_Trigger on VIAutorisation_pointage__c (before insert, before update, before delete,
                                                     after insert,  after update,  after delete) {
 if (!VIUtils.ByPassTrigger()){  

     if (Trigger.isBefore) {
         if (Trigger.isInsert || Trigger.isupdate) {
             // is it possible to insert the line ?
             VI01_VIAutorisation_pointage.Load_libelle(trigger.new);
         }
     }
 }
 
}