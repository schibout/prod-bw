/*
* Classe pour mettre à jour les champs suivants de l'objet rendez-vous de service:  "Kilométrages parcourus", "Début réel","Fin réelle".
"Kilométrages parcourus"-->  Kilomètres parcourus de l'objet "Entree de feuille de temps" de type trajet
"Début réel" --> Heure de début de la 1ère entrée de feuille de temps de type "Travail"
"Fin réelle"--> Heure de fin de la dernière entrée de feuille de temps de type "Travail"
* @version 1.00   02/08/2019
* @Auteur TMA EI  
* @ClassTest  AP01_ServiceAppointement_Test
* @CodeCoverage  
*/
public class AP01_ServiceAppointement {
    public static void MajheureReelSA(List <ServiceAppointment> ListSAs,map<id,ServiceAppointment>oldmapSA)
    {  
        List<TimeSlot> ListTimeSlot = new List<TimeSlot>();
        Set<String> SetOperatingHours = new Set<String>(); 
        for(ServiceAppointment SAs:ListSAs)
        {
            if(SAs.OperatingHours__c!=null)
            {
                SetOperatingHours.add(SAs.OperatingHours__c);
            }
        }
        ListTimeSlot=[select id,StartTime,EndTime,DayOfWeek,OperatingHours.name from TimeSlot where OperatingHours.name in:SetOperatingHours order by DayOfWeek,StartTime];
        
        List <ServiceAppointment> ListSA = new List <ServiceAppointment> ();
        List <ServiceAppointment> ListSAToRetreive = new List <ServiceAppointment> ();
        List <ServiceAppointment> ListSAToUpdate = new List <ServiceAppointment> ();
        List <TimeSheetEntry> ListSAToCheck = new List <TimeSheetEntry> ();  
        List <TimeSheetEntry> ListTSEToUpdate = new List <TimeSheetEntry> ();  
        ListSAToRetreive = [SELECT Id, ActualStartTime ,ServiceTerritory.OperatingHours.name,SchedEndTime, SA_KilometragesParcourus__c, ActualEndTime, SchedStartTime, Duration, Status, DurationType,ActualDuration,
                            (SELECT Id, TSE_TypeDeTrajet__c, TSE_KilometresParcourus__c, EndTime, StartTime, TSE_NatureDuTemps__c,DurationInMinutes  
                             FROM Entrees_de_feuille_de_temps__r ORDER BY TSE_NatureDuTemps__c, StartTime)
                            FROM ServiceAppointment
                            WHERE Id in:ListSAs];
        
        for(ServiceAppointment SA:ListSAToRetreive){
            String dayOfWeek = SA.SchedEndTime.format('EEEE'); 
            Decimal sumKilometers = 0;
            integer IntDure = 0;
            /*IF( SA.Duration!=null && SA.Duration != oldmapSA.get(SA.Id).Duration && SA.Status!=Label.SA_Status_Termine && SA.Status!=Label.SA_Status_EnCours && SA.Status!=Label.SA_status_Impossible_de_terminer )
            {
                if(SA.DurationType == 'Hours'){ // SA.SchedEndTime=getSchedEnd(SA.SchedStartTime ,SA.Duration,ListTimeSlot ,dayOfWeek);  ListSAToUpdate.add(SA);//TMABabcock-97
                 
                }
                else if(SA.DurationType == 'Minutes'){ SA.SchedEndTime=getSchedEnd(SA.SchedStartTime ,SA.Duration,ListTimeSlot ,dayOfWeek);ListSAToUpdate.add(SA);
                }
            }*/
            for(TimeSheetEntry TSE: SA.Entrees_de_feuille_de_temps__r){ 
                if(TSE.TSE_NatureDuTemps__c == '2'){ 
                    ListSAToCheck.add(TSE);
                    if(TSE.DurationInMinutes != null){ 
                        IntDure += TSE.DurationInMinutes;
                    }
                }
                
                if(ListSAToCheck != null && ListSAToCheck.size() > 0){ 
                    //Check if status is "En Cours"
                    if(SA.Status == Label.SA_Status_EnCours){ 
                        SA.ActualStartTime = ListSAToCheck[0].StartTime;
                        SA.SchedStartTime = SA.ActualStartTime;
                        if(SA.SchedStartTime >= SA.SchedEndTime ){
                            SA.SchedEndTime = SA.SchedStartTime.addHours(Integer.valueof(SA.Duration));
                        }
                        if(SA.DurationType == 'Hours' ){ 
                            //SA.SchedEndTime = SA.ActualStartTime.addHours(Integer.valueof(SA.Duration));
                            //SA.SchedEndTime=getSchedEnd(SA.ActualStartTime ,SA.Duration,ListTimeSlot ,dayOfWeek);//TMABabcock-97 
                            //SA.SchedEndTime = SA.ActualStartTime.addHours(2);
                        }
                        else if(SA.DurationType == 'Minutes'){ SA.SchedEndTime=getSchedEnd(SA.ActualStartTime ,SA.Duration,ListTimeSlot ,dayOfWeek);
                        }
                        // SA.SchedEndTime=SA.SchedEndTime.addHours(- Offset);
                    }
                    
                    //Check if status is "Terminé"
                    if(SA.Status == Label.SA_Status_Termine ){
                        Integer NbrTSE = ListSAToCheck.size();
                        if(ListSAToCheck[NbrTSE-1].EndTime==null)
                        {
                            ListSAToCheck[NbrTSE-1].EndTime=system.now();   ListTSEToUpdate.add(ListSAToCheck[NbrTSE-1]);
                        }
                        
                        if(ListSAToCheck[NbrTSE-1].EndTime != null){
                            SA.ActualEndTime = ListSAToCheck[NbrTSE-1].EndTime;
                            SA.SchedEndTime = SA.ActualEndTime; 
                        }                    
                    }
                }  
                
                if(SA.Status == Label.SA_Status_Termine){
                    if (TSE.TSE_NatureDuTemps__c == '1'){
                        if(TSE.TSE_KilometresParcourus__c!=null)
                        {
                            sumKilometers += TSE.TSE_KilometresParcourus__c;
                            SA.SA_KilometragesParcourus__c = sumKilometers;
                        }
                    }
                }
                
                
            }

            SA.ActualDuration = IntDure;
            if((ListSAToCheck != null && ListSAToCheck.size() > 0) || SA.SA_KilometragesParcourus__c != null){
                ListSAToUpdate.add(SA);
            }
        }
        
        if(ListSAToUpdate != null && ListSAToUpdate.size() > 0){
            system.debug('ListSAToUpdate: ' + ListSAToUpdate);
            update ListSAToUpdate; 
        }
        
        if(ListTSEToUpdate!=null && ListTSEToUpdate.size()>0)
        { 
            update ListTSEToUpdate;
        }
        
    } 
    public static Datetime getSchedEnd(datetime ActualStartTime , Decimal Duration,List<TimeSlot> listTimeSlots,String SchedDayOfweek)
    {
        Boolean twoShifts=false;
        Map<String,map<integer,TimeSlot>> MaptimeSlotshifts = new Map<String,Map<integer,TimeSlot>>(); 
        Map<String,TimeSlot> MapTimeSlot= new  Map<String,TimeSlot>(); 
        for(TimeSlot TS:listTimeSlots)
        {
            if(!MapTimeSlot.containskey(TS.DayOfWeek))
            {
                MapTimeSlot.put(TS.DayOfWeek,TS);
                MaptimeSlotshifts.put(TS.DayOfWeek, new Map<integer,TimeSlot>()) ;
                MaptimeSlotshifts.get(TS.DayOfWeek).put(1,TS);
            }
            else
            { 
                MaptimeSlotshifts.get(TS.DayOfWeek).put(2,TS);   
            } 
            if(MaptimeSlotshifts!=null && MaptimeSlotshifts.size()>0 && (MaptimeSlotshifts.get(TS.DayOfWeek)).containskey(2))
            {
                twoShifts=true;
            }
            
        } 
        datetime FinSched=ActualStartTime; 
        system.debug('SchedDayOfweek11#####'+SchedDayOfweek);
        system.debug('MapTimeSlot11#####'+MapTimeSlot);
        if(MapTimeSlot!=null  && MapTimeSlot.containskey(SchedDayOfweek))
        {
            do {
                
                FinSched= FinSched.addHours(+1);  Time sched=Time.newInstance(FinSched.hour(), FinSched.minute(), 0, 0); if(sched <= (twoShifts==false?MapTimeSlot.get(SchedDayOfweek).EndTime: (MaptimeSlotshifts.get(SchedDayOfweek)).get(2).EndTime))
                {
                    if(MaptimeSlotshifts!=null && MaptimeSlotshifts.size()>0 && (MaptimeSlotshifts.get(SchedDayOfweek)).containskey(2))
                    {
                        if(sched > (MaptimeSlotshifts.get(SchedDayOfweek)).get(1).endTime && sched < (MaptimeSlotshifts.get(SchedDayOfweek)).get(2).StartTime)
                        {
                            integer EndBreakMin= ((MaptimeSlotshifts.get(SchedDayOfweek)).get(1).endTime).minute() + ((((MaptimeSlotshifts.get(SchedDayOfweek)).get(1).endTime).hour()) * 60); integer  FinSchedMin=FinSched.time().minute() + (FinSched.time().hour() * 60) ; Integer MinBetweenBreak = FinSchedMin - EndBreakMin;
                            FinSched=Datetime.newInstance(FinSched.date(), (((MaptimeSlotshifts.get(SchedDayOfweek)).get(2)).StartTime).addminutes(MinBetweenBreak!=0 ?MinBetweenBreak: 60));
                            
                        }
                    } 
                    Duration --;  
                }
                
                else
                {
                    integer EndHoraireMin=(twoShifts==false? (MapTimeSlot.get(SchedDayOfweek).EndTime).minute(): ((MaptimeSlotshifts.get(SchedDayOfweek)).get(2).EndTime).minute()); integer EndschedMin=FinSched.addHours(-1).time().minute() ; Integer MinutesBetween= (EndHoraireMin == 0?60 :EndHoraireMin)- (EndschedMin) ;
                    
                    FinSched= FinSched.addDays(+1);  if(FinSched.format('EEEE')=='Saturday')
                    {
                        
                        FinSched= Datetime.newInstance(FinSched.date().addDays(+2), (MapTimeSlot.get(SchedDayOfweek).StartTime).addminutes(EndHoraireMin==EndschedMin?60:(MinutesBetween < 0) ? 60 - ((60 - EndschedMin) + EndHoraireMin) :60 - MinutesBetween)); 
                        
                    }
                    else if(FinSched.format('EEEE')=='Sunday')
                    {
                        
                        FinSched= Datetime.newInstance(FinSched.date().addDays(+1), (MapTimeSlot.get(SchedDayOfweek).StartTime).addminutes(EndHoraireMin==EndschedMin?60:(MinutesBetween < 0) ? (60 - ((60 - EndschedMin) + EndHoraireMin)) :60 - MinutesBetween)); 
                        
                    }
                    else
                    {    
                        FinSched=Datetime.newInstance(FinSched.date(), (MapTimeSlot.get(SchedDayOfweek).StartTime).addminutes(EndHoraireMin==EndschedMin?60: (MinutesBetween < 0) ? 60 - ((60 - EndschedMin) + EndHoraireMin) : 60 - MinutesBetween) );    // FinSched=Datetime.newInstance(FinSched.date(), (MapTimeSlot.get(SchedDayOfweek).StartTime).addHours(+1) );
                    } 
                    Duration --;  }}while (Duration >0);
        }return FinSched;
    }}