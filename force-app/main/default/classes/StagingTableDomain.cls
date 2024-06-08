public with sharing class StagingTableDomain
{
    
    public static List<Staging_Table__c> mapMissingNewsBureau(
        List<Staging_Table__c> records, 
        Map<String, String> bureauNamesMap,
        Map<String, Map<String, String>> earningCodesMap,
        Map<String, bureau__c> bureausMap
    ) {
        List<Staging_Table__c> stagingListNoError = new List<Staging_Table__c>();
        List<Staging_Table__c> stagingListWithError = new List<Staging_Table__c>();
        for(Staging_Table__c st : records)
        {
            if(st.Status__c == 'Finished') continue;
            if(st.Error_Code__c != 500 && st.Error_Code__c != 400)
            {
                if(st.Earnings_Code__c == null && st.Gross_Pay__c == null)
                {
                    st.Straight_Time__c = st.Hours__c != null? (st.Hours__c)/8 : 0;
                } 
                if(st.Earnings_Code__c == null && st.Gross_Pay__c != null)
                {
                    st.Error_Code__c = 101;
                    st.Error_Message__c = 'Please select an EarrningsCode';
                    st.Status__c = 'unprocessed';
                }
                else
                {
                    Map<String, String> ecmap = earningCodesMap.get(st.Earnings_Code__c);
                    if(ecmap != null && !ecmap.isEmpty())
                    {
                        string Grosspay = (new list<string>(ecmap.keyset()) )[0];
                        if(Grosspay == 'Missed_Meal__c') {
                            if(st.Gross_Pay__c!=null)
                                st.put(Grosspay, String.valueOf(st.Gross_Pay__c.format()));
                            if(st.Error_Code__c == 100) {
                                st.Error_Code__c = null;
                                st.Error_Message__c = null;
                            }
                        }
                        else if(Grosspay == 'Paid_Time_Off__c')
                        {
                            st.Paid_Time_Off__c = true;
                            if(st.Error_Code__c == 100) {
                                st.Error_Code__c = null;
                                st.Error_Message__c = null;
                            }
                        }
                        else
                        {
                            st.put(Grosspay, st.Gross_Pay__c);
                            if(st.Error_Code__c == 100) {
                                st.Error_Code__c = null;
                                st.Error_Message__c = null;
                            }
                        }
                        
                        if(ecmap.get(Grosspay) != null)
                        {
                            if(ecmap.get(Grosspay) == 'Straight_Time__c') {
                                st.put('Straight_Time__c', st.Hours__c != null? (st.Hours__c)/8 : 0);
                                if(st.Error_Code__c == 100) {
                                    st.Error_Code__c = null;
                                    st.Error_Message__c = null;
                                }
                                
                            }
                            else if(ecmap.get(Grosspay) == 'Foreign_Rates__c') {
                                st.put('Foreign_Rates__c', st.Hours__c != null? (st.Hours__c)/8 : 0);
                                if(st.Error_Code__c == 100) {
                                    st.Error_Code__c = null;
                                    st.Error_Message__c = null;
                                }
                                
                            } 
                            else {
                                st.put(ecmap.get(Grosspay), st.Hours__c);
                                if(st.Error_Code__c == 100) {
                                    st.Error_Code__c = null;
                                    st.Error_Message__c = null;
                                }
                            }
                        }
                    }
                    else
                    {
                        st.Error_Code__c = 100;
                        st.Error_Message__c = 'Earning Code not found';
                        st.Status__c = 'unprocessed';
                    }
                }
                if(st.get('News_Bureau__c') == 'DC') {
                    st.News_Bureau__c = 'WASHINGTON';
                }
                //GC 01/26/2022: Added new logic to verify the Bureaus with the existent Bureaus on Salesforce
                else if(
                    !bureausMap.containsKey(st.News_Bureau__c) &&
                     st.News_Bureau__c != null
                ){
                    string mapkey = st.Dept__c;
                    if(bureauNamesMap.get(mapkey) != null) {
                        st.News_Bureau__c = bureauNamesMap.get(mapkey);
                    } else {
                        st.Error_Code__c = st.Error_Code__c != null ? st.Error_Code__c : 200;
                        st.Error_Message__c = st.Error_Message__c != null ? st.Error_Message__c : 'News Bureau cannot be mapped';
                    }
                }
                else if( st.get('News_Bureau__c') == null) 
                {
                    string mapkey = st.Dept__c;
                    
                    if(bureauNamesMap.get(mapkey) != null)
                        st.News_Bureau__c = bureauNamesMap.get(mapkey);
                    else
                    {
                        st.Error_Code__c = st.Error_Code__c != null ? st.Error_Code__c : 200;
                        st.Error_Message__c = st.Error_Message__c != null ? st.Error_Message__c : 'News Bureau cannot be mapped';
                    }
                }
            }
            if(st.Error_Code__c == 100 || st.Error_Code__c == 101)
                stagingListWithError.add(st); 
            
            stagingListNoError.add(st);
        }
        update stagingListWithError;
        return stagingListNoError;
    }
    
    public static Map<String, Staging_Table__c> segregateRecords(
        List<Staging_Table__c> records, 
        Map<String, Staging_Table__c> errorTimesheets
    ) {
        for(Staging_Table__c st : records)
        {
            if(st.Error_Code__c == 100)
                errorTimesheets.put(st.News_Bureau__c + st.Employee_ID__c + st.Work_Date__c, st);
        }
        return errorTimesheets;
    }
    
    public static Map<String, Staging_Table__c> mergeRecords(
        List<Staging_Table__c> records, 
        Map<String, Staging_Table__c> temporaryTimesheets,
        Map<String, Staging_Table__c> errorTimesheets
    ) {
        List<Staging_Table__c> mergeList = new List<Staging_Table__c>();
        List<Staging_Table__c> duplicateList = new List<Staging_Table__c>();
        List<Staging_Table__c> updateMergeList = new List<Staging_Table__c>();
        List<Staging_Table__c> errorList = new List<Staging_Table__c>();
        Map<String, Staging_Table__c> tempTimesheets = new Map<String, Staging_Table__c>();
        Set<String> uniqueIdentifierList = new Set<String>();
        if(temporaryTimesheets != null && temporaryTimesheets.size()>0)
        {
            for(String uniqueid : temporaryTimesheets.keyset())
            {
                uniqueIdentifierList.add(uniqueid);
                tempTimesheets.put(uniqueid, temporaryTimesheets.get(uniqueid));
            }
        }
        for(integer i = 0; i < records.size(); i++)
        {
            Staging_Table__c st = records[i].clone(false);
            string uniqueIdentifier = st.News_Bureau__c + st.Employee_ID__c + st.Work_Date__c;
            if(records[i].Status__c.toUpperCase()  != 'MERGED' && records[i].Error_Code__c != 100)
            {
                if(uniqueIdentifierList.add(uniqueIdentifier))
                {
                    records[i].Status__c  = 'Merged';
                    mergeList.add(records[i]);
                }
                else if(temporaryTimesheets.get(uniqueIdentifier) != null)
                {
                    Staging_Table__c mergedStaging = temporaryTimesheets.get(uniqueIdentifier);
                    mergedStaging.Straight_Time__c = mergedStaging.Straight_Time__c != null? (mergedStaging.Straight_Time__c+(st.Straight_Time__c != null ? st.Straight_Time__c:0)) : st.Straight_Time__c;
                    mergedStaging.Straight_Time_Cost__c = mergedStaging.Straight_Time_Cost__c!=null? (mergedStaging.Straight_Time_Cost__c+(st.Straight_Time_Cost__c != null ? st.Straight_Time_Cost__c:0)) : st.Straight_Time_Cost__c;
                    mergedStaging.Over_Time__c = mergedStaging.Over_Time__c!=null ? (mergedStaging.Over_Time__c+(st.Over_Time__c != null ? st.Over_Time__c:0)) : st.Over_Time__c;
                    mergedStaging.Over_Time_Cost__c = mergedStaging.Over_Time_Cost__c!=null? (mergedStaging.Over_Time_Cost__c+(st.Over_Time_Cost__c != null ? st.Over_Time_Cost__c:0)) : st.Over_Time_Cost__c;
                    mergedStaging.Night_Differential__c = mergedStaging.Night_Differential__c!=null? (mergedStaging.Night_Differential__c+(st.Night_Differential__c != null ? st.Night_Differential__c:0)): st.Night_Differential__c;
                    mergedStaging.Night_Differential_Cost__c = mergedStaging.Night_Differential_Cost__c!=null? (mergedStaging.Night_Differential_Cost__c+(st.Night_Differential_Cost__c != null ? st.Night_Differential_Cost__c:0)) : st.Night_Differential_Cost__c;
                    mergedStaging.Meal_Penalties__c = mergedStaging.Meal_Penalties__c!=null? (mergedStaging.Meal_Penalties__c+(st.Meal_Penalties__c != null ? st.Meal_Penalties__c:0)): st.Meal_Penalties__c;
                    mergedStaging.Meal_Penalties_Cost__c = mergedStaging.Meal_Penalties_Cost__c!=null? (mergedStaging.Meal_Penalties_Cost__c+(st.Meal_Penalties_Cost__c != null ? st.Meal_Penalties_Cost__c:0)): st.Meal_Penalties_Cost__c;
                    mergedStaging.Penalty_Time__c = mergedStaging.Penalty_Time__c!=null? (mergedStaging.Penalty_Time__c+(st.Penalty_Time__c != null ? st.Penalty_Time__c:0)) : st.Penalty_Time__c;
                    mergedStaging.Penalty_Time_Cost__c = mergedStaging.Penalty_Time_Cost__c!=null? (mergedStaging.Penalty_Time_Cost__c+(st.Penalty_Time_Cost__c != null ? st.Penalty_Time_Cost__c:0)) : st.Penalty_Time_Cost__c;
                    mergedStaging.Missed_Meal__c = mergedStaging.Missed_Meal__c!=null? mergedStaging.Missed_Meal__c: st.Missed_Meal__c;
                    mergedStaging.Fees__c = mergedStaging.Fees__c!=null? (mergedStaging.Fees__c+(st.Fees__c != null ? st.Fees__c:0)): st.Fees__c;
                    mergedStaging.Rest_Penalty__c = mergedStaging.Rest_Penalty__c!=null? (mergedStaging.Rest_Penalty__c+(st.Rest_Penalty__c != null ? st.Rest_Penalty__c:0)): st.Rest_Penalty__c;
                    mergedStaging.Rest_Penalty_Cost__c = mergedStaging.Rest_Penalty_Cost__c!=null? (mergedStaging.Rest_Penalty_Cost__c+(st.Rest_Penalty_Cost__c != null ? st.Rest_Penalty_Cost__c:0)): st.Rest_Penalty_Cost__c;
                    mergedStaging.Vacation_Allowance__c = mergedStaging.Vacation_Allowance__c!=null? (mergedStaging.Vacation_Allowance__c+(st.Vacation_Allowance__c != null ? st.Vacation_Allowance__c:0)): st.Vacation_Allowance__c;
                    mergedStaging.Vacation_Allowance_Cost__c = mergedStaging.Vacation_Allowance_Cost__c!=null? (mergedStaging.Vacation_Allowance_Cost__c+(st.Vacation_Allowance_Cost__c != null ? st.Vacation_Allowance_Cost__c:0)): st.Vacation_Allowance_Cost__c;
                    
                    //RC 12/14/2021: New fields
                    mergedStaging.Out_of_Town_Flat_Time__c = mergedStaging.Out_of_Town_Flat_Time__c!=null ? (mergedStaging.Out_of_Town_Flat_Time__c+(st.Out_of_Town_Flat_Time__c != null ? st.Out_of_Town_Flat_Time__c:0)) : st.Out_of_Town_Flat_Time__c;
                    mergedStaging.Out_of_Town_Flat_Day_Cost__c = mergedStaging.Out_of_Town_Flat_Day_Cost__c!=null? (mergedStaging.Out_of_Town_Flat_Day_Cost__c+(st.Out_of_Town_Flat_Day_Cost__c != null ? st.Out_of_Town_Flat_Day_Cost__c:0)) : st.Out_of_Town_Flat_Day_Cost__c;
                    mergedStaging.Overnight__c = mergedStaging.Overnight__c!=null ? (mergedStaging.Overnight__c+(st.Overnight__c != null ? st.Overnight__c:0)) : st.Overnight__c;
                    mergedStaging.Overnight_Cost__c = mergedStaging.Overnight_Cost__c!=null? (mergedStaging.Overnight_Cost__c+(st.Overnight_Cost__c != null ? st.Overnight_Cost__c:0)) : st.Overnight_Cost__c;
                    mergedStaging.Foreign_Rates__c = mergedStaging.Foreign_Rates__c != null? (mergedStaging.Foreign_Rates__c+(st.Foreign_Rates__c != null ? st.Foreign_Rates__c:0)) : st.Foreign_Rates__c;
                    //mergedStaging.Foreign_Rates__c = mergedStaging.Foreign_Rates__c!=null? (mergedStaging.Foreign_Rates__c+(st.Foreign_Rates__c != null ? st.Foreign_Rates__c/8 :0)): st.Foreign_Rates__c/8;
                    mergedStaging.Foreign_Rates_Cost__c = mergedStaging.Foreign_Rates_Cost__c!=null? (mergedStaging.Foreign_Rates_Cost__c+(st.Foreign_Rates_Cost__c != null ? st.Foreign_Rates_Cost__c:0)): st.Foreign_Rates_Cost__c;
                    mergedStaging.Premium_Time__c = mergedStaging.Premium_Time__c!=null ? (mergedStaging.Premium_Time__c+(st.Premium_Time__c != null ? st.Premium_Time__c:0)) : st.Premium_Time__c;
                    mergedStaging.Premium_Time_Cost__c = mergedStaging.Premium_Time_Cost__c!=null ? (mergedStaging.Premium_Time_Cost__c+(st.Premium_Time_Cost__c != null ? st.Premium_Time_Cost__c:0)) : st.Premium_Time_Cost__c;
                    
                    mergedStaging.Holiday_Pay_100__c = mergedStaging.Holiday_Pay_100__c!=null? (mergedStaging.Holiday_Pay_100__c+(st.Holiday_Pay_100__c != null ? st.Holiday_Pay_100__c:0)): st.Holiday_Pay_100__c;
                    mergedStaging.Holiday_Pay_100_Cost__c = mergedStaging.Holiday_Pay_100_Cost__c!=null? (mergedStaging.Holiday_Pay_100_Cost__c+(st.Holiday_Pay_100_Cost__c != null ? st.Holiday_Pay_100_Cost__c:0)): st.Holiday_Pay_100_Cost__c;
                    mergedStaging.Holiday_Pay_200__c = mergedStaging.Holiday_Pay_200__c!=null? (mergedStaging.Holiday_Pay_200__c+(st.Holiday_Pay_200__c != null ? st.Holiday_Pay_200__c:0)): st.Holiday_Pay_200__c;
                    mergedStaging.Holiday_Pay_200_Cost__c = mergedStaging.Holiday_Pay_200_Cost__c!=null? (mergedStaging.Holiday_Pay_200_Cost__c+(st.Holiday_Pay_200_Cost__c != null ? st.Holiday_Pay_200_Cost__c:0)): st.Holiday_Pay_200_Cost__c;
                    mergedStaging.Holiday_Pay_50__c = mergedStaging.Holiday_Pay_50__c!=null? (mergedStaging.Holiday_Pay_50__c+(st.Holiday_Pay_50__c != null ? st.Holiday_Pay_50__c:0)): st.Holiday_Pay_50__c;
                    mergedStaging.Holiday_Pay_50_Cost__c = mergedStaging.Holiday_Pay_50_Cost__c!=null? (mergedStaging.Holiday_Pay_50_Cost__c+(st.Holiday_Pay_50_Cost__c != null ? st.Holiday_Pay_50_Cost__c:0)): st.Holiday_Pay_50_Cost__c;
                    
                    mergedStaging.Paid_Time_Off__c = mergedStaging.Paid_Time_Off__c == false ? st.Paid_Time_Off__c : mergedStaging.Paid_Time_Off__c;
                    duplicateList.add(records[i]);
                }
                else
                {
                    duplicateList.add(records[i]);
                }
            }
            
            if(
                records[i].Status__c.toUpperCase()  == 'MERGED' &&
                records[i].Reprocess__c == True &&
                records[i].Error_Code__c == 200
            ){
                records[i].Error_Code__c = null;
                records[i].Error_Message__c = null;
                records[i].Reprocess__c = false;
                mergeList.add(records[i]);
            }
        }
        for(Staging_Table__c st : mergeList)
        {
            for(Staging_Table__c dupst : duplicateList)
            {
                if(dupst.News_Bureau__c == st.News_Bureau__c && dupst.Employee_ID__c == st.Employee_ID__c && dupst.Work_Date__c == st.Work_Date__c)
                {
                    st.Straight_Time__c = st.Straight_Time__c != null? (st.Straight_Time__c+(dupst.Straight_Time__c != null ? dupst.Straight_Time__c:0)) : dupst.Straight_Time__c;
                    st.Straight_Time_Cost__c = st.Straight_Time_Cost__c!=null? (st.Straight_Time_Cost__c+(dupst.Straight_Time_Cost__c != null ? dupst.Straight_Time_Cost__c:0)) : dupst.Straight_Time_Cost__c;
                    st.Over_Time__c = st.Over_Time__c!=null? (st.Over_Time__c+(dupst.Over_Time__c != null ? dupst.Over_Time__c:0)): dupst.Over_Time__c;
                    st.Over_Time_Cost__c = st.Over_Time_Cost__c!=null? (st.Over_Time_Cost__c+(dupst.Over_Time_Cost__c != null ? dupst.Over_Time_Cost__c:0)): dupst.Over_Time_Cost__c;
                    st.Night_Differential__c = st.Night_Differential__c!=null? (st.Night_Differential__c+(dupst.Night_Differential__c != null ? dupst.Night_Differential__c:0)): dupst.Night_Differential__c;
                    st.Night_Differential_Cost__c = st.Night_Differential_Cost__c!=null? (st.Night_Differential_Cost__c+(dupst.Night_Differential_Cost__c != null ? dupst.Night_Differential_Cost__c:0)): dupst.Night_Differential_Cost__c;
                    st.Meal_Penalties__c = st.Meal_Penalties__c!=null? (st.Meal_Penalties__c+(dupst.Meal_Penalties__c != null ? dupst.Meal_Penalties__c:0)): dupst.Meal_Penalties__c;
                    st.Meal_Penalties_Cost__c = st.Meal_Penalties_Cost__c!=null? (st.Meal_Penalties_Cost__c+(dupst.Meal_Penalties_Cost__c != null ? dupst.Meal_Penalties_Cost__c:0)): dupst.Meal_Penalties_Cost__c;
                    st.Penalty_Time__c = st.Penalty_Time__c!=null? (st.Penalty_Time__c+(dupst.Penalty_Time__c != null ? dupst.Penalty_Time__c:0)): dupst.Penalty_Time__c;
                    st.Penalty_Time_Cost__c = st.Penalty_Time_Cost__c!=null? (st.Penalty_Time_Cost__c+(dupst.Penalty_Time_Cost__c != null ? dupst.Penalty_Time_Cost__c:0)): dupst.Penalty_Time_Cost__c;
                    st.Missed_Meal__c = st.Missed_Meal__c!=null? st.Missed_Meal__c: dupst.Missed_Meal__c;
                    st.Fees__c = st.Fees__c!=null? (st.Fees__c+(dupst.Fees__c != null ? dupst.Fees__c:0)): dupst.Fees__c;
                    st.Rest_Penalty__c = st.Rest_Penalty__c!=null? (st.Rest_Penalty__c+(dupst.Rest_Penalty__c != null ? dupst.Rest_Penalty__c:0)): dupst.Rest_Penalty__c;
                    st.Rest_Penalty_Cost__c = st.Rest_Penalty_Cost__c!=null? (st.Rest_Penalty_Cost__c+(dupst.Rest_Penalty_Cost__c != null ? dupst.Rest_Penalty_Cost__c:0)): dupst.Rest_Penalty_Cost__c;
                    st.Vacation_Allowance__c = st.Vacation_Allowance__c!=null? (st.Vacation_Allowance__c+(dupst.Vacation_Allowance__c != null ? dupst.Vacation_Allowance__c:0)): dupst.Vacation_Allowance__c;
                    st.Vacation_Allowance_Cost__c = st.Vacation_Allowance_Cost__c!=null? (st.Vacation_Allowance_Cost__c+(dupst.Vacation_Allowance_Cost__c != null ? dupst.Vacation_Allowance_Cost__c:0)): dupst.Vacation_Allowance_Cost__c;
                    
                    //RC 12/14/2021: New fields
                    st.Out_of_Town_Flat_Time__c = st.Out_of_Town_Flat_Time__c!=null? (st.Out_of_Town_Flat_Time__c+(dupst.Out_of_Town_Flat_Time__c != null ? dupst.Out_of_Town_Flat_Time__c:0)): dupst.Out_of_Town_Flat_Time__c;
                    st.Out_of_Town_Flat_Day_Cost__c = st.Out_of_Town_Flat_Day_Cost__c!=null? (st.Out_of_Town_Flat_Day_Cost__c+(dupst.Out_of_Town_Flat_Day_Cost__c != null ? dupst.Out_of_Town_Flat_Day_Cost__c:0)): dupst.Out_of_Town_Flat_Day_Cost__c;
                    st.Overnight_Cost__c = st.Overnight_Cost__c!=null? (st.Overnight_Cost__c+(dupst.Overnight_Cost__c != null ? dupst.Overnight_Cost__c:0)): dupst.Overnight_Cost__c;
                    st.Overnight__c = st.Overnight__c!=null? (st.Overnight__c+(dupst.Overnight__c != null ? dupst.Overnight__c:0)): dupst.Overnight__c;
                    st.Foreign_Rates__c = st.Foreign_Rates__c != null? (st.Foreign_Rates__c+(dupst.Foreign_Rates__c != null ? dupst.Foreign_Rates__c:0)) : dupst.Foreign_Rates__c;
                    //st.Foreign_Rates__c = st.Foreign_Rates__c!=null? (st.Foreign_Rates__c+(dupst.Foreign_Rates__c != null ? dupst.Foreign_Rates__c/8:0)): (dupst.Foreign_Rates__c != null ? dupst.Foreign_Rates__c/8:0);
                    st.Foreign_Rates_Cost__c = st.Foreign_Rates_Cost__c!=null? (st.Foreign_Rates_Cost__c+(dupst.Foreign_Rates_Cost__c != null ? dupst.Foreign_Rates_Cost__c:0)): dupst.Foreign_Rates_Cost__c;
                    st.Premium_Time__c = st.Premium_Time__c!=null? (st.Premium_Time__c+(dupst.Premium_Time__c != null ? dupst.Premium_Time__c:0)): dupst.Premium_Time__c;
                    st.Premium_Time_Cost__c = st.Premium_Time_Cost__c!=null? (st.Premium_Time_Cost__c+(dupst.Premium_Time_Cost__c != null ? dupst.Premium_Time_Cost__c:0)): dupst.Premium_Time_Cost__c;
                    
                    st.Holiday_Pay_100__c = st.Holiday_Pay_100__c!=null? (st.Holiday_Pay_100__c+(dupst.Holiday_Pay_100__c != null ? dupst.Holiday_Pay_100__c:0)): dupst.Holiday_Pay_100__c;
                    st.Holiday_Pay_100_Cost__c = st.Holiday_Pay_100_Cost__c!=null? (st.Holiday_Pay_100_Cost__c+(dupst.Holiday_Pay_100_Cost__c != null ? dupst.Holiday_Pay_100_Cost__c:0)): dupst.Holiday_Pay_100_Cost__c;
                    st.Holiday_Pay_200__c = st.Holiday_Pay_200__c!=null? (st.Holiday_Pay_200__c+(dupst.Holiday_Pay_200__c != null ? dupst.Holiday_Pay_200__c:0)): dupst.Holiday_Pay_200__c;
                    st.Holiday_Pay_200_Cost__c = st.Holiday_Pay_200_Cost__c!=null? (st.Holiday_Pay_200_Cost__c+(dupst.Holiday_Pay_200_Cost__c != null ? dupst.Holiday_Pay_200_Cost__c:0)): dupst.Holiday_Pay_200_Cost__c;
                    st.Holiday_Pay_50__c = st.Holiday_Pay_50__c!=null? (st.Holiday_Pay_50__c+(dupst.Holiday_Pay_50__c != null ? dupst.Holiday_Pay_50__c:0)): dupst.Holiday_Pay_50__c;
                    st.Holiday_Pay_50_Cost__c = st.Holiday_Pay_50_Cost__c!=null? (st.Holiday_Pay_50_Cost__c+(dupst.Holiday_Pay_50_Cost__c != null ? dupst.Holiday_Pay_50_Cost__c:0)): dupst.Holiday_Pay_50_Cost__c;
                    
                    st.Paid_Time_Off__c = st.Paid_Time_Off__c == false ? dupst.Paid_Time_Off__c : st.Paid_Time_Off__c;

                    //AA Fill Merged_WFQ_records__c	with Merged Workforce Queue IDs

                    String idsMerged = String.isBlank(st.Merged_WFQ_records__c) ? (String)dupst.Id : st.Merged_WFQ_records__c + ', ' +  (String)dupst.Id;
                    st.Merged_WFQ_records__c = idsMerged.substring(0, 255);

                }
            }
            updateMergeList.add(st);
            tempTimesheets.put(st.News_Bureau__c + st.Employee_ID__c + st.Work_Date__c , st);
        }
        for(String uniqueid : tempTimesheets.keyset())
        {
            for(String uniqueid1 : errorTimesheets.keyset())
            {
                if(uniqueid == uniqueid1)
                {
                    Staging_Table__c st = tempTimesheets.get(uniqueid);
                    st.Status__c = 'Partially Merged';
                    errorList.add(st);
                }
            }
        }    
        delete duplicateList;
        update updateMergeList;
        update errorList;
        return tempTimesheets;
        //return a list of merged Staging table records
        //mark records merged
        //mark records with errors
    }
    
    public static Map<String, Contact> matchEmployees(
        List<Staging_table__c> scope, 
        Map<String, Staging_Table__c> temporaryTimesheets, 
        Map<String, bureau__c> bureausMapdb 
    ) {
        
        for(Staging_table__c st : scope)
        {
            if(
                (   
                    st.Error_Code__c == 400 &&
                    (
                        st.Status__c.toUppercase() == 'Merged' || 
                        st.Status__c.toUppercase() == 'Partially Merged'
                    ) &&
                    st.Reprocess__c == true &&
                    st.Employee__c != null
                )||
                (   
                    st.Error_Code__c == 500 &&
                    st.Status__c.toUppercase() == 'Merged' &&
                    st.Reprocess__c == true
                )
            )
            {
                temporaryTimesheets.put(st.News_Bureau__c + st.Employee_ID__c + st.Work_Date__c , st);
            }
        }
        Map<String, Contact> employeeMap = new Map<String, Contact>();
        List<Contact> employeeList = new List<Contact>();
        List<Contact> newEmployeeList = new List<Contact>();
        Map<String, Contact> newEmployeeMap = new Map<String, Contact>();
        Set<String> employeeIds = new Set<String>();
        Map<String, bureau__c> bureausMap = new Map<String, bureau__c>();
        Set<String> bureausSet = new Set<String>();
        Map<String, String> employeeTypesMap = new Map<String, String>();
        List<Staging_table__c> records = temporaryTimesheets.values();
        employeeTypesMap.put('S', 'Staff');
        employeeTypesMap.put('P', 'Freelancer');
        
        
        for(Staging_table__c record : records) {
            employeeIds.add(String.valueOf(record.get('Employee_ID__c')));
            bureausSet.add(String.valueOf(record.get('News_Bureau__c')));
        }
        
        //GC: Gets the Bureaus Ids from the Selector
        List<bureau__c> bureausList = StagingTableSelector.queryBureausIds(bureausSet);
        for(bureau__c bur: bureausList){
            bureausMap.put(bur.Name, bur);
        }
        
        employeeList = [
            SELECT Id, Employee_ID__c, Employee_Title__c, Employee_Type__c,Talent_Type__c
            FROM Contact
            WHERE Employee_ID__c IN:employeeIds
        ];
        
        for(Contact employee : employeeList) employeeMap.put(employee.Employee_ID__c, employee);
        
        for(Staging_table__c record : records) {
            if(record.Employee_ID__c == 'Error' ) continue;
            if(
                (   
                    record.Error_Code__c == 400 &&
                    record.Status__c.toUppercase() == 'Merged' &&
                    record.Reprocess__c == true &&
                    record.Employee__c != null
                )
            ) {
                List<Contact> matchingEmployees = [
                    SELECT Id, Employee_ID__c, Employee_Title__c, Employee_Type__c,Talent_Type__c
                    FROM Contact
                    WHERE Id =: record.Employee__c
                ];
                matchingEmployees[0].Employee_ID__c = record.Employee_ID__c;
                matchingEmployees[0].WFS_Employee_Title__c = record.Employee_Title__c;

                if(record.News_Bureau__c != null && bureausMapdb.containsKey(record.News_Bureau__c)) {
                    matchingEmployees[0].Bureau__c = bureausMap.get(record.News_Bureau__c).Id;
                } else if (record.News_Bureau__c != null && !bureausMapdb.containsKey(record.News_Bureau__c)){
                    matchingEmployees[0].Bureau__c = bureausMap.get('DEFAULT BUREAU').Id;
                }

                employeeMap.put(matchingEmployees[0].Employee_ID__c, matchingEmployees[0]);
                record.Error_Code__c = null;
                record.Error_Message__c = null;
                record.Reprocess__c = false;
            }
            
            if(employeeMap.containsKey(record.Employee_ID__c)) {          
                // LR 12/12/2022: Check if matched SF Employee is a talent
                if(employeeMap.get(record.Employee_ID__c).Employee_Type__c=='Talent'){
                    employeeMap.get(record.Employee_ID__c).Talent_Type__c = employeeTypesMap.get(record.Employee_Type__c);
                }else{
                    employeeMap.get(record.Employee_ID__c).Employee_Type__c = employeeTypesMap.get(record.Employee_Type__c);
                }
                //GC 01/26/2022: Added Error code to the logic so it doesn't say reference to null object.
                if(record.News_Bureau__c != null && bureausMapdb.containsKey(record.News_Bureau__c)) {
                    employeeMap.get(record.Employee_ID__c).Bureau__c = bureausMap.get(record.News_Bureau__c).Id;
                }
                employeeMap.get(record.Employee_ID__c).WFS_Employee_Title__c = record.Employee_Title__c;
            }

            //GC 01/27/2022: Added logic to avoid the match if the News Bureau is incorrect
            if( 
                !employeeMap.containsKey(record.Employee_ID__c) &&
                record.News_Bureau__c != null && bureausMapdb.containsKey(record.News_Bureau__c) &&
                (record.Error_Code__c == 500 || record.Error_Code__c == null)
            ) {
                Contact matchedContact = new Contact();
                matchedContact = StagingTableDomain.matchMissingEmployee(record, bureausMap);
                if( matchedContact.Employee_ID__c != 'Error') {
                    employeeMap.put(matchedContact.Employee_ID__c, matchedContact);
                    newEmployeeList.add(matchedContact);
                }
            }
        }
        update records;
        upsert newEmployeeList;
        update employeeMap.values();
        return  employeeMap;
    }

    
    public static Contact matchMissingEmployee(
        Staging_Table__c record, 
        Map<String, bureau__c> bureausMap
    ) {
        
        Map<String, String> employeeTypesMap = new Map<String, String>();
        List<Contact> matchingEmployees = new List<Contact>();
        Contact newEmployee = new Contact();
        employeeTypesMap.put('S', 'Staff');
        employeeTypesMap.put('P', 'Freelancer');

        if(
            !employeeTypesMap.containsKey(record.Employee_Type__c) ||
            (
                record.Employee_Type__c == 'S' &&
                record.Employee_Title__c.contains('FL ')
            )
        ) {
            record.Error_Code__c = 400;
            record.Error_Message__c = 'Potential duplicate employee found. Please match to the correct employee.';
            return new Contact(Employee_ID__c = 'Error');
        }
        
        matchingEmployees = [
            SELECT Id, Employee_ID__c,Employee_Type__c,Talent_Type__c
            FROM Contact
            WHERE Employee_ID__c = null
            AND FirstName =: String.valueOf(record.get('First_Name__c'))
            AND LastName =: String.valueOf(record.get('Last_Name__c'))
            AND (
                    Employee_Type__c =: String.valueOf(employeeTypesMap.get(String.valueOf(record.get('Employee_Type__c'))))
                    OR Talent_Type__c =: String.valueOf(employeeTypesMap.get(String.valueOf(record.get('Employee_Type__c'))))
                )
            AND Union__c =: String.valueOf(record.get('Union__c'))
            AND Bureau__c =: bureausMap.get(String.valueOf(record.get('News_Bureau__c'))).Id
        ];
        if(matchingEmployees.size() == 1) {
            matchingEmployees[0].Employee_ID__c = record.Employee_ID__c;
            update matchingEmployees[0];
            return matchingEmployees[0];
        } 
        
        if( matchingEmployees.size() > 1 ){
            record.Error_Code__c = 400;
            record.Error_Message__c = 'Potential duplicate employee found. Please match to the correct employee.';
            return new Contact(Employee_ID__c = 'Error');
        }
        
        matchingEmployees = [
            SELECT Id, Employee_ID__c,Employee_Type__c,Talent_Type__c
            FROM Contact
            WHERE Employee_ID__c = null
            AND FirstName =: String.valueOf(record.get('First_Name__c'))
            AND LastName =: String.valueOf(record.get('Last_Name__c'))
            AND (
                    Employee_Type__c =: String.valueOf(employeeTypesMap.get(String.valueOf(record.get('Employee_Type__c'))))
                    OR Talent_Type__c =: String.valueOf(employeeTypesMap.get(String.valueOf(record.get('Employee_Type__c'))))
                )
            AND Union__c =: String.valueOf(record.get('Union__c'))
        ];
        
        if(matchingEmployees.size() == 1) {
            matchingEmployees[0].Employee_ID__c = record.Employee_ID__c;
            update matchingEmployees[0];
            return matchingEmployees[0];
        }
        
        if( matchingEmployees.size() > 1 ){
            record.put('Error_Code__c', 400);
            record.put('Error_Message__c', 'Potential duplicate employee found. Please match to the correct employee.');
            return new Contact(Employee_ID__c = 'Error');
        }
        
        if( matchingEmployees.size() == 0) {
            
            newEmployee.FirstName = record.First_Name__c;
            newEmployee.LastName = record.Last_Name__c;
            newEmployee.Employee_ID__c = record.Employee_ID__c;
            newEmployee.Employee_Title__c = record.Employee_Title__c;
            newEmployee.Employee_Type__c = employeeTypesMap.get(record.Employee_Type__c);
            newEmployee.Union__c = record.Union__c;
            newEmployee.Currency__c = 'USD';
            newEmployee.Bureau__c = bureausMap.get(record.News_Bureau__c).Id;
        }
        return newEmployee;
    }
    
    public static Map<String, Staging_Table__c> createSEA(
        List<Staging_Table__c> records, 
        Map<String, Staging_Table__c> temporaryTimesheets, 
        Map<String, Contact> employees
    ) {
        List<Staging_Table__c> recordsToReprocess = new List<Staging_Table__c>();
        Set<Date> dateList = new Set<Date>();
        Set<String> bureaunameList = new Set<String>();
        Set<id> listStoryId = new Set<id>();
        Set<id> listLocationId = new Set<id>();
        Set<id> listCostCenterId = new Set<id>();
        for(Staging_Table__c st : records)
        {
            if(st.Reprocess__c == true && st.Status__c == 'Merged' && st.Error_Code__c == 500)
            {
                dateList.add(st.Work_Date__c);
                bureaunameList.add(st.News_Bureau__c);
                listStoryId.add(st.Story__c);
                listLocationId.add(st.Location__c);
                listCostCenterId.add(st.Cost_Center__c);
                st.Error_Code__c = null;
                recordsToReprocess.add(st);
                temporaryTimesheets.put(st.News_Bureau__c + st.Employee_ID__c + st.Work_Date__c , st);
            }
        }

        List<bureau__c> bureauList = StagingTableSelector.queryBureausIds(bureaunameList);
        List<Id> bureausIds = new List<Id>();
        Map<String, bureau__c> bureausMap = new Map<String, bureau__c>();
        for(bureau__c bur: bureauList){
            bureausIds.add(bur.Id);
            bureausMap.put(bur.Name, bur);
        }
        List<Schedule__c> scheduleList = StagingTableSelector.querySchedules(bureausIds, dateList);
        Map<String, Schedule__c> scheduleMap = new Map<String, Schedule__c>();
        Set<String> uniqueScList = new Set<String>();
        for(Schedule__c sc : scheduleList)
        {
            Date scDate = Date.newInstance(sc.Date__c.year(), 
                                           sc.Date__c.month(), 
                                           sc.Date__c.day());
            scheduleMap.put(sc.Bureau__c+String.valueOf(scDate), sc);
            uniqueScList.add(sc.Bureau__c+String.valueOf(scDate));
        }
        List<Story_Schedule_Association__c> stryScheList = StagingTableSelector.queryStorySchedules(listStoryId, scheduleList, listLocationId, listCostCenterId);
        Map<String, Story_Schedule_Association__c> stryScheduleMap = new Map<String, Story_Schedule_Association__c>();
        Set<String> uniquescaList = new Set<String>();
        for(Story_Schedule_Association__c strysch : stryScheList)
        {
            stryScheduleMap.put(String.valueOf(strysch.Schedule__c)+
                                String.valueOf(strysch.Cost_Center__c)+
                                String.valueOf(strysch.Location__c)+
                                String.valueOf(strysch.Story__c), strysch);
            uniquescaList.add(String.valueOf(strysch.Schedule__c)+String.valueOf(strysch.Cost_Center__c)+String.valueOf(strysch.Location__c)+String.valueOf(strysch.Story__c));
        }
        List<Contact> empList = new List<Contact>();
        if(employees != null && employees.size()>0)
        {
            for(String s : employees.keyset())
            {
                empList.add(employees.get(s));
            }
        }
        List<ScheduleAssociation__c> stryEmpList = StagingTableSelector.queryStoryEmployees(stryScheList, empList);
        List<Schedule__c> createSch = new List<Schedule__c>();
        List<Story_Schedule_Association__c> createSCA = new List<Story_Schedule_Association__c>();
        List<ScheduleAssociation__c> createSEA = new List<ScheduleAssociation__c>();
        List<CreateStryEmpA> createSEAStp = new List<CreateStryEmpA>();
        List<Staging_Table__c> updateStagingSEA = new List<Staging_Table__c>();
        for(Staging_Table__c st : recordsToReprocess)
        {
            boolean schedule = false;
            boolean storySchedule = false;
            boolean stryEmp = false;
            Bureau__c bure = bureausMap.get(st.News_Bureau__c);
            for(Schedule__c sc : scheduleList)
            {
                if(st.Work_Date__c == sc.Date__c && bure.Id == sc.Bureau__c)
                {
                    schedule = true;
                    for(Story_Schedule_Association__c sca : stryScheList)
                    {
                        if(st.Story__c == sca.Story__c && st.Cost_Center__c == sca.Cost_Center__c && st.Location__c == sca.Location__c && sca.Schedule__c == sc.id)
                        {
                            storySchedule = true;
                            for(ScheduleAssociation__c sea : stryEmpList)
                            {
                                if(sea.Story_Schedule_Association__c == sca.id && sea.Employee__r.Employee_ID__c == st.Employee_ID__c)
                                    stryEmp = true;
                            }
                        }
                    }
                }
            }
            Bureau__c bu = bureausMap.get(st.News_Bureau__c);
            Date stDate = Date.newInstance(st.Work_Date__c.year(), 
                                           st.Work_Date__c.month(), 
                                           st.Work_Date__c.day());
            if(schedule == false)
            {
                if(uniqueScList.add(bu.id+String.valueOf(stDate)))
                {
                    Schedule__c sch = new Schedule__c();
                    sch.Date__c = st.Work_Date__c;
                    sch.Bureau__c = bu.id;
                    createSch.add(sch);
                    scheduleMap.put(sch.Bureau__c+String.valueOf(stDate), sch);
                }
            }
            if(storySchedule == false)
            {
                Schedule__c sc = scheduleMap.get(bu.id+String.valueOf(stDate));
                Story_Schedule_Association__c strysch = new Story_Schedule_Association__c();
                strysch.Cost_Center__c = st.Cost_Center__c;
                strysch.Location__c = st.Location__c;
                strysch.Story__c = st.Story__c;
                if(sc.id != null)
                {
                    if(uniquescaList.add(String.valueOf(sc.id)+String.valueOf(strysch.Cost_Center__c)+String.valueOf(strysch.Location__c)+String.valueOf(strysch.Story__c)))
                    {
                        strysch.Schedule__c = sc.id;
                        createSCA.add(strysch);
                        stryScheduleMap.put(String.valueOf(strysch.Schedule__c)+
                                            String.valueOf(strysch.Cost_Center__c)+
                                            String.valueOf(strysch.Location__c)+
                                            String.valueOf(strysch.Story__c), strysch);
                    }
                }
                else
                {
                    CreateStryEmpA cseaStp = new CreateStryEmpA();
                    cseaStp.schedule = bu.id+String.valueOf(stDate);
                    cseaStp.storyScheduleAcc = strysch;
                    createSEAStp.add(cseaStp);
                }
            }
            if(stryEmp == false)
            {
                Contact emp = employees.get(st.Employee_ID__c);

                ScheduleAssociation__c stryempacc = new ScheduleAssociation__c();
                stryempacc.Employee__c = emp.id;
                stryempacc.Assignment_Information__c = st.Assignment_Information__c;
                /* TP 06/10/2022 : 526 Workforce Queue new Assignment Fields */
                stryempacc.Cloned__c = true;
                
                Schedule__c sc = scheduleMap.get(bu.id+String.valueOf(stDate));
                if(sc.id != null)
                {
                    Story_Schedule_Association__c sca = stryScheduleMap.get(String.valueOf(sc.id)+
                                                                            String.valueOf(st.Cost_Center__c)+
                                                                            String.valueOf(st.Location__c)+
                                                                            String.valueOf(st.Story__c));
                    if(sca != null && sca.Id !=null)
                    {
                        stryempacc.Story_Schedule_Association__c = sca.Id;
                        stryempacc.X9MaxValidationCheckbox__c = false;
                        createSEA.add(stryempacc);
                    }
                    else
                    {
                        CreateStryEmpA cseaStp = new CreateStryEmpA();
                        cseaStp.storySchedule = String.valueOf(sc.id)+String.valueOf(st.Cost_Center__c)+String.valueOf(st.Location__c)+String.valueOf(st.Story__c);
                        cseaStp.storyEmployeeAcc = stryempacc;
                        createSEAStp.add(cseaStp);
                    }
                }
                else
                {
                    CreateStryEmpA cseaStp = new CreateStryEmpA();
                    cseaStp.schedule = bu.id+String.valueOf(stDate);
                    cseaStp.storySchedule = String.valueOf(st.Cost_Center__c)+String.valueOf(st.Location__c)+String.valueOf(st.Story__c);
                    cseaStp.storyEmployeeAcc = stryempacc;
                    createSEAStp.add(cseaStp);
                }
            }
            st.Error_Code__c = null;
            st.Reprocess__c = false;
            updateStagingSEA.add(st);
        }
        update updateStagingSEA;
        insert createSch;
        for(CreateStryEmpA csea : createSEAStp)
        {
            if(csea.storyScheduleAcc != null)
            {
                Schedule__c sc = scheduleMap.get(csea.schedule);
                Story_Schedule_Association__c sca = csea.storyScheduleAcc;
                if(uniquescaList.add(String.valueOf(sc.id)+String.valueOf(sca.Cost_Center__c)+String.valueOf(sca.Location__c)+String.valueOf(sca.Story__c)))
                {

                    sca.Schedule__c = sc.Id;
                    sca.Cost_Center__c = sca.Cost_Center__c;
                    sca.Location__c = sca.Location__c;
                    sca.Story__c = sca.Story__c;
                    createSCA.add(sca);
                    stryScheduleMap.put(String.valueOf(sca.Schedule__c)+
                                        String.valueOf(sca.Cost_Center__c)+
                                        String.valueOf(sca.Location__c)+
                                        String.valueOf(sca.Story__c), sca);
                }
            }
        }
        insert createSCA;
        for(CreateStryEmpA csea : createSEAStp)
        {
            if(csea.storyEmployeeAcc != null && csea.schedule != null)
            {
                Schedule__c sc = scheduleMap.get(csea.schedule);
                string scastring = string.valueOf(sc.Id)+csea.storySchedule;
                Story_Schedule_Association__c sca = stryScheduleMap.get(scastring);
                ScheduleAssociation__c sea = csea.storyEmployeeAcc;
                sea.Story_Schedule_Association__c = sca.Id;
                sea.X9MaxValidationCheckbox__c = false;
                createSEA.add(sea);
            }
            else if(csea.storyEmployeeAcc != null && csea.schedule == null)
            {
                ScheduleAssociation__c sea = csea.storyEmployeeAcc;
                Story_Schedule_Association__c sca = stryScheduleMap.get(csea.storySchedule);
                sea.Story_Schedule_Association__c = sca.Id;
                sea.X9MaxValidationCheckbox__c = false;
                createSEA.add(sea);
            }
        }

        insert createSEA;
        return temporaryTimesheets;
    }
    
    public static List<Timesheet__c> createTimesheets(
        Map<String, Staging_Table__c> temporaryTimesheets, 
        Map<String, Contact> employeesMap
    ) {
        
        //GC 09/09/2021: Verifies the records
        List<Staging_Table__c> stRecords = new List<Staging_Table__c>();
        List<Staging_Table__c> stRecordsUpdate = new List<Staging_Table__c>();
        List<Timesheet__c> tmRecordsUpsert = new List<Timesheet__c>();
        List<Timesheet__c> tmRecordsAutoUpdate = new List<Timesheet__c>();
        Map<String, Staging_Table__c> stRecordsMap = new Map<String, Staging_Table__c>();
        Map<String, Timesheet__c> tmRecordsMap = new Map<String, Timesheet__c>();
        Map<String, Timesheet__c> tmWithStoryRecordsMap = new Map<String, Timesheet__c>();
        Map<String, Timesheet__c> alltmWithStoryRecordsMap = new Map<String, Timesheet__c>();
        Map<String, ScheduleAssociation__c> seasRecordsMap = new Map<String, ScheduleAssociation__c>();
        Set<String> bureausSet = new Set<String>();
        Set<String> employeesSet = new Set<String>();
        Set<Date> stDates = new Set<Date>();
        List<Contact> employeesList = new List<Contact>();
        Set<Id> employeesIds = new Set<Id>();
        Set<Id> bureausIds = new Set<Id>();
        Map<String, bureau__c> bureausMap = new Map<String, bureau__c>();
        
        Map<String, Date> dateFilterForRates = new Map<String, Date>();
        dateFilterForRates.put('earliestDate', null);
        dateFilterForRates.put('latestDate', null);
        
        //GC: Gets the values for Staging Table records, Bureaus and Employees for every temporaryTimesheets
        for(Staging_Table__c st: temporaryTimesheets.values()) {

            stRecords.add(st);
            if(st.News_Bureau__c != null){
                bureausSet.add(st.News_Bureau__c.toUppercase());
            }
            employeesSet.add(st.Employee_ID__c);
            stDates.add(st.Work_Date__c);
            if(
                dateFilterForRates.get('earliestDate') == null ||
                st.Work_Date__c < dateFilterForRates.get('earliestDate')
            ) {
                dateFilterForRates.put('earliestDate', st.Work_Date__c);
            }
            if(
                dateFilterForRates.get('latestDate') == null ||
                st.Work_Date__c > dateFilterForRates.get('latestDate')
            ) {
                dateFilterForRates.put('latestDate', st.Work_Date__c);
            }
        }
        
        //GC: Gets the Bureaus Ids from the Selector
        List<bureau__c> bureausList = StagingTableSelector.queryBureausIds(bureausSet);
        for(bureau__c bur: bureausList){
            bureausIds.add(bur.Id);
            bureausMap.put(bur.Name, bur);
        }
        
        //GC: Gets the Employee information from the map
        for(String con: employeesSet){
            if(employeesMap.containsKey(con)){
                employeesList.add(employeesMap.get(con));
                employeesIds.add(employeesMap.get(con).Id);
                //employeesMapTwo.put(con.Employee_ID__c, con);
            }
        }
        
        //GC: Query to get the placeholders
        List<Timesheet__c> timesheetsPlaceholders = 
            StagingTableSelector.queryTimesheetPlaceholders(
                bureausIds,
                employeesIds,
                stDates
            );
        
        //TP: Query to get the all timesheets
        List<Timesheet__c> allTimesheets = 
            StagingTableSelector.queryAllTimesheets(
                bureausIds,
                employeesIds,
                stDates
            );
        
        //GC: Query to get the SEAs
        List<ScheduleAssociation__c> seasList = 
            StagingTableSelector.querySEAs(
                bureausIds,
                employeesIds,
                stDates
            );
        
        //GC: Goes through every TM record
        for(Timesheet__c tmr: timesheetsPlaceholders){
            //GC: Holds the Timesheet Key
            String tmKeyMap;
            String tmStoryKeyMap;
            //GC: Holds the Employee Id from Timesheet
            String tmEmpId;
            //GC: Converts the Date so takes out the hours
            Date tmDate = Date.newInstance(tmr.Date__c.year(), 
                                           tmr.Date__c.month(), 
                                           tmr.Date__c.day());
            tmEmpId = employeesMap.get(tmr.Employee__r.Employee_ID__c).Employee_ID__c;
            tmKeyMap = String.valueOf(tmDate) + String.valueOf(tmr.Bureau__c) + tmEmpId;
            tmStoryKeyMap = tmKeyMap + String.valueOf(tmr.Story_Employee_Association__r.Story_Schedule_Association__r.Story__c) + String.valueOf(tmr.Story_Employee_Association__r.Story_Schedule_Association__r.Cost_Center__c);
            tmRecordsMap.put(tmKeyMap, tmr);
            tmWithStoryRecordsMap.put(tmStoryKeyMap, tmr);
        }
        
        //TP: Goes through every TM record
        for(Timesheet__c tmr: allTimesheets){
            String tmStoryKeyMap;
            String tmEmpId;
            Date tmDate = Date.newInstance(tmr.Date__c.year(), 
                                           tmr.Date__c.month(), 
                                           tmr.Date__c.day());
            tmEmpId = employeesMap.get(tmr.Employee__r.Employee_ID__c).Employee_ID__c;
            tmStoryKeyMap = String.valueOf(tmDate) + String.valueOf(tmr.Bureau__c) + tmEmpId + String.valueOf(tmr.Story_Employee_Association__r.Story_Schedule_Association__r.Story__c) + String.valueOf(tmr.Story_Employee_Association__r.Story_Schedule_Association__r.Cost_Center__c);
            alltmWithStoryRecordsMap.put(tmStoryKeyMap, tmr);
        }
        
        //GC: Goes through every SEA record
        for(ScheduleAssociation__c sea: seasList){
            //GC: Holds the Timesheet Key
            String seaKeyMap;
            //GC: Holds the Employee Id from Timesheet
            String seaEmpId;
            //GC: Converts the Date so takes out the hours
            Date tmDate = Date.newInstance(sea.Story_Schedule_Association__r.Schedule__r.Date__c.year(), 
                                           sea.Story_Schedule_Association__r.Schedule__r.Date__c.month(), 
                                           sea.Story_Schedule_Association__r.Schedule__r.Date__c.day());
            seaEmpId = employeesMap.get(sea.Employee__r.Employee_ID__c).Employee_ID__c;
            seaKeyMap = String.valueOf(tmDate) + String.valueOf(sea.Story_Schedule_Association__r.Schedule__r.Bureau__c) + seaEmpId;
            seasRecordsMap.put(seaKeyMap, sea);
            
        }
        
        //List<TimesheetRate__c> timesheetRate = TimesheetRatesSelector.selectByBureauId(bureausIds);
        Map<Id, TimesheetRate__c> timesheetRateMap = new Map<Id, TimesheetRate__c>(
            TimesheetRatesSelector.selectTimesheetBatchRates(
                bureausIds,
                dateFilterForRates.get('earliestDate'),
                dateFilterForRates.get('latestDate')
            )
        );
        Map<String, String> employeeTypesMap = new Map<String, String>();
        employeeTypesMap.put('S', 'Staff');
        employeeTypesMap.put('P', 'Freelancer');
        //GC: Goes through every ST record
        for(Staging_Table__c str: stRecords){
            //GC: Processes only Staging_Table records with status "MERGED"
            if(
                (
                    str.Status__c.toUppercase() == 'MERGED' &&
                    str.Error_Code__c == 500 &&
                    str.Reprocess__c == true
                ) ||
                (
                    str.Status__c.toUppercase() == 'MERGED' &&
                    str.Error_Code__c == null
                ) ||
                (
                    str.Status__c.toUppercase() == 'MERGED' &&
                    str.Error_Code__c == 200 &&
                    str.News_Bureau__c != null &&
                    str.Reprocess__c == true
                ) ||
                (
                    str.Status__c.toUppercase() == 'MERGED' &&
                    str.Error_Code__c == 400 &&
                    str.Employee__c != null &&
                    str.Reprocess__c == true
                )
            ){
                //GC: Holds the information for the Timesheet and ST
                Timesheet__c tmDataToUpsert = new Timesheet__c();
                Staging_Table__c stDataToUpdate = new Staging_Table__c();
                //GC: Holds the Staging Table Key
                String stKeyMap;
                //GC: Converts the name into the Bureau Id
                String bureauId;
                if(bureausMap.containsKey(str.News_Bureau__c.toUppercase())) {
                    bureauId = bureausMap.get(str.News_Bureau__c.toUppercase()).Id;
                }else{
                    //System.debug('RC: ' +str.News_Bureau__c);
                }
                //GC: Converts Date so takes out the hours
                Date stDate = Date.newInstance(str.Work_Date__c.year(), 
                                               str.Work_Date__c.month(), 
                                               str.Work_Date__c.day());
                stKeyMap = String.valueOf(stDate) + bureauId + str.Employee_ID__c;
                //stRecordsMap.put(stKeyMap, str);
                
                
                
                //GC: Compare the SEAs Key with the ST Key and checks if there's a match
                if(seasRecordsMap.containsKey(stKeyMap)){
                    TimesheetRate__c specificTimesheetRate = new TimesheetRate__c();
                    TimesheetRate__c genericTimesheetRate = new TimesheetRate__c();
                    TimesheetRate__c rate = new TimesheetRate__c();
                    Contact currentEmployee = employeesMap.get(str.Employee_ID__c);
                    for(TimesheetRate__c currentRate : timesheetRateMap.values()) {
                        id bureau = bureausMap.get(str.News_Bureau__c.toUppercase()).Id;
                        string empType = employeeTypesMap.get(str.Employee_Type__c);
                        if(
                            currentEmployee.Employee_Title__c != null &&
                            (
                                currentEmployee.Employee_Title__c == currentRate.Employee_Title__c &&
                                bureau == currentRate.Bureau__c &&
                                empType == currentRate.Employee_Type__c &&
                                str.Union__c == currentRate.Union__c &&
                                str.Work_Date__c >= currentRate.Start_Date__c &&
                                str.Work_Date__c <= currentRate.End_Date__c
                            )
                        ) {
                            specificTimesheetRate = currentRate;

                        }
                        if(
                            bureau == currentRate.Bureau__c &&
                            empType == currentRate.Employee_Type__c &&
                            str.Union__c == currentRate.Union__c &&
                            str.Work_Date__c >= currentRate.Start_Date__c &&
                            str.Work_Date__c <= currentRate.End_Date__c &&
                            currentRate.Employee_Title__c == null
                        ) {
                            genericTimesheetRate = currentRate;
                        }
                    }
                    if(specificTimesheetRate.Id != null) {
                        rate = specificTimesheetRate;
                    }
                    if(specificTimesheetRate.Id == null && genericTimesheetRate.Id != null) {
                        rate = genericTimesheetRate;
                    }
                    
                    //if(rate.Id == null) System.debug('No timesheet Rate Found!');

                    String tmNewKey = stKeyMap + String.valueOf(seasRecordsMap.get(stKeyMap).Story_Schedule_Association__r.Story__c) + String.valueOf(seasRecordsMap.get(stKeyMap).Story_Schedule_Association__r.Cost_Center__c);
                    if(rate.Id != null) {
                        //If there's a match, updates that Timesheet.
                        if(tmWithStoryRecordsMap.containsKey(tmNewKey)){
                            tmDataToUpsert.Id = tmWithStoryRecordsMap.get(tmNewKey).Id;
                            tmDataToUpsert.Automated_Process__c = True;
                            
                            tmDataToUpsert.CostCenter__c = seasRecordsMap.get(stKeyMap).Story_Schedule_Association__r.Cost_Center__c;
                            tmDataToUpsert.Story__c = seasRecordsMap.get(stKeyMap).Story_Schedule_Association__r.Story__c;
                            tmDataToUpsert.Story_Employee_Association__c = seasRecordsMap.get(stKeyMap).Id;
                            
                            tmDataToUpsert.Bureau__c = bureausMap.get(str.News_Bureau__c.toUppercase()).Id;
                            tmDataToUpsert.Date__c = str.Work_Date__c;
                            tmDataToUpsert.Employee__c = seasRecordsMap.get(stKeyMap).Employee__c;
                            tmDataToUpsert.Foreign_Rates__c = str.Foreign_Rates__c != null ? (str.Foreign_Rates__c/8):0;
                            tmDataToUpsert.Gross_Pay__c = str.Gross_Pay__c;
                            tmDataToUpsert.Holiday_Pay_100__c = str.Holiday_Pay_100__c;
                            tmDataToUpsert.Holiday_Pay_200__c = str.Holiday_Pay_200__c;
                            tmDataToUpsert.Holiday_Pay_50__c = str.Holiday_Pay_50__c;
                            tmDataToUpsert.Hours__c = str.Hours__c;
                            tmDataToUpsert.Internal_Notes__c = str.Internal_Notes__c;
                            tmDataToUpsert.Meal_Penalties__c = str.Meal_Penalties__c;
                            tmDataToUpsert.Missed_Meal__c = str.Missed_Meal__c;
                            tmDataToUpsert.Network_ID__c = str.Network_ID__c;
                            tmDataToUpsert.Night_Differential__c = str.Night_Differential__c;
                            tmDataToUpsert.Out_of_Town_Flat_Time__c = str.Out_of_Town_Flat_Time__c;
                            tmDataToUpsert.Over_Time__c = str.Over_Time__c;
                            tmDataToUpsert.PayRate_OVR__c = str.PayRate_OVR__c;
                            tmDataToUpsert.Penalty_Time__c = str.Penalty_Time__c;
                            tmDataToUpsert.Rest_Penalty__c = str.Rest_Penalty__c;
                            tmDataToUpsert.Show__c = str.Show__c;
                            tmDataToUpsert.Straight_Time__c = str.Straight_Time__c;
                            tmDataToUpsert.Vacation_Allowance__c = str.Vacation_Allowance__c;
                            tmDataToUpsert.Overnight__c = str.Overnight__c;
                            tmDataToUpsert.Premium_Time__c = str.Premium_Time__c;
                            tmDataToUpsert.Fees__c = str.Fees__c;
                            string empType = employeeTypesMap.get(str.Employee_Type__c);
                            if(empType == 'Freelancer') {
                                tmDataToUpsert.Fringe__c  = rate.Fringe__c;
                            }
                            
                            if(empType == 'Freelancer' && rate.Fringe__c != null && rate.Fringe__c != 0) {
                                if(str.Paid_Time_Off__c == true || tmRecordsMap.get(stKeyMap).Paid_Time_Off__c == true)
                                    tmDataToUpsert.Straight_Time_Cost__c = null;
                                else{
                                    if(str.Straight_Time_Cost__c != null)
                                        tmDataToUpsert.Straight_Time_Cost__c = str.Straight_Time_Cost__c * (1+(rate.Fringe__c/100));
                                    else
                                    {
                                        if(str.Straight_Time__c!=null)
                                            tmDataToUpsert.Straight_Time_Cost__c = (str.Straight_Time__c * (rate.Straight_Time__c == null ? 0 : rate.Straight_Time__c)) * (1 + (rate.Fringe__c / 100));
                                    }
                                }
                                if(str.Vacation_Allowance_Cost__c != null)
                                    tmDataToUpsert.Vacation_Allowance_Cost__c = str.Vacation_Allowance_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Vacation_Allowance__c!=null)
                                        tmDataToUpsert.Vacation_Allowance_Cost__c = (str.Vacation_Allowance__c * (rate.Vacation_Allowance__c == null ? 0 : rate.Vacation_Allowance__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Foreign_Rates_Cost__c != null)
                                    tmDataToUpsert.Foreign_Rates_Cost__c = str.Foreign_Rates_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Foreign_Rates__c!=null)
                                        tmDataToUpsert.Foreign_Rates_Cost__c = ((str.Foreign_Rates__c/8) * (rate.Foreign_Rates__c == null ? 0 : rate.Foreign_Rates__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Holiday_Pay_50_Cost__c != null)
                                    tmDataToUpsert.Holiday_Pay_50_Cost__c = str.Holiday_Pay_50_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Holiday_Pay_50__c!=null)
                                        tmDataToUpsert.Holiday_Pay_50_Cost__c = (str.Holiday_Pay_50__c * (rate.Holiday_Pay_50__c == null ? 0 : rate.Holiday_Pay_50__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Holiday_Pay_100_Cost__c != null)
                                    tmDataToUpsert.Holiday_Pay_100_Cost__c = str.Holiday_Pay_100_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Holiday_Pay_100__c!=null)
                                        tmDataToUpsert.Holiday_Pay_100_Cost__c = (str.Holiday_Pay_100__c * (rate.Holiday_Pay_100__c == null ? 0 : rate.Holiday_Pay_100__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Holiday_Pay_200_Cost__c != null)
                                    tmDataToUpsert.Holiday_Pay_200_Cost__c = str.Holiday_Pay_200_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Holiday_Pay_200__c!=null)
                                        tmDataToUpsert.Holiday_Pay_200_Cost__c = (str.Holiday_Pay_200__c * (rate.Holiday_Pay_200__c == null ? 0 : rate.Holiday_Pay_200__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Rest_Penalty_Cost__c != null)
                                    tmDataToUpsert.Rest_Penalty_Cost__c = str.Rest_Penalty_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Rest_Penalty__c!=null)
                                        tmDataToUpsert.Rest_Penalty_Cost__c = (str.Rest_Penalty__c * (rate.Rest_Penalty__c == null ? 0 : rate.Rest_Penalty__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Over_Time_Cost__c != null)
                                    tmDataToUpsert.Over_Time_Cost__c = str.Over_Time_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Over_Time__c!=null)
                                        tmDataToUpsert.Over_Time_Cost__c = (str.Over_Time__c * (rate.Over_Time_Rate__c == null ? 0 : rate.Over_Time_Rate__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Night_Differential_Cost__c != null)
                                    tmDataToUpsert.Night_Differential_Cost__c = str.Night_Differential_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Night_Differential__c!=null)
                                        tmDataToUpsert.Night_Differential_Cost__c = (str.Night_Differential__c * (rate.Night_Differential__c == null ? 0 : rate.Night_Differential__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Meal_Penalties_Cost__c != null)
                                    tmDataToUpsert.Meal_Penalties_Cost__c = str.Meal_Penalties_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Meal_Penalties__c!=null)
                                        tmDataToUpsert.Meal_Penalties_Cost__c = (str.Meal_Penalties__c * (rate.Meal_Penalties__c == null ? 0 : rate.Meal_Penalties__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Penalty_Time_Cost__c != null)
                                    tmDataToUpsert.Penalty_Time_Cost__c = str.Penalty_Time_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Penalty_Time__c!=null)
                                        tmDataToUpsert.Penalty_Time_Cost__c = (str.Penalty_Time__c * (rate.Penalty_Rate__c == null ? 0 : rate.Penalty_Rate__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Overnight_Cost__c != null)
                                    tmDataToUpsert.Overnight_Cost__c = str.Overnight_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Overnight__c!=null)
                                        tmDataToUpsert.Overnight_Cost__c = (str.Overnight__c * (rate.Overnight__c == null ? 0 : rate.Overnight__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Premium_Time_Cost__c != null)
                                    tmDataToUpsert.Premium_Time_Cost__c = str.Premium_Time_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Premium_Time__c!=null)
                                        tmDataToUpsert.Premium_Time_Cost__c = (str.Premium_Time__c * (rate.Premium_Time__c == null ? 0 : rate.Premium_Time__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Out_of_Town_Flat_Day_Cost__c != null)
                                    tmDataToUpsert.Out_of_Town_Flat_Day_Cost__c = str.Out_of_Town_Flat_Day_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Out_of_Town_Flat_Time__c!=null)
                                        tmDataToUpsert.Out_of_Town_Flat_Day_Cost__c = (str.Out_of_Town_Flat_Time__c * (rate.Out_of_Town_Flat_Day_rate__c == null ? 0 : rate.Out_of_Town_Flat_Day_rate__c)) * (1 + (rate.Fringe__c / 100));
                                }
                            } 
                            else {
                                if(str.Straight_Time_Cost__c != null && str.Paid_Time_Off__c == false)
                                    tmDataToUpsert.Straight_Time_Cost__c = str.Straight_Time_Cost__c;
                                else
                                {
                                    if(str.Straight_Time__c!=null && str.Paid_Time_Off__c == false)
                                        tmDataToUpsert.Straight_Time_Cost__c = (str.Straight_Time__c * (rate.Straight_Time__c == null ? 0 : rate.Straight_Time__c));
                                }
                                if(str.Vacation_Allowance_Cost__c != null)
                                    tmDataToUpsert.Vacation_Allowance_Cost__c = str.Vacation_Allowance_Cost__c;
                                else
                                {
                                    if(str.Vacation_Allowance__c!=null)
                                        tmDataToUpsert.Vacation_Allowance_Cost__c = (str.Vacation_Allowance__c * (rate.Vacation_Allowance__c == null ? 0 : rate.Vacation_Allowance__c));
                                }
                                if(str.Foreign_Rates_Cost__c != null)
                                    tmDataToUpsert.Foreign_Rates_Cost__c = str.Foreign_Rates_Cost__c;
                                else
                                {
                                    if(str.Foreign_Rates__c!=null)
                                        tmDataToUpsert.Foreign_Rates_Cost__c = ((str.Foreign_Rates__c/8) * (rate.Foreign_Rates__c == null ? 0 : rate.Foreign_Rates__c));
                                }
                                if(str.Holiday_Pay_50_Cost__c != null)
                                    tmDataToUpsert.Holiday_Pay_50_Cost__c = str.Holiday_Pay_50_Cost__c;
                                else
                                {
                                    if(str.Holiday_Pay_50__c!=null)
                                        tmDataToUpsert.Holiday_Pay_50_Cost__c = (str.Holiday_Pay_50__c * (rate.Holiday_Pay_50__c == null ? 0 : rate.Holiday_Pay_50__c));
                                }
                                if(str.Holiday_Pay_100_Cost__c != null)
                                    tmDataToUpsert.Holiday_Pay_100_Cost__c = str.Holiday_Pay_100_Cost__c;
                                else
                                {
                                    if(str.Holiday_Pay_100__c!=null)
                                        tmDataToUpsert.Holiday_Pay_100_Cost__c = (str.Holiday_Pay_100__c * (rate.Holiday_Pay_100__c == null ? 0 : rate.Holiday_Pay_100__c));
                                }
                                if(str.Holiday_Pay_200_Cost__c != null)
                                    tmDataToUpsert.Holiday_Pay_200_Cost__c = str.Holiday_Pay_200_Cost__c;
                                else
                                {
                                    if(str.Holiday_Pay_200__c!=null)
                                        tmDataToUpsert.Holiday_Pay_200_Cost__c = (str.Holiday_Pay_200__c * (rate.Holiday_Pay_200__c == null ? 0 : rate.Holiday_Pay_200__c));
                                }
                                if(str.Rest_Penalty_Cost__c != null)
                                    tmDataToUpsert.Rest_Penalty_Cost__c = str.Rest_Penalty_Cost__c;
                                else
                                {
                                    if(str.Rest_Penalty__c!=null)
                                        tmDataToUpsert.Rest_Penalty_Cost__c = (str.Rest_Penalty__c * (rate.Rest_Penalty__c == null ? 0 : rate.Rest_Penalty__c));
                                }
                                if(str.Over_Time_Cost__c != null)
                                    tmDataToUpsert.Over_Time_Cost__c = str.Over_Time_Cost__c;
                                else
                                {
                                    if(str.Over_Time__c!=null)
                                        tmDataToUpsert.Over_Time_Cost__c = (str.Over_Time__c * (rate.Over_Time_Rate__c == null ? 0 : rate.Over_Time_Rate__c));
                                }
                                if(str.Night_Differential_Cost__c != null)
                                    tmDataToUpsert.Night_Differential_Cost__c = str.Night_Differential_Cost__c;
                                else
                                {
                                    if(str.Night_Differential__c!=null)
                                        tmDataToUpsert.Night_Differential_Cost__c = (str.Night_Differential__c * (rate.Night_Differential__c == null ? 0 : rate.Night_Differential__c));
                                }
                                if(str.Meal_Penalties_Cost__c != null)
                                    tmDataToUpsert.Meal_Penalties_Cost__c = str.Meal_Penalties_Cost__c;
                                else
                                {
                                    if(str.Meal_Penalties__c!=null)
                                        tmDataToUpsert.Meal_Penalties_Cost__c = (str.Meal_Penalties__c * (rate.Meal_Penalties__c == null ? 0 : rate.Meal_Penalties__c));
                                }
                                if(str.Penalty_Time_Cost__c != null)
                                    tmDataToUpsert.Penalty_Time_Cost__c = str.Penalty_Time_Cost__c;
                                else
                                {
                                    if(str.Penalty_Time__c!=null)
                                        tmDataToUpsert.Penalty_Time_Cost__c = (str.Penalty_Time__c * (rate.Penalty_Rate__c == null ? 0 : rate.Penalty_Rate__c));
                                }
                                if(str.Overnight_Cost__c != null)
                                    tmDataToUpsert.Overnight_Cost__c = str.Overnight_Cost__c;
                                else
                                {
                                    if(str.Overnight__c!=null)
                                        tmDataToUpsert.Overnight_Cost__c = (str.Overnight__c * (rate.Overnight__c == null ? 0 : rate.Overnight__c));
                                }
                                if(str.Premium_Time_Cost__c != null)
                                    tmDataToUpsert.Premium_Time_Cost__c = str.Premium_Time_Cost__c;
                                else
                                {
                                    if(str.Premium_Time__c!=null)
                                        tmDataToUpsert.Premium_Time_Cost__c = (str.Premium_Time__c * (rate.Premium_Time__c == null ? 0 : rate.Premium_Time__c));
                                }
                                if(str.Out_of_Town_Flat_Day_Cost__c != null)
                                    tmDataToUpsert.Out_of_Town_Flat_Day_Cost__c = str.Out_of_Town_Flat_Day_Cost__c;
                                else
                                {
                                    if(str.Out_of_Town_Flat_Time__c!=null)
                                        tmDataToUpsert.Out_of_Town_Flat_Day_Cost__c = (str.Out_of_Town_Flat_Time__c * (rate.Out_of_Town_Flat_Day_rate__c == null ? 0 : rate.Out_of_Town_Flat_Day_rate__c));
                                }
                            }
                            
                            
                            tmDataToUpsert.WFS_Sourced__c = true;
                            tmDataToUpsert.Paid_Time_Off__c = str.Paid_Time_Off__c;
                            tmRecordsUpsert.add(tmDataToUpsert);
                            
                            stDataToUpdate.Id = str.Id;
                            stDataToUpdate.Error_Code__c = null;
                            stDataToUpdate.Error_Message__c = null;
                            stDataToUpdate.Status__c = 'Finished';
                            stRecordsUpdate.add(stDataToUpdate);
                            
                        }
                        //If there's NO match, creates a Timesheet.
                        else {
                            if(alltmWithStoryRecordsMap.containsKey(tmNewKey))
                            {
                                tmDataToUpsert.Story__c = alltmWithStoryRecordsMap.get(tmNewKey).Story__c;
                                tmDataToUpsert.CostCenter__c = alltmWithStoryRecordsMap.get(tmNewKey).CostCenter__c;
                            }
                            else
                            {
                                tmDataToUpsert.Story__c = seasRecordsMap.get(stKeyMap).Story_Schedule_Association__r.Story__c;
                                tmDataToUpsert.CostCenter__c = seasRecordsMap.get(stKeyMap).Story_Schedule_Association__r.Cost_Center__c;
                            }
                            tmDataToUpsert.Id = null;
                            tmDataToUpsert.Automated_Process__c = True;
                            
                            tmDataToUpsert.Story_Employee_Association__c = seasRecordsMap.get(stKeyMap).Id;
                            
                            tmDataToUpsert.Bureau__c = bureausMap.get(str.News_Bureau__c.toUppercase()).Id;
                            tmDataToUpsert.Date__c = str.Work_Date__c;
                            tmDataToUpsert.Earnings_Code__c = str.Earnings_Code__c;
                            tmDataToUpsert.Employee__c = seasRecordsMap.get(stKeyMap).Employee__c;
                            tmDataToUpsert.Year__c = str.Year__c;
                            tmDataToUpsert.Foreign_Rates__c = str.Foreign_Rates__c != null ? (str.Foreign_Rates__c/8):0;
                            tmDataToUpsert.Gross_Pay__c = str.Gross_Pay__c;
                            tmDataToUpsert.Holiday_Pay_100__c = str.Holiday_Pay_100__c;
                            tmDataToUpsert.Holiday_Pay_200__c = str.Holiday_Pay_200__c;
                            tmDataToUpsert.Holiday_Pay_50__c = str.Holiday_Pay_50__c;
                            tmDataToUpsert.Hours__c = str.Hours__c;
                            tmDataToUpsert.Internal_Notes__c = str.Internal_Notes__c;
                            tmDataToUpsert.Meal_Penalties__c = str.Meal_Penalties__c;
                            tmDataToUpsert.Missed_Meal__c = str.Missed_Meal__c;
                            tmDataToUpsert.Network_ID__c = str.Network_ID__c;
                            tmDataToUpsert.Night_Differential__c = str.Night_Differential__c;
                            tmDataToUpsert.Out_of_Town_Flat_Time__c = str.Out_of_Town_Flat_Time__c;
                            tmDataToUpsert.Over_Time__c = str.Over_Time__c;
                            tmDataToUpsert.PayRate_OVR__c = str.PayRate_OVR__c;
                            tmDataToUpsert.Penalty_Time__c = str.Penalty_Time__c;
                            tmDataToUpsert.Rest_Penalty__c = str.Rest_Penalty__c;
                            tmDataToUpsert.Show__c = str.Show__c;
                            tmDataToUpsert.Straight_Time__c = str.Straight_Time__c;
                            tmDataToUpsert.Vacation_Allowance__c = str.Vacation_Allowance__c;
                            tmDataToUpsert.Overnight__c = str.Overnight__c;
                            tmDataToUpsert.Premium_Time__c = str.Premium_Time__c;
                            tmDataToUpsert.Fees__c = str.Fees__c;
                            string empType = employeeTypesMap.get(str.Employee_Type__c);
                            if(empType == 'Freelancer') {
                                tmDataToUpsert.Fringe__c  = rate.Fringe__c;
                            }
                            if(empType == 'Freelancer' && rate.Fringe__c != null && rate.Fringe__c != 0) {
                                if(str.Paid_Time_Off__c == true)
                                    tmDataToUpsert.Straight_Time_Cost__c = null;
                                else{
                                    if(str.Straight_Time_Cost__c != null)
                                        tmDataToUpsert.Straight_Time_Cost__c = str.Straight_Time_Cost__c * (1+(rate.Fringe__c/100));
                                    else
                                    {
                                        if(str.Straight_Time__c!=null)
                                            tmDataToUpsert.Straight_Time_Cost__c = (str.Straight_Time__c * (rate.Straight_Time__c == null ? 0 : rate.Straight_Time__c)) * (1 + (rate.Fringe__c / 100));
                                    }
                                }
                                if(str.Vacation_Allowance_Cost__c != null)
                                    tmDataToUpsert.Vacation_Allowance_Cost__c = str.Vacation_Allowance_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Vacation_Allowance__c!=null)
                                        tmDataToUpsert.Vacation_Allowance_Cost__c = (str.Vacation_Allowance__c * (rate.Vacation_Allowance__c == null ? 0 : rate.Vacation_Allowance__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Foreign_Rates_Cost__c != null)
                                    tmDataToUpsert.Foreign_Rates_Cost__c = str.Foreign_Rates_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Foreign_Rates__c!=null)
                                        tmDataToUpsert.Foreign_Rates_Cost__c = ((str.Foreign_Rates__c/8) * (rate.Foreign_Rates__c == null ? 0 : rate.Foreign_Rates__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Holiday_Pay_50_Cost__c != null)
                                    tmDataToUpsert.Holiday_Pay_50_Cost__c = str.Holiday_Pay_50_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Holiday_Pay_50__c!=null)
                                        tmDataToUpsert.Holiday_Pay_50_Cost__c = (str.Holiday_Pay_50__c * (rate.Holiday_Pay_50__c == null ? 0 : rate.Holiday_Pay_50__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Holiday_Pay_100_Cost__c != null)
                                    tmDataToUpsert.Holiday_Pay_100_Cost__c = str.Holiday_Pay_100_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Holiday_Pay_100__c!=null)
                                        tmDataToUpsert.Holiday_Pay_100_Cost__c = (str.Holiday_Pay_100__c * (rate.Holiday_Pay_100__c == null ? 0 : rate.Holiday_Pay_100__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Holiday_Pay_200_Cost__c != null)
                                    tmDataToUpsert.Holiday_Pay_200_Cost__c = str.Holiday_Pay_200_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Holiday_Pay_200__c!=null)
                                        tmDataToUpsert.Holiday_Pay_200_Cost__c = (str.Holiday_Pay_200__c * (rate.Holiday_Pay_200__c == null ? 0 : rate.Holiday_Pay_200__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Rest_Penalty_Cost__c != null)
                                    tmDataToUpsert.Rest_Penalty_Cost__c = str.Rest_Penalty_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Rest_Penalty__c!=null)
                                        tmDataToUpsert.Rest_Penalty_Cost__c = (str.Rest_Penalty__c * (rate.Rest_Penalty__c == null ? 0 : rate.Rest_Penalty__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Over_Time_Cost__c != null)
                                    tmDataToUpsert.Over_Time_Cost__c = str.Over_Time_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Over_Time__c!=null)
                                        tmDataToUpsert.Over_Time_Cost__c = (str.Over_Time__c * (rate.Over_Time_Rate__c == null ? 0 : rate.Over_Time_Rate__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Night_Differential_Cost__c != null)
                                    tmDataToUpsert.Night_Differential_Cost__c = str.Night_Differential_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Night_Differential__c!=null)
                                        tmDataToUpsert.Night_Differential_Cost__c = (str.Night_Differential__c * (rate.Night_Differential__c == null ? 0 : rate.Night_Differential__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Meal_Penalties_Cost__c != null)
                                    tmDataToUpsert.Meal_Penalties_Cost__c = str.Meal_Penalties_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Meal_Penalties__c!=null)
                                        tmDataToUpsert.Meal_Penalties_Cost__c = (str.Meal_Penalties__c * (rate.Meal_Penalties__c == null ? 0 : rate.Meal_Penalties__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Penalty_Time_Cost__c != null)
                                    tmDataToUpsert.Penalty_Time_Cost__c = str.Penalty_Time_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Penalty_Time__c!=null)
                                        tmDataToUpsert.Penalty_Time_Cost__c = (str.Penalty_Time__c * (rate.Penalty_Rate__c == null ? 0 : rate.Penalty_Rate__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Overnight_Cost__c != null)
                                    tmDataToUpsert.Overnight_Cost__c = str.Overnight_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Overnight__c!=null)
                                        tmDataToUpsert.Overnight_Cost__c = (str.Overnight__c * (rate.Overnight__c == null ? 0 : rate.Overnight__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Premium_Time_Cost__c != null)
                                    tmDataToUpsert.Premium_Time_Cost__c = str.Premium_Time_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Premium_Time__c!=null)
                                        tmDataToUpsert.Premium_Time_Cost__c = (str.Premium_Time__c * (rate.Premium_Time__c == null ? 0 : rate.Premium_Time__c)) * (1 + (rate.Fringe__c / 100));
                                }
                                if(str.Out_of_Town_Flat_Day_Cost__c != null)
                                    tmDataToUpsert.Out_of_Town_Flat_Day_Cost__c = str.Out_of_Town_Flat_Day_Cost__c * (1+(rate.Fringe__c/100));
                                else
                                {
                                    if(str.Out_of_Town_Flat_Time__c!=null)
                                        tmDataToUpsert.Out_of_Town_Flat_Day_Cost__c = (str.Out_of_Town_Flat_Time__c * (rate.Out_of_Town_Flat_Day_rate__c == null ? 0 : rate.Out_of_Town_Flat_Day_rate__c)) * (1 + (rate.Fringe__c / 100));
                                }
                            } 
                            else {
                                if(str.Straight_Time_Cost__c != null && str.Paid_Time_Off__c == false)
                                    tmDataToUpsert.Straight_Time_Cost__c = str.Straight_Time_Cost__c;
                                else
                                {
                                    if(str.Straight_Time__c!=null && str.Paid_Time_Off__c == false)
                                        tmDataToUpsert.Straight_Time_Cost__c = (str.Straight_Time__c * (rate.Straight_Time__c == null ? 0 : rate.Straight_Time__c));
                                }
                                if(str.Vacation_Allowance_Cost__c != null)
                                    tmDataToUpsert.Vacation_Allowance_Cost__c = str.Vacation_Allowance_Cost__c;
                                else
                                {
                                    if(str.Vacation_Allowance__c!=null)
                                        tmDataToUpsert.Vacation_Allowance_Cost__c = (str.Vacation_Allowance__c * (rate.Vacation_Allowance__c == null ? 0 : rate.Vacation_Allowance__c));
                                }
                                if(str.Foreign_Rates_Cost__c != null)
                                    tmDataToUpsert.Foreign_Rates_Cost__c = str.Foreign_Rates_Cost__c;
                                else
                                {
                                    if(str.Foreign_Rates__c!=null)
                                        tmDataToUpsert.Foreign_Rates_Cost__c = ((str.Foreign_Rates__c/8) * (rate.Foreign_Rates__c == null ? 0 : rate.Foreign_Rates__c));
                                }
                                if(str.Holiday_Pay_50_Cost__c != null)
                                    tmDataToUpsert.Holiday_Pay_50_Cost__c = str.Holiday_Pay_50_Cost__c;
                                else
                                {
                                    if(str.Holiday_Pay_50__c!=null)
                                        tmDataToUpsert.Holiday_Pay_50_Cost__c = (str.Holiday_Pay_50__c * (rate.Holiday_Pay_50__c == null ? 0 : rate.Holiday_Pay_50__c));
                                }
                                if(str.Holiday_Pay_100_Cost__c != null)
                                    tmDataToUpsert.Holiday_Pay_100_Cost__c = str.Holiday_Pay_100_Cost__c;
                                else
                                {
                                    if(str.Holiday_Pay_100__c!=null)
                                        tmDataToUpsert.Holiday_Pay_100_Cost__c = (str.Holiday_Pay_100__c * (rate.Holiday_Pay_100__c == null ? 0 : rate.Holiday_Pay_100__c));
                                }
                                if(str.Holiday_Pay_200_Cost__c != null)
                                    tmDataToUpsert.Holiday_Pay_200_Cost__c = str.Holiday_Pay_200_Cost__c;
                                else
                                {
                                    if(str.Holiday_Pay_200__c!=null)
                                        tmDataToUpsert.Holiday_Pay_200_Cost__c = (str.Holiday_Pay_200__c * (rate.Holiday_Pay_200__c == null ? 0 : rate.Holiday_Pay_200__c));
                                }
                                if(str.Rest_Penalty_Cost__c != null)
                                    tmDataToUpsert.Rest_Penalty_Cost__c = str.Rest_Penalty_Cost__c;
                                else
                                {
                                    if(str.Rest_Penalty__c!=null)
                                        tmDataToUpsert.Rest_Penalty_Cost__c = (str.Rest_Penalty__c * (rate.Rest_Penalty__c == null ? 0 : rate.Rest_Penalty__c));
                                }
                                if(str.Over_Time_Cost__c != null)
                                    tmDataToUpsert.Over_Time_Cost__c = str.Over_Time_Cost__c;
                                else
                                {
                                    if(str.Over_Time__c!=null)
                                        tmDataToUpsert.Over_Time_Cost__c = (str.Over_Time__c * (rate.Over_Time_Rate__c == null ? 0 : rate.Over_Time_Rate__c));
                                }
                                if(str.Night_Differential_Cost__c != null)
                                    tmDataToUpsert.Night_Differential_Cost__c = str.Night_Differential_Cost__c;
                                else
                                {
                                    if(str.Night_Differential__c!=null)
                                        tmDataToUpsert.Night_Differential_Cost__c = (str.Night_Differential__c * (rate.Night_Differential__c == null ? 0 : rate.Night_Differential__c));
                                }
                                if(str.Meal_Penalties_Cost__c != null)
                                    tmDataToUpsert.Meal_Penalties_Cost__c = str.Meal_Penalties_Cost__c;
                                else
                                {
                                    if(str.Meal_Penalties__c!=null)
                                        tmDataToUpsert.Meal_Penalties_Cost__c = (str.Meal_Penalties__c * (rate.Meal_Penalties__c == null ? 0 : rate.Meal_Penalties__c));
                                }
                                if(str.Penalty_Time_Cost__c != null)
                                    tmDataToUpsert.Penalty_Time_Cost__c = str.Penalty_Time_Cost__c;
                                else
                                {
                                    if(str.Penalty_Time__c!=null)
                                        tmDataToUpsert.Penalty_Time_Cost__c = (str.Penalty_Time__c * (rate.Penalty_Rate__c == null ? 0 : rate.Penalty_Rate__c));
                                }
                                if(str.Overnight_Cost__c != null)
                                    tmDataToUpsert.Overnight_Cost__c = str.Overnight_Cost__c;
                                else
                                {
                                    if(str.Overnight__c!=null)
                                        tmDataToUpsert.Overnight_Cost__c = (str.Overnight__c * (rate.Overnight__c == null ? 0 : rate.Overnight__c));
                                }
                                if(str.Premium_Time_Cost__c != null)
                                    tmDataToUpsert.Premium_Time_Cost__c = str.Premium_Time_Cost__c;
                                else
                                {
                                    if(str.Premium_Time__c!=null)
                                        tmDataToUpsert.Premium_Time_Cost__c = (str.Premium_Time__c * (rate.Premium_Time__c == null ? 0 : rate.Premium_Time__c));
                                }
                                if(str.Out_of_Town_Flat_Day_Cost__c != null)
                                    tmDataToUpsert.Out_of_Town_Flat_Day_Cost__c = str.Out_of_Town_Flat_Day_Cost__c;
                                else
                                {
                                    if(str.Out_of_Town_Flat_Time__c!=null)
                                        tmDataToUpsert.Out_of_Town_Flat_Day_Cost__c = (str.Out_of_Town_Flat_Time__c * (rate.Out_of_Town_Flat_Day_rate__c == null ? 0 : rate.Out_of_Town_Flat_Day_rate__c));
                                }
                            }
                            
                            tmDataToUpsert.WFS_Sourced__c = true;
                            tmDataToUpsert.Paid_Time_Off__c = str.Paid_Time_Off__c;
                            tmRecordsUpsert.add(tmDataToUpsert);
                            
                            stDataToUpdate.Id = str.Id;
                            stDataToUpdate.Error_Code__c = null;
                            stDataToUpdate.Error_Message__c = null;
                            stDataToUpdate.Status__c = 'Finished';
                            stRecordsUpdate.add(stDataToUpdate);
                        }
                    }
                    else {
                        if(tmWithStoryRecordsMap.containsKey(tmNewKey)){
                            tmDataToUpsert.Id = tmWithStoryRecordsMap.get(tmNewKey).Id;
                            tmDataToUpsert.Automated_Process__c = True;
                            
                            tmDataToUpsert.CostCenter__c = seasRecordsMap.get(stKeyMap).Story_Schedule_Association__r.Cost_Center__c;
                            tmDataToUpsert.Story__c = seasRecordsMap.get(stKeyMap).Story_Schedule_Association__r.Story__c;
                            tmDataToUpsert.Story_Employee_Association__c = seasRecordsMap.get(stKeyMap).Id;
                            
                            tmDataToUpsert.Bureau__c = bureausMap.get(str.News_Bureau__c.toUppercase()).Id;
                            tmDataToUpsert.Date__c = str.Work_Date__c;
                            tmDataToUpsert.Employee__c = seasRecordsMap.get(stKeyMap).Employee__c;
                            tmDataToUpsert.Foreign_Rates__c = str.Foreign_Rates__c != null ? (str.Foreign_Rates__c/8):0;
                            tmDataToUpsert.Gross_Pay__c = str.Gross_Pay__c;
                            tmDataToUpsert.Holiday_Pay_100__c = str.Holiday_Pay_100__c;
                            tmDataToUpsert.Holiday_Pay_200__c = str.Holiday_Pay_200__c;
                            tmDataToUpsert.Holiday_Pay_50__c = str.Holiday_Pay_50__c;
                            tmDataToUpsert.Hours__c = str.Hours__c;
                            tmDataToUpsert.Internal_Notes__c = str.Internal_Notes__c;
                            tmDataToUpsert.Meal_Penalties__c = str.Meal_Penalties__c;
                            tmDataToUpsert.Missed_Meal__c = str.Missed_Meal__c;
                            tmDataToUpsert.Network_ID__c = str.Network_ID__c;
                            tmDataToUpsert.Night_Differential__c = str.Night_Differential__c;
                            tmDataToUpsert.Out_of_Town_Flat_Time__c = str.Out_of_Town_Flat_Time__c;
                            tmDataToUpsert.Over_Time__c = str.Over_Time__c;
                            tmDataToUpsert.PayRate_OVR__c = str.PayRate_OVR__c;
                            tmDataToUpsert.Penalty_Time__c = str.Penalty_Time__c;
                            tmDataToUpsert.Rest_Penalty__c = str.Rest_Penalty__c;
                            tmDataToUpsert.Show__c = str.Show__c;
                            tmDataToUpsert.Straight_Time__c = str.Straight_Time__c;
                            tmDataToUpsert.Vacation_Allowance__c = str.Vacation_Allowance__c;
                            tmDataToUpsert.Overnight__c = str.Overnight__c;
                            tmDataToUpsert.Premium_Time__c = str.Premium_Time__c;
                            tmDataToUpsert.Fees__c = str.Fees__c;
                            if(str.Paid_Time_Off__c == false)
                                tmDataToUpsert.Straight_Time_Cost__c = str.Straight_Time_Cost__c ;
                            tmDataToUpsert.Vacation_Allowance_Cost__c = str.Vacation_Allowance_Cost__c;
                            tmDataToUpsert.Foreign_Rates_Cost__c = str.Foreign_Rates_Cost__c;
                            tmDataToUpsert.Holiday_Pay_50_Cost__c = str.Holiday_Pay_50_Cost__c;
                            tmDataToUpsert.Holiday_Pay_100_Cost__c = str.Holiday_Pay_100_Cost__c;
                            tmDataToUpsert.Holiday_Pay_200_Cost__c = str.Holiday_Pay_200_Cost__c;
                            tmDataToUpsert.Rest_Penalty_Cost__c = str.Rest_Penalty_Cost__c;
                            tmDataToUpsert.Over_Time_Cost__c = str.Over_Time_Cost__c;
                            tmDataToUpsert.Night_Differential_Cost__c = str.Night_Differential_Cost__c;
                            tmDataToUpsert.Meal_Penalties_Cost__c = str.Meal_Penalties_Cost__c;
                            tmDataToUpsert.Penalty_Time_Cost__c = str.Penalty_Time_Cost__c;
                            tmDataToUpsert.Overnight_Cost__c = str.Overnight_Cost__c;
                            tmDataToUpsert.Premium_Time_Cost__c = str.Premium_Time_Cost__c;
                            tmDataToUpsert.Out_of_Town_Flat_Day_Cost__c = str.Out_of_Town_Flat_Day_Cost__c;
                            
                            tmDataToUpsert.WFS_Sourced__c = true;
                            tmDataToUpsert.Paid_Time_Off__c = str.Paid_Time_Off__c;
                            tmRecordsUpsert.add(tmDataToUpsert);
                            
                            stDataToUpdate.Id = str.Id;
                            stDataToUpdate.Error_Code__c = null;
                            stDataToUpdate.Error_Message__c = null;
                            stDataToUpdate.Status__c = 'Finished';
                            stRecordsUpdate.add(stDataToUpdate);
                        }
                        //If there's NO match, creates a Timesheet.
                        else {
                            tmDataToUpsert.Id = null;
                            tmDataToUpsert.Automated_Process__c = True;
                            
                            if(alltmWithStoryRecordsMap.containsKey(tmNewKey))
                            {
                                tmDataToUpsert.Story__c = alltmWithStoryRecordsMap.get(tmNewKey).Story__c;
                                tmDataToUpsert.CostCenter__c = alltmWithStoryRecordsMap.get(tmNewKey).CostCenter__c;
                            }
                            else
                            {
                                tmDataToUpsert.Story__c = seasRecordsMap.get(stKeyMap).Story_Schedule_Association__r.Story__c;
                                tmDataToUpsert.CostCenter__c = seasRecordsMap.get(stKeyMap).Story_Schedule_Association__r.Cost_Center__c;
                            }
                            
                            tmDataToUpsert.Story_Employee_Association__c = seasRecordsMap.get(stKeyMap).Id;
                            
                            tmDataToUpsert.Bureau__c = bureausMap.get(str.News_Bureau__c.toUppercase()).Id;
                            tmDataToUpsert.Date__c = str.Work_Date__c;
                            tmDataToUpsert.Earnings_Code__c = str.Earnings_Code__c;
                            tmDataToUpsert.Employee__c = seasRecordsMap.get(stKeyMap).Employee__c;
                            tmDataToUpsert.Year__c = str.Year__c;
                            tmDataToUpsert.Foreign_Rates__c = str.Foreign_Rates__c != null ? (str.Foreign_Rates__c/8):0;
                            tmDataToUpsert.Gross_Pay__c = str.Gross_Pay__c;
                            tmDataToUpsert.Holiday_Pay_100__c = str.Holiday_Pay_100__c;
                            tmDataToUpsert.Holiday_Pay_200__c = str.Holiday_Pay_200__c;
                            tmDataToUpsert.Holiday_Pay_50__c = str.Holiday_Pay_50__c;
                            tmDataToUpsert.Hours__c = str.Hours__c;
                            tmDataToUpsert.Internal_Notes__c = str.Internal_Notes__c;
                            tmDataToUpsert.Meal_Penalties__c = str.Meal_Penalties__c;
                            tmDataToUpsert.Missed_Meal__c = str.Missed_Meal__c;
                            tmDataToUpsert.Network_ID__c = str.Network_ID__c;
                            tmDataToUpsert.Night_Differential__c = str.Night_Differential__c;
                            tmDataToUpsert.Out_of_Town_Flat_Time__c = str.Out_of_Town_Flat_Time__c;
                            tmDataToUpsert.Over_Time__c = str.Over_Time__c;
                            tmDataToUpsert.PayRate_OVR__c = str.PayRate_OVR__c;
                            tmDataToUpsert.Penalty_Time__c = str.Penalty_Time__c;
                            tmDataToUpsert.Rest_Penalty__c = str.Rest_Penalty__c;
                            tmDataToUpsert.Show__c = str.Show__c;
                            tmDataToUpsert.Straight_Time__c = str.Straight_Time__c;
                            tmDataToUpsert.Vacation_Allowance__c = str.Vacation_Allowance__c;
                            tmDataToUpsert.Overnight__c = str.Overnight__c;
                            tmDataToUpsert.Premium_Time__c = str.Premium_Time__c;
                            tmDataToUpsert.Fees__c = str.Fees__c;
                            if(str.Paid_Time_Off__c == false)
                                tmDataToUpsert.Straight_Time_Cost__c = str.Straight_Time_Cost__c ;
                            tmDataToUpsert.Vacation_Allowance_Cost__c = str.Vacation_Allowance_Cost__c;
                            tmDataToUpsert.Foreign_Rates_Cost__c = str.Foreign_Rates_Cost__c;
                            tmDataToUpsert.Holiday_Pay_50_Cost__c = str.Holiday_Pay_50_Cost__c;
                            tmDataToUpsert.Holiday_Pay_100_Cost__c = str.Holiday_Pay_100_Cost__c;
                            tmDataToUpsert.Holiday_Pay_200_Cost__c = str.Holiday_Pay_200_Cost__c;
                            tmDataToUpsert.Rest_Penalty_Cost__c = str.Rest_Penalty_Cost__c;
                            tmDataToUpsert.Over_Time_Cost__c = str.Over_Time_Cost__c;
                            tmDataToUpsert.Night_Differential_Cost__c = str.Night_Differential_Cost__c;
                            tmDataToUpsert.Meal_Penalties_Cost__c = str.Meal_Penalties_Cost__c;
                            tmDataToUpsert.Penalty_Time_Cost__c = str.Penalty_Time_Cost__c;
                            tmDataToUpsert.Overnight_Cost__c = str.Overnight_Cost__c;
                            tmDataToUpsert.Premium_Time_Cost__c = str.Premium_Time_Cost__c;
                            tmDataToUpsert.Out_of_Town_Flat_Day_Cost__c = str.Out_of_Town_Flat_Day_Cost__c;
                            
                            tmDataToUpsert.WFS_Sourced__c = true;
                            tmDataToUpsert.Paid_Time_Off__c = str.Paid_Time_Off__c;
                            tmRecordsUpsert.add(tmDataToUpsert);
                            
                            stDataToUpdate.Id = str.Id;
                            stDataToUpdate.Error_Code__c = null;
                            stDataToUpdate.Error_Message__c = null;
                            stDataToUpdate.Status__c = 'Finished';
                            stRecordsUpdate.add(stDataToUpdate);
                        }
                    }
                    
                } else {
                    stDataToUpdate.Id = str.Id;
                    stDataToUpdate.Error_Code__c = 500;
                    stDataToUpdate.Error_Message__c = 'Corresponding assignment cannot be found.';
                    stRecordsUpdate.add(stDataToUpdate);
                }
            }
        }
        for(Staging_Table__c rec : stRecordsUpdate ){
            if(rec.isDeleted) {
                stRecordsUpdate.remove(stRecordsUpdate.indexOf(rec));
            }
        }
        List<Database.SaveResult> updateResult = Database.update(stRecordsUpdate, false);
        for (Database.SaveResult result : updateResult) {
            if(result.isSuccess() == false) {
                System.debug('Staging Table record expected update failure : ' + result);
            }
        }
        return tmRecordsUpsert;
    }
    
    public static void onBeforeUpdate(List<Staging_Table__c> newRecords) {
        validate200ErrorReprocess(newRecords);
        validate500ErrorReprocess(newRecords);
    }
    
    private static void validate200ErrorReprocess(List<Staging_Table__c> newRecords) {
        
        for(Staging_Table__c st : newRecords) {
            if(
                st.News_Bureau__c != null &&
                st.Error_Code__c == 200 
            ){
                st.Reprocess__c = true;
            }
        }
        
    }
    
    private static void validate500ErrorReprocess(List<Staging_Table__c> newRecords) {
        
        for(Staging_Table__c st : newRecords) {
            if(
                st.Assignment_Information__c != null &&
                st.Location__c != null &&
                st.Story__c != null &&
                st.Cost_Center__c != null &&
                st.Error_Code__c == 500
            ){
                st.Reprocess__c = true;
            }     
        }
    }

    public class CreateStryEmpA {
        private string schedule;
        private string storySchedule;
        private Story_Schedule_Association__c storyScheduleAcc;
        private ScheduleAssociation__c storyEmployeeAcc;
    }
    
}