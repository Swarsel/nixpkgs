{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPecl,
  pcre2,
  php,
  valgrind,
}:

let
  version = "6.1.8";
in
buildPecl {
  inherit version;
  pname = "swoole";

  src = fetchFromGitHub {
    owner = "swoole";
    repo = "swoole-src";
    rev = "v${version}";
    hash = "sha256-z/f3GLI/PQJJWcY968fOH00btDaKDx3M0Nb/IOjDgeY=";
  };

  buildInputs = [ pcre2 ] ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ valgrind ];
  # tests require internet access
  doCheck = false;

  meta = {
    description = "Coroutine-based concurrency library for PHP";
    homepage = "https://www.swoole.com";
    changelog = "https://github.com/swoole/swoole-src/releases/tag/v${version}";
    license = lib.licenses.asl20;
    broken = lib.versionAtLeast php.version "8.5";
    teams = [ lib.teams.php ];
  };
}
