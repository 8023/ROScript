:global ddnsList;
:local debug false;
:local cfEmail "your-cloudflare-email";
:local cfToken "your-cloudflare-token";
:local cfZoneid "your-cloudflare-zoneid";

:if ($debug = true) do={
    :log info "CF-DDNS: Start";
}
:foreach k,v in $ddnsList do={
    :foreach i,j in $v do={
        :local cfUrl ("https://api.cloudflare.com/client/v4/zones/" . $cfZoneid . "/dns_records/" . ($j->"id"));
        :local cfHeader "X-Auth-Email:$cfEmail,X-Auth-Key:$cfToken,content-type:application/json";

        :local ipaddr;
        :local ipCurrent;
        :local cfData;
        :if ([:find ($j->"ipObsolete") ":"] >= 0) do={
            :do {
                :set ipaddr [/ipv6/address/get [find interface=$k global] address];
                :set ipCurrent [:pick $ipaddr 0 [:find $ipaddr "/"]];
                :if ($ipCurrent != "::1") do={
                    :set cfData ("{\"type\":\"AAAA\",\"name\":\"" . ($j->"domain") . "\",\"content\":\"" . $ipCurrent . "\",\"ttl\":60}");
                } else={
                    :set cfData ("{\"type\":\"TXT\",\"name\":\"" . ($j->"domain") . "\",\"content\":\"" . [:rndstr] . "\",\"ttl\":60}");
                }
            } on-error={
                :set ipCurrent "::1";
                :set cfData ("{\"type\":\"TXT\",\"name\":\"" . ($j->"domain") . "\",\"content\":\"" . [:rndstr] . "\",\"ttl\":60}");
            };
        } else={
            :do {
                :set ipaddr [/ip/address/get [find interface=$k] address];
                :set ipCurrent [:pick $ipaddr 0 [:find $ipaddr "/"]];
                :if ($ipCurrent != "127.0.0.1") do={
                    :set cfData ("{\"type\":\"A\",\"name\":\"" . ($j->"domain") . "\",\"content\":\"" . $ipCurrent . "\",\"ttl\":60}");
                } else={
                    :set cfData ("{\"type\":\"TXT\",\"name\":\"" . ($j->"domain") . "\",\"content\":\"" . [:rndstr] . "\",\"ttl\":60}");
                }
            } on-error={
                :set ipCurrent "127.0.0.1";
                :set cfData ("{\"type\":\"TXT\",\"name\":\"" . ($j->"domain") . "\",\"content\":\"" . [:rndstr] . "\",\"ttl\":60}");
            }
        }

        :if ($debug = true) do={
            :log info ("CF-DDNS: interface = " . $k);
            :log info ("CF-DDNS: domain = " . ($j->"domain"));
            :log info ("CF-DDNS: ipCurrent = " . $ipCurrent);
            :log info ("CF-DDNS: ipObsolete = " . ($j->"ipObsolete"));
            :log info ("CF-DDNS: cfUrl = " . $cfUrl);
            :log info ("CF-DDNS: cfHeader = " . $cfHeader);
            :log info ("CF-DDNS: cfData = " . $cfData);
        }

        :if (($j->"ipObsolete") != $ipCurrent) do={
            :do {
                :local result [/tool fetch http-method=put mode=https url="$cfUrl" http-header-field="$cfHeader" http-data="$cfData" as-value output=user];
                :if ([:find ($result->"data") "\"success\":true," -1] > 1) do={
                    :log info ("CF-DDNS: interface=". $k . ", domain=" . ($j->"domain") . ", ip=" . $ipCurrent);
                    :set ($ddnsList->$k->$i->"ipObsolete") $ipCurrent;
                } else={
                    :log error "CF-DDNS: flush dns error!";
                }
            } on-error= {
                :log error "CF-DDNS: request error!";
            }
        } else={
            :if ($debug = true) do={
                :log info "CF-DDNS: No Update Needed!";
            }
        }
    }
}
:if ($debug = true) do={
    :log info "CF-DDNS: End";
}