@isTest
public class Test_AP01_ServiceContract {
    
    public static testMethod void test_ServiceContractAfterUpdate()  { 
        
      /*
         user UserEnCours=[SELECT USER_ByPassRegleValidation__c 
                  FROM user 
                  WHERE lastName != 'API'
                  LIMIT 1];
                  
        UserEnCours.USER_ByPassRegleValidation__c=true;
        
        update UserEnCours;
      */
        
        user API=[SELECT USER_ByPassRegleValidation__c 
                  FROM user 
                  WHERE lastName=:label.API
                  LIMIT 1];
                  
        API.USER_ByPassRegleValidation__c=true;
        
        update API;
        
     //   System.runAs(UserEnCours){
            
           Account newAccount=new Account(Name='Test Account For Update Maintenance Plan',
                                           ShippingCity='Lebanon',
                                           ShippingPostalCode='123',
                                           ShippingStreet='Test',
                                           BillingStreet='Test',
                                           BillingCity='Test',
                                           BillingPostalCode='1234',
                                           RecordTypeId = '0120O000000kqi1',
                                           ACC_SIREN__c='133456789');
            insert newAccount;
            
            opportunity newOpportunity=new opportunity();
            newOpportunity.AccountId = newAccount.Id;
            newOpportunity.name='Test Opportunity For Maintenance Plan';
            newOpportunity.closedate=Date.today() + 10;
            newOpportunity.stageName='Devis';
            insert newOpportunity;

            
            contact Newcontact=new contact(LastName='Test Contact',
                                     AccountId=newAccount.Id,
                                     Email='Test@gmail.com');
            insert Newcontact;
            
            ServiceContract newServiceContract=new ServiceContract ();
            newServiceContract.name='Test Contract For Maintenance Plan';
            newServiceContract.SC_Statut__c = '1';
            newServiceContract.SC_SousDomaine__c = '16';
            newServiceContract.StartDate =  Date.Today() + 8;
            newServiceContract.EndDate = Date.Today() + 356;
            newServiceContract.AccountId = newAccount.Id;
            newServiceContract.SC_CompteLivre__c = newAccount.Id;
            newServiceContract.SC_NomDuCompteDeFacturation__c = newAccount.Id;
            newServiceContract.ContactId = Newcontact.Id;
            newServiceContract.SC_NAffaire__c = newOpportunity.Id;
            insert newServiceContract;
             newServiceContract.name='Test';
            update newServiceContract;
             newServiceContract.SC_Statut__c = '3';
             newServiceContract.StartDate = Date.Today() + 8;
             newServiceContract.EndDate = Date.Today() + 357;
            
            MaintenancePlan newMaintenancePlan=new MaintenancePlan ();
            newMaintenancePlan.MaintenancePlanTitle='Test For Maintenance Plan';
            newMaintenancePlan.ServiceContractId = newServiceContract.Id; 
            newMaintenancePlan.StartDate = Date.Today() + 8;
            newMaintenancePlan.EndDate =  Date.Today() + 356;
            newMaintenancePlan.Frequency = 6;
            newMaintenancePlan.FrequencyType = 'Months';
            newMaintenancePlan.GenerationTimeframe = 12; 
            newMaintenancePlan.GenerationTimeframeType = 'Months';
            newMaintenancePlan.NextSuggestedMaintenanceDate = Date.Today() + 10;
            newMaintenancePlan.GenerationHorizon = 10;
            insert newMaintenancePlan;
            
          
          System.runAs(API){
           
           //  newServiceContract.SC_Statut__c = '3';
           //  newServiceContract.StartDate = Date.NewInstance (2020,04,03);
           //  newServiceContract.EndDate = Date.NewInstance (2021,04,02);
          
           test.startTest();  
            update newServiceContract; 
        
           test.stopTest();
             
              
        }
    }
}