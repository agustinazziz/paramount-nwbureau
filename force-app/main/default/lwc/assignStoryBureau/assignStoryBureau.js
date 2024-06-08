import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class AssignStoryBureau extends LightningElement {
    @api flowView;
    @api employeeId
    @api dayDate;
    @api scheduleId;
    @api bureau;
    @api costCenter;
    @api assignmentInfo;
    @api locationId;


    get inputVariables() {
        return [
            {
                name: 'employeeId',
                type: 'String',
                value: this.employeeId == null ? '' : this.employeeId
            },
            {
                name: 'scheduleId',
                type: 'String',
                value: this.scheduleId == null ? '' : this.scheduleId
            },
            {
                name: 'bureau',
                type: 'String',
                value: this.bureau == null ? '' : this.bureau
            },
            {
                name: 'dayDate',
                type: 'Date',
                value: this.dayDate == null ? '' : this.dayDate
            },
            {
                name: 'defaultAssignmentInformaton',
                type: 'String',
                value: this.assignmentInfo == null? '' : this.assignmentInfo
            },
            {
                name: 'defaultCostCenter',
                type: 'String',
                value: this.costCenter == null ? '' : this.costCenter
            },
            {
                name: 'defaultLocation',
                type: 'String',
                value: this.locationId == null ? '' : this.locationId
            }
        ];
    }

    handleClick(event){
        const TITLE = event.target.title;
        switch (TITLE) {
            case 'Cancel':
                this.flowView = false;
                break;
                
            default:
                this.flowView = true;
                break;
        }
    }

    handleStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            let created = event.detail.outputVariables[0].value;
            if (created) {
                this.showToast ("Story has been successfully assigned",
                `The selected Story has been successfully assigned.`,
                "success")
            }
            else {
                this.showToast ("Error during asignation",
                `There was an error during story assignment. A Story employee association for the same employee and Story Schedule Association already exists!`,
                "error")
            }

            this.dispatchEvent(new CustomEvent('refreshview', {"message" : "refresh view"}));
            this.flowView = false;
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}