@isTest
public class VISchedCreatePeriode_Test {

    static testmethod void VISchedCreatePeriode_Test() {
    
        VIInsertDataTest.VIInsertData_GBP_Avenant();
        
        VISchedCreatePeriode v = new VISchedCreatePeriode();
        v.execute(null);
    }
}