public class AP02_MaintenancePlan { 
    public static void MajDateInterventionMA(List<MaintenancePlan> ListMPs) 
    { 
        List<MaintenanceAsset> ListMAs = new  List<MaintenanceAsset>();
        List<MaintenanceAsset> ListMAsToUpdate = new  List<MaintenanceAsset>();
        ListMAs=[select id,NextSuggestedMaintenanceDate,MaintenancePlanId,MaintenancePlan.StartDate,
                 MaintenancePlan.EndDate,MaintenancePlan.Frequency ,MaintenancePlan.NextSuggestedMaintenanceDate,MaintenancePlan.FrequencyType
                 from MaintenanceAsset where MaintenancePlanId in :ListMPs];  
        for(MaintenanceAsset MA :ListMAs)
        { 
            Date DateDebut=MA.MaintenancePlan.StartDate;
            Date DateFin=MA.MaintenancePlan.EndDate; 
            Integer JourReelle = DateDebut.DaysBetween(DateFin);
            Integer MoiReelle = DateDebut.MonthsBetween(DateFin); 
            Integer NbrJours= MA.MaintenancePlan.Frequency * 7;
            Integer YearReelle = MA.MaintenancePlan.EndDate.year() -  MA.MaintenancePlan.StartDate.year();
            if(MA.MaintenancePlan.FrequencyType =='Months')
            { 
                if(MoiReelle > MA.MaintenancePlan.Frequency)
                {
                    MA.NextSuggestedMaintenanceDate= MA.MaintenancePlan.NextSuggestedMaintenanceDate.addDays(JourReelle);  
                }
                else
                {
                    MA.NextSuggestedMaintenanceDate= MA.MaintenancePlan.NextSuggestedMaintenanceDate.addMonths(MA.MaintenancePlan.Frequency);   
                }  
            } 
            else if(MA.MaintenancePlan.FrequencyType =='Days')
            {
                if(JourReelle > MA.MaintenancePlan.Frequency)
                {
                    MA.NextSuggestedMaintenanceDate= MA.MaintenancePlan.NextSuggestedMaintenanceDate.addDays(JourReelle);  
                }
                else
                {
                    MA.NextSuggestedMaintenanceDate= MA.MaintenancePlan.NextSuggestedMaintenanceDate.addDays(MA.MaintenancePlan.Frequency);    
                }
            }
            else if(MA.MaintenancePlan.FrequencyType =='weeks')
            {
                if(JourReelle > NbrJours)
                {
                    MA.NextSuggestedMaintenanceDate= MA.MaintenancePlan.NextSuggestedMaintenanceDate.addDays(JourReelle);   
                }
                else 
                {
                    MA.NextSuggestedMaintenanceDate= MA.MaintenancePlan.NextSuggestedMaintenanceDate.addDays(NbrJours);
                }
            }
            else if (MA.MaintenancePlan.FrequencyType =='Years')
            {
                if(YearReelle > MA.MaintenancePlan.Frequency)
                {
                    MA.NextSuggestedMaintenanceDate= MA.MaintenancePlan.NextSuggestedMaintenanceDate.addDays(JourReelle);      
                }
                else
                {
                    MA.NextSuggestedMaintenanceDate= MA.MaintenancePlan.NextSuggestedMaintenanceDate.addYears(MA.MaintenancePlan.Frequency);       
                }
            } 
            ListMAsToUpdate.add(MA);
        }
        update ListMAsToUpdate; 
    } 
    public static void MajDateInterventionMP(List<MaintenancePlan> ListMPs ) 
    { 
        List<MaintenancePlan> ListMPsToRetreive = new List<MaintenancePlan>();
        List<MaintenancePlan> ListMPsToRetreiveToUpdate = new List<MaintenancePlan>();
        ListMPsToRetreive = [select id,NextSuggestedMaintenanceDate,(Select id,NextSuggestedMaintenanceDate from MaintenanceAssets) from MaintenancePlan where id in:ListMPs];
        for (MaintenancePlan MP:ListMPsToRetreive)
        { 
            MP.NextSuggestedMaintenanceDate= MP.MaintenanceAssets[0].NextSuggestedMaintenanceDate;
            ListMPsToRetreiveToUpdate.add(MP);
            
        }
        update ListMPsToRetreiveToUpdate;
    }
}