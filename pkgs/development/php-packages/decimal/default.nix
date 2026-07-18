{
  lib,
  buildPecl,
  mpdecimal,
  php,
}:
let
  version = "1.5.0";
in
buildPecl {
  pname = "decimal";
  version = version;
  buildInputs = [ mpdecimal ];
  configureFlags = [ "--with-libmpdec-path=${mpdecimal}" ];
  hash = "sha256-it8w8hOLYwtCZoDYhaP5k5TD/pQLtj37K2lSESF80ok=";

  meta = {
    description = "Arbitrary-precision decimal arithmetic for PHP";
    homepage = "https://php-decimal.github.io";
    changelog = "https://pecl.php.net/package-changelog.php?package=decimal&release=${version}";
    license = lib.licenses.mit;
    teams = [ lib.teams.php ];
  };
}
