class Test{
    //find kth last element in singly linked list
    public static int findKthLast(Node head, int k){
        if(head == null || k < 1) return -1;
        Node p1 = head;
        for(int i = 0; i < k-1; i++){
            if(p1.next == null) return -1;
            p1 = p1.next;
        }
    }



                    


    public static void main(String[] args){
    }
}