{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "kubecm";
  version = "0.35.1";

  src = fetchFromGitHub {
    owner = "sunny0826";
    repo = "kubecm";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5wTxVzpvwD6jx6Cfa0ChIi8wQCrnqzZM2jvwGpQdq50=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-TyJpFN8JEWpzCHKUX3iYUHhTOOAp5I1YEzhUkWPXx8A=";
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd kubecm \
      --bash <($out/bin/kubecm completion bash) \
      --fish <($out/bin/kubecm completion fish) \
      --zsh <($out/bin/kubecm completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sunny0826/kubecm/version.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Manage your kubeconfig more easily";
    homepage = "https://github.com/sunny0826/kubecm/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      qjoly
      sailord
    ];

    mainProgram = "kubecm";
  };
})
