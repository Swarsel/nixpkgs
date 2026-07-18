{
  lib,
  fetchFromGitHub,
  bzip2,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rns-proxy";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "mytecor";
    repo = "rns-proxy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+nn6BjzG/SJr8plAVj3R9c459XqvbKSGSqAnNa+QGkY=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    bzip2
  ];

  cargoHash = "sha256-o+tMlsTuFR89lNwSl3+s+WOTVVReGCJc1xAAwK1zklg=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "SOCKS5 tunnels over the Reticulum Network Stack";
    homepage = "https://github.com/mytecor/rns-proxy";
    changelog = "https://github.com/mytecor/rns-proxy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ drupol ];
    mainProgram = "rns-proxy";
  };
})
