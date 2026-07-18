{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  rustPlatform,
  systemdLibs,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sftool";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "OpenSiFli";
    repo = "sftool";
    tag = finalAttrs.version;
    hash = "sha256-ty95ZIFztbYOzdNfWNiDbPNbY3Jqyz2e2PZphPWE1mA=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    systemdLibs # libudev-sys
  ];

  cargoHash = "sha256-0V+n6QhKfzQVy6emzNX6178PtYTaHVSWL5tW5BvqEpU=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Download tool for the SiFli family of chips";
    homepage = "https://github.com/OpenSiFli/sftool";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "sftool";
  };
})
