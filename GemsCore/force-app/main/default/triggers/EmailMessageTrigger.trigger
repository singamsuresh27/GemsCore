trigger EmailMessageTrigger on EmailMessage (after insert) {

     if (Trigger.isAfter && Trigger.isInsert)
    {
        EmailMessageTriggerHandler.EmailMessageTriggerHandler(trigger.new);
    }
}