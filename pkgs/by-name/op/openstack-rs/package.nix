{
  lib,
  stdenv,
  fetchFromGitHub,
  cacert,
  installShellFiles,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "openstack-rs";
  version = "0.13.7";

  src = fetchFromGitHub {
    owner = "gtema";
    repo = "openstack";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cpx35OT/x/2XJD4RzaWX/yKM4nwBgl6/gVrEtgyljEI=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  cargoHash = "sha256-LwN+7LkE/nFbiUlcSjQRxIg0BtO4XLuf/wPS1Vdvx+M=";

  nativeCheckInputs = [
    cacert
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd osc \
      --bash <($out/bin/osc completion bash) \
      --fish <($out/bin/osc completion fish) \
      --zsh <($out/bin/osc completion zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "OpenStack CLI and TUI implemented in Rust";
    homepage = "https://github.com/gtema/openstack";
    changelog = "https://github.com/gtema/openstack/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ lykos153 ];
    mainProgram = "osc";
  };
})
