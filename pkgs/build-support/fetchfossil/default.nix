{
  lib,
  stdenv,
  cacert,
  fossil,
}:

lib.fetchers.withNormalizedHash { } (
  {
    rev,
    url,
    name ? null,
    outputHash ? lib.fakeHash,
    outputHashAlgo ? null,
  }:

  stdenv.mkDerivation {
    inherit outputHash outputHashAlgo;
    inherit url rev;

    nativeBuildInputs = [
      fossil
      cacert
    ];

    builder = ./builder.sh;
    # Envvar docs are hard to find. A link for the future:
    # https://www.fossil-scm.org/index.html/doc/trunk/www/env-opts.md
    impureEnvVars = [ "http_proxy" ];
    name = "fossil-archive" + (lib.optionalString (name != null) "-${name}");
    outputHashMode = "recursive";
    preferLocalBuild = true;
  }
)
