# cwjobs_scraper

A little while ago I watched an old PyCon talk about improving your life by writing simple, sloppy scripts that aren't tested or documented. Inspired by this, I wrote a simple, sloppy script that records how many jobs relevant to my skillset are added to CWJobs each day. The plan was to leave it running for a year or so and see what patterns exist in the job market.

I wrote the script in about five minutes. I then spent about two hours automating the AWS infrastructure needed to run it as a Lambda, schedule its execution, and persist its results to a database. I'm not sure if the guy who presented that talk would be happy with this or not.

Anyway, I wanted to talk about this a bit.

It feels like I've written a quick and dirty script to do what I want, and then set it to run in a massively over-engineered environment. The quick-and-dirty environment would be a cron job that fires the script every day and appends the result to a CSV file somewhere. What I actually have is a CloudWatch rule that fires my script and writes it to DynamoDB, a secure distributed key-value store with sophisticated query functionality.

I really don't know whether it would have been better to run this as a cron job on a virtual server somewhere. The problem with those sorts of scripts is that you don't have a manifest for them. You can forget they're there, and either they'll run forever on some box you don't notice you're paying a fiver a month for, or they'll silently fail at some point and you won't notice until you suddenly need them. In one sense, it's an improvement that there's all this monitoring apparatus and a monthly itemised AWS bill that'll remind me I did this.

That said, this isn't really what AWS Lambda is for. This script hits a webpage and then writes to a database, both of which are relatively slow network operations. It takes almost three seconds to complete. It doesn't matter too much because it only runs a few times a day, and it might not even register on my monthly AWS bill, but it still rankles. This does seem to be the "approved" AWS way of running scripts like this, but it's not like AWS are going to object to me running slow, expensive scripts on their platform.

Is there some PaaS out there, which I just don't know about, that schedules and executes scripts, wraps them in monitoring and logging apparatus, and persists their output to sensible places? Something that maintains a manifest of all the scripts you have, notifies you if they fail, and issues helpful reminders to make sure they're all still relevant?
