{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kubetui";
  version = "1.12.1";

  src = fetchFromGitHub {
    owner = "sarub0b0";
    repo = "kubetui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tLnZLZUYaV5o91wO95arZfkDtnSxui+3TLFCe+uAVdY=";
  };

  cargoHash = "sha256-En58/bR1UEqUlkIoyU9iEm/UzB2m7mhdAqWp44sU2z4=";

  checkFlags = [
    "--skip=workers::kube::store::tests::kubeconfigからstateを生成"
  ];

  meta = {
    description = "Intuitive TUI tool for real-time monitoring and exploration of Kubernetes resources";
    homepage = "https://github.com/sarub0b0/kubetui";
    changelog = "https://github.com/sarub0b0/kubetui/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.unix;
    mainProgram = "kubetui";
  };
})
