({
    initializeComponent : function(component, event, helper) {
        var cloneButtonVisibility = component.get('c.setCloneButtonVisibility');
        $A.enqueueAction(cloneButtonVisibility);
        var dayDate = component.get("v.dayDate");
        component.set("v.dayDateMin", helper.minDateCalculation(dayDate));
        component.set("v.dayDateMax", helper.maxDateCalculation(dayDate));
    },
 
    // AA 04/08/2024 Commented because of the pill container refactor.

//     handleItemRemove : function(component, event, helper) {
//         if(!confirm("Delete this assignment?")){
//             return;
//         }
//         var stories = component.get('v.stories');
//         var storyIndex = event.getParam("index");
//         var storyData = stories[storyIndex];
//         var parameters = {
//             "storyEmployeeAssociationId" : storyData.name
//         }
//         helper.storyDeletionHelperPromise(component, event, parameters).
//         then(
//             deletionResult =>{
//                 if(deletionResult == true) {
//                     stories.splice(storyIndex, 1);
//                     component.set('v.stories', stories);
//                     var data = {
//                         "title" : "Story Assignation Deletion",
//                         "message" : "Story assignation " + storyData.label + " was deleted",
//                         "type" : "success"
//                     }
//                     helper.showToast(component, event, data);
//                 }
//             }
//         ).catch(
//             deletionError => {
//                 console.log(deletionError);
//                 var data = {
//                     "title" : "Story Assignation Deletion Error",
//                     "message" : "Story assignation " + storyData.label + " was not deleted. Please try again",
//                     "type" : "error"
//                 }
//                 helper.showToast(component, event, data);
//             }
//         );   
// helper.refreshView(component, event);     
//     },
    // AA 04/08/2024 Added to refresh view from lwc.
        handleRefreshView: function(component, event, helper) {
            helper.refreshView(component,event);
        },

    handleChange:function(component,event,helper){
        var bureauId = component.get('v.bureauId');
        var bureauListString = $A.get('$Label.c.International_Ids');            
        var bureauList = [];
        bureauList = bureauListString.split(',');
        if(bureauList.indexOf(bureauId) != -1) {
            var story = component.find('storyId').get('v.value');
            var defaultCostCenter = $A.get('$Label.c.International_Default_Cost_Center_Id');
            if(story){
                helper.getStoryCostCenter(component,story).then(function(result){
                    if(result){
                        component.set('v.costCenter', result);
                    }else{
                        component.set('v.costCenter', defaultCostCenter);
                    }

                });   
            }
        }   
    },
 
    closeModal:function(component,event,helper){    
        component.set('v.showNewEmployeeModal', false);
    },
 
    openModal: function(component,event,helper) {
        component.set('v.showNewEmployeeModal', true);
        var internationalAutoPopulation = component.get('c.setInternationalDefaultValues');
        var domesticAutoPopulation = component.get('c.setDomesticDefaultValues');
        $A.enqueueAction(internationalAutoPopulation);
        $A.enqueueAction(domesticAutoPopulation);
    },
 
    handleDateChange : function(component, event, helper){
        var newDate = event.getParam('value');
        var minDate = component.get('v.dayDateMin', 'v.value');
        var maxDate = component.get('v.dayDateMax', 'v.value');
     /* var paseNewDate = new Date(newDate);
        var timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;  
        var timezoneEurope = timezone.slice(0,6);
        var timezoneAsia = timezone.slice(0,4);
        if(timezoneEurope==='Europe' || timezoneAsia==='Asia'){
            paseNewDate.setHours(0,0,0);
        }else{
           paseNewDate.setDate(paseNewDate.getDate());
        }
        console.log(paseNewDate);
        var tempDate=paseNewDate.toString(); */
        
       /* if(
            new Date(tempDate) > new Date(maxDate) ||
            new Date(tempDate) < new Date(minDate)
        ) {
            var data = {
                "Title" : "Date out",
                "message" : "Only one week of assignments can be created at a time . Please review the selected Dates",
                "type" : "warning"
            }
            helper.showToast(component, event, data);
            return;
        }*/
        component.set('v.dayDate', newDate);
    },
 
        
    handleEndDateChange : function(component, event, helper){
        var newDate = event.getParam('value');
        var minDate = component.get('v.dayDateMin', 'v.value');
        var maxDate = component.get('v.dayDateMax', 'v.value');
   /*   var paseNewDate = new Date(newDate);
        var timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;  
        var timezoneEurope = timezone.slice(0,6);
        var timezoneAsia = timezone.slice(0,4);
        if(timezoneEurope==='Europe' || timezoneAsia==='Asia'){
            paseNewDate.setHours(0,0,0);
        }else{
                paseNewDate.setDate(paseNewDate.getDate());
        }
 
        
        var tempDate=paseNewDate.toString(); */
       
     /*   if(
            new Date(tempDate) > new Date(maxDate) ||
            new Date(tempDate) < new Date(minDate) &&
            newDate != null 
        ) {
            var data = {
                "Title" : "Date out",
                "message" : "Only one week of assignments can be created at a time . Please review the selected Dates",
                "type" : "warning"
            }
            helper.showToast(component, event, data);
            return;
        } */
             component.set('v.endDate', newDate);
    },
 
    handleStoryAssignation : function(component, event, helper) {
 
   /*   var timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;  
        var timezoneEurope = timezone.slice(0,6);
        var timezoneAsia = timezone.slice(0,4); */
        var createNewAssignmentButton = component.find('createNewAssignmentButton');
        createNewAssignmentButton.set('v.disabled', true);
        var storyId = component.find('storyId').get('v.value');
        var locationId = component.find('locationId').get('v.value');
        var assignmentInformation = component.find('assignmentInformation').get('v.value');
        var liveShot = component.find('liveShot').get('v.value');
        var prosumerUsed = component.find('prosumerUsed').get('v.value');
        var breakingNews = component.find('breakingNews').get('v.value');
        var schedule = component.get('v.schedule');
        var costCenterId = component.find('costCenterId').get('v.value');
        var employeeId = component.get('v.employeeId');
        var dayDate = component.get('v.dayDate');
        var endDate = component.get('v.endDate');
        var bureau  = component.get('v.bureauId');
        var parsedStartDate = new Date(dayDate);
        var parsedEndDate = new Date(endDate);
        var minDate = component.get('v.dayDateMin', 'v.value');
        var maxDate = component.get('v.dayDateMax', 'v.value');
 
        if(dayDate === null) {
            var data = {
                "Title" : "Empty date",
                "message" : "Please select a date",
                "type" : "warning"
            }
            helper.showToast(component, event, data);
            createNewAssignmentButton.set('v.disabled', false);
            return;
        }
                if(
            endDate != null &&
            parsedStartDate > parsedEndDate
        ) {
            var data = {
                "Title" : "Wrong dates",
                "message" : "The end date cannot be less than the start date.",
                "type" : "warning"
            }
            helper.showToast(component, event, data);
            createNewAssignmentButton.set('v.disabled', false);
            return;
        }
        
    /*  if(timezoneEurope==='Europe' || timezoneAsia==='Asia'){
            parsedStartDate.setHours(0,0,0);
            parsedEndDate.setHours(0,0,0);
        }else{
          parsedStartDate.setDate(parsedStartDate.getDate());
          parsedEndDate.setDate(parsedEndDate.getDate());
        }
        var sd=parsedStartDate.toString();
        var ed=parsedEndDate.toString(); */
        
    /*    if(
            new Date(sd) > new Date(maxDate) ||
            new Date(sd) < new Date(minDate) ||
            new Date(ed) > new Date(maxDate) ||
            new Date(ed) < new Date(minDate) &&
            endDate != null
        ) {
            var data = {
                "Title" : "Date out",
                "message" : "Only one week of assignments can be created at a time . Please review the selected Dates",
                "type" : "warning"
            }
            helper.showToast(component, event, data);
            createNewAssignmentButton.set('v.disabled', false);
            return;
        }
*/
 
 
        if(schedule == null) {
            schedule = {
                "Id" : ""
            }
        }
 
        if(
            bureau == null
        ) {
            var data = {
                "Title" : "Mandatory fields",
                "message" : "Please Select a bureau before adding employees!",
                "type" : "warning"
            }
            helper.showToast(component, event, data);
            return;      
        }
 
        if(
            storyId == "" ||
            storyId == null ||
            locationId == null ||
            locationId == "" ||
            costCenterId == null ||
            costCenterId == "null" ||
            costCenterId == "" ||
            assignmentInformation == "null" ||
            breakingNews == "null" ||
            liveShot == "null" ||
            prosumerUsed == "null"
        ) {
            var data = {
                "Title" : "Mandatory fields",
                "message" : "Please complete all fields",
                "type" : "warning"
            }
 
            helper.showToast(component, event, data);
            createNewAssignmentButton.set('v.disabled', false);
            return;      
        } else {
            var parameters = {
                "storyId" : storyId,
                "locationId" : locationId,
                "assignmentInformation" : assignmentInformation,
                "scheduleId" : schedule.Id,
                "costCenterId" : costCenterId,
                "employeeId" : employeeId,
                "dayDate" : dayDate,
                "bureauId" : bureau,
                "liveShot" : liveShot,
                "prosumerUsed" : prosumerUsed,
                "breakingNews" : breakingNews,
                "endDate" : endDate
            }
            helper.storyAssignationHelperPromise(component, event, parameters).
            then(
                assignationResult => {
                    var data = {
                        "title" : "Story has been successfuly assigned",
                        "type" : "success",
                        "message" : "The selected story has been succesfully assigned!"
                    }
                    var closeModal = component.get('c.closeModal');
                    helper.showToast(component, event, data);
                    $A.enqueueAction(closeModal);
                    helper.refreshView(component, event);
                    createNewAssignmentButton.set('v.disabled', false);
                }
            ).catch(
                error =>{
                    console.log(error);
                    var assignmentError = error;
                    var errorMessages = helper.parseErrorObject(assignmentError);
                    var data = {
                        "title" : "Error during asignation",
                        "type" : "error",
                        "message" : "There was an error during story assignment. " + errorMessages
                    }
                    helper.showToast(component, event, data);
                    createNewAssignmentButton.set('v.disabled', false);
                }
            );
        }
    },
 
    cloneToNextDay : function(component, event, helper) {
        var stories = component.get('v.stories');
        component.set('v.showDayCloneModal', true);
        var storyEmployeeAssociations = [];
        stories.forEach(story => {
            storyEmployeeAssociations.push(story.name);
        });
        component.set('v.seaIdsToClone', storyEmployeeAssociations);
    },
    cloneToDate : function(component, event, helper) {
        var stories = component.get('v.stories');
        component.set('v.showDateCloneModal', true);
        var storyEmployeeAssociations = [];
        stories.forEach(story => {
            storyEmployeeAssociations.push(story.name);
        });
        var flow = component.find("Story_Clone");
        var inputVariables = [
            { 
                name : "Input_SEAs", 
                type : "String", 
                value: storyEmployeeAssociations 
            }
        ];
        flow.startFlow("Story_Clone", inputVariables);
    },
 
    handleFlowStatusChange : function (component, event, helper) {
        var status = event.getParam('status');
        if (status === "FINISHED") {
            helper.showToast(
                component, 
                event, 
                {
                    "title" : "DAY CLONING SUCCESSFUL",
                    "message" : "Record successfully cloned!",
                    "Type" : "success"
                }
            );
            component.set('v.showDayCloneModal', false);
            helper.refreshView(component, event);
        }
        if (status === "ERROR") {
            helper.showToast(
                component, 
                event, 
                {
                    "title" : "DAY CLONING ERROR",
                    "message" : "An error has ocurred. Please try again",
                    "Type" : "error"
                }
            );
            component.set('v.showDayCloneModal', false);
            helper.refreshView(component, event);
        }
    },
    handleFlowStoryStatusChange : function (component, event, helper) {
 
        var status = event.getParam('status');
        if (status === "FINISHED") {
            helper.showToast(
                component, 
                event, 
                {
                    "title" : "STORY CLONE SUCCESSFUL",
                    "message" : "Record successfully cloned!",
                    "Type" : "success"
                }
            );
            component.set('v.showDateCloneModal', false);
            helper.refreshView(component, event);
        }
        if (status === "ERROR") {
            helper.showToast(
                component, 
                event, 
                {
                    "title" : "STORY CLONE ERROR",
                    "message" : "An error has ocurred. Please try again",
                    "Type" : "error"
                }
            );
            component.set('v.showDateCloneModal', false);
            helper.refreshView(component, event);
        }
    },
 
    closeWeekClone : function (component, event, helper) {
        component.set('v.showDayCloneModal', false)
        component.set('v.showDateCloneModal', false)
    },
 
    setCloneButtonVisibility : function(component, event, helper) {
        var stories = component.get('v.stories');
        if(stories.length > 0) {
            component.set('v.cloneButtonVisibility', true);
        }else{
            component.set('v.cloneButtonVisibility', false);
        }
    },
 
    setInternationalDefaultValues : function(component, event, helper) {
        var bureauId = component.get('v.bureauId');
        var bureauListString = $A.get('$Label.c.International_Ids');
        var location = component.get('v.employeeLocation');
        var defaultLocation;
        console.log('location:', location);
        if(location == null || location == '' || location == undefined ) {
            defaultLocation = $A.get('$Label.c.International_Default_Location_Id');
        } else {
            defaultLocation = location;
        }
        var defaultAssignmentInformation = $A.get('$Label.c.International_Default_Assignmet_Information');
        var defaultCostCenter = $A.get('$Label.c.International_Default_Cost_Center_Id');
        var bureauList = [];
        bureauList = bureauListString.split(',');
        if(bureauList.indexOf(bureauId) != -1) {
            component.find('locationId').set('v.value', defaultLocation);
            component.find('assignmentInformation').set('v.value', defaultAssignmentInformation);
            component.find('costCenterId').set('v.value', defaultCostCenter);
        }
    },
 
    setDomesticDefaultValues : function(component, event, elper) {
        var location = component.get('v.employeeLocation');
        var bureauListString = $A.get('$Label.c.International_Ids');
        var bureauId = component.get('v.bureauId');
        var bureauList = [];
        bureauList = bureauListString.split(',');
        if(
            location !== null &&
            location !== '' &&
            location !== undefined &&
            bureauList.indexOf(bureauId) == -1
        ) {
            component.find('locationId').set('v.value', location);
        }
    },
 
    handleDayCloneModalClosing : function(component, event, helper) {
    /*  component.set('v.showDayCloneModal', false)
        component.set('v.showDateCloneModal', false)*/
        var closeModal = component.get('c.closeModal');
        $A.enqueueAction(closeModal);
        helper.refreshView(component, event);
        /*
         let to = window.setTimeout(
                () => {
                            helper.refreshView(component, event);
                }, 
                4000
                    );
 
        */
    }
 
})