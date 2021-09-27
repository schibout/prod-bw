@IsTest
public class VFC01_Opp_ADDError_Test {
   @IsTest  private static void VFC01_Opp_ADDError_test1 () {
         // Instantiate the standard controller
        Account act = new Account();
        Apexpages.StandardController sc = new Apexpages.standardController(act);
 		// create a class instance
       VFC01_Opp_ADDError ss = new VFC01_Opp_ADDError(sc );

     }
}