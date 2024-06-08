import { LightningElement, api } from 'lwc';
import MyModal from 'c/storyCloningModal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class StoryCloningButton extends LightningElement {

    _disableCondition;
    @api stories;
    @api storyEmployeeAssociations;
    @api
    get disabledCondition() {
        return this._disableCondition;
    }
    set disabledCondition(value) {
        this._disableCondition = value;
    }

    async openModal() {

        const result = await MyModal.open({
            size: 'small',
            description: 'Open Modal',
            stories: this.stories,
            storyEmployeeAssociations: this.storyEmployeeAssociations,
            onrefreshview:(e)=>{
                
                console.log('Llega 2');

            }
        });
        if (result === 'OK') {
            this.showToast('STORY CLONE SUCCESSFUL', 'Record successfully cloned!', 'success');
            this.dispatchEvent(new CustomEvent('refreshview'));
        } if (result === 'Error') {
            this.showToast('STORY CLONE ERROR', 'An error has ocurred. Please try again', 'error');
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
}