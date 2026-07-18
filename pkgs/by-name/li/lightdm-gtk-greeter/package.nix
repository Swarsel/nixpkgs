{
  lib,
  stdenv,
  fetchurl,
  at-spi2-core,
  gtk3,
  hicolor-icon-theme,
  intltool,
  librsvg,
  lightdm,
  lightdm-gtk-greeter,
  linkFarm,
  pkg-config,
  wrapGAppsHook3,
  xfce4-dev-tools,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lightdm-gtk-greeter";
  version = "2.0.9";

  src = fetchurl {
    # Release tarball differs from source tarball.
    url = "https://github.com/Xubuntu/lightdm-gtk-greeter/releases/download/lightdm-gtk-greeter-${finalAttrs.version}/lightdm-gtk-greeter-${finalAttrs.version}.tar.gz";
    hash = "sha256-yP3xmKqaP50NrQtI3+I8Ine3kQfo/PxillKQ8QgfZF0=";
  };

  postPatch = ''
    # https://github.com/Xubuntu/lightdm-gtk-greeter/pull/178
    cp data/badges/xfce{,-wayland}_badge-symbolic.svg
  '';

  nativeBuildInputs = [
    pkg-config
    intltool
    xfce4-dev-tools
    wrapGAppsHook3
  ];

  buildInputs = [
    lightdm
    librsvg
    hicolor-icon-theme
    gtk3
  ];

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--disable-indicator-services-command"
    "--sbindir=${placeholder "out"}/bin" # for wrapGAppsHook3 to wrap automatically
  ];

  preConfigure = ''
    configureFlagsArray+=( --enable-at-spi-command="${at-spi2-core}/libexec/at-spi-bus-launcher --launch-immediately" )
  '';

  postInstall = ''
    substituteInPlace "$out/share/xgreeters/lightdm-gtk-greeter.desktop" \
      --replace-fail "Exec=lightdm-gtk-greeter" "Exec=$out/bin/lightdm-gtk-greeter"
  '';

  installFlags = [
    "localstatedir=\${TMPDIR}"
    "sysconfdir=${placeholder "out"}/etc"
  ];

  passthru.xgreeters = linkFarm "lightdm-gtk-greeter-xgreeters" [
    {
      name = "lightdm-gtk-greeter.desktop";
      path = "${lightdm-gtk-greeter}/share/xgreeters/lightdm-gtk-greeter.desktop";
    }
  ];

  meta = {
    description = "GTK greeter for LightDM";
    homepage = "https://github.com/Xubuntu/lightdm-gtk-greeter";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ bobby285271 ];
    platforms = lib.platforms.linux;
    mainProgram = "lightdm-gtk-greeter";
  };
})
