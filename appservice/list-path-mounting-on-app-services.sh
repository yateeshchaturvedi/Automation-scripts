#set env value as "true" for which script is to be run
dev=false
stage=false
prod=true
	
#for Development Environment
if [ $dev == true ]
then
	echo -e "\n\n entering in dev env \n\n"
	#variables
	subscription="<subscription-name>"
	resourcegroup="<resource-group-name>"
	
	#set subscription for required resourcegroup
	az account set --subscription "$subscription"
	
    appnames=$(az webapp list --resource-group "$resourcegroup" --query "[].name" --output tsv)
	
    #convert string into string array
	appnamearray=($appnames)

	#for loop to parse every fileshare
	for appname in "${appnamearray[@]}"
	do
		#print the name of appservice
		echo -e "\n AppName = $appname"

        az webapp config storage-account list --name $appname --resource-group "$resourcegroup" --query "[].value.{mountPath: mountPath, shareName: shareName}" -o json

				
		
	done
fi

#for Stage Environment
if [ $stage == true ]
then
	echo -e "\n\n entering in stage env \n\n"
	#variables
	subscription="<subscription-name>"
	resourcegroup="<resource-group-name>"
	
	#set subscription for required resourcegroup
	az account set --subscription "$subscription"
	
    appnames=$(az webapp list --resource-group "$resourcegroup" --query "[].name" --output tsv)
	
    #convert string into string array
	appnamearray=($appnames)

	#for loop to parse appservice name
	for appname in "${appnamearray[@]}"
	do
		#print the name of appservice name
		echo -e "\n AppName = $appname"

        az webapp config storage-account list --name $appname --resource-group "$resourcegroup" --query "[].value.{mountPath: mountPath, shareName: shareName}" -o json

	done
fi

#for Produciton Environment
if [ $prod == true ]
then
	echo -e "\n\n entering in prod env \n\n"
	#variables
	subscription="<subscription-name>"
	resourcegroup="<resource-group-name>"
	
	#set subscription for required resourcegroup
	az account set --subscription "$subscription"
	
	appnames=$(az webapp list --resource-group "$resourcegroup" --query "[].name" --output tsv)
	
    #convert string into string array
	appnamearray=($appnames)

	#for loop to parse every fileshare
	for appname in "${appnamearray[@]}"
	do
		#print the name of appservice name
		echo -e "\n AppName = $appname"
	
        az webapp config storage-account list --name $appname --resource-group "$resourcegroup" --query "[].value.{mountPath: mountPath, shareName: shareName}" -o json
		
	done
fi
