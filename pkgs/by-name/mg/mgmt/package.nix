{
  lib,
  fetchFromGitHub,
  augeas,
  buildGoModule,
  gotools,
  libvirt,
  libxml2,
  nex,
  pkg-config,
  ragel,
}:
buildGoModule (finalAttrs: {
  pname = "mgmt";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "purpleidea";
    repo = "mgmt";
    tag = finalAttrs.version;
    hash = "sha256-jVFIVlytDvfTrAzWkX+pedAq/AcLrCDFtLPx0Wc+XjM=";
  };

  postPatch = ''
    rm -rf vendor
    patchShebangs misc/header.sh
  '';

  nativeBuildInputs = [
    gotools
    nex
    pkg-config
    ragel
  ];

  buildInputs = [
    augeas
    libvirt
    libxml2
  ];

  vendorHash = "sha256-mMRAlqySy6dpRG86p0BHSpYn2gzE8N4sZ3qHiyuttBA=";

  preBuild = ''
    make lang resources funcgen
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.program=${finalAttrs.pname}"
    "-X main.version=${finalAttrs.version}"
  ];

  proxyVendor = true;
  subPackages = [ "." ];

  meta = {
    description = "Next generation distributed, event-driven, parallel config management";
    homepage = "https://mgmtconfig.com";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      karpfediem
    ];

    platforms = lib.platforms.linux;
    mainProgram = "mgmt";
  };
})
