## Edits to humio.conf:
```
AUTHENTICATION_METHOD=saml
#

PUBLIC_URL=https://yoursite.com
#be sure to include either http:// or https:// or you'll get a protocol error

SAML_IDP_SIGN_ON_URL=https://login.microsoftonline.com/<YOUR_AAD_GUID>/saml2
#you'll get this from the SAML screen in AAD

SAML_IDP_ENTITY_ID=https://sts.windows.net/<YOUR_AAD_GUID>/
#you'll get this from the SAML screen in AAD

SAML_IDP_CERTIFICATE=/certs/humio-AAD-SSO.pem
#once you upload your cert to your Enterprise App in AAD, you'll download this response file 

AUTO_CREATE_USER_ON_SUCCESSFUL_LOGIN=true
#make sure there's not an extra L in successful(l)

SAML_GROUP_MEMBERSHIP_ATTRIBUTE=role
#note, you'll need to create this attribute in your AAD Enterprise App and name it "role"

AUTO_UPDATE_GROUP_MEMBERSHIPS_ON_SUCCESSFUL_LOGIN=true
#

PREFIX_AUTHORIZATION_ENABLED=true
#you'll need to create a 'view-role-prefix-auth.json' file for this to work
```

## Sample 'view-role-prefix-auth.json' file
```
{
  "views" : {
     "humio" : {
        "HumioUser" : "*",
        "HumioAdmin" : "*"
     },
      
     "humio-audit" : {
        "HumioUser" : "*",
        "HumioAdmin" : "*"
     },
  }
}
```
* Note, this example gives permissions to everything - that's what the astrisk means. You'll want to review the Humio docs and create your own queries to ensure these roles are locked down to your liking. 

## Instructions for creating the app in Azure Active Directory
* Login to https://portal.azure.com
* Open Enterprise Applications
* Create a new app
## Configure SAML
* Single Sign-on > select SAML
* Edit Basic SAML Configuration
1. Your Identifier / Entity ID will be `<YOUR_SITE_URL>/api/v1/saml/metadata`
2. Your Reply URL will be `<YOUR_SITE_URL>/api/v1/saml/acs`
3. Leave Sign-on url and Relay state blank
* Edit User Attributes and Claims
1. Add a new claim
2. Name = `role`
3. Source attribute = `user.assignedroles`
4. Leave Namespace blank
* Edit SAML signing certificate
1. Import certificate
2. Upload your pfx certificate > it needs to be encrypted with a password to add
3. CLick the 3 dots next to your new cert and set it to active
4. Click the three dots next to your new cert and download a PEM cert
5. You can delete the old cert here if you want
6. Download the pem cert to your humio server and place it where you place the rest of your certs
7. Edit your humio.conf file to include the path to this cert in `SAML_IDP_CERTIFICATE`
* Set up Humio by copying values to humio.conf
1. Copy the value from the Login URL box to `SAML_IDP_SIGN_ON_URL`
2. Copy the value from the Azure AD Identiier to `SAML_IDP_ENTITY_ID`
## Create Roles
* In AAD, go to App Registrations
* Open the app you just created
* Edit the manifest
* Under ` "appRoles": [` add the following, at the bottom, just above the closing `]`
```
    {
      "allowedMemberTypes": [
        "User"
      ],
      "displayName": "HumioAdministrator",
      "id": "30f71b1a-74db-4a0f-bae6-dcdd4bc8a57d",
      "isEnabled": true,
      "description": "Administrators can access all Repos",
      "value": "HumioAdministrator"
    },
    {
      "allowedMemberTypes": [
        "User"
      ],
      "displayName": "HumioUser",
      "id": "4722356f-1b76-4a8c-8c1e-91282e21affe",
      "isEnabled": true,
      "description": "Users can access all Repos",
      "value": "HumioUser"
    },
```
* Ensure your indentations are good
* Save
## Assign Roles
* Open your app under Enterprise Applications
* Select Users and Groups
* Assign users (or groups) to your app, the assign them to one of the two roles you just created
## Create authorizations for your roles
* Save the sample 'view-role-prefix-auth.json' file from the top of this page to your humio data directory (for me this was `/data/humio-data`)
## Rebuild your instance
* I use docker so I recreated my Humio instance at this point
## Login
* Give it a test drive! Users should be automatically created and assigned to the roles specified in AAD.
