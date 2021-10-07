# Implementing a Complete Binary Heap in JavaScript: The Priority Queue

[![Mike Peritz](https://miro.medium.com/fit/c/60/60/1*PCg8Q5_durEtCYkxraYE0g.jpeg)](https://codeburst.io/@mike.peritz?source=post_page-----7d85bd256ecf----------------------)

[Mike Peritz](https://codeburst.io/@mike.peritz?source=post_page-----7d85bd256ecf----------------------)Follow

[Jun 6, 2017](https://codeburst.io/implementing-a-complete-binary-heap-in-javascript-the-priority-queue-7d85bd256ecf?source=post_page-----7d85bd256ecf----------------------) · 7 min read

# What’s a heap?

A heap is a tree-like data structure where each node must be ordered with respect to the value of its children. This ordering must persist throughout the entire heap. Put simply, a parent node’s value must always be greater (or less) than its children’s values. There are two types of heap: max heap and min heap. As you may have guessed, in a max heap, parent node values are greater than those of their children, whereas the opposite is true in a min heap.

# What’s a Binary Heap?

Binary heaps are a specific implementation of a heap whereby each parent can have no more than two children. Additionally, a *complete* binary heap has every level filled, except for the bottom level. This level gets populated left to right.

# Why should I care?

A heap is a useful and efficient way to store and look up data that must maintain order. The classic example is a priority queue abstract data type. A priority queue is a set of data where higher or lower valued data points bubble to the front of the queue and are therefore accessed first. We’re going to use that as our example in this post of how a heap can improve lookup efficiency. Please note: this example will make use of ES2015, so be sure to brush up on classes, arrow functions, and object destructuring before you read this!

# First, the naive solution.

To understand how the binary heap will optimize our solution, it is important to see the naive solution. The naive solution to the priority queue is a linked-list data structure where each node has a “priority” key. Lets start by defining the node class:

```javascript
class Node {
  constructor(val, priority) {
    this.value = val;
    this.priority = priority;
    this.next = null;
  }
}
```

Awesome. Now each node can have a value and a priority, and can point to the next node in our priority queue.

Now we can initialize our linked list. Lets call it PriorityQueue and give it a “first” property to represent the highest priority item in the queue.

```javascript
class PriorityQueue {
  constructor {
    this.first = null;
  }
}
```

If we want to use our priority queue, we’re going to need to be able to insert values. Nodes with a higher *this.priority* will be inserted at earlier points in the linked list. To do this we must visit each node in the list until we find one with a lower *this.priority* than the new node we are inserting. Additionally, if we encounter a node(s) with the same priority, we must insert the new node after all nodes with matching priority. This can be accomplished iteratively with a pointer.

There are two edge cases to deal with:

1. When the priority queue is empty, we set *this.first* to a new node with the passed in value and priority.
2. When the new node has a higher priority, we need to set its *.next*property to the current *this.first* node, and then reset *this.first* to be the new node.

We can handle both edge cases if we just do the action described in #2 above in an if statement, and then we’ll handle all other cases in the else:

```javascript
class PriorityQueue {
  constructor {
    this.first = null;
  }
  
  insert(value, priority) {
    const newNode = new Node(value, priority);
    if (!this.first || priority > this.first.priority) {
      newNode.next = this.first;
      this.first = newNode;
    } else {
      let pointer = this.first;
      while (pointer.next && priority < pointer.next.priority) {
        pointer = pointer.next;
      }
      newNode.next = pointer.next;
      pointer.next = newNode;
    }
  }
  
}
```

Great! Now that we can add to the priority queue, we want to be able to remove elements as well. Since we know the highest priority node is always referenced as *this.first*, we just have to save a reference to its value, and then reset *this.first* to the next node in the queue:

```javascript
class PriorityQueue {
  constructor {
    this.first = null;
  }
  
  insert(value, priority) {
    const newNode = new Node(value, priority);
    if (!this.first || priority > this.first.priority) {
      newNode.next = this.first;
      this.first = newNode;
    } else {
      let pointer = this.first;
      while (pointer.next && priority < pointer.next.priority) {
        pointer = pointer.next;
      }
      newNode.next = pointer.next;
      pointer.next = newNode;
    }
  }
  
  remove() {
    const first = this.first;
    this.first = this.first.next;
    return first;
  }
  
}
```

<iframe src="https://codeburst.io/media/2ea7504b1c9bf19b7f91da4ca7c79526" frameborder="0" height="622" width="680" title="priority-queue-LL-final.js" class="hh n o hg ab" scrolling="auto" style="box-sizing: inherit; top: 0px; left: 0px; width: 680px; height: 622px; position: absolute;"></iframe>

There you have it, a perfectly valid priority queue. But lets talk about efficiency. Because we potentially have to visit all items in the list, inserting values to the linked-list priority queue has O(*n*) time complexity, while removing them is constant time, or, O(*1*). That’s a very good lookup efficiency, but our insertion efficiency is mediocre at best. What if we could optimize our insertion to be O(*log n*)? As you may have guessed, we can do this using a binary heap.

# Optimized Solution: The Complete Binary Heap

As stated above, a binary heap is a great way to implement the priority queue because it maintains the order (or *priority*) of its data, with the added bonus of a tree’s efficient insert time. Because complete binary heaps/trees handle insertion level-by-level, we can use JavaScript’s array object to hold our data, and use a *level-ordered* algorithm to dictate how each data point is stored. Typically, heaps have a lot of methods on their prototypes, but we are just going to implement insert and remove.

To understand this better, lets learn by example. Consider the simple complete binary heap below:

![img](https://miro.medium.com/max/38/1*XSchy2OiWWwlkPNhhoKVBg.png?q=20)

![img](https://miro.medium.com/max/626/1*XSchy2OiWWwlkPNhhoKVBg.png)

Now lets walk through the level-ordered algorithm to see how this heap could be represented as a JavaScript array:

```
We start with an array with the uppermost parent node:

[100]

The parent node's children come next, ordered left to right:

[100, 19, 36]

Then the "19" node's children, again left to right:

[100, 19, 36, 17, 3]

As well as the "36" node's children:

[100, 19, 36, 17, 3, 25, 1]

See a pattern emerging?
If a given node is located at index 'x' in the array, its left child exists at
index = 2x, and its right child exists at index = 2x + 1.  Each node's parent exists
at index = x / 2 (rounded down).

So the final binary heap array looks like this:

[100, 19, 36, 17, 3, 25, 1, 2, 7]

And we can find any given child's parent/children using our algorithm.  For instance,
the "25" node exists at index = 5, therefore its parent must exist at 5/2 rounded down
which equals 2.  It works!
```



<iframe src="https://codeburst.io/media/61f4650c2760aabc3057d840e46831d0" frameborder="0" height="644" width="680" title="level-ordered-algorithm.txt" class="hh n o hg ab" scrolling="auto" style="box-sizing: inherit; top: 0px; left: 0px; width: 680px; height: 644px; position: absolute;"></iframe>

OK, now that we have a nice representation of the complete binary heap in JavaScript, lets implement our functionality. We can begin with insertion. Inserting any value must maintain the rules of our complete binary heap. Namely:

1. The priority of the node that gets inserted cannot be greater than its parent.
2. Every level of the heap must be full, except the lowest level, which fills left to right.

So, we begin by simply adding a new node to the end of our heap array. JavaScript arrays have a useful .push method which accomplishes this for us. We then need to adjust our heap array in order to obey the rules above. Since we know where every node’s parent is, this is a simple matter of checking the child node’s priority with its parent and swapping them if so. We continue to do this until the parent node has a lower priority than the child, or we run out of parent nodes, in which case the new node takes over the highest level of the heap. Lets see it in action:

```javascript
class PriorityQueue {
  constructor() {
    this.heap = [null]
  }
  
  insert(value, priority) {
    const newNode = new Node(value, priority);
    this.heap.push(newNode);
    let currentNodeIdx = this.heap.length - 1;
    let currentNodeParentIdx = Math.floor(currentNodeIdx / 2);
    while (
      this.heap[currentNodeParentIdx] &&
      newNode.priority > this.heap[currentNodeParentIdx].priority
    ) {
      const parent = this.heap[currentNodeParentIdx];
      this.heap[currentNodeParentIdx] = newNode;
      this.heap[currentNodeIdx] = parent;
      currentNodeIdx = currentNodeParentIdx;
      currentNodeParentIdx = Math.floor(currentNodeIdx / 2);
    }
  }
  
}
```



<iframe src="https://codeburst.io/media/7c7ed56e0ec30ebafbae1b749a632f25" frameborder="0" height="536" width="680" title="priority-heap-insert.js" class="hh n o hg ab" scrolling="auto" style="box-sizing: inherit; top: 0px; left: 0px; width: 680px; height: 536px; position: absolute;"></iframe>

Note that the first element in this.heap is null. The reason for this will become evident when we implement the remove() method.

Because we are only visiting levels in the heap (as opposed to each node), our efficiency is at worst O(*number of levels*), which translates to O(*log n*), a drastic improvement over the linked-list solution efficiency of O(*n*).

Now lets implement removal. Due to the nature of a heap, our highest priority item is always at the top of the heap. So all we have to do is return the second item in *this.heap*, right? (Remember that the first element is *null*).

Sort of, but remember that now we’ve removed a node from our heap. It has to be replaced! We still have to obey the rules of the complete binary heap, so we can’t just swap elements willy-nilly. The first step is to pop off the last element of the heap, and set it to be our first element. This allows us to obey rule 2 above. Because there is a high likelihood that this element’s priority is lower than its children, we now have to start swapping it with its children until we satisfy rule 1 above. We do this by testing which child is higher, left or right. This is the reason we initialized *this.heap* with a zero index value of *null.* We have to start at index 1 order to multiply by 2 and find the first node’s children. If we started at index zero, we would never be able to find the first node’s children, because that calculation would always result in an index of zero.

Lets see one possible implementation of this:

```javascript
remove() {
  if (this.heap.length < 3) {
    const toReturn = this.heap.pop();
    this.heap[0] = null;
    return toReturn;
  }
  const toRemove = this.heap[1];
  this.heap[1] = this.heap.pop();
  let currentIdx = 1;
  let [left, right] = [2*currentIdx, 2*currentIdx + 1];
  let currentChildIdx = this.heap[right] && this.heap[right].priority >= this.heap[left].priority ? right : left;
  while (this.heap[currentChildIdx] && this.heap[currentIdx].priority <= this.heap[currentChildIdx].priority) {
    let currentNode = this.heap[currentIdx]
    let currentChildNode = this.heap[currentChildIdx];
    this.heap[currentChildIdx] = currentNode;
    this.heap[currentIdx] = currentChildNode;
  }
  return toRemove;
}
```



<iframe src="https://codeburst.io/media/1c60b45eec043d145fe7c902c80d2587" frameborder="0" height="466" width="680" title="priority-heap-remove.js" class="hh n o hg ab" scrolling="auto" style="box-sizing: inherit; top: 0px; left: 0px; width: 680px; height: 466px; position: absolute;"></iframe>

Note the edge case taken care of in lines 2–6. This accounts for the fact that if we replace the first element in the heap with *this.heap.pop()*, we are replacing that element with itself! It also handles the case of an empty heap by returning null and replacing the zero index of the heap with a new *null*value.

So what is the efficiency of removal with this solution? Once again we may visit every level of the heap, meaning (just like insertion), we have a time complexity of O(*log n*). Isn’t this worse than our time complexity with the linked-list? Yup, but the gains we get in insertion will outweigh the loss we see in removal. Lets visualize this with a chart:

![img](https://miro.medium.com/max/38/1*EHKwJOq4iradT5hAr4nqSA.png?q=20)

![img](https://miro.medium.com/max/750/1*EHKwJOq4iradT5hAr4nqSA.png)

Credit: Wolfram-Alpha

This plot shows the efficiency of each implementation if we were to add and then immediately remove between 1 and 50 elements from our priority queue. For the linked-list, the operation of adding and then immediately removing elements would be O(*n*) + O(*1*) which results in the blue line you see above. For the binary heap, the efficiency of this operation would be O(*log n*) + O(*log n*) which results in the red line above. The difference is clear. The sacrifice we make in our removal efficiency is totally worth it.

# Conclusion

I hope this article has helped you understand more about heaps, and how they can improve time complexity. For more practice, try implementing additional methods like *peek*, a method that returns the first element in the priority queue without removing it. You could also try *heapify*, a method that will create a heap out of an array of elements.



https://codeburst.io/implementing-a-complete-binary-heap-in-javascript-the-priority-queue-7d85bd256ecf