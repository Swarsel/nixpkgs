{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "yanic";
  version = "1.8.3";

  src = fetchFromGitHub {
    owner = "FreifunkBremen";
    repo = "yanic";
    rev = "v${finalAttrs.version}";
    hash = "sha256-6jGuqqUr9DJyPYAVBBHc5qtfJIbvjGndT2Y+RSLMzhY=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-TcmkPBHxpmTgXNW8gPkzMpjPGCQu/HrZqAu9jDpPEjo=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd yanic \
      --bash <($out/bin/yanic completion bash) \
      --fish <($out/bin/yanic completion fish) \
      --zsh <($out/bin/yanic completion zsh)
  '';

  ldflags = [
    "-X github.com/FreifunkBremen/yanic/cmd.VERSION=${finalAttrs.version}"
    "-s"
    "-w"
  ];

  meta = {
    description = "Tool to collect and aggregate respondd data";
    homepage = "https://github.com/FreifunkBremen/yanic";
    changelog = "https://github.com/FreifunkBremen/yanic/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ herbetom ];
    mainProgram = "yanic";
  };
})
