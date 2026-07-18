{
  lib,
  fetchFromGitHub,
  fetchpatch2,
  glib,
  libz,
  openssl,
  ostree-full,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  zstd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bootc";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "bootc-dev";
    repo = "bootc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-TztsiC+DwD9yEAmjTuiuOi+Kf8WEYMsOVVnMKpSM3/g=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-7UKquq6ZargQUDGZk22X9Co92v8e995bL+tuAjvh/7c=";
      url = "https://github.com/bootc-dev/bootc/commit/ff8b1b411270275c49ee512d54b27ed7a2fca112.patch";
    })
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libz
    zstd
    openssl
    glib
    ostree-full
  ];

  cargoHash = "sha256-KGwXQ6+/w3uHuPqSADsqJSip+SMdC104dfW7tNxGwnc=";

  checkFlags = [
    # These all require a writable /var/tmp
    "--skip=test_cli_fns"
    "--skip=test_diff"
    "--skip=test_tar_export_reproducible"
    "--skip=test_tar_export_structure"
    "--skip=test_tar_import_empty"
    "--skip=test_tar_import_export"
    "--skip=test_tar_import_signed"
    "--skip=test_tar_write"
    "--skip=test_tar_write_tar_layer"
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  cargoBuildFlags = [ "-p bootc" ];

  meta = {
    description = "Boot and upgrade via container images";
    homepage = "https://bootc-dev.github.io/bootc";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ thesola10 ];
    platforms = lib.platforms.linux;
    mainProgram = "bootc";
  };
})
