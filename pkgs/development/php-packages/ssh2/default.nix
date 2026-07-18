{
  lib,
  buildPecl,
  libssh2,
}:

buildPecl rec {
  pname = "ssh2";
  version = "1.4.1";
  buildInputs = [ libssh2 ];
  configureFlags = [ "--with-ssh2=${libssh2.dev}" ];
  sha256 = "sha256-e8pbI/cx252O0K6l25uxXaj/EzsPu6lhArguldpNh2Q=";

  meta = {
    description = "PHP bindings for the libssh2 library";
    homepage = "https://github.com/php/pecl-networking-ssh2";
    changelog = "https://pecl.php.net/package-info.php?package=ssh2&version=${version}";
    license = lib.licenses.php301;
    maintainers = [ lib.maintainers.ostrolucky ];
    teams = [ lib.teams.php ];
  };
}
