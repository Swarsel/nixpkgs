{
  lib,
  fetchFromGitHub,
  buildGo126Module,
  makeWrapper,
  nix-update-script,
  symlinkJoin,
  v2ray-rules-dat,
  assets ? [
    v2ray-rules-dat
  ],
}:

buildGo126Module (finalAttrs: {
  pname = "xray";
  version = "26.3.27";

  src = fetchFromGitHub {
    owner = "XTLS";
    repo = "Xray-core";
    rev = "v${finalAttrs.version}";
    hash = "sha256-tSSoaIKHgLf9ry6p0Y+BM1Nx8X+40BDDfJJYkABUoEc=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-kwvck6Eo/e6qgb1ENznhwZ/GPX75ssLUvR2u8Qm3UIM=";
  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -Dm555 "$GOPATH"/bin/main $out/bin/xray
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/xray \
      --set-default V2RAY_LOCATION_ASSET $assetsDrv/share/v2ray \
      --set-default XRAY_LOCATION_ASSET $assetsDrv/share/v2ray
  '';

  assetsDrv = symlinkJoin {
    name = "v2ray-assets";
    paths = assets;
  };

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "main" ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Platform for building proxies to bypass network restrictions. A replacement for v2ray-core, with XTLS support and fully compatible configuration";
    homepage = "https://github.com/XTLS/Xray-core";
    license = with lib.licenses; [ mpl20 ];
    maintainers = with lib.maintainers; [ iopq ];
    mainProgram = "xray";
  };
})
