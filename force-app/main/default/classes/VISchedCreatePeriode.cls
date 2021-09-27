/*
 *  This class checks that all periode are created in the system
 * 
 *  How to run it every day at 22:00 pm : 
  VISchedCreatePeriode batchSch=new VISchedCreatePeriode();
  String sch='0 0 22 * * ? *'; // Every day at 22:00
  System.schedule('VISchedCreatePeriode', sch , batchSch);
 *  
 *
 * How to run it by hand 
  VISchedCreatePeriode v = new VISchedCreatePeriode();
  v.execute(null);

 * 
 */
global class VISchedCreatePeriode implements Schedulable
{

    Public integer MONTH_AFTER  = 60 ;
    global void execute(SchedulableContext sc)
    {

        // Let's insert the mission periode
        date Date_deb=date.newinstance(2018,01,01);
        date Date_end=System.today().addmonths(MONTH_AFTER); 
        List<VIPeriode__c>ListNewPeriode = new List<VIPeriode__c>();
        For(VIentiteBW__c Entite_bw : [SELECT id, name, Entite_BW__c  FROM VIentiteBW__c where ouvert__c=true]) {       
            Map<string,VIPeriode__c>MapPeriode = new Map<string,VIPeriode__c>();
            for(VIPeriode__c per : [SELECT id, name, date_de_debut__c, date_de_fin__c, statut__c
                                      FROM VIPeriode__c
                                     WHERE entite_BW__c = :Entite_bw.Entite_BW__c]) {
                 MapPeriode.put(Per.name, per);
            }
            Date d=Date_deb ; 
            while (d<Date_end) {
                string key=string.valueof(d.Year())+string.valueof(d.month()).leftpad(2,'0')+Entite_bw.name ;
                if(!MapPeriode.containskey(key)) {
                    Date date1 = d.toStartOfMonth();
                    Date date2 = d.toStartOfMonth().addmonths(1).toStartOfMonth().adddays(-1);
                    string statut ;
                    if(date1<=system.today()) {
                        statut=VIConstant.PERIODE_FERMEE; 
                    } else {
                        statut=VIConstant.PERIODE_FUTURE;
                    }
                    VIPeriode__c NewPeriode = new VIPeriode__c (name=key,
                                                                date_de_debut__c=date1,
                                                                date_de_fin__c=date2,
                                                                Entite_bw__c=Entite_bw.entite_bw__c,
                                                                Statut__c=statut);
                    ListNewPeriode.add(NewPeriode);
                }
                d=d.addmonths(1);
            }
        }
        if(ListNewPeriode.size()>0)
            insert ListNewPeriode;
        

        // The periode are inserted. Now, we have to update periode_precedente
        List<VIPeriode__c>ListUpdatesPeriode = new List<VIPeriode__c>();
        List<VIPeriode__c>ListPeriode = [SELECT id,name, Periode_comptable_precedente__c , Entite_bw__c
                                           FROM VIPeriode__C
                                       ORDER BY Entite_bw__c, name] ;
        
        for(integer i=0 ;i<ListPeriode.size();i++ ) {
            if(ListPeriode[i].Periode_comptable_precedente__c==null && i!=0) {
                if(ListPeriode[i].Entite_bw__c==ListPeriode[i-1].Entite_bw__c) {
                    ListPeriode[i].Periode_comptable_precedente__c=ListPeriode[i-1].id;
                    ListUpdatesPeriode.add(ListPeriode[i]);
                }
            } 
        }   
        if(ListUpdatesPeriode.size()>0)
            Update ListUpdatesPeriode;
        
    }
   
}