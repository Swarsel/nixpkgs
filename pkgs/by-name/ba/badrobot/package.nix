{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "badrobot";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "controlplaneio";
    repo = "badrobot";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-U3b5Xw+GjnAEXteivztHdcAcXx7DYtgaUbW5oax0mIk=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-oYdkCEdrw1eE5tnKveeJM3upRy8hOVc24JNN1bLX+ec=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd badrobot \
      --bash <($out/bin/badrobot completion bash) \
      --fish <($out/bin/badrobot completion fish) \
      --zsh <($out/bin/badrobot completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/controlplaneio/badrobot/cmd.version=v${finalAttrs.version}"
  ];

  meta = {
    description = "Operator Security Audit Tool";

    longDescription = ''
      Badrobot is a Kubernetes Operator audit tool. It statically analyses
      manifests for high risk configurations such as lack of security
      restrictions on the deployed controller and the permissions of an
      associated clusterole. The risk analysis is primarily focussed on the
      likelihood that a compromised Operator would be able to obtain full
      cluster permissions.
    '';

    homepage = "https://github.com/controlplaneio/badrobot";
    changelog = "https://github.com/controlplaneio/badrobot/releases/tag/v${finalAttrs.src.tag}";
    license = with lib.licenses; [ asl20 ];

    maintainers = with lib.maintainers; [
      jk
    ];

    mainProgram = "badrobot";
  };
})
