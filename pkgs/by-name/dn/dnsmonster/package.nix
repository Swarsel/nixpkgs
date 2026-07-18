{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGo125Module,
  libpcap,
}:

buildGo125Module (finalAttrs: {
  pname = "dnsmonster";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "FenkoHQ";
    repo = "dnsmonster";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Ae7SzImNHOOpaaVLFHdfLrwGhaHkvZBt+s/sRoHYwzk=";
  };

  buildInputs = [ libpcap ];
  vendorHash = "sha256-7rIBbaYr1dgC0ArcuwZelHKG5TLIQDV9JSBoYOcz+C0=";

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/mosajjal/dnsmonster/util.releaseVersion=${finalAttrs.version}"
  ];

  meta = {
    description = "Passive DNS Capture and Monitoring Toolkit";
    homepage = "https://github.com/FenkoHQ/dnsmonster";
    changelog = "https://github.com/FenkoHQ/dnsmonster/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "dnsmonster";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
