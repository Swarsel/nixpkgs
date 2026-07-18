{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  sq,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "sq";
  version = "0.50.0";

  src = fetchFromGitHub {
    owner = "neilotoole";
    repo = "sq";
    rev = "v${finalAttrs.version}";
    hash = "sha256-K9bqV9iJADP3yHSay6ZUv+ohakbD5sIEDJusTGSoqec=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-w08vGn2AxdZVQU/E/RPBipqFOuujnAjpvSluw/a8zjY=";
  # Some tests violates sandbox constraints.
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd sq \
      --bash <($out/bin/sq completion bash) \
      --fish <($out/bin/sq completion fish) \
      --zsh <($out/bin/sq completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/neilotoole/sq/cli/buildinfo.Version=v${finalAttrs.version}"
  ];

  proxyVendor = true;

  passthru.tests = {
    version = testers.testVersion {
      version = "v${finalAttrs.version}";
      package = sq;
    };
  };

  meta = {
    description = "Swiss army knife for data";
    homepage = "https://sq.io/";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "sq";
  };
})
