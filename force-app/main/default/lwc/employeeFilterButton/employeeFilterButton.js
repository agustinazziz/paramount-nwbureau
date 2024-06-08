import { LightningElement, api, track } from 'lwc';

export default class EmployeeFilterButton extends LightningElement {
    _weekDataClean;
    @api
    get weekDataClean() {
        return this._weekDataClean;
    }
    set weekDataClean(value) {
        if (JSON.stringify(this._weekDataClean) != JSON.stringify(value)) {
            this._weekDataClean = value;
            this.auxList = [];
        }
    }
    //AA 6/4/2024 #1590 Synchronized filter
    @api weekDataFilter;
    @api filterController;
    @track sendFilter;
    @track employeeFilterByStories = [];
    isFiltering = false;
    
    @track employees = [{ label: "Select a employee", value: [""], class: "sendEmployee" }];
    dropdownClass = "slds-size_1-of-1 slds-dropdown-trigger slds-dropdown-trigger_click slds-is-closed";
    dropdownBool = false;
    auxList = [];

    get otherEmployees() { return this.employees.slice(1); } // Exclude the first element ("All" option)

    get allClass() { return this.employees.length > 0 ? this.employees[0].class : ''; }

    fillDropdown() {
        const employeeList = JSON.parse(this.weekDataClean).map(employee => {
            const nameParts = employee.employeeName.split(' ');
            const lastName = nameParts.pop();
            const firstName = nameParts.shift();
            const middleName = nameParts.join(' ');
            const label = middleName ? `${lastName}, ${firstName} ${middleName}` : `${lastName}, ${firstName}`;

            return {
                label,
                value: employee.employeeName,
                class: "sendEmployee"
            };
        });

        // Sort the employee list by last name (alpha ascending)
        employeeList.sort((a, b) => {
            const lastNameA = a.label.split(', ')[0];
            const lastNameB = b.label.split(', ')[0];
            if (lastNameA < lastNameB) return -1;
            if (lastNameA > lastNameB) return 1;
            return 0;
        });

        
        //AA 6/4/2024 #1590 Synchronized filter
        if (this.sendFilter == 'stories' && this.filterController == 'stories' && this.employeeFilterByStories.length != 0){                 
            this.employees = this.employeeFilterByStories;
            this.auxList = [];
                

        }else if (this.weekDataFilter.length < employeeList.length && this.filterController == 'stories') {
            let employeeFilterList = [];
            this.employeeFilterByStories = [];

            this.weekDataFilter.forEach(employee => employeeFilterList.push(employee.employeeName));
            
            this.employees = [{ label: "All", value: "All", class: "sendEmployee" },
            ...employeeList
            .filter(employee => employeeFilterList.includes(employee.value))
            .map(employee => ({
                ...employee,
                class: employeeFilterList.includes(employee.value) ? 'sendEmployee' : 'notSendEmployee'
            }))];
            
            employeeFilterList = [];
            
        } else if (this.auxList.length > 0) {
            this.employeeFilterByStories = [];
            this.employees = this.auxList;
        } else {
            this.employeeFilterByStories = [];
            this.employees = [{ label: "All", value: "All", class: "sendEmployee" }, ...employeeList];
        }
    }
    
    //AA 6/4/2024 #1590 Synchronized filter
    @api 
    cleanList(){
        this.employeeFilterByStories = [];

    }
    @api 
    noFiltering(){
        this.isFiltering = false;

    }

    handleClick() {
        this.dropdownBool ? this.closeModal() : this.openModal();
    }

    handleChange(event) {
        const value = event.currentTarget.dataset.value;
        const firstClass = this.employees[0].class === "sendEmployee" ? "notSendEmployee" : "sendEmployee";
        const eachEmployee = this.employees.find(item => item.value === value);

        if (value === "All") {
            this.employees.forEach(employee => { employee.class = firstClass; });
        } else {
            eachEmployee.class = eachEmployee.class === "sendEmployee" ? "notSendEmployee" : "sendEmployee";
            this.employees[0].class = this.employees.slice(1).every(employee => employee.class === "sendEmployee") ? "sendEmployee" : "notSendEmployee";
        }
        this.auxList = this.employees;
    }

    send() {
        
        //AA 6/4/2024 #1590 Synchronized filter
        if (this.filterController == 'stories') {
            this.sendFilter = 'stories';
            this.employeeFilterByStories = this.employees;
            this.auxList = [];
            
        }
        const employeesToSend = this.employees.filter(employee => employee.class === "notSendEmployee").map(employee => employee.value);  

        this.isFiltering = !employeesToSend.every(employee => employee.class == 'sendEmployee');
        this.handleDispatch(employeesToSend, this.filterController, this.filterController == 'employees');
        this.closeModal();
        
    }

    splitStoryToSend(inputList, outputList) {
        inputList.forEach(story => {
            const [firstPart, ...otherParts] = story.split(";;");
            otherParts.forEach(part => outputList.push(part + " - " + firstPart));
        });
    }

    openModal() {
        if (this.weekDataClean && this.weekDataClean[0] !== undefined) {
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

    handleDispatch(value, filterController, cleanStories) {
        const valueChangeEvent = new CustomEvent("valuechange", { detail: { value, filterController, cleanStories } });
        this.dispatchEvent(valueChangeEvent);
    }
}