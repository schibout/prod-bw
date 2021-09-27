/*
* @author: Henri Saslawsky
* @date: 16/12/20202
* @description: Trigger to check that when changing a Affaire
*/

trigger VIAffaire_Trigger on VIAffaire__c (before insert, before update, before delete,
                                                     after insert,  after update,  after delete) {
 if (!VIUtils.ByPassTrigger()){  

     if (Trigger.isBefore) {
         if (Trigger.isDelete) {      
             // is it possible to delete the line ?
         } else if (Trigger.isInsert) {
             // is it possible to insert the line ?
             if(VI01_Affaire.verifdate(true, trigger.new,trigger.oldMap)) { 
                 return;
             }    
             VI01_affaire.Maj_Region_secteur(trigger.new);
         } else if (Trigger.isupdate) {
             // is it possible to update the line ?
             if(VI01_Affaire.verifdate(false, trigger.new,trigger.oldMap)) { 
                 return;
             }    
             VI01_affaire.Maj_Region_secteur(trigger.new);
         }
     }
     if (Trigger.isAfter) {
         if (Trigger.isDelete) {      
             //
         } else if (Trigger.isInsert) {
             VI01_Affaire.creation_lam(trigger.new);
         } else if (Trigger.isupdate) {
           //  VI01_Affaire.creation_lam(trigger.new);
         }
     } 
 }
 
}