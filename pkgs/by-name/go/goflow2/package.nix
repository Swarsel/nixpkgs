{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
let
  version = "2.2.6";
in
buildGoModule {
  inherit version;
  pname = "goflow2";

  src = fetchFromGitHub {
    owner = "netsampler";
    repo = "goflow2";
    rev = "v${version}";
    hash = "sha256-PGXBsUDooYEq5RuLRwmTMOxYuXCxhfAo9Ef/75TWPc0=";
  };

  vendorHash = "sha256-fhZ74kSCYd/7P9A9rdQhe8ejNIsFGuSQVO84tIRN+QY=";

  ldflags = [
    "-s"
    "-w"
    "-X=main.version=${version}"
  ];

  meta = {
    description = "High performance sFlow/IPFIX/NetFlow Collector";
    homepage = "https://github.com/netsampler/goflow2";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ isabelroses ];
  };
}
