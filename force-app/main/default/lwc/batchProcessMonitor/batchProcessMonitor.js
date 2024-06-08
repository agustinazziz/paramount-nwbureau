import { api, LightningElement } from 'lwc';
import getApexData from '@salesforce/apex/batchProcessMonitorController.getBatchStatus';

export default class BatchProcessMonitor extends LightningElement {
    @api bureau;
    showProgressBar = false;
    progress = 0;
    progressLabel;

    connectedCallback(){
        this.verifyJobsInProgress();
    }

    updateCloningVisibility(value){
        const cloneVisibilyEvent = new CustomEvent(
            'monitorevent',
            {
                detail : {
                    disableCloning : value
                }
            }
            
        );
        this.dispatchEvent(cloneVisibilyEvent);
    }

    calculateProgress(data) {
        let progressNumber = (data.processed / data.total) * 100;
        this.progress = progressNumber;
        this.progressLabel = isNaN(progressNumber) ? '0%' :  Math.round(progressNumber) + '%';
    }

    queryApexJobs() {
        getApexData()
            .then( result => {
                let parsedResult = JSON.parse(result);
                if(parsedResult.jobsInProgress) {
                    this.showProgressBar = true;
                    this.updateCloningVisibility(true);
                    this.calculateProgress(parsedResult);
                } else {
                    this.showProgressBar = false;
                    this.updateCloningVisibility(false);
                }
            })
            .catch( error => {
                console.log('error:', error);
            });
    }

    verifyJobsInProgress() {
        let scope = this;
        const timeoutId = setInterval(
            function() {
                scope.queryApexJobs();
            }, 
            5000
        );
        
        console.log('verification executed');
    }

}