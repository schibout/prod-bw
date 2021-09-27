@IsTest
public class VFC98_ACC_ADDError_Test {
   @IsTest  private static void VFC98_ACC_ADDError_test1 () {
         // Instantiate the standard controller
        Account act = new Account();
        Apexpages.StandardController sc = new Apexpages.standardController(act);
        // create a class instance
       VFC98_ACC_ADDError ss = new VFC98_ACC_ADDError(sc );

     }
}