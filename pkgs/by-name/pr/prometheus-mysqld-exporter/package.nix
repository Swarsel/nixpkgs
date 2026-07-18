{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "mysqld_exporter";
  version = "0.18.0";

  src = fetchFromGitHub {
    owner = "prometheus";
    repo = "mysqld_exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uHr9hVjnQx1DIr7ByaqgmR4YOvCYo49+b+Ikh+Vlh+o=";
  };

  vendorHash = "sha256-fM3CqyOEKYJOFkEwBE7/yIQEKUUIbBIbmHQp12/psas=";

  # skips tests with external dependencies, e.g. on mysqld
  checkFlags = [
    "-short"
  ];

  ldflags =
    let
      t = "github.com/prometheus/common/version";
    in
    [
      "-s"
      "-w"
      "-X ${t}.Version=${finalAttrs.version}"
      "-X ${t}.Revision=${finalAttrs.src.rev}"
      "-X ${t}.Branch=unknown"
      "-X ${t}.BuildUser=nix@nixpkgs"
      "-X ${t}.BuildDate=unknown"
    ];

  meta = {
    description = "Prometheus exporter for MySQL server metrics";
    homepage = "https://github.com/prometheus/mysqld_exporter";
    changelog = "https://github.com/prometheus/mysqld_exporter/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      benley
      globin
    ];

    mainProgram = "mysqld_exporter";
  };
})
