{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "commitizen-go";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "lintingzhen";
    repo = "commitizen-go";
    rev = "v${version}";
    hash = "sha256-pAWdIQ3icXEv79s+sUVhQclsNcZg+PTZZ6I6JPo7pNg=";
  };

  vendorHash = "sha256-TbrgKE7P3c0gkqJPDkbchWTPkOuTaTAWd8wDcpffcCc=";
  env.CGO_ENABLED = 0;
  # we can't obtain the commit hash when using fetchFromGitHub
  commit_revision = "unspecified (nix build)";

  ldflags = [
    "-X 'github.com/lintingzhen/commitizen-go/cmd.revision=${commit_revision}'"
    "-X 'github.com/lintingzhen/commitizen-go/cmd.version=${version}'"
  ];

  subPackages = [ "." ];

  meta = {
    description = "Command line utility to standardize git commit messages, golang version";
    homepage = "https://github.com/lintingzhen/commitizen-go";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ seanrmurphy ];
    mainProgram = "commitizen-go";
  };
}
