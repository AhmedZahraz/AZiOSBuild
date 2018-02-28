# AZiOSBuild
Bash script to sign your iOS apps manually, wihtout passing by Xcode.

Concretely, this script: <br>
*  Import the p12 file, passed in args, to your Keychain System
*  Install the provisioning profile, passed in args
*  Archive the project
*  Create signed iPA

How it works
------------

*  [Download AZiOSBuild.zip](https://github.com/AhmedZahraz/AZiOSBuild/archive/master.zip) <br><br>
*  Extract aziOSBuild.sh and run:<br>
           `chmod +x aziOSBuild.sh`<br><br>
*  Run script: <br>
    *  without options <br>
    `./aziOSBuild.sh`<br>
    *  with [options](#options) <br>
`./aziOSBuild.sh -project /.../TestApp.xcodeproj -exportPath /.../FolderIPA -p12Path /.../CertificatsPrive.p12  -p12Password "test" -provisioningProfilePath /.../ProvisioningProfilesDistribution.mobileprovision -configuration release -scheme TestApp`

Options
------------

| Options        | Commentary  | required  |
| ------------- |:-------------:| -----:|
| -project      | path to xcodeproj or xcworkspace | Yes |
| -exportPath      | the generated iPA location    | Yes |
| -p12Path | path to p12 file      | Yes |
| -p12Password | password of p12 file      | Yes |
| -provisioningProfilePath | path to the provisioning profile | Yes |
| -configuration | project configuration | Yes |
| -scheme | project scheme | Yes |
| -sdk | Build an Xcode project or workspace against the specified SDK | No |
