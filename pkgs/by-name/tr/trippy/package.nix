{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "trippy";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "fujiapple852";
    repo = "trippy";
    rev = finalAttrs.version;
    hash = "sha256-+WLWtHguDm23VLjZ4aQnyLAnE/uynONj8lsfVMTTuwY=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-kVqj+rYPxfv/9h+HDdSL5jU6DoU5KoJVVQot4O4WVNc=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    local INSTALL="$out/bin/trip"
    installShellCompletion --cmd trip \
      --bash <($out/bin/trip --generate bash) \
      --fish <($out/bin/trip --generate fish) \
      --zsh <($out/bin/trip --generate zsh)
  '';

  cargoBuildFlags = [ "--package trippy" ];

  meta = {
    description = "Network diagnostic tool";
    homepage = "https://trippy.cli.rs";
    changelog = "https://github.com/fujiapple852/trippy/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.matthiasbeyer ];
    mainProgram = "trip";
  };
})
