# Do's and Don't and Things to remember

## Do's

- Gather Functional Requirement. Determine the scope (use cases) for system design problem.
- Identify the Non Functional Requirement such as Availability, Latency, Consistency and Security, for every use cases.




## Things to remember

### Rest API design
- Always use plural form of resource in url. For example, /users will work.
- POST request is not idempotent. And, used to create new resource. URL pattern is /users
- GET request is idempotent. And, used to retrieve resource. URL pattern is /users/{user_id}
- GET request is used to retrieve all resources. URL pattern is /users. We can have sort, pagination and filter criteria.
- PUT request is idempotent. And, used to update or create resource. URL pattern is /users/{user_id}. It is mandatory to have id in url (which identify the resource). It always replace the resource as a whole.
- PATCH request is not idempotent. And, used to update a selective field in a resource. URL pattern is /users/{user_id}. It is mandatory to have id in url (which identify the resource). For eg: if you want to archive/unarchive a record, or update a array or particular field.
- DELETE request is idempotent. And, used to delete or soft delete resource. URL pattern is /users/{user_id}. It is mandatory to have id in url (which identify the resource).
Use noun in url pattern. For example, /users, /dogs etc...
Use plural form of resource in url pattern. For example, /users, /dogs etc... But in some cases, we can use singular form of resource in url pattern. For example, /users/{user_id}/follow  or /users/{user_id}/unfollow etc... User will follow or unfollow a user. Another example /search/photos, /search/users etc...


### Caching
- Caching always introduce some sort of staleness, so if data get updated very frequently, it will be difficult to keep the cache up to date.
- Use cache for master data, which don't get update very frequently
- Use cache for any precomputed result, which will be valid for some time period such as a mt, hour, day etc...
- You can achieve strong consistency between cache and database by using inline cache (where cache is source of truth). Read through and Write through cache. Redis has module named RedisGears which support Write behind.


### Microservices
- Don't break services into microservices until they represent separate concerns/modules. Don't break it just for the sake of autoscaling.
- Break services into microservice if 
   - if they represent separate concerns or different business units or different modules
   - if they require separate technology or infrastructure. (for eg: if one service require more compute power than another service, or if one service is more efficient in writing in different languages than another service).
- Separating into microservice require lot of infrastructure changes, as well as we have to code for failure scenarios.


### SQL vs NoSQL
Use SQL database, in below scenarios
- When your data is structured, and you have to perform complex queries.
- When we require ACID transactions.
- You can scale your database to have more than one read replica. But, having more than one write replica is not recommended.
- Partitioning of data is required, to scale your database. But, it will require complex join queries.
Use NoSQL database, in below scenarios
- When your data is unstructured, and you have dynamics fields.
- When you don't require ACID transactions. (strong consistency or transactions)
- When you have lot of data to be stored and read.
- Most of the time, it provide eventual consistency, so that we can have high availability. For eg: in mongodb suppose we write a record and read it. if both request goes to same server then it will be consistent but if one request goes to one server and another request goes to another server then it can be inconsistent (latency to replicate that record on slave machine)



PDF Generator API allows you easily generate PDF documents from pre-defined templates and JSON data. Enable your users to create and manage their document templates using a browser-based drag-and-drop editor to reduce development and support costs.

We make PDF easy.
All the tools you’ll need to be more productive and work smarter with documents.


Create the Perfect Document
File too big? Compress it. Need a specific format? Convert it. Things getting chaotic? Merge and split files, or remove excess pages. Smallpdf has it all.




PDF on the fly.
PDFByte API allows you to generate PDF documents on the fly from JSON data using pre-defined templates. It also helps you to enrich your existing PDF documents using simple and robust URL parameters.


unlock=""
merge
lock=""
split=1,2-6,7-10
splitByText=32221
watermark=

addimage=
delimage=

