This is the rough guideline on how to deliver the infra scaling presentation, note that you do not have to strictly follow this and understand that the slides were made with this flow in mind.

slide 1 - Introduce topic, explain that we will examine how to tackle system design using concepts we have went through and introduce storage concept with this exercise

slide 2 - Derp Image to show how app works, explain user flow, upload, search, and download

slide 3 - Explain what features we will need: Upload, Download, Search, Metadata to build this app, maybe go into details what's metadata and why we need it

slide 4 - Explain what cloud storage we will be using, brief explaination

slide 5 - Introduce the start of single server, maybe with a question on how to start

slide 6 - Explain how the services work together in the server, Upload/Download/Search as apis, Storage and Metadata are internal services to interact with the storage layers

slide 7 - Introduce scaling to 100 users, question on what could break first (storage from photos)

slide 8 - Explain the cloud storage options, benefits / trade-offs you could use for photos between EBS, EFS and S3

slide 9 - End up with s3 and explain your choice

slide 10 - Introduce scaling to 10000 users, explain what could happen, basically alot of problems with the services

slide 11 - Introduce microservices, explain the choices made based on the problems and scaling search + metadata with replicas

slide 12 - Throw problem on AZ going down

slide 13 - Show replication by AZ, explain how it provides high availability and focus on availability over performance, also explain how ALB distribute traffic between AZs. Prompt audience if there are any problem with this design (metadata storage still in local)

sldie 14 - Introduce the problem with the design

slide 15 - Explain the 2 solutions: sharding or shared storage, on how they work + benefits + tradeoff

slide 16 - End up with EFS and explain your choice

slide 17 - Introduce scaling to 50k to 100k users, with question on different regions

slide 18 - Introduce new problem also, EFS is region bounded, maybe can ask audience what solution they can think of

slide 19 - Don't care what the audience say and show multi-region solution, explain how it works: metadata migrate to dynamodb + global tables, services replicated across regions to serve based on geolocation routing solution (route 53 / global accelerator, can omit and dunnid to go into details)

slide 20 - Final problem, Introduce scaling 1mil users

slide 21 - Show and explain caching, use S3 lifecycle to migrate less visited photos to cheaper storage options

slide 22 - Final explaination (everyone is probably dead at this point so you can roughly go throuh it)