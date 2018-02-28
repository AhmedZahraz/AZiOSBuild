# AZiOSBuild
Bash script to sign your iOS apps manully, wihtout passing by Xcode.

Concretely, this script: <br>
*  Import the p12 file, passed in args, to your Keychain System
*  Install the provisioning profile, passed in args
*  Archive the project
*  Create signed iPA
