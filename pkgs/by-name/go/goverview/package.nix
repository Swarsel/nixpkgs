{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "goverview";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "j3ssie";
    repo = "goverview";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IgvpMuDwMK9IdPs1IRbPbpgr7xZuDX3boVT5d7Lb+3w=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-i/m2s9e8PDfGmguNihynVI3Y7nAXC4weoWFXOwUVDSE=";
  # Tests require network access
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd goverview \
      --bash <($out/bin/goverview completion bash) \
      --fish <($out/bin/goverview completion fish) \
      --zsh <($out/bin/goverview completion zsh)
  '';

  ldflags = [
    "-w"
    "-s"
  ];

  meta = {
    description = "Tool to get an overview of the list of URLs";
    homepage = "https://github.com/j3ssie/goverview";
    changelog = "https://github.com/j3ssie/goverview/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "goverview";
  };
})
