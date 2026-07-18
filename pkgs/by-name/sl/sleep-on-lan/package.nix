{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "sleep-on-lan";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "SR-G";
    repo = "sleep-on-lan";
    rev = "${finalAttrs.version}-RELEASE";
    sha256 = "sha256-WooFGIdXIIoJPMqmPpnT+bc+P+IARMSxa3CvXY9++mw=";
  };

  vendorHash = "sha256-JqDDG53khtDdMLVOscwqi0oGviF+3DMkv5tkHvp1gJc=";

  ldflags = [
    "-s"
    "-w"
    "-X main.BuildVersion=${finalAttrs.version}"
    "-X main.BuildVersionLabel=nixpkgs"
  ];

  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    description = "Multi-platform process allowing to sleep on LAN a Linux or Windows computer, through wake-on-lan (reversed) magic packets or through HTTP REST requests";
    homepage = "https://github.com/SR-G/sleep-on-lan";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ devusb ];
    platforms = lib.platforms.linux;
    mainProgram = "sleep-on-lan";
  };
})
