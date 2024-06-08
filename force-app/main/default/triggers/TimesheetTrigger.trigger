Trigger TimesheetTrigger on Timesheet__c (after insert, before insert, before update) {
    
    if(Trigger.isBefore){
        if(Trigger.isUpdate){
            System.debug('GC TimesheetTrigger isBefore isUpdate: ' + Trigger.new);
            TimesheetDomain.updateInternationalTimesheet(
                Trigger.new,
                Trigger.oldMap
            );   
        }
    }
    
    if (Trigger.isAfter){
        if(Trigger.isInsert){
            System.debug('GC TimesheetTrigger isAfter isInsert: ' + Trigger.newMap);
            TimesheetDomain.ratesCalculation(Trigger.newMap);
            //GC 08/30/2021: Added so can trigger the calculation on Assignment records based on new Timesheets records.
            AssignmentDomain.handleAssignmentChange(Trigger.new);
        }
    }
    
}