@isTest
public class TestDataFactory {

    public class UserBuilder {

        public User build(String profile){
            User u = new User();
            u.FirstName = 'Adam';
            u.LastName = 'Back';
            u.email = 'ausername@test.dev';
            u.Alias = 'alias';
            u.EmailEncodingKey = 'UTF-8';
            u.Username = 'ausername@test.dev';
            u.TimeZoneSidKey = 'America/Denver';
            u.LocaleSidKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            u.LanguageLocaleKey = 'en_US';
            u.IsActive = true;
            u.ProfileId = [SELECT Id FROM Profile WHERE Name =: profile].Id;
            insert u;
            return u;
        }
    }

    public class ScheduleBuilder {
        private Id bureau;
        private Date scheduleDate;
        private string Location;

        public ScheduleBuilder setBureau(String value) {
            this.bureau = value;
            return this;
        }

        public ScheduleBuilder setDate(Date value) {
            this.scheduleDate = value;
            return this;
        }
        public ScheduleBuilder setLocation(String value) {
            this.Location = value;
            return this;
        }

        public Schedule__c build() {
            Schedule__c schedule = new Schedule__c();
            schedule.Bureau__c = this.bureau;
            schedule.Date__c = this.scheduleDate;
            schedule.Location__c = this.Location;
            
            return schedule;
        }
    }

    public class BureauBuilder {
        private String bureauName;

        public BureauBuilder setName(String value) {
            this.bureauName = value;
            return this;
        }

        public Bureau__c build() {
            Bureau__c bureau = new Bureau__c();
            bureau.Name = this.bureauName;
            return bureau;
        }
    }

    public class ContactBuilder {
        private String firstName;
        private String lastName;
        private String bureau;
        private String employeeRole;
        private String employeeType;
        private Boolean disableCalculation = false;
        private String AssistantName;
        private string Assitantphone;
        private date Birthdate;
        private String Code;
        private String union;
        private String DL;
        private String Jigsaw;
        private String Department;
        private String Description;
        private String Email;
        private String EmployeeID;
        private boolean DoNotCall;
        private boolean HasOptedOutOfEmail;
        private String EmployeeTitle;
        private String wfcEmployeeTitle;
        private String Fax;
        private boolean HasOptedOutOfFax;
        private date FromDate;
        private String HomePhone;
        private String LeadSource;
        private ID Location;
        private String MailingAddress;
        private String MobilePhone;
        private String OtherAddress;
        private String OtherPhone;
        private String Phone;
        private id ReportsToId;
        private String TalentType;
        private String Title;
        private date Todate;
        private string Dept;
        private String CurrencySymbol;
        
        public ContactBuilder setDept(String value) {
            this.Dept = value;
            return this;
        }

        public ContactBuilder setFirstName(String value) {
            this.firstName = value;
            return this;
        }

        public ContactBuilder setLastName(String value) {
            this.lastName = value;
            return this;
        }

        public ContactBuilder setBureau(String value) {
            this.bureau = value;
            return this;
        }

        public ContactBuilder setEmployeeRole(String value) {
            this.employeeRole = value;
            return this;
        }

        public ContactBuilder setEmployeeType(String value) {
            this.employeeType = value;
            return this;
        }
        
        public ContactBuilder setDisableCalculation(Boolean value) {
            this.disableCalculation = value;
            return this;
        }

        public ContactBuilder setAssistantName(String value) {
            this.AssistantName = value;
            return this;
        }
        public ContactBuilder setAssitantphone(string value) {
            this.Assitantphone = value;
            return this;
        }
        public ContactBuilder setBirthdate(date value) {
            this.Birthdate = value;
            return this;
        }
        public ContactBuilder setCode(String value) {
            this.Code = value;
            return this;
        }
        public ContactBuilder setUnion(String value) {
            this.union = value;
            return this;
        }
        public ContactBuilder setDL(String value) {
            this.DL = value;
            return this;
        }
        public ContactBuilder setJigsaw(String value) {
            this.Jigsaw = value;
            return this;
        }
        public ContactBuilder setDepartment(String value) {
            this.Department = value;
            return this;
        }
        public ContactBuilder setDescription(String value) {
            this.Description = value;
            return this;
        }
        public ContactBuilder setEmail(String value) {
            this.Email = value;
            return this;
        }
        public ContactBuilder setEmployeeId(String value) {
            this.EmployeeId = value;
            return this;
        }

  		public ContactBuilder setDoNotCall(boolean value) {
            this.DoNotCall = value;
            return this;
        }
        
        public ContactBuilder setHasOptedOutOfEmail(boolean value) {
            this.HasOptedOutOfEmail = value;
            return this;
        }
        
        public ContactBuilder setwfcEmployeeTitle(String value) {
            this.wfcEmployeeTitle = value;
            return this;
        }
        public ContactBuilder setFax(String value) {
            this.Fax = value;
            return this;
        }
		
        public ContactBuilder setHasOptedOutOfFax(boolean value) {
            this.HasOptedOutOfFax = value;
            return this;
        }
        
        public ContactBuilder setFromDate(date value) {
            this.FromDate = value;
            return this;
        }
        
        public ContactBuilder setHomePhone(String value) {
            this.HomePhone = value;
            return this;
        }
        
        public ContactBuilder setLeadSource(String value) {
            this.LeadSource = value;
            return this;
        }
        
        public ContactBuilder setLocation(String value) {
            this.Location = value;
            return this;
        }
        
        public ContactBuilder setMailingAddress(String value) {
            this.MailingAddress = value;
            return this;
        }
        
        public ContactBuilder setMobilePhone(String value) {
            this.MobilePhone = value;
            return this;
        }
        
        public ContactBuilder setOtherAddress(String value) {
            this.OtherAddress = value;
            return this;
        }
        
        public ContactBuilder setOtherPhone(String value) {
            this.OtherPhone = value;
            return this;
        }
        
        public ContactBuilder setPhone(String value) {
            this.Phone = value;
            return this;
        }
        
        public ContactBuilder setReportsToId(String value) {
            this.ReportsToId = value;
            return this;
        }
        
        public ContactBuilder setTalentType(String value) {
            this.TalentType = value;
            return this;
        }
        
        public ContactBuilder setTitle(String value) {
            this.Title = value;
            return this;
        }

        public ContactBuilder setTodate(date value) {
            this.Todate = value;
            return this;
        }

        public ContactBuilder setCurrency(String value) {
            this.CurrencySymbol = value;
            return this;
        }

        public Contact build() {
            Contact contact = new Contact();
            contact.FirstName = this.firstName;
            contact.LastName = this.lastName;
            contact.Bureau__c = this.bureau;
            contact.Employee_Title__c = this.employeeRole;
            contact.Employee_Type__c = this.employeeType;
            contact.Disable_Calculation__c = this.disableCalculation;
            contact.Union__c = this.union;
            contact.AssistantName = this.AssistantName;
            contact.AssistantPhone = this.Assitantphone;
            contact.Birthdate = this.Birthdate;
            contact.Code__c = this.Code;
            contact.D_L__c = this.DL;
            contact.Jigsaw = this.Jigsaw;
            contact.Department = this.Department;
            contact.Dept__c =this.Dept;
            contact.Description = this.Description;
            contact.Email = this.Email;
            contact.Employee_ID__c = this.EmployeeId;
            contact.WFS_Employee_Title__c= this.wfcEmployeeTitle;
            contact.Fax= this.Fax;
            contact.From_Date__c= this.FromDate;
            contact.HomePhone = this.HomePhone;
            contact.LeadSource= this.LeadSource;
            contact.Location__c= this.Location;
            contact.MobilePhone= this.MobilePhone;
            contact.OtherPhone= this.OtherPhone;
            contact.Phone= this.Phone;
            contact.ReportsToId= this.ReportsToId;
            contact.Talent_Type__c= this.TalentType;
            contact.Title= this.Title;
            contact.To_date__c= this.Todate;
            contact.Currency__c = this.CurrencySymbol;
            return contact;
        }
    }

    public class StoryBuilder {
        private Boolean active;
        private String bureaus;
        //private String costCenters;
        private Id homeBureau;
        private String Name;
        private Id schedule;
        private String StoryCode;

        public StoryBuilder setActive(Boolean value) {
            this.active = value;
            return this;
        }

        public StoryBuilder setBureaus(String value) {
            this.bureaus = value;
            return this;
        }

        public StoryBuilder setHomeBureau(Id value) {
            this.homeBureau = value;
            return this;
        }
        public StoryBuilder setStoryCode(String value) {
            this.StoryCode = value;
            return this;
        }

        public StoryBuilder setName(String value) {
            this.Name = value;
            return this;
        }

        public StoryBuilder setSchedule(Id value) {
            this.schedule = value;
            return this;
        }

        public Story__c build() {
            Story__c story = new Story__c();
            story.Active__c = this.active;
            story.Bueraus_Active_in__c = this.bureaus;
            //story.CostCenter__c = this.costCenters;
            story.Home_Bureau__c = this.homeBureau;
            story.Name = this.Name;
            story.Story_Code__c	=this.StoryCode;
            story.Schedule__c = this.schedule;
            return story;
        }
    }

    public class CostCenterBuilder {
        private String name;

        public CostCenterBuilder setName(String value) {
            this.name = value;
            return this;
        }

        public CostCenter__c build() {
            CostCenter__c costCenter = new CostCenter__c();
            costCenter.Name = this.name;
            return costCenter;
        }
    }
    
    public class LocationBuilder {
        private String country;
        private String locationName;
        private String state;

        public LocationBuilder setCountry(String value) {
            this.country = value;
            return this;
        }

        public LocationBuilder setName(String value) {
            this.locationName = value;
            return this;
        }

        public Location__c build() {
            Location__c location = new Location__c();
            location.Country__c = this.country;
            location.Name = this.locationName;
            return location;
        }
    }
    
    public class StoryScheduleAssociationBuilder {
        private Id costCenter;
        private Boolean isCostCenteValid;
        private Id location;
        private Id schedule;
        private Id story;
        private string AssignmentInformation;
        private string UniqueIdentifier;

        public StoryScheduleAssociationBuilder setCostCenter(Id value) {
            this.costCenter = value;
            return this;
        }

        public StoryScheduleAssociationBuilder setLocation(Id value) {
            this.location = value;
            return this;
        }

        public StoryScheduleAssociationBuilder setSchedule(Id value) {
            this.schedule = value;
            return this;
        }
            public StoryScheduleAssociationBuilder setUniqueIdentifier(Id value) {
            this.UniqueIdentifier = value;
            return this;
        }
        public StoryScheduleAssociationBuilder setAssignmentInformation(string value) {
            this.AssignmentInformation = value;
            return this;
        }


        public StoryScheduleAssociationBuilder setIsCostCenterInvalid(Boolean value) {
            this.isCostCenteValid = value;
            return this;
        }

        public StoryScheduleAssociationBuilder setStory(Id value) {
            this.story = value;
            return this;
        }

        public Story_Schedule_Association__c build() {
            Story_Schedule_Association__c storySchedule =
                new Story_Schedule_Association__c();
            storySchedule.Cost_Center__c = this.costCenter;
            storySchedule.Its_the_cost_center_invalid__c = this.isCostCenteValid;
            storySchedule.Location__c =this.location;
            storySchedule.Schedule__c = this.schedule;
            storySchedule.Assignment_Information__c = this.AssignmentInformation;
            storySchedule.Story__c = this.story;
            return storySchedule;
        }
    }

    public class StoryEmployeeAssociationBuilder {
        private Id employee;
        private Id storyScheduleAssociation;
        private String assignmentInformation;
        private String liveShot, prosumerUsed, breakingNews;

        public StoryEmployeeAssociationBuilder setEmployee(Id value) {
            this.employee = value;
            return this;
        }

        public StoryEmployeeAssociationBuilder setAssignmentInformation(String value) {
            this.assignmentInformation = value;
            return this;
        }

        public StoryEmployeeAssociationBuilder setStoryScheduleAssociation(Id value) {
            this.storyScheduleAssociation = value;
            return this;
        }

        public StoryEmployeeAssociationBuilder setLiveShot(String value) {
            this.liveShot = value;
            return this;
        }

        public StoryEmployeeAssociationBuilder setProsumerUsed(String value) {
            this.prosumerUsed = value;
            return this;
        }

        public StoryEmployeeAssociationBuilder setBreakingNews(String value) {
            this.breakingNews = value;
            return this;
        }


        public ScheduleAssociation__c build() {
            //prepopulating all categories if not declared
            this.liveShot = String.isEmpty(this.liveShot) ? 'No' : this.liveShot;
            this.prosumerUsed = String.isEmpty(this.prosumerUsed) ? 'No' : this.prosumerUsed;
            this.breakingNews = String.isEmpty(this.breakingNews) ? 'No' : this.breakingNews;
            ScheduleAssociation__c storyEmployee = 
                new ScheduleAssociation__c();
            storyEmployee.Employee__c = this.employee;
            storyEmployee.Story_Schedule_Association__c = this.storyScheduleAssociation;
            storyEmployee.Assignment_Information__c = this.assignmentInformation;
            storyEmployee.Live_Shot__c = this.liveShot;
            storyEmployee.Prosumer_Used__c = this.prosumerUsed;
            storyEmployee.Breaking_News__c = this.breakingNews;
            return storyEmployee;
        }
    }

    public class ExpenseBuilder {

        private Double airfare;
        private Decimal airfareAdditionalCost;
        private Decimal amountOfTheExpense;
        private Id bureau;
        private Decimal carRental; 
        private String costCategory;
        private Id costCenter;
        private Decimal costCenterADJ;
        private String costTypeCodePicklist;
        private String costTypeCodeText;
        private String description;
        private Double doMeal;
        private Decimal doMealCost;
        private Date expenseDate;
        private Id employee;
        private Decimal equipmentRentalAdditional;
        private Decimal equipmentRentalDaily;
        private Decimal equipmentRentalLiveU;
        private Decimal equipmentRentalWeekly;
        private Decimal excessBaggage;
        private String expenseCategory;
        //private Boolean expenseValidation;
        private Double foMeal;
        private Decimal foMealCost;
        private Decimal foreignRate;
        private Decimal freelanceDailyRate;
        private Decimal freelanceWeeklyRate;
        private Decimal gasMilage;
        private Double hotel;
        private Decimal inTown;
        private Decimal inTownCost;
        private Decimal other;
        private String otherExpenses;
        private Id schedule;
        private Id story;
        private Id storyEmployeeAssociation;
        private Decimal taxis;
        private Decimal tips;
        private String travelLocation;
        private String type;
        private Decimal vanDriver;
        
        public ExpenseBuilder setAirfare(Double value) {
            this.airfare = value;
            return this;
        }
        
        public ExpenseBuilder setAirfareAdditionalCost(Decimal value) {
            this.airfareAdditionalCost = value;
            return this;
        }
        
        
        public ExpenseBuilder setAmountOfTheExpense(Decimal value) {
            this.amountOfTheExpense = value;
            return this;
        }
        
        public ExpenseBuilder setBureau(Id value) {
            this.bureau = value;
            return this;
        }
        public ExpenseBuilder setCarRental(Decimal value) {
            this.carRental = value;
            return this;
        }
        
        public ExpenseBuilder setCostCategory(String value) {
            this.costCategory = value;
            return this;
        }
        
        public ExpenseBuilder setCostCenter(String value) {
            this.costCenter = value;
            return this;
        }
        
        public ExpenseBuilder setCostCenterADJ(Decimal value) {
            this.costCenterADJ = value;
            return this;
        }
        public ExpenseBuilder setCostTypeCodePicklist(String value) {
            this.costTypeCodePicklist = value;
            return this;
        }
        public ExpenseBuilder setCostTypeCodeText(String value) {
            this.costTypeCodeText = value;
            return this;
        }
        
        public ExpenseBuilder setDate(Date value) {
            this.expenseDate = value;
            return this;
        }
        
        public ExpenseBuilder setDescription(String value) {
            this.description = value;
            return this;
        }
        
        public ExpenseBuilder setDoMeal(Double value) {
            this.doMeal = value;
            return this;
        }
        
        public ExpenseBuilder setDoMealCost(Decimal value) {
            this.doMealCost = value;
            return this;
        }
        
        public ExpenseBuilder setEmployee(Id value) {
            this.employee = value;
            return this;
        }
        
        public ExpenseBuilder setEquipmentRentalAdditional(Decimal value) {
            this.equipmentRentalAdditional = value;
            return this;
        }
        public ExpenseBuilder setEquipmentRentalDaily(Decimal value) {
            this.equipmentRentalDaily = value;
            return this;
        }
        
        public ExpenseBuilder setEquipmentRentalLiveU(Decimal value) {
            this.equipmentRentalLiveU = value;
            return this;
        }
        
        public ExpenseBuilder setEquipmentRentalWeekly(Decimal value) {
            this.equipmentRentalWeekly = value;
            return this;
        }
        
        public ExpenseBuilder setExcessBaggage(Decimal value) {
            this.excessBaggage = value;
            return this;
        }
        
        public ExpenseBuilder setExpenseCategory(String value) {
            this.expenseCategory = value;
            return this;
        }
        
        public ExpenseBuilder setFoMeal(Double value) {
            this.foMeal = value;
            return this;
        }
        
        public ExpenseBuilder setFoMealCost(Decimal value) {
            this.foMealCost = value;
            return this;
        }
        public ExpenseBuilder setForeignRate(Decimal value) {
            this.foreignRate = value;
            return this;
        }
        public ExpenseBuilder setFreelanceDailyRate(Decimal value) {
            this.freelanceDailyRate = value;
            return this;
        }
        public ExpenseBuilder setFreelanceWeeklyRate(Decimal value) {
            this.freelanceWeeklyRate = value;
            return this;
        }
        public ExpenseBuilder setGasMilage(Decimal value) {
            this.gasMilage = value;
            return this;
        }
        
        public ExpenseBuilder setHotel(Double value) {
            this.hotel = value;
            return this;
        }
        
        public ExpenseBuilder setInTown(Decimal value) {
            this.inTown = value;
            return this;
        }
        public ExpenseBuilder setInTownCost(Decimal value) {
            this.inTownCost = value;
            return this;
        }
        public ExpenseBuilder setOther(Decimal value) {
            this.other = value;
            return this;
        }
        public ExpenseBuilder setOtherExpenses(string value) {
            this.otherExpenses = value;
            return this;
        }
        
        public ExpenseBuilder setSchedule(Id value) {
            this.schedule = value;
            return this;
        }
        public ExpenseBuilder setStory(Id value) {
            this.story = value;
            return this;
        }
        
        public ExpenseBuilder setStoryEmployeeAssociation(Id value) {
            this.storyEmployeeAssociation = value;
            return this;
        }
        
        public ExpenseBuilder setTaxis(Decimal value) {
            this.taxis = value;
            return this;
        }
        
        public ExpenseBuilder setTravelLocation(String value) {
            this.travelLocation = value;
            return this;
        }
        
        public ExpenseBuilder setTips(Decimal value) {
            this.tips = value;
            return this;
        }
        
        public ExpenseBuilder setType(String value) {
            this.type = value;
            return this;
        }
        
        public ExpenseBuilder setVanDriver(Decimal value) {
            this.vanDriver = value;
            return this;
        }
        
        public Expenses__c build() {
            Expenses__c expense = new Expenses__c();
            expense.Airfare__c = this.airFare;
            expense.Airfare_Additional_Cost__c = this.airfareAdditionalCost;
            expense.Amount_of_the_expense__c = this.amountOfTheExpense;
            expense.Bureau__c = this.bureau;
            expense.Car_Rental__c = this.carRental;
            expense.Cost_Center__c = this.costCenter;
            expense.Cost_Center_ADJ2__c = this.costCenterADJ;
            expense.Cost_Category__c = this.costCategory;
            expense.Cost_Type_Code__c = this.costTypeCodePicklist;
            expense.CostType_Code__c = this.costTypeCodeText;
            expense.Date__c = this.expenseDate;
            expense.Description_of_the_expense__c = this.description;
            expense.DoMeal__c = this.doMeal;
            expense.DoMeal_Cost__c = this.doMealCost;
            expense.Employee__c = this.employee;
            expense.Equipment_Rental_Additional__c = this.equipmentRentalAdditional;
            expense.Equipment_Rental_Daily__c = this.equipmentRentalDaily;
            expense.Equipment_Rental_LiveU__c = this.equipmentRentalLiveU;
            expense.Equipment_Rental_Weekly__c = this.equipmentRentalWeekly;
            expense.Excess_Baggage__c = this.excessBaggage;
            expense.Expense_Category__c = this.expenseCategory;
            //expense.Expenses_Validation_Bollean__c = this.expenseValidation;
            expense.FoMeal__c = this.foMeal;
            expense.FoMeal_Cost__c = this.foMealCost;
            expense.Foreign_Rate__c = this.foreignRate;
            expense.Freelance_Daily_Rate__c = this.freelanceDailyRate;
            expense.Freelance_Weekly_Rate__c = this.freelanceWeeklyRate;
            expense.Gas_Milage__c = this.gasMilage;
            expense.Hotel__c = this.hotel;
            expense.In_Town__c = this.inTown;
            expense.In_Town_Cost__c = this.inTownCost;
            expense.Other__c = this.other;
            expense.Other_Expenses__c = this.otherExpenses;
            expense.Story__c = this.story;
            expense.Story_Employee_Association__c = this.storyEmployeeAssociation;
            expense.Taxis__c = this.taxis;
            expense.Tips__c = this.tips;
            expense.Travel_Location__c = this.travelLocation;
            expense.Type__c = this.type;
            expense.Van_Driver__c = this.vanDriver;
            
            return expense;
        }
    }
    
    public class TimesheetBuilder {
        
        private Id bureau;
        private Id costCenter;
        private Boolean automatedProcess;
        private Boolean bankHolidayTime;
        private Boolean christmasNewYearTime;
        private Date timesheetDate;
        private decimal dollars;
        private string earningCode;
        private Id employee;
        private Double episode;
        private Decimal fees;
        private Decimal foreignRates;
        private Decimal foreignRatesCost;
        private Decimal fringe;
        private Decimal grossPay;
        private Decimal holidayPay;
        private Decimal holidayPay100;
        private Decimal holidayPay100cost;
        private Decimal holidayPay200;
        private Decimal holidayPay200cost;
        private Decimal holidayPay50;
        private Decimal holidayPay50cost;
        private Double hours;
        private String internalNote;
        private Decimal mealPenalties;
        private Decimal mealPenaltiesCost;
        private String missedMeal;
        private String networkID;
        private Decimal nightDifferential;
        private Decimal nightDifferentialCost;
        private Decimal outOfTownFlatTime;
        private Decimal outOfTownFlatDayCost;
        private Decimal overTime;
        private Decimal overTimeCost;
        private Decimal overNight;
        private Decimal overNightCost;
        private Decimal penaltyTime;
        private Decimal payrateOVR;
        private Decimal penaltyTimeCost;
        private Decimal premiumTime;
        private Decimal premiumTimeCost;
        private Decimal restPenalty;
        private Decimal restPenaltyCost;
        private Date startDate;
        private Id story;
        private Id storyEmployeeAssociation;
        private Decimal straightTime;
        private Decimal straightTimeCost;
        private String show;
        private Id timesheetRate;
        private Decimal vacationAllowance;
        private Decimal vacationAllowanceCost;
        private Boolean weekendTime;
        private Boolean wfsSourced;
        private Double year;
        private Decimal x67Days;
        private Decimal x67DaysCost;
        
        public TimesheetBuilder set67Days(decimal value) {
            this.x67Days = value;
            return this;
        }

        public TimesheetBuilder set67DaysCost(decimal value) {
            this.x67DaysCost = value;
            return this;
        }
        
        public TimesheetBuilder setBureau(Id value) {
            this.bureau = value;
            return this;
        }
        
        public TimesheetBuilder setCostCenter(Id value) {
            this.costCenter = value;
            return this;
        }
        
        public TimesheetBuilder setDate(Date value) {
            this.timesheetDate = value;
            return this;
        }
        
        public TimesheetBuilder setAutomatedProcess(Boolean value) {
            this.automatedProcess = value;
            return this;
        }
        
        public TimesheetBuilder setDollars(decimal value) {
            this.dollars = value;
            return this;
        }
        
        public TimesheetBuilder setEmployee(Id value) {
            this.employee = value;
            return this;
        }
        
        public TimesheetBuilder setEpisode(Double value) {
            this.episode = value;
            return this;
        }
        
        public TimesheetBuilder setFees(Decimal value) {
            this.fees = value;
            return this;    
        }
        
        public TimesheetBuilder setForeignRates(Decimal value) {
            this.foreignRates = value;
            return this; 
        }
        
        public TimesheetBuilder setForeignRatesCost(Decimal value) {
            this.foreignRatesCost = value;
            return this;        
        }
        
        public TimesheetBuilder setFringe(Decimal value) {
            this.fringe = value;
            return this;      
        }
        
        public TimesheetBuilder setGrossPay(Decimal value) {
            this.grossPay = value;
            return this;      
        }    
        
        public TimesheetBuilder setHolidayPay(Decimal value) {
            this.holidayPay = value;
            return this;      
        }

        public TimesheetBuilder setHolidayPay100(Decimal value) {
            this.holidayPay100 = value;
            return this;      
        } 

        public TimesheetBuilder setHolidayPay100cost(Decimal value) {
            this.holidayPay100cost = value;
            return this;      
        }

        public TimesheetBuilder setHolidayPay200(Decimal value) {
            this.holidayPay200 = value;
            return this;      
        }   

        public TimesheetBuilder setHolidayPay200cost(Decimal value) {
            this.holidayPay200cost = value;
            return this;      
        }

        public TimesheetBuilder setHolidayPay50(Decimal value) {
            this.holidayPay50 = value;
            return this;      
        }   

        public TimesheetBuilder setHolidayPay50cost(Decimal value) {
            this.holidayPay50cost = value;
            return this;      
        }        
        
        public TimesheetBuilder setHours(Decimal value) {
            this.hours = value;
            return this;
        } 
        public TimesheetBuilder setEarningCode(String value) {
            this.earningCode = value;
            return this;
        }
        
        public TimesheetBuilder setInternalNote(String value) {
            this.internalNote = value;
            return this;
        }
        
        public TimesheetBuilder setMealPenalties(Decimal value) {
            this.mealPenalties = value;
            return this;
        }
        
        public TimesheetBuilder setMealPenaltiesCost(Decimal value) {
            this.mealPenaltiesCost = value;
            return this;
        }
        
        public TimesheetBuilder setMissedMeal(String value) {
            this.missedMeal = value;
            return this;
        }
        
        public TimesheetBuilder setNetworkID(String value) {
            this.networkID = value;
            return this;
        }
        
        public TimesheetBuilder setNightDifferential(Decimal value) {
            this.nightDifferential = value;
            return this;
        }
        
        public TimesheetBuilder setNightDifferentialCost(Decimal value) {
            this.nightDifferentialCost = value;
            return this;
        }
        
        public TimesheetBuilder setOutOfTownFlatTime(Decimal value) {
            this.OutOfTownFlatTime = value;
            return this;
        }

        public TimesheetBuilder setOutOfTownFlatDayCost(Decimal value) {
            this.OutOfTownFlatDayCost = value;
            return this;
        }

        public TimesheetBuilder setOvertime(Decimal value) {
            this.overTime = value;
            return this;
        }

        public TimesheetBuilder setOvertimeCost(Decimal value) {
            this.overTimeCost = value;
            return this;
        }

        public TimesheetBuilder setOverNight(Decimal value) {
            this.overNight = value;
            return this;
        }

        public TimesheetBuilder setOverNightCost(Decimal value) {
            this.overNightCost = value;
            return this;
        }
        
        public TimesheetBuilder setPayrateOVR (Decimal value) {
            this.payrateOVR = value;
            return this;
        }
        
        public TimesheetBuilder setPenaltyTime(Decimal value) {
            this.penaltyTime = value;
            return this;
        }
        
        public TimesheetBuilder setPenaltyTimeCost(Decimal value) {
            this.penaltyTimeCost = value;
            return this;
        }
        
        public TimesheetBuilder setPremiumTime(Decimal value) {
            this.premiumTime = value;
            return this;
        }
        
        public TimesheetBuilder setPremiumTimeCost(Decimal value) {
            this.premiumTimeCost = value;
            return this;
        }
        
        public TimesheetBuilder setRestPenalty(Decimal value) {
            this.restPenalty = value;
            return this;
        }
        
        public TimesheetBuilder setRestPenaltyCost(Decimal value) {
            this.restPenaltyCost = value;
            return this;
        }
        
        public TimesheetBuilder setShow(String value) {
            this.show = value;
            return this;
        }
        
        public TimesheetBuilder setStoryEmployeeAssociation(Id value) {
            this.storyEmployeeAssociation = value;
            return this;
        }
        
        public TimeSheetBuilder setStory(Id value) {
            this.story = value;
            return this;
        }
        
        public TimesheetBuilder setStartDate(Date value) {
            this.startDate = value;
            return this;
        }
        
        public TimesheetBuilder setStraightTime(Decimal value) {
            this.straightTime = value;
            return this;
        }

        public TimesheetBuilder setStraightTimeCost(Decimal value) {
            this.straightTimeCost = value;
            return this;
        }

        public TimesheetBuilder setTimesheetRate(Id value) {
            this.timesheetRate = value;
            return this;
        }

        public TimesheetBuilder setVacationAllowance(Decimal value) {
            this.vacationAllowance = value;
            return this;
        }

        public TimesheetBuilder setVacationAllowanceCost(Decimal value) {
            this.vacationAllowanceCost = value;
            return this;
        }
        
        public TimesheetBuilder setWFS_Sourced(Boolean value) {
            this.wfsSourced = value;
            return this;
        }

        public TimesheetBuilder setYear(Double value) {
            this.year = value;
            return this;
        }
        
        
        public Timesheet__c build(){
            Timesheet__c timesheet = new Timesheet__c();
            timesheet.Automated_Process__c = this.automatedProcess;
            timesheet.Bureau__c = this.bureau;
            timesheet.CostCenter__c = this.costCenter;
            timesheet.Date__c = this.timesheetDate;
            timesheet.Dollars__c = this.dollars;
            timesheet.Earnings_Code__c = this.earningCode;
            timesheet.Employee__c = this.employee;
            timesheet.Episode__c = this.episode;
            timesheet.Fees__c = this.fees;
            timesheet.Foreign_Rates__c = this.foreignRates;
            timesheet.Foreign_Rates_Cost__c = this.foreignRatesCost;
            timesheet.Fringe__c = this.fringe;
            timesheet.Gross_Pay__c = this.grossPay;
            timesheet.Holiday_Pay__c = this.holidayPay;
            timesheet.Holiday_Pay_100__c = this.holidayPay100;
            timesheet.Holiday_Pay_100_Cost__c = this.holidayPay100cost;
            timesheet.Holiday_Pay_200__c = this.holidayPay200;
            timesheet.Holiday_Pay_200_Cost__c = this.holidayPay200cost;
            timesheet.Holiday_Pay_50__c = this.holidayPay50;
            timesheet.Holiday_Pay_50_Cost__c = this.holidayPay50cost;
            timesheet.Hours__c = this.hours;
            timesheet.Internal_Notes__c = this.internalNote;
            timesheet.Meal_Penalties__c = this.mealPenalties;
            timesheet.Meal_Penalties_Cost__c = this.MealPenaltiesCost;
            timesheet.Missed_Meal__c = this.missedMeal;
            timesheet.Network_ID__c = this.networkID;
            timesheet.Night_Differential__c = this.nightDifferential;
            timesheet.Night_Differential_Cost__c = this.nightDifferentialCost;
            timesheet.Out_of_Town_Flat_Time__c = this.outOfTownFlatTime;
            timesheet.Out_of_Town_Flat_Day_Cost__c = this.outOfTownFlatDayCost;
            timesheet.Over_time__c = this.overTime;
            timesheet.Over_Time_Cost__c = this.overTimeCost;
            timesheet.Overnight__c = this.overNight;
            timesheet.Overnight_Cost__c = this.overNightCost;
            timesheet.PayRate_OVR__c = this.payrateOVR;
            timesheet.Penalty_Time__c = this.penaltyTime;
            timesheet.Penalty_Time_Cost__c = this.penaltyTimeCost;
            timesheet.Premium_Time__c = this.premiumTime;
            timesheet.Penalty_Time_Cost__c = this.premiumTimeCost;
            timesheet.Rest_Penalty__c = this.restPenalty;
            timesheet.Rest_Penalty_Cost__c = this.restPenaltyCost;
            timesheet.Show__c = this.show;
            timesheet.Start_Date__c = this.startDate;
            timesheet.Story__c = this.story;
            timesheet.Story_Employee_Association__c = this.storyEmployeeAssociation;
            timesheet.Straight_Time__c = this.straightTime;
            timesheet.Straight_Time_Cost__c = this.straightTimeCost;
            timesheet.Timesheet_Rate__c = this.timesheetRate;
            timesheet.Vacation_Allowance__c = this.vacationAllowance;
            timesheet.Vacation_Allowance_Cost__c = this.vacationAllowanceCost;
            timesheet.WFS_Sourced__c = this.wfsSourced;
            timesheet.Year__c = this.year;
            timesheet.X6_7_Days__c = this.x67Days;
            timesheet.X6_7_Days_Total__c = this.x67DaysCost;
            
            return timesheet;
        }
    }

    public class StoryCostBuilder {
        private Integer cost;
        private String description;
        private Id story;
        private Id StoryEmployeeAssociation;

        public StoryCostBuilder setStory(Id value) {
            this.story = value;
            return this;
        }

        public StoryCostBuilder setStoryEmployeeAssociation(Id value) {
            this.StoryEmployeeAssociation = value;
            return this;
        }

        public StoryCostBuilder setCost(Integer value) {
            this.cost = value;
            return this;
        }

        public StoryCostBuilder setDescription(String value) {
            this.description = value;
            return this;
        }

        public Story_Cost__c build() {
            Story_Cost__c storyCost = new Story_Cost__c();
            storyCost.Cost__c = this.cost;
            storyCost.Description__c = this.description;
            storyCost.Story__c = this.story;
            storyCost.Story_Employee_Association__c = this.StoryEmployeeAssociation;
            return storyCost;
        }
    }

    public class ExpenseRatesBuilder{
        
        private String basis;
        private Id bureau;
        private String costCategory;
        private String costTypeDescription;
        private String costTypeCode;
        private String costTypeName;
        private String talent;
        private String travel;
        private String staff;
        private String freelance;
        private String isUnion;
        private String isntUnion;
        private String inTown;
        private String domestic;
        private Date endDate;
        private Date startDate;
        private String expenseCategory;
        private String foreign; 
        private Double rate;
        private String rateBSD;
        private string unanime;
        
        public ExpenseRatesBuilder setBasis(String value) {
            this.Basis = value;
            return this;
        }
        
        public ExpenseRatesBuilder setBureau(Id value) {
            this.bureau = value;
            return this;
        }
        
        public ExpenseRatesBuilder setCostCategory(String value) {
            this.costCategory = value;
            return this;
        }
        
        public ExpenseRatesBuilder setCostTypeDescription(String value) {
            this.costTypeDescription = value;
            return this;
        }

        public ExpenseRatesBuilder setCostTypeCode(String value) {
            this.costTypeCode = value;
            return this;
        }
        
        public ExpenseRatesBuilder setCostTypeName(String value) {
            this.costTypeName = value;
            return this;
        }
        
        public ExpenseRatesBuilder setTalent(String value) {
            this.talent = value;
            return this;
        }

        public ExpenseRatesBuilder setTravel(String value) {
            this.travel = value;
            return this;
        }
        
        public ExpenseRatesBuilder setStaff(String value) {
            this.staff = value;
            return this;
        }
        
        public ExpenseRatesBuilder setFreelance(String value) {
            this.freelance = value;
            return this;
        }
        
        public ExpenseRatesBuilder setIsUnion(String value) {
            this.isUnion = value;
            return this;
        }
        
        public ExpenseRatesBuilder setIsntUnion(String value) {
            this.isntUnion = value;
            return this;
        }
        
        public ExpenseRatesBuilder setInTown(String value) {
            this.inTown = value;
            return this;
        }
        
        public ExpenseRatesBuilder setDomestic(String value) {
            this.domestic = value;
            return this;
        }
        
        public ExpenseRatesBuilder setStartDate(Date value) {
            this.startDate = value;
            return this;
        }
        
        public ExpenseRatesBuilder setEndDate(Date value) {
            this.endDate = value;
            return this;
        }
        
        public ExpenseRatesBuilder setExpenseCategory (String value) {
            this.expenseCategory = value;
            return this;
        }
        
        public ExpenseRatesBuilder setForeign(String value) {
            this.foreign = value;
            return this;
        }
        
        public ExpenseRatesBuilder setRate(Double value) {
            this.rate = value;
            return this;
        }

        public ExpenseRatesBuilder setRateBSD(String value) {
            this.rateBSD = value;
            return this;
        }

        public ExpenseRatesBuilder setUnanime(String value) {
            this.unanime = value;
            return this;
        }

        public Expense_Rates__c build(){
            Expense_Rates__c expenseRates = new Expense_Rates__c();
            expenseRates.BASIS__c = this.basis;
            expenseRates.Bureau__c = this.bureau;
            expenseRates.Cost_Category__c = this.costCategory;
            expenseRates.Cost_Type_Description__c =this.costTypeDescription;
            expenseRates.CostTypeCode__c = this.costTypeCode;
            expenseRates.CostTypeName__c = this.costTypeName;
            expenseRates.TALENT__c = this.talent;
            expenseRates.TRAVEL__c = this.travel;
            expenseRates.STAFF__c = this.staff;
            expenseRates.FREELANCE__c = this.freelance;
            expenseRates.ISUNION__c = this.isUnion;
            expenseRates.ISNTUNION__c = this.isntUnion;
            expenseRates.INTOWN__c = this.inTown;
            expenseRates.DOMESTIC__c = this.domestic;
            expenseRates.End_Date__c = this.endDate;
            expenseRates.Expense_Category__c = this.expenseCategory;
            expenseRates.FOREIGN__c = this.foreign;
            expenseRates.Rate__c = this.rate;
            expenseRates.RateBSD__c = this.rateBSD;
            expenseRates.UNINAME__c = this.unanime;
            return expenseRates;
        }
    }
    
    public class HolidayCustomBuilder {
            private id Bureau;
            private date HolidayDate;
            private boolean is_Duplicated;
            private string Name;

            public HolidayCustomBuilder setBureau(Id value) {
                this.Bureau = value;
                return this;
            }

            public HolidayCustomBuilder setDate(Date value) {
                this.HolidayDate = value;
                return this;
            }

            public HolidayCustomBuilder setIsDuplicated(Boolean value) {
                this.is_Duplicated = value;
                return this;
            }

            public HolidayCustomBuilder setName (String value) {
                this.Name = value;
                return this;
            }


        public HolidayCustom__c build() {
            HolidayCustom__c HolidayCustom = new HolidayCustom__c();
            HolidayCustom.Bureau__c = this.Bureau;
            HolidayCustom.Date__c = this.HolidayDate;
            HolidayCustom.is_Duplicated__c = this.is_Duplicated;
            HolidayCustom.Name   = this.Name;

            return HolidayCustom;

            }
        }
    
    public class TimesheetRateBuilder {
        
        private String Name;
        private Decimal Bank_Holiday_Rate;
        private Id Bureau;
        private Decimal Christams_New_Day_Rate;
        private String Employee_Title;
        private String Employee_Type;
        private date End_Date;
        private Decimal Foreign_Rates;
        private Decimal Fringe;
        private Decimal Holiday_Pay_100;
        private Decimal Holiday_Pay_200;
        private Decimal Holiday_Pay_50;
        private Decimal Meal_Penalties;
        private Decimal Night_Differential;
        private Decimal Out_of_Town_Flat_Day_rate;
        private Decimal Over_Time_Rate;
        private Decimal Overnight;
        private Decimal Penalty_Rate;
        private Decimal Rest_Penalty;
        private Date Start_Date;
        private Decimal Straight_Time;
        private String Talent_Type;
        private String Union;
        private Decimal Vacation_Allowance;
        private Decimal Weekday_Rate;
        private Decimal Weekend_Rate;
        private Decimal X6_7_Days_Rate;
        private String currencySymbol;
        
        public TimesheetRateBuilder setBankHolidayRate(Decimal value) {
            this.Bank_Holiday_Rate = value;
            return this;
        }
        
        public TimesheetRateBuilder setBureau(Id value) {
            this.Bureau = value;
            return this;
        }
        
        public TimesheetRateBuilder setChristmasNewYearRate(Decimal value) {
            this.Christams_New_Day_Rate = value;
            return this;
        }
        
        public TimesheetRateBuilder setEmployeeRole(String value) {
            this.Employee_Title = value;
            return this;
        }
        
        public TimesheetRateBuilder setEmployeeType(String value) {
            this.Employee_Type = value;
            return this;
        }
        
        public TimesheetRateBuilder setEndDate(Date value) {
            this.End_Date = value;
            return this;
        }
        
        public TimesheetRateBuilder setForeignRate(Decimal value) {
            this.Foreign_Rates = value;
            return this;
        }
        
        public TimesheetRateBuilder SetFringe(Decimal value) {
            this.Fringe = value;
            return this;
        }
        
        public TimesheetRateBuilder setHolidayPay100(Decimal value) {
            this.Holiday_Pay_100 = value;
            return this;
        }
        
        public TimesheetRateBuilder setHolidayPay200(Decimal value) {
            this.Holiday_Pay_200 = value;
            return this;
        }
        
        public TimesheetRateBuilder setHolidayPay50(Decimal value) {
            this.Holiday_Pay_50 = value;
            return this;
        }
        
        public TimesheetRateBuilder setMealPenalties(Decimal value) {
            this.Meal_Penalties = value;
            return this;
        }
        
        public TimesheetRateBuilder setNightDifferential(Decimal value) {
            this.Night_Differential = value;
            return this;
        }
        
        public TimesheetRateBuilder setOutOfTownFlatRate(Decimal value) {
            this.Out_of_Town_Flat_Day_rate = value;
            return this;
        }
        
        public TimesheetRateBuilder setOvertimeRate(Decimal value) {
            this.Over_Time_Rate = value;
            return this;
        }
        
        public TimesheetRateBuilder setOvernight(Decimal value) {
            this.Overnight = value;
            return this;
        }
        
        public TimesheetRateBuilder setPenaltyRate(Decimal value) {
            this.Penalty_Rate = value;
            return this;
        }
        
        public TimesheetRateBuilder setRestPenalty(Decimal value) {
            this.Rest_Penalty = value;
            return this;
        }
        public TimesheetRateBuilder setStartDate(Date value) {
            this.Start_Date = value;
            return this;
        }
        
        
        public TimesheetRateBuilder setStraightTime(Decimal value) {
            this.Straight_Time = value;
            return this;
        }
        
        public TimesheetRateBuilder setTalentType(String value) {
            this.Talent_Type = value;
            return this;
        }
        
        public TimesheetRateBuilder setUnion(String value) {
            this.Union = value;
            return this;
        }
        
        
        public TimesheetRateBuilder setVacationAllowance(Decimal value) {
            this.Vacation_Allowance = value;
            return this;
        }
        
        public TimesheetRateBuilder setWeekDayRate(Decimal value) {
            this.Weekday_Rate = value;
            return this;
        }
        
        public TimesheetRateBuilder setWeekendRate(Decimal value) {
            this.Weekend_Rate = value;
            return this;
        }

        public TimesheetRateBuilder setX6_7Days(Decimal value) {
            this.X6_7_Days_Rate = value;
            return this;
        }

        public TimesheetRateBuilder setCurrency(String value) {
            this.currencySymbol = value;
            return this;
        }
        
        public TimesheetRate__c build() {
            TimesheetRate__c TimesheetRate = new TimesheetRate__c();
            TimesheetRate.Bank_Holiday_Rate__c = this.Bank_Holiday_Rate;
            TimesheetRate.Bureau__c = this.Bureau;
            TimesheetRate.Christams_New_Day_Rate__c = this.Christams_New_Day_Rate;
            TimesheetRate.Employee_Title__c = this.Employee_Title;
            TimesheetRate.Employee_Type__c = this.Employee_Type;
            TimesheetRate.End_Date__c = this.End_Date;
            TimesheetRate.Foreign_Rates__c = this.Foreign_Rates;
            TimesheetRate.Fringe__c = this.Fringe;
            TimesheetRate.Holiday_Pay_100__c = this.Holiday_Pay_100;
            TimesheetRate.Holiday_Pay_200__c = this.Holiday_Pay_200;
            TimesheetRate.Holiday_Pay_50__c = this.Holiday_Pay_50;
            TimesheetRate.Meal_Penalties__c = this.Meal_Penalties;
            TimesheetRate.Night_Differential__c = this.Night_Differential;
            TimesheetRate.Out_of_Town_Flat_Day_rate__c = this.Out_of_Town_Flat_Day_rate;
            TimesheetRate.Over_Time_Rate__c = this.Over_Time_Rate;
            TimesheetRate.Overnight__c = this.Overnight;
            TimesheetRate.Penalty_Rate__c = this.Penalty_Rate;
            TimesheetRate.Rest_Penalty__c = this.Rest_Penalty;
            TimesheetRate.Start_Date__c = this.Start_Date;
            TimesheetRate.Straight_Time__c = this.Straight_Time;
            TimesheetRate.Talent_Type__c = this.Talent_Type;
            TimesheetRate.Union__c = this.Union;
            TimesheetRate.Vacation_Allowance__c = this.Vacation_Allowance;
            TimesheetRate.Weekday_Rate__c = this.Weekday_Rate;
            TimesheetRate.Weekend_Rate__c = this.Weekend_Rate;
            TimesheetRate.X6_7_Days__c = this.X6_7_Days_Rate;
            TimesheetRate.Currency__c = this.currencySymbol;
            
            return TimesheetRate;
        }
    }

    public class StagingTableBuilder {
        private String Status;
        private String DL;
        private String Dept;
        private String EmployeeType;
        private String EarningsCode;
        private String Union;
        private String NetworkID;
        private String EmployeeTitle;
        private String MissedMeal;

        public StagingTableBuilder setStatus(String value) 
        {
            this.Status = value;
            return this;
        }
        public StagingTableBuilder setDL(String value) 
        {
            this.DL = value;
            return this;
        }
        public StagingTableBuilder setDept(String value) 
        {
            this.Dept = value;
            return this;
        }
        public StagingTableBuilder setEmployeeType(String value) 
        {
            this.EmployeeType = value;
            return this;
        }
        public StagingTableBuilder setEarningsCode(String value) 
        {
            this.EarningsCode = value;
            return this;
        }
        public StagingTableBuilder setUnion(String value) 
        {
            this.Union = value;
            return this;
        }
        public StagingTableBuilder setNetworkID(String value) 
        {
            this.NetworkID = value;
            return this;
        }
        public StagingTableBuilder setEmployeeTitle(String value) 
        {
            this.EmployeeTitle = value;
            return this;
        }
        public StagingTableBuilder setMissedMeal(String value) 
        {
            this.MissedMeal = value;
            return this;
        }
        public Staging_table__c build() 
        {
            Staging_table__c StagingTable = new Staging_table__c();
            StagingTable.Status__c = this.Status;
            StagingTable.D_L__c = this.DL;
            StagingTable.Dept__c = this.Dept;
            StagingTable.Employee_Type__c = this.EmployeeType;
            StagingTable.Earnings_Code__c = this.EarningsCode;
            StagingTable.Union__c = this.Union;
            StagingTable.Network_ID__c = this.NetworkID;
            StagingTable.Employee_Title__c = this.EmployeeTitle;
            StagingTable.Missed_Meal__c = this.MissedMeal;
            
            return StagingTable;
        }
    }
}