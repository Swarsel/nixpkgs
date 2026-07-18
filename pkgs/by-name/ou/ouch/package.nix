{
  lib,
  fetchFromGitHub,
  bzip2,
  bzip3,
  cmake,
  git,
  installShellFiles,
  pkg-config,
  rustPlatform,
  xz,
  zlib,
  zstd,
  # RAR code is under non-free unRAR license
  # see the meta.license section below for more details
  enableUnfree ? false,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ouch";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "ouch-org";
    repo = "ouch";
    rev = finalAttrs.version;
    hash = "sha256-fxBalMi5xdLNBnd5VIdAYDIjbSBrOPrmpKlKW1DmbxQ=";
  };

  nativeBuildInputs = [
    cmake
    installShellFiles
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    bzip2
    bzip3
    xz
    zlib
    zstd
  ];

  cargoHash = "sha256-kYef8Xsi1gO0V2yXHiTkPi2rFjECw3jjhADSMhhu5zg=";
  env.OUCH_ARTIFACTS_FOLDER = "artifacts";

  nativeCheckInputs = [
    git
  ];

  postInstall = ''
    installManPage artifacts/*.1
    installShellCompletion artifacts/ouch.{bash,fish} --zsh artifacts/_ouch --nushell artifacts/ouch.nu
  '';

  buildFeatures = [
    "use_zlib"
    "use_zstd_thin"
    "bzip3"
    "zstd/pkg-config"
  ]
  ++ lib.optionals enableUnfree [
    "unrar"
  ];

  buildNoDefaultFeatures = true;

  meta = {
    description = "Command-line utility for easily compressing and decompressing files and directories";
    homepage = "https://github.com/ouch-org/ouch";
    changelog = "https://github.com/ouch-org/ouch/blob/${finalAttrs.version}/CHANGELOG.md";
    license = with lib.licenses; [ mit ] ++ lib.optionals enableUnfree [ unfreeRedistributable ];

    maintainers = with lib.maintainers; [
      psibi
      krovuxdev
      philocalyst
    ];

    platforms = lib.platforms.all;
    mainProgram = "ouch";
  };
})
