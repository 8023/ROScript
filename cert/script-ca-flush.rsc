:do {
    /tool fetch url=https://mkcert.org/generate/ check-certificate=yes dst-path=cacert.pem;
    /certificate import file-name=cacert.pem passphrase="" name="cert-rootca";
    /file remove cacert.pem;
    :log info ("CA Update Successful!");
} on-error={
    :log error ("CA Update Error!");
};
