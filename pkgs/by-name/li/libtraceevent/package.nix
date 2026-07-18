{
  lib,
  stdenv,
  asciidoc,
  cunit,
  docbook_xml_dtd_45,
  docbook_xsl,
  fetchgit,
  gitUpdater,
  meson,
  ninja,
  pkg-config,
  xmlto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libtraceevent";
  version = "1.9";

  src = fetchgit {
    url = "https://git.kernel.org/pub/scm/libs/libtrace/libtraceevent.git";
    rev = "libtraceevent-${finalAttrs.version}";
    hash = "sha256-4KuF+UNMWxfxXYVlS0cBY5/p242UQ/NoRRVK+wmn04E=";
  };

  outputs = [
    "out"
    "dev"
    "devman"
    "doc"
  ];

  postPatch = ''
    chmod +x Documentation/install-docs.sh.in
    patchShebangs --build check-manpages.sh Documentation/install-docs.sh.in
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    asciidoc
    xmlto
    docbook_xml_dtd_45
    docbook_xsl
  ];

  doCheck = true;
  checkInputs = [ cunit ];

  ninjaFlags = [
    "all"
    "docs"
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "libtraceevent-";
    # No nicer place to find latest release.
    url = "https://git.kernel.org/pub/scm/libs/libtrace/libtraceevent.git";
  };

  meta = {
    description = "Linux kernel trace event library";
    homepage = "https://git.kernel.org/pub/scm/libs/libtrace/libtraceevent.git/";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ wentasah ];
    platforms = lib.platforms.linux;
  };
})
