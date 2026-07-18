{
  lib,
  fetchFromGitHub,
  buildGoModule,
  goatcounter,
  nixosTests,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "goatcounter";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "arp242";
    repo = "goatcounter";
    rev = "v${finalAttrs.version}";
    hash = "sha256-BVKz1vPYDOpaBdurR1wjg1Jo+qncqrIbZuDVmlFAO9I=";
  };

  vendorHash = "sha256-ICbtL6O1Kbig2WgbLCVSSe9MbIrYWmxYn4M2R5mwv/c=";
  # Derived from the upstream build scripts:
  #
  # `-trimpath` is used, which `allowGoReference` sets
  allowGoReference = true;

  # Flags set in the upstream build.
  ldflags = [
    "-s"
    "-w"
    "-X zgo.at/goatcounter/v2.Version=${finalAttrs.src.rev}"
  ];

  modRoot = ".";
  subPackages = [ "cmd/goatcounter" ];

  passthru.tests = {
    version = testers.testVersion {
      version = "v${finalAttrs.version}";
      command = "goatcounter version";
      package = goatcounter;
    };

    moduleTest = nixosTests.goatcounter;
  };

  meta = {
    description = "Easy web analytics. No tracking of personal data";

    longDescription = ''
      GoatCounter is an open source web analytics platform available as a hosted
      service (free for non-commercial use) or self-hosted app. It aims to offer easy
      to use and meaningful privacy-friendly web analytics as an alternative to
      Google Analytics or Matomo.
    '';

    homepage = "https://github.com/arp242/goatcounter";
    changelog = "https://github.com/arp242/goatcounter/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ tylerjl ];
    mainProgram = "goatcounter";
  };
})
