trigger SC_BeforeUpdate on ServiceContract (before update) {
    for(ServiceContract SC:Trigger.new)
    {
        system.debug('Trigger.new###'+Trigger.new);
    }

system.debug('Trigger.old###'+Trigger.old);
}