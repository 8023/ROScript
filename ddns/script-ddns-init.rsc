:global ddnsList;
:set ddnsList {
    "pppoec-wan1"={
        {"ipObsolete"="0.0.0.0/0"; "id"="adfd34ba892cbebd97e7c15f5214d5fd"; "domain"="wan1.xxx.com"};
        {"ipObsolete"="0.0.0.0/0"; "id"="e6689c1212f5dd9cb1f22bb9210a8534"; "domain"="wan.xxx.com"};
        {"ipObsolete"="::/0"; "id"="a9f1e59abf446aa3710d72e2cb4a2347"; "domain"="wan1.xxx.com"};
        {"ipObsolete"="::/0"; "id"="dd7fe88003ec5dec35a9158ab94a7fbf"; "domain"="wan.xxx.com"}
    };
    "pppoec-wan2"={
        {"ipObsolete"="0.0.0.0/0"; "id"="174e545b21819b697becf92c64f0771f"; "domain"="wan2.xxx.com"};
        {"ipObsolete"="0.0.0.0/0"; "id"="7f39fb8a0ad9b6542c475b448ca6d2ae"; "domain"="wan.xxx.com"};
        {"ipObsolete"="::/0"; "id"="8a8f61a2f6efb0948a44d42dcc6efddb"; "domain"="wan2.xxx.com"};
        {"ipObsolete"="::/0"; "id"="701968f10b3e78393c1898a2b3bb6973"; "domain"="wan.xxx.com"}
    };
    "your-interface-name"={
        {"ipObsolete"="0.0.0.0/0"; "id"="your-record-id1"; "domain"="your-domain-name1-for-ipv4"};
        {"ipObsolete"="0.0.0.0/0"; "id"="your-record-id2"; "domain"="your-domain-name2-for-ipv4"};
        {"ipObsolete"="::/0"; "id"="your-record-id3"; "domain"="your-domain-name1-for-ipv6"};
        {"ipObsolete"="::/0"; "id"="your-record-id4"; "domain"="your-domain-name2-for-ipv6"}
    }
};
:log info "CF-DDNS: init successful!";