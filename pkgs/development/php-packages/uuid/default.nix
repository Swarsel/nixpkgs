{
  lib,
  fetchFromGitHub,
  buildPecl,
  libuuid,
}:

let
  version = "1.3.0";
in
buildPecl {
  inherit version;
  pname = "uuid";

  src = fetchFromGitHub {
    owner = "php";
    repo = "pecl-networking-uuid";
    tag = "v${version}";
    hash = "sha256-00zJ//O1xqKTedRYThzeXOuL25wKLMZXjJWm/eXLkC4=";
  };

  buildInputs = [ libuuid ];
  makeFlags = [ "phpincludedir=$(dev)/include" ];
  env.PHP_UUID_DIR = libuuid;
  doCheck = true;

  meta = {
    description = "Wrapper around Universally Unique IDentifier library (libuuid)";
    homepage = "https://github.com/php/pecl-networking-uuid";
    changelog = "https://github.com/php/pecl-networking-uuid/releases/tag/v${version}";
    license = lib.licenses.php301;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.php ];
  };
}
