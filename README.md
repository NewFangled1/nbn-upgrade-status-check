# nbn-upgrade-status-check

The Australian National Broadband Network (NBN) announced an on-demand upgrade program for select premises serviced via Fibre to the Node (FTTN) and Fibre to the Curb (FTTC) to Fibre to the Premises (FTTP) in October 2020.

NBN has progressively announced towns and suburbs where FTTN users will be eligible for a FTTP upgrade (FTTC areas aren't disclosed by NBN).

The details regarding actual availability of the program are limited with not all households in announced suburbs eligible for upgrades.

I wrote this bash script to periodically fetch data from the NBN API for a specific premises and email if there are any changes in the data. The purpose is to know when the free fibre upgrade is available (or at least when there is some change in status) for the premises without having to manually check with the NBN's address checker.
he script only looks for changes in the following fields:
- altReasonCode
- techChangeStatus
- programType
- targetEligibilityQuarter
- techFlip

I run the script on a Synology NAS using the Task Scheduler, but you are welcome to try on other devices.

**How to run**

Place the script in a suitable location. For a NAS, preferably locate in a shared directory rather than a system directory to avoid permissions issues. For example in: /volume1/data/Scripts/NBN_Lookup
Add to Task Scheduler to run periodically (e.g. once a day). The script is run like:
bash /(ScriptLocation)/NBN_API_Fetch.sh (LocationID) (Email address) (Name) (Send data on Friday?)

Where:
(LocationID) is the unique Id for the premises. It can be found by putting your address in: https://www.aussiebroadband.com.au/nbn-poi/

(Email address) is the address to send emails to

(Name) a unique name. This is used because script may monitor multiple premises, this name is used as part of the text file that stores the data and also part of the subject of emails

(Send data on Friday?) Set to Yes to send the fetched data on a Friday regardless if the data has changed. I use this because I want to receive emails periodically to know the script is still working. Setting to anything else (e.g. No), will mean emails are only sent when the data changes

For example:
bash /volume1/data/Scripts/NBN_Lookup/NBN_API_Fetch.sh LOC000000000000 example@email.com Bob Yes

**Some things to note**
- The script will create a text file in the same location as the script. This is used to store the data and check against to see if the data has changed.
- To check multiple premises, add a separate instance to task scheduler and make sure to use a different <Name>. Probably a good idea to run at different times too 
- The script will email the data the first time the script is run (check in the junk folder)
- The script assumes the device already has an FROM email address setup with correct server settings etc. I used a new Gmail address in my NAS
- Don't set this to run too often. The data changes rarely. So something like once a day is suitable
