{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "prometheus-speedtest-exporter";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "podocarp";
    repo = "speedtest_exporter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-n9eunZRssS13mTOeFeZ/PpfSj430DKf3ZRS10hY4Ps8=";
  };

  vendorHash = "sha256-HBg44D0CUc4HYCBwGrswnrqG5o5ltA6UT8L0oWetlIc=";
  __structuredAttrs = true;

  meta = {
    description = "Speedtest.net Exporter for the Prometheus monitoring system";
    homepage = "https://github.com/podocarp/speedtest_exporter";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ podocarp ];
    mainProgram = "speedtest_exporter";
  };
})
