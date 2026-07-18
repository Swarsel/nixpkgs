{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hyprland-workspaces";
  version = "2.0.4";

  src = fetchFromGitHub {
    owner = "FieldofClay";
    repo = "hyprland-workspaces";
    rev = "v${finalAttrs.version}";
    hash = "sha256-a5P99aSqhlZqClXAoaUNv/jmuM5duLDf+OzMeKGwDVI=";
  };

  cargoHash = "sha256-UoL1b+T4z2hAl7GOga68qwAyCtm+Xo+AbyORmwvsqkw=";

  meta = {
    description = "Multi-monitor aware Hyprland workspace widget";
    homepage = "https://github.com/FieldofClay/hyprland-workspaces";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      kiike
      donovanglover
    ];

    platforms = lib.platforms.linux;
    mainProgram = "hyprland-workspaces";
  };
})
