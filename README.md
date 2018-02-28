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
`./aziOSBuild.sh -project /.../TestApp.xcodeproj -exportPath /.../FolderIPA -p12Path /.../CertificatsPrive.p12  -p12Password "test" -provisioningProfilePath /.../ProvisioningProfilesDistribution.mobileprovision -configuration release -scheme TestApp -distributionMethod app-store`

Options
------------

| Options        | Commentary  | required  |
| ------------- |:-------------:| -----:|
| -project      | Path to xcodeproj or xcworkspace | Yes |
| -exportPath      | Specifies the destination of the generated IPA    | Yes |
| -p12Path | Path to p12 file      | Yes |
| -p12Password | Password of p12 file      | Yes |
| -provisioningProfilePath | Path to the provisioning profile | Yes |
| -configuration | Project configuration | Yes |
| -scheme | Project scheme | Yes |
| -sdk | Build an Xcode project or workspace against the specified SDK | No |
| -distributionMethod | Describes how Xcode should export the archive | Yes |
