{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  cmake,
  darwin,
  docbook_xml_dtd_45,
  docbook_xsl,
  libxml2,
  libxslt,
  lua5_2_compat,
  pkg-config,
  rsync,
}:

let
  xnu = darwin.sourceRelease "xnu";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "lsyncd";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "lsyncd";
    repo = "lsyncd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QBmvS1HGF3VWS+5aLgDr9AmUfEsuSz+DTFIeql2XHH4=";
  };

  postPatch = ''
    substituteInPlace default-rsync.lua \
      --replace "/usr/bin/rsync" "${rsync}/bin/rsync"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    rsync
    lua5_2_compat
    asciidoc
    libxml2
    docbook_xml_dtd_45
    docbook_xsl
    libxslt
  ];

  # Special flags needed on Darwin:
  # https://github.com/lsyncd/lsyncd/blob/42413cabbedca429d55a5378f6e830f191f3cc86/INSTALL#L51
  cmakeFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    "-DWITH_INOTIFY=OFF"
    "-DWITH_FSEVENTS=ON"
    "-DXNU_DIR=${xnu}"
  ];

  dontUseCmakeBuildDir = true;

  meta = {
    description = "Utility that synchronizes local directories with remote targets";
    homepage = "https://github.com/lsyncd/lsyncd";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ bobvanderlinden ];
    platforms = lib.platforms.all;
    mainProgram = "lsyncd";
  };
})
