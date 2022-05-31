public class DateUtilities {
	
	public static List<Holiday> Holiday_List {get; set;}
	public static Map<integer, string> MonthNumberToMonthName_Map {get; set;}
	public static Map<string, integer> RecurrenceInstanceToOccurenceNumber_Map {get; set;}
	public static Map<integer, string> DayOfWeekMaskNumberToDayOfHoliday_Map {get; set;}
	
	
	/** Manage holidays from the Holiday sfdc standard object. Holidays have to be configured for this method to work correctly. **/
	public static void initHolidaysVariables(){
		
		Holiday_List = [select h.Name, h.RecurrenceType, h.RecurrenceStartDate, h.RecurrenceMonthOfYear, h.RecurrenceInstance, h.RecurrenceDayOfWeekMask, h.IsRecurrence, h.IsAllDay, h.ActivityDate 
							from Holiday h];
		
		System.debug( '## Holiday_List :  ' + Holiday_List);
		
		MonthNumberToMonthName_Map = new Map<integer, string>{
			1 =>'January',
			2 =>'February',
			3 =>'March',
			4 =>'April',
			5 =>'May',
			6 =>'June',
			7 =>'July',
			8 =>'August',
			9 =>'September',
			10=>'October',
			11=>'November',
			12=>'December'
		};
	
		RecurrenceInstanceToOccurenceNumber_Map = new Map<string, integer>{
			'First' =>1,
			'Second'=>2,
			'Third' =>3,
			'Fourth'=>4
		};
	
		DayOfWeekMaskNumberToDayOfHoliday_Map = new Map<integer, string>{
			1 =>'Sun',
			2 =>'Mon',
			4 =>'Tue',
			8 =>'Wed',
			16=>'Thu',
			32=>'Fri',
			64=>'Sat'
		};
		
	}
	
	
	/** This method calculates the fields based on the category SLA (BobTimer) **/
	public static void calculateWorkingDaysOnListOfCases(List<Case> lRecordsToUpdate){
		
		Date tempDate;
		Integer tempCategoryDays;
		Integer tempWorkingDaysBetweenDates;
		
		for(Case oCase : lRecordsToUpdate){
            tempDate = (oCase.CreatedDate != null) ? oCase.CreatedDate.date() : Date.today();
            tempCategoryDays = (oCase.CategorySLA__c != null) ? Integer.valueof(oCase.CategorySLA__c) : 0;
			
			// Communicated BobTimer due date
			oCase.Communicated_Due_Date__c = addWorkingDaysToDate( tempDate, tempCategoryDays );
			// Time between promise and reality = number of days between Communicated Bob Timer due date and the first outgoing interaction
			if( oCase.F_ClientFirstInteractionDate__c != null && oCase.Communicated_Due_Date__c != null ){
				tempWorkingDaysBetweenDates = getWorkingDaysBetweenDates(oCase.Communicated_Due_Date__c, oCase.F_ClientFirstInteractionDate__c.date());
				//oCase.Time_Between_Promise_And_Reality__c = tempWorkingDaysBetweenDates == 0 ? null : tempWorkingDaysBetweenDates;
				oCase.Time_Between_Promise_And_Reality__c = tempWorkingDaysBetweenDates;
			// If no first outgoing interaction, we'll compare with the case Closed Date if Closed Date is not null
			}else if( oCase.F_ClientFirstInteractionDate__c == null && oCase.ClosedDate != null && oCase.Communicated_Due_Date__c != null ){
				tempWorkingDaysBetweenDates = getWorkingDaysBetweenDates(oCase.Communicated_Due_Date__c, oCase.ClosedDate.date());
				//oCase.Time_Between_Promise_And_Reality__c = tempWorkingDaysBetweenDates == 0 ? null : tempWorkingDaysBetweenDates;
				oCase.Time_Between_Promise_And_Reality__c = tempWorkingDaysBetweenDates;
			}else{
				oCase.Time_Between_Promise_And_Reality__c = null;
			}
			// Duration in working days
			if(oCase.ClosedDate != null){
				oCase.Duration_In_Working_Days__c = getWorkingDaysBetweenDates(tempDate, oCase.ClosedDate.date());
			}else{
				oCase.Duration_In_Working_Days__c = getWorkingDaysBetweenDates(tempDate, Date.today());
			}
		}
		
	}
	
	
	/** This method returns a date calculated from the date passed in parameter to which a number of working days are added **/
	public static Date addWorkingDaysToDate(Date startDate, Integer numberOfDaysToAdd){
		Date dateToReturn = startDate;
		Integer numberOfWorkingDays = 0;
		
		for (Integer i = 1; numberOfWorkingDays < numberOfDaysToAdd; i++){
			dateToReturn = dateToReturn + 1;
			
			if( !isWeekEndDay(dateToReturn) && !isHoliday(dateToReturn) ){
				numberOfWorkingDays++;
			}
		}
		return dateToReturn;
	}
	
	
	/** This method returns a number of working days calculated between the dates passed in parameter, excluding week-ends and holidays **/
	public static Integer getWorkingDaysBetweenDates(Date startDate, Date endDate){
		Date tempStartDate = ( endDate >= startDate ) ? startDate : endDate;
		Date tempEndDate = ( endDate >= startDate ) ? endDate : startDate;
		Date tempDate = tempStartDate;
		Integer numberOfWorkingDays = 0;
		
		for (Integer i = 0; i < tempStartDate.daysBetween(tempEndDate); i++){
			tempDate = tempDate + 1;
			
			if( !isWeekEndDay(tempDate) && !isHoliday(tempDate) ){
				numberOfWorkingDays++;
			}
		}
		if (startDate >= endDate) numberOfWorkingDays = numberOfWorkingDays * -1;
		return numberOfWorkingDays;
	}
	
	
	/** Returns true if date during a week-end, false otherwise **/
	public static Boolean isWeekEndDay(Date dateToCheck){
		Set<integer> WeekendDay_Set;
		
		// Saturday and Sunday are the weekend
		String StartOfWeek = getFormattedDate( Date.today().toStartOfWeek(), 'EEE' );
		if( StartOfWeek == 'Sun' ){
			WeekendDay_Set = new Set<integer>{6,0}; // Sat, Sun
		}else{
			WeekendDay_Set = new Set<integer>{5,6}; // Sat, Sun
		}
		
		if( WeekendDay_Set.contains( dateToCheck.toStartofWeek().daysBetween(dateToCheck) ) ){
			// Saturday or Sunday
			return true;
		}
		return false;
	}
	
	
	/** Returns true if date during holidays, false otherwise **/
	public static Boolean isHoliday(Date dateToCheck){
		
		if( Holiday_List == null ) initHolidaysVariables();
		
		for(Holiday HolidayObj : Holiday_List){
			if( HolidayObj.IsAllDay ){
				if( !HolidayObj.IsRecurrence ){   // Variable Holidays like 'Easter Monday'
					if( dateToCheck.isSameDay(HolidayObj.ActivityDate) ){
						System.debug( '## ' + HolidayObj.Name + ' occurred on the ' + dateToCheck.format() );
						return true;
					}
				}else if( HolidayObj.IsRecurrence ){
					if( HolidayObj.RecurrenceType == 'RecursYearly' ){   // Annual Holidays like 'Christmas Day' and 'New Year'
						if( dateToCheck.month() == HolidayObj.RecurrenceStartDate.month() && dateToCheck.day() == HolidayObj.RecurrenceStartDate.day() ){
							System.debug( '## ' + HolidayObj.Name + ' occurred on the ' + dateToCheck.format() );
							return true;
						}
					}
					/*else if( HolidayObj.RecurrenceType == 'RecursYearlyNth' ){   // 1st Monday in June or 4th Monday in October for instance, no use case in France
						if( MonthNumberToMonthName_Map.get(dateToCheck.month()) == HolidayObj.RecurrenceMonthOfYear ){
							if( RecurrenceInstanceToOccurenceNumber_Map.containsKey(HolidayObj.RecurrenceInstance) ){
								
								Integer OccurenceNumber = RecurrenceInstanceToOccurenceNumber_Map.get( HolidayObj.RecurrenceInstance );
								Date StartOfCurrentMonth = dateToCheck.toStartOfMonth();
								Date WeekOfHoliday = StartOfCurrentMonth.addDays( (OccurenceNumber-1)*7 ); // Add Weeks
								String DayOfHoliday = DayOfWeekMaskNumberToDayOfHoliday_Map.get(HolidayObj.RecurrenceDayOfWeekMask);
								for(Integer i=0; i<7; i++){ // Check the week
									if( getFormattedDate(WeekOfHoliday.addDays(i), 'EEE') == DayOfHoliday && WeekOfHoliday.addDays(i) == dateToCheck ){
										System.debug( '## ' + HolidayObj.Name + ' occurred on the ' + dateToCheck.format() );
										return true;
									}
								}
							}else{   // Last Monday in May for instance
								// Need to manage if a use case is added for France
							}
						}
					}*/
					else{
						// Isn't a holiday, only yearly holidays are considered
					}
				}
			}else{
				// Isn't a holiday, only full days are considered
			}
		}
		
		return false;
	}
	
	
	private static String getFormattedDate( Date DateObj, String FormatString ){
		// http://docs.oracle.com/javase/1.4.2/docs/api/java/text/SimpleDateFormat.html
		return DateTime.newInstance(DateObj, Time.newInstance(0, 0, 0, 0)).format( FormatString );
	}
	
	
	/** This method returns a number of minutes calculated between the dates passed in parameter, based on SFDC Standard Business Hours object excluding week-ends and holidays **/
	public static Long getGapInMinutes(Datetime startDateTime, Datetime endDateTime){
		
		Id businessHoursId = [select Id, Name from BusinessHours where IsActive = true and IsDefault = true ].Id;
		DateTime dateTime1 = startDateTime;    // Datetime.valueOf('2019-12-13 12:00:00')
		DateTime dateTime2 = endDateTime;    // Datetime.valueOf('2019-12-16 11:00:00')
		Long minutes = Math.abs(BusinessHours.diff(businessHoursId,dateTime1,dateTime2)/1000/60);
		//Long hours = Math.abs(BusinessHours.diff(businessHoursId,dateTime1,dateTime2)/1000/60/60);
		//Decimal days = hours / 24.0;
		
		return minutes;
	}
	
}