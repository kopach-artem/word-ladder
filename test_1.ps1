write-host "Hi!"
Pause
write-host "Bye!"
$ip = (resolve-dnsname "spacex.com" -Type A).IPAddress
tracert -h 2 $ip
ping $ip