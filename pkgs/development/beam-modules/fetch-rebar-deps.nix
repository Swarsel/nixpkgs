{
  lib,
  stdenv,
  rebar3,
}:

{
  name,
  sha256,
  src,
  version,
  meta ? { },
}:

stdenv.mkDerivation {
  inherit version;
  inherit meta;
  pname = "rebar-deps-${name}";

  buildPhase = ''
    cp -r ${src} src
    chmod -R u+w src
    cd src
    HOME='.' DEBUG=1 ${rebar3}/bin/rebar3 get-deps
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/_checkouts"
    for i in ./_build/default/lib/* ; do
       echo "$i"
       cp -R "$i" "$out/_checkouts"
    done
    runHook postInstall
  '';

  dontConfigure = true;
  dontFixup = true;
  dontUnpack = true;
  impureEnvVars = lib.fetchers.proxyImpureEnvVars;
  outputHash = sha256;
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
}
