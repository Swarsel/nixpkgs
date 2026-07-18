{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "glooctl";
  version = "1.21.11";

  src = fetchFromGitHub {
    owner = "solo-io";
    repo = "gloo";
    rev = "v${finalAttrs.version}";
    hash = "sha256-inW2L8BzZnupDmgOR53pPQlATQRoTo4/VGDZD8fvUQ8=";
  };

  strictDeps = true;
  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-BMaRuW8NUIsTnPvIbMWd4tgt7IUUU7VjK64DMNP5hC0=";

  preCheck = ''
    export HOME=$TMPDIR
  '';

  postInstall = ''
    mv $out/bin/cmd $out/bin/glooctl
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd glooctl \
      --bash <($out/bin/glooctl completion bash) \
      --zsh <($out/bin/glooctl completion zsh)
  '';

  ldflags = [
    "-s"
    "-X github.com/solo-io/gloo/pkg/version.Version=${finalAttrs.version}"
  ];

  subPackages = [ "projects/gloo/cli/cmd" ];

  meta = {
    description = "Unified CLI for Gloo, the feature-rich, Kubernetes-native, next-generation API gateway built on Envoy";
    homepage = "https://docs.solo.io/gloo-edge/latest/reference/cli/glooctl/";
    changelog = "https://github.com/solo-io/gloo/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "glooctl";
  };
})
