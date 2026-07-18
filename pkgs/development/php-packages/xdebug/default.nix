{
  lib,
  fetchFromGitHub,
  buildPecl,
}:

let
  version = "3.5.3";
in
buildPecl {
  inherit version;
  pname = "xdebug";

  src = fetchFromGitHub {
    owner = "xdebug";
    repo = "xdebug";
    rev = version;
    hash = "sha256-UrRQqnWEE0y8I4DTDWn21yGScG42+XaFFl6UjcJXbtM=";
  };

  doCheck = true;
  zendExtension = true;

  meta = {
    description = "Provides functions for function traces and profiling";
    homepage = "https://xdebug.org/";
    changelog = "https://github.com/xdebug/xdebug/releases/tag/${version}";
    license = lib.licenses.php301;
    teams = [ lib.teams.php ];
  };
}
