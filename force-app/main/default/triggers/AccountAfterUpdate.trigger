trigger AccountAfterUpdate on Account (after update) {
    
    User APIUser=[SELECT id
                      FROM user
                      WHERE lastname=:label.API];
    
    list<Account> listAccounts = new list<Account>();

    for(Account acc : trigger.new)
    {

     
  if(userinfo.getuserid()==APIUser.Id && (trigger.oldMap.get(acc.Id).RecordtypeId != trigger.newMap.get(acc.Id).RecordtypeId) 
  && trigger.newMap.get(acc.Id).RecordtypeId == Label.Acc_RecordTypeID)
       
       {
          listAccounts.add(acc);
        }
     }
        
    if(listAccounts.size()>0)
    {
        system.debug('listAccounts :' + listAccounts);
        AP01_Account.updateTechTalendExportDevis(listAccounts);
    }   
 }