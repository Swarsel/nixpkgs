{
  lib,
  fetchFromGitHub,
  bzip2,
  curl,
  installShellFiles,
  libgit2,
  nix,
  nix-update-script,
  nurl,
  openssl,
  pkg-config,
  rustPlatform,
  spdx-license-list-data,
  sqlite,
  versionCheckHook,
  writeText,
  zlib,
  zstd,
}:

let
  get-nix-license = import ./get_nix_license.nix {
    inherit lib writeText;
  };
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nix-init";
  version = "0.3.6";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "nix-init";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9UEGGtNm5XpcBA/80v03XEunWshgM0M35TrJ79PQNG8=";
  };

  postPatch = ''
    mkdir -p data
    ln -s ${get-nix-license} data/get_nix_license.rs
  '';

  nativeBuildInputs = [
    curl
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    bzip2
    curl
    libgit2
    openssl
    sqlite
    zlib
    zstd
  ];

  cargoHash = "sha256-cRnyTuUIRUFPWUle7/bcqcZ9LjvhRuK2tF++hoMl+xs=";

  env = {
    GEN_ARTIFACTS = "artifacts";
    LIBGIT2_NO_VENDOR = true;
    LIBSQLITE3_SYS_USE_PKG_CONFIG = true;
    NIX = lib.getExe nix;
    NURL = lib.getExe nurl;
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  preBuild = ''
    cargo run -p license-store-cache \
      -j $NIX_BUILD_CORES --frozen \
      data/license-store-cache.zstd ${spdx-license-list-data.json}/json/details
  '';

  checkFlags = [
    # require internet access
    "--skip=e2e"
    "--skip=lang::rust::tests"
  ];

  postInstall = ''
    installManPage artifacts/nix-init.1
    installShellCompletion artifacts/nix-init.{bash,fish} --zsh artifacts/_nix-init
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  buildNoDefaultFeatures = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command line tool to generate Nix packages from URLs";
    homepage = "https://github.com/nix-community/nix-init";
    changelog = "https://github.com/nix-community/nix-init/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      eclairevoyant
      figsoda
    ];

    mainProgram = "nix-init";
  };
})
