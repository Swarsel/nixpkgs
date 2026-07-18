{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  buildPackages,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "diffoci";
  version = "0.1.8";

  src = fetchFromGitHub {
    owner = "reproducible-containers";
    repo = "diffoci";
    rev = "v${finalAttrs.version}";
    hash = "sha256-rOgnFqjA78JhW3oo3tHDsIjz8GzwK6Og7BqOTEj5fn4=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-IQrPFZPL6KOnU75tT/YWUGN1oasCOTLzVG2ZllgWhJE=";

  postInstall =
    let
      diffoci =
        if stdenv.buildPlatform.canExecute stdenv.hostPlatform then
          placeholder "out"
        else
          buildPackages.diffoci;
    in
    ''
      installShellCompletion --cmd diffoci \
        --bash <(${diffoci}/bin/diffoci completion bash) \
        --fish <(${diffoci}/bin/diffoci completion fish) \
        --zsh <(${diffoci}/bin/diffoci completion zsh)
    '';

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/reproducible-containers/diffoci/cmd/diffoci/version.Version=v${finalAttrs.version}"
  ];

  meta = {
    description = "Diff for Docker and OCI container images";
    homepage = "https://github.com/reproducible-containers/diffoci/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jk ];
    mainProgram = "diffoci";
  };
})
