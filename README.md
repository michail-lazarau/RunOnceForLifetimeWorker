This code ensures a specific action executes exactly once during an object's lifetime.
The Token system allows multiple different actions to be associated with a single object, with each Token representing one unique action.
While the recursive lock isn't essential, it serves as a safeguard against potential deadlocks when working with multiple lock objects.
