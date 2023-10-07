@istest
public class AP02_MaintenancePlan_Test {
    static testMethod void AP02_MaintenancePlanTest() {
        
        ServiceContract SC = new ServiceContract();
        SC.Name='test';
        SC.StartDate=system.today();
        SC.EndDate= system.today()+350;
        insert SC;
        MaintenancePlan MP = new MaintenancePlan(); 
        MP.StartDate= system.today();
        MP.EndDate= system.today()+350;
        MP.ServiceContractId=SC.id;
        MP.Frequency=6;
        MP.FrequencyType='Months';
        MP.GenerationTimeframe=3;
        MP.GenerationTimeframeType='Months';
        MP.NextSuggestedMaintenanceDate=system.today()+3;
        insert MP; 
        MaintenancePlan MP2 = new MaintenancePlan(); 
        MP2.StartDate= system.today();
        MP2.EndDate= system.today()+350;
        MP2.ServiceContractId=SC.id;
        MP2.Frequency=6;
        MP2.FrequencyType='Days';
        MP2.GenerationTimeframe=3;
        MP2.GenerationTimeframeType='Days';
        MP2.NextSuggestedMaintenanceDate=system.today()+3;
        insert MP2; 
        Asset asts = new Asset();
        asts.Name = 'Test Asset';
        insert asts;
        
        MaintenanceAsset MA=new MaintenanceAsset();
        MA.MaintenancePlanId=MP.id;
        MA.AssetId=asts.id;
        insert MA;
        MaintenanceAsset MA2=new MaintenanceAsset();
        MA2.MaintenancePlanId=MP2.id;
        MA2.AssetId=asts.id;
        insert MA2;
        
        test.startTest();
        MP2.Frequency=8;
        Update MP2; 
        MP.Frequency=8;
        Update MP;  
        test.stopTest();
    }
    
}