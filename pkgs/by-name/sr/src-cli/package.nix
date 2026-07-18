{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  src-cli,
  testers,
}:

buildGoModule rec {
  pname = "src-cli";
  version = "7.5.0";

  src = fetchFromGitHub {
    owner = "sourcegraph";
    repo = "src-cli";
    rev = version;
    hash = "sha256-4E4ph++YP3c3+edmLHTGTGybKpiVoAzbehOmhYglzpo=";
  };

  vendorHash = "sha256-cr5KUYuEDlahkz2DwTD2yw+Tl/QrTP2O6b1HzQqXnzE=";

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/sourcegraph/src-cli/internal/version.BuildTag=${version}"
  ];

  subPackages = [
    "cmd/src"
  ];

  passthru.tests = {
    version = testers.testVersion {
      command = "src version -client-only";
      package = src-cli;
    };
  };

  meta = {
    description = "Sourcegraph CLI";
    homepage = "https://github.com/sourcegraph/src-cli";
    changelog = "https://github.com/sourcegraph/src-cli/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      keegancsmith
      burmudar
    ];

    mainProgram = "src";
  };
}
