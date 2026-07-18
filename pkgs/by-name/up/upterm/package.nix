{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nixosTests,
  testers,
  upterm,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "upterm";
  version = "0.24.0";

  src = fetchFromGitHub {
    owner = "owenthereal";
    repo = "upterm";
    rev = "v${finalAttrs.version}";
    hash = "sha256-b52Rny6mYkmfF6Umn2tzlnUhNkENHPFpCzp55OWj92w=";
  };

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
    installShellFiles
  ];

  vendorHash = "sha256-UkZnLbxn0dPT43ycuevcwMw0dXnX1OPHLh5F1XMHWDI=";
  doCheck = true;

  postInstall = ''
    # force go to build for build arch rather than host arch during cross-compiling
    CGO_ENABLED=0 GOOS= GOARCH= go run cmd/gendoc/main.go
    installManPage etc/man/man*/*
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    for cmd in upterm uptermd; do
      installShellCompletion --cmd $cmd \
        --bash <($out/bin/$cmd completion bash) \
        --fish <($out/bin/$cmd completion fish) \
        --zsh <($out/bin/$cmd completion zsh)
    done
  '';

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/owenthereal/upterm/internal/version.Version=${finalAttrs.version}"
  ];

  subPackages = [
    "cmd/upterm"
    "cmd/uptermd"
  ];

  passthru.tests = {
    inherit (nixosTests) uptermd;

    version = testers.testVersion {
      version = "Upterm version ${finalAttrs.version}";
      command = "HOME=$PWD upterm version"; # upterm tries to write to $HOME
      package = upterm;
    };
  };

  meta = {
    description = "Secure terminal-session sharing";
    homepage = "https://upterm.dev";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hax404 ];
  };
})
