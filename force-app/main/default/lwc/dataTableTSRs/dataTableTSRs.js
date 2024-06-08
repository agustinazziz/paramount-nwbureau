import { LightningElement, track, api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBureaus from '@salesforce/apex/TimesheetRatesWizardCreateInvocable.getBureaus';



export default class DataTableTSRs extends LightningElement {

    @track columns = [
        { label: 'Start Date', fieldName: 'sd' },
        { label: 'End Date', fieldName: 'ed' },
        { label: 'Union', fieldName: 'union' },
        { label: 'Bureau', fieldName: 'buro' },
    ];

    @track defaultSelection = [];
    @api resultVariable = [];
    @track sortBy;
    @track list = [];
    @track auxBuro = [];
    @track sortDirection;
    @track preSelectedRows = [];
    @api availableActions = [];
    @api TSRsSelectedPlains = [];
    @api TSRsSelectedPlain = [];
    @api TSRsInput = [];
    @api TSRsOutput = [];
    @api NewTSRsValues;
    @track variable;
    @api IsUpdate;



     connectedCallback() {
        if (this.NewTSRsValues.Fringe__c) {
            this.columns.push({ label: 'Fringe', fieldName: 'fringe' },)
        }
        if (this.NewTSRsValues.Straight_Time__c) {
            this.columns.push({ label: 'Straight Time', fieldName: 'straightTime' },)
        }

        if (this.NewTSRsValues.Overnight__c) {
            this.columns.push({ label: 'Overnight', fieldName: 'overnight' },)
        }
        if (this.NewTSRsValues.Penalty_Rate__c) {
            this.columns.push({ label: 'Penalty Rate', fieldName: 'penaltyRate' },)
        }
        if (this.NewTSRsValues.Rest_Penalty__c) {
            this.columns.push({ label: 'Rest Penalty', fieldName: 'restPenalty' },)
        }
        if (this.NewTSRsValues.Night_Differential__c) {
            this.columns.push({ label: 'Night Differential', fieldName: 'nightDifferential' },)
        }
        if (this.NewTSRsValues.Over_Time_Rate__c) {
            this.columns.push({ label: 'Over Time Rate', fieldName: 'overTimeRate' },)
        }
        if (this.NewTSRsValues.Premium_Time__c) {
            this.columns.push({ label: 'Premium Time', fieldName: 'premiumTime' },)
        }
        if (this.NewTSRsValues.Meal_Penalties__c) {
            this.columns.push({ label: 'Meal Penalties', fieldName: 'mealPenalties' },)
        }
        if (this.NewTSRsValues.Holiday_Pay_50__c) {
            this.columns.push({ label: 'Holiday Pay 50%', fieldName: 'holidayPay50' },)
        }
        if (this.NewTSRsValues.Holiday_Pay_100__c) {
            this.columns.push({ label: 'Holiday Pay 100%', fieldName: 'holidayPay100' },)
        }
        if (this.NewTSRsValues.Holiday_Pay_200__c) {
            this.columns.push({ label: 'Holiday Pay 200%', fieldName: 'holidayPay200' },)
        }
        if (this.NewTSRsValues.Vacation_Allowance__c) {
            this.columns.push({ label: 'Vacation Allowance', fieldName: 'vacationAllowance' },)
        }
        if (this.NewTSRsValues.Foreign_Rates__c) {
            this.columns.push({ label: 'Foreign Rates', fieldName: 'foreignRates' },)
        }
        if (this.NewTSRsValues.Out_of_Town_Flat_Day_rate__c) {
            this.columns.push({ label: 'Out of Town Flat Day Rate', fieldName: 'outofTownFlatDayRate' },)
        }
        if (this.NewTSRsValues.Christams_New_Day_Rate__c) {
            this.columns.push({ label: 'Christmas/New Day Rate', fieldName: 'christmasNewDayRate' },)
        }
        if (this.NewTSRsValues.Weekday_Rate__c) {
            this.columns.push({ label: 'Weekday Rate', fieldName: 'weekdayRate' },)
        }
        if (this.NewTSRsValues.Weekend_Rate__c) {
            this.columns.push({ label: 'Weekend Rate', fieldName: 'weekendRate' },)
        }
        if (this.NewTSRsValues.Bank_Holiday_Rate__c) {
            this.columns.push({ label: 'Bank Holiday Rate', fieldName: 'bankHolidayRate' },)
        }
        if (this.NewTSRsValues.X6_7_Days__c) {
            this.columns.push({ label: '6/7 Days', fieldName: 'x67Days' },)
        }
        if (this.IsUpdate) {

            getBureaus({})
                .then((result) => {
                    this.variable = result;
                    let aux = this.TSRsInput;
                    let retRet = [];
                    let ids = [];
                    var i = 0;//Variable to preselect all fields
                    console.log(aux);
                    aux.forEach(element => {
                        i++;
                        let ret = {};
                        ret.uniqueId = i;
                        ret.id = element.Id;
                        ret.name = element.Name;
                        ret.sd = element.Start_Date__c;
                        ret.ed = element.End_Date__c;
                        ret.tal = element.Talent_Type__c;
                        ret.cur = element.Currency__c;
                        ret.empTitle = element.Employee_Title__c;
                        ret.empType = element.Employee_Type__c;
                        ret.union = element.Union__c;
                        ret.buroId = element.Bureau__c;
                        ret.straightTime = element.Straight_Time__c;   
                        ret.overnight = element.Overnight__c;
                        ret.penaltyRate = element.Penalty_Rate__c;
                        ret.restPenalty = element.Rest_Penalty__c;
                        ret.overTimeRate = element.Over_Time_Rate__c;
                        ret.nightDifferential = element.Night_Differential__c;
                        ret.premiumTime = element.Premium_Time__c;
                        ret.mealPenalties = element.Meal_Penalties__c;
                        ret.holidayPay50 = element.Holiday_Pay_50__c;
                        ret.holidayPay100 = element.Holiday_Pay_100__c;
                        ret.holidayPay200 = element.Holiday_Pay_200__c;
                        ret.vacationAllowance = element.Vacation_Allowance__c;
                        ret.outofTownFlatDayRate = element.Out_of_Town_Flat_Day_rate__c;
                        ret.christmasNewDayRate = element.Christams_New_Day_Rate__c;
                        ret.weekdayRate = element.Weekday_Rate__c;
                        ret.weekendRate = element.Weekend_Rate__c;
                        ret.bankHolidayRate = element.Bank_Holiday_Rate__c;
                        ret.x67Days = element.X6_7_Days__c;
                        ret.foreignRates = element.Foreign_Rates__c;
                        ret.fringe = element.Fringe__c;

                        result.forEach(bureau => {
                            if (element.Bureau__c == bureau.Id) {
                                ret.buro = bureau.Name;
                            }
                        })

                        console.log(ret.buro);
                        retRet.push(ret);
                        ids.push(ret.uniqueId);
                        this.resultVariable.push(element);
                        this.defaultSelection.push(element.Name);


                    });
               
                    this.list = retRet;
                    this.preSelectedRows = ids;
                    this.defaultSelection = retRet;
                    console.log('LR SelectedRows' + this.preSelectedRows);

                }).catch((error) => {
                    this.error = error;
                    console.log(error);
                })

        } else {
            getBureaus({})
                .then((result) => {
                    this.variable = result;
                    let aux = this.TSRsInput;
                    let retRet = [];
                    let ids = [];
                    var i = 0;//Variable to preselect all fields

                    aux.forEach(element => {
                        i++;
                        let ret = {};
                        ret.uniqueId = i;
                        ret.id = element.Id;
                        ret.name = element.Name;
                        ret.sd = element.Start_Date__c;
                        ret.ed = element.End_Date__c;
                        ret.tal = element.Talent_Type__c;
                        ret.cur = element.Currency__c;
                        ret.empTitle = element.Employee_Title__c;
                        ret.empType = element.Employee_Type__c;
                        ret.union = element.Union__c;
                        ret.buroId = element.Bureau__c;
                        ret.straightTime = this.NewTSRsValues.Straight_Time__c;
                        ret.overnight = this.NewTSRsValues.Overnight__c;
                        ret.penaltyRate = this.NewTSRsValues.Penalty_Rate__c;
                        ret.restPenalty = this.NewTSRsValues.Rest_Penalty__c;
                        ret.overTimeRate = this.NewTSRsValues.Over_Time_Rate__c;
                        ret.nightDifferential = this.NewTSRsValues.Night_Differential__c;
                        ret.premiumTime = this.NewTSRsValues.Premium_Time__c;
                        ret.mealPenalties = this.NewTSRsValues.Meal_Penalties__c;
                        ret.holidayPay50 = this.NewTSRsValues.Holiday_Pay_50__c;
                        ret.holidayPay100 = this.NewTSRsValues.Holiday_Pay_100__c;
                        ret.holidayPay200 = this.NewTSRsValues.Holiday_Pay_200__c;
                        ret.vacationAllowance = this.NewTSRsValues.Vacation_Allowance__c;
                        ret.outofTownFlatDayRate = this.NewTSRsValues.Out_of_Town_Flat_Day_rate__c;
                        ret.christmasNewDayRate = this.NewTSRsValues.Christams_New_Day_Rate__c;
                        ret.weekdayRate = this.NewTSRsValues.Weekday_Rate__c;
                        ret.weekendRate = this.NewTSRsValues.Weekend_Rate__c;
                        ret.bankHolidayRate = this.NewTSRsValues.Bank_Holiday_Rate__c;
                        ret.x67Days = this.NewTSRsValues.X6_7_Days__c;
                        ret.foreignRates = this.NewTSRsValues.Foreign_Rates__c;
                        ret.fringe = this.NewTSRsValues.Fringe__c;


                        result.forEach(bureau => {
                            if (element.Bureau__c == bureau.Id) {
                                ret.buro = bureau.Name;
                            }
                        })

                        console.log(ret.buro);
                        retRet.push(ret);
                        ids.push(ret.uniqueId);
                        this.resultVariable.push(element);
                        this.defaultSelection.push(element.Name);

                    });
                    this.list = retRet;
                    this.preSelectedRows = ids;
                    this.defaultSelection = retRet;
                    console.log('LR SelectedRows' + this.preSelectedRows);

                }).catch((error) => {
                    this.error = error;
                    console.log(error);
                })
        }

    }

    handleBack() {
        if (this.availableActions.find((action) => action === "BACK")) {
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
        }
    }

    //LR 5/31/2022: Handles the error notifications
    showNotification() {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: 'At least one Timesheet has to be selected!',
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }

    handleGoNext() {
        //GC 10/27/2021: Checks if NEXT is allowed on this screen
        // console.log('GC LINE 18:' + list.un);
        this.list.forEach(element => {
            //  console.log('GC LINE 18:' + element.uniqueId);
            if (this.defaultSelection.includes(element)) {
                console.log('GC LINE 21:' + element.id);
                this.TSRsOutput.push({
                    "Name": element.name,
                    "Id": element.id,
                    "Bureau__c": element.buroId,
                    "Currency__c": element.cur,
                    "Employee_Title__c": element.empTitle,
                    "Employee_Type__c": element.empType,
                    "End_Date__c": element.ed,
                    "Start_Date__c": element.sd,
                    "Talent_Type__c": element.tal,
                    "Union__c": element.union
                });
                this.TSRsSelectedPlain.push(element.id);
            }
        });

        console.log(this.TSRsSelectedPlain);
        if (!this.TSRsSelectedPlain.length) {
            this.TSRsSelectedPlains = null;
            this.showNotification();
        } else {
            //GC 10/27/2021: Stores the variables
            const attributeChangeEvent = new FlowAttributeChangeEvent(
                'TSRsOutput',
                this.TSRsOutput,
                'TSRsSelectedPlains',
                this.TSRsSelectedPlains
            );
            this.dispatchEvent(attributeChangeEvent);
            //GC 10/27/2021: Calls the NEXT event on the Screen Flow
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
            this.TSRsSelectedPlains = "";
            this.TSRsSelectedPlains = this.TSRsSelectedPlain.join(';');
        }


    }


    //LR 5/31/2022: Change method of the datatable group
    handleChange(event) {

        this.defaultSelection = event.detail.selectedRows
        console.log('GC: Default selection');
        console.log(event.detail.selectedRows);
    }

    //GC 10/27/2021: To populate the default selection of the checkbox group
    get selectedValues() {
        return this.defaultSelection.join(";");
    }


}