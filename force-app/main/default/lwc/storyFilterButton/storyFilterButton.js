import { LightningElement, track, api } from 'lwc';

export default class StoryFilterButton extends LightningElement {
    @api weekDataClean;
    //AA 6/4/2024 #1590 Synchronized filter
    @api weekDataFilter;
    @api filterController;
    @track storiesFilterByEmployees = [];
    isFiltering = false;

    @track valueCombo;
    @track stories = [{ label: "Select a story", value: [""], class: "sendStory" }];
    allClass = "sendStory";
    dropdownClass = "slds-size_1-of-1 slds-dropdown-trigger slds-dropdown-trigger_click slds-is-closed";
    dropdownBool = false;

    fillDropdown() {
        
        //AA 6/4/2024 #1590 Synchronized filter
        if (this.filterController == 'employees' && this.storiesFilterByEmployees.length > 0) {
            this.stories = this.storiesFilterByEmployees;
        }
        else {
            this.storiesFilterByEmployees = [];
            let StoriesInDashboard = [];
            let storyListUniqueValues = [];
            let daysOfWeek = [
                'sunday',
                'monday',
                'tuesday',
                'wednesday',
                'thursday',
                'friday',
                'saturday',
            ];
            //Obtain the stories from the data that brings the WeeklyDashboard.cmp
                let storiesCounter = new Set();
                let filteredStoriesCounter= new Set();
    
                this.fillSet(JSON.parse(this.weekDataClean), storiesCounter, daysOfWeek);
                this.fillSet(this.weekDataFilter, filteredStoriesCounter, daysOfWeek);
    
                
                //AA 6/4/2024 #1590 Synchronized filter
                if(filteredStoriesCounter.size < storiesCounter.size && this.filterController == 'employees'){
                    StoriesInDashboard = this.fillStories(this.weekDataFilter, daysOfWeek);
                    
                }else{
                    StoriesInDashboard = this.fillStories(JSON.parse(this.weekDataClean), daysOfWeek);
        
                }

    
            let StoriesInDashboardTrim = Array.from(new Set(StoriesInDashboard.map(JSON.stringify))).map(JSON.parse);
    
            let mergedData = StoriesInDashboardTrim.reduce((acc, curr) => {
                let existingIndex = acc.findIndex(item => item.storyName === curr.storyName);
                if (existingIndex !== -1) {
                    acc[existingIndex].costCenters.push(curr.costCenter.trim());
                } else {
                    acc.push({
                        storyName: curr.storyName,
                        costCenters: [curr.costCenter.trim()]
                    });
                }
                return acc;
            }, []);
            mergedData.forEach(story => {
                let fullValue = story.storyName + ";;" + story.costCenters.join(";;");
                storyListUniqueValues.push({ label: story.storyName, value: fullValue, class: "sendStory" });
            });
    
            if (this.differentArray(this.stories, storyListUniqueValues)) {
                this.stories = storyListUniqueValues;
                this.stories.sort((a, b) => a.label.localeCompare(b.label));
                this.allClass = "sendStory";
            }
        }
        
    }
    
    //AA 6/4/2024 #1590 Synchronized filter
    @api
    cleanList(){
        this.storiesFilterByEmployees = [];
        this.allClass = 'sendStory';
        this.stories = this.stories.map( story => {
            story.class ='sendStory'
            return story;
        });

    }
    @api
    noFiltering(){
        this.isFiltering = false;

    }

    fillSet(employees, listToFill, daysOfWeek){
        employees.forEach(employee => {
            daysOfWeek.forEach(day => {
                employee.stories[day].forEach(storyDay => {
                    listToFill.add(storyDay.label);
                });
            });
        });
    }

    fillStories(employees, daysOfWeek){
        let storiesInDashboard = [];
        employees.forEach(employee => {
            daysOfWeek.forEach(day => {
                employee.stories[day].forEach(storyDay => {
                    let divideStory = storyDay.label.split('-');
                    let formatedStory = divideStory.slice(1).join('-').trim();
                    storiesInDashboard.push({ costCenter: divideStory[0], storyName: formatedStory });
                });
            });
        });
        return storiesInDashboard;
    }

    differentArray(arr1, arr2) {
        if (arr1.length !== arr2.length) {
            return true;
        }

        arr1.sort((a, b) => a.value.localeCompare(b.value));
        arr2.sort((a, b) => a.value.localeCompare(b.value));

        for (let i = 0; i < arr1.length; i++) {
            if (arr1[i].value !== arr2[i].value) {
                return true;
            }
        }
        return false;
    }



    handleClick() {
        if (!this.dropdownBool) {
            this.openModal();
        } else {
            this.closeModal();
        }
    }

    handleChange(event) {
        let value = event.currentTarget.dataset.value;
        let eachStory = this.stories.find(item => item.value === value);

        if (value === "All") {
            this.iconClass(this.allClass === "sendStory" ? "notSendStory" : "sendStory");
        } else {
            this.allClass = "notSendStory";
            eachStory.class = (eachStory.class === "sendStory") ? "notSendStory" : "sendStory";
        }
    }

    send() {
        let storiesToSend = [];
        let storiesLocal = [];
        if (this.allClass === "sendStory") {
            this.stories = this.stories.map(function (story) {
                return { label: story.label, value: story.value, class: "sendStory" };
            });
        } else {
            this.stories.forEach(story => {
                if (story.class === "notSendStory") {
                    storiesToSend.push(story.value);
                }
            });
            this.splitStoryToSend(storiesToSend, storiesLocal);
            storiesToSend = storiesLocal;
        }
        
        //AA 6/4/2024 #1590 Synchronized filter
        if (this.filterController == 'employees') {
            this.sendFilter = 'employees';
            this.storiesFilterByEmployees = this.stories;
        }
        this.isFiltering = !storiesToSend.every(story => story.class == 'sendStory');
        this.handleDispatch(storiesToSend, this.filterController, this.filterController == 'stories');
        this.closeModal();
    }

    splitStoryToSend(inputList, outputList) {
        inputList.forEach(story => {
            let splitStories = story.split(";;");
            for (let i = 0; i < splitStories.length; i++) {
                if (i !== 0) {
                    outputList.push(splitStories[i] + " - " + splitStories[0]);
                }
            }
        });
    }

    iconClass(varString) {
        this.allClass = varString;
        this.stories = this.stories.map(function (story) {
            return { label: story.label, value: story.value, class: varString };
        });
    }

    openModal() {
        if (this.weekDataClean[0] !== undefined) {
            this.fillDropdown();
        }
        this.dropdownClass = "slds-size_1-of-1 slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open";
        this.dropdownBool = true;
    }
    @api
    closeModal() {
        this.dropdownClass = "slds-size_1-of-1 slds-dropdown-trigger slds-dropdown-trigger_click slds-is-closed";
        this.dropdownBool = false;
    }

    handleDispatch(value, filterController, cleanEmployees) {
        const valueChangeEvent = new CustomEvent("valuechange", {
            detail: { value, filterController, cleanEmployees }
        });
        this.dispatchEvent(valueChangeEvent);
    }
}