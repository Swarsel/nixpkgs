{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "gitlab-ci-pipelines-exporter";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "mvisonneau";
    repo = "gitlab-ci-pipelines-exporter";
    rev = "v${version}";
    sha256 = "sha256-r/6tRecbLN9bX2+HYyk4tT0uNiAqtZwMoMMQUJ7niJI=";
  };

  vendorHash = "sha256-k1yqPVaCRtU9qpCSBR4Mo4n+9cOCT9xyRI1Ian9rNOk=";
  doCheck = true;

  ldflags = [
    "-X main.version=v${version}"
  ];

  subPackages = [ "cmd/gitlab-ci-pipelines-exporter" ];

  meta = {
    description = "Prometheus / OpenMetrics exporter for GitLab CI pipelines insights";
    homepage = "https://github.com/mvisonneau/gitlab-ci-pipelines-exporter";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      mmahut
      mvisonneau
    ];

    mainProgram = "gitlab-ci-pipelines-exporter";
  };
}
