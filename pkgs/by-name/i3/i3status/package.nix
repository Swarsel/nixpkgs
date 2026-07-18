{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  asciidoc,
  docbook_xml_dtd_45,
  docbook_xsl,
  libconfuse,
  libnl,
  libpulseaudio,
  meson,
  ninja,
  perl,
  pkg-config,
  xmlto,
  yajl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "i3status";
  version = "2.15";

  src = fetchurl {
    url = "https://i3wm.org/i3status/i3status-${finalAttrs.version}.tar.xz";
    hash = "sha256-bGf1LK5PE533ZK0cxzZWK+D5d1B5G8IStT80wG6vIgU=";
  };

  nativeBuildInputs = [
    meson
    ninja
    perl
    pkg-config
    asciidoc
    xmlto
    docbook_xml_dtd_45
    docbook_xsl
  ];

  buildInputs = [
    libconfuse
    yajl
    alsa-lib
    libpulseaudio
    libnl
  ];

  separateDebugInfo = true;

  meta = {
    description = "Generates a status line for i3bar, dzen2, xmobar or lemonbar";
    homepage = "https://i3wm.org";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ stapelberg ];
    platforms = lib.platforms.all;
    mainProgram = "i3status";
  };

})
