@IsTest
public class TimesheetDomainTest {
    
    @TestSetup
    static void makeData(){

        User targetUser = new TestDataFactory.UserBuilder().build('Bureau Weekly Users');
        ScheduleAssociationTriggerBypass__c executeScheduleAssociationTrigger =
            new ScheduleAssociationTriggerBypass__c();
        executeScheduleAssociationTrigger.execute__c = true;
        executeScheduleAssociationTrigger.SetupOwnerId = targetUser.ProfileId;
        executeScheduleAssociationTrigger.Name = 'ScheduleAssociationTriggerBypass (Profile)';
        insert executeScheduleAssociationTrigger;
        
        Bureau__c londonBureau = new TestDataFactory.BureauBuilder().
            setName('LONDON/EUROPEAN OPERATIONS').
            build();
        insert londonBureau;

        Bureau__c asiaBureau = new TestDataFactory.BureauBuilder().
            setName('ASIA OPERATIONS').
            build();
        insert asiaBureau;

        Bureau__c northBureau = new TestDataFactory.BureauBuilder().
            setName('NORTH').
            build();
        insert northBureau;
        

        CostCenter__c CostCenter48H = new TestDataFactory.CostCenterBuilder().
            setName('48H').
            build();
        insert costCenter48H;

        CostCenter__c CostCenterCBSN = new TestDataFactory.CostCenterBuilder().
            setName('CBSN').
            build();
        insert CostCenterCBSN;

        Schedule__c londonSchedule = new TestDataFactory.ScheduleBuilder().
            setBureau(londonBureau.Id).
            setDate(Date.newInstance(2021, 1, 3)).
            build();
        insert londonSchedule;

        Schedule__c northSchedule = new TestDataFactory.ScheduleBuilder().
            setBureau(northBureau.Id).
            setDate(Date.newInstance(2021, 1, 3)).
            build();
        insert northSchedule;

        Schedule__c asiaSchedule = new TestDataFactory.ScheduleBuilder().
            setBureau(asiaBureau.Id).
            setDate(Date.newInstance(2021, 1, 3)).
            build();
        insert asiaSchedule;

        Location__c japanLocation = new TestDataFactory.LocationBuilder().
            setName('Studio one').
            setCountry('Japan').
            build();
        insert japanLocation;

        Location__c specificJapanLocation = new TestDataFactory.LocationBuilder().
        setName('Studio two').
        setCountry('Japan').
        build();
        specificJapanLocation.Is_Specific_Location__c = 'LONDON';
        insert specificJapanLocation;

        
        Contact nuLondonStaffGBPEmployee = new TestDataFactory.ContactBuilder().
            setFirstName('Satoshi').
            setLastName('Nakamoto').
            setEmployeeRole('RESEARCHER').
            setEmployeeType('Staff').
            setUnion('NU').
            setBureau(londonBureau.Id).
            setDisableCalculation(false).
            setCurrency('GBP').
            build();
        insert nuLondonStaffGBPEmployee;

        Contact nuLondonStaffEuroEmployee = new TestDataFactory.ContactBuilder().
            setFirstName('Sergey').
            setLastName('Nazarov').
            setEmployeeRole('RESEARCHER').
            setEmployeeType('Staff').
            setUnion('NU').
            setBureau(londonBureau.Id).
            setDisableCalculation(false).
            setCurrency('EUR').
            build();
        insert nuLondonStaffEuroEmployee;

        Contact unionNorthStaffUSDEmployee = new TestDataFactory.ContactBuilder().
            setFirstName('Hal').
            setLastName('Finney').
            setEmployeeRole('RESEARCHER').
            setEmployeeType('Staff').
            setUnion('510').
            setBureau(northBureau.Id).
            setCurrency('EUR').
            setDisableCalculation(false).
            build();
        insert unionNorthStaffUSDEmployee;
        
        Contact unionNorthFreelancerUSDEmployee = new TestDataFactory.ContactBuilder().
            setFirstName('Freelancer').
            setLastName('Cameraman').
            setEmployeeRole('FL CAMERA').
            setEmployeeType('Freelancer').
            setUnion('510').
            setBureau(northBureau.Id).
            setDisableCalculation(false).
            setCurrency('USD').
            build();
        insert unionNorthFreelancerUSDEmployee;

        Story__c london48HStory = new TestDataFactory.StoryBuilder().
            setActive(true).
            setBureaus(londonBureau.Name).
            //setCostCenters(costCenter48H.Name).
            setHomeBureau(londonBureau.Id).
            setName('The Times 03/Jan/2009 Chancellor on brink of second bailout for banks').
            setSchedule(londonSchedule.Id).
            build();
        insert london48HStory;

        TimesheetRate__c nuLondonStaffResearcherGBPTimesheetRate = new TestDataFactory.TimesheetRateBuilder().
            setBankHolidayrate(10.1).
            setBureau(londonBureau.Id).
            setChristmasNewYearRate(20.2).
            setEmployeeRole('RESEARCHER').
            setEmployeeType('Staff').
            setForeignRate(10.2).
            setHolidayPay100(100).
            setHolidayPay200(200).
            setHolidayPay50(50).
            setMealPenalties(10.3).
            setNightDifferential(20.2).
            setOutOfTownFlatRate(15.1).
            setOvertimeRate(15.1).
            setPenaltyRate(30).
            setRestPenalty(35).
            setStraightTime(25).
            setUnion('NU').
            setVacationAllowance(30.3).
            setWeekDayRate(20).
            setWeekendRate(40).
            setX6_7Days(67).
            setCurrency('GBP').
            setStartDate(Date.newInstance(2021,1,1)).
            setEndDate(Date.newInstance(2021,12,31)).
            build();
        insert nuLondonStaffResearcherGBPTimesheetRate;

        TimesheetRate__c unionLondonStaffResearcherGBPTimesheetRate = new TestDataFactory.TimesheetRateBuilder().
            setBankHolidayrate(10.1).
            setBureau(londonBureau.Id).
            setChristmasNewYearRate(20.2).
            setEmployeeRole('RESEARCHER').
            setEmployeeType('Staff').
            setForeignRate(10.2).
            setHolidayPay100(100).
            setHolidayPay200(200).
            setHolidayPay50(50).
            setMealPenalties(10.3).
            setNightDifferential(20.2).
            setOutOfTownFlatRate(15.1).
            setOvertimeRate(15.1).
            setPenaltyRate(30).
            setRestPenalty(35).
            setStraightTime(25).
            setUnion('510').
            setVacationAllowance(30.3).
            setWeekDayRate(20).
            setWeekendRate(40).
            setX6_7Days(67).
            setCurrency('GBP').
            setStartDate(Date.newInstance(2021,1,1)).
            setEndDate(Date.newInstance(2021,12,31)).
            build();
        insert unionLondonStaffResearcherGBPTimesheetRate;

        TimesheetRate__c unionNorthStaffResearcherEURTimesheetRate = new TestDataFactory.TimesheetRateBuilder().
            setBankHolidayrate(10.1).
            setBureau(northBureau.Id).
            setChristmasNewYearRate(20.2).
            setEmployeeRole('RESEARCHER').
            setEmployeeType('Staff').
            setForeignRate(10.2).
            setHolidayPay100(100).
            setHolidayPay200(200).
            setHolidayPay50(50).
            setMealPenalties(10.3).
            setNightDifferential(20.2).
            setOutOfTownFlatRate(15.1).
            setOvertimeRate(15.1).
            setPenaltyRate(30).
            setRestPenalty(35).
            setStraightTime(25).
            setUnion('510').
            setVacationAllowance(30.3).
            setWeekDayRate(20).
            setWeekendRate(40).
            setCurrency('EUR').
            setStartDate(Date.newInstance(2021,1,1)).
            setEndDate(Date.newInstance(2021,12,31)).
            build();
        insert unionNorthStaffResearcherEURTimesheetRate;

        TimesheetRate__c nuNorthStaffResearcherEURTimesheetRate = new TestDataFactory.TimesheetRateBuilder().
            setBankHolidayrate(10.1).
            setBureau(northBureau.Id).
            setChristmasNewYearRate(20.2).
            setEmployeeRole('RESEARCHER').
            setEmployeeType('Staff').
            setForeignRate(10.2).
            setHolidayPay100(100).
            setHolidayPay200(200).
            setHolidayPay50(50).
            setMealPenalties(10.3).
            setNightDifferential(20.2).
            setOutOfTownFlatRate(15.1).
            setOvertimeRate(15.1).
            setPenaltyRate(30).
            setRestPenalty(35).
            setStraightTime(25).
            setUnion('NU').
            setVacationAllowance(30.3).
            setWeekDayRate(20).
            setWeekendRate(40).
            setCurrency('EUR').
            setStartDate(Date.newInstance(2021,1,1)).
            setEndDate(Date.newInstance(2021,12,31)).
            build();
        insert nuNorthStaffResearcherEURTimesheetRate;
        
        TimesheetRate__c unionNorthFreelancerFLCAMERAEURTimesheetRate = new TestDataFactory.TimesheetRateBuilder().
            setFringe(18.5).
            setBureau(northBureau.Id).
            setChristmasNewYearRate(20.2).
            setEmployeeRole('FL CAMERA').
            setEmployeeType('Freelancer').
            setForeignRate(10.2).
            setHolidayPay100(100).
            setHolidayPay200(200).
            setHolidayPay50(50).
            setMealPenalties(10.3).
            setNightDifferential(20.2).
            setOutOfTownFlatRate(15.1).
            setOvertimeRate(15.1).
            setPenaltyRate(30).
            setRestPenalty(35).
            setStraightTime(25).
            setUnion('510').
            setCurrency('EUR').
            setVacationAllowance(30.3).
            setStartDate(Date.newInstance(2021,1,1)).
            setEndDate(Date.newInstance(2021,12,31)).
            build();
        insert unionNorthFreelancerFLCAMERAEURTimesheetRate;

        Expense_Rates__c nuLondonStaffDoMealExpenseRate = new TestDataFactory.ExpenseRatesBuilder().
            setBureau(londonBureau.Id).
            setCostCategory('Payroll').
            setCostTypeCode('TestTypeCodeDomestic').
            setCostTypeName('ATestExpenseRateDomestic').
            setTalent('FALSE').
            setStaff('TRUE').
            setFreelance('FALSE').
            setIsUnion('FALSE').
            setIsntUnion('TRUE').
            setInTown('FALSE').
            setDomestic('TRUE').
            setForeign('FALSE').
            setRate(64).
        	build();
            nuLondonStaffDoMealExpenseRate.Start_Date__c = Date.newInstance(2021, 1, 1);
            nuLondonStaffDoMealExpenseRate.End_Date__c = Date.newInstance(2021, 12, 31);
        insert nuLondonStaffDoMealExpenseRate;

        Expense_Rates__c nuNorthStaffDoMealExpenseRate = new TestDataFactory.ExpenseRatesBuilder().
            setBureau(northBureau.Id).
            setCostCategory('Payroll').
            setCostTypeCode('TestTypeCodeDomestic').
            setCostTypeName('ATestExpenseRateDomestic').
            setTalent('FALSE').
            setStaff('TRUE').
            setFreelance('FALSE').
            setIsUnion('FALSE').
            setIsntUnion('TRUE').
            setInTown('FALSE').
            setDomestic('TRUE').
            setForeign('FALSE').
            setRate(64).
        	build();
            nuNorthStaffDoMealExpenseRate.Start_Date__c = Date.newInstance(2021, 1, 1);
            nuNorthStaffDoMealExpenseRate.End_Date__c = Date.newInstance(2021, 12, 31);
        insert nuNorthStaffDoMealExpenseRate;

        Story_Schedule_Association__c london48HjapanSSA = 
            new TestDataFactory.StoryScheduleAssociationBuilder().
            setCostCenter(costCenter48H.Id).
            setLocation(japanLocation.Id).
            setSchedule(londonSchedule.Id).
            setStory(london48HStory.Id).
            setIsCostCenterInvalid(true).
            build();

        insert london48HjapanSSA;

        Story_Schedule_Association__c north48HjapanSSA = 
            new TestDataFactory.StoryScheduleAssociationBuilder().
            setCostCenter(costCenter48H.Id).
            setLocation(japanLocation.Id).
            setSchedule(northSchedule.Id).
            setStory(london48HStory.Id).
            setIsCostCenterInvalid(true).
            build();

        insert north48HjapanSSA;
        
        Story_Schedule_Association__c asiaStoryScheduleAssociation = 
            new TestDataFactory.StoryScheduleAssociationBuilder().
            setCostCenter(costCenter48H.Id).
            setLocation(japanLocation.Id).
            setSchedule(asiaSchedule.Id).
            setStory(london48HStory.Id).
            setIsCostCenterInvalid(true).
            build();

        insert asiaStoryScheduleAssociation; 
    }

    @IsTest
    static void whenLondonInternationalDefaultTimesheetIsCreatedWithFxRate_verifyCalculations(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Satoshi'
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];

        CostCenter__c anotherCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = 'CBSN'
        ];

        Story_Schedule_Association__c aStoryScheduleAssociation = [
            SELECT Id
            FROM Story_Schedule_Association__c
            WHERE Schedule__r.Bureau__r.Name =: 'LONDON/EUROPEAN OPERATIONS'
        ];

        FX_Rate__c anFxRate = new FX_Rate__c(
            Currency__c = 'GBP',
            Start_Date__c = Date.newInstance(2021,1,1),
            FX_Rate__c = 1.5,
            End_Date__c = Date.newInstance(2021,12,31),
            Active__c = true
        );
        insert anFxRate;

        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            
            insert aStoryEmployeeAssociation;
        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of expenses was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == 22.65,
            'A wrong Straight_Time_Cost__c calculation. Expecting 22.65. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == 1,
            'A wrong Straight_Time__c. Expecting 1. ' +  timesheetsAfterInsert[0].Straight_Time__c +
            ' returned'   
        );
    }

    @IsTest
    static void whenAsiaInternationalDefaultTimesheetIsCreatedWithFxRate_verifyCalculations(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Satoshi'
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];

        CostCenter__c anotherCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = 'CBSN'
        ];

        Story_Schedule_Association__c aStoryScheduleAssociation = [
            SELECT Id
            FROM Story_Schedule_Association__c
            WHERE Schedule__r.Bureau__r.Name =: 'ASIA OPERATIONS'
        ];

        

        FX_Rate__c anFxRate = new FX_Rate__c(
            Currency__c = 'GBP',
            Start_Date__c = Date.newInstance(2021,1,1),
            FX_Rate__c = 1.5,
            End_Date__c = Date.newInstance(2021,12,31),
            Active__c = true
        );
        insert anFxRate;

        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            
            insert aStoryEmployeeAssociation;
        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of expenses was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == null,
            'A wrong Straight_Time_Cost__c calculation. Expecting null. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == null,
            'A wrong Straight_Time__c. Expecting null. ' +  timesheetsAfterInsert[0].Straight_Time__c +
            ' returned'   
        );
    }

    @IsTest
    static void whenLondonInternationalDefaultTimesheetIsCreatedWithFxRate_verifyAllFieldsCalculations(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];
        
        Bureau__c aBureau = [
            SELECT Id, Name
            FROM Bureau__c
            WHERE Name = 'LONDON/EUROPEAN OPERATIONS'
        ];

        Schedule__c aSchedule = [
            SELECT Id, Name, Date__c
            FROM Schedule__c
            WHERE Bureau__c =: aBureau.Id
        ];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Satoshi'
        ];

        Story__c aStory = [
            SELECT Id, Name
            FROM Story__c
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];

        CostCenter__c anotherCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = 'CBSN'
        ];

        Story_Schedule_Association__c aStoryScheduleAssociation = [
            SELECT Id
            FROM Story_Schedule_Association__c
            WHERE Schedule__r.Bureau__c =: aBureau.Id
        ];

        FX_Rate__c anFxRate = new FX_Rate__c(
            Currency__c = 'GBP',
            Start_Date__c = Date.newInstance(2021,1,1),
            FX_Rate__c = 1.5,
            End_Date__c = Date.newInstance(2021,12,31),
            Active__c = true
        );

        insert anFxRate;
        
        ScheduleAssociationTriggerBypass__c executeScheduleAssociationTrigger =
            new ScheduleAssociationTriggerBypass__c();
        
        executeScheduleAssociationTrigger = [
            SELECT Id, execute__c
            FROM ScheduleAssociationTriggerBypass__c
        ];

        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            executeScheduleAssociationTrigger.execute__c = false;
            update executeScheduleAssociationTrigger;

            insert aStoryEmployeeAssociation;

            executeScheduleAssociationTrigger.execute__c = true;
            update executeScheduleAssociationTrigger;

            Timesheet__c aTimesheet = new TestDataFactory.TimesheetBuilder().
                setBureau(aBureau.Id).
                setCostCenter(aCostCenter.Id).
                setDate(aSchedule.Date__c).
                setAutomatedProcess(false).
                setEmployee(anEmployee.Id).
                setStraightTime(1).
                setVacationAllowance(1).
                setForeignRates(1).
                setHolidayPay(1).
                setHolidayPay100(1).
                setHolidayPay200(1).
                setHolidayPay50(1).
                setMealPenalties(1).
                setMissedMeal('10').
                setNightDifferential(1).
                setOutOfTownFlatTime(1).
                setOvertime(1).
                setOverNight(1).
                setPayrateOVR(1).
                setPenaltyTime(1).
                setPremiumTime(1).
                setRestPenalty(1).
                setStoryEmployeeAssociation(aStoryEmployeeAssociation.Id).
                setWFS_Sourced(false).
                build();
            
            insert aTimesheet;

        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of expenses was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == 22.65,
            'A wrong Straight_Time_Cost__c calculation. Expecting 60. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == 1,
            'A wrong Straight_Time__c. Expecting 1. ' +  timesheetsAfterInsert[0].Straight_Time__c +
            ' returned'   
        );
    }

    @IsTest
    static void whenAsiaInternationalDefaultTimesheetIsCreatedWithFxRate_verifyAllFieldsCalculations(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];
        
        Bureau__c aBureau = [
            SELECT Id, Name
            FROM Bureau__c
            WHERE Name = 'ASIA OPERATIONS'
        ];

        Schedule__c aSchedule = [
            SELECT Id, Name, Date__c
            FROM Schedule__c
            WHERE Bureau__c =: aBureau.Id
        ];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Satoshi'
        ];

        Story__c aStory = [
            SELECT Id, Name
            FROM Story__c
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];

        CostCenter__c anotherCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = 'CBSN'
        ];

        Story_Schedule_Association__c aStoryScheduleAssociation = [
            SELECT Id
            FROM Story_Schedule_Association__c
            WHERE Schedule__r.Bureau__c =: aBureau.Id
        ];

        FX_Rate__c anFxRate = new FX_Rate__c(
            Currency__c = 'GBP',
            Start_Date__c = Date.newInstance(2021,1,1),
            FX_Rate__c = 1.5,
            End_Date__c = Date.newInstance(2021,12,31),
            Active__c = true
        );

        insert anFxRate;
        
        ScheduleAssociationTriggerBypass__c executeScheduleAssociationTrigger =
            new ScheduleAssociationTriggerBypass__c();
        
        executeScheduleAssociationTrigger = [
            SELECT Id, execute__c
            FROM ScheduleAssociationTriggerBypass__c
        ];

        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            executeScheduleAssociationTrigger.execute__c = false;
            update executeScheduleAssociationTrigger;

            insert aStoryEmployeeAssociation;

            executeScheduleAssociationTrigger.execute__c = true;
            update executeScheduleAssociationTrigger;

            Timesheet__c aTimesheet = new TestDataFactory.TimesheetBuilder().
                setBureau(aBureau.Id).
                setCostCenter(aCostCenter.Id).
                setDate(aSchedule.Date__c).
                setAutomatedProcess(false).
                setEmployee(anEmployee.Id).
                setStraightTime(1).
                setVacationAllowance(1).
                setForeignRates(1).
                setHolidayPay(1).
                setHolidayPay100(1).
                setHolidayPay200(1).
                setHolidayPay50(1).
                setMealPenalties(1).
                setMissedMeal('10').
                setNightDifferential(1).
                setOutOfTownFlatTime(1).
                setOvertime(1).
                setOverNight(1).
                setPayrateOVR(1).
                setPenaltyTime(1).
                setPremiumTime(1).
                setRestPenalty(1).
                setStoryEmployeeAssociation(aStoryEmployeeAssociation.Id).
                setWFS_Sourced(false).
                build();
            
            try {
                
                insert aTimesheet;
            } catch (Exception e) {
                System.debug('INSERT DEBUG');
                System.debug(e.getStackTraceString());
                System.debug(e.getCause());
                System.debug(e.getMessage());
            }

        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of expenses was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == null,
            'A wrong Straight_Time_Cost__c calculation. Expecting null. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == 1,
            'A wrong Straight_Time__c. Expecting 1. ' +  timesheetsAfterInsert[0].Straight_Time__c +
            ' returned'   
        );
    }

    @IsTest
    static void whenLondonInternationalDefaultTimesheetIsUpdatedWithFxRate_verifyAllFieldsCalculations(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];

        Bureau__c aBureau = [
            SELECT Id, Name
            FROM Bureau__c
            WHERE Name = 'LONDON/EUROPEAN OPERATIONS'
        ];

        Schedule__c aSchedule = [
            SELECT Id, Name, Date__c
            FROM Schedule__c
            WHERE Bureau__c =: aBureau.Id
        ];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Satoshi'
        ];

        Story__c aStory = [
            SELECT Id, Name
            FROM Story__c
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];

        CostCenter__c anotherCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = 'CBSN'
        ];

        Story_Schedule_Association__c aStoryScheduleAssociation = [
            SELECT Id
            FROM Story_Schedule_Association__c
            WHERE Schedule__c =: aSchedule.Id
        ];

        FX_Rate__c anFxRate = new FX_Rate__c(
            Currency__c = 'GBP',
            Start_Date__c = Date.newInstance(2021,1,1),
            FX_Rate__c = 1.5,
            End_Date__c = Date.newInstance(2021,12,31)
            //Active__c = true
        );

        insert anFxRate;
        
        ScheduleAssociationTriggerBypass__c executeScheduleAssociationTrigger =
            new ScheduleAssociationTriggerBypass__c();
        
        executeScheduleAssociationTrigger = [
            SELECT Id, execute__c
            FROM ScheduleAssociationTriggerBypass__c
        ];

        
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            executeScheduleAssociationTrigger.execute__c = false;
            update executeScheduleAssociationTrigger;

            insert aStoryEmployeeAssociation;

            executeScheduleAssociationTrigger.execute__c = true;
            update executeScheduleAssociationTrigger;

            Timesheet__c aTimesheet = new TestDataFactory.TimesheetBuilder().
                setBureau(aBureau.Id).
                setCostCenter(aCostCenter.Id).
                setDate(aSchedule.Date__c).
                setAutomatedProcess(false).
                setEmployee(anEmployee.Id).
                setStraightTime(1).
                setVacationAllowance(1).
                setForeignRates(1).
                setHolidayPay(1).
                setHolidayPay100(1).
                setHolidayPay200(1).
                setHolidayPay50(1).
                setMealPenalties(1).
                setMissedMeal('10').
                setNightDifferential(1).
                setOutOfTownFlatTime(1).
                setOvertime(1).
                setOverNight(1).
                setPayrateOVR(1).
                setPenaltyTime(1).
                setPremiumTime(1).
                setRestPenalty(1).
                setStoryEmployeeAssociation(aStoryEmployeeAssociation.Id).
                setWFS_Sourced(false).
                build();
            
            insert aTimesheet;
            
            Timesheet__c tmForUpdate = [
            	SELECT Id, Straight_Time__c, Vacation_Allowance__c, Foreign_Rates__c, 
                Holiday_Pay_100__c, Holiday_Pay_200__c, Holiday_Pay_50__c, Meal_Penalties__c, 
                Missed_Meal__c, Night_Differential__c, Out_of_Town_Flat_Time__c, Over_Time__c, 
                Overnight__c, PayRate_OVR__c, Penalty_Time__c, Rest_Penalty__c
                FROM Timesheet__c
                WHERE Id =: aTimesheet.Id
            ];

            tmForUpdate.Straight_Time__c = 2; 
            tmForUpdate.Vacation_Allowance__c = 2;
            tmForUpdate.Foreign_Rates__c = 2;
            tmForUpdate.Holiday_Pay_100__c = 2;
            tmForUpdate.Holiday_Pay_200__c = 2;
            tmForUpdate.Holiday_Pay_50__c = 2;
            tmForUpdate.Meal_Penalties__c = 2;
            tmForUpdate.Missed_Meal__c = '10';
            tmForUpdate.Night_Differential__c = 2;
            tmForUpdate.Out_of_Town_Flat_Time__c = 2;
            tmForUpdate.Over_Time__c = 2;
            tmForUpdate.Overnight__c = 2;
            tmForUpdate.PayRate_OVR__c = 2;
            tmForUpdate.Penalty_Time__c = 2;
            tmForUpdate.Rest_Penalty__c = 2;

                
        Test.startTest();
            update tmForUpdate;
            System.debug('RC timesheet' + tmForUpdate);
        Test.stopTest();

        }

        List<Timesheet__c> timesheetsAfterUpdate = new List<Timesheet__c>();
        timesheetsAfterUpdate = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];
        
        System.assert(
            timesheetsAfterUpdate.size() == 1,
            'A wrong number of Timesheets was created. Expecting 1. ' +  timesheetsAfterUpdate.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterUpdate[0].Straight_Time_Cost__c == 45.3,
            'A wrong Straight_Time_Cost__c calculation. Expecting 45.3. ' +  timesheetsAfterUpdate[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterUpdate[0].Straight_Time__c == 2,
            'A wrong Straight_Time__c. Expecting 2. ' +  timesheetsAfterUpdate[0].Straight_Time__c +
            ' returned'   
        );
    }

    @IsTest
    static void whenLondonInternationalDefaultTimesheetIsUpdatedWithFxRate_verifyAllFieldsCalculationsWeekDayTrue(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];

        Bureau__c aBureau = [
            SELECT Id, Name
            FROM Bureau__c
            WHERE Name = 'LONDON/EUROPEAN OPERATIONS'
        ];

        Schedule__c aSchedule = [
            SELECT Id, Name, Date__c
            FROM Schedule__c
            WHERE Bureau__c =: aBureau.Id
        ];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Satoshi'
        ];

        Story__c aStory = [
            SELECT Id, Name
            FROM Story__c
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];

        CostCenter__c anotherCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = 'CBSN'
        ];

        Story_Schedule_Association__c aStoryScheduleAssociation = [
            SELECT Id
            FROM Story_Schedule_Association__c
            WHERE Schedule__c =: aSchedule.Id
        ];

        FX_Rate__c anFxRate = new FX_Rate__c(
            Currency__c = 'GBP',
            Start_Date__c = Date.newInstance(2021,1,1),
            FX_Rate__c = 1.5,
            End_Date__c = Date.newInstance(2021,12,31)
            //Active__c = true
        );

        insert anFxRate;
        
        ScheduleAssociationTriggerBypass__c executeScheduleAssociationTrigger =
            new ScheduleAssociationTriggerBypass__c();
        
        executeScheduleAssociationTrigger = [
            SELECT Id, execute__c
            FROM ScheduleAssociationTriggerBypass__c
        ];

        
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            executeScheduleAssociationTrigger.execute__c = false;
            update executeScheduleAssociationTrigger;

            insert aStoryEmployeeAssociation;

            executeScheduleAssociationTrigger.execute__c = true;
            update executeScheduleAssociationTrigger;

            Timesheet__c aTimesheet = new TestDataFactory.TimesheetBuilder().
                setBureau(aBureau.Id).
                setCostCenter(aCostCenter.Id).
                setDate(Date.newInstance(2021, 1, 4)).
                setAutomatedProcess(false).
                setEmployee(anEmployee.Id).
                setStraightTime(1).
                setVacationAllowance(1).
                setForeignRates(1).
                setHolidayPay(1).
                setHolidayPay100(1).
                setHolidayPay200(1).
                setHolidayPay50(1).
                setMealPenalties(1).
                setMissedMeal('10').
                setNightDifferential(1).
                setOutOfTownFlatTime(1).
                setOvertime(1).
                setOverNight(1).
                setPayrateOVR(1).
                setPenaltyTime(1).
                setPremiumTime(1).
                setRestPenalty(1).
                setStoryEmployeeAssociation(aStoryEmployeeAssociation.Id).
                setWFS_Sourced(false).
                build();
            
            insert aTimesheet;
            
            Timesheet__c tmForUpdate = [
            	SELECT Id, Straight_Time__c, Vacation_Allowance__c, Foreign_Rates__c, 
                Holiday_Pay_100__c, Holiday_Pay_200__c, Holiday_Pay_50__c, Meal_Penalties__c, 
                Missed_Meal__c, Night_Differential__c, Out_of_Town_Flat_Time__c, Over_Time__c, 
                Overnight__c, PayRate_OVR__c, Penalty_Time__c, Rest_Penalty__c
                FROM Timesheet__c
                WHERE Id =: aTimesheet.Id
            ];

            tmForUpdate.Straight_Time__c = 2; 
            tmForUpdate.Vacation_Allowance__c = 2;
            tmForUpdate.Foreign_Rates__c = 2;
            tmForUpdate.Holiday_Pay_100__c = 2;
            tmForUpdate.Holiday_Pay_200__c = 2;
            tmForUpdate.Holiday_Pay_50__c = 2;
            tmForUpdate.Meal_Penalties__c = 2;
            tmForUpdate.Missed_Meal__c = '10';
            tmForUpdate.Night_Differential__c = 2;
            tmForUpdate.Out_of_Town_Flat_Time__c = 2;
            tmForUpdate.Over_Time__c = 2;
            tmForUpdate.Overnight__c = 2;
            tmForUpdate.PayRate_OVR__c = 2;
            tmForUpdate.Penalty_Time__c = 2;
            tmForUpdate.Rest_Penalty__c = 2;


                
        Test.startTest();
            update tmForUpdate;
            System.debug('RC timesheet' + tmForUpdate);
        Test.stopTest();

        }

        List<Timesheet__c> timesheetsAfterUpdate = new List<Timesheet__c>();
        timesheetsAfterUpdate = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];
        
        System.assert(
            timesheetsAfterUpdate.size() == 1,
            'A wrong number of Timesheets was created. Expecting 1. ' +  timesheetsAfterUpdate.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterUpdate[0].Straight_Time_Cost__c == 45.3,
            'A wrong Straight_Time_Cost__c calculation. Expecting 45.3. ' +  timesheetsAfterUpdate[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterUpdate[0].Straight_Time__c == 2,
            'A wrong Straight_Time__c. Expecting 2. ' +  timesheetsAfterUpdate[0].Straight_Time__c +
            ' returned'   
        );
    }

    @IsTest
    static void whenAsiaInternationalDefaultTimesheetIsUpdatedWithFxRate_verifyAllFieldsCalculations(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];

        Bureau__c aBureau = [
            SELECT Id, Name
            FROM Bureau__c
            WHERE Name = 'ASIA OPERATIONS'
        ];

        Schedule__c aSchedule = [
            SELECT Id, Name, Date__c
            FROM Schedule__c
            WHERE Bureau__c =: aBureau.Id
        ];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Satoshi'
        ];

        Story__c aStory = [
            SELECT Id, Name
            FROM Story__c
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];

        CostCenter__c anotherCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = 'CBSN'
        ];

        Story_Schedule_Association__c aStoryScheduleAssociation = [
            SELECT Id
            FROM Story_Schedule_Association__c
            WHERE Schedule__c =: aSchedule.Id
        ];

        FX_Rate__c anFxRate = new FX_Rate__c(
            Currency__c = 'GBP',
            Start_Date__c = Date.newInstance(2021,1,1),
            FX_Rate__c = 1.5,
            End_Date__c = Date.newInstance(2021,12,31)
            //Active__c = true
        );

        insert anFxRate;
        
        ScheduleAssociationTriggerBypass__c executeScheduleAssociationTrigger =
            new ScheduleAssociationTriggerBypass__c();
        
        executeScheduleAssociationTrigger = [
            SELECT Id, execute__c
            FROM ScheduleAssociationTriggerBypass__c
        ];

        
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            executeScheduleAssociationTrigger.execute__c = false;
            update executeScheduleAssociationTrigger;

            insert aStoryEmployeeAssociation;

            executeScheduleAssociationTrigger.execute__c = true;
            update executeScheduleAssociationTrigger;

            Timesheet__c aTimesheet = new TestDataFactory.TimesheetBuilder().
                setBureau(aBureau.Id).
                setCostCenter(aCostCenter.Id).
                setDate(aSchedule.Date__c).
                setAutomatedProcess(false).
                setEmployee(anEmployee.Id).
                setStraightTime(1).
                setVacationAllowance(1).
                setForeignRates(1).
                setHolidayPay(1).
                setHolidayPay100(1).
                setHolidayPay200(1).
                setHolidayPay50(1).
                setMealPenalties(1).
                setMissedMeal('10').
                setNightDifferential(1).
                setOutOfTownFlatTime(1).
                setOvertime(1).
                setOverNight(1).
                setPayrateOVR(1).
                setPenaltyTime(1).
                setPremiumTime(1).
                setRestPenalty(1).
                setStoryEmployeeAssociation(aStoryEmployeeAssociation.Id).
                setWFS_Sourced(false).
                build();
            
            insert aTimesheet;
            
            Timesheet__c tmForUpdate = [
            	SELECT Id, Straight_Time__c, Vacation_Allowance__c, Foreign_Rates__c, 
                Holiday_Pay_100__c, Holiday_Pay_200__c, Holiday_Pay_50__c, Meal_Penalties__c, 
                Missed_Meal__c, Night_Differential__c, Out_of_Town_Flat_Time__c, Over_Time__c, 
                Overnight__c, PayRate_OVR__c, Penalty_Time__c, Rest_Penalty__c
                FROM Timesheet__c
                WHERE Id =: aTimesheet.Id
            ];

            tmForUpdate.Straight_Time__c = 2; 
            tmForUpdate.Vacation_Allowance__c = 2;
            tmForUpdate.Foreign_Rates__c = 2;
            tmForUpdate.Holiday_Pay_100__c = 2;
            tmForUpdate.Holiday_Pay_200__c = 2;
            tmForUpdate.Holiday_Pay_50__c = 2;
            tmForUpdate.Meal_Penalties__c = 2;
            tmForUpdate.Missed_Meal__c = '10';
            tmForUpdate.Night_Differential__c = 2;
            tmForUpdate.Out_of_Town_Flat_Time__c = 2;
            tmForUpdate.Over_Time__c = 2;
            tmForUpdate.Overnight__c = 2;
            tmForUpdate.PayRate_OVR__c = 2;
            tmForUpdate.Penalty_Time__c = 2;
            tmForUpdate.Rest_Penalty__c = 2;

                
        Test.startTest();
            update tmForUpdate;
            System.debug('RC timesheet' + tmForUpdate);
        Test.stopTest();

        }

        List<Timesheet__c> timesheetsAfterUpdate = new List<Timesheet__c>();
        timesheetsAfterUpdate = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];
        
        System.assert(
            timesheetsAfterUpdate.size() == 1,
            'A wrong number of Timesheets was created. Expecting 1. ' +  timesheetsAfterUpdate.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterUpdate[0].Straight_Time_Cost__c == null,
            'A wrong Straight_Time_Cost__c calculation. Expecting null. ' +  timesheetsAfterUpdate[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterUpdate[0].Straight_Time__c == 2,
            'A wrong Straight_Time__c. Expecting 2. ' +  timesheetsAfterUpdate[0].Straight_Time__c +
            ' returned'   
        );
    }

    @IsTest
    static void whenLondonInternationalDefaultTimesheetIsCreatedWithoutFxRate_verifyCalculations(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Satoshi'
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];

        CostCenter__c anotherCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = 'CBSN'
        ];

        Story_Schedule_Association__c aStoryScheduleAssociation = [
            SELECT Id
            FROM Story_Schedule_Association__c
            WHERE Schedule__r.Bureau__r.Name =: 'LONDON/EUROPEAN OPERATIONS'
        ];


        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            insert aStoryEmployeeAssociation;
        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of expenses was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == 15.1,
            'A wrong Straight_Time_Cost__c calculation. Expecting 40. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == 1,
            'A wrong Straight_Time__c. Expecting 1. ' +  timesheetsAfterInsert[0].Straight_Time__c +
            ' returned'   
        );
    }

    @IsTest
    static void whenAsiaInternationalDefaultTimesheetIsCreatedWithoutFxRate_verifyCalculations(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Satoshi'
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];

        CostCenter__c anotherCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = 'CBSN'
        ];

        Story_Schedule_Association__c aStoryScheduleAssociation = [
            SELECT Id
            FROM Story_Schedule_Association__c
            WHERE Schedule__r.Bureau__r.Name =: 'ASIA OPERATIONS'
        ];


        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            insert aStoryEmployeeAssociation;
        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of expenses was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == null,
            'A wrong Straight_Time_Cost__c calculation. Expecting null. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == null,
            'A wrong Straight_Time__c. Expecting null. ' +  timesheetsAfterInsert[0].Straight_Time__c +
            ' returned'   
        );
    }

    @IsTest
    static void whenLondonWeekDayInternationalDefaultTimesheetIsCreatedWithFxRate_verifyCalculations(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];

        Bureau__c aBureau = [
            SELECT Id, Name
            FROM Bureau__c
            WHERE Name = 'LONDON/EUROPEAN OPERATIONS'
        ];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Hal'
        ];

        Story__c aStory = [
            SELECT Id, Name
            FROM Story__c
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];
        Location__c aLocation = [
            SELECT Id
            FROM Location__c
            WHERE Name = 'Studio one'
        ];
        
        Schedule__c aSchedule = new Schedule__c(
            Bureau__c = aBureau.Id,
            Date__c = Date.newInstance(2021,1,6)
        );
        insert aSchedule;

        FX_Rate__c anFxRate = new FX_Rate__c(
            Currency__c = 'EUR',
            Start_Date__c = Date.newInstance(2021,1,1),
            FX_Rate__c = 1.5,
            End_Date__c = Date.newInstance(2021,12,31),
            Active__c = true
        );
        insert anFxRate;

        Story_Schedule_Association__c aStoryScheduleAssociation = 
            new TestDataFactory.StoryScheduleAssociationBuilder().
            setCostCenter(aCostCenter.Id).
            setLocation(aLocation.Id).
            setSchedule(aSchedule.Id).
            setStory(aStory.Id).
            setIsCostCenterInvalid(true).
            build();

        insert aStoryScheduleAssociation;

        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            insert aStoryEmployeeAssociation;
        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of expenses was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == 22.65,
            'A wrong Straight_Time_Cost__c calculation. Expecting 22.65. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == 1,
            'A wrong Straight_Time__c. Expecting 1. ' +  timesheetsAfterInsert[0].Straight_Time__c +
            ' returned'   
        );
    }

    @IsTest
    static void whenAsiaWeekDayInternationalDefaultTimesheetIsCreatedWithFxRate_verifyCalculations(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];

        Bureau__c aBureau = [
            SELECT Id, Name
            FROM Bureau__c
            WHERE Name = 'ASIA OPERATIONS'
        ];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Hal'
        ];

        Story__c aStory = [
            SELECT Id, Name
            FROM Story__c
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];
        Location__c aLocation = [
            SELECT Id
            FROM Location__c
            WHERE Name = 'Studio one'
        ];
        
        Schedule__c aSchedule = new Schedule__c(
            Bureau__c = aBureau.Id,
            Date__c = Date.newInstance(2021,1,6)
        );
        insert aSchedule;

        FX_Rate__c anFxRate = new FX_Rate__c(
            Currency__c = 'GBP',
            Start_Date__c = Date.newInstance(2021,1,1),
            FX_Rate__c = 1.5,
            End_Date__c = Date.newInstance(2021,12,31),
            Active__c = true
        );
        insert anFxRate;

        Story_Schedule_Association__c aStoryScheduleAssociation = 
            new TestDataFactory.StoryScheduleAssociationBuilder().
            setCostCenter(aCostCenter.Id).
            setLocation(aLocation.Id).
            setSchedule(aSchedule.Id).
            setStory(aStory.Id).
            setIsCostCenterInvalid(true).
            build();

        insert aStoryScheduleAssociation;

        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            insert aStoryEmployeeAssociation;
        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of expenses was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == null,
            'A wrong Straight_Time_Cost__c calculation. Expecting null. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == null,
            'A wrong Straight_Time__c. Expecting null. ' +  timesheetsAfterInsert[0].Straight_Time__c + ' returned'   
        );
    }

    @IsTest
    static void whenLondonWeekDayInternationalDefaultTimesheetIsCreatedWithoutFxRate_verifyCalculations(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];

        Bureau__c aBureau = [
            SELECT Id, Name
            FROM Bureau__c
            WHERE Name = 'LONDON/EUROPEAN OPERATIONS'
        ];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Hal'
        ];

        Story__c aStory = [
            SELECT Id, Name
            FROM Story__c
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];
        Location__c aLocation = [
            SELECT Id
            FROM Location__c
            WHERE Name = 'Studio one'
        ];
        
        Schedule__c aSchedule = new Schedule__c(
            Bureau__c = aBureau.Id,
            Date__c = Date.newInstance(2021,1,6)
        );
        insert aSchedule;

        Story_Schedule_Association__c aStoryScheduleAssociation = 
            new TestDataFactory.StoryScheduleAssociationBuilder().
            setCostCenter(aCostCenter.Id).
            setLocation(aLocation.Id).
            setSchedule(aSchedule.Id).
            setStory(aStory.Id).
            setIsCostCenterInvalid(true).
            build();

        insert aStoryScheduleAssociation;

        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            insert aStoryEmployeeAssociation;
        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of expenses was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == 15.1,
            'A wrong Straight_Time_Cost__c calculation. Expecting 15.1. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == 1,
            'A wrong Straight_Time__c. Expecting 1. ' +  timesheetsAfterInsert[0].Straight_Time__c +
            ' returned'   
        );
    }

    @IsTest
    static void whenAsiaWeekDayInternationalDefaultTimesheetIsCreatedWithoutFxRate_verifyCalculations(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];

        Bureau__c aBureau = [
            SELECT Id, Name
            FROM Bureau__c
            WHERE Name = 'ASIA OPERATIONS'
        ];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Hal'
        ];

        Story__c aStory = [
            SELECT Id, Name
            FROM Story__c
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];
        Location__c aLocation = [
            SELECT Id
            FROM Location__c
            WHERE Name = 'Studio one'
        ];
        
        Schedule__c aSchedule = new Schedule__c(
            Bureau__c = aBureau.Id,
            Date__c = Date.newInstance(2021,1,6)
        );
        insert aSchedule;

        Story_Schedule_Association__c aStoryScheduleAssociation = 
            new TestDataFactory.StoryScheduleAssociationBuilder().
            setCostCenter(aCostCenter.Id).
            setLocation(aLocation.Id).
            setSchedule(aSchedule.Id).
            setStory(aStory.Id).
            setIsCostCenterInvalid(true).
            build();

        insert aStoryScheduleAssociation;

        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            insert aStoryEmployeeAssociation;
        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of expenses was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == null,
            'A wrong Straight_Time_Cost__c calculation. Expecting null. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == null,
            'A wrong Straight_Time__c. Expecting null. ' +  timesheetsAfterInsert[0].Straight_Time__c + ' returned'   
        );
    }

    @IsTest
    static void whenChristmasBankHolidayInternationalDefaultTimesheetIsCreated_verifyCalculations(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];

        Bureau__c aBureau = [
            SELECT Id, Name
            FROM Bureau__c
            WHERE Name = 'LONDON/EUROPEAN OPERATIONS'
        ];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Hal'
        ];

        Story__c aStory = [
            SELECT Id, Name
            FROM Story__c
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];
        Location__c aLocation = [
            SELECT Id
            FROM Location__c
            WHERE Name = 'Studio one'
        ];
        
        Schedule__c aSchedule = new Schedule__c(
            Bureau__c = aBureau.Id,
            Date__c = Date.newInstance(2021,1,6)
        );
        insert aSchedule;

        HolidayCustom__c aHolidayCustom = new HolidayCustom__c(
            Name = 'Christmas',
            Bureau__c = aBureau.Id,
            Date__c = aSchedule.Date__c
        );

        insert aHolidayCustom;

        FX_Rate__c anFxRate = new FX_Rate__c(
            Currency__c = 'EUR',
            Start_Date__c = Date.newInstance(2021,1,1),
            FX_Rate__c = 1.5,
            End_Date__c = Date.newInstance(2021,12,31),
            Active__c = true
        );
        insert anFxRate;

        Story_Schedule_Association__c aStoryScheduleAssociation = 
            new TestDataFactory.StoryScheduleAssociationBuilder().
            setCostCenter(aCostCenter.Id).
            setLocation(aLocation.Id).
            setSchedule(aSchedule.Id).
            setStory(aStory.Id).
            setIsCostCenterInvalid(true).
            build();

        insert aStoryScheduleAssociation;

        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            insert aStoryEmployeeAssociation;
        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of expenses was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == 30.3,
            'A wrong Straight_Time_Cost__c calculation. Expecting 30.3. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == 1,
            'A wrong Straight_Time__c. Expecting 1. ' +  timesheetsAfterInsert[0].Straight_Time__c +
            ' returned'   
        );
    }

    @IsTest
    static void whenNewYearBankHolidayInternationalDefaultTimesheetIsCreated_verifyCalculations(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];

        Bureau__c aBureau = [
            SELECT Id, Name
            FROM Bureau__c
            WHERE Name = 'LONDON/EUROPEAN OPERATIONS'
        ];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Hal'
        ];

        Story__c aStory = [
            SELECT Id, Name
            FROM Story__c
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];
        Location__c aLocation = [
            SELECT Id
            FROM Location__c
            WHERE Name = 'Studio one'
        ];
        
        Schedule__c aSchedule = new Schedule__c(
            Bureau__c = aBureau.Id,
            Date__c = Date.newInstance(2021,1,6)
        );
        insert aSchedule;

        HolidayCustom__c aHolidayCustom = new HolidayCustom__c(
            Name = 'New Year',
            Bureau__c = aBureau.Id,
            Date__c = aSchedule.Date__c
        );

        insert aHolidayCustom;

        FX_Rate__c anFxRate = new FX_Rate__c(
            Currency__c = 'EUR',
            Start_Date__c = Date.newInstance(2021,1,1),
            FX_Rate__c = 1.5,
            End_Date__c = Date.newInstance(2021,12,31),
            Active__c = true
        );
        insert anFxRate;

        Story_Schedule_Association__c aStoryScheduleAssociation = 
            new TestDataFactory.StoryScheduleAssociationBuilder().
            setCostCenter(aCostCenter.Id).
            setLocation(aLocation.Id).
            setSchedule(aSchedule.Id).
            setStory(aStory.Id).
            setIsCostCenterInvalid(true).
            build();

        insert aStoryScheduleAssociation;

        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            insert aStoryEmployeeAssociation;
        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of expenses was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == 30.3,
            'A wrong Straight_Time_Cost__c calculation. Expecting 30.3' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == 1,
            'A wrong Straight_Time__c. Expecting 1. ' +  timesheetsAfterInsert[0].Straight_Time__c +
            ' returned'   
        );
    }

    @IsTest
    static void whenBankHolidayInternationalDefaultTimesheetIsCreated_verifyCalculations(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];

        Bureau__c aBureau = [
            SELECT Id, Name
            FROM Bureau__c
            WHERE Name = 'LONDON/EUROPEAN OPERATIONS'
        ];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Hal'
        ];

        Story__c aStory = [
            SELECT Id, Name
            FROM Story__c
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];
        Location__c aLocation = [
            SELECT Id
            FROM Location__c
            WHERE Name = 'Studio one'
        ];
        
        Schedule__c aSchedule = new Schedule__c(
            Bureau__c = aBureau.Id,
            Date__c = Date.newInstance(2021,1,6)
        );
        insert aSchedule;

        HolidayCustom__c aHolidayCustom = new HolidayCustom__c(
            Name = 'Bank Holiday',
            Bureau__c = aBureau.Id,
            Date__c = aSchedule.Date__c
        );

        insert aHolidayCustom;

        Story_Schedule_Association__c aStoryScheduleAssociation = 
            new TestDataFactory.StoryScheduleAssociationBuilder().
            setCostCenter(aCostCenter.Id).
            setLocation(aLocation.Id).
            setSchedule(aSchedule.Id).
            setStory(aStory.Id).
            setIsCostCenterInvalid(true).
            build();

        insert aStoryScheduleAssociation;

        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            insert aStoryEmployeeAssociation;
        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of expenses was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == 10.1,
            'A wrong Straight_Time_Cost__c calculation. Expecting 10.1. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == 1,
            'A wrong Straight_Time__c. Expecting 1. ' +  timesheetsAfterInsert[0].Straight_Time__c +
            ' returned'   
        );
    }

    @IsTest
    static void whenBankHolidayInternationalDefaultTimesheetIsCreatedWithFxRate_verifyCalculations(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];

        Bureau__c aBureau = [
            SELECT Id, Name
            FROM Bureau__c
            WHERE Name = 'LONDON/EUROPEAN OPERATIONS'
        ];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Hal'
        ];

        Story__c aStory = [
            SELECT Id, Name
            FROM Story__c
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];
        Location__c aLocation = [
            SELECT Id
            FROM Location__c
            WHERE Name = 'Studio one'
        ];
        
        Schedule__c aSchedule = new Schedule__c(
            Bureau__c = aBureau.Id,
            Date__c = Date.newInstance(2021,1,6)
        );
        insert aSchedule;

        HolidayCustom__c aHolidayCustom = new HolidayCustom__c(
            Name = 'Bank Holiday',
            Bureau__c = aBureau.Id,
            Date__c = aSchedule.Date__c
        );

        insert aHolidayCustom;

        FX_Rate__c anFxRate = new FX_Rate__c(
            Currency__c = 'EUR',
            Start_Date__c = Date.newInstance(2021,1,1),
            FX_Rate__c = 1.5,
            End_Date__c = Date.newInstance(2021,12,31),
            Active__c = true
        );
        insert anFxRate;

        Story_Schedule_Association__c aStoryScheduleAssociation = 
            new TestDataFactory.StoryScheduleAssociationBuilder().
            setCostCenter(aCostCenter.Id).
            setLocation(aLocation.Id).
            setSchedule(aSchedule.Id).
            setStory(aStory.Id).
            setIsCostCenterInvalid(true).
            build();

        insert aStoryScheduleAssociation;

        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            insert aStoryEmployeeAssociation;
        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of expenses was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == 15.15,
            'A wrong Straight_Time_Cost__c calculation. Expecting 15.15. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == 1,
            'A wrong Straight_Time__c. Expecting 1. ' +  timesheetsAfterInsert[0].Straight_Time__c +
            ' returned'   
        );
    }
    
	@IsTest
    static void whenDomesticTimesheetIsCreatedWithoutFringe_verifyCalculations(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];
        
        Bureau__c aBureau = [
            SELECT Id, Name
            FROM Bureau__c
            WHERE Name = 'NORTH'
        ];

        Schedule__c aSchedule = [
            SELECT Id, Name, Date__c
            FROM Schedule__c
            WHERE Bureau__c =: aBureau.Id
        ];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Satoshi'
        ];

        Story__c aStory = [
            SELECT Id, Name
            FROM Story__c
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];

        CostCenter__c anotherCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = 'CBSN'
        ];

        Story_Schedule_Association__c aStoryScheduleAssociation = [
            SELECT Id
            FROM Story_Schedule_Association__c
            WHERE Schedule__c =: aSchedule.Id
        ];
        
        ScheduleAssociationTriggerBypass__c executeScheduleAssociationTrigger =
            new ScheduleAssociationTriggerBypass__c();
        
        executeScheduleAssociationTrigger = [
            SELECT Id, execute__c
            FROM ScheduleAssociationTriggerBypass__c
        ];

        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            executeScheduleAssociationTrigger.execute__c = false;
            update executeScheduleAssociationTrigger;

            insert aStoryEmployeeAssociation;

            executeScheduleAssociationTrigger.execute__c = true;
            update executeScheduleAssociationTrigger;

            Timesheet__c aTimesheet = new TestDataFactory.TimesheetBuilder().
                setBureau(aBureau.Id).
                setCostCenter(aCostCenter.Id).
                setDate(aSchedule.Date__c).
                setAutomatedProcess(false).
                setEmployee(anEmployee.Id).
                setStraightTime(1).
                setVacationAllowance(1).
                setForeignRates(1).
                setHolidayPay(1).
                setHolidayPay100(1).
                setHolidayPay200(1).
                setHolidayPay50(1).
                setMealPenalties(1).
                setMissedMeal('10').
                setNightDifferential(1).
                setOutOfTownFlatTime(1).
                setOvertime(1).
                setOverNight(1).
                setPayrateOVR(1).
                setPenaltyTime(1).
                setPremiumTime(1).
                setRestPenalty(1).
                setStoryEmployeeAssociation(aStoryEmployeeAssociation.Id).
                setWFS_Sourced(false).
                build();
            
            insert aTimesheet;

        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of expenses was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == 25,
            'A wrong Straight_Time_Cost__c calculation. Expecting 25. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == 1,
            'A wrong Straight_Time__c. Expecting 1. ' +  timesheetsAfterInsert[0].Straight_Time__c +
            ' returned'   
        );
    }
    
    @IsTest
    static void whenDomesticTimesheetIsCreatedWithFringe_verifyCalculations(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];
        
        Bureau__c aBureau = [
            SELECT Id, Name
            FROM Bureau__c
            WHERE Name = 'NORTH'
        ];

        Schedule__c aSchedule = [
            SELECT Id, Name, Date__c
            FROM Schedule__c
            WHERE Bureau__c =: aBureau.Id
        ];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Freelancer'
        ];

        Story__c aStory = [
            SELECT Id, Name
            FROM Story__c
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];

        CostCenter__c anotherCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = 'CBSN'
        ];

        Story_Schedule_Association__c aStoryScheduleAssociation = [
            SELECT Id
            FROM Story_Schedule_Association__c
            WHERE Schedule__c =: aSchedule.Id
        ];
        
        ScheduleAssociationTriggerBypass__c executeScheduleAssociationTrigger =
            new ScheduleAssociationTriggerBypass__c();
        
        executeScheduleAssociationTrigger = [
            SELECT Id, execute__c
            FROM ScheduleAssociationTriggerBypass__c
        ];

        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            executeScheduleAssociationTrigger.execute__c = false;
            update executeScheduleAssociationTrigger;

            insert aStoryEmployeeAssociation;

            executeScheduleAssociationTrigger.execute__c = true;
            update executeScheduleAssociationTrigger;

            Timesheet__c aTimesheet = new TestDataFactory.TimesheetBuilder().
                setBureau(aBureau.Id).
                setCostCenter(aCostCenter.Id).
                setDate(aSchedule.Date__c).
                setAutomatedProcess(false).
                setEmployee(anEmployee.Id).
                setStraightTime(1).
                setVacationAllowance(1).
                setForeignRates(1).
                setHolidayPay(1).
                setHolidayPay100(1).
                setHolidayPay200(1).
                setHolidayPay50(1).
                setMealPenalties(1).
                setMissedMeal('10').
                setNightDifferential(1).
                setOutOfTownFlatTime(1).
                setOvertime(1).
                setOverNight(1).
                setPayrateOVR(1).
                setPenaltyTime(1).
                setPremiumTime(1).
                setRestPenalty(1).
                setStoryEmployeeAssociation(aStoryEmployeeAssociation.Id).
                setWFS_Sourced(false).
                build();
            
            insert aTimesheet;

        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of expenses was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == 29.625,
            'A wrong Straight_Time_Cost__c calculation. Expecting 29.625. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == 1,
            'A wrong Straight_Time__c. Expecting 1. ' +  timesheetsAfterInsert[0].Straight_Time__c +
            ' returned'   
        );
    }
    
    @IsTest
    static void whenDomesticEmployeeDisabledCalculation_verifyNoCalculationsOnCreation(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];
        
        Bureau__c aBureau = [
            SELECT Id, Name
            FROM Bureau__c
            WHERE Name = 'NORTH'
        ];

        Schedule__c aSchedule = [
            SELECT Id, Name, Date__c
            FROM Schedule__c
            WHERE Bureau__r.Name = 'NORTH'
        ];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Satoshi'
        ];
        
        anEmployee.Disable_Calculation__c = true;
        update anEmployee;

        Story__c aStory = [
            SELECT Id, Name
            FROM Story__c
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];

        CostCenter__c anotherCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = 'CBSN'
        ];

        Story_Schedule_Association__c aStoryScheduleAssociation = [
            SELECT Id
            FROM Story_Schedule_Association__c
            WHERE Schedule__c =: aSchedule.Id
        ];
        
        ScheduleAssociationTriggerBypass__c executeScheduleAssociationTrigger =
            new ScheduleAssociationTriggerBypass__c();
        
        executeScheduleAssociationTrigger = [
            SELECT Id, execute__c
            FROM ScheduleAssociationTriggerBypass__c
        ];

        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            executeScheduleAssociationTrigger.execute__c = false;
            update executeScheduleAssociationTrigger;

            insert aStoryEmployeeAssociation;

            executeScheduleAssociationTrigger.execute__c = true;
            update executeScheduleAssociationTrigger;

            Timesheet__c aTimesheet = new TestDataFactory.TimesheetBuilder().
                setBureau(aBureau.Id).
                setCostCenter(aCostCenter.Id).
                setDate(aSchedule.Date__c).
                setAutomatedProcess(false).
                setEmployee(anEmployee.Id).
                setStraightTime(1).
                setVacationAllowance(1).
                setForeignRates(1).
                setHolidayPay(1).
                setHolidayPay100(1).
                setHolidayPay200(1).
                setHolidayPay50(1).
                setMealPenalties(1).
                setMissedMeal('10').
                setNightDifferential(1).
                setOutOfTownFlatTime(1).
                setOvertime(1).
                setOverNight(1).
                setPayrateOVR(1).
                setPenaltyTime(1).
                setPremiumTime(1).
                setRestPenalty(1).
                setStoryEmployeeAssociation(aStoryEmployeeAssociation.Id).
                setWFS_Sourced(false).
                build();
            
            insert aTimesheet;

        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of Timesheets was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == null,
            'A wrong Straight_Time_Cost__c calculation. Expecting null. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == 1,
            'A wrong Straight_Time__c. Expecting 1. ' +  timesheetsAfterInsert[0].Straight_Time__c +
            ' returned'   
        );
    }
    
    @IsTest
    static void whenDomesticEmployeeDisabledCalculation_verifyNoCalculationsOnUpdate(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];
        
        Bureau__c aBureau = [
            SELECT Id, Name
            FROM Bureau__c
            WHERE Name = 'NORTH'
        ];

        Schedule__c aSchedule = [
            SELECT Id, Name, Date__c
            FROM Schedule__c
            WHERE Bureau__r.Name = 'NORTH'
        ];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Satoshi'
        ];
        
        anEmployee.Disable_Calculation__c = true;
        update anEmployee;

        Story__c aStory = [
            SELECT Id, Name
            FROM Story__c
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];

        CostCenter__c anotherCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = 'CBSN'
        ];

        Story_Schedule_Association__c aStoryScheduleAssociation = [
            SELECT Id
            FROM Story_Schedule_Association__c
            WHERE Schedule__c =: aSchedule.Id
        ];
        
        ScheduleAssociationTriggerBypass__c executeScheduleAssociationTrigger =
            new ScheduleAssociationTriggerBypass__c();
        
        executeScheduleAssociationTrigger = [
            SELECT Id, execute__c
            FROM ScheduleAssociationTriggerBypass__c
        ];

        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            executeScheduleAssociationTrigger.execute__c = false;
            update executeScheduleAssociationTrigger;

            insert aStoryEmployeeAssociation;

            executeScheduleAssociationTrigger.execute__c = true;
            update executeScheduleAssociationTrigger;

            Timesheet__c aTimesheet = new TestDataFactory.TimesheetBuilder().
                setBureau(aBureau.Id).
                setCostCenter(aCostCenter.Id).
                setDate(aSchedule.Date__c).
                setAutomatedProcess(false).
                setEmployee(anEmployee.Id).
                setStraightTime(1).
                setVacationAllowance(1).
                setForeignRates(1).
                setHolidayPay(1).
                setHolidayPay100(1).
                setHolidayPay200(1).
                setHolidayPay50(1).
                setMealPenalties(1).
                setMissedMeal('10').
                setNightDifferential(1).
                setOutOfTownFlatTime(1).
                setOvertime(1).
                setOverNight(1).
                setPayrateOVR(1).
                setPenaltyTime(1).
                setPremiumTime(1).
                setRestPenalty(1).
                setStoryEmployeeAssociation(aStoryEmployeeAssociation.Id).
                setWFS_Sourced(false).
                build();
            insert aTimesheet;
            
            Timesheet__c singleTimesheet = [
            	SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            	FROM Timesheet__c LIMIT 1
        	];
            
            singleTimesheet.Straight_Time__c = 2;
            update singleTimesheet;
            
        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of Timesheets was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == null,
            'A wrong Straight_Time_Cost__c calculation. Expecting null. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == 2,
            'A wrong Straight_Time__c. Expecting 2. ' +  timesheetsAfterInsert[0].Straight_Time__c +
            ' returned'   
        );
    }
    
    @IsTest
    static void whenInternationalEmployeeDisabledCalculation_verifyNoCalculationsOnCreation(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];

        Bureau__c aBureau = [
            SELECT Id, Name
            FROM Bureau__c
            WHERE Name = 'LONDON/EUROPEAN OPERATIONS'
        ];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Hal'
        ];
        
        anEmployee.Disable_Calculation__c = true;
        update anEmployee;

        Story__c aStory = [
            SELECT Id, Name
            FROM Story__c
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];
        Location__c aLocation = [
            SELECT Id
            FROM Location__c
            WHERE Name = 'Studio one'
        ];
        
        Schedule__c aSchedule = new Schedule__c(
            Bureau__c = aBureau.Id,
            Date__c = Date.newInstance(2021,1,6)
        );
        insert aSchedule;

        FX_Rate__c anFxRate = new FX_Rate__c(
            Currency__c = 'GBP',
            Start_Date__c = Date.newInstance(2021,1,1),
            FX_Rate__c = 1.5,
            End_Date__c = Date.newInstance(2021,12,31),
            Active__c = true
        );
        insert anFxRate;

        Story_Schedule_Association__c aStoryScheduleAssociation = 
            new TestDataFactory.StoryScheduleAssociationBuilder().
            setCostCenter(aCostCenter.Id).
            setLocation(aLocation.Id).
            setSchedule(aSchedule.Id).
            setStory(aStory.Id).
            setIsCostCenterInvalid(true).
            build();

        insert aStoryScheduleAssociation;

        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            insert aStoryEmployeeAssociation;
        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of expenses was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == null,
            'A wrong Straight_Time_Cost__c calculation. Expecting null. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == 1,
            'A wrong Straight_Time__c. Expecting 1. ' +  timesheetsAfterInsert[0].Straight_Time__c +
            ' returned'   
        );
    }
    
    @IsTest
    static void whenInternationalEmployeeDisabledCalculation_verifyNoCalculationsOnUpdate(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];

        Bureau__c aBureau = [
            SELECT Id, Name
            FROM Bureau__c
            WHERE Name = 'LONDON/EUROPEAN OPERATIONS'
        ];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Hal'
        ];
        
        anEmployee.Disable_Calculation__c = true;
        update anEmployee;

        Story__c aStory = [
            SELECT Id, Name
            FROM Story__c
        ];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];
        Location__c aLocation = [
            SELECT Id
            FROM Location__c
            WHERE Name = 'Studio one'
        ];
        
        Schedule__c aSchedule = new Schedule__c(
            Bureau__c = aBureau.Id,
            Date__c = Date.newInstance(2021,1,6)
        );
        insert aSchedule;

        FX_Rate__c anFxRate = new FX_Rate__c(
            Currency__c = 'GBP',
            Start_Date__c = Date.newInstance(2021,1,1),
            FX_Rate__c = 1.5,
            End_Date__c = Date.newInstance(2021,12,31),
            Active__c = true
        );
        insert anFxRate;

        Story_Schedule_Association__c aStoryScheduleAssociation = 
            new TestDataFactory.StoryScheduleAssociationBuilder().
            setCostCenter(aCostCenter.Id).
            setLocation(aLocation.Id).
            setSchedule(aSchedule.Id).
            setStory(aStory.Id).
            setIsCostCenterInvalid(true).
            build();

        insert aStoryScheduleAssociation;

        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            insert aStoryEmployeeAssociation;
        }
        Test.stopTest();
        
        Timesheet__c singleTimesheet = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c LIMIT 1
        ];
        
        singleTimesheet.Straight_Time__c = 2;
        update singleTimesheet;

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c
            FROM Timesheet__c
        ];
        
        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of expenses was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == null,
            'A wrong Straight_Time_Cost__c calculation. Expecting null. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == 2,
            'A wrong Straight_Time__c. Expecting 2. ' +  timesheetsAfterInsert[0].Straight_Time__c +
            ' returned'   
        );
    }

    @IsTest
    static void whenLondonINTWeekendDefaultTimesheetIsCreatedWithFxAndX6_7Rate_verifyX6_7Days(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Satoshi'
        ];

        Bureau__c aBureau = [
            SELECT Id
            FROM Bureau__c
            WHERE Name = 'LONDON/EUROPEAN OPERATIONS'
        ][0];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];

        Location__c aLocation = [
            SELECT Id
            FROM Location__c
        ][0];
        Story__c aStory = [
            SELECT Id
            FROM Story__c
        ][0];

        Schedule__c aSchedule = new TestDataFactory.ScheduleBuilder().
            setBureau(aBureau.Id).
            setDate(Date.newInstance(2021, 1, 10)).
            build();
        insert aSchedule;

        Story_Schedule_Association__c aStoryScheduleAssociation = new Story_Schedule_Association__c();
        aStoryScheduleAssociation.Location__c = aLocation.Id;
        aStoryScheduleAssociation.Cost_Center__c = aCostCenter.Id;
        aStoryScheduleAssociation.Story__c = aStory.Id;
        aStoryScheduleAssociation.Schedule__c = aSchedule.Id;
        insert aStoryScheduleAssociation;


        FX_Rate__c anFxRate = new FX_Rate__c(
            Currency__c = 'GBP',
            Start_Date__c = Date.newInstance(2021,1,1),
            FX_Rate__c = 1.5,
            End_Date__c = Date.newInstance(2021,12,31),
            Active__c = true
        );
        insert anFxRate;

        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            
            insert aStoryEmployeeAssociation;
        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c, X6_7_Days_Total__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of expenses was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == 22.65,
            'A wrong Straight_Time_Cost__c calculation. Expecting 22.65. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );

        System.assert(
            timesheetsAfterInsert[0].X6_7_Days_Total__c == 100.5,
            'A wrong X6_7_Days_Total__c calculation. Expecting 100.5. ' +  timesheetsAfterInsert[0].X6_7_Days_Total__c +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == 1,
            'A wrong Straight_Time__c. Expecting 1. ' +  timesheetsAfterInsert[0].Straight_Time__c +
            ' returned'   
        );
    }

    @IsTest
    static void whenLondonINTWeekendDefaultTimesheetIsCreatedWithFxRateAndNoX6_7_verifyX6_7Days(){
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Satoshi'
        ];

        Bureau__c aBureau = [
            SELECT Id
            FROM Bureau__c
            WHERE Name = 'LONDON/EUROPEAN OPERATIONS'
        ][0];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];

        Location__c aLocation = [
            SELECT Id
            FROM Location__c
        ][0];
        Story__c aStory = [
            SELECT Id
            FROM Story__c
        ][0];

        TimesheetRate__c internationalNURate = [
            SELECT Id, X6_7_Days__c
            FROM TimesheetRate__c
            WHERE Union__c = 'NU'
            AND Bureau__c =: aBureau.Id
            AND Employee_Type__c = 'Staff'
            AND Employee_Title__c = 'RESEARCHER'
        ][0];

        internationalNURate.X6_7_Days__c = null;
        update internationalNURate;

        Schedule__c aSchedule = new TestDataFactory.ScheduleBuilder().
            setBureau(aBureau.Id).
            setDate(Date.newInstance(2021, 1, 10)).
            build();
        insert aSchedule;

        Story_Schedule_Association__c aStoryScheduleAssociation = new Story_Schedule_Association__c();
        aStoryScheduleAssociation.Location__c = aLocation.Id;
        aStoryScheduleAssociation.Cost_Center__c = aCostCenter.Id;
        aStoryScheduleAssociation.Story__c = aStory.Id;
        aStoryScheduleAssociation.Schedule__c = aSchedule.Id;
        insert aStoryScheduleAssociation;


        FX_Rate__c anFxRate = new FX_Rate__c(
            Currency__c = 'GBP',
            Start_Date__c = Date.newInstance(2021,1,1),
            FX_Rate__c = 1.5,
            End_Date__c = Date.newInstance(2021,12,31),
            Active__c = true
        );
        insert anFxRate;

        Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            
            insert aStoryEmployeeAssociation;
        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c, X6_7_Days_Total__c,
                   X6_7_Days__c
            FROM Timesheet__c
        ];

        System.assert(
            timesheetsAfterInsert.size() == 1,
            'A wrong number of expenses was created. Expecting 1. ' +  timesheetsAfterInsert.size() +
            ' returned'   
        );
        System.assert(
            timesheetsAfterInsert[0].Straight_Time_Cost__c == 22.65,
            'A wrong Straight_Time_Cost__c calculation. Expecting 22.65. ' +  timesheetsAfterInsert[0].Straight_Time_Cost__c +
            ' returned'   
        );

        System.assert(
            timesheetsAfterInsert[0].X6_7_Days_Total__c == null,
            'A wrong X6_7_Days_Total__c calculation. Expecting null. ' +  timesheetsAfterInsert[0].X6_7_Days_Total__c +
            ' returned'   
        );

        System.assert(
            timesheetsAfterInsert[0].X6_7_Days__c == null,
            'A wrong X6_7_Days__c calculation. Expecting null. ' +  timesheetsAfterInsert[0].X6_7_Days__c +
            ' returned'   
        );

        System.assert(
            timesheetsAfterInsert[0].Straight_Time__c == 1,
            'A wrong Straight_Time__c. Expecting 1. ' +  timesheetsAfterInsert[0].Straight_Time__c +
            ' returned'   
        );
    }
    
  @IsTest
    static void updateTimesheetWithStraightTimeCost(){
        //LR: test case for bug 1210
        User user = [
            SELECT Id, Name, Profile.Name
            FROM User 
            WHERE Profile.Name = 'Bureau Weekly Users'
            AND IsActive = true
        ][0];

        Contact anEmployee = [
            SELECT Id, Name
            FROM Contact
            WHERE FirstName = 'Satoshi'
        ];

        Bureau__c aBureau = [
            SELECT Id
            FROM Bureau__c
            WHERE Name = 'LONDON/EUROPEAN OPERATIONS'
        ][0];

        CostCenter__c aCostCenter = [
            SELECT Id
            FROM CostCenter__c
            WHERE Name = '48H'
        ];

        Location__c aLocation = [
            SELECT Id
            FROM Location__c
        ][0];
        Story__c aStory = [
            SELECT Id
            FROM Story__c
        ][0];
        
        
        TimesheetRate__c internationalNURate = [
            SELECT Id, X6_7_Days__c
            FROM TimesheetRate__c
            WHERE Union__c = 'NU'
            AND Bureau__c =: aBureau.Id
            AND Employee_Type__c = 'Staff'
            AND Employee_Title__c = 'RESEARCHER'
        ][0];

        internationalNURate.X6_7_Days__c = null;
        update internationalNURate;

        Schedule__c aSchedule = new TestDataFactory.ScheduleBuilder().
            setBureau(aBureau.Id).
            setDate(Date.newInstance(2021, 1, 10)).
            build();
        insert aSchedule;

        Story_Schedule_Association__c aStoryScheduleAssociation = new Story_Schedule_Association__c();
        aStoryScheduleAssociation.Location__c = aLocation.Id;
        aStoryScheduleAssociation.Cost_Center__c = aCostCenter.Id;
        aStoryScheduleAssociation.Story__c = aStory.Id;
        aStoryScheduleAssociation.Schedule__c = aSchedule.Id;
        insert aStoryScheduleAssociation;



        
                Test.startTest();
        System.runAs(user){
            ScheduleAssociation__c aStoryEmployeeAssociation =
                new TestDataFactory.StoryEmployeeAssociationBuilder().
                setEmployee(anEmployee.Id).
                setAssignmentInformation('DOMESTIC').
                setStoryScheduleAssociation(aStoryScheduleAssociation.Id).
                build();
            
            insert aStoryEmployeeAssociation;
        }
        Test.stopTest();

        List<Timesheet__c> timesheetsAfterInsert = new List<Timesheet__c>();
        timesheetsAfterInsert = [
            SELECT Id, Straight_Time__c, Straight_Time_Cost__c, X6_7_Days_Total__c,
                   X6_7_Days__c
            FROM Timesheet__c
        ];
        timesheetsAfterInsert[0].Straight_Time_cost__c=200;
       timesheetsAfterInsert[0].over_time_Cost__c=200;
         timesheetsAfterInsert[0].rest_penalty_Cost__c=200;
        update timesheetsAfterInsert;
        
                System.assert(
            timesheetsAfterInsert[0].Straight_Time_cost__c == 200,
            'A wrong Straight_Time_cost__c. Expecting 200. ' +  timesheetsAfterInsert[0].Straight_Time_cost__c +
            ' returned'   
        );
        
                        System.assert(
            timesheetsAfterInsert[0].over_time_Cost__c == 200,
            'A wrong over_time_Cost__c. Expecting 200. ' +  timesheetsAfterInsert[0].over_time_Cost__c +
            ' returned'   
        );
        
                        System.assert(
            timesheetsAfterInsert[0].rest_penalty_Cost__c == 200,
            'A wrong Straight_Time_cost__c. Expecting 200. ' +  timesheetsAfterInsert[0].Straight_Time_cost__c +
            ' returned'   
        );
    
    }
    
    
    
    
}