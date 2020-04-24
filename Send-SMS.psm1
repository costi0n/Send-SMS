<#
 .Synopsis
  Send Sms via Skebby Account

 .Description
  Send Sms via Skebby Account. This function supports multiple recipient 
  and lets you send sms at scheduled date

 .Parameter Recipient
  cellular number to recipient

 .Parameter Message
  Body of message to sent

 .Parameter Sender
  The sender's name to be displayed on the receiving device.


 .Example
    $result = (Send-SMS -cred $credential -recipient $recipient -message $message -sender $sender -url $url)
    $result.result - ritorna lo stato del'invio
    $result.remaining_credits - numero di sms disponibili

#>

function loginSkebby {
  param (
    [Object] $cred = @{},
    [string] $urlLogin = $null
  )
  $uriLogin = [System.Uri]$urlLogin
  try {
        $loginResult = Invoke-WebRequest -Uri $urlLogin -Body $cred -Method 'GET'
        $session = @{
          userkey = $loginResult.Content.Split(";")[0]
          sesikey = $loginResult.Content.Split(";")[1]
        }
        if ( $loginResult.StatusCode -eq "200") {
          Return $session
      } else {
          Return $false
      }
  } catch {
          Return $false
  }
}



function Send-SMS {
  param(
    [object] $cred = @{},
    [array] $recipient = @(),
    [string] $message = $null,
    [string] $sender = $null,
    [string] $messagetype = "TI",
    [string] $url = "https://api.skebby.it/API/v1.0/REST/"
    )
    $urlLogin = $url + "login"
    $urlSMS = $url + "sms"

    $uriLogin = [System.Uri]$urlLogin
    $uriSend = [System.Uri]$urlSMS
    
    $s = loginSkebby -cred $cred -urlLogin $uriLogin 

    if ( $s -eq $false ) {
        Return "Qualcosa non ha funzionato"
    } else {

      $header = @{
                user_key = $s.userkey
                Session_key = $s.sesikey
      }
      $arrayPOST = @{
                  message_type = $messagetype
                  message = $message
                  recipient = $recipient
                  sender = $sender
                  returnCredits = $true
                  returnRemaining = $true
                  encoding = "ucs2"
              }
      $jsonPOST = $arrayPOST | ConvertTo-JSON
      
      try {
        $result = Invoke-RestMethod -Uri $uriSend -Method POST -Headers $header -Body $jsonPOST -ContentType "application/json"
        Return $result
      } catch {
                Write-Host "Non e' stato possibile inviare l'SMS !"
              }

    }

}


Export-ModuleMember -Function Send-SMS