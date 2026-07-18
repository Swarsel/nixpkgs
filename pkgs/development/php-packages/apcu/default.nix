{
  lib,
  fetchFromGitHub,
  buildPecl,
  pcre2,
}:

let
  version = "5.1.28";
in
buildPecl {
  inherit version;
  pname = "apcu";

  src = fetchFromGitHub {
    owner = "krakjoe";
    repo = "apcu";
    rev = "v${version}";
    sha256 = "sha256-L8bGSPUuBsZXsJdeY6cVA0DvI2+0wEbNHH6IcfT+cFU=";
  };

  outputs = [
    "out"
    "dev"
  ];

  buildInputs = [ pcre2 ];
  makeFlags = [ "phpincludedir=$(dev)/include" ];
  doCheck = true;

  meta = {
    description = "Userland cache for PHP";
    homepage = "https://pecl.php.net/package/APCu";
    changelog = "https://github.com/krakjoe/apcu/releases/tag/v${version}";
    license = lib.licenses.php301;
    teams = [ lib.teams.php ];
  };
}
