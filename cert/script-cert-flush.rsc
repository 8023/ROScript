:local date [/system clock get date];
:local months {
    "jan"="01"; "feb"="02"; "mar"="03"; "apr"="04"; "may"="05"; "jun"="06";
    "jul"="07"; "aug"="08"; "sep"="09"; "oct"="10"; "nov"="11"; "dec"="12"
};
:set $date ([:pick $date 7 11] . $months->[:pick $date 0 3] . [:pick $date 4 6]);

:local url "sftp://x.x.x.x:xxxx/your-cert-path/";
:local user "your-username";
:local pass "your-password";
:local files {
    "cert.pem";
    "privkey.pem"
};

:if ([/certificate/find name~"cert-letsencrypt_"] = "" || \
     [/certificate/find name~"cert-letsencrypt_" expires-after<10d] != "" ) do={
    :log info "Cert Update Start!"
    :local cert ("cert-letsencrypt_" . $date);

    :foreach file in=$files do={
        :do {
            /tool/fetch url=($url . $file) user=$user password=$pass
            /delay 2
            /certificate/import file-name=$file passphrase="" name=$cert
            /delay 2
            /file/remove $file
            /delay 2
        } on-error={
            :log error "Cert Update Error!";
            :error "Cert Update Error!";
        }
    }

    /interface/sstp-server/server/set certificate=$cert
    /ip/service/set www-ssl certificate=$cert
    /ip/service/set api-ssl certificate=$cert
    :foreach cert in=[/certificate/find name~"cert-letsencrypt_" expires-after<10d] do={
        /certificate/remove [get $cert name]
    }

}
:log info "Cert Update Successful!";