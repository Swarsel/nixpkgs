{
  lib,
  stdenv,
  fetchFromGitHub,
  # tests
  cacert,
  # nativeBuildInputs
  cmake,
  nix-update-script,
  openssl,
  perl,
  pkg-config,
  protobuf,
  # buildInputs
  rdkafka,
  restate,
  rust-jemalloc-sys-unprefixed,
  rustPlatform,
  # passthru
  testers,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "restate";
  version = "1.7.2";

  src = fetchFromGitHub {
    owner = "restatedev";
    repo = "restate";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UXyDlrhCVD4lPVnlNvLg8QcV+nBOmHrq8m0eiJFsq/c=";
  };

  nativeBuildInputs = [
    cmake
    openssl
    perl
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    rdkafka
    # tikv-jemalloc-sys's vendored jemalloc configure breaks under gcc 15.
    rust-jemalloc-sys-unprefixed
  ];

  cargoHash = "sha256-Enouq6a0V0q/raMfjXIDIijF1gb7ezBn1kFIqxwklp4=";

  env = {
    # Have to be set to dynamically link librdkafka
    CARGO_FEATURE_DYNAMIC_LINKING = 1;
    # krb5-src contains K&R-style C code incompatible with GCC 14's default C23 standard;
    # tikv-jemalloc-sys has a strerror_r return type mismatch (-Wint-conversion)
    NIX_CFLAGS_COMPILE = "-std=gnu17 -Wno-error=int-conversion";
    PROTOC = lib.getExe protobuf;
    PROTOC_INCLUDE = "${protobuf}/include";

    # rustflags as defined in the upstream's .cargo/config.toml
    RUSTFLAGS =
      let
        target = stdenv.hostPlatform.config;
        targetFlags = lib.fix (self: {
          "aarch64-unknown-linux-gnu" = self.build ++ [
            # Enable frame pointers to support Parca (https://github.com/parca-dev/parca-agent/pull/1805)
            "-C force-frame-pointers=yes"
            "--cfg tokio_taskdump"
          ];

          "aarch64-unknown-linux-musl" = self.build ++ [
            # Enable frame pointers to support Parca (https://github.com/parca-dev/parca-agent/pull/1805)
            "-C force-frame-pointers=yes"
            "-C link-self-contained=yes"
            "--cfg tokio_taskdump"
          ];

          build = [
            "-C force-unwind-tables"
            "--cfg uuid_unstable"
            "--cfg tokio_unstable"
          ];

          "x86_64-unknown-linux-musl" = self.build ++ [
            "-C link-self-contained=yes"
            "--cfg tokio_taskdump"
          ];
        });
      in
      lib.concatStringsSep " " (lib.attrsets.attrByPath [ target ] targetFlags.build targetFlags);

    VERGEN_GIT_SHA = "v${finalAttrs.version}";
  };

  nativeCheckInputs = [
    cacert
  ];

  checkFlags = [
    # Error: deadline has elapsed
    "--skip"
    "replicated_loglet"
    # TIMEOUT [ 180.006s]
    "--skip"
    "fast_forward_over_trim_gap"
    # TIMEOUT (could be related to https://github.com/restatedev/restate/issues/3043)
    "--skip"
    "restatectl_smoke_test"
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  # Feature resolution seems to be failing due to this https://github.com/rust-lang/cargo/issues/7754
  auditable = false;
  useNextest = true;

  passthru = {
    tests.restateCliVersion = testers.testVersion {
      command = "restate --version";
      package = restate;
    };

    tests.restateCtlVersion = testers.testVersion {
      command = "restatectl --version";
      package = restate;
    };

    tests.restateServerVersion = testers.testVersion {
      command = "restate-server --version";
      package = restate;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Platform for developing distributed fault-tolerant applications";
    homepage = "https://restate.dev";
    changelog = "https://github.com/restatedev/restate/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsl11;
    maintainers = with lib.maintainers; [ myypo ];
    mainProgram = "restate";
  };
})
