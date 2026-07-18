{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "cloudfoundry-cli";
  version = "8.18.4";

  src = fetchFromGitHub {
    owner = "cloudfoundry";
    repo = "cli";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-qbNRferh8AEo3Y7zCgaQKQ1IZHSbhDYzy7OqZahiBfA=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-zkv7ZuEKp6Nlw1NQqr0A6HX4Jx/yFR4wpo7tyD6VoXY=";

  postInstall = ''
    mv "$out/bin/cli" "$out/bin/cf"
    installShellCompletion --bash $bashCompletionScript
  '';

  # upstream have helpfully moved the bash completion script to a separate
  # repo which receives no releases or even tags
  bashCompletionScript = fetchurl {
    sha256 = "06w26kpnjd3f2wdjhb4pp0kaq2gb9kf87v7pjd9n2g7s7qhdqyhy";
    url = "https://raw.githubusercontent.com/cloudfoundry/cli-ci/5f4f0d5d01e89c6333673f0fa96056749e71b3cd/ci/installers/completion/cf8";
  };

  ldflags = [
    "-s"
    "-w"
    "-X code.cloudfoundry.org/cli/version.binaryBuildDate=1970-01-01"
    "-X code.cloudfoundry.org/cli/version.binaryVersion=${finalAttrs.version}"
  ];

  subPackages = [ "." ];

  meta = {
    description = "Official command line client for Cloud Foundry";
    homepage = "https://github.com/cloudfoundry/cli";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ris ];
    mainProgram = "cf";
  };
})
