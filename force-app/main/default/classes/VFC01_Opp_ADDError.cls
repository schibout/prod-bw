/*
 * author: julien debes
 * date: 1-9-2019
 * test class:VFC01_Opp_ADDError_Test
 * description: class that show an error message each time "new" button is clicked on the object opportunity.
 * 
 * */

public class VFC01_Opp_ADDError {
 public VFC01_Opp_ADDError(ApexPages.StandardController stdController) {
            ShowError();
    }

  static  public pagereference ShowError() {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, label.OPP_CreationOppError);
        ApexPages.addMessage(msg);
        return null;
		}
}