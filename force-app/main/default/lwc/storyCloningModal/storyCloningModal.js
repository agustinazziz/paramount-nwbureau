import { api, track } from 'lwc';
import LightingModal from 'lightning/modal';

export default class StoryCloningModal extends LightingModal {
   @track isModalOpen = false;
    @api stories;
    @api storyEmployeeAssociations;

    get inputVariables() {
        const storyEmployeeAssociations = this.stories.map(story => story.name);

        return [
            {
                name: 'Input_SEAs',
                type: 'String',
                value: storyEmployeeAssociations
            }
        ];
    }

    closeModal() {
        this.close();
    }

    handleStatusChange(event) {
        console.log('gl 0       '+event.detail.status);
        if (event.detail.status === 'FINISHED') {
            this.close('OK');

        }
        if (event.detail.status === 'ERROR') {
           this.close('Error');
        }
        console.log("gl at the end of the method ");
    }
}