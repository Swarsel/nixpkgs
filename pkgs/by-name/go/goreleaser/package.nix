{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGo126Module,
  buildPackages,
  goreleaser,
  installShellFiles,
  testers,
}:
buildGo126Module (finalAttrs: {
  pname = "goreleaser";
  version = "2.17.0";

  src = fetchFromGitHub {
    owner = "goreleaser";
    repo = "goreleaser";
    rev = "v${finalAttrs.version}";
    hash = "sha256-BB2URWDc5WR51uVsA0I9qhd0T6wYtmqM/jF5YAaV30o=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-dSJ7F7PKGMZCoKAbu7SpJSXDKQWicoqNA3Kwl9+kGwI=";
  # tests expect the source files to be a build repo
  doCheck = false;

  postInstall =
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      ${emulator} $out/bin/goreleaser man > goreleaser.1
      installManPage ./goreleaser.1
      installShellCompletion --cmd goreleaser \
        --bash <(${emulator} $out/bin/goreleaser completion bash) \
        --fish <(${emulator} $out/bin/goreleaser completion fish) \
        --zsh  <(${emulator} $out/bin/goreleaser completion zsh)
    '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.builtBy=nixpkgs"
  ];

  subPackages = [
    "."
  ];

  passthru.tests.version = testers.testVersion {
    inherit (finalAttrs) version;
    command = "goreleaser -v";
    package = goreleaser;
  };

  meta = {
    description = "Deliver Go binaries as fast and easily as possible";
    homepage = "https://goreleaser.com";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      sarcasticadmin
      techknowlogick
      caarlos0
    ];

    mainProgram = "goreleaser";
  };
})
