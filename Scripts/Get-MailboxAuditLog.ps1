# This contains a function for getting Mailbox Audit logging

function Get-MailboxAuditLog
{
<#
    .SYNOPSIS
    Get mailbox audit log entries.

    .DESCRIPTION
    Get mailbox audit log entries for specific a user account. 
	The output will be written to: Output\MailboxAuditLog\

	.PARAMETER UserIds
    UserIds is the Identity parameter specifying a single mailbox to retrieve mailbox audit log entries from.

	.PARAMETER StartDate
    startDate is the parameter specifying the start date of the date range.

	.PARAMETER EndDate
    endDate is the parameter specifying the end date of the date range.

	.PARAMETER OutputDir
    outputDir is the parameter specifying the output directory.
	Default: Output\MailboxAuditLog

	.PARAMETER Encoding
    Encoding is the parameter specifying the encoding of the CSV output file.
	Default: UTF8
    
	.EXAMPLE
    Get-MailboxAuditLog
	Get all available mailbox audit log entries for all user accounts

    .EXAMPLE
    Get-MailboxAuditLog -UserIds Test@invictus-ir.com
	Get mailbox audit log entries for the user Test@invictus-ir.com

	.EXAMPLE
    Get-MailboxAuditLog -UserIds "Test@invictus-ir.com,HR@invictus-ir.com"
	Get mailbox audit log entries for the users Test@invictus-ir.com and HR@invictus-ir.com.

	.EXAMPLE
	Get-MailboxAuditLog -UserIds Test@invictus-ir.com -StartDate 1/4/2023 -EndDate 5/4/2023
	Get mailbox audit log entries for the user Test@invictus-ir.com between 1/4/2023 and 5/4/2023.
#>
	[CmdletBinding()]
	param(
		[string]$UserIds,
		[string]$StartDate,
		[string]$EndDate,
		[string]$OutputDir,
		[string]$Encoding
	)

	try {
		$areYouConnected = Search-MailboxAuditlog -ErrorAction stop
	}
	catch {
		write-logFile -Message "[WARNING] You must call Connect-M365 before running this script" -Color "Red"
		break
	}

	write-logFile -Message "[INFO] Running Get-MailboxAuditLog" -Color "Green"

	if ($OutputDir -eq "" ){
		$OutputDir = "Output\MailboxAuditLog"
		If (!(test-path $OutputDir)){
			write-logFile -Message "[INFO] Creating the following directory: $OutputDir" 
			New-Item -ItemType Directory -Force -Name $OutputDir | Out-Null
		}
	}

	if ($Encoding -eq "" ){
		$Encoding = "UTF8"
	}
	
	StartDate
	EndDate

	if (($null -eq $UserIds) -Or ($UserIds -eq ""))  {
		write-logFile -Message "[INFO] No users provided.. Getting the MailboxAuditLog for all users" -Color "Yellow"
		Get-mailbox -resultsize unlimited  |
		ForEach-Object {
			$date = Get-Date -Format "yyyyMMddHHmm"
			$outputFile = "$OutputDir\mailboxAuditLog_$($_.UserPrincipalName)_$($date).csv"

			write-logFile -Message "[INFO] Collecting the MailboxAuditLog for $($_.UserPrincipalName)"
			$result = Search-MailboxAuditlog -Identity $_.UserPrincipalName -LogonTypes Delegate,Admin,Owner -StartDate $script:StartDate -EndDate $script:EndDate -ShowDetails -ResultSize 250000 
			$result | export-csv -NoTypeInformation -Path $outputFile -Encoding $Encoding
			
			write-logFile -Message "[INFO] Output is written to: $outputFile" -Color "Green"
		}
	}

	elseif ($UserIds -match ",") {
		$UserIds.Split(",") | Foreach {
			$user = $_
			$date = Get-Date -Format "yyyyMMddHHmm"
			$outputFile = "$OutputDir\mailboxAuditLog_$($user)_$($date).csv"

			write-logFile -Message "[INFO] Collecting the MailboxAuditLog for $user"
			$result = Search-MailboxAuditlog -Identity $user -LogonTypes Delegate,Admin,Owner -StartDate $script:StartDate -EndDate $script:EndDate -ShowDetails -ResultSize 250000 
			$result | export-csv -NoTypeInformation -Path $outputFile -Encoding $Encoding
			
			write-logFile -Message "[INFO] Output is written to: $outputFile" -Color "Green"
		}
	}

	else {		
		$date = Get-Date -Format "yyyyMMddHHmm"
		$outputFile = "$OutputDir\mailboxAuditLog_$($UserIds)_$($date).csv"

		write-logFile -Message "[INFO] Collecting the MailboxAuditLog for $UserIds"
		$result = Search-MailboxAuditlog -Identity $UserIds -LogonTypes Delegate,Admin,Owner -StartDate $script:StartDate -EndDate $script:EndDate -ShowDetails -ResultSize 250000 
		$result | export-csv -NoTypeInformation -Path $outputFile -Encoding $Encoding
		
		write-logFile -Message "[INFO] Output is written to: $outputFile" -Color "Green"
	} 
}