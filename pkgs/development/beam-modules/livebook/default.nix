{
  lib,
  stdenv,
  fetchFromGitHub,
  beamPackages,
  bun,
  makeWrapper,
  nix-update-script,
  nixosTests,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

beamPackages.mixRelease rec {
  inherit (beamPackages) elixir;
  pname = "livebook";
  version = "0.19.8";

  src = fetchFromGitHub {
    owner = "livebook-dev";
    repo = "livebook";
    tag = "v${version}";
    hash = "sha256-cIFnGUJ8yRnEBL9eu4Jpg1sMlTV1t/ybhHusLSFdZEY=";
  };

  postPatch = ''
    substituteInPlace lib/mix/tasks/compile.ensure_livebook_priv.ex \
      --replace-fail 'Mix.Task.run("bun.install", ~w"--if-missing")' ':ok' \
      --replace-fail 'Mix.Task.run("bun", ~w"assets install")' ':ok' \
      --replace-fail 'Mix.Task.run("bun", ~w" assets run build")' ':ok'
  '';

  nativeBuildInputs = [
    bun
    makeWrapper
    writableTmpDirAsHomeHook
  ];

  buildInputs = [ beamPackages.erlang ];

  preBuild = ''
    cp -r ${node_modules}/node_modules assets/node_modules
    chmod -R +w assets/node_modules
    ln -sf ../../deps/phoenix assets/node_modules/phoenix
    ln -sf ../../deps/phoenix_html assets/node_modules/phoenix_html
    ln -sf ../../deps/phoenix_live_view assets/node_modules/phoenix_live_view
    pushd assets
    bun --bun ./node_modules/vite/bin/vite.js build
    popd
  '';

  postInstall =
    let
      path = lib.makeBinPath [
        beamPackages.elixir
        beamPackages.erlang
      ];
    in
    ''
      wrapProgram $out/bin/livebook \
        --prefix PATH : ${path} \
        --set MIX_REBAR3 ${beamPackages.rebar3}/bin/rebar3

      wrapProgram $out/bin/server \
        --prefix PATH : ${path}
    '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  mixFodDeps = beamPackages.fetchMixDeps {
    inherit src version;
    pname = "mix-deps-${pname}";
    hash = "sha256-T74RmUORPdNibxdl+bRGyYyOdnKs1TyjtdutLtfLNLM=";
  };

  node_modules = stdenv.mkDerivation {
    inherit src version;
    pname = "${pname}-node_modules";

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    installPhase = ''
      mkdir -p deps/phoenix deps/phoenix_html deps/phoenix_live_view
      echo '{"name": "phoenix", "version": "1.0.0"}' > deps/phoenix/package.json
      echo '{"name": "phoenix_html", "version": "1.0.0"}' > deps/phoenix_html/package.json
      echo '{"name": "phoenix_live_view", "version": "1.0.0"}' > deps/phoenix_live_view/package.json
      cd assets
      bun install \
        --no-cache \
        --backend=copyfile \
        --cpu="*" \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress \
        --os="*"
      mkdir -p $out
      cp -r node_modules $out/
      rm -rf $out/node_modules/phoenix
      rm -rf $out/node_modules/phoenix_html
      rm -rf $out/node_modules/phoenix_live_view
    '';

    dontBuild = true;
    dontFixup = true;
    outputHash = "sha256-XtEkedj5QJh1tveKKd5sh4xcC6Gol1DUweQKEw1jLgU=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgramArg = [ "version" ];

  passthru = {
    tests = {
      livebook-service = nixosTests.livebook-service;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Automate code & data workflows with interactive Elixir notebooks";
    homepage = "https://livebook.dev/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      munksgaard
      scvalex
    ];

    platforms = lib.platforms.unix;
    mainProgram = "livebook";

    teams = [
      lib.teams.beam
      lib.teams.ngi
    ];
  };
}
