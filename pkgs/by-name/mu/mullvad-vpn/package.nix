{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  atk,
  autoPatchelfHook,
  cairo,
  coreutils,
  cups,
  dbus,
  dpkg,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gnugrep,
  gtk3,
  iproute2,
  libGL,
  libappindicator,
  libgbm,
  libnotify,
  libx11,
  libxcb,
  libxcomposite,
  libxcursor,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxshmfence,
  libxtst,
  makeWrapper,
  nspr,
  nss,
  pango,
  systemd,
  versionCheckHook,
  wayland,
}:

let
  deps = [
    alsa-lib
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    pango
    gtk3
    libappindicator
    libnotify
    libgbm
    libx11
    libxscrnsaver
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxtst
    libxcb
    libxshmfence
    nspr
    nss
    systemd
  ];

  selectSystem =
    attrs:
    attrs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  platform = selectSystem {
    aarch64-linux = "arm64";
    x86_64-linux = "amd64";
  };

  hash = selectSystem {
    aarch64-linux = "sha256-pEzb21CSPn/ZflzZGTSJI5Hz3Q+ERFILg8q7V89AN1Q=";
    x86_64-linux = "sha256-OMbuc66AhwaIVgkiooUlttDazGLC5BCTiGPXA46TGso=";
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "mullvad-vpn";
  version = "2026.3";

  src = fetchurl {
    inherit hash;
    url = "https://github.com/mullvad/mullvadvpn-app/releases/download/${finalAttrs.version}/MullvadVPN-${finalAttrs.version}_${platform}.deb";
  };

  postPatch = ''
    patchShebangs opt/Mullvad\ VPN/mullvad-vpn
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
  ];

  buildInputs = deps;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mullvad $out/bin

    mv usr/share/* $out/share
    mv usr/bin/* $out/bin
    mv opt/Mullvad\ VPN/* $out/share/mullvad

    ln -s $out/share/mullvad/mullvad-{gui,vpn} $out/bin/
    ln -sf $out/share/mullvad/resources/mullvad-problem-report $out/bin/mullvad-problem-report

    wrapProgram $out/bin/mullvad-vpn \
      --set MULLVAD_DISABLE_UPDATE_NOTIFICATION 1 \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          gnugrep
        ]
      }

    wrapProgram $out/bin/mullvad-daemon \
        --set-default MULLVAD_RESOURCE_DIR "$out/share/mullvad/resources"

    wrapProgram $out/bin/mullvad-gui \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--enable-features=UseOzonePlatform --ozone-platform=wayland --enable-wayland-ime=true}}"

    sed -i "s|Exec.*$|Exec=$out/bin/mullvad-vpn $U|" $out/share/applications/mullvad-vpn.desktop

    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;
  dontBuild = true;
  dontConfigure = true;

  runtimeDependencies = [
    (lib.getLib systemd)
    iproute2
    libGL
    libnotify
    libappindicator
    wayland
  ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Client for Mullvad VPN";
    homepage = "https://github.com/mullvad/mullvadvpn-app";
    changelog = "https://github.com/mullvad/mullvadvpn-app/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      jackr
      airone01
      sigmasquadron
    ];

    platforms = lib.platforms.unix;
    badPlatforms = [ lib.systems.inspect.patterns.isDarwin ];
    mainProgram = "mullvad-vpn";
  };
})
