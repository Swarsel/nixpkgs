{
  lib,
  stdenv,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  bash,
  buildNpmPackage,
  bun,
  cairo,
  callPackage,
  cargo,
  cmake,
  coreutils,
  deno,
  dotnet-sdk_9,
  flock,
  go,
  libxml2,
  libxslt,
  lld,
  makeWrapper,
  nix-update-script,
  nixosTests,
  nsjail,
  openssl,
  pango,
  perl,
  php,
  pixman,
  pkg-config,
  powershell,
  procps,
  python312,
  rustPlatform,
  rustfmt,
  uv,
  xmlsec,
  librusty_v8 ? (
    callPackage ./librusty_v8.nix {
      inherit (callPackage ./fetchers.nix { }) fetchLibrustyV8;
    }
  ),
  ui_builder ? (callPackage ./ui_builder.nix { }),
  withClosedSourceFeatures ? false,
  withEnterpriseFeatures ? false,
}:

let
  pname = "windmill";
  version = "1.601.1";

  src = fetchFromGitHub {
    owner = "windmill-labs";
    repo = "windmill";
    rev = "v${version}";
    hash = "sha256-3Djrk8gHW3NjNzSy4A38LmTfl18LKDKgFeNMBPKlhfM=";
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  inherit pname version src;

  patches = [
    ./download.py.config.proto.patch
    ./python_executor.patch
    ./python_versions.patch
    ./run.ansible.config.proto.patch
    ./run.bash.config.proto.patch
    ./run.bun.config.proto.patch
    ./run.csharp.config.proto.patch
    ./run.go.config.proto.patch
    ./run.php.config.proto.patch
    ./run.powershell.config.proto.patch
    ./run.python3.config.proto.patch
    ./run.rust.config.proto.patch
    ./rust_executor.patch
  ];

  postPatch = ''
    substituteInPlace windmill-common/src/utils.rs \
      --replace-fail 'unknown-version' 'v${version}'
  '';

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    cmake # for libz-ng-sys crate
    perl
  ];

  buildInputs = [
    openssl
    rustfmt
    lld
    (lib.getLib stdenv.cc.cc)
    libxml2
    xmlsec
    libxslt
  ];

  cargoHash = "sha256-ivfseD1zWcy4P8Anbo/e1r2rRma/6mj25blkrXpwNHE=";

  env = {
    FRONTEND_BUILD_DIR = "${finalAttrs.passthru.web-ui}/share/windmill-frontend";
    RUSTY_V8_ARCHIVE = librusty_v8;
    SQLX_OFFLINE = "true";
  };

  # needs a postgres database running
  doCheck = false;

  postFixup = ''
    wrapProgram "$out/bin/windmill" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ stdenv.cc.cc ]} \
      --prefix PATH : ${
        lib.makeBinPath [
          # uv searches for python on path as well!
          python312

          procps # bash_executor
          coreutils # bash_executor
        ]
      } \
      --set PYTHON_PATH "${python312}/bin/python3" \
      --set GO_PATH "${go}/bin/go" \
      --set DENO_PATH "${deno}/bin/deno" \
      --set NSJAIL_PATH "${nsjail}/bin/nsjail" \
      --set FLOCK_PATH "${flock}/bin/flock" \
      --set BASH_PATH "${bash}/bin/bash" \
      --set POWERSHELL_PATH "${powershell}/bin/pwsh" \
      --set BUN_PATH "${bun}/bin/bun" \
      --set UV_PATH "${uv}/bin/uv" \
      --set DOTNET_PATH "${dotnet-sdk_9}/bin/dotnet" \
      --set DOTNET_ROOT "${dotnet-sdk_9}/share/dotnet" \
      --set PHP_PATH "${php}/bin/php" \
      --set CARGO_PATH "${cargo}/bin/cargo"
  '';

  buildFeatures = [
    "agent_worker_server"
    # "benchmark" # DO NOT ACTIVATE, this is for benchmark testing
    #"bigquery"
    "cloud"
    "csharp"
    "default"
    "deno_core"
    "dind"
    #"duckdb"
    "embedding"
    "flow_testing"
    "gcp_trigger"
    "http_trigger"
    #"java"
    "jemalloc"
    "kafka"
    "license"
    "loki"
    "mcp"
    "mqtt_trigger"
    #"mssql"
    #"mysql"
    "nats"
    #"nu"
    "oauth2"
    "openidconnect"
    #"oracledb"
    "parquet"
    "php"
    "postgres_trigger"
    "python"
    #"ruby"
    #"rust" # compiler environment is incomplete
    "scoped_cache"
    "smtp"
    "sqlx"
    "sqs_trigger"
    "static_frontend"
    "websocket"
    "zip"
  ]
  ++ (lib.optionals withEnterpriseFeatures [
    "enterprise_saml"
    "enterprise"
    "otel"
    "prometheus"
    "stripe"
    "tantivy"
  ])
  ++ (lib.optionals withClosedSourceFeatures [ "private" ]);

  sourceRoot = "${src.name}/backend";
  passthru.tests = lib.optionalAttrs (stdenv.hostPlatform.isLinux) nixosTests.windmill;

  passthru.updateScript = _experimental-update-script-combinators.sequence [
    (nix-update-script {
      extraArgs = [
        "--subpackage"
        "web-ui"
      ];
    })
    ./update-librusty.sh
    ./update-ui_builder.sh
  ];

  passthru.web-ui = buildNpmPackage {
    inherit version src;
    pname = "windmill-ui";

    nativeBuildInputs = [
      pkg-config
    ];

    buildInputs = [
      pixman
      cairo
      pango
    ];

    npmDepsHash = "sha256-eVN7q8hRH7NYjZiE5dLRMUKlyrtnAPGPdYV6/S4Sc+4=";
    # without these you get a
    # FATAL ERROR: Ineffective mark-compacts near heap limit Allocation failed - JavaScript heap out of memory
    env.NODE_OPTIONS = "--max-old-space-size=8192";

    preBuild = ''
      npm run generate-backend-client
    '';

    installPhase = ''
      mkdir -p $out/share
      mv build $out/share/windmill-frontend

      mkdir -p $out/share/windmill-frontend/static
      ln -s ${ui_builder} $out/share/windmill-frontend/static/ui_builder
    '';

    # WORKS
    npmFlags = [
      # Skip "postinstall" script that attempts to download and unpack ui-builder (patching out the url with nix-store path doesn't work)
      "--ignore-scripts"
    ];

    postUnpack = ''
      cp ${src}/openflow.openapi.yaml .
    '';

    sourceRoot = "${src.name}/frontend";
  };

  meta = {
    description = "Open-source developer platform to turn scripts into workflows and UIs";
    homepage = "https://windmill.dev";
    changelog = "https://github.com/windmill-labs/windmill/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      happysalada
    ];

    # limited by librusty_v8
    # nsjail not available on darwin
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "windmill";
  };
})
