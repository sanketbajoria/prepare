# SQL vs. NoSQL Database: When to Use, How to Choose

## Difference between SQL and NoSQL databases. Deep dive, decision tree, and cheatsheet to choose the best for your data type and use case from 12 database types.



How do you choose a database? Maybe, you assess whether the use case needs a Relational database. Depending on the answer, you pick your favorite SQL or NoSQL datastore, and make it work. It is a prudent tactic: a known devil is better than an unknown angel.

Picking the right datastore can simplify your application. A wrong choice can add friction. This article will help you expand your list of known devils with an in-depth overview of various datastores. It covers the following:

- **Database parts** that define a datastore’s characteristics.
- **Datastores** categorized by **data types**: deep dive into databases for unstructured, structured (tabular), and semi-structured (NoSQL) data.
- **Differences** between **SQL** and **NoSQL** databases.
- **Datastores** specialized for various **use cases**.
- **Decision cheatsheet** to navigate the landscape of on-prem and on-cloud datastore choices.

## **ToC:**

[TOC]

# Inside a Database

A high-level understanding of how databases work helps in evaluating alternatives. Databases have 5 components: interface, query processor, metadata, indexes, and storage:

1. **Interface Language or API:** Each database defines a language or API to interact with it. It covers definition, manipulation, query, and control of data and transactions.
2. **Query Processor:** The “CPU” of the database. Its job is to process incoming requests, perform needed actions, and return results.
3. **Storage:** The disk or memory where the data is stored.
4. **Indexes:** Data structures to quickly locate the queried data in the storage.
5. **Metadata:** Meta-information of data, storage. and indexes (e.g., catalog, schema, size).

The **Query Processor** performs the following steps for each incoming request:

1. Parses the request and validates it against the metadata.
2. Creates an efficient execution plan that exploits the indexes.
3. Reads or updates the storage.
4. Updates metadata and indexes.
5. Computes and returns results.

To determine a datastore matches your application needs, you need carefully examine:

- **Operations** supported by the interface. If the computations you require are in-built, you will need to write less code.
- Available **indexes**. It will determine how fast your queries run.

In the next sections, let’s examine operations and indexes in datastores for various data types.

![Database Components: interface language, query processor, storage, indexes, and metadata; and the steps performed by the query processor.](https://miro.medium.com/max/2000/1*uvZUrnyutUrbMHbBIghLHA.jpeg)

Database Components: interface language, query processor, storage, indexes, and metadata; and the steps performed by the query processor. Image is by author and released under [Creative Commons BY-NC-ND 4.0 International](https://creativecommons.org/licenses/by-nc-nd/4.0/) license.

# Blob Storage for Unstructured Data

The file system is the simplest and oldest datastore. We use it every day to store all kinds of data. Blob Storage is a hyper-scale distributed version of the filesystem. It is used to store *unstructured data*.

Blob’s [backronym](https://en.wikipedia.org/wiki/Backronym) is Binary Large OBjects. You can store any kind of data. Therefore blob datastore has no role in interpreting the data:

- Blob supports CRUD (create, read, update, delete) **operations** at the file level.
- The directory or file *path* is the **index**.

So you can quickly locate and read the file. But locating something within a file requires a sequential scan. Documents, images, audio, and video files are stored in blobs.

# Tabular Datastores for Structured Data

Tabular datastores are suitable for storing *structured data*. Each record (*row*) has the same number of attributes (*columns*) of the same type.

There are two kinds of applications:

- Online **Transaction** Processing (**OLTP**): Capture, store, and process data from transactions in real-time.
- Online **Analytical** Processing (**OLAP**): analyze aggregated historical data from OLTP applications.

OLTP applications need datastores that support *low latency* reads and writes of *individual* records. OLAP applications need datastores that support *high throughput* reads on a large number of (*read-only*) records.

## OLTP: Relational or Row-Oriented Database

Relation Database Management Systems (RDBMS) are one of the earliest datastores. The data is organized in tables. Tables are [normalized](https://en.wikipedia.org/wiki/Database_normalization) for reduced data redundancy and better data integrity.

Tables may have primary and foreign keys:

- [**Primary Key**](https://en.wikipedia.org/wiki/Primary_key) is a minimal set of attributes (columns) that uniquely identifies a record (row) in a table.
- [**Foreign Key**](https://en.wikipedia.org/wiki/Foreign_key) establishes relationships between tables. It is a set of attributes in a table that refers to the primary key of another table.

Query and transactions are coded using Standard Query Language (SQL).

Relational databases are optimized for transaction operations. Transactions often update multiple records in multiple tables. Indexes are optimized for frequent low-latency writes of [ACID Transactions](https://en.wikipedia.org/wiki/ACID):

- **Atomicity:** Any transaction that updates multiple rows is treated as a single *unit*. A successful transaction performs *all* updates. A failed transaction performs *none* of the updates, i.e., the database is left unchanged.
- **Consistency:** Every transaction brings the database from one valid state to another. It guarantees to maintain all database invariants and constraints.
- **Isolation:** Concurrent execution of multiple transactions leaves the database in the same state as if the transactions were executed sequentially.
- **Durability:** Committed transactions are permanent, and survive even a system crash.

There are plenty to choose from:

- Cloud Agnostic: Oracle, Microsoft SQL Server, IBM DB2, [PostgreSQL](https://www.postgresql.org/), and [MySQL](https://www.mysql.com/)
- AWS: Hosted PostgreSQL and MySQL in [Relational Database Service (RDS)](https://aws.amazon.com/rds/)
- Microsoft Azure: Hosted SQL Server as [Azure SQL Database](https://azure.microsoft.com/en-in/products/azure-sql/database/)
- Google Cloud: Hosted PostgreSQL and MySQL in [Cloud SQL](https://cloud.google.com/sql/), and also horizontally scaling [Cloud Spanner](https://cloud.google.com/spanner)

## OLAP: Columnar or Column-Oriented Database

While transactions are on rows (records), analytics properties are computed on columns (attributes). OLAP applications need an optimized column-read operation on a table.

One way to achieve it is by adding column-oriented indexes to Relational databases. For example:

- [Columnstore indexes in Microsoft SQL Server](https://docs.microsoft.com/en-us/sql/relational-databases/indexes/columnstore-indexes-overview?view=sql-server-ver15)
- [Columnstore indexing in PostgreSQL](https://swarm64.com/post/postgresql-columnstore-index-intro/)

However, the primary RDBMS operation is low-latency high-frequency ACID transactions. That does not scale to the Big Data scale common in analytics applications.

For Big Data, storing in blob storage [**Data Lakes**](https://en.wikipedia.org/wiki/Data_lake) became popular. Partial analytics summarizations were computed and maintained in [**OLAP Cubes**](https://en.wikipedia.org/wiki/OLAP_cube). Advances in the scale and performance of Columnar storage made OLAP Cubes obsolete. But the concepts are still relevant for designing the data pipelines.

Modern [**Data Warehouses**](https://en.wikipedia.org/wiki/Data_warehouse) are built on [**Columnar**](https://en.wikipedia.org/wiki/Column-oriented_DBMS) databases. Data is stored by columns instead of by rows. Available choices are:

- AWS: [RedShift](https://aws.amazon.com/redshift/?whats-new-cards.sort-by=item.additionalFields.postDateTime&whats-new-cards.sort-order=desc)
- Azure: [Synapse](https://azure.microsoft.com/en-in/services/synapse-analytics/)
- Google Cloud: [BigQuery](https://cloud.google.com/bigquery)
- Apache: [Druid](https://druid.apache.org/), [Kudu](https://kudu.apache.org/), [Pinot](https://pinot.apache.org/)
- Others: [ClickHouse](https://clickhouse.tech/), [Snowflake](https://www.snowflake.com/)

[Databricks Delta Lake](https://databricks.com/product/delta-lake-on-databricks) offers columnar-like performance on data stored in data lakes.

![RDBMS vs. Columnar: Row-Oriented databases for OLTP and Column-Oriented databases for OLAP applications](https://miro.medium.com/max/2000/1*_uKRRPGdiHBGkQ36WOzxUw.jpeg)

RDBMS vs. Columnar: Row-Oriented databases for OLTP and Column-Oriented databases for OLAP applications. Image is by author and released under [Creative Commons BY-NC-ND 4.0 International](https://creativecommons.org/licenses/by-nc-nd/4.0/) license.

# NoSQL for Semi-structured Data

NoSQL datastores cater to semi-structured data types: key-value, wide column, document (tree), and graph.

## Key-Value Datastore

A key-value store is a [dictionary or hash table](https://en.wikipedia.org/wiki/Associative_array) database. It is designed for CRUD operations with a unique key for each record:

- Create(key, value): Add a key-value pair to the datastore
- Read(key): Lookup the value associated with the key
- Update(key, value): Change the existing value for the key
- Delete(key): Delete the (key, value) record from the datastore

The values do not have a fixed schema and can be anything from primitive values to compound structures. Key-value stores are highly partitionable (thus scale horizontally). [Redis](https://redis.io/) is a popular key-value store.

## Wide-column Datastore

A wide-column store has tables, rows, and columns. But the names of the columns and their types may be different for each row in the same table. Logically, It is a versioned sparse matrix with multi-dimensional mapping (row-value, column-value, timestamp). It is like a two-dimensional key-value store, with each cell value versioned with a timestamp.

Wide-column datastores are highly partitionable. It has a notion of column families that are stored together. The logical coordinates of a cell are: (Row Key, Column Name, Version). The physical lookup is as following: Region Dictionary ⇒ Column Family Directory ⇒ Row Key ⇒ Column Family Name ⇒ Column Qualifier ⇒ Version. So, wide-column stores are actually row-oriented databases.

[Apache HBase](https://hbase.apache.org/) was the first open-source wide-column datastore. Check out [HBase in Practice](https://www.slideshare.net/larsgeorge/hbase-in-practice), for core concepts of wide-column datastores.

## Document Datastore

Document stores are for storing and retrieving a document consisting of nested objects. a tree structure such as XML, JSON, and YAML.

In a key-value store, the value is opaque. But the document stores exploit the tree structure of the value to offer richer operations. [MongoDB](https://www.mongodb.com/document-databases) is a popular example of a document store.

## Graph Datastore

Graph databases are like document stores but are designed for graphs instead of document trees. For example, a graph database will suit to store and query a social connection network.

[Neo4J](https://neo4j.com/) is a prominent graph database. It is also common to use [JanusGraph](https://janusgraph.org/) kind of index over a wide-column store.

# SQL vs. NoSQL Database Comparision

Non-relational NoSQL datastores gained popularity for two reasons:

- RDBMS did not scale horizontally for Big Data
- Not all data fits into strict RDBMS schema

NoSQL datastores offer horizontal scale at various CAP Theorem tradeoffs. As per [CAP Theorem](https://en.wikipedia.org/wiki/CAP_theorem), a distributed datastore can give at most 2 of the following 3 guarantees:

- **Consistency:** Every read receives the most recent write or an error.
- **Availability:** Every request gets a (non-error) response, regardless of the individual states of the nodes.
- **Partition tolerance:** The cluster does not fail despite an arbitrary number of messages being dropped (or delayed) by the network between nodes.

Note that the consistency definitions in CAP Theorem and ACID Transactions are different. ACID consistency is about data integrity (data is consistent w.r.t. relations and constraints after every transaction). CAP is about the state of all nodes being consistent with each other at any given time.

Only a few NoSQL datastores are ACID-complaint. Most NoSQL datastore support [BASE model](https://dl.acm.org/doi/10.1145/1394127.1394128):

- **Basically Available:** Data is replicated on many storage systems and is available most of the time.
- **Soft-state:** Replicas are not consistent all the time; so the state may only be partially correct as it may not yet have converged.
- **Eventually consistent:** Data will become consistent at some point in the future, but no guarantee when.

## Difference between SQL and NoSQL

Differences between RDBMS and NoSQL databases stem from their choices for:

- **Data Model:** RDBMS databases are used for normalized structured (tabular) data strictly adhering to a relational schema. NoSQL datastores are used for non-relational data, e.g. key-value, document tree, graph.
- **Transaction Guarantees:** All RDBMS databases support ACID transactions, but most NoSQL datastores offer BASE transactions.
- **CAP Tradeoffs:** RDBMS databases prioritize strong consistency over everything else. But NoSQL datastores typically prioritize availability and partition tolerance (horizontal scale) and offer only [eventual consistency](https://en.wikipedia.org/wiki/Eventual_consistency).

## SQL vs. NoSQL Performance

RDBMS are designed for fast transactions updating multiple rows across tables with complex integrity constraints. SQL queries are expressive and declarative. You can focus on ***what\*** a transaction should accomplish. RDBMS will figure out ***how\*** to do it. It will optimize your query using relational algebra and find the best execution plan.

NoSQL datastores are designed for efficiently handling a lot more data than RDBMS. There are no relational constraints on the data, and it does not need to be even tabular. NoSQL offers performance at a higher scale by typically giving up strong consistency. Data access is mostly through REST APIs. NoSQL query languages (such as GraphQL) are not yet as mature as SQL in design and optimizations. So you need to take care of both *what* and *how* to do it efficiently.

**RDBMS scale vertically.** You need to upgrade hardware (more powerful CPU, higher storage capacity) to handle the increasing load.

**NoSQL datastores scale horizontally.** NoSQL is better in handling partitioned data, so you can scale by adding more machines.

![SQL vs. NoSQL: Difference between NoSQL and SQL databases](https://miro.medium.com/max/2000/1*1QyI7Zxx73mkG0FcwNUyuw.jpeg)

SQL vs. NoSQL: Difference between NoSQL and SQL databases. Image is by author and released under [Creative Commons BY-NC-ND 4.0 International](https://creativecommons.org/licenses/by-nc-nd/4.0/) license.

# NoSQL Use Case Specializations

The line between various types of NoSQL datastore is blurry. On occasions, even the line between SQL and NoSQL is blurry ([PostgreSQL as a key-value store](https://www.postgresql.org/docs/13/hstore.html) and [PostgreSQL as JSON document DB](https://www.sisense.com/blog/postgres-vs-mongodb-for-storing-json-data/)).

A datastore can be morphed to serve another similar data type by adding indexes and operations for that data type. Initial Columnar-like OLAP databases were RDBMS with column-store index. The same is happening to NoSQL stores for supporting multiple data types.

That’s why it is better to think about the use case and pick the datastore suitable for your application. A datastore that serves multiple use cases may help reduce the overhead.

For analytics use cases, a tabular columnar database is often more suitable than a NoSQL database.

Datastores with in-built operations suitable for the use case are preferred (instead of implementing those operations in each application).

## In-memory Key-Value Datastore

Same as a key-value store, but the data is in the memory instead of on the disk. It eliminates the disk IO overhead and serves as a fast cache.

## Time Series Datastore

A time series is a series of data points, indexed and ordered by timestamp. The timestamp is the key in the Time Series datastores.

A time series can be modeled as:

- **Key-value:** associated pairs of timestamps and values
- **Wide column:** with the timestamp as the key for the table

A wide column store with date-time functions from the programming languages is often used as a time series database.

In analytics use cases, a columnar database can be used for time-series data as well.

## Immutable Ledger Datastore

Immutable Ledger is for maintaining an immutable and (cryptographically) verifiable transaction log owned by a central trusted authority.

From the storage perspective, a wide column store suffices. But datastore operations must be **immutable** and **verifiable**. Very few datastores (e.g. [Amazon QLDB](https://aws.amazon.com/qldb/), [Azure SQL Ledger](https://docs.microsoft.com/en-us/azure/azure-sql/database/ledger-overview), and [Hyperledger Fabric](https://github.com/hyperledger/fabric)) fulfill those requirements at present.

## Geospatial Datastore

A Geospatial database is a database to store geographic data (such as countries, cities, etc.). It is optimized for geospatial queries and geometric operations.

A wide column, key-value, document, or relational database with geospatial queries is commonly used for this purpose:

- [PostGIS](https://postgis.net/) extension to PostgreSQL
- [GeoJSON](https://docs.mongodb.com/manual/reference/geojson/) objects in MongoDB

In analytics use cases, a columnar database may suit better.

## Text Search Datastore

Text search on unstructured (natural) or semi-structured text is a common operation in many applications. The text can either be plain or rich (e.g. PDF), stored in a document database, or stored in a blob store. [Elastic Search](https://www.elastic.co/what-is/elasticsearch) has been a popular solution.

# When to Use SQL vs. NoSQL: Decision Tree & Cloud Cheat Sheet

Given so many data types, uses cases, choices, application considerations, and cloud/on-prem constraints, it can be time-consuming to analyze all options. The cheat sheet below will help you quickly shortlist few candidates.

It is impractical to wait for learning everything needed to make a choice. This cheat sheet will get you few reasonable choices to start with. It is simplified by design, and some nuances and choices are absent. It is optimized for recall instead of precision.

![SQL vs. NoSQL: Cheatsheet for database choices on AWS, Microsoft Azure, Google Cloud Platform, and cloud-agnostic/on-prem/open-source.](https://miro.medium.com/max/2000/1*SbI8FV6rKx2i3mHEVk-GGw.jpeg)

When to use SQL vs. NoSQL: Decision tree and cloud cheat sheet for database choices on AWS, Microsoft Azure, Google Cloud Platform, and cloud-agnostic/on-prem/open-source. Image is by author and released under [Creative Commons BY-NC-ND 4.0 International](https://creativecommons.org/licenses/by-nc-nd/4.0/) license.

# Summary

This article walked you through various datastore choices and explained how to pick one based on:

- Application: transactions or analytics
- Data Type (SQL vs. NoSQL): Structured, Semi-structured, unstructured
- Use Case
- Deployment: major cloud provider, on-prem, vendor lock-in considerations

# Resources

1. [Database Services on AWS](https://aws.amazon.com/products/databases/)
2. AWS Whitepaper: [Overview of Amazon Web Services — Databases](https://docs.aws.amazon.com/whitepapers/latest/aws-overview/database.html)
3. [How to choose the right database — AWS technical content series](https://aws.amazon.com/startups/start-building/how-to-choose-a-database/)
4. [Understanding Azure datastore models](https://docs.microsoft.com/en-us/azure/architecture/guide/technology-choices/data-store-overview)
5. [Types of databases on Azure](https://azure.microsoft.com/en-in/product-categories/databases/)
6. [Google Cloud database services](https://cloud.google.com/products/databases)
7. [Data lifecycle and database choices on Google Cloud Platform](https://cloud.google.com/architecture/data-lifecycle-cloud-platform)