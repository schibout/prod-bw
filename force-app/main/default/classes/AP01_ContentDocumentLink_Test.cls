@istest
public class AP01_ContentDocumentLink_Test {
    
    static testMethod void AP01_ContentDocumentLinkTest() 
    {
        User API = [SELECT USER_ByPassRegleValidation__c 
                    FROM user 
                    WHERE lastName=:label.API
                    LIMIT 1];
        API.USER_ByPassRegleValidation__c = true;
        
        update API;
        
        System.runAs(API)
        {
            //Insert Account
            Account newAccount = new Account (Name = 'Test Account For Update Quote', ShippingCity = 'Lebanon', 
                                              ShippingPostalCode = '123', ACC_SIREN__c = '123456779');
            insert newAccount;
            
            Asset asts = new Asset();
            asts.Name = 'Test Asset';
            asts.AccountId = newAccount.Id;
            insert asts;
            
            //Insert Contact
            Contact newContact = new Contact(LastName='Test Contact', AccountId=newAccount.Id, Email='Test@gmail.com');
            insert newContact;
            
            //Insert WorkOrder
            String RT_RapportSimple = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('WO_A_Rapport_simple').getRecordTypeId();
            
            WorkOrder newWorkOrder = new WorkOrder (RecordTypeId = RT_RapportSimple, ContactId = newContact.Id, AccountId = newAccount.Id);
            newWorkOrder.Assetid = asts.Id;
            insert newWorkOrder;
            
            OperatingHours oh = new OperatingHours();
            oh.Name = 'TestOH';
            insert oh;
            
            ServiceTerritory SR= new ServiceTerritory();
            SR.IsActive=true;
            SR.Name='Ouest';
            SR.OperatingHoursId=oh.id;
            insert SR;
            
            //Insert ServiceAppointment
            ServiceAppointment newServiceAppointment = new ServiceAppointment (ServiceTerritoryId=SR.id,ParentRecordId = newAccount.Id,SchedStartTime=date.today(),SchedEndTime=date.today()+1, EarliestStartTime = date.today(),
                                                                               DueDate = date.today(),duration=4);
            newServiceAppointment.Intervention__c = newWorkOrder.Id;   
            
            insert newServiceAppointment;
            
            Blob beforeblob=Blob.valueOf('Unit Test Attachment Body');
            ContentVersion cv = new ContentVersion();
            cv.title = 'test content trigger';      
            cv.PathOnClient ='test';           
            cv.VersionData =beforeblob;          
            insert cv; 
            
            ContentVersion cv1 = new ContentVersion();
            cv1.title = 'test content trigger 2';      
            cv1.PathOnClient ='test 2';           
            cv1.VersionData =beforeblob;          
            insert cv1;
            
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            system.debug('documents = '+documents);
            system.debug('documents size = '+documents.size());
            
            ContentDocumentLink contentlink1 = new ContentDocumentLink();
            contentlink1.LinkedEntityId = newWorkOrder.id;
            contentlink1.ShareType = 'V';
            contentlink1.ContentDocumentId = documents[0].Id;
            contentlink1.Visibility = 'AllUsers'; 
            
            ContentDocumentLink contentlink2 = new ContentDocumentLink();
            contentlink2.LinkedEntityId = newServiceAppointment.id;
            contentlink2.ShareType = 'V';
            contentlink2.ContentDocumentId = documents[1].Id;
            contentlink2.Visibility = 'AllUsers';
            
            List<ContentDocumentLink> lstCDL = new List<ContentDocumentLink>();
            lstCDL.add(contentlink1);
            lstCDL.add(contentlink2);
            
            insert lstCDL;
            
            
            ServiceReport srep = new ServiceReport();
            srep.DocumentBody = Blob.valueOf('Test Content') ;
            srep.DocumentContentType ='application/pdf';
            srep.DocumentName='Test';
            srep.ParentId = newWorkOrder.Id ; 
            insert srep ;
            
        }
        
    }
    
}