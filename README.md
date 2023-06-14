Options for not duplicating

1. Having this be ordered
1. Having a parent module of replication call the child module. The parent module makes the

My goals for this module are to avoid having to run code in a specific order.

This will lead to some conessions though, mainly that the module will have to create and control the s3 buckets that are being replicated. Without this being done, there will also be some way you could run the modules which was cause this not to work

This will then limit the ability to make a module a replica of what it is supposed to be

----

Scratch all of that,
