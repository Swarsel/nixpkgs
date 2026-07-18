{
  lib,
  stdenv,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  buildNpmPackage,
  common-updater-scripts,
  fetchzip,
  gnugrep,
  jre,
  libiconv,
  makeWrapper,
  nix-update,
  nix-update-script,
  nodejs,
  rustPlatform,
  writeShellScript,
}:

let
  version = "0.32.0";
  apalacheVersion = "0.56.1";
  evaluatorVersion = "0.6.0";

  metaCommon = {
    description = "Formal specification language with TLA+ semantics";
    homepage = "https://quint-lang.org";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bugarela ];
    platforms = lib.platforms.unix;
  };

  src = fetchFromGitHub {
    owner = "informalsystems";
    repo = "quint";
    tag = "v${version}";
    hash = "sha256-GTbphBmALx/gDc/iV/wtE1ovpK43VtCQoneN5AqUmvg=";
  };

  # Build the Quint CLI from source
  quint-cli = buildNpmPackage {
    inherit version src nodejs;
    pname = "quint-cli";
    npmDepsHash = "sha256-6vKu9OTw68A92uhk1vHYDld5ixUln2tZav8pi55/l4c=";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/quint
      cp -r node_modules $out/share/quint
      cp -r dist $out/share/quint

      runHook postInstall
    '';

    dontNpmPrune = true;
    npmBuildScript = "compile";
    sourceRoot = "${src.name}/quint";

    meta = metaCommon // {
      description = "CLI for the Quint formal specification language";
    };
  };

  # Build the Rust evaluator from source
  quint-evaluator = rustPlatform.buildRustPackage {
    inherit src;
    pname = "quint-evaluator";
    version = evaluatorVersion;

    buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
      libiconv
    ];

    cargoHash = "sha256-aGVs/J+lAPHOsi01xShfZHBeUjd6eONpraNuMkaVfO8=";
    # Skip tests during build, as many rust tests rely on the Quint CLI
    doCheck = false;
    sourceRoot = "${src.name}/evaluator";

    meta = metaCommon // {
      description = "Evaluator for the Quint formal specification language";
    };
  };

  # Download Apalache. It runs on the JVM, so no need to build it from source.
  apalacheDist = fetchzip {
    hash = "sha256-2Gy+wQOUyuauiGedDNPPHatwcphll3BuL3SD4D12XMI=";
    url = "https://github.com/apalache-mc/apalache/releases/download/v${apalacheVersion}/apalache.tgz";
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit version src;
  pname = "quint";
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/quint \
      --add-flags "${quint-cli}/share/quint/dist/src/cli.js" \
      --set QUINT_HOME "$out/share/quint" \
      --prefix PATH : ${lib.makeBinPath [ jre ]}

    install -Dm755 ${quint-evaluator}/bin/quint_evaluator -t $out/share/quint/rust-evaluator-v${evaluatorVersion}/

    mkdir -p $out/share/quint/apalache-dist-${apalacheVersion}
    cp -r ${apalacheDist} $out/share/quint/apalache-dist-${apalacheVersion}/apalache
    chmod +x $out/share/quint/apalache-dist-${apalacheVersion}/apalache/bin/apalache-mc

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  passthru = {
    inherit
      quint-cli
      quint-evaluator
      apalacheDist
      apalacheVersion
      ;

    updateScript = _experimental-update-script-combinators.sequence [
      (nix-update-script {
        extraArgs = [
          "--subpackage"
          "quint-cli"
        ];
      })
      (writeShellScript "update" ''
        src=$(nix build --print-out-paths --no-link .#quint.src)
        QUINT_EVALUATOR_VERSION=$(${lib.getExe gnugrep} -m1 "const QUINT_EVALUATOR_VERSION" $src/quint/src/rust/binaryManager.ts | sed -E "s/.*= 'v?([^']+)'.*/\1/")
        ${lib.getExe nix-update} quint.quint-evaluator --version $QUINT_EVALUATOR_VERSION
        DEFAULT_APALACHE_VERSION_TAG=$(${lib.getExe gnugrep} "DEFAULT_APALACHE_VERSION_TAG" $src/quint/src/apalache.ts | sed -E "s/.*= '([^']+)'.*/\1/")
        ${lib.getExe' common-updater-scripts "update-source-version"} quint $DEFAULT_APALACHE_VERSION_TAG --version-key=apalacheVersion --source-key=apalacheDist --ignore-same-version --ignore-same-hash
      '')
    ];
  };

  meta = metaCommon // {
    mainProgram = "quint";
  };
})
