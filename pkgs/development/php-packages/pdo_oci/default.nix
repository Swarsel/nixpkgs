{
  lib,
  buildPecl,
  oracle-instantclient,
  php,
}:

buildPecl {
  pname = "pdo_oci";
  version = "1.2.0";

  postPatch = ''
    sed -i -e 's|OCISDKMANINC=`.*$|OCISDKMANINC="${oracle-instantclient.dev}/include"|' config.m4
  '';

  buildInputs = [ oracle-instantclient ];
  configureFlags = [ "--with-pdo-oci=instantclient,${oracle-instantclient.lib}/lib" ];
  hash = "sha256-xV5ZvOtowkPntuqQ0dSyhpC5l+MDkvEKHoRi8S0/k34=";
  internalDeps = [ php.extensions.pdo ];

  meta = {
    description = "PHP PDO_OCI extension lets you access Oracle Database";
    homepage = "https://pecl.php.net/package/pdo_oci";
    changelog = "https://pecl.php.net/package-changelog.php?package=PDO_OCI";
    license = lib.licenses.php301;
    teams = [ lib.teams.php ];
  };
}
