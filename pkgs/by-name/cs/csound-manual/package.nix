{
  lib,
  stdenv,
  fetchFromGitHub,
  docbook_xml_dtd_45,
  docbook_xsl,
  libxslt,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "csound-manual";
  version = "6.18.0";

  src = fetchFromGitHub {
    owner = "csound";
    repo = "manual";
    rev = finalAttrs.version;
    sha256 = "sha256-W8MghqUBr3V7LPgNwU6Ugw16wdK3G37zAPuasMlZ2+I=";
  };

  nativeBuildInputs = [
    libxslt.bin
    docbook_xsl
    python3
    python3.pkgs.pygments
  ];

  buildPhase = ''
    make XSL_BASE_PATH=${docbook_xsl}/share/xml/docbook-xsl html-dist
  '';

  installPhase = ''
    mkdir -p $out/share/doc/csound
    cp -r ./html $out/share/doc/csound
  '';

  prePatch = ''
    substituteInPlace manual.xml \
      --replace "http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd" \
                "${docbook_xml_dtd_45}/xml/dtd/docbook/docbookx.dtd"
  '';

  meta = {
    description = "Csound Canonical Reference Manual";
    homepage = "https://github.com/csound/manual";
    license = lib.licenses.fdl12Plus;
    maintainers = with lib.maintainers; [ hlolli ];
    platforms = lib.platforms.all;
  };
})
