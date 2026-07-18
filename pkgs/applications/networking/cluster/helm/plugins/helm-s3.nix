{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "helm-s3";
  version = "0.17.2";

  src = fetchFromGitHub {
    owner = "hypnoglow";
    repo = "helm-s3";
    rev = "v${version}";
    hash = "sha256-ivaREH6IiNNfgah45jITzl50miDJ34BlzWwMEdKAbjg=";
  };

  # NOTE: Remove the install and upgrade hooks.
  postPatch = ''
    sed -i '/^hooks:/,+2 d' plugin.yaml
  '';

  vendorHash = "sha256-F01BWnCAZ9IJgbHgnmlB2f/MTqu0mWcidCPDdTqzhUg=";

  # NOTE: make test-unit, but skip awsutil, which needs internet access
  checkPhase = ''
    go test $(go list ./... | grep -vE '(awsutil|e2e)')
  '';

  postInstall = ''
    install -dm755 $out/helm-s3
    mv $out/bin $out/helm-s3/
    install -m644 -Dt $out/helm-s3 plugin.yaml
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  subPackages = [ "cmd/helm-s3" ];

  meta = {
    description = "Helm plugin that allows to set up a chart repository using AWS S3";
    homepage = "https://github.com/hypnoglow/helm-s3";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ yurrriq ];
  };
}
