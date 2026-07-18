{
  lib,
  stdenv,
  fetchurl,
  gtk3,
  intltool,
  pkg-config,
  polkit,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "polkit-gnome";
  version = "0.105";

  src = fetchurl {
    url = "mirror://gnome/sources/polkit-gnome/${finalAttrs.version}/polkit-gnome-${finalAttrs.version}.tar.xz";
    hash = "sha256-F4RJSWO4v5oA7txs06KGj7EjuKXlFuZsXtpI3xerk2k=";
  };

  nativeBuildInputs = [
    pkg-config
    intltool
  ];

  buildInputs = [
    polkit
    gtk3
  ];

  configureFlags = [ "--disable-introspection" ];

  # Desktop file from Debian
  postInstall = ''
    mkdir -p $out/etc/xdg/autostart
    substituteAll ${./polkit-gnome-authentication-agent-1.desktop} $out/etc/xdg/autostart/polkit-gnome-authentication-agent-1.desktop
  '';

  meta = {
    description = "Dbus session bus service that is used to bring up authentication dialogs";
    homepage = "https://gitlab.gnome.org/Archive/policykit-gnome";
    changelog = "https://gitlab.gnome.org/Archive/policykit-gnome/-/blob/${finalAttrs.version}/NEWS?ref_type=tags";
    license = lib.licenses.lgpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
