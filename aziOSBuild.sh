#!/bin/bash  

#ARGS
XCODE_PROJ_OR_XCWORKSPACE_PATH=""
ARCHIVE_PATH=""
EXPORT_PATH=""
P12_PATH=""
P12_PASSWORD=""
PROVISIONING_PROFILE_PATH=""
CONFIGURATION=""
SCHEME=""
SDK=""

UUID=""
PROJECT_EXTENSION=""
CERT_NAME=""
TEAM_ID="" 

function checkArgs()
{
	if [ "$#" == 0 ]; then
		echo "***************************************************************************************"
		echo "1- Please enter your Project xcodeproj or xcworkspace path:"
		echo "***************************************************************************************"
    	read XCODE_PROJ_OR_XCWORKSPACE_PATH
    	echo "***************************************************************************************"
    	echo "2- Please enter your Export path (the generated IPA will be created at this location):"
    	echo "***************************************************************************************"
    	read EXPORT_PATH
    	echo "***************************************************************************************"
    	echo "3- Please enter your P12 file path:"
    	echo "***************************************************************************************"
    	read P12_PATH
    	echo "***************************************************************************************"
    	echo "4- Please enter your P12 file password:"
    	echo "***************************************************************************************"
    	read P12_PASSWORD
    	echo "***************************************************************************************"
    	echo "5- Please enter your provisioningProfile path:"
    	echo "***************************************************************************************"
    	read PROVISIONING_PROFILE_PATH
    	echo "***************************************************************************************"
    	printf "6- Please enter your Project Configuration (release, debug, ..ect).\n   Notice that uou can run xcodebuild -list in your project folder to see the list of configuration(s) and scheme(s):\n"
    	echo "***************************************************************************************"
    	read CONFIGURATION
    	echo "***************************************************************************************"
    	printf "7- Please enter your Project Scheme.\n  Notice that You can run xcodebuild -list in your project folder to see the list of configuration(s) and scheme(s):\n"
    	echo "***************************************************************************************"
    	read SCHEME
    	echo "***************************************************************************************"
    	printf "8- Please enter the SDK name (iphoneos11.2, ..ect).\n  Notice that you can run xcodebuild -showsdks to see the list of installed sdk:\n"
    	echo "***************************************************************************************"
    	read SDK
	elif [ "$#" -lt 7 ]; then
    	echo "Not enough arguments : you should pass XCODE_PROJ_OR_XCWORKSPACE_PATH EXPORT_PATH P12_PATH P12_PASSWORD PROVISIONING_PROFILE_PATH CONFIGURATION SCHEME SDK in this order (SDK is not required) - You can run xcodebuild -list in your project folder to see the list of configuration(s) and scheme(s) - You can run xcodebuild -showsdks to see the list of installed sdk"
    	exit
	else 
		#init vars
		while [[ $# -gt 0 ]]
		do
		key="$1"

		case $key in			
		    -e|-project)
		    XCODE_PROJ_OR_XCWORKSPACE_PATH="$2"
		    shift # past argument
		    shift # past value
		    ;;
		    -s|-exportPath)
		    EXPORT_PATH="$2"
		    shift # past argument
		    shift # past value
		    ;;
		    -l|-p12Path)
		    P12_PATH="$2"
		    shift # past argument
		    shift # past value
		    ;;
		    -l|-p12Password)
		    P12_PASSWORD="$2"
		    shift # past argument
		    shift # past value
		    ;;
		    -l|-provisioningProfilePath)
		    PROVISIONING_PROFILE_PATH="$2"
		    shift # past argument
		    shift # past value
		    ;;
		    -l|-configuration)
		    CONFIGURATION="$2"
		    shift # past argument
		    shift # past value
		    ;;
		    -l|-scheme)
		    SCHEME="$2"
		    shift # past argument
		    shift # past value
		    ;;
		    -l|-sdk)
		    SDK="$2"
		    shift # past argument
		    shift # past value
		    ;;
		esac
		done
		# XCODE_PROJ_OR_XCWORKSPACE_PATH=$1
		# EXPORT_PATH=$2
		# P12_PATH=$3
		# P12_PASSWORD=$4
		# PROVISIONING_PROFILE_PATH=$5
		# CONFIGURATION=$6
		# SCHEME=$7
		# SDK=$8
	fi

	projectName=$(basename "$XCODE_PROJ_OR_XCWORKSPACE_PATH")
	PROJECT_EXTENSION="${projectName##*.}"

  	if [ ! -e "${XCODE_PROJ_OR_XCWORKSPACE_PATH}" ]; then
    	echo "XCODE_PROJ_OR_XCWORKSPACE_PATH not found, verify your path "$XCODE_PROJ_OR_XCWORKSPACE_PATH
    	exit
    elif [ "$PROJECT_EXTENSION" != "xcodeproj" ] && [ "$PROJECT_EXTENSION" != "xcworkspace" ]; then
    	echo "XCODE_PROJ_OR_XCWORKSPACE_PATH should be with 'xcodeproj' or 'xcworkspace' extension"
    	exit
  	elif [ ! -e "${EXPORT_PATH}" ]; then
  		mkdir -p "$EXPORT_PATH"
  		if [ $? -eq 0 ]; then
    		echo "EXPORT PATH created : "$EXPORT_PATH
		else
    		echo "EXPORT_PATH is invalid : verify your path "$EXPORT_PATH
    		exit
		fi
   	elif [ ! -e "${P12_PATH}" ]; then
    	echo "P12_PATH not found, verify your path "$P12_PATH
    	exit
   	elif [ ! -e "${PROVISIONING_PROFILE_PATH}" ]; then
    	echo "PROVISIONING_PROFILE_PATH not found, verify your path "$PROVISIONING_PROFILE_PATH
    	exit
  	else
     	echo "build start ..."
  	fi
}

#Extract Cert Name from p12 File then, TEAM_ID from name
function extractTeamID()
{
####pyhton based solution
CERT_NAME=$(python - "$P12_PATH" "$P12_PASSWORD" <<END 
import sys
from OpenSSL.crypto import *
p12 = load_pkcs12(file(sys.argv[1], 'rb').read(), sys.argv[2])
print(p12.get_friendlyname())
END)
#####bash based solution
#CERT_NAME=$(openssl pkcs12 -in "$P12_PATH" -nodes -passin pass:"$P12_PASSWORD" | openssl x509 -noout -subject | awk -F'[=/]' '{print $6}')
if [ -z "$CERT_NAME" ]; then
	echo "Error 1 : cannot extract TeamID from p12 file : verify your password"
    exit
fi
TEAM_ID=$(echo $CERT_NAME | cut -d "(" -f2 | cut -d ")" -f1)
if [ -z "$TEAM_ID" ]; then
	echo "Error 2 : cannot extract TeamID from p12 file"
    exit
fi
echo "Team ID = "$TEAM_ID
}

#Extract UUID from Provisioning profile
function extractUUID() {
	if [ -z "$PROVISIONING_PROFILE_PATH" ]; then
		echo "Error 3 : PROVISIONING_PROFILE_PATH not found in path "$PROVISIONING_PROFILE_PATH
    	exit
	fi
	UUID=$(grep "<key>UUID</key>" "$PROVISIONING_PROFILE_PATH" -A 1 --binary-files=text | sed -E -e "/<key>/ d" -e "s/(^.*<string>)//" -e "s/(<.*)//")
	if [ -z "$UUID" ]; then
	echo "Error 4 : cannot extract UUID from your PROVISIONING_PROFILE_PATH."
    exit
	fi
	echo "UUID = "$UUID
}

# Import p12 to system keychain
function importP12ToSystemKeychain() {
	if [ -z "$P12_PATH" ]; then
		echo "Error 5 : P12_PATH not found in path "$P12_PATH
    	exit
	fi
	security import "${P12_PATH}" -P $P12_PASSWORD
	if [ $? -eq 0 ]; then
    	echo "P12 file imported to your system keychain"
	else
    	echo "Error 6 : cannot import your P12 file to your system keychain : verify the file password"
    	exit
	fi
}

# Install provisioning Profile <==> copy it to $HOME/Library/MobileDevice/Provisioning Profiles/
function installProvisioningProfile() {
	if [ -z "$PROVISIONING_PROFILE_PATH" ]; then
		echo "Error 9 : PROVISIONING_PROFILE_PATH not found in path "$PROVISIONING_PROFILE_PATH
    	exit
	fi
	cp "${PROVISIONING_PROFILE_PATH}" "$HOME/Library/MobileDevice/Provisioning Profiles/${UUID}.mobileprovision"
	if [ $? -eq 0 ]; then
    	echo "Install provisioning Profile OK"
	else
    	echo "Error 9 : cannot copy your PROVISIONING_PROFILE file to your system keychain : $HOME/Library/MobileDevice/Provisioning Profiles/"
    	exit
	fi
}

#create exportOptionsPlist
function createExportOptionsPlistFile() {
	if [ -z "$UUID" ]; then
		echo "Error 7 : UUID is empty"
    	exit
	fi
	if [ -z "$TEAM_ID" ]; then
		echo "Error 8 : teamID is empty"
    	exit
	fi
	exportOptions='<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">
	<dict>
	    <key>provisioningProfiles</key>
	    <dict>
	        <key>com.trigonetech.ayruu</key>
	        <string>'$UUID'</string>
	    </dict>
	    <key>method</key>
	    <string>app-store</string>
	    <key>teamID</key>
	    <string>'$TEAM_ID'</string>
	</dict>
	</plist>'
	echo $exportOptions >> exportOptions.plist
	#tee exportOptions.plist <<<$exportOptions
	if [ $? -eq 0 ]; then
    	echo "File exportOptions.plist created."
	else
    	echo "Error 10 : cannot create exportOptions.plist"
    	exit
	fi
}

function createArchive() {
	if [ -z "$CONFIGURATION" ]; then
		echo "Error 12 : CONFIGURATION is empty"
    	exit
	fi
	if [ -z "$SCHEME" ]; then
		echo "Error 13 : SCHEME is empty"
    	exit
	fi
	if [ -z "$SDK" ]; then
		SDK="iphoneos"
	fi
	ARCHIVE_PATH="./autoCreatedArchive.xcarchive"
	#xcodebuild -project TestResignApp.xcodeproj -target TestResignApp -sdk iphoneos11.2 -configuration Release -archivePath /Users/ahmed/Documents/ProjectRetD/TestResignApp/myArchive/ahmedArchiveNew.xcarchive  -scheme TestResignApp PROVISIONING_PROFILE_SPECIFIER="AyruuProvisioningProfilesDistribution" CODE_SIGN_IDENTITY="iPhone Distribution: Trigone Tech (HLHA86H3UL)" archive
	if [ "$PROJECT_EXTENSION" == "xcodeproj" ]; then
		PROJECT_INPUT_TYPE="project"
	elif [ "$PROJECT_EXTENSION" == "xcworkspace" ]; then
		PROJECT_INPUT_TYPE="workspace"
	else
		echo "Invalid project type : "$XCODE_PROJ_OR_XCWORKSPACE_PATH" should be with xcodeproj or xcworkspace extention"
		exit
	fi
	xcodebuild -"${PROJECT_INPUT_TYPE}" "${XCODE_PROJ_OR_XCWORKSPACE_PATH}" -sdk $SDK -configuration $CONFIGURATION -archivePath $ARCHIVE_PATH -scheme "${SCHEME}" PROVISIONING_PROFILE_SPECIFIER=$UUID CODE_SIGN_IDENTITY="${CERT_NAME}" archive
	if [ $? -eq 0 ]; then
    	echo "Archive file created."
	else
    	echo "Error 11 : cannot create archive file"
    	exit
	fi
}

function createIPA() {
	#xcodebuild -exportArchive -archivePath /Users/ahmed/Documents/ProjectRetD/TestResignApp/myArchive/ahmedArchiveNew.xcarchive -exportOptionsPlist exportOptions.plist -exportPath $PWD/build
	xcodebuild -exportArchive -archivePath "${ARCHIVE_PATH}" -exportOptionsPlist exportOptions.plist -exportPath "${EXPORT_PATH}"
	if [ $? -eq 0 ]; then
    	echo "IPA file created at "$EXPORT_PATH
	else
    	echo "Error 14 : cannot create ipa file"
    	exit
	fi
}

checkArgs "$@"
extractTeamID
extractUUID
importP12ToSystemKeychain
installProvisioningProfile
createExportOptionsPlistFile
createArchive
createIPA