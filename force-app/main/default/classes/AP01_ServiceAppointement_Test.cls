@isTest 
public class AP01_ServiceAppointement_Test{
    public static testMethod void AP01_ServiceAppointementTest(){
        
        user API = [SELECT USER_ByPassRegleValidation__c 
                    FROM user 
                    WHERE lastName=:label.API
                    LIMIT 1];
        API.USER_ByPassRegleValidation__c = true;
        
        update API;
        
        System.runAs(API){            
            //Insert Account
            Account newAccount = new Account (Name = 'Test Account For Update Quote', ShippingCity = 'Lebanon', 
                                              ShippingPostalCode = '123', ACC_SIREN__c = '123456779');
            insert newAccount;
            
            //Insert Contact
            Contact newContact = new Contact(LastName='Test Contact', AccountId=newAccount.Id, Email='Test@gmail.com');
            insert newContact;
            
            //Insert ServiceResource
            ServiceResource newServiceResource = new ServiceResource (Name = 'ServiceResource', RelatedRecordId = API.Id);            
            insert newServiceResource;
            
            OperatingHours oh = new OperatingHours();
            oh.Name = 'TestOH';
            oh.TimeZone='Europe/Paris';
            insert oh;
            
            ServiceTerritory SR= new ServiceTerritory();
            SR.IsActive=true;
            SR.Name='Ouest';
            SR.OperatingHoursId=oh.id;
            insert SR;
            
            
            List<TimeSlot> lstTS = new List<TimeSlot>();
            TimeSlot TS = new TimeSlot();
            TS.OperatingHoursId=oh.id;
            TS.StartTime=System.now().AddDays(+2).Time();
            TS.EndTime=System.now().AddDays(+2).Time().addHours(3);
            lstTS.add(TS);
            insert lstTS;
            
            
            //Insert TimeSheet
            TimeSheet newTimeSheet = new TimeSheet (ServiceResourceId = newServiceResource.Id, StartDate = date.today(), EndDate = date.today());
            
            insert newTimeSheet;
            
            //Insert ServiceAppointment            
            ServiceAppointment newServiceAppointment = new ServiceAppointment (ServiceTerritoryId=SR.id,ParentRecordId = newAccount.Id,SchedStartTime=date.today()-2,SchedEndTime=date.today()-1, EarliestStartTime = date.today(),
                                                                               DueDate = date.today(),duration=4);            
            insert newServiceAppointment;
            
            //Insert WorkOrder
            String RT_RapportSimple = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('WO_A_Rapport_simple').getRecordTypeId();
            
            WorkOrder newWorkOrder = new WorkOrder (RecordTypeId = RT_RapportSimple, ContactId = newContact.Id, AccountId = newAccount.Id);
            insert newWorkOrder;
            
            //Insert TimeSheetEntry
            String RT_tempsDeTrajet = Schema.SObjectType.TimeSheetEntry.getRecordTypeInfosByDeveloperName().get('RT_TE_Temps_de_trajet').getRecordTypeId();
            String RT_temps = Schema.SObjectType.TimeSheetEntry.getRecordTypeInfosByDeveloperName().get('RT_TE_Temps').getRecordTypeId();
            
            TimeSheetEntry newTimeSheetEntryTrajet = new TimeSheetEntry (RecordTypeId = RT_tempsDeTrajet, TimeSheetId = newTimeSheet.Id, 
                                                                         TSE_RendezVousDeService__c = newServiceAppointment.Id,
                                                                         TSE_KilometresParcourus__c = 55, StartTime = date.today(),
                                                                         EndTime = date.today() + 5);
            insert newTimeSheetEntryTrajet;
            
            TimeSheetEntry newTimeSheetEntryTemps = new TimeSheetEntry (RecordTypeId = RT_temps, TimeSheetId = newTimeSheet.Id, 
                                                                        WorkOrderId = newWorkOrder.Id, TSE_RendezVousDeService__c = newServiceAppointment.Id,
                                                                        StartTime = date.today()-1, EndTime = date.today()-1);
            insert newTimeSheetEntryTemps;            
            FSL.GlobalAPIS.addStatusTransition('A programmer', 'Planifié'); 
            FSL.GlobalAPIS.addStatusTransition('Planifié', 'Expédié'); 
            FSL.GlobalAPIS.addStatusTransition('Expédié', 'En Cours'); 
            FSL.GlobalAPIS.addStatusTransition('En Cours', 'Terminé'); 
            newServiceAppointment.status = 'Planifié';
            update newServiceAppointment;
            
            newServiceAppointment.status = 'Expédié';
            
            update newServiceAppointment;
            newServiceAppointment.status = 'En cours';
            update newServiceAppointment; 
            
            //    test.startTest();
            
            /* system.assertEquals(newTimeSheetEntryTemps.StartTime, newServiceAppointment.ActualStartTime);
system.assertEquals(newTimeSheetEntryTemps.StartTime, newServiceAppointment.SchedStartTime);
system.assertEquals(newServiceAppointment.ActualStartTime + integer.valueof(newServiceAppointment.Duration),
newServiceAppointment.SchedEndTime);*/
            
            //  test.stopTest();
            
            newServiceAppointment.status = 'Terminé';
            update newServiceAppointment; 
            
            
            string SchedDayOfweek = newServiceAppointment.SchedEndTime.format('EEEE');
            
            Datetime FinSched = AP01_ServiceAppointement.getSchedEnd(newServiceAppointment.ActualStartTime , newServiceAppointment.Duration,lstTS,SchedDayOfweek);
            
            //    test.startTest();
            
            /*    system.assertEquals(newTimeSheetEntryTemps.EndTime, newServiceAppointment.ActualEndTime);
system.assertEquals(newTimeSheetEntryTemps.EndTime, newServiceAppointment.SchedEndTime);
system.assertEquals(newTimeSheetEntryTrajet.TSE_KilometresParcourus__c, newServiceAppointment.SA_KilometragesParcourus__c);*/
            
            //  test.stopTest();
        }
    }
}