//
//  Database.executeBatch(new VIBatchRegenerateTotal('B9%',false,false), VIBatchRegenerateTotal.NBR_LOT());
//  
//  
/*
   VIBatchRegenerateTotal v = new VIBatchRegenerateTotal('',true,false);
   v.execute(null);
*/

//
global class VIBatchRegenerateTotal implements Schedulable,Database.Batchable<sObject>,Database.Stateful {
    global List<String> ListLigne;
    public VItype_de_depense__c tdMO  = new VItype_de_depense__c();
    public VItype_de_depense__c tdGAR = new VItype_de_depense__c();
    public VItype_de_depense__c tdEMM = new VItype_de_depense__c();
    public VItype_de_depense__c tdAMP = new VItype_de_depense__c();
    public VItype_de_depense__c tdFOL = new VItype_de_depense__c();     
    Global VICentre_section__c CS801;
    public VIPeriode__c periode_ouverte;
    
    
    public Map<string,VIperiode__c>MapEntite_bwPeriode = new Map<string,VIperiode__c>();

    private string AffaireAGenerer; 
    private boolean Enchaine ;
    private boolean Commencement ;

    
     public VIBatchRegenerateTotal(String Param1,Boolean Param2,Boolean Param3 ) {
        AffaireAGenerer = Param1;        
        Enchaine = Param2;      
        Commencement = Param3;       
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        for(VIType_de_depense__c td : [SELECT ID,name from VIType_de_depense__c where name like 'MO %' or name like 'GAR%' or name like 'EMM%' or name like 'AMP%' or name like 'FOL%']) {
            if(td.name.startswith('MO '))
                 tdMO=td ; 

            if(td.name.startswith('GAR'))
                 tdGAR=td ; 

            if(td.name.startswith('EMM'))
                 tdEMM=td ; 

            if(td.name.startswith('AMP'))
                 tdAMP=td ; 

            if(td.name.startswith('FOL'))
                 tdFOL=td ; 
        }
        CS801 = [select id from VICentre_section__c where name like '801%' ];        
        
        for(VIPeriode__c per : [SELECT ID,name, entite_bw__c, date_de_debut__c, date_de_fin__c , statut__c
                                  FROM VIPeriode__c
                                 WHERE entite_bw__c='1'  ]) {
             MapEntite_bwPeriode.put(per.name,per);
             if(per.statut__c==VIConstant.PERIODE_OUVERTE)  {
                 periode_ouverte=per; 
             }
         }




        string a = AffaireAGenerer+'%';
        string query =  'select id, name, Date_ouverture_affaire__c, ';
        query = query + '       Date_de_SAV_previsionnelle__c , Date_de_SAV_reelle__c  ';
        query = query + '  FROM Viaffaire__c ';
        if(AffaireAGenerer=='9') {
            query = query + '   WHERE (name like \'9%\' or name like \'8%\') ';
        } else  if(AffaireAGenerer=='!9') {
            query = query + '   WHERE (not (name like \'9%\' or name like \'8%\')) ';
            query = query + '   AND ((Date_de_fin_de_garantie__c = null or Date_de_fin_de_garantie__c >='+string.valueof(periode_ouverte.date_de_fin__c).left(10)+' ) ';            
            query = query + '    or  (Date_max_mouvement__c >='+string.valueof(periode_ouverte.date_de_fin__c).left(10)+' )) ';                        
        } else if(AffaireAGenerer=='AMPEMMFOL') {
            String formatted = system.now().addhours(-2).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
            query = query + '   WHERE id in (select affaire__c from viachat__c where type_depense__r.name like \'EMM%\' and createddate>'+formatted+') ';                        
        } else if(AffaireAGenerer=='VIEILLES') {
            query = query + '   WHERE Date_ouverture_affaire__c<2018-01-01 ';                        
        } else {
            query = query + '   WHERE name like \'' + AffaireAGenerer+'%\' ';            
        }
        if(AffaireAGenerer=='') { 
            query = query + '   AND (Date_de_fin_de_garantie__c = null or Date_de_fin_de_garantie__c >='+string.valueof(periode_ouverte.date_de_fin__c).left(10)+' ) ';
        }
        query = query + '   AND Date_ouverture_affaire__c<='+string.valueof(periode_ouverte.date_de_fin__c).left(10)+'  ';
        query = query + '           order by Name asc';
        
        system.debug(query);
        return Database.getQueryLocator(query);

    }        
        



    global void execute(Database.BatchableContext BC, List<VIaffaire__c> scope){

        for(VIAffaire__c l:scope) {
            date date_param;
            if(Commencement) {
                date_param=date.newinstance(2020,12,1);
            } else {
                date_param=periode_ouverte.date_de_debut__c;
            }
            VIUtils.recalc(l.id,true, true, tdMO,tdGAR, tdEMM, tdAMP, tdFOl, cs801, MapEntite_bwPeriode,date_param );
        }
    }

    global void finish(Database.BatchableContext BC) {
        if(AffaireAGenerer=='!9') {        
            Database.executeBatch(new VIBatchDeleteLC('',true),VIBatchDeleteLC.NBR_LOT);            
        }

    }
    
    global void execute(SchedulableContext scon) {
        if(AffaireAGenerer=='') {
            Database.executeBatch(new VIBatchRegenerateTotal('9',Enchaine,commencement),1);  
            Database.executeBatch(new VIBatchRegenerateTotal('!9',Enchaine,commencement),VIBatchRegenerateTotal.NBR_LOT);              
        } else {
            Database.executeBatch(new VIBatchRegenerateTotal(AffaireAGenerer,Enchaine,commencement),1);
        } 
    }

    public static final integer NBR_LOT =12;    

    
    public string convert_date_periode(Date d) {
        string p = string.valueof(d.year())+('00'+string.valueof(d.month())).right(2)+'BW FRA';        
        return p;
    }
    
}