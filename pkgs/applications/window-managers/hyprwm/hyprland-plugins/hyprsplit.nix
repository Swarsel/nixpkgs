{
  lib,
  fetchFromGitHub,
  meson,
  mkHyprlandPlugin,
  ninja,
  nix-update-script,
}:
mkHyprlandPlugin (finalAttrs: {
  version = "0.54.2";

  src = fetchFromGitHub {
    owner = "shezdy";
    repo = "hyprsplit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NFMLZmM6lM7v6WFcewOp7pKPlr6ampX/MB/kGxt/gPE=";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  pluginName = "hyprsplit";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Hyprland plugin for awesome / dwm like workspaces";
    homepage = "https://github.com/shezdy/hyprsplit";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      aacebedo
      mrdev023
    ];
  };
})
