{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:
buildGoModule (finalAttrs: {
  pname = "prometheus-chrony-exporter";
  version = "0.13.3";

  src = fetchFromGitHub {
    owner = "superq";
    repo = "chrony_exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nfOiGWi+buOmJGaCZpbcbQzXeCnm8q+QW53DavgoBDI=";
    leaveDotGit = true;

    postFetch = ''
      cd "$out"
      date -u -d "@$(git log -1 --pretty=%ct)" "+%Y-%m-%dT%H:%M:%SZ" > $out/BUILD_COMMIT_DATE
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  vendorHash = "sha256-nOu4t4Dchw+TXqfIY0B50zalo2ZhPWkoOeQ5MgbljMU=";

  # do not use real BuildDate, but fixed imagenary (commit date) for binary reproducibility
  preBuild = ''
    ldflags+=" -X github.com/prometheus/common/version.BuildDate=$(cat BUILD_COMMIT_DATE)"
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/prometheus/common/version.Version=${finalAttrs.version}"
    "-X github.com/prometheus/common/version.Revision=${finalAttrs.src.rev}"
    "-X github.com/prometheus/common/version.Branch=master"
    "-X github.com/prometheus/common/version.BuildUser=nix@nixpkgs"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/chrony_exporter";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Prometheus exporter for the chrony NTP service";
    homepage = "https://github.com/SuperQ/chrony_exporter";
    changelog = "https://github.com/superq/chrony_exporter/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ paepcke ];
    mainProgram = "chrony_exporter";
  };
})
