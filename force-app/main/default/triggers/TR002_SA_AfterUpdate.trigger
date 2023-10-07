trigger TR002_SA_AfterUpdate on ServiceAppointment (After update) {
    system.debug('Test1234####' );
    List<ServiceAppointment> ListSAToUpdate= new List<ServiceAppointment>();
    if(PAD.canTrigger('AP01_ServiceAppointement')){
      
        for(ServiceAppointment SA :Trigger.new)
        { 
             system.debug('old###'+trigger.oldMap.get(SA.Id).Status);
                 system.debug('New###'+SA.Status);
            // Se déclencher quand le status d'un rendez-vous passe à Terminé
            if(SA.Status != trigger.oldMap.get(SA.Id).Status && SA.Status == Label.SA_Status_Termine ||
               SA.Status != trigger.oldMap.get(SA.Id).Status && SA.Status == 'En cours' ||
              SA.Status != trigger.oldMap.get(SA.Id).Status && SA.Status == Label.SA_status_Journ_e_Termin_e /*||
               SA.Status != trigger.oldMap.get(SA.Id).Status && SA.Status == Label.SA_status_Impossible_de_terminer ||
               (SA.Duration!=null && SA.Duration != trigger.oldMap.get(SA.Id).Duration &&  SA.Status != Label.SA_Status_Termine && SA.SchedEndTime!=null && SA.SchedStartTime!=null )*/)
            {
                system.debug('Yss###'); 
                ListSAToUpdate.add(SA);
            }
        }
    }
    if(ListSAToUpdate != null && ListSAToUpdate.size() > 0)
    {
        
        //Mettre à jour debut et fin reelle du rendez-vous
       // if(test = false)
      AP01_ServiceAppointement.MajheureReelSA(ListSAToUpdate,trigger.oldMap);
    }
}