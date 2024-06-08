({
    afterRender : function (component, helper) {
        this.superAfterRender();
        try {
            helper.refreshView(component, event);
        } catch (error) {
            console.log(error.message);
        }
    }
})