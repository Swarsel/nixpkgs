{
  lib,
  fetchFromGitHub,
  asciidoctor,
  curl,
  findutils,
  installShellFiles,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "snphost";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "virtee";
    repo = "snphost";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9ztYKXZXhc+Fci8WvAyMWwdjurXL/S10ekCjaFOKWZE=";
  };

  nativeBuildInputs = [
    asciidoctor
    findutils
    installShellFiles
    pkg-config
  ];

  buildInputs = [
    curl
    openssl
    zlib
  ];

  cargoHash = "sha256-wZpb/S0g3KccaPlve3YeVFA9d1BqrtAe7tE2qlisG+M=";
  env.OPENSSL_NO_VENDOR = true;

  # man page is placed in cargo's $OUT_DIR, which is randomized.
  # Contacted upstream about it, for now use find to locate it.
  postInstall = ''
    installManPage $(find target/x86_64-unknown-linux-gnu/release/build -name "snphost.1")
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Administrative utility for SEV-SNP";
    homepage = "https://github.com/virtee/snphost/";
    changelog = "https://github.com/virtee/snphost/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      katexochen
      charludo
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "snphost";
  };
})
