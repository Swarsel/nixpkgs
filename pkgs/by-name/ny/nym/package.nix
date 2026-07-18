{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  darwin,
  gitUpdater,
  openssl,
  pkg-config,
  rustPlatform,
  rustc,
}:

rustPlatform.buildRustPackage rec {
  pname = "nym";
  version = "2024.14-crunch-patched";

  src = fetchFromGitHub {
    owner = "nymtech";
    repo = "nym";
    tag = "nym-binaries-v${version}";
    hash = "sha256-ze0N+Hg+jVFKaoreCrZUUA3cHGtUZFtxCh5RwTqOdsc=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-51QdzV4eYnA+pC1b7TagSF1g+n67IvZw3euJyI3ZRtM=";

  env = {
    OPENSSL_NO_VENDOR = true;
    SWAGGER_UI_DOWNLOAD_URL = "file://${swagger-ui}";
  };

  env = {
    VERGEN_BUILD_SEMVER = version;
    VERGEN_BUILD_TIMESTAMP = "0";
    VERGEN_CARGO_PROFILE = "release";
    VERGEN_GIT_BRANCH = "master";
    VERGEN_GIT_COMMIT_TIMESTAMP = "0";
    VERGEN_RUSTC_CHANNEL = "stable";
    VERGEN_RUSTC_SEMVER = rustc.version;
  };

  checkFlags = [
    "--skip=ping::http::tests::resolve_host_with_valid_hostname_returns_some"
  ];

  checkType = "debug";

  swagger-ui = fetchurl {
    hash = "sha256-SBJE0IEgl7Efuu73n3HZQrFxYX+cn5UU5jrL4T5xzNw=";
    url = "https://github.com/swagger-api/swagger-ui/archive/refs/tags/v5.17.14.zip";
  };

  passthru.updateScript = gitUpdater {
    rev-prefix = "nym-binaries-v";
  };

  meta = {
    description = "Mixnet providing IP-level privacy";

    longDescription = ''
      Nym routes IP packets through other participating nodes to hide their source and destination.
      In contrast with Tor, it prevents timing attacks at the cost of latency.
    '';

    homepage = "https://nymtech.net";
    changelog = "https://github.com/nymtech/nym/releases/tag/nym-binaries-v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.all;
  };
}
