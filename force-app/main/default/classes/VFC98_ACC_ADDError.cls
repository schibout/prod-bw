public class VFC98_ACC_ADDError {
 public VFC98_ACC_ADDError(ApexPages.StandardController stdController) {
            ShowError();
    }

  static  public pagereference ShowError() {
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, label.ACC_CreationACCError);
        ApexPages.addMessage(msg);
        return null;
        }
}