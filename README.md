# Install and run Gophish from standard debian box 

## How to configure a campaign 

- Step 1:   Create an instance any cloud providor
- Step 2:		Register a domain where you can edit the records. Godaddy will do for this.
- Step 3:		Register/login at MailGun.
- Step 4:		In MailGun go to "Get Started" > "Add a Custom Domain" and follow the steps there to add the DNS records for MailGun
- Step 5:   Add the A record which points to the instance's public address.
- Step 6:		If needed, authorize ports 80, 443, and 3333 in the firewall. This can be done in Google Cloud console by going to "Compute Engine" > "VM instances" and then pasting the command:

<br>
gcloud compute firewall-rules create allow-ports-443-80-3333 --allow tcp:443,tcp:80,tcp:3333 --network default --priority 1000 --direction INGRESS --target-tags allow-ports-443-80-333 --description "Allow traffic on ports 443, 80, and 3333"
<br><br>

- Step 7:		Run the Gophish installer script here with the command: "chmod +x install.sh; ./install.sh"
- Step 8:		Run the configuration script for gophish with the command: "chmod +x ConfigureGophish.sh; ./ConfigureGophish.sh"
- Step 9:		Login to the Gophish console at https://(Instance IP address):3333 with the username and password provided by the installer script. (This can also be found in the installer.log file)
- Step 10:  Configure Gophish and MailGun with the username and password provided by going to mailgun.com > send > sending domains > SMTP credentials. These can be added to the Gophish sending profile.
