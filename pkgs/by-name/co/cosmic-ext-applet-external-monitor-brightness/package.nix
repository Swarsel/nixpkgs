{
  lib,
  stdenv,
  fetchFromGitHub,
  just,
  libcosmicAppHook,
  nix-update-script,
  pkg-config,
  rustPlatform,
  udev,
}:
rustPlatform.buildRustPackage {
  pname = "cosmic-ext-applet-external-monitor-brightness";
  version = "0.0.1-unstable-2026-02-15";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "cosmic-ext-applet-external-monitor-brightness";
    rev = "f84c46dfa89c369484cc616d15485ae1bf257803";
    hash = "sha256-uEoLhVIv25KNoDD28HIIMutxR2nv+AIapSRlz+ETGuQ=";
  };

  nativeBuildInputs = [
    libcosmicAppHook
    just
    pkg-config
  ];

  buildInputs = [ udev ];
  cargoHash = "sha256-ou7iukl1pHMfcJNemwLdZYYxugbJJQ53XpCYowUTj90=";
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
    description = "Applet to control the brightness of external monitors";
    homepage = "https://github.com/cosmic-utils/cosmic-ext-applet-external-monitor-brightness";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ HeitorAugustoLN ];
    platforms = lib.platforms.linux;
    mainProgram = "cosmic-ext-applet-external-monitor-brightness";
  };
}
