global class DeleteBenefitLoggerSchedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        DeleteBenefitLoggerBatch delLogs = new DeleteBenefitLoggerBatch();
        database.executeBatch(delLogs, 200);
    }

}