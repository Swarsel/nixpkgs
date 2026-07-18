{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "grafana-image-renderer";
  version = "5.9.1";

  src = fetchFromGitHub {
    owner = "grafana";
    repo = "grafana-image-renderer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ODH5u7Q+CIJKZQEKz2QswgHm+ZVzmiRmw9GVR47iooI=";
  };

  postPatch = ''
    substituteInPlace go.mod --replace-fail 'go 1.26.4' 'go 1.26.3'
  '';

  vendorHash = "sha256-QiseTdsFOBg3aDYpdmLHfXL9eFll6iJo4wSKwXvdGnM=";
  subPackages = [ "." ];

  meta = {
    description = "Grafana backend plugin that handles rendering of panels & dashboards to PNGs using headless browser (Chromium/Chrome)";
    homepage = "https://github.com/grafana/grafana-image-renderer";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ma27 ];
    mainProgram = "grafana-image-renderer";
  };
})
