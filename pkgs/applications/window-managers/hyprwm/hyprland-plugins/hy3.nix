{
  lib,
  fetchFromGitHub,
  cmake,
  hyprland,
  mkHyprlandPlugin,
  nix-update-script,
}:
mkHyprlandPlugin (finalAttrs: {
  version = "0.55.0";

  src = fetchFromGitHub {
    owner = "outfoxxed";
    repo = "hy3";
    tag = "hl${finalAttrs.version}";
    hash = "sha256-P3wwiIfqo89evW7xzI+wOI/qM1WPZBiiSmGNtBmYeVk=";
  };

  nativeBuildInputs = [ cmake ];
  dontStrip = true;
  pluginName = "hy3";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "hl(.*)"
    ];
  };

  meta = {
    inherit (hyprland.meta) platforms;
    description = "Hyprland plugin for an i3 / sway like manual tiling layout";
    homepage = "https://github.com/outfoxxed/hy3";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      aacebedo
      johnrtitor
    ];
  };
})
