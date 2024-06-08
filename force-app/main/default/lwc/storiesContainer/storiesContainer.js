import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import  deleteAssignment from "@salesforce/apex/EmployeeDayController.deleteStoryAssignation";

export default class StoriesContainer extends LightningElement {
    @api items;

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    handleItemRemove(event) {
        const assignmentId = event.detail.item.name;
        const storyName = event.detail.item.label;

        if(!confirm("Delete this assignment?")){
            return;
        }
        
        deleteAssignment({ storyEmployeeAssociationId: assignmentId })
        .then((result) => {
            console.log('Assignment deleted');

            this.dispatchEvent(new CustomEvent('refreshviewremove', {"message" : "refresh view"}));
            console.log('Refresh sent');
            
            
            this.showToast ("Story Assignation Deletion",
                            `Story assignation ${storyName} was deleted`,
                            "success")
        })
        .catch((error) => {

            this.showToast ("Story Assignation Deletion",
                            `Error while story assignation ${storyName} was deleted`,
                            "error")

        });


    }
        

}