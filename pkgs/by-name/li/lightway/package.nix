{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  libtool,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "lightway";
  version = "0-unstable-2026-04-24";

  src = fetchFromGitHub {
    owner = "expressvpn";
    repo = "lightway";
    rev = "8e0940f047ee72db5daa1fb7c3bb82bc89e0f1d9";
    hash = "sha256-OFMAEw613aIGG7N5LBAGbVrpkqMUBi7lUy7jm5tZowc=";
  };

  # For wolfSSL.
  nativeBuildInputs = [
    autoconf
    automake
    libtool
    rustPlatform.bindgenHook
  ];

  cargoHash = "sha256-gY8KokOtdBT7Vq+lGn2sk4/o3A0TypEqv09TVJqaZjc=";

  # Enable ARM crypto extensions, overrides the default stdenv.hostPlatform.gcc.arch.
  env.NIX_CFLAGS_COMPILE =
    with stdenv.hostPlatform;
    lib.optionalString (isAarch && isLinux) "-march=${gcc.arch}+crypto";

  cargoBuildFlags = lib.cli.toCommandLineGNU { } {
    features = lib.optionals stdenv.hostPlatform.isLinux [
      "io-uring"
    ];

    package = [
      "lightway-client"
      "lightway-server"
    ];
  };

  meta = {
    description = "A modern VPN protocol in Rust";
    homepage = "https://expressvpn.com/lightway";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      dustyhorizon
      usertam
    ];

    platforms = with lib.platforms; darwin ++ linux;
    mainProgram = "lightway-client";
  };
}
