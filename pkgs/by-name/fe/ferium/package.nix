{
  lib,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ferium";
  version = "4.7.1";

  src = fetchFromGitHub {
    owner = "gorilla-devs";
    repo = "ferium";
    rev = "v${finalAttrs.version}";
    hash = "sha256-eeQjezB6pRdnPADLgDLo8b+bUSP12gfBhFNt/uYCwHU=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-3YKFKngyLg2ah4GY+LlbPbnVks7/xFawnMf3D1gjmwI=";
  # Requires an internet connection
  doCheck = false;

  postInstall = ''
    for shell in bash fish zsh; do
      $out/bin/ferium complete $shell > ferium.$shell
      installShellCompletion ferium.$shell
    done
  '';

  # Disable the GUI file picker so that GTK/XDG dependencies aren't used
  buildNoDefaultFeatures = true;

  meta = {
    description = "Fast and multi-source CLI program for managing Minecraft mods and modpacks from Modrinth, CurseForge, and GitHub Releases";
    homepage = "https://github.com/gorilla-devs/ferium";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      leo60228
      soupglasses
    ];

    mainProgram = "ferium";
  };
})
