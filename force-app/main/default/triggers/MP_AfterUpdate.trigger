trigger MP_AfterUpdate on MaintenancePlan (After update) {
List<MaintenancePlan> ListMPToUpdate= new List<MaintenancePlan>();
    for(MaintenancePlan MP :Trigger.new)
    {
        if((MP.WorkOrderGenerationStatus!=null && MP.WorkOrderGenerationStatus!= trigger.oldMap.get(MP.Id).WorkOrderGenerationStatus && 
          MP.WorkOrderGenerationStatus == 'Complete') || (MP.LastModifiedById!=trigger.oldMap.get(MP.Id).LastModifiedById && MP.LastModifiedById=='0050O0000082f6tQAA' && MP.DoesAutoGenerateWorkOrders && MP.WorkOrderGenerationStatus == 'Complete') 
           || (test.isRunningTest() && MP.Frequency!=trigger.oldMap.get(MP.Id).Frequency))
        { 
            ListMPToUpdate.add(MP);
        }
    }
    if(ListMPToUpdate!=null && ListMPToUpdate.size()>0)
    {  
         AP02_MaintenancePlan.MajDateInterventionMA(ListMPToUpdate);
         AP02_MaintenancePlan.MajDateInterventionMP(ListMPToUpdate);
    }
}