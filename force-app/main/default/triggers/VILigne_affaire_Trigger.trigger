/*
* @author: Henri Saslawsky
* @date: 16/12/20202
* @description: Trigger to check that when changing a ligne_affaire
*/

trigger VILigne_affaire_Trigger on VILigne_affaire__c (before insert, before update, before delete,
                                                     after insert,  after update,  after delete) {

                                                         
 if (!VIUtils.ByPassTrigger()){  

     if (Trigger.isBefore) {
         if (Trigger.isDelete) {      
             // is it possible to delete the line ?
             VI01_Ligne_affaire.CanDelete(trigger.old) ; 
         } else if (Trigger.isInsert) {
             // is it possible to insert the line ?
             // No need to compute the value when the line is created
         } else if (Trigger.isupdate) {
             // We only need to compute the value if Ecart_C_A_F_MontantD__c changed, otherwise we can give up
             boolean NeedCompute = false ; 
             for(VILigne_affaire__c la : trigger.new) {
                 if(la.Ecart_C_A_F_MontantD__c != Trigger.oldMap.get(la.id).Ecart_C_A_F_MontantD__c)
                     NeedCompute=true; 
                 if(la.Ecart_C_A_F_heure__c != Trigger.oldMap.get(la.id).Ecart_C_A_F_Heure__c)
                     NeedCompute=true; 
             }
             if (NeedCompute)
                 VI01_Ligne_affaire.Compute_Value(trigger.new) ; 
         }
     }
     if (Trigger.isAfter) {
         list<string>ListidAff = new list<string>();                  
         if (Trigger.isDelete) {      
      //   
         } else if (Trigger.isInsert) {
      //   
         } else if (Trigger.isupdate) {
             ListidAff= VI01_Ligne_affaire.ReProcess_LA(trigger.new,trigger.oldMap);
         }
     } 
 }

 
}