global class RunAutoLaunchedFlow implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Access the Flow named "ACAL_SUB_Refresh_Public_Holidays_Events"
        Flow.Interview.ACAL_SUB_Refresh_Public_Holidays_Events flow = 
            new Flow.Interview.ACAL_SUB_Refresh_Public_Holidays_Events(
                new Map<String, Object>{
                    'storeHolidaysForNextXYears_in' => 3});

        // Start flow
        flow.start();
    }
}