public class AP01_ContentDocumentLink {
    
    public static void cloneAttachments(List<ContentDocumentLink> lstCDL)
    {
        List<WorkOrder> lstWO = new List<WorkOrder>();
        List<ServiceAppointment> lstSA = new List<ServiceAppointment>();
        List<ContentDocumentlink> lstEquipDocLink = new  List<ContentDocumentlink>();
        List<ContentDocumentlink> lstEquipDocLinkSA = new  List<ContentDocumentlink>();
        List<String> SetIDcontdocEquip = new  List<String>(); 
         List<String> SetIDcontdocEquipSA = new  List<String>(); 
        Set<id> workOrderIds = new Set<id>();
        Set<id> serviceAppointmentIds = new Set<id>();
        
        String test1 = 'WorkOrder';
        String test2 = 'ServiceAppointment';
        
        for(ContentDocumentLink cdl : lstCDL)
        {
            if(cdl.LinkedEntityId!=null && 'WorkOrder' == (cdl.LinkedEntityId.getSObjectType() + ''))
            {
                workOrderIds.add(cdl.LinkedEntityId);
            }
            else if (cdl.LinkedEntityId!=null && 'ServiceAppointment' == (cdl.LinkedEntityId.getSObjectType() + ''))
            {
                serviceAppointmentIds.add(cdl.LinkedEntityId);
                system.debug('serviceAppointmentIds###'+serviceAppointmentIds);
            }
        }
        
        if(workOrderIds.size() > 0)
        {
            lstWO = [Select id, Asset.id  
                       from WorkOrder 
                      where id in :workOrderIds];
        }
        
        if(serviceAppointmentIds.size() > 0)
        {
            lstSA = [Select id, Intervention__r.AssetId  
                       from ServiceAppointment 
                      where id in :serviceAppointmentIds];
            system.debug('lstSA###'+lstSA);
        }
        
        Map<String, String> mapWO = new Map<String, String>();
        for(WorkOrder wo : lstWO)
        {
            if(wo.AssetId != null)
            {
                mapWO.put(wo.id, wo.AssetId);   
            }
        }
        
        if(mapWO!=null && mapWO.keySet().size() > 0)
        {
            // Chercher la liste des documents rattachées aux work orders
            List<ContentDocumentlink> lstCntDocLink = [SELECT id, ShareType, Visibility, LinkedEntityId, ContentDocumentId
                                                       FROM ContentDocumentlink
                                                       WHERE LinkedEntityId in :mapWO.keySet()];
            lstEquipDocLink = [SELECT id, ShareType, Visibility, LinkedEntityId, ContentDocumentId
                                                       FROM ContentDocumentlink
                                                       WHERE LinkedEntityId in :mapWO.values()];
            for(ContentDocumentlink cdlequip:lstEquipDocLink)
            {
                if(cdlequip.ContentDocumentId!=null)
                {
                SetIDcontdocEquip.add(cdlequip.ContentDocumentId);
                    }
            } 
            system.debug('SetIDcontdocEquip###'+SetIDcontdocEquip);
            // Map qui a comme key le document attaché au work order et comme valeur l'id du work order 
            Map<ContentDocumentlink, String> mapAttachment = new Map<ContentDocumentlink, String>();
            for(ContentDocumentlink cdl : lstCntDocLink)
            {
                if(cdl.LinkedEntityId!=null)
                {
                mapAttachment.put(cdl, cdl.LinkedEntityId);
                    }
                  
            }
            system.debug('mapAttachment###'+mapAttachment);
            // Si l'id du work order liée au document est la même que celle liée à l'equipement, copier les documents attachées sur work order vers l'equipement attachées à ce work order
            List<ContentDocumentLink> linkToInsert = new List<ContentDocumentLink>();
            for(ContentDocumentlink cdl : mapAttachment.keySet())
            {
                 
                if(mapWO!=null && mapWO.containsKey(mapAttachment.get(cdl)) && SetIDcontdocEquip!=null && cdl.ContentDocumentId!=null && !SetIDcontdocEquip.contains(cdl.ContentDocumentId)  )
                {
                    // system.debug('ContentDocumentId###'+cdl.ContentDocumentId);
                    system.debug('Map###'+mapWO.get(mapAttachment.get(cdl)));
                    // Pour copier les documents, il suffit de mettre l'id du nouveau objet dans le champ LinkedEntityId
                    // On ne cré pas des nouveaux docs, on ajoute seulement un nouveau lien du doc vers le nouveau objet
                    ContentDocumentLink link = new ContentDocumentLink();
                    link.LinkedEntityId = mapWO.get(mapAttachment.get(cdl));
                    link.ContentDocumentId = cdl.ContentDocumentId;
                    link.ShareType = cdl.ShareType;
                    link.Visibility = cdl.Visibility;
                    
                    linkToInsert.add(link);
                }
            }
            
            if(linkToInsert.size() > 0)
            {
                insert linkToInsert;
            }
        }
        
        Map<String, String> mapSA = new Map<String, String>();
        for(ServiceAppointment sa : lstSA)
        {
            if(sa.Intervention__r.AssetId != null)
            {
                mapSA.put(sa.id, sa.Intervention__r.AssetId);   
                system.debug('mapSA###'+mapSA);
            }
        }
        
        if(mapSA.keySet().size() > 0)
        {
              system.debug('Tst534###');
            system.debug('mapSA.keySet()###'+mapSA.keySet());
            // Chercher la liste des documents rattachées aux ServiceAppointment
            List<ContentDocumentlink> lstCntDocLink = [SELECT id, ShareType, Visibility, LinkedEntityId, ContentDocumentId
                                                       FROM ContentDocumentlink
                                                       WHERE LinkedEntityId in :mapSA.keySet()];
             system.debug('lstCntDocLink'+lstCntDocLink);
            lstEquipDocLinkSA=[SELECT id, ShareType, Visibility, LinkedEntityId, ContentDocumentId
                                                       FROM ContentDocumentlink
                                                       WHERE LinkedEntityId in :mapSA.values()];
            system.debug('lstEquipDocLinkSA'+lstEquipDocLinkSA);
            for(ContentDocumentlink cdlequipSA:lstEquipDocLinkSA)
            {
                if(cdlequipSA.ContentDocumentId!=null)
                {
                SetIDcontdocEquipSA.add(cdlequipSA.ContentDocumentId);
                    }
            }
            system.debug('SetIDcontdocEquipSA####'+SetIDcontdocEquipSA);
            // Map qui a comme key le document attaché au ServiceAppointment et comme valeur l'id du ServiceAppointment 
            Map<ContentDocumentlink, String> mapAttachment = new Map<ContentDocumentlink, String>();
            for(ContentDocumentlink cdl : lstCntDocLink)
            {
                
                mapAttachment.put(cdl, cdl.LinkedEntityId);
            }
            system.debug('mapAttachment##'+mapAttachment);
            // Si l'id du ServiceAppointment liée au document est la même que celle liée à l'equipement, copier les documents attachées sur ServiceAppointment vers l'equipement attachées à ce ServiceAppointment
            List<ContentDocumentLink> linkToInsert = new List<ContentDocumentLink>();
            for(ContentDocumentlink cdl : mapAttachment.keySet())
            {
                if(mapSA!=null && mapSA.containsKey(mapAttachment.get(cdl)) && SetIDcontdocEquipSA!=null && cdl.ContentDocumentId!=null && !SetIDcontdocEquipSA.contains(cdl.ContentDocumentId) )
                {
                   system.debug('Done##' );
                    // Pour copier les documents, il suffit de mettre l'id du nouveau objet dans le champ LinkedEntityId
                    // On ne cré pas des nouveaux docs, on ajoute seulement un nouveau lien du doc vers le nouveau objet
                    ContentDocumentLink link = new ContentDocumentLink();
                    
                    link.LinkedEntityId = mapSA.get(mapAttachment.get(cdl));
                    if(cdl.ContentDocumentId!=null)
                    {
                    link.ContentDocumentId = cdl.ContentDocumentId;
                        }
                    if(cdl.ShareType!=null)
                    {
                    link.ShareType = cdl.ShareType;
                        }
                    link.Visibility = cdl.Visibility;
                    
                    linkToInsert.add(link);
                }
            }
            
            if(linkToInsert.size() > 0)
            {
                insert linkToInsert;
            }
        }
        
    }
}