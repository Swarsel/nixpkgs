{
  lib,
  stdenv,
  fetchFromGitHub,
  # nativeBuildInputs
  cmake,
  darwin,
  fetchzip,
  nix-update-script,
  # buildInputs
  openssl,
  perl,
  pkg-config,
  protobuf,
  rdkafka,
  rustPlatform,
  versionCheckHook,
}:

let
  fetchNpmPackage =
    {
      hash,
      js_dev_file,
      js_prod_file,
      name,
      version,
      ...
    }@args:
    let
      package = fetchzip {
        inherit hash;
        url = "https://registry.npmjs.org/${name}/-/${baseNameOf name}-${version}.tgz";
      };

      files =
        with args;
        [
          {
            src = js_prod_file;
            dst = "./src/environmentd/src/http/static/js/vendor/${name}.js";
          }
          {
            src = js_prod_file;
            dst = "./src/prof-http/src/http/static/js/vendor/${name}.js";
          }
          {
            src = js_dev_file;
            dst = "./src/environmentd/src/http/static-dev/js/vendor/${name}.js";
          }
          {
            src = js_dev_file;
            dst = "./src/prof-http/src/http/static-dev/js/vendor/${name}.js";
          }
        ]
        ++ lib.optionals (args ? css_file) [
          {
            src = css_file;
            dst = "./src/environmentd/src/http/static/css/vendor/${name}.css";
          }
          {
            src = css_file;
            dst = "./src/prof-http/src/http/static/css/vendor/${name}.css";
          }
        ]
        ++ lib.optionals (args ? extra_file) [
          {
            src = extra_file.src;
            dst = "./src/environmentd/src/http/static/${extra_file.dst}";
          }
          {
            src = extra_file.src;
            dst = "./src/prof-http/src/http/static/${extra_file.dst}";
          }
        ];
    in
    lib.concatStringsSep "\n" (
      lib.forEach files (
        { dst, src }:
        ''
          mkdir -p "${dirOf dst}"
          cp "${package}/${src}" "${dst}"
        ''
      )
    );

  npmPackages = import ./npm_deps.nix;
in
rustPlatform.buildRustPackage rec {
  pname = "materialize";
  version = "0.87.2";

  src = fetchFromGitHub {
    owner = "MaterializeInc";
    repo = "materialize";
    tag = "v${version}";
    hash = "sha256-EHhN+avUxzwKU48MubiMM40W9J93yZlNqV+xeP44dl0=";
    fetchSubmodules = true;
  };

  postPatch = ''
    ${lib.concatStringsSep "\n" (map fetchNpmPackage npmPackages)}
    substituteInPlace ./misc/dist/materialized.service \
      --replace-fail /usr/bin $out/bin \
      --replace-fail _Materialize root
    substituteInPlace ./src/catalog/build.rs \
      --replace-fail '&[ ' '&["."'
  '';

  nativeBuildInputs = [
    cmake
    perl
    pkg-config
    rustPlatform.bindgenHook
  ]
  # Provides the mig command used by the krb5-src build script
  ++ lib.optional stdenv.hostPlatform.isDarwin darwin.bootstrap_cmds;

  buildInputs = [
    openssl
    rdkafka
  ];

  cargoHash = "sha256-+OREisZ/vw3Oi5MNCYn7u06pZKtf+2trlGyn//uAGws=";

  env = {
    # needed to dynamically link rdkafka
    CARGO_FEATURE_DYNAMIC_LINKING = 1;
    MZ_DEV_BUILD_SHA = "000000000000000000000000000000000000000000000000000";
    # Needed to get openssl-sys to use pkg-config.
    OPENSSL_NO_VENDOR = 1;
    # needed for internal protobuf c wrapper library
    PROTOC = lib.getExe protobuf;
    PROTOC_INCLUDE = "${protobuf}/include";
  };

  # the check phase requires linking with rocksdb which can be a problem since
  # the rust rocksdb crate is not updated very often.
  doCheck = false;

  # Skip tests that use the network
  checkFlags = [
    "--exact"
    "--skip=test_client"
    "--skip=test_client_errors"
    "--skip=test_client_all_subjects"
    "--skip=test_client_subject_and_references"
    "--skip=test_no_block"
    "--skip=test_safe_mode"
    "--skip=test_tls"
  ];

  postInstall = ''
    install --mode=444 -D ./misc/dist/materialized.service $out/etc/systemd/system/materialized.service
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  cargoBuildFlags = [
    "--bin=clusterd"
    "--bin=environmentd"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/environmentd";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Streaming SQL materialized view engine for real-time applications";
    homepage = "https://materialize.com";
    license = lib.licenses.bsl11;
    maintainers = with lib.maintainers; [ petrosagg ];
    platforms = lib.platforms.unix;
    mainProgram = "environmentd";
  };
}
