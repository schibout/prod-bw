trigger SABeforeInsert on ServiceAppointment (before insert) {
    List<ServiceAppointment> ListSAToInsert =  new List<ServiceAppointment>();
    for(ServiceAppointment SA:Trigger.new)
    {
        if(SA.Duration >=3 && SA.DurationType=='Hours' && (SA.Status==Label.SA_Programme ||SA.Status==Label.SA_Planifie ||SA.Status==Label.SA_Expedie))
        {
            ListSAToInsert.Add(SA);
        }
        
    }
    if(PAD.canTrigger('AP02_ServiceAppointment'))
    {
        If(ListSAToInsert!=null && ListSAToInsert.size()>0)
        {
            AP02_ServiceAppointment.MajMultidaySA(ListSAToInsert);
        }
    }
    
}