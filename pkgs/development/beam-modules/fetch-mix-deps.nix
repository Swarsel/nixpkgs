{
  lib,
  cacert,
  elixir,
  git,
  hex,
  rebar,
  rebar3,
  stdenvNoCC,
}@inputs:

{
  pname,
  src,
  version,
  debug ? false,
  elixir ? inputs.elixir,
  hash ? "",
  hex ? inputs.hex.override { inherit elixir; },
  meta ? { },
  mixEnv ? "prod",
  mixTarget ? "host",
  patches ? [ ],
  sha256 ? "",
  ...
}@attrs:

let
  hash_ =
    if hash != "" then
      {
        outputHash = hash;
        outputHashAlgo = null;
      }
    else if sha256 != "" then
      {
        outputHash = sha256;
        outputHashAlgo = "sha256";
      }
    else
      {
        outputHash = lib.fakeSha256;
        outputHashAlgo = "sha256";
      };
in
stdenvNoCC.mkDerivation (
  attrs
  // {
    inherit patches;
    inherit meta;

    nativeBuildInputs = [
      elixir
      hex
      cacert
      git
    ];

    env = {
      DEBUG = if debug then 1 else 0; # for rebar3
      # there is a persistent download failure with absinthe 1.6.3
      # those defaults reduce the failure rate
      HEX_HTTP_CONCURRENCY = 1;
      HEX_HTTP_TIMEOUT = 120;
      MIX_DEBUG = if debug then 1 else 0;
      MIX_ENV = mixEnv;
      # the api with `mix local.rebar rebar path` makes a copy of the binary
      MIX_REBAR = "${rebar}/bin/rebar";
      MIX_REBAR3 = "${rebar3}/bin/rebar3";
      MIX_TARGET = mixTarget;
    }
    // (attrs.env or { });

    installPhase =
      attrs.installPhase or ''
        runHook preInstall
        mix deps.get ''${MIX_ENV:+--only $MIX_ENV}
        find "$TEMPDIR/deps" -path '*/.git/*' -a ! -name HEAD -exec rm -rf {} +
        cp -r --no-preserve=mode,ownership,timestamps $TEMPDIR/deps $out
        runHook postInstall
      '';

    configurePhase =
      attrs.configurePhase or ''
        runHook preConfigure
        export HEX_HOME="$TEMPDIR/.hex";
        export MIX_HOME="$TEMPDIR/.mix";
        export MIX_DEPS_PATH="$TEMPDIR/deps";

        # Rebar
        export REBAR_GLOBAL_CONFIG_DIR="$TMPDIR/rebar3"
        export REBAR_CACHE_DIR="$TMPDIR/rebar3.cache"
        runHook postConfigure
      '';

    dontBuild = true;
    impureEnvVars = lib.fetchers.proxyImpureEnvVars;
    outputHashMode = "recursive";
  }
  // hash_
)
