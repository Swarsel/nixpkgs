{
  lib,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rmux";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "Helvesec";
    repo = "rmux";
    tag = "v${finalAttrs.version}";
    hash = "sha256-73pSH4wowEWYyKQf1htbB0RnCw3qHe0rENr66eyFnM4=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-YcCYMEM+u+Vq5mzqlL1rqyJmSYt2VxZNBt6cJ4t0Als=";
  # Tests require network access
  doCheck = false;
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Universal multiplexer with a typed SDK";
    homepage = "https://github.com/Helvesec/rmux";
    changelog = "https://github.com/Helvesec/rmux/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "rmux";
  };
})
