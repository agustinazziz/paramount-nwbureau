({
    initializeComponent: function (component, event, helper) {
        helper.getBureaus(component, event);
        helper.setDefaultDate(component, event);
        helper.handleScroll(component, event);
    },

    handleStateChange: function (component, event, helper) {
        helper.stateChangeHandler(component, event);
    },

    handleDateChange: function (component, event, helper) {
        component.find("employeeFilterButton").cleanList();
        component.find("storyFilterButton").cleanList();
        component.find("employeeFilterButton").noFiltering();
        component.find("storyFilterButton").noFiltering();
        component.set("v.storiesFiltered", []);
        component.set("v.employeeFiltered", []);
        component.set(
            'v.dashboardDate',
            event.getSource().get('v.value')
        );
        helper.refreshView(component);
    },

    handleCreateEmployee: function (component, event, helper) {

        component.set('v.showNewEmployeeModal', false);
        component.set('v.createEmpModal', true);
        var flow = component.find("createEmpFlow");
        flow.startFlow("Create_Employee");

    },

    handlePreviousWeekNavigation: function (component, event, helper) {
        component.find("employeeFilterButton").cleanList();
        component.find("storyFilterButton").cleanList();
        component.find("employeeFilterButton").noFiltering();
        component.find("storyFilterButton").noFiltering();
        component.set("v.storiesFiltered", []);
        component.set("v.employeeFiltered", []);
        var currentWeek = component.get('v.currentWeek');
        var previous = helper.substractDays(currentWeek.weekStart, 7);
        var newDashboardDate = helper.getCleanDate(previous);
        component.set(
            'v.dashboardDate',
            newDashboardDate
        );
        helper.refreshView(component, event);
    },

    handleAddEmployee: function (component, event, helper) {

        var employeeId = component.find('employeeId').get('v.value');
        var weekDataEmployeeList = helper.getEmployeesFromWeekData(component, event);
        if (weekDataEmployeeList.includes(employeeId)) {
            var data = {
                title: "Employee already in the view",
                message: "This employee has already been added",
                type: "warning"
            }
            helper.showToast(component, event, data);
            return;
        }
        if (employeeId == null) {
            var data = {
                title: "Please select an employee",
                message: "Please select an employee to be added.",
                type: "warning"
            }
            helper.showToast(component, event, data);
            return;
        }
        var employeeData;
        var employee;
        var closeModal = component.get('c.closeModal');
        var dashboardCookie = JSON.parse(helper.getCookie(helper.cookieName));
        var currentWeek = JSON.stringify(dashboardCookie.currentWeek);
        var bureau = dashboardCookie.bureau;
        var employeeDataPromise =
            helper.employeeDataHelper(
                component,
                employeeId,
                currentWeek,
                bureau
            );
        employeeDataPromise.then(
            $A.getCallback(function (value) {

                employeeData = value;
                employee = {
                    "employeeName": employeeData.employee.Name,
                    "employeeId": employeeData.employee.Id,
                    "employeeTitle": employeeData.employee.Employee_Title__c,
                    "employeeLocation": employeeData.employee.Location__c,
                    "stories": {
                        "sunday": [],
                        "monday": [],
                        "tuesday": [],
                        "wednesday": [],
                        "thursday": [],
                        "friday": [],
                        "saturday": []
                    },
                    "weekDates": employeeData.weekDates,
                    "weekCalendarDates": dashboardCookie.currentWeek.weekDates,
                    "bureau": bureau
                };
                helper.createEmployeeWeekComponent(component, employee);
            })
        ).catch($A.getCallback(function (error) {
            var data = {
                title: "Unexpected error retriving employee data",
                message: "An unexpected error has ocurred while retrieving employee data. " +
                    "If error persists contact your system administrator",
                type: "warning"
            }
            helper.showToast(component, event, data);
        }));

        $A.enqueueAction(closeModal);
    },

    closeModal: function (component, event, helper) {
        component.set('v.showNewEmployeeModal', false);
    },

    closeCreateEmp: function (component, event, helper) {
        component.set('v.createEmpModal', false);
    },

    openModal: function (component, event, helper) {
        component.set('v.showNewEmployeeModal', true);
    },

    handleBureauChange: function (component, event, helper) {
        component.find("employeeFilterButton").cleanList();
        component.find("storyFilterButton").cleanList();
        component.find("employeeFilterButton").noFiltering();
        component.find("storyFilterButton").noFiltering();
        component.set("v.storiesFiltered", []);
        component.set("v.employeeFiltered", []);
        var selectedBureau = event.getParam("value");
        helper.userDashboardBureauUpdate(component, selectedBureau).
            then(
                $A.getCallback(function (data) {
                    //silent success
                })
            ).catch(
                $A.getCallback(function (error) {
                    console.log(error);
                })
            );
        component.set('v.bureau', selectedBureau);
        helper.refreshView(component, event);
    },

    handleRefreshViewEvent: function (component, event, helper) {
        helper.refreshView(component, event);
    },

    closeWeekClone: function (component, event, helper) {
        component.set('v.showCloneWeekModal', false)
    },

    cloneWeek: function (component, event, helper) {
        component.set('v.showCloneWeekModal', true);
        var flow = component.find("Cloning_for_a_Week_2_0");
        var bureau = component.find('bureauPicker').get('v.value');
        var dashboardCookie = JSON.parse(helper.getCookie(helper.cookieName));
        var inputVariables = [
            { name: "TheBureau2", type: "String", value: bureau },
            { name: "PassaedMonday", type: "String", value: dashboardCookie.currentWeek.weekDates.MONDAY }];

        flow.startFlow("Cloning_for_a_Week_2_0", inputVariables);
    },


    handleFlowStatusChange: function (component, event, helper) {
        if (event.getParam('status') === "FINISHED") {
            var closeWeekCloneModal = component.get('c.closeWeekClone');
            $A.enqueueAction(closeWeekCloneModal);
        }
    },

    handleFlowStatusChangeCE: function (component, event, helper) {
        if (event.getParam('status') === "FINISHED") {
            var closeCreateEmployeeModal = component.get('c.closeCreateEmp');
            var outputVariables = event.getParam("outputVariables");
            var outputVar;
            for (var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                // Pass the values to the component's attributes
                if (outputVar.name === "Employee") {

                    var employeeId = outputVar.value.Id;
                    var weekDataEmployeeList = helper.getEmployeesFromWeekData(component, event);
                    var employeeData;
                    var employee;
                    var closeModal = component.get('c.closeModal');
                    var dashboardCookie = JSON.parse(helper.getCookie(helper.cookieName));
                    var currentWeek = JSON.stringify(dashboardCookie.currentWeek);
                    var bureau = dashboardCookie.bureau;
                    var employeeDataPromise =
                        helper.employeeDataHelper(
                            component,
                            employeeId,
                            currentWeek,
                            bureau
                        );
                    employeeDataPromise.then(
                        $A.getCallback(function (value) {

                            employeeData = value;
                            employee = {
                                "employeeName": employeeData.employee.Name,
                                "employeeId": employeeData.employee.Id,
                                "employeeTitle": employeeData.employee.Employee_Title__c,
                                "employeeLocation": employeeData.employee.Location__c,
                                "stories": {
                                    "sunday": [],
                                    "monday": [],
                                    "tuesday": [],
                                    "wednesday": [],
                                    "thursday": [],
                                    "friday": [],
                                    "saturday": []
                                },
                                "weekDates": employeeData.weekDates,
                                "weekCalendarDates": dashboardCookie.currentWeek.weekDates,
                                "bureau": bureau
                            };
                            helper.createEmployeeWeekComponent(component, employee);
                        })
                    ).catch($A.getCallback(function (error) {
                        var data = {
                            title: "Unexpected error retriving employee data",
                            message: "An unexpected error has ocurred while retrieving employee data. " +
                                "If error persists contact your system administrator",
                            type: "warning"
                        }
                        helper.showToast(component, event, data);
                    }));

                    $A.enqueueAction(closeModal);
                } else {

                }
            }
            $A.enqueueAction(closeCreateEmployeeModal);

        }
    },
    //GC: Redirects to Assignments Import
    gotoList: function (component, event, helper) {
        var action = component.get("c.getListViews");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "Assignment_Import__c"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);

    },

    handleMonitorEvent: function (component, event, helper) {

        var action = event.getParam('disableCloning');

        if (action) {
            helper.disableCloning(component, event);
        } else {
            helper.enableCloning(component, event);
        }

    },
    //GL 4/18/24 #1553: aggregate this function to grab the value form lwc
    getStoriesFromStoryFilter: function (component, event, helper) {
        component.set("v.storiesFiltered", event.getParam('value'));
        component.find("employeeFilterButton").closeModal();
//test
        //AA 6/4/2024 #1590 Synchronized filter
        if (component.get("v.employeeFiltered").length == 0 && event.getParam('value').length > 0) {
            component.set("v.filterController", 'stories');
        }
        if (event.getParam('filterController') == 'stories' && event.getParam('value').length == 0){
            component.find("employeeFilterButton").noFiltering();
            component.set("v.employeeFiltered", []);
            component.set("v.filterController", 'employees');
        }
        if(event.getParam('cleanEmployees')){
            component.set("v.employeeFiltered", []);
            component.find("employeeFilterButton").cleanList();
            component.find("employeeFilterButton").noFiltering();

        }

        helper.refreshView(component, event);
    },
    
    getStoriesFromEmployeeFilter: function (component, event, helper) {
        component.set("v.employeeFiltered", event.getParam('value'));
        component.find("storyFilterButton").closeModal();
        
        //AA 6/4/2024 #1590 Synchronized filter
        if (component.get("v.storiesFiltered").length == 0 && event.getParam('value').length > 0) {
            component.set("v.filterController", 'employees');

        }
        if (event.getParam('filterController') == 'employees' && event.getParam('value').length == 0){
            component.find("storyFilterButton").noFiltering();
            component.set("v.storiesFiltered", []);
            component.set("v.filterController", 'stories');
        }
        if(event.getParam('cleanStories')){
            component.set("v.storiesFiltered", []);
            component.find("storyFilterButton").cleanList();
            component.find("storyFilterButton").noFiltering();
        }
        
        helper.refreshView(component, event);
    },

})