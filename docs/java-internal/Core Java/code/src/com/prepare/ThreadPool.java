package com.prepare;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.*;

class Worker extends Thread{
	private BlockingQueue<FutureTask> queue;
	Worker(BlockingQueue<FutureTask> queue){
		this.queue = queue;
	}
	public void run(){
		while(true){
			FutureTask task  =  queue.remove();
			task.run();
		}
	}
}


public class ThreadPool {
	private BlockingQueue<FutureTask> queue = new LinkedBlockingQueue<>();
	private int maxThreads;
	private int minThreads;
	private List<Worker> workers = new ArrayList<>();
	
	public ThreadPool(int maxThreads, int minThreads){
		this.maxThreads = maxThreads;
		this.minThreads = minThreads;
		init();
	}
	
	private void init(){
		for(int i =0;i<minThreads;i++){
			startNewThread();
		}
	}
	
	private boolean startNewThread(){
		if(minThreads < maxThreads){
			Worker w = new Worker(this.queue);
			workers.add(w);
			++minThreads;
			w.start();
			return true;
		}
		return false;
	}
	
	public Future submit(Callable c){
		FutureTask f = new FutureTask(c);
		queue.add(f);
		startNewThread();
		return f;
	}
	
	public Future submit(Runnable c){
		FutureTask f = new FutureTask(c, null);
		queue.add(f);
		startNewThread();
		return f;
	}
	
}

