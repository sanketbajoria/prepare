package com.prepare;

import java.util.ArrayList;
import java.util.LinkedHashMap;

public class Main {

    public static void main(String[] args) {
	// write your code here
        ArrayList<Integer> l = new ArrayList<>();
        l.add(4);
        LinkedHashMap map = new LinkedHashMap();
        Employee e = new Employee(10, "test");
        map.put(e, e);
        System.out.println(map);
    }
}
class Employee implements Comparable<Employee>{
    private Integer age;
    private String name;
    private boolean married;
    public Employee(int age, String name){
        this.age = age;
        this.name = name;
    }
    public void setMarried(boolean married){
        this.married = married;
    }

    @Override
    public int compareTo(Employee o) {
        return this.age.compareTo(o.age);
    }
}