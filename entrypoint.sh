#!/bin/sh -l

TFC_ORG_NAME=$(echo $1)
TFC_ORG_EMAIL=$(echo $2)
TFC_WS=$(echo $3)
TFC_TOKEN=$(echo $4)
TFC_HOST=$(echo $5)

# Create Organization
printf "\nCreate organization:%s" "$TFC_ORG_NAME"
sed "s/TFC_ORG_NAME/$TFC_ORG_NAME/; s/TFC_ORG_EMAIL/$TFC_ORG_EMAIL/" < /tmp/organization.payload > organization.json
organization_id=$(curl  --header "Authorization: Bearer $TFC_TOKEN" --header "Content-Type: application/vnd.api+json" --request POST --data @organization.json "https://$TFC_HOST/api/v2/organizations" | jq -r ".data.id")
echo "::set-output name=organization_id::$organization_id"

#Create Workspaces
for workspace in $TFC_WS
do
  # Create Workspace
  printf "\nCreate workspace:%s" "$workspace"
  sed "s/TFC_WS/$workspace/" < /tmp/workspace.payload > workspace.json
  workspace_id=$(curl -s --header "Authorization: Bearer $TFC_TOKEN" --header "Content-Type: application/vnd.api+json" --request POST --data @workspace.json "https://$TFC_HOST/api/v2/organizations/$TFC_ORG_NAME/workspaces" | jq -r ".data.id")
  echo "::set-output name=workspace_id_$workspace::$workspace_id"

#  # Create / Update Variables
#  IFS=$'\n' # To ignore whitespaces in line
#  for variable in $(echo $TFC_WS | jq -rc ".$workspace[]"); # JQ will output all variables in a single line
#  do
#    key=$(echo $variable | jq -rc ".key")
#    value=$(echo $variable | jq -rc ".value" | sed -e 's/[]\/$*.^[]/\\&/g') # this variable needs to be escaped
#    sensitive=$(echo $variable | jq -rc ".sensitive")
#    category=$(echo $variable | jq -rc ".category")
#
#    printf "\nCreate variable %s" "$key"
#    sed -e "s/TFC_VAR_KEY/$key/" -e "s/TFC_VAR_VALUE/$value/" -e "s/TFC_VAR_SENSITIVE/$sensitive/" -e "s/TFC_VAR_CATEGORY/$category/" < /tmp/variable.payload  > payload.json
#    variable_id=$(curl -s --header "Authorization: Bearer $TFC_TOKEN" --header "Content-Type: application/vnd.api+json" --request POST --data @payload.json "https://$TFC_HOST/api/v2/workspaces/$workspace_id/vars" | jq -r ".data.id")
#    echo "::set-output name=variable_id_$key::$variable_id"
#  done
done


#Clean existing variables
#printf "\nClear existing variables"
#curl -s --header "Authorization: Bearer $TFC_TOKEN" --header "Content-Type: application/vnd.api+json" "https://$TFC_HOST/api/v2/workspaces/$wid/vars" > vars.json
#x=$(cat vars.json | jq -r ".data[].id" | wc -l | awk '{print $1}')
#i=0
#while [ $i -lt $x ]
#do
#  curl -s --header "Authorization: Bearer $TFC_TOKEN" --header "Content-Type: application/vnd.api+json" --request DELETE "https://$TFC_HOST/api/v2/workspaces/$wid/vars/$(cat vars.json | jq -r ".data[$i].id")" > logs.txt
#  i=`expr $i + 1`
#done

