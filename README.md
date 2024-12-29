<h>Install and run Gophish from standard debian box</h> 

<p>
Step 1:		Register a domain where you can edit the records. Godaddy will do for this
Step 2:		Register/login at MailGun.
Step 3:		In mail gun go to "Get Started" > "Add a Custom Domain" and follow the steps there
Step 4:		If needed, authorize ports 80, 443 and 3333 in the firewall. This can be done in google cloud console by going to "Compute Eingine" > "VM instances" and then pasting the command:
gcloud compute firewall-rules create allow-ports-443-80-3333 --allow tcp:443,tcp:80,tcp:3333 --network default --priority 1000 --direction INGRESS --target-tags allow-ports-443-80-333 --description "Allow traffic on ports 443, 80, and 3333"
Step 5:		Run the Gophish installer script here with the command: "chmod +x install.sh; ./install.sh"
Step 6:		Run the configuration script for gophish with the command: "chmod +x ConfigureGophish.sh; ./ConfigureGophish.sh"
Step 7:		Login to the Gophish consule at https://(Instance IP address):3333 with the username and password provided by the installer script. (This can also be found in the installer.log file)

</p>
