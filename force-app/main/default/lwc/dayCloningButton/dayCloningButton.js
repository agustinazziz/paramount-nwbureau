import { LightningElement,api } from 'lwc';
import MyModal from 'c/dayClone';
export default class DayCloningButton extends LightningElement {


    
    _disableCondition;
    @api assignmentList;
    @api targetEmployee;
    @api bureauId;
    @api
    get disabledCondition() {
        return this._disableCondition;
    }
    set disabledCondition(value) {
        this._disableCondition = value;
    }

    async handleOpenDayClone() {
        console.log('open modal');
        await MyModal.open({
            size: 'small',
            description: 'Open Modal',
            assignmentList: this.assignmentList,
            targetEmployee: this.targetEmployee,
            bureauId: this.bureauId,
            onrefreshviewdayclone:(e)=>{

                this.dispatchEvent(new CustomEvent('refreshviewdayclone'));
            }
        });

    }

    handeEvent(){

    }



}