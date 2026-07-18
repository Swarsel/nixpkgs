{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gdk-pixbuf,
  glib,
  gtk3,
  librsvg,
  lightdm,
  lightdm-mini-greeter,
  linkFarm,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lightdm-mini-greeter";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "prikhi";
    repo = "lightdm-mini-greeter";
    rev = finalAttrs.version;
    sha256 = "sha256-Pm7ExfusFIPktX2C4UE07qgOVhcWhVxnaD3QARpmu7Y=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    lightdm
    gtk3
    glib
    gdk-pixbuf
    librsvg
  ];

  configureFlags = [ "--sysconfdir=/etc" ];
  makeFlags = [ "configdir=${placeholder "out"}/etc" ];

  postInstall = ''
    substituteInPlace "$out/share/xgreeters/lightdm-mini-greeter.desktop" \
      --replace "Exec=lightdm-mini-greeter" "Exec=$out/bin/lightdm-mini-greeter"
  '';

  passthru.xgreeters = linkFarm "lightdm-mini-greeter-xgreeters" [
    {
      name = "lightdm-mini-greeter.desktop";
      path = "${lightdm-mini-greeter}/share/xgreeters/lightdm-mini-greeter.desktop";
    }
  ];

  meta = {
    description = "Minimal, configurable, single-user GTK3 LightDM greeter";
    homepage = "https://github.com/prikhi/lightdm-mini-greeter";
    changelog = "https://github.com/prikhi/lightdm-mini-greeter/blob/master/CHANGELOG.md";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      mnacamura
      prikhi
    ];

    platforms = lib.platforms.linux;
    mainProgram = "lightdm-mini-greeter";
  };
})
