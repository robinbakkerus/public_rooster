
$global:modus = $null

Function askModus{
    Write-host "Geef deploy modus prod of acc" -ForegroundColor Cyan
    $global:modus = Read-Host 
    
    # Check the modus and create the files:
    if ( $global:modus -eq "prod" -or $global:modus -eq "acc" ) {
        Write-host "Deploying to $global:modus" -ForegroundColor Cyan
    } else {
        Write-host "Onbekende modus" -ForegroundColor Cyan
        exit
    }
    
}

Function writeRunModeFile {
    Write-host "Write file ..." 
    $mode = $Global:modus
    $date = Get-Date -Format "dd-MMM-yyyy"

    $code = @"

import 'package:public_rooster/model/app_models.dart';

RunMode appRunModus = RunMode.{0};
String appVersion = '{1}';

"@ -f $mode, $date

    $filename = ".\lib\data\app_version.dart"
    [IO.File]::WriteAllLines($filename, $code)
}

Function runFirebaseScripts{
    Write-host "Run scripts ..." 
    flutter clean
    flutter build web
    Remove-Item '.firebase' -Force -Recurse
    firebase deploy --only hosting:$global:modus
}

askModus;
writeRunModeFile;
runFirebaseScripts