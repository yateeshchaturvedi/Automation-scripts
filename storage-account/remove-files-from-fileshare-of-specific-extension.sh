#set env value as "true" for which script is to be run
dev=false
stage=false
prod=true

#azure login in shell
# az login
# sleep 30
	
#for Development Environment
if [ $dev == true ]
then
	echo -e "\n\n entering in dev env \n\n"
	#variables
	subscription="<subscription-name>"
	resourcegroup="<resource-group-name>"
	storageaccount="<storage-account-name>"
	
	#set subscription for required resourcegroup
	az account set --subscription "$subscription"
	
	#generate account key for storage account
	accountkey=$(az storage account keys list -g $resourcegroup -n $storageaccount --query [0].value -o tsv)

	#get all the names of fileshares stored in azure storage account	
	sharename=$(az storage share list --account-key $accountkey --account-name $storageaccount | grep -i "name" | awk '{ print $2 } ' | sed 's/,,*$//')

	#removes double quotes from "sharename" string
	allfileshares=`sed -e 's/^"//' -e 's/"$//' <<<"$sharename"`
	
	#convert string into string array
	filesharearray=($allfileshares)
	
	#for loop to parse every fileshare
	for fileshare in "${filesharearray[@]}"
	do
		#print the name of file share
		echo -e "\n filesharename = $fileshare" 
		
		#get all the files stored inside of given fileshare having pattern as ".sql.gz" & ".sql"
		files=$(az storage file list --share-name "$fileshare" --account-name $storageaccount --account-key $accountkey | grep -i "Name" | awk '{ print $2 } ' | sed 's/,,*$//' | grep -i ".tar.gz")
			echo ${files[@]}
		
		#delete all the files having pattern as ".sql.gz"
		az storage file delete-batch --account-key $accountkey --account-name $storageaccount --source "$fileshare" --pattern '*.sql.gz' --dryrun
		#delete all the files having pattern as ".sql"
		az storage file delete-batch --account-key $accountkey --account-name $storageaccount --source "$fileshare" --pattern '*.sql' --dryrun
		#delete all the files having pattern as ".tar.gz"
		az storage file delete-batch --account-key $accountkey --account-name $storageaccount --source "$fileshare" --pattern '*.tar.gz' --dryrun
				
		
	done
fi

#for Stage Environment
if [ $stage == true ]
then
	echo -e "\n\n entering in stage env \n\n"
	#variables
	subscription="<subscription-name>"
	resourcegroup="<resource-group-name>"
	storageaccount="<storage-account-name>"
	
	#set subscription for required resourcegroup
	az account set --subscription "$subscription"
	
	#generate account key for storage account
	accountkey=$(az storage account keys list -g $resourcegroup -n $storageaccount --query [0].value -o tsv)

	#get all the names of fileshares stored in azure storage account
	sharename=$(az storage share list --account-key $accountkey --account-name $storageaccount | grep -i "name" | awk '{ print $2 } ' | sed 's/,,*$//')

	#removes double quotes from "sharename" string
    allfileshares=`sed -e 's/^"//' -e 's/"$//' <<<"$sharename"`
	
	#convert string into string array
	filesharearray=($allfileshares) #convert string into an array
	
	#for loop to parse every fileshare
	for fileshare in "${filesharearray[@]}"
	do
		#print the name of file share
		echo -e "\n newfileshare = $fileshare" 
		
		#get all the files stored inside of given fileshare having pattern as ".sql.gz" & ".sql"
		files=$(az storage file list --share-name "$fileshare" --account-name $storageaccount --account-key $accountkey | grep -i "Name" | awk '{ print $2 } ' | sed 's/,,*$//' | grep -i ".sql.gz\|.sql")
			echo ${files[@]}
		
		#delete all the files having pattern as ".sql.gz"
		az storage file delete-batch --account-key $accountkey --account-name $storageaccount --source "$fileshare" --pattern '*.sql.gz' --dryrun
		
		#delete all the files having pattern as ".sql"
		az storage file delete-batch --account-key $accountkey --account-name $storageaccount --source "$fileshare" --pattern '*.sql' --dryrun
	done
fi

#for Produciton Environment
if [ $prod == true ]
then
	echo -e "\n\n entering in prod env \n\n"
	#variables
	subscription="<subscription-name>"
	resourcegroup="<resource-group-name>"
	storageaccount="<storage-account-name>"
	
	#set subscription for required resourcegroup
	az account set --subscription "$subscription"
	
	#generate account key for storage account
	accountkey=$(az storage account keys list -g $resourcegroup -n $storageaccount --query [0].value -o tsv)

	#get all the names of fileshares stored in azure storage account
	sharename=$(az storage share list --account-key $accountkey --account-name $storageaccount | grep -i "name" | awk '{ print $2 } ' | sed 's/,,*$//')

	#removes double quotes from "sharename" string
    allfileshares=`sed -e 's/^"//' -e 's/"$//' <<<"$sharename"`
	
	#convert string into string array
	filesharearray=($allfileshares) #convert string into an array
	
	#for loop to parse every fileshare
	for fileshare in "${filesharearray[@]}"
	do
		#print the name of file share
		echo -e "\n newfileshare = $fileshare" 
		
		#get all the files stored inside of given fileshare having pattern as ".sql.gz" & ".sql"
		files=$(az storage file list --share-name "$fileshare" --account-name $storageaccount --account-key $accountkey | grep -i "Name" | awk '{ print $2 } ' | sed 's/,,*$//' | grep -i ".sql.gz\|.sql")
			echo ${files[@]}
		
		#delete all the files having pattern as ".sql.gz"
		az storage file delete-batch --account-key $accountkey --account-name $storageaccount --source "$fileshare" --pattern '*.tar.gz' --dryrun
		
		#delete all the files having pattern as ".sql"
		az storage file delete-batch --account-key $accountkey --account-name $storageaccount --source "$fileshare" --pattern '*.tar' --dryrun
	done
fi
