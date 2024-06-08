import { LightningElement, api } from 'lwc';
import bureauListString from "@salesforce/label/c.International_Ids";
import interDefaultId from "@salesforce/label/c.International_Default_Location_Id";
import defaultAssignmentInformation from "@salesforce/label/c.International_Default_Assignmet_Information";
import defaultCostCenter from "@salesforce/label/c.International_Default_Cost_Center_Id";

export default class EmployeeDayLWC extends LightningElement {

    @api stories;
    @api cloneButtonVisibility;
    @api cloningDisabled;
    @api dayDate;
    @api bureauId;
    @api employeeId;
    @api schedule;
    //Vast for default values 
    @api costCenter = null;
    @api assignmentInformation = null;
    @api locationId = null;

    @api employeeLocation;
    @api storyEmployeeAssociations = [];
    @api dayCloneModal = false;
    showNewEmployeeModal;
    @api scheduleId

    connectedCallback() {
        if (this.schedule == null || this.schedule == '' || this.schedule == undefined) {
        } else {
            this.scheduleId = this.schedule.Id;
        }
        this.cloneButtonVisibility = this.stories.length > 0 ? true : false;
        // if (this.stories.length > 0) {
        //     this.cloneButtonVisibility = true;
        // } else {
        //     this.cloneButtonVisibility = false;
        // } 
        this.stories.forEach((element) => {
            this.storyEmployeeAssociations.push(element.name);

        });
        //setInternationalDefaultValues
        let defaultLocation;
        if (this.employeeLocation == null || this.employeeLocation == '' || this.employeeLocation == undefined) {
            defaultLocation = interDefaultId;
        } else {
            defaultLocation = this.employeeLocation;
        }
        let bureauList = [];
        bureauList = bureauListString.split(',');

        if (bureauList.indexOf(this.bureauId) != -1) {
            this.locationId = defaultLocation;
            this.assignmentInformation = defaultAssignmentInformation;
            this.costCenter = defaultCostCenter;
            //console.log('Assign default Int values');
        }
        //setDomesticDefaultValues
        if (
            this.employeeLocation !== null &&
            this.employeeLocation !== '' &&
            this.employeeLocation !== undefined &&
            bureauList.indexOf(this.bureauId) == -1
        ) {
            this.locationId = this.employeeLocation;
            // console.log('Assign default Domestic values'+bureauList.indexOf(this.bureauId));
        }
    }

    handleRefreshView() {
        //console.log('mando Refresh 5');
        const refreshView = new CustomEvent('refreshvieweventweek', { message: 'refresh view' });
        this.dispatchEvent(refreshView);
    }
}