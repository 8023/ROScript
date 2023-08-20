:local listNames {
    "adlist-pbr-cm";
    "adlist-pbr-tt";
    "adlist-pbr-cu";
    "adlist-scanner"
};
:local ipTypes {
    "v4";
    "v6"
};

:foreach listName in=$listNames do={
    :foreach ipType in=$ipTypes do={
        :local listFile ($listName . ".rsc");
        :local listUrl ("http://x.x.x.x:xxxx/general/" . $ipType . "/" . $listFile)

        :do {
            /tool fetch url=$listUrl
        } on-error={
            :log error ("PBR Download Error: " . $listUrl)
        }

        :if ([:len [/file find name=$listFile]] > 0) do={
            :if ($ipType = "v4") do={
                /ip/firewall/address-list/remove [find list=$listName]
            }
            :if ($ipType = "v6") do={
                /ipv6/firewall/address-list/remove [find list=$listName]
            }
            /import $listFile
            /file remove [find name=$listFile]
        }
    }
}

:log info "PBR Updata Successful!"
