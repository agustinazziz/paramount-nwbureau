import { LightningElement } from 'lwc';
import { FlowNavigationNextEvent, FlowNavigationFinishEvent } from 'lightning/flowSupport';

export default class FlowNavigation extends LightningElement {

    handleClick(event){
        const TITLE = event.target.title;
        switch (TITLE) {
            case 'Cancel':
                console.log(TITLE);
                const customEvent = new CustomEvent('closemodal', {
                    detail: { message: 'Clo' }
                });
                this.dispatchEvent(customEvent);
                break;

            case 'Assign Story':
                console.log(TITLE);
                const finishNavigationEvent = new FlowNavigationFinishEvent();
                this.dispatchEvent(finishNavigationEvent);
                break;

            default:
                this.flowView = true;
                break;
        }
    }
}