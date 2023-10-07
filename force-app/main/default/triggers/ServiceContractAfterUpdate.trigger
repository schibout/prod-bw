trigger ServiceContractAfterUpdate on ServiceContract (after update) {
    system.debug('Trigger.newAfter'+Trigger.new);
    User APIUser=[SELECT id
                      FROM user
                      WHERE lastname=:label.API];
    
    list<ServiceContract> ListServiceContracts= new list<ServiceContract>();
    list<ServiceContract> ListServiceContractsNonRenouvellable= new list<ServiceContract>();
   
    for(ServiceContract sc : trigger.new)
    {

     
      if(  userinfo.getuserid()==APIUser.Id &&  trigger.newMap.get(sc.Id).SC_Statut__c == Label.Actif && ((trigger.oldMap.get(sc.Id).StartDate != trigger.newMap.get(sc.Id).StartDate) 
      || trigger.oldMap.get(sc.Id).EndDate != trigger.newMap.get(sc.Id).EndDate)) {
          listServiceContracts.add(sc);
        }

   }
     
    
     if(listServiceContracts.size()>0)
    {
        system.debug('ListServiceContract :' + listServiceContracts);
        AP01_ServiceContract.RenouvellementOnMaintenancePlan(listServiceContracts);
    }  
  
 }