### Core Data Fundamentals: Concurrency

#### Author: Bart Jacobs

So far, we have used a single managed object context, which we created in the `CoreDataManager` class. This works fine, but there will be times when one managed object context won't suffice.

What happens if you access the same managed object context from different threads? What do you expect happens? What happens if you pass a managed object from a background thread to the main thread? Let's start with the basics.

**Read this article on the [blog](http://bartjacobs.com/core-data-fundamentals-concurrency/)**.
