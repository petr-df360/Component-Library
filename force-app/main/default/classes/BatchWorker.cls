/**
* Copyright (c) 2013, Andrew Fawcett
* All rights reserved
**/

public abstract with sharing class BatchWorker implements Database.Batchable<Object>
{
    private List<Object> workList;
    public Id batchJobId {get; private set;}
    public Integer batchSize {get; set;}
    
    public BatchWorker()
    {
        this.workList = new List<Object>();
    }
    
    public BatchWorker(List<Object> workList)
    {
        this.workList = workList;
    }
    
    public BatchWorker addWork(Object work)
    {
        workList.add(work);
        return this;
    }
    
    public abstract void doWork(Object work);
    
    public BatchWorker run(Integer size)
    {
        batchJobId = Database.executeBatch(this, size);
        return this;    
    }
    
     public BatchWorker run()
    {
        batchJobId = Database.executeBatch(this, 2000);
        return this;
    }
    
    public Iterable<Object> start(Database.BatchableContext BC) { return workList; }
    
    public void execute(Database.BatchableContext info, List<Object> workList) {
        doWork(workList[0]);        
    }
        
    public void finish(Database.BatchableContext info) {
        if(workList!= null && workList.size()>0){
            this.workList.remove(0);
            System.debug('Finishing serial BatchWorker Job. Remaining: ' + workList.size());
        }
        
        if(workList != null && workList.size()>0) {
            batchJobId = Database.executeBatch(this, 2000);
        }else{
            System.debug('All batch jobs executed & finished in serial mode.');
        }
    }
}