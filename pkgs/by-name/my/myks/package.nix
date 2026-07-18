{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  myks,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "myks";
  version = "5.13.2";

  src = fetchFromGitHub {
    owner = "mykso";
    repo = "myks";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ij1QmMr2JJSjs+5e80RxjZcCKoSqNb9mD+IKtQjX13w=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-x5yCigeM4ltL1wphW8ufa0WB3nd14AOkXGLggAxKTrs=";
  env.CGO_ENABLED = 0;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd myks \
      --bash <($out/bin/myks completion bash) \
      --zsh <($out/bin/myks completion zsh) \
      --fish <($out/bin/myks completion fish)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${finalAttrs.version}"
    "-X=main.commit=nixpkg-${finalAttrs.version}"
    "-X=main.date=1970-01-01"
  ];

  subPackages = ".";
  passthru.tests.version = testers.testVersion { package = myks; };

  meta = {
    description = "Configuration framework for Kubernetes applications";
    homepage = "https://github.com/mykso/myks";
    changelog = "https://github.com/mykso/myks/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers.kbudde
      lib.maintainers.zebradil
    ];

    mainProgram = "myks";
  };
})
