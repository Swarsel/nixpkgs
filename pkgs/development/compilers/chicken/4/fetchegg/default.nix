# Fetches a chicken egg from henrietta using `chicken-install -r'
# See: http://wiki.call-cc.org/chicken-projects/egg-index-4.html

{
  lib,
  chicken,
  stdenvNoCC,
}:
{
  name,
  version,
  md5 ? "",
  sha256 ? "",
}:

if md5 != "" then
  throw "fetchegg does not support md5 anymore, please use sha256"
else
  stdenvNoCC.mkDerivation {
    inherit version;
    nativeBuildInputs = [ chicken ];
    builder = ./builder.sh;
    eggName = name;
    impureEnvVars = lib.fetchers.proxyImpureEnvVars;
    name = "chicken-${name}-export-${version}";
    outputHash = sha256;
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  }
