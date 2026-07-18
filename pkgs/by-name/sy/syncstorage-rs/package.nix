{
  lib,
  fetchFromGitHub,
  cmake,
  libmysqlclient,
  makeBinaryWrapper,
  nix-update-script,
  nixosTests,
  pkg-config,
  python3,
  rustPlatform,
}:

let
  pyFxADeps = python3.withPackages (p: [
    p.setuptools # imports pkg_resources
    # remainder taken from requirements.txt
    p.pyfxa
    p.tokenlib
    p.cryptography
  ]);
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "syncstorage-rs";
  version = "0.21.1-unstable-2026-01-26";

  src = fetchFromGitHub {
    owner = "mozilla-services";
    repo = "syncstorage-rs";
    rev = "11659d98f9c69948a0aab353437ce2036c388711";
    hash = "sha256-G37QvxTNh/C3gmKG0UYHI6QBr0F+KLGRNI/Sx33uOsc=";
  };

  nativeBuildInputs = [
    cmake
    makeBinaryWrapper
    pkg-config
    python3
  ];

  buildInputs = [
    libmysqlclient
  ];

  cargoHash = "sha256-9Dcf5mDyK/XjsKTlCPXTHoBkIq+FFPDg1zfK24Y9nHQ=";
  # almost all tests need a DB to test against
  doCheck = false;

  preFixup = ''
    wrapProgram $out/bin/syncserver \
      --prefix PATH : ${lib.makeBinPath [ pyFxADeps ]}
  '';

  passthru.tests = { inherit (nixosTests) firefox-syncserver; };
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Mozilla Sync Storage built with Rust";
    homepage = "https://github.com/mozilla-services/syncstorage-rs";
    changelog = "https://github.com/mozilla-services/syncstorage-rs/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "syncserver";
  };
})
