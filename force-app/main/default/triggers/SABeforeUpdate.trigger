trigger SABeforeUpdate on ServiceAppointment (before Update) {
 List<ServiceAppointment> ListSAToUpdate =  new List<ServiceAppointment>();
    for(ServiceAppointment SA:Trigger.new)
    {
        if(SA.Duration!=null && SA.Duration!= trigger.oldMap.get(SA.Id).Duration && SA.DurationType=='Hours' && SA.Duration >=3 && 
           (SA.Status==Label.SA_Programme ||SA.Status==Label.SA_Planifie ||SA.Status==Label.SA_Expedie))
        {
            ListSAToUpdate.Add(SA);
        }
        
    }
    if(PAD.canTrigger('AP02_ServiceAppointment'))
    {
        If(ListSAToUpdate!=null && ListSAToUpdate.size()>0)
        {
            AP02_ServiceAppointment.MajMultidaySA(ListSAToUpdate);
        }
    }
}