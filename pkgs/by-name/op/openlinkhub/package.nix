{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  pipewire,
  pkg-config,
  udev,
  usbutils,
}:

buildGoModule (finalAttrs: {
  pname = "openlinkhub";
  version = "0.8.9";

  src = fetchFromGitHub {
    owner = "jurkovic-nikola";
    repo = "OpenLinkHub";
    tag = finalAttrs.version;
    hash = "sha256-g8ZdiBaEelS+LhnOA23mMR+irN1wKD6Rp66sCnSD2tU=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    pipewire
    udev
    usbutils
  ];

  vendorHash = "sha256-/itomxsbTDT7ML52bpUfDZIBZ/Rh/zx4Blg+PP7m7gE=";
  env.CGO_CFLAGS_ALLOW = "-fno-strict-overflow";

  installPhase = ''
    runHook preInstall

    install -Dm 644 -t $out/etc/udev/rules.d 99-openlinkhub.rules
    install -Dm 755 -t $out/opt/OpenLinkHub $GOPATH/bin/OpenLinkHub

    cp -rt $out/opt/OpenLinkHub database static web

    mkdir -p $out/bin
    ln -st $out/bin $out/opt/OpenLinkHub/OpenLinkHub

    runHook postInstall
  '';

  proxyVendor = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open source interface for iCUE LINK Hub and other Corsair AIOs, Hubs for Linux";
    homepage = "https://github.com/jurkovic-nikola/OpenLinkHub";
    changelog = "https://github.com/jurkovic-nikola/OpenLinkHub/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      bot-wxt1221
      mikaeladev
    ];

    platforms = lib.platforms.linux;
    mainProgram = "OpenLinkHub";
  };
})
