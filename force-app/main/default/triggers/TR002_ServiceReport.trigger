trigger TR002_ServiceReport on ServiceReport (After insert) {
    Set<id> SetContentDocId = new Set<id>();
    Set<id> SetContentDocVersionId = new Set<id>();
    List<ContentDocumentLink > ListCDL = new List<ContentDocumentLink>();
    List<ContentVersion> ListContentVersion = new List<ContentVersion>();
    For(ServiceReport SR:Trigger.new)
    {
        if(SR.ContentVersionDocumentId!=null)
        {
            SetContentDocId.add(SR.ContentVersionDocumentId);
        } 
        
    }
    if(SetContentDocId!=null && SetContentDocId.size()>0)
    {
        ListContentVersion=[select id,contentdocumentId from  ContentVersion where id IN: SetContentDocId];
    }
    for (ContentVersion CV:ListContentVersion)
    {
        if(CV.contentdocumentId!=null)
        {
            SetContentDocVersionId.add(CV.contentdocumentId);
        }
    }
    
    if(SetContentDocVersionId!=null && SetContentDocVersionId.size()>0)
    {
        ListCDL =[select id,linkedEntityID from ContentDocumentLink where ContentDocumentid IN :SetContentDocVersionId];
    }
    if(ListCDL!=null && ListCDL.size()>0)
    {
          AP01_ContentDocumentLink.cloneAttachments(ListCDL);
    }
}