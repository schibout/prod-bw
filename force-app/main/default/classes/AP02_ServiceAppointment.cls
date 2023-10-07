/* 
* Cochers le champ "plusieur jours" sur un rendez-vous de service si la durée >= 3 h
* @version 1.00   26/09/2019
* @Auteur TMA EI JSA
* @ClassTest  AP01_ServiceAppointement_Test
* @CodeCoverage  
*/
public class AP02_ServiceAppointment {
public static void MajMultidaySA(List <ServiceAppointment> ListSAs) 
    {
        for(ServiceAppointment SA :ListSAs)
        {
          SA.FSL__IsMultiDay__c  = true;     
        }
    }
}