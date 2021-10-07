[TOC]



# System Design Guide for AWS Solution Architect Interview

System Design approach : Handling Ambiguity by using Systematic Approach to clarify the problem statement. And why is so important : Because is to understand how the candidate deals with ambiguity and this quality is so important for the job.

**First Step : Questions requirements clarifications:**

***1.Users/Customers :\***

- Who will use the system
- How the system will be used

***2. SCALE (Read and Write)\***

- How many read/write per second
- How much data is queried per request
- How many (videos) views are processed per second
- Can there be spikes in traffic

***3.Performance/Latency\***

- What is expected write in read data delay
- What is expected latency for read queries

***4.High Avaibility/Reliability\***

- RTO/RPO
- Disaster Recovery
- SLA 99.99

***5.Cost\***

- Should the design minimise the cost of developments
- Should the design minimise the cost of maintenance

**Second Step : All the Clarification Requirements to get us to end goal of:**

## **1.Functional Requirement (API = System behaviour=Access pattern)**

## **ALB vs API Gateway**

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGB8XCsGavaXA/article-inline_image-shrink_1000_1488/0/1600573320725?e=1635379200&v=beta&t=DnGSKyEuth1YYC9goqL1W5FP3zeTMSpI5DpzUQYF2Bc)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQEk3cZ1oyb2LA/article-inline_image-shrink_1000_1488/0/1600573359800?e=1635379200&v=beta&t=mZWg86EexX5617iwDsDa_Xgv0TxRUvSLLW2N0mfaVNk)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQF-37ncpKarug/article-inline_image-shrink_1000_1488/0/1600573422848?e=1635379200&v=beta&t=Osj0AF3Z_H_ZEu1ivvdgQcT2VpV5lGrj3KVM4FM_AZM)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHBwuJ4G2qSpw/article-inline_image-shrink_1000_1488/0/1600573513922?e=1635379200&v=beta&t=rvoasDqSxFdxRaxfVgWN2nLsZ1GVqrHClTX0L2xoxvU)



## **2.Non Functional(HA/Reliability, Latency/Performance, Security)**

## **A. Data Modelling(**SQL - NoSQL) **and Data Storage :**

**Data Modelling :**

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHOcri3NJjMzw/article-inline_image-shrink_1500_2232/0/1600500324122?e=1635379200&v=beta&t=LV3BHBccDHRnMCL8rtWf9jyasq4-7x8kP2I-yuDNV3o)



**Data Storage :**

1. Object Storage : Amazon S3
2. Metadata : AWS Glue Catalog, Lake Formation, and Hive Metastore(Presto, Spark, Hive, Pig) - can be hosted on Amazon RDS
3. Checkpointing with Amazon Kinesis Data Streams and Amazon Lambda : Amazon DinamoDb = Managed Key Value based on wide column data
4. NoSQL based on Document similar with MangoDb = Amazon DocumentDb
5. Manage Relational Database Service = Amazon RDS
6. Managed GraphDB = Amazon Neptune
7. Cache = Amazon ElasticCache = managed Memcached or Redis service
8. Amazon DynamoDB accelerator (DAX) = Managed in-memory cache for DynamoDB

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQEtz51BvnzTyg/article-inline_image-shrink_1500_2232/0/1600500148461?e=1635379200&v=beta&t=yM4tzSxuEbxB22XjM02j66x8Xd4qp_5iBu_qkQb-6Io)

##  

## **B. Data Processing Services**

Delivery of data :

1. Virtualized :VM
2. Managed Services
3. Serverless/Clusterless/Containerized

## **Serverless Lambda:**

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGpCdJne5ZyAg/article-inline_image-shrink_1500_2232/0/1600585998719?e=1635379200&v=beta&t=ssH-ax_BPGTYo6aArLKVB9otDd0aZ4t00Em-HPUPrRg)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQF3DwJWzGpgLg/article-inline_image-shrink_1000_1488/0/1600586020843?e=1635379200&v=beta&t=zi7h5eAdIbUByCYr61OqIfrlCNWvmWnNGEK3Jtb1q_c)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGtqf0r3JYF2Q/article-inline_image-shrink_1000_1488/0/1600586047718?e=1635379200&v=beta&t=rfPmMeE3b5XhnilbmPpSFQllGWDYoBdcwhiOxU_J7_g)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGwGRbp1zXZUw/article-inline_image-shrink_1000_1488/0/1600586070512?e=1635379200&v=beta&t=GtL6i0FmHKyKJR2ljOIPd8OZx2v3N1kM6WoEilg-ET4)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFj91dpt_abfw/article-inline_image-shrink_1000_1488/0/1600586087174?e=1635379200&v=beta&t=Ik19CDVCNqordQfasy8Lxz-wIi2_QNrDbN-IUcQ-cmg)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGS5hY-PgLHwQ/article-inline_image-shrink_1000_1488/0/1600586105884?e=1635379200&v=beta&t=57jOPhTROZLP3Id_25528HerH_EvPXnNCp7MHtJDhkE)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQH5b7ETKARkkQ/article-inline_image-shrink_1000_1488/0/1600586123488?e=1635379200&v=beta&t=B3x0pryPd6tkdMXRDW_32wCBE2OMgPPhrd23xeKKOlI)

## Serverless Glue:

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFN1XtjLri5jw/article-inline_image-shrink_1000_1488/0/1600593919976?e=1635379200&v=beta&t=S5mi8v4QKMzS0KKdjZzfZLjogfmc0cuCtAHplJSYba8)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQEs_AlHlehqZg/article-inline_image-shrink_1000_1488/0/1600593939103?e=1635379200&v=beta&t=UMe42qhSHkhb8SGr0Qi74KTEKrh2amv5_hRan38W4Dg)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFBpaEdQTv3aQ/article-inline_image-shrink_1500_2232/0/1600593969675?e=1635379200&v=beta&t=8m23hhKVDeUfQh-OC6FuBHJ_NIArx6kaq5y9AmPVQtA)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGulbFubQ3Zqw/article-inline_image-shrink_1000_1488/0/1600593991775?e=1635379200&v=beta&t=tmWlBXTAj_dI_ao5XcGEnpJo4Ur-Q6gI_k5Yd3f28jY)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHJoiF3nlRgtA/article-inline_image-shrink_1000_1488/0/1600594012001?e=1635379200&v=beta&t=FKFcIyT8vFTg9wEblMwRiU3Os_QVxpFO5gBMH2QMpw8)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFNpCMwB-yrig/article-inline_image-shrink_1000_1488/0/1600594028486?e=1635379200&v=beta&t=Tw8mAEMxbJXjzv-RtQiIQb6KJ2unwT_ayKXaxVBCAe8)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQEVOS2_z2xhuA/article-inline_image-shrink_1000_1488/0/1600594046249?e=1635379200&v=beta&t=oEVIojGiDD-qadcYIKF8WCEnlsnR13GxDXY8SdpaGiA)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQEeel9QcpiFtw/article-inline_image-shrink_1000_1488/0/1600594061593?e=1635379200&v=beta&t=nz_lcLDXg-AGJZ0aS-Dpzw91bAvUbAaujGD4E6os-XQ)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQF8nCa2x-SW8A/article-inline_image-shrink_1000_1488/0/1600594074940?e=1635379200&v=beta&t=t94YITUQFfmUS2DC8e3NyBVWhcH5sEFWU8g8dCJ3BtU)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHIcVXLgoov5Q/article-inline_image-shrink_1500_2232/0/1600609585359?e=1635379200&v=beta&t=vswWAu6IUczuvcPXMNPcyL1Y4RTORNzrYiHBLgucQDw)

## Amazon Glue Deep Dive:

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGcyLhEdHqFNQ/article-inline_image-shrink_1500_2232/0/1600609660319?e=1635379200&v=beta&t=2VSz9gNb_3UeJEdsygVteC4wPYVCGgvaa5xljWJKXJs)

![Robinhood Architecture](https://media-exp1.licdn.com/dms/image/C5612AQHRQCmJk501IA/article-inline_image-shrink_1500_2232/0/1600609706912?e=1635379200&v=beta&t=ndLY5vEF7apaxiov0VsU5Lo-yDo5Hk5V1auT1T2ZtEY)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHb0LcxPJwFOA/article-inline_image-shrink_1500_2232/0/1600609742345?e=1635379200&v=beta&t=BBVD2L2LAtmHCgHHiMUVy8RlGxDfTNe3Ty6nTzdOZ44)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGSzYpr0yTewA/article-inline_image-shrink_1500_2232/0/1600609780931?e=1635379200&v=beta&t=NYOhFqBVwjQrGjnUQwFR7jm01inwgjy89-L3wSObDJo)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGvWhuHAS-DDA/article-inline_image-shrink_1500_2232/0/1600609832032?e=1635379200&v=beta&t=yHO9IhJHctTaEzN-bUH7ZAgXXZmCepH_vvkEosKr0XA)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFiyKqIuHsTXA/article-inline_image-shrink_1500_2232/0/1600609899608?e=1635379200&v=beta&t=xh9C0Zpgbwq8YZjrcpsu5V7vgCbbxzyDs7SGqj37T_c)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQF7ULURSxbkOA/article-inline_image-shrink_1500_2232/0/1600609968617?e=1635379200&v=beta&t=xgLDEBhPgsfj16LnsG7Ce7eiOfPhdeRkrarjdm4lizA)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHPmovVUBU1rw/article-inline_image-shrink_1500_2232/0/1600610048413?e=1635379200&v=beta&t=dD-XIeDsABEmHjNXt8PzrMOBkNING0fIpC4QvFVZcdY)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQEfGixt0ZrdHA/article-inline_image-shrink_1500_2232/0/1600610098832?e=1635379200&v=beta&t=oEUHtqRvto-a0NwmTJMUFZgjs-3fQASWMgB8nfqHHtU)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGJDld3kKAuOA/article-inline_image-shrink_1500_2232/0/1600610161647?e=1635379200&v=beta&t=UmucQeASyUtvyiW_jvvz3izFZeRBLXXpRtAbqKD369k)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGCzl9DWwE5PQ/article-inline_image-shrink_1500_2232/0/1600610243904?e=1635379200&v=beta&t=qRAdzENzDA7mHZStk84ngR0g-ClCEriFw0oGZkWwnqY)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQH8GEm4mT1ikQ/article-inline_image-shrink_1500_2232/0/1600610316968?e=1635379200&v=beta&t=Pag3KZXpowHGpX8x9x9d5XcEmDe1oJsVkvuGgnsQ9Dw)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFCsOdWjbNuqA/article-inline_image-shrink_1500_2232/0/1600610363313?e=1635379200&v=beta&t=c8K5d_B-BiyNcg4aprCmFrOD9T8VkLphQxHGKzTWDMU)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQF259jUNOROIw/article-inline_image-shrink_1500_2232/0/1600610412320?e=1635379200&v=beta&t=w8-_QLaD02IKVOf6r8_cTP4rLTWSQxB89D2KkM92Jx4)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQG418BOgtLazw/article-inline_image-shrink_1500_2232/0/1600610470903?e=1635379200&v=beta&t=_xBQeuuMRoJvzH72jsPrmWo77ycphrmL9UKX672xOac)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQEq70tIYQkKcQ/article-inline_image-shrink_1500_2232/0/1600610510435?e=1635379200&v=beta&t=QZLlyZD7qoOcdgP9E0vvj_jL2c_BkLJQkcDnr0XOe_I)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHNJ1vjafbMjw/article-inline_image-shrink_1500_2232/0/1600610564233?e=1635379200&v=beta&t=VKTbQVNZUyLY2BPhUt480xYmrndL2BGeZbXVMbaeT5A)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFlKTJzzn2X0g/article-inline_image-shrink_1500_2232/0/1600650215829?e=1635379200&v=beta&t=GEUaPwTbTwHlXIfjn3aAD7TyJeaej5D4D9TF4fIL9xQ)



## Serverless Lake Formation :

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFC4wAqsYy7Ug/article-inline_image-shrink_1500_2232/0/1600650082165?e=1635379200&v=beta&t=Ebgc0bvFY-Uo8nAVsVNMT982FeWgc114nfsG2D7Wz-Q)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFjT-2QnlbASg/article-inline_image-shrink_1500_2232/0/1600650404640?e=1635379200&v=beta&t=01TwmqfSVeIvsTfHqYKYsZDZieD4w42uZBorciDS_EE)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGvtKFKqVnygQ/article-inline_image-shrink_1500_2232/0/1600650518226?e=1635379200&v=beta&t=1PN3mfDcMroUKbgPeuJ-cKWEni1rffgRGDCLfaj0las)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQEn30Se2N7VnA/article-inline_image-shrink_1500_2232/0/1600650639985?e=1635379200&v=beta&t=bDIsUiqXEhpJRMXicmifSkVrH_lT8jE1zKQ7Qh-ug1I)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGEQ4VSBG3loA/article-inline_image-shrink_1500_2232/0/1600650667077?e=1635379200&v=beta&t=7_j5_HKDIECqSezHADmN9rf7THAOM54ZjV3crWOetqI)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQEWIBgxTk6T3w/article-inline_image-shrink_1500_2232/0/1600650715770?e=1635379200&v=beta&t=zGPHmb4KTa3ArU1Uu4U-9SkCLJ9F2mqWxCmWMa3ooTs)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFKnT9OpVvCNA/article-inline_image-shrink_1500_2232/0/1600650760058?e=1635379200&v=beta&t=4Stof3roCcVvDsngv-nqM-vD5PlaF0dukTUFhkOsQGI)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGj8v8wWqNcTQ/article-inline_image-shrink_1500_2232/0/1600650786032?e=1635379200&v=beta&t=01SvsbwfHDE0csqSCIXtS5UbV38VGYmFQwyI3-IlR50)

##  

## **C. Data Aggregation/ETL**

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQEbWbGxzTEHgQ/article-inline_image-shrink_1500_2232/0/1600500573045?e=1635379200&v=beta&t=mNXL0HAt3_Amra4EUqifsH_YtW-qo2Z3ttTcFJwo1uM)

## Amazon Lake Formation

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQENW9hrbHzHMg/article-inline_image-shrink_1000_1488/0/1600957306409?e=1635379200&v=beta&t=OldLcl7y6irzfDh9mDCANqJ-tW7mkwU23P4H51kJlww)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQEwah2HIFs25Q/article-inline_image-shrink_1000_1488/0/1600957332068?e=1635379200&v=beta&t=7F-QYS0oF9CT_jxns27ZhJ3vz5BkRnjgHGOMzaPm1bc)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHeVkpBewmCHw/article-inline_image-shrink_1000_1488/0/1600957391038?e=1635379200&v=beta&t=rvN0a576m7REmNnJ3oNPEzEr2Il2AN_3-DSUDEx2xGQ)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGBCQ2PW6aJjQ/article-inline_image-shrink_1000_1488/0/1600957456010?e=1635379200&v=beta&t=IzO4VlTofkABpLPsvL0GORQv9qVzhDSgZ70-liB3obM)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQEicuoGB6DKNA/article-inline_image-shrink_1000_1488/0/1600957508459?e=1635379200&v=beta&t=w-Ke3Cfpo0Uh1O_N5B2COGIPBzHQEzOVHa0F-em2re8)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQEd12m5ckx_Zg/article-inline_image-shrink_1000_1488/0/1600957667482?e=1635379200&v=beta&t=GNK-XhRHaxJVg2Vhol2ar0r_5m0KGhq1AnHfdYC-w0k)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQE5iDCulrXxww/article-inline_image-shrink_1000_1488/0/1600957738762?e=1635379200&v=beta&t=JoNBV1YCO0Q26z-9nv6JgVzeF7TK9cV2NFowtYsTCUA)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHc6Tzj7cheIw/article-inline_image-shrink_1000_1488/0/1600957779802?e=1635379200&v=beta&t=_4KCEAQ4iBbN74K90wLiE5fjJyc1_xwmXU81BHUreXE)

<iframe class="center" frameborder="0" allowfullscreen="true" src="https://www.linkedin.com/embeds/publishingEmbed.html?articleId=7107777933680449475" height="314" width="744" title="Getting started with AWS Lake Formation | Amazon Web Services" data-li-src="https://www.linkedin.com/embeds/publishingEmbed.html?articleId=7107777933680449475" style="box-sizing: inherit; margin: 4.4rem auto; padding: var(--artdeco-reset-base-padding-zero); border: var(--artdeco-reset-base-border-zero); font-size: var(--artdeco-reset-base-font-size-hundred-percent); vertical-align: var(--artdeco-reset-base-vertical-align-baseline); background: var(--artdeco-reset-base-background-transparent); outline: var(--artdeco-reset-base-outline-zero); display: block; width: 744px; text-align: center;"></iframe>



## **D. Data Ingestion/Collection/PutObject/PutObjects**

1. Real Time/Streaming: Amazon Kinesis Data Streams, Amazon SQS, IoT, Apache Kafka, Amazon MSK(Managed Service For Kafka
2. Near Real Time / Reactive actions/ Interactive: Amazon Kinesis Data Firehouse, Amazon Database Migration System/DMS
3. Batch : Amazon Snowball, Amazon Data Pipeline

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQH1wDXdjeLThQ/article-inline_image-shrink_1500_2232/0/1600500460870?e=1635379200&v=beta&t=UddT4vgREZi3e1Qe0LmlZeHQ-sXOl4MG2TxsTHCQ60k)

## Amazon Kinesis Deep Dive:

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGrlicplED6Tw/article-inline_image-shrink_1500_2232/0/1600524685262?e=1635379200&v=beta&t=u8vnUi85On-EySvpeqIqbTxnm6Gs6qsC-tE3FSDjTk8)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFfU8AZG1N66w/article-inline_image-shrink_1500_2232/0/1600524751354?e=1635379200&v=beta&t=-7lWsYQiYfG5q6gfkhDrMOllpLb4rJpXqA0iFf2EKLw)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFqY8NNXXc0eA/article-inline_image-shrink_1500_2232/0/1600524788267?e=1635379200&v=beta&t=G84Q_UsnEPFG2k9Qef5ce4I2KvkV29eF5naPMQnI72w)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHlnzT_ICtO0w/article-inline_image-shrink_1500_2232/0/1600524864649?e=1635379200&v=beta&t=oqDBRC_TRHSD_DFpsP4tElUxHh1aEhqCqDCiH3BInBI)

## Kinesis Data Stream Producers:

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQH-I_jHNM1Oww/article-inline_image-shrink_1000_1488/0/1600524289925?e=1635379200&v=beta&t=8gMOOyaG3uuvlrX2TLUi_FYDGcff6zXyajso4Q9utvg)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHXblSyUw_RSw/article-inline_image-shrink_1500_2232/0/1600524334475?e=1635379200&v=beta&t=_k8fdKdmySPWRefJJNcEs52wkIODU1v4iT_NXQdlXmg)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFw0XUGxdYL0Q/article-inline_image-shrink_1500_2232/0/1600524353843?e=1635379200&v=beta&t=ERLXBpGWVJ1onSpdNr1ssw2Tcq8wgVfdGzcuQE4PcR8)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGxp6YfPcTjaQ/article-inline_image-shrink_1500_2232/0/1600524382709?e=1635379200&v=beta&t=BgJCYS0_xAX2hJzmwuj7d3l7fJR8uEFyUxzo37t2Dco)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGD7ZqaYP83rw/article-inline_image-shrink_1500_2232/0/1600524415530?e=1635379200&v=beta&t=8uSK3pYbvYfFhLjVKQ95rOraoFPBUm5TehIRt1IhL4Y)

## **Kinesis Data Stream Consumer :**

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQEDMpEMiT_ZLg/article-inline_image-shrink_1500_2232/0/1600521651208?e=1635379200&v=beta&t=aoOEQX41CooIOUD_qvJIy4-tvhXCzxex4vna0iSwd_o)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQE8TgTBut5Zng/article-inline_image-shrink_1000_1488/0/1600521895518?e=1635379200&v=beta&t=ZXdh-yc2dfCsggwdp4i4jSeYibsLK3uLxdj8D-mEm98)



![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFL5V3Fk6MQZQ/article-inline_image-shrink_1500_2232/0/1600521620511?e=1635379200&v=beta&t=rpBAJXjZJG_p0gvtm_nkLJiSdDkL5Vh7l1z6Qlmp0Bg)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHvpuJMOy631A/article-inline_image-shrink_1000_1488/0/1600521732801?e=1635379200&v=beta&t=Dkb_ke0b6gNpCm3v-KHVDQAj1bS6KeiTSMK-wKqG37g)

***Kinesis Connector Library is deprecated and been change to Lambda or Kinesis Firehouse\***

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGsvwNNHmUJbw/article-inline_image-shrink_1000_1488/0/1600521929911?e=1635379200&v=beta&t=6HNf0fY0uOiojRE-v1b-TjPP5v1O0BQbwYZg3PDwJuQ)

***Amazon Kinesis Enhanced Fan-Out\***

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFeg3HPiG2Yag/article-inline_image-shrink_1500_2232/0/1600522080772?e=1635379200&v=beta&t=cKl9J5LcqFgDKM3Cvybj9M4PjYg0ztAOOQd8jCo21CQ)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQE-Rt97o0MOYw/article-inline_image-shrink_1500_2232/0/1600522091691?e=1635379200&v=beta&t=v9xNYFPbPaRciCLIKWW2A2qhWnZ5NAt85LUllaYml54)

## Kinesis Scaling

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQEfRQ4DmaNgww/article-inline_image-shrink_1000_1488/0/1600525896926?e=1635379200&v=beta&t=7L4a2mKvnA4F-oeclbLeqLBdSzMcGm28QZ9eS2OToP4)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHRwDm0Ek4P-A/article-inline_image-shrink_1000_1488/0/1600525912760?e=1635379200&v=beta&t=Lm5usGNb-bcK6AtWVYyOAOUS7AWU4ULmHf7qUkXsgik)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQH6aqP765cxiA/article-inline_image-shrink_1000_1488/0/1600525927192?e=1635379200&v=beta&t=puGRjeTOPdFEuY5ij8WihQgVlaBq0zyAwfLcSvhOL7U)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFPmefb0hT54A/article-inline_image-shrink_1000_1488/0/1600525946720?e=1635379200&v=beta&t=eCquhtqlgjxVABFBkSpq9dFb5BTV-UCHujFJnjuOoAc)



## **Kinesis Data Firehouse**

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQH9PvkGRSgepA/article-inline_image-shrink_1500_2232/0/1600525186899?e=1635379200&v=beta&t=x13ZQxRWxnV-5erP4-ZeYE2g6kDSlwRN-8mxcuLxDx0)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGFiQ3MhDS-bA/article-inline_image-shrink_1500_2232/0/1600525553707?e=1635379200&v=beta&t=jMyxezG0B-JqTy9BeoQTAy75u_0mLB9WCj0qVHkopek)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGJupB9j3PFsw/article-inline_image-shrink_1500_2232/0/1600525572009?e=1635379200&v=beta&t=4LjhMQpx88rGCgl1pPdwCo_o5AcRtf9QmnjEN0JtJCE)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQG3vTE-00xMWg/article-inline_image-shrink_1500_2232/0/1600525602147?e=1635379200&v=beta&t=R1-hqgHanAM2wDlA2IKlB-705p7qTaXuwEuFQhxvz1Q)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHNfwrNgiIrEQ/article-inline_image-shrink_1500_2232/0/1600525625938?e=1635379200&v=beta&t=fEjU-yQW3pq0AY57U-GP3MdLoxRvvRRHTUn4nEwkT2U)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFSU8V0W3tzbA/article-inline_image-shrink_1000_1488/0/1600526303183?e=1635379200&v=beta&t=x8v7z7H-JmncOMJBgzqW1R9qJOfUFzi8akzwmXsV8rk)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFeUvo08Ep4Hg/article-inline_image-shrink_1000_1488/0/1600526321744?e=1635379200&v=beta&t=8L7D8fyeJGUJquODtqRMyUAOFFJZJ8PHg25ks4Ifpm4)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHZ9ubt6aqrUA/article-inline_image-shrink_1500_2232/0/1600526336737?e=1635379200&v=beta&t=aHCS9CEUONEq0B3ix8z7__LqNS43ryykatgg61eLe4A)

## **E. Data Retrieval Path/GetObject/GetObjects**



## **F. Data Analytics**

**Interactive & Batch Analytics**

1. Amazon ElasticSearch : managed service for elastic search
2. Amazon Redshift & Redshift Spectrum : Managed data warehouse and Spectrum enables querying S3(Data Lake)
3. Amazon Athena : Serverless interactive query service
4. Amazon EMR : Managed Hadoop framework for running Apache Spark, Flink, Presto, Tez, Hive, Pig, HBase, and others

**Predictive Analytics** : Machine Learning = Amazon Sagemaker

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGZSKsYdtqsbg/article-inline_image-shrink_1500_2232/0/1600500244132?e=1635379200&v=beta&t=E_15U3aZOJDhrOsG2UXylgxxPCAla648bb5oxRbQD6Y)

**Lake House Approach with Amazon Redshift and Amazon S3**

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQExZY31SKNSLg/article-inline_image-shrink_1500_2232/0/1601173012802?e=1635379200&v=beta&t=GAPF6T34cAhRXDdCqNV7TSeWH30RrcCDW3ltTUqWuzw)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHE8jRPBRp_rA/article-inline_image-shrink_1500_2232/0/1601173262342?e=1635379200&v=beta&t=em0iXpNM6zOxQiv4xbOSxVqRD8DQlxwR-f2DJ7wSPjg)

**Redshift Architectures**

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGi_E4Pdw41_A/article-inline_image-shrink_1500_2232/0/1601173694025?e=1635379200&v=beta&t=KbCkmUNzhqcQJrNJS_heVjjZj_J4OhQpfAP8AxxGYqY)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFSnrICy3CFLw/article-inline_image-shrink_1000_1488/0/1601173713521?e=1635379200&v=beta&t=NfZ_4f3k0CAg6o9rReCDK58EYx-ZKy60IIqSrjac2hI)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHikAlsTPSizw/article-inline_image-shrink_1000_1488/0/1601173732082?e=1635379200&v=beta&t=tGGYkoa5Ndu54UypEwmsy3Xy7ZfY6-RdPmJiLrbCOoE)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFW2aXEXyjbRw/article-inline_image-shrink_1000_1488/0/1601173742117?e=1635379200&v=beta&t=AZQAm2zsjf59P9skgeQf0bNznfQDmCkzFTrf6lY1fD4)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFbrOqHFLzudw/article-inline_image-shrink_1000_1488/0/1601173804968?e=1635379200&v=beta&t=6r48pXACWfOOn59cvjUDy9mO1swC08dQ89f6JniDUew)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGIk3FuLmC-aQ/article-inline_image-shrink_1000_1488/0/1601173845034?e=1635379200&v=beta&t=iX8YdTUaV-x1n0F1d0oVZE6yiLuDLyumQDWq_0bg0UI)

**Redshift ETL Data**

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQE_j8ukozaapg/article-inline_image-shrink_1000_1488/0/1601173964950?e=1635379200&v=beta&t=Cc_BSX3s9_JJLxoaNXDCGQ05wxv8K3hcYQY24-ea8U8)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQELz4qfMnqSSA/article-inline_image-shrink_1000_1488/0/1601174021645?e=1635379200&v=beta&t=I5mHoyk9najB7EbkSo9QTimOHSd9_9_JjaGyZnLwrcE)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGh1ZYsDCwwJg/article-inline_image-shrink_1500_2232/0/1601174073917?e=1635379200&v=beta&t=OuKcq_WiQb59H21cpIjzuKAiP8myxhVt6y1s3_frC5g)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHRzF3H_kMsQg/article-inline_image-shrink_1000_1488/0/1601174121918?e=1635379200&v=beta&t=S9YyksYzVuOLcc7mooixXa_Bh2LeX_fTKBwN4W9abTY)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGGoh_aRgEoDQ/article-inline_image-shrink_1000_1488/0/1601174135416?e=1635379200&v=beta&t=TsxDrJ0TKFg0QoWdWXlrnjabERD2B_Lt88PgnpfH0SQ)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQE4XKzuQk-wJA/article-inline_image-shrink_1500_2232/0/1601174187874?e=1635379200&v=beta&t=3BWFcv_jM8fa5XMEDnsp1P4NUZCgGXwYqE_MYqHpJSg)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHAtShlNMc0qA/article-inline_image-shrink_1500_2232/0/1601174229387?e=1635379200&v=beta&t=TjYYfEbWQcCqDKJUPWLDhtLk7ypJRfB8Riuw9GaON38)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQEBfC3h1hn9iQ/article-inline_image-shrink_1000_1488/0/1601174290944?e=1635379200&v=beta&t=sARDiJcNbr--OCYGN4GGj1QQoWYaqEWXAg_8TSYHbnc)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFOp_xvYsZJww/article-inline_image-shrink_1000_1488/0/1601174301463?e=1635379200&v=beta&t=HabgAUlWM9ErNZZN0L4rLaA8tzFqP4-lWAH_Bi76Bos)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFZ_eJUb4_V2A/article-inline_image-shrink_1000_1488/0/1601174315834?e=1635379200&v=beta&t=7dWqzwAZfeUGkO3PgnqLlGXdvNwRlZZ7hnqibLuyE_E)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHhpf5BPeLFXg/article-inline_image-shrink_1500_2232/0/1601174376837?e=1635379200&v=beta&t=DV_GrD9kjl3pHN9V16FdDnQvIQg80w_e-W73REsSPTc)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQEIqQjKoeElrw/article-inline_image-shrink_1000_1488/0/1601174437986?e=1635379200&v=beta&t=C9MItVV44uZnlogo40EmwOqxbZi2Jf4IaVd2djAr6hU)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFmuaA8J1Wl6g/article-inline_image-shrink_1500_2232/0/1601174562807?e=1635379200&v=beta&t=1kuJFVitwx_KEdjpMBfgNB-DQxYPmwZZvkVozarwS30)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQE2RSrw2sQAPg/article-inline_image-shrink_1500_2232/0/1601174575018?e=1635379200&v=beta&t=q0UdbRSXHT8KyIRmCgfZ5bzv6rs_VObR7MoaoUJPj4o)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHoTh8ioklm4Q/article-inline_image-shrink_1500_2232/0/1601174588126?e=1635379200&v=beta&t=VxQD0uNVwApkKT9hMdRTedYsvmPYr4vLgkH15o3xsl4)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQG1fJMlLExnww/article-inline_image-shrink_1500_2232/0/1601174602357?e=1635379200&v=beta&t=Hyxl6EsCSuyErfljLWX1CsYTXXmvxXO1VarNxRiK44I)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGLk9vqK9F5rw/article-inline_image-shrink_1000_1488/0/1601174629184?e=1635379200&v=beta&t=BiBHjO0WELrHNALWTihG_EfQYgl-x_AiMAF58IdH2OI)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGbQIncc7dAIA/article-inline_image-shrink_1000_1488/0/1601174639309?e=1635379200&v=beta&t=K-Ym3OTFmeOJ3_SAsUotfWZBkE3Oo54xkiKwNT3TbLY)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHdW8o4SsQM5A/article-inline_image-shrink_1000_1488/0/1601174659896?e=1635379200&v=beta&t=Ln1XatOZjKbd_LqY0DnTj_YACKSIYnFSFJmNJ_qEBrM)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQE68gHD9Vs23Q/article-inline_image-shrink_1500_2232/0/1601174910307?e=1635379200&v=beta&t=SDj83KAYLsHWdCSPWF9l1fQVOGR0yaAU9bpmHyjKZNQ)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGF5G8npNIflA/article-inline_image-shrink_1500_2232/0/1601174924136?e=1635379200&v=beta&t=CTNaM0L0ZPPYKjy1DmZtzLe030Y0VTVnl7RHiLOIm3w)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGMR6I5u3y91w/article-inline_image-shrink_1500_2232/0/1601174938164?e=1635379200&v=beta&t=99tIJzpZvgkvmAbSk6u06lUMeXIHu2dvzJXWxfBHXKw)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGFtt0GT8mJrw/article-inline_image-shrink_1500_2232/0/1601174951109?e=1635379200&v=beta&t=2FneeGSmzH1aZy2-vq3PgUi6SmNrMPVNPRzHPElqhHM)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFKlJ52E1r-Gw/article-inline_image-shrink_1500_2232/0/1601174965834?e=1635379200&v=beta&t=WYllbsaPSdUzD6WqZwHDCMeeT9xLzjkbvyo4L5eMH8k)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHSL2BknNggzQ/article-inline_image-shrink_1000_1488/0/1601175152047?e=1635379200&v=beta&t=XyK_o8PeTlnIJS4g2vBz3-ax9Mi3ZJ0uICzjQrzOAtE)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGT4Djn7gwJWA/article-inline_image-shrink_1000_1488/0/1601175167614?e=1635379200&v=beta&t=ObEdRQROHqX64c5fUAb0py9CWmp1KrT23o3uGPTaP9k)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQH-AxYqZvAMPA/article-inline_image-shrink_1000_1488/0/1601175182660?e=1635379200&v=beta&t=oq2Us3ZEWcJgelmFq9VdL_jn3uHD8_up3cP9wLkVBkg)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFxfyUHBewmcg/article-inline_image-shrink_1000_1488/0/1601175196983?e=1635379200&v=beta&t=cmGeIp-Ihvg_VTbKfxRno9f1brc-2TpN5oDlxnI0ZoQ)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQG554TwA4bNoQ/article-inline_image-shrink_1000_1488/0/1601175212575?e=1635379200&v=beta&t=9yelB2ZJl6enDSW_uEgfKYLQwIelyiQyXC0VMzqsQhs)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQG9VhG-hNu3Nw/article-inline_image-shrink_1500_2232/0/1601175249502?e=1635379200&v=beta&t=v96b10llmyIUi9l4IwrlkxleP0BUFHapBA5SzwoyJEE)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGlyZDvRAil1w/article-inline_image-shrink_1500_2232/0/1601175273256?e=1635379200&v=beta&t=K8I4RMLkR8IMsoSxVHJIDSA7y3nM-0ju8wGVFGqAy-Q)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQGUfdcKvaegfg/article-inline_image-shrink_1500_2232/0/1601175290420?e=1635379200&v=beta&t=d3SgnwDabseyrNgAizCHIFQjKPffpSB8mxCujLlu51I)





## **E. Data Technology Stack/Architecture**

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHxUsZdjzuwwQ/article-inline_image-shrink_1500_2232/0/1600500685568?e=1635379200&v=beta&t=vwTNnymeOkqR1aFWgZiZFloxpy67zaV_9_keKhuO7o4)





![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFz6WlHczX3zA/article-inline_image-shrink_1000_1488/0/1600402801274?e=1635379200&v=beta&t=Yjrs1dEHtuDic0QiOBT8V0aKER4yaclIgSykiw9yOrY)











**Big Data Best Practises / Step by Step Architecting Big Data :**

***1.Build decoupled system :\***

-Data-Store-Process-Store-Analyze-Answers

***2.Use the right tool for the job\***

-Data structure, latency, throughput, access patterns

***3.Leverage AWS managed and Serverless services\***

-Scalable/elastic, available, reliable, secure, no/low admin

***4.Use log-centric design patterns\***

-Immutable logs, data lake(S3), materialised views

***5.Be cost-conscious\***

-Big data doesn't mean Big Cost

***6.Machine Learning for Predictive Analysis\***

##  

## **Sample of Design Patterns :**

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQEYORlunE34Ow/article-inline_image-shrink_1500_2232/0/1600484653442?e=1635379200&v=beta&t=oiH3JINgD8pidyymRDNVZ1TxQiwX4wlpQm1nnTpjUXQ)



![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQF5awrcjhe5eQ/article-inline_image-shrink_1500_2232/0/1600500788060?e=1635379200&v=beta&t=eWhfQ-dSUKJg3qqkoNqnT5abDUbf9JI8LbHugRsE2zE)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFf6-JKoWWWlQ/article-inline_image-shrink_1500_2232/0/1600500827068?e=1635379200&v=beta&t=r_U57DVb0GrJVU5DYh0gS7IlEpdX-AqSAboveZHNkRQ)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFLAB1PME8FFw/article-inline_image-shrink_1500_2232/0/1600500872878?e=1635379200&v=beta&t=vo-gy2T_q61nzXzgQFZdmJOe0cIcV5ENXmk8GMfXHgY)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQHCvcay9gQM-w/article-inline_image-shrink_1500_2232/0/1600501049737?e=1635379200&v=beta&t=yzQ2voVXSbhPLvqaFFoj2dUaWPIghtixkRxrqTcrFuA)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFD5VHW5_ZtUg/article-inline_image-shrink_1500_2232/0/1600501072385?e=1635379200&v=beta&t=T9nsJDTErYyZ7KgZ2_PZQtPdYPjyn6wl_MPxfTC-4QU)

![No alt text provided for this image](https://media-exp1.licdn.com/dms/image/C5612AQFic_IkL7UsKg/article-inline_image-shrink_1500_2232/0/1600501090512?e=1635379200&v=beta&t=uuZY-xjIvT4OZFfdVrwQ42_EPsmxbLqZuydPVoY_uSs)