public class RemindersSchedule implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new Reminders7DailyBatch());
    }

}