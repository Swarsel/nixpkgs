{
  lib,
  fetchFromGitHub,
  git,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "workset";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "fossable";
    repo = "workset";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ryi5zLlOVNVtHhMZ5PglNFKVrrSlrcj3TOoeHKjGAic=";
  };

  nativeBuildInputs = [ pkg-config ];
  cargoHash = "sha256-VJ1vXEZkOYUGba8hfgdlNpT0QAvHDPdR+TNhDNprKNk=";
  nativeCheckInputs = [ git ];
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Manage git repos with working sets";
    homepage = "https://github.com/fossable/workset";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ cilki ];
    platforms = lib.platforms.unix;
    mainProgram = "workset";
  };
})
