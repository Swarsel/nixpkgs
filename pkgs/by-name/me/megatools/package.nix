{
  lib,
  stdenv,
  asciidoc,
  curl,
  docbook2x,
  docbook_xml_dtd_45,
  fetchgit,
  glib,
  libxml2,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "megatools";
  version = "1.11.5";

  src = fetchgit {
    url = "https://xff.cz/git/megatools";
    rev = finalAttrs.version;
    hash = "sha256-XOGjdvMw8wfhBwyOBnQqiiJeOGvYXKMYxiJ6BZeEwDQ=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    asciidoc
    docbook_xml_dtd_45
    docbook2x
    libxml2
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    curl
    glib
  ];

  enableParallelBuilding = true;

  meta = {
    description = "Command line client for Mega.co.nz";
    homepage = "https://xff.cz/megatools/";
    changelog = "https://xff.cz/megatools/builds/NEWS";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      viric
      vji
    ];

    platforms = lib.platforms.unix;
  };
})
