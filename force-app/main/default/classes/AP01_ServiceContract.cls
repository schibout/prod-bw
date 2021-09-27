public class AP01_ServiceContract{
    
    public static void RenouvellementOnMaintenancePlan(List<ServiceContract> newServiceContracts)
    {
        
        Set<Id> servicecontractset = new Set<Id>();
        Double DifferenceBetween2Dates;
        
        MaintenancePlan [] ListMaintenancePlans=new MaintenancePlan[]{};  
            
            
            
            map <Id, ServiceContract> mapServiceContractToMaintenancePlans = 
            new map <Id, ServiceContract>([Select Id, StartDate, EndDate, (Select StartDate, EndDate, NextSuggestedMaintenanceDate, DoesAutoGenerateWorkOrders, GenerationHorizon From MaintenancePlans)  
                                           From ServiceContract where Id In:newServiceContracts]);
        system.debug ('mapServiceContractToMaintenancePlans :'+ mapServiceContractToMaintenancePlans );
        
        
        if (mapServiceContractToMaintenancePlans.values().size()>0) {
            system.debug ('mapServiceContractToMaintenancePlans.values():'+ mapServiceContractToMaintenancePlans.values());
            
            for(ServiceContract sc : mapServiceContractToMaintenancePlans.values()) {
                
                ListMaintenancePlans = sc.MaintenancePlans;
                system.debug ('ListMaintenancePlans :'+ ListMaintenancePlans);
                if (ListMaintenancePlans.size()> 0) {
                    for (MaintenancePlan mp : ListMaintenancePlans) 
                    {
                        mp.StartDate = sc.StartDate;
                        mp.EndDate = sc.EndDate;
                        //TMABABCOCK-40 JSA
                       if(mp.NextSuggestedMaintenanceDate > system.today())
                        {
                            mp.GenerationHorizon= (system.today().daysBetween(mp.NextSuggestedMaintenanceDate)) - 1;
                        } 
                        //TMABABCOCK-35 - Removed by TMAEITL
                        //if (mp.DoesAutoGenerateWorkOrders == False) {
                        //    mp.DoesAutoGenerateWorkOrders = True;
                        //}
                        //End TMABABCOCK-35
                        //TMABABCOCK-170
                        if(mp.NextSuggestedMaintenanceDate !=null && sc.StartDate!=null && mp.NextSuggestedMaintenanceDate  < sc.StartDate)
                        {
                        mp.NextSuggestedMaintenanceDate = mp.NextSuggestedMaintenanceDate.addYears(1)/*sc.StartDate + Integer.ValueOf(Label.GenerationHorizon)*/;
                      
                            }
                        //END TMABABCOCK-170
                        //mp.GenerationHorizon = Integer.ValueOf(Label.GenerationHorizon); 
                        //DifferenceBetween2Dates = mp.NextSuggestedMaintenanceDate - mp.StartDate; 
                    }
                } 
            }
        }
        
        update ListMaintenancePlans;  
        
    }
}