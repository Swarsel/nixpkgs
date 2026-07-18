{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  go,
  nix-update-script,
}:

buildGoModule rec {
  pname = "jx";
  version = "3.17.17";

  src = fetchFromGitHub {
    owner = "jenkins-x";
    repo = "jx";
    rev = "v${version}";
    sha256 = "sha256-Fu8qBiRWLZBK2Qn+fVPi7TVeqK+/ZD5a/c5yvPnypWo=";
  };

  vendorHash = "sha256-tGvreLuxaRswjCGzroCRRDZR4QadQKLrX9Hz3u22VZ0=";
  env.CGO_ENABLED = 0;

  postInstall = ''
    mv $out/bin/cmd $out/bin/jx
  '';

  ldflags = [
    "-s"
    "-X github.com/jenkins-x/jx/pkg/cmd/version.Version=${version}"
    "-X github.com/jenkins-x/jx/pkg/cmd/version.Revision=${src.rev}"
    "-X github.com/jenkins-x/jx/pkg/cmd/version.GoVersion=${go.version}"
    "-X github.com/jenkins-x/jx/pkg/cmd/version.GitTreeState=clean"
    "-X github.com/jenkins-x/jx/pkg/cmd/version.BuildDate=''"
  ];

  subPackages = [ "cmd" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command line tool for installing and using Jenkins X";

    longDescription = ''
      Jenkins X provides automated CI+CD for Kubernetes with Preview
      Environments on Pull Requests using using Cloud Native pipelines
      from Tekton.
    '';

    homepage = "https://jenkins-x.io";
    changelog = "https://github.com/jenkins-x/jx/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kalbasit ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "jx";
    broken = stdenv.hostPlatform.isDarwin;
  };
}
