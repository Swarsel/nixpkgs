{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGo125Module,
  buildPackages,
  installShellFiles,
  nix-update-script,
  versionCheckHook,
}:
buildGo125Module (finalAttrs: {
  pname = "usque";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "Diniboy1123";
    repo = "usque";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4vFlHJINMDlaOC+R5Q+vUhmyrXlv1r8UiNVRx8juxZ4=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-/SYyIWRr+uwF5Jr5Ql08a+WwrZMXmKEa+Q7Nxzt2wKw=";

  postInstall =
    let
      exe =
        if stdenv.buildPlatform.canExecute stdenv.hostPlatform then
          "$out/bin/usque"
        else
          lib.getExe buildPackages.usque;
    in
    ''
      installShellCompletion --cmd usque \
        --bash <(${exe} completion bash) \
        --fish <(${exe} completion fish) \
        --zsh <(${exe} completion zsh)
    '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/Diniboy1123/usque/cmd.version=${finalAttrs.version}"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}";
  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open-source reimplementation of the Cloudflare WARP client's MASQUE protocol";
    homepage = "https://github.com/Diniboy1123/usque";
    changelog = "https://github.com/Diniboy1123/usque/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "usque";
  };
})
