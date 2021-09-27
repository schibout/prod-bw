trigger TR001_ContentDocumentLink on ContentDocumentLink (after insert) {

     AP01_ContentDocumentLink.cloneAttachments(trigger.new);
}