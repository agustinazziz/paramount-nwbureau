({
    cookieName : '9QaMBs8jBpPBEDg2epa7C4S9',

    removeEmployeeWeekAssignations : function(component, event) {
        component.find('removeButton').set('v.disabled', true);
        var employeeId = component.get('v.employeeId');
        var dashboardCookie = JSON.parse(this.getCookie(this.cookieName));
        var currentWeek = JSON.stringify(dashboardCookie.currentWeek);
        var bureau = dashboardCookie.bureau;
        return new Promise($A.getCallback(function(resolve, reject) {
            var removeEmployeeAssignations = component.get('c.removeAssignations');
            removeEmployeeAssignations.setParams({
                "employeeId" : employeeId,
                "currentWeek" : currentWeek,
                "bureau" : bureau
            });
            removeEmployeeAssignations.setCallback(this, function(response) {
                var status = response.getState();
                if(status === "SUCCESS"){
                    var removalResult = response.getReturnValue();
                    resolve(removalResult);
                } else if( status === "ERROR"){
                    var removalErrors = response.getError();
                    console.log(JSON.stringify(removalErrors));
                    component.find('removeButton').set('v.disabled', false);
                    reject('rejected');
                }
            });
            $A.enqueueAction(removeEmployeeAssignations);
        }));
    },

     getCookie : function(name) {
        var cookieObject = {};
        var originalCookieValue = document.cookie;
        var cookies = originalCookieValue.replace('CookieConsentPolicy=0:1; ', '').split(';');
        for(var item in cookies) {
            var cookie = cookies[item].split('=');
            cookieObject[cookie[0]] = cookie[1];
        }
        return cookieObject[name];
    }, 

    showToast : function(component, event, data) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": data.title,
            "message": data.message,
            "type" : data.type
        });
        toastEvent.fire();
    }
})