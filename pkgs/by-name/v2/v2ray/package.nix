{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  nix-update-script,
  nixosTests,
  symlinkJoin,
  v2ray-domain-list-community,
  v2ray-geoip,
  assets ? [
    v2ray-geoip
    v2ray-domain-list-community
  ],
}:

buildGoModule (finalAttrs: {
  pname = "v2ray-core";
  version = "5.49.0";

  src = fetchFromGitHub {
    owner = "v2fly";
    repo = "v2ray-core";
    rev = "v${finalAttrs.version}";
    hash = "sha256-a1q/QJpXt3XJZwSteOf3+cQ2W7+KmMfknv1qaByg4Hc=";
  };

  nativeBuildInputs = [ makeWrapper ];
  # `nix-update` doesn't support `vendorHash` yet.
  # https://github.com/Mic92/nix-update/pull/95
  vendorHash = "sha256-A45fCy9Ytm/zVLQEn1QbUumBYZVG+jbmSFWkS/yAJn4=";

  installPhase = ''
    runHook preInstall
    install -Dm555 "$GOPATH"/bin/main $out/bin/v2ray
    install -Dm444 release/config/systemd/system/v2ray{,@}.service -t $out/lib/systemd/system
    install -Dm444 release/config/*.json -t $out/etc/v2ray
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/v2ray \
      --suffix XDG_DATA_DIRS : $assetsDrv/share
    substituteInPlace $out/lib/systemd/system/*.service \
      --replace User=nobody DynamicUser=yes \
      --replace /usr/local/bin/ $out/bin/ \
      --replace /usr/local/etc/ /etc/
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
    tests.simple-vmess-proxy-test = nixosTests.v2ray;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Platform for building proxies to bypass network restrictions";
    homepage = "https://www.v2fly.org/en_US/";
    license = with lib.licenses; [ mit ];

    maintainers = with lib.maintainers; [
      servalcatty
      ryan4yin
    ];

    mainProgram = "v2ray";
  };
})
