{
  lib,
  fetchFromGitHub,
  cacert,
  libsodium,
  openssl,
  pkg-config,
  protobuf,
  rustPlatform,
  xz,
  zeromq,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "habitat";
  version = "1.6.1245";

  src = fetchFromGitHub {
    owner = "habitat-sh";
    repo = "habitat";
    rev = finalAttrs.version;
    hash = "sha256-n2ylJSCXPnnPHadfZaRS/3vxtnvkXhiTzCyObK7hmEk=";
  };

  nativeBuildInputs = [
    pkg-config
    protobuf
  ];

  buildInputs = [
    libsodium
    openssl
    xz
    zeromq
  ];

  cargoHash = "sha256-JMIAHupv3da71j5ID5ZR0mD7ZLLj4ktIs0aQrdWi3jU=";

  env = {
    OPENSSL_NO_VENDOR = true;
    SODIUM_USE_PKG_CONFIG = true;
    SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";
  };

  cargoBuildFlags = [
    "-p"
    "hab"
  ];

  cargoTestFlags = finalAttrs.cargoBuildFlags;

  meta = {
    description = "Application automation framework";
    homepage = "https://www.habitat.sh";
    changelog = "https://github.com/habitat-sh/habitat/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      rushmorem
      qjoly
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "hab";
  };
})
