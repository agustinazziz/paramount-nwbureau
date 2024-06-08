({
    cookieName: '9QaMBs8jBpPBEDg2epa7C4S9',

    setDefaultDate: function (component, event) {
        var dashboardCookie = this.getCookie(this.cookieName);
        var currentWeek;
        if (dashboardCookie === undefined) {
            var cleanDate = this.getCleanDate(new Date());
            currentWeek = this.getCurrentWeek(cleanDate);
            this.createCookie(
                this.cookieName,
                {
                    "currentWeek": currentWeek,
                    "dashboardDate": cleanDate,
                    "employees": []
                },
                7
            );
            dashboardCookie = JSON.parse(this.getCookie(this.cookieName));
            component.set('v.dashboardDate', new Date(dashboardCookie.dashboardDate));
            component.set('v.currentWeek', dashboardCookie.currentWeek);
            component.find('datePicker').set('v.value', dashboardCookie.dashboardDate);
            this.setDefaultBureau(component, event);
        } else {
            dashboardCookie = JSON.parse(dashboardCookie);
            component.set('v.dashboardDate', new Date(dashboardCookie.dashboardDate));
            component.find('datePicker').set('v.value', dashboardCookie.dashboardDate);
            component.find('bureauPicker').set('v.value', dashboardCookie.bureau);
        }
    },

    setDefaultBureau: function (component, event) {
        var dashboardCookie = JSON.parse(this.getCookie(this.cookieName));
        var helper = this;
        this.getDefaultBureau(component, event).
            then(
                $A.getCallback(function (bureauId) {
                    component.set('v.bureau', bureauId.SetupOwnerId);
                    dashboardCookie.bureau = bureauId.SetupOwnerId;
                    helper.createCookie(
                        helper.cookieName,
                        bureauId.SetupOwnerId,
                        7
                    );
                    component.set('v.bureau', bureauId.SetupOwnerId);
                    component.find('bureauPicker').set('v.value', bureauId);
                })
            ).catch(
                $A.getCallback(function (error) {
                    var data = {
                        "title": "UNEXPECTED ERROR",
                        "message": "An unexpected error has occurred while populating default bureau " +
                            "if error persist please contact your system administrator",
                        "type": "warning"
                    }
                    helper.showToast('Default bureau configuration', event, data);
                    console.log(JSON.stringify(error.message));
                })
            );
    },

    addDays: function (date, days) {
        var unixTime = date.getTime();

        var newDate = new Date(
            unixTime + (days * 86400000)
        );
        return newDate;
    },

    substractDays: function (date, days) {
        var unixTime = date.getTime();
        var newDate = new Date(
            unixTime - (days * 86400000)
        );
        return newDate;
    },

    getCurrentWeek: function (selectdDate) {
        var dashboardDate = new Date(selectdDate);
        var daysToSubstract = dashboardDate.getUTCDay() === 0 ? 0 : dashboardDate.getUTCDay();
        var weekStart = dashboardDate.getUTCDay() === 0 ? dashboardDate : this.substractDays(dashboardDate, daysToSubstract);
        var weekEnd = this.addDays(weekStart, 6);
        var newWeek = {
            "weekStart": weekStart,
            "weekEnd": weekEnd,
            "weekDayNumbers": {
                "SUNDAY": weekStart.getUTCDate(),
                "MONDAY": this.addDays(weekStart, 1).getUTCDate(),
                "TUESDAY": this.addDays(weekStart, 2).getUTCDate(),
                "WEDNESDAY": this.addDays(weekStart, 3).getUTCDate(),
                "THURSDAY": this.addDays(weekStart, 4).getUTCDate(),
                "FRIDAY": this.addDays(weekStart, 5).getUTCDate(),
                "SATURDAY": weekEnd.getUTCDate(),
            },
            "weekDates": {
                "SUNDAY": weekStart.getUTCFullYear() + '-' +
                    (weekStart.getUTCMonth() + 1) + '-' +
                    weekStart.getUTCDate(),
                "MONDAY": this.addDays(weekStart, 1).getUTCFullYear() + '-' +
                    (this.addDays(weekStart, 1).getUTCMonth() + 1) + '-' +
                    this.addDays(weekStart, 1).getUTCDate(),
                "TUESDAY": this.addDays(weekStart, 2).getUTCFullYear() + '-' +
                    (this.addDays(weekStart, 2).getUTCMonth() + 1) + '-' +
                    this.addDays(weekStart, 2).getUTCDate(),
                "WEDNESDAY": this.addDays(weekStart, 3).getUTCFullYear() + '-' +
                    (this.addDays(weekStart, 3).getUTCMonth() + 1) + '-' +
                    this.addDays(weekStart, 3).getUTCDate(),
                "THURSDAY": this.addDays(weekStart, 4).getUTCFullYear() + '-' +
                    (this.addDays(weekStart, 4).getUTCMonth() + 1) + '-' +
                    this.addDays(weekStart, 4).getUTCDate(),
                "FRIDAY": this.addDays(weekStart, 5).getUTCFullYear() + '-' +
                    (this.addDays(weekStart, 5).getUTCMonth() + 1) + '-' +
                    this.addDays(weekStart, 5).getUTCDate(),
                "SATURDAY": weekEnd.getUTCFullYear() + '-' +
                    (weekEnd.getUTCMonth() + 1) + '-' +
                    weekEnd.getUTCDate(),
            }
        }
        return newWeek;
    },

    fixTimeZoneOffset: function (dateToFix) {
        var unixTime = dateToFix.getTime();
        var userTimeZoneOffset = dateToFix.getTimezoneOffset() * 60000;
        var newDate = new Date((unixTime - userTimeZoneOffset));
        return newDate;
    },

    createCookie: function (name, value, days) {
        var expiration;
        if (days) {
            var date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
            expiration = date.toGMTString();
        } else {
            expiration = "";
        }
        document.cookie = name + '=' + JSON.stringify(value) + '; expires=' + expiration + '; path=/';
    },

    getCookie: function (name) {
        var cookieObject = {};
        var originalCookieValue = document.cookie;
        var cookies = originalCookieValue.
            replace('CookieConsentPolicy=0:1; ', '').
            replace('CookieConsentPolicy=0:0; ', '').
            split(';');
        for (var item in cookies) {
            var cookie = cookies[item].split('=');
            cookieObject[cookie[0]] = cookie[1];
        }
        return cookieObject[name];
    },

    stateChangeHandler: function (component, event) {

        var dashboardDate = component.get('v.dashboardDate');
        var selectedBureau = component.find('bureauPicker').get('v.value');
        component.set(
            'v.currentWeek',
            this.getCurrentWeek(dashboardDate)
        );
        var employees = component.get('v.employees');
        var newAppState = {
            "dashboardDate": dashboardDate,
            "currentWeek": this.getCurrentWeek(dashboardDate),
            "employees": employees,
            "bureau": selectedBureau
        }
        this.createCookie(
            this.cookieName,
            newAppState,
            7
        );
    },

    refreshView: function (component, event) {
        var helper = this;
        var dashboardCookie = JSON.parse(this.getCookie(this.cookieName));
        var data;
        this.weekDataHelperPromise(
            component,
            dashboardCookie.currentWeek.weekStart,
            dashboardCookie.currentWeek.weekEnd,
            dashboardCookie.bureau
        ).then(
            $A.getCallback(function (value) {
                helper.cleanEmployees(component);
                data = value;
            })
        ).then(
            $A.getCallback(function (value) {
                helper.initializeGrid(component, event);
            })
        );
        component.set('v.weekData', data);
    },

    parseNewSelectedDate: function (selectedDate) {
        var dateObject = new Date(selectedDate);
        var cleanWeekStart = dateObject.getUTCFullYear() +
            '-' + (dateObject.getUTCMonth() + 1) +
            '-' + dateObject.getUTCDate();
        return cleanWeekStart;
    },

    getCleanDate: function (selectedDate) {
        return selectedDate.getUTCFullYear() +
            '-' + (selectedDate.getUTCMonth() + 1) +
            '-' + selectedDate.getUTCDate();
    },

    showToast: function (component, event, data) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": data.title,
            "message": data.message,
            "type": data.type
        });
        toastEvent.fire();
    },

    getBureaus: function (component, event) {
        var allBureaus = component.get('c.getActiveBureaus');
        allBureaus.setCallback(this, function (response) {
            var status = response.getState();
            if (status === "SUCCESS") {
                var costCenters = JSON.parse(response.getReturnValue());
                var costCenterValuePairs = [];
                costCenters.forEach(costCenter => {
                    costCenterValuePairs.push({
                        "label": costCenter.Name,
                        "value": costCenter.Id
                    })
                });
                costCenterValuePairs.sort((a, b) => a.label.localeCompare(b.label));
                component.set('v.bureauOptions', costCenterValuePairs);
            } else if (status === "ERROR") {
                var cloneErrors = response.getError();
                console.log(JSON.stringify(cloneErrors));
            }
        });
        $A.enqueueAction(allBureaus);
    },

    weekDataHelper: function (component, weekStart, weekEnd, bureau) {
        this.lockNavigation(component);
        weekStart = this.getCleanDate(new Date(weekStart));
        weekEnd = this.getCleanDate(new Date(weekEnd));
        var getWeekData = component.get('c.getAllWeekData');
        getWeekData.setParams({
            "weekStart": weekStart,
            "weekEnd": weekEnd,
            "bureau": bureau
        });
        getWeekData.setCallback(this, function (response) {
            var status = response.getState();
            if (status === "SUCCESS") {
                var weekData = JSON.parse(response.getReturnValue());
                component.set('v.weekData', weekData);
                this.unlockNavigation(component);
            } else if (status === "ERROR") {
                var cloneErrors = response.getError();
                console.log(JSON.stringify(cloneErrors));
            }
        });
        $A.enqueueAction(getWeekData);
    },

    employeeDataHelper: function (component, employeeId, currentWeek, bureau) {
        return new Promise($A.getCallback(function (resolve, reject) {
            var getEmployeeData = component.get('c.getEmployeeData');
            getEmployeeData.setParams({
                "employeeId": employeeId,
                "currentWeek": currentWeek,
                "bureau": bureau
            });
            getEmployeeData.setCallback(this, function (response) {
                var status = response.getState();
                if (status === "SUCCESS") {
                    var employeeData = JSON.parse(response.getReturnValue());
                    component.set('v.employeeData', employeeData);
                    resolve(employeeData);
                } else if (status === "ERROR") {
                    var cloneErrors = response.getError();
                    console.log(JSON.stringify(cloneErrors));
                    reject('rejected');
                }
            });
            $A.enqueueAction(getEmployeeData);
        }));
    },

    getDefaultBureau: function (component, event) {
        return new Promise($A.getCallback(function (resolve, reject) {
            var defaultBureau = component.get('c.getBureauWithUser');
            defaultBureau.setCallback(this, function (response) {
                var status = response.getState();
                if (status === "SUCCESS") {
                    var bureau = response.getReturnValue();
                    component.set('v.bureau', bureau);
                    resolve(bureau);
                } else if (status === "ERROR") {
                    var bureauErrors = response.getError();
                    console.log(JSON.stringify(bureauErrors));
                    reject(bureauErrors);
                }
            });
            $A.enqueueAction(defaultBureau);
        }));
    },

    weekDataHelperPromise: function (component, weekStart, weekEnd, bureau) {
        var helper = this;
        return new Promise($A.getCallback(function (resolve, reject) {
            helper.lockNavigation(component);
            weekStart = helper.getCleanDate(new Date(weekStart));
            weekEnd = helper.getCleanDate(new Date(weekEnd));
            var getWeekData = component.get('c.getAllWeekData');
            getWeekData.setParams({
                "weekStart": weekStart,
                "weekEnd": weekEnd,
                "bureau": bureau
            });
            getWeekData.setCallback(helper, function (response) {
                var status = response.getState();
                if (status === "SUCCESS") {
                    var weekData = response.getReturnValue();
                    // GL 4/18/24 #1553: LWC storyFilterButton
                    console.log('gl aura v1');
                    component.set('v.weekDataClean', weekData);
                    let storiesFiltered = component.get('v.storiesFiltered');
                    let employeeFiltered = component.get('v.employeeFiltered');
                    let handledata = JSON.parse(weekData);
                    //if (storiesFiltered) {
                        handledata.forEach(employee => {
                            Object.keys(employee.stories).forEach(key => {
                                employee.stories[key] = employee.stories[key].filter(obj => !storiesFiltered.includes(obj.label));
                            });
                        });
                   // } 

                    handledata = handledata.filter(item => {
                        return Object.values(item.stories).some(story => story.length !== 0);
                    });
                    //if (employeeFiltered) {
                        handledata = handledata.filter(item => !employeeFiltered.includes(item.employeeName));
                        
                   // }  
                   
                   //AA 6/4/2024 #1590 Synchronized filter
                   component.set('v.weekDataFilter', handledata);

                    weekData = JSON.stringify(handledata);
                    //GL 4/18/24 #1553: until this line
                    component.set('v.weekData', weekData);
                    helper.unlockNavigation(component);
                    resolve(weekData);
                } else if (status === "ERROR") {
                    var cloneErrors = response.getError();
                    console.log(JSON.stringify(cloneErrors));
                    reject("Rejected");
                }
            });
            $A.enqueueAction(getWeekData);
        }));
    },

    lockNavigation: function (component) {
        component.find('previousWeekButton').set('v.disabled', true);
        component.find('datePicker').set('v.disabled', true);
        component.find('bureauPicker').set('v.disabled', true);
    },

    unlockNavigation: function (component, event) {
        component.find('previousWeekButton').set('v.disabled', false);
        component.find('datePicker').set('v.disabled', false);
        component.find('bureauPicker').set('v.disabled', false);
    },

    createEmployeeWeekComponent: function (component, employee) {
        var employees = component.get('v.employees');
        var bureau = component.find('bureauPicker').get('v.value');
        var headerComponent;
        headerComponent = this.createSectionHeaderComponent(component, employee);
        $A.createComponent(
            "c:employeeWeek",
            {
                "name": employee.employeeId,
                "employeeName": employee.employeeName,
                "employeeId": employee.employeeId,
                "employeeTitle": employee.employeeTitle,
                "employeeLocation": employee.employeeLocation,
                "sunday": employee.stories.sunday,
                "monday": employee.stories.monday,
                "tuesday": employee.stories.tuesday,
                "wednesday": employee.stories.wednesday,
                "thursday": employee.stories.thursday,
                "friday": employee.stories.friday,
                "saturday": employee.stories.saturday,
                "weekDates": employee.weekDates,
                "bureau": bureau,
                "weekCalendarDates": employee.weekCalendarDates
            },
            $A.getCallback(function (newEmployee, status, errorMessage) {

                if (status === "SUCCESS") {
                    if (employee.header) {
                        employees = employees.concat(headerComponent);
                    }
                    employees = employees.concat(newEmployee);
                    component.set("v.employees", employees);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + JSON.stringify(errorMessage));
                }
            })
        );
    },

    createSectionHeaderComponent: function (component, employee) {
        var self = this;
        $A.createComponent(
            "c:SectionHeader",
            {
                "label": employee.sortingGroup
            },
            $A.getCallback(function (newHeader, status, errorMessage) {

                if (status === "SUCCESS") {
                    component.set("v.newHeaderComponent", newHeader);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                } else if (status === "ERROR") {
                    console.log("Error: " + JSON.stringify(errorMessage));
                }
            })
        );
        var headerComponent = component.get("v.newHeaderComponent");
        return headerComponent;
    },

    employeeExist: function (employees, employeeId) {
        employees.forEach(employee => {
            if (employee.attributeSet.values.employeeId == employeeId) {
                return true;
            }
        });
        return false;
    },

    cleanEmployees: function (component) {
        component.set('v.employees', []);
    },

    initializeGrid: function (component, event) {
        var dashboardCookie = JSON.parse(this.getCookie(this.cookieName));
        var gridData = JSON.parse(component.get('v.weekData'));
        var lastSectionHeader;
        gridData.forEach(employee => {
            try {

                if (
                    lastSectionHeader != employee.sortingGroup ||
                    lastSectionHeader == null
                ) {
                    employee.header = true;
                    lastSectionHeader = employee.sortingGroup;
                }
                employee.weekCalendarDates = dashboardCookie.currentWeek.weekDates;
                this.createEmployeeWeekComponent(component, employee);
            } catch (error) {
                console.log(error.message);
            }
        });
    },

    getEmployeesFromWeekData: function (component, event) {
        var employees = [];
        var weekData = JSON.parse(component.get('v.weekData'));
        weekData.forEach(employee => {
            employees.push(employee.employeeId);
        });
        return employees;
    },

    handleScroll: function (component, event) {
        var stickyPosition = 101;
        window.addEventListener('scroll', function (e) {
            var barToStick = component.find('sticky-headbar').getElement();
            var scrollPositionY = window.pageYOffset;

            if (scrollPositionY >= stickyPosition) {
                barToStick.style = `position: sticky; top: ${stickyPosition - 12}px; z-index: 99;`
            } else {
                barToStick.style = `position: relative: top: 0;`
            }
        })
    },

    disableCloning: function (component, event) {
        var employees = component.get('v.employees');
        var weekCloneDisabled = component.find("cloneWeek");
        weekCloneDisabled.set('v.disabled', true);
        employees.forEach(employee => {
            employee.set('v.cloningDisabled', true);
        });
    },

    enableCloning: function (component, event) {
        var employees = component.get('v.employees');
        var weekCloneDisabled = component.find("cloneWeek");
        weekCloneDisabled.set('v.disabled', false);
        employees.forEach(employee => {
            employee.set('v.cloningDisabled', false);
        });
    },

    userDashboardBureauUpdate: function (component, bureau) {

        return new Promise($A.getCallback(function (resolve, reject) {

            var updateUser = component.get('c.updateUserDashboardBureau');
            updateUser.setParams({
                "bureau": bureau
            });
            updateUser.setCallback(this, function (response) {
                var status = response.getState();
                if (status === "SUCCESS") {
                    resolve("success");
                } else if (status === "ERROR") {
                    var errorMessage = response.getError();
                    console.log("Dashboard Bureau update failed: " + JSON.stringify(errorMessage));
                    reject("Rejected");
                }
            });
            $A.enqueueAction(updateUser);

        }));
    }
})