{
  lib,
  stdenv,
  fetchurl,
  dbus,
  docbook-xsl-nons,
  docbook_xml_dtd_43,
  glib,
  libxslt,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xdg-dbus-proxy";
  version = "0.1.7";

  src = fetchurl {
    url = "https://github.com/flatpak/xdg-dbus-proxy/releases/download/${finalAttrs.version}/xdg-dbus-proxy-${finalAttrs.version}.tar.xz";
    hash = "sha256-OtPSe6V04XisteTUOLo2rOJeNWT4mcNvMcVvgsetu+c=";
  };

  nativeBuildInputs = [
    docbook-xsl-nons
    docbook_xml_dtd_43
    libxslt
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    glib
  ];

  # dbus[2345]: Failed to start message bus: Failed to open "/etc/dbus-1/session.conf": No such file or directory
  doCheck = false;

  nativeCheckInputs = [
    dbus
  ];

  meta = {
    description = "DBus proxy for Flatpak and others";
    homepage = "https://github.com/flatpak/xdg-dbus-proxy";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ jtojnar ];
    platforms = lib.platforms.linux;
    mainProgram = "xdg-dbus-proxy";
  };
})
