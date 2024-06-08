({
    handleRemoval : function(component, event, helper) {

        var confirmationMessage = 'This will delete ' +
            component.get('v.employeeName') + '\'s assignments for the current week.' +
            ' Do you want to continue?';
        if(confirm(confirmationMessage)) {
            helper.removeEmployeeWeekAssignations(component, event).
            then(removalResult => {
                component.destroy();
            }).catch(removalError => {
                var data = {
                    "title" : "Error removing employee",
                    "message" : removalError,
                    "type" : "error"
                };
                helper.showToast(component, event, helper, data);
            });
        }
    },

    // AA 04/08/2024 Added function to refresh event.
    handleEvent : function(component, event, helper) {
        let refresh = component.getEvent("refreshViewEvent");
        refresh.setParams({
            "message" : "refresh view"
        });
        refresh.fire();
    }

})