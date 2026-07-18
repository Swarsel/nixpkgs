{
  lib,
  fetchFromGitHub,
  nix-update-script,
  nixosTests,
  openssl,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mycelium";
  version = "0.7.10";

  src = fetchFromGitHub {
    owner = "threefoldtech";
    repo = "mycelium";
    rev = "v${finalAttrs.version}";
    hash = "sha256-lKhq0+mymon6Xu82CSF96Kys1XSOpV/J+nwVywnUur4=";
  };

  nativeBuildInputs = [ versionCheckHook ];
  cargoHash = "sha256-heHR/iR5OUctvXh6HUpfrJtoKeziY6bqT0vkXPOEjIU=";

  env = {
    OPENSSL_DIR = "${lib.getDev openssl}";
    OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
    OPENSSL_NO_VENDOR = 1;
  };

  doInstallCheck = true;
  sourceRoot = "${finalAttrs.src.name}/myceliumd";

  passthru = {
    tests = {
      inherit (nixosTests) mycelium;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "End-2-end encrypted IPv6 overlay network";
    homepage = "https://github.com/threefoldtech/mycelium";
    changelog = "https://github.com/threefoldtech/mycelium/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      flokli
      matthewcroughan
      rvdp
    ];

    mainProgram = "mycelium";
  };
})
