package com.prepare;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Solution {
    public static int maxArea(List<Integer> A) {
        int max = -1;
        for(int i=0;i<A.size();i++){
            for(int j=i+1;j<A.size();j++){
                max = Math.max((j-i) * Math.min(A.get(i), A.get(j)), max);
            }
        }
        return max == -1?0:max;
    }

    public static void main(String[] args){
        List<Integer> a = Arrays.asList(1,5,4,3);
        System.out.println(maxArea(a));

    }
}