({
    cookieName : '9QaMBs8jBpPBEDg2epa7C4S9',
    
    getStoryCostCenter : function(component, story) {
        var helper = this;
        return new Promise($A.getCallback(function(resolve, reject) {
            var storyCS = component.get("c.getCostCenterFromStory");
            storyCS.setParams({
                storyId: story
            });
            
            storyCS.setCallback(helper, function(response) {
                var status = response.getState();
                if(status === "SUCCESS"){
                    var storyAssignation = response.getReturnValue();
                    resolve(storyAssignation);
                } else if( status === "ERROR"){
                    var assignationErrors = response.getError();
                    console.log(assignationErrors);
                    reject(assignationErrors);
                }
            });
            $A.enqueueAction(storyCS);
        }));
    },

    storyAssignationHelperPromise : function(component, event, parameters) {
        var helper = this;
        var params = parameters;
        return new Promise($A.getCallback(function(resolve, reject) {
            var assignStory = component.get('c.assignStory');
            assignStory.setParams(params);
            assignStory.setCallback(helper, function(response) {
                var status = response.getState();
                if(status === "SUCCESS"){
                    var storyAssignation = response.getReturnValue();
                    resolve(storyAssignation);
                } else if( status === "ERROR"){
                    var assignationErrors = response.getError();
                    console.log(assignationErrors);
                    reject(assignationErrors);
                }
            });
            $A.enqueueAction(assignStory);
            })
        );
    },

    storyDeletionHelperPromise : function(component, event, parameters) {
        var helper = this;
        var params = parameters;
        return new Promise($A.getCallback(function(resolve, reject) {
            var deleteStoryAssignation = component.get('c.deleteStoryAssignation');
            deleteStoryAssignation.setParams(params);
            deleteStoryAssignation.setCallback(helper, function(response) {
                var status = response.getState();
                if(status === "SUCCESS"){
                    var storyDeletionResult = response.getReturnValue();
                    resolve(storyDeletionResult);
                } else if( status === "ERROR"){
                    var deletionErrors = response.getError();
                    console.log(JSON.stringify(deletionErrors));
                    reject(deletionErrors.message);
                }
            });
            $A.enqueueAction(deleteStoryAssignation);
        }));
    },

    showToast : function(component, event, data) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(data);
        toastEvent.fire();
    },

    refreshView : function(component, event) {
        var refresh = component.getEvent("refreshViewEventWeek");
        refresh.setParams({
            "message" : "refresh view"
        });
        refresh.fire();
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

    parseErrorObject : function(errorObject) {
        var pageErrors = '';
        errorObject.forEach( error => {
            error.pageErrors.forEach( pageError => {
                pageErrors = pageErrors + pageError.message + ' - ';
            });
        });
        return pageErrors;
    },
           
    minDateCalculation : function(dateString){
        var minDate = new Date(dateString);
        minDate.setUTCDate(minDate.getUTCDate() - minDate.getUTCDay());
        var minDateString = minDate.getUTCFullYear() + '-' + (minDate.getUTCMonth() + 1)  + '-' + minDate.getUTCDate();
        return minDateString;
    },

    maxDateCalculation : function(dateString){
        var maxDate = new Date(dateString);
        maxDate.setUTCDate(maxDate.getUTCDate() + (6 - maxDate.getUTCDay()));
        var maxDateString = maxDate.getUTCFullYear() + '-' + (maxDate.getUTCMonth() + 1) + '-' + maxDate.getUTCDate();
        return maxDateString;
    }
})