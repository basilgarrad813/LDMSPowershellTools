$name = ls C:\Users -filter "ALS_SVC*"
$name.name | % { net user $_ /delete }
Remove-Item C:\users\*ALS_SVC* -recurse

exit