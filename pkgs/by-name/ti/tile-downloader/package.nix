{
  lib,
  fetchFromGitLab,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tile-downloader";
  version = "0.1.0";

  src = fetchFromGitLab {
    owner = "stephen";
    repo = "tile-downloader";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+FnLGMUGyuaN7uPRvuounDKwF6pV9NKv3r/ajdKtdCE=";
    domain = "gitlab.scd31.com";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-jKNp+YJKZ3qpaDzwi3DvFaZAipRhm1+sTtKBtQEj7qI=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Multi-threaded raster tile downloader, primarily designed for downloading OSM tiles for usage offline";
    homepage = "https://gitlab.scd31.com/stephen/tile-downloader";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ scd31 ];
    mainProgram = "tile-downloader";
  };
})
