:local bcs ""

:foreach nws in=[/ip/address/find interface~"your-interface-regex"] do={
    :local netw [/ip/address/get $nws address];
    :local mask [:tonum [:pick $netw ([:find $netw "/"]+1) [:len $netw]]]
    :set netw [:toip [:pick $netw 0 [:find $netw "/"]]];

    :set $bcs ($bcs . ($netw | (255.255.255.255 >> $mask)) . ";");
}
:set bcs [:pick $bcs 0 ([:len $bcs]-1)];

:if ([/system/ntp/server/get broadcast-addresses] != $bcs) do={
    :set bcs ($bcs . "|");
    :for j from=0 to=([:len $bcs] - 1) do={
        :local char [:pick $bcs $j];
        :if ($char = ";") do={
            :set $char ",";
        }
        :set bcs ($bcs . $char);
    }
    :set bcs [:pick $bcs ([:find $bcs "|"] + 1) ([:len $bcs] - 1)];

    /system/ntp/server/set broadcast-addresses=$bcs;
    :log info ("SET NTP Server broadcast: " . $bcs);
}

