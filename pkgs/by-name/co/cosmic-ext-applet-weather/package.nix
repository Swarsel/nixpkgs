{
  lib,
  stdenv,
  fetchFromGitHub,
  just,
  libcosmicAppHook,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "cosmic-ext-applet-weather";
  version = "0-unstable-2026-06-05";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "cosmic-ext-applet-weather";
    rev = "4571eeee76755cc202f11007c4641196ad8a2793";
    hash = "sha256-D/uCIJL79AWRIabps8I82wc0yP9CrOimx0g9dEthd08=";
  };

  nativeBuildInputs = [
    libcosmicAppHook
    just
  ];

  cargoHash = "sha256-AHz4gQGGbVMmr/bbUdkfNQq3zx88+kPenq6kDz8IxN8=";
  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "cargo-target-dir"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}"
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch=HEAD"
    ];
  };

  meta = {
    description = "Simple weather info applet for COSMIC";
    homepage = "https://github.com/cosmic-utils/cosmic-ext-applet-weather";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ HeitorAugustoLN ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-ext-applet-weather";
  };
}
