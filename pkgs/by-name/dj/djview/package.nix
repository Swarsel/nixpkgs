{
  lib,
  stdenv,
  fetchurl,
  autoconf,
  automake,
  djvulibre,
  libsForQt5,
  libtiff,
  libtool,
  libxt,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "djview";
  version = "4.12.3";

  src = fetchurl {
    url = "mirror://sourceforge/djvu/djview-${finalAttrs.version}.tar.gz";
    hash = "sha256-F7+5cxq4Bw4BI1OB8I5XsSMf+19J6wMYc+v6GJza9H0=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkg-config
    libsForQt5.qttools
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    djvulibre
    libsForQt5.qtbase
    libxt
    libtiff
  ];

  configureFlags = [
    "--disable-silent-rules"
    "--disable-dependency-tracking"
    "--with-x"
    "--with-tiff"
    "--disable-nsdejavu" # 2023-11-14: modern browsers have dropped support for NPAPI
  ];

  preConfigure = ''
    NOCONFIGURE=1 ./autogen.sh
  '';

  postInstall =
    let
      Applications = "$out/Applications";
    in
    lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p ${Applications}
      cp -a src/djview.app -t ${Applications}

      mkdir -p $out/bin
      pushd $out/bin
      ln -sf ../Applications/djview.app/Contents/MacOS/djview
      popd
    '';

  meta = {
    description = "Portable DjVu viewer (Qt5)";

    longDescription = ''
      The portable DjVu viewer (Qt5) and browser (nsdejavu) plugin.

      Djview highlights:
        - entirely based on the public DjVulibre api.
        - entirely written in portable Qt5.
        - works natively under Unix/X11, MS Windows, and macOS X.
        - continuous scrolling of pages
        - side-by-side display of pages
        - ability to specify a url to the djview command
        - all plugin and cgi options available from the command line
        - all silly annotations implemented
        - display thumbnails as a grid
        - display outlines
        - page names supported (see djvused command set-page-title)
        - metadata dialog (see djvused command set-meta)
        - implemented as reusable Qt widgets

      nsdejavu: browser plugin for DjVu. It internally uses djview.
      Has CGI-style arguments to configure the view of document (see man).
    '';

    homepage = "https://djvu.sourceforge.net/djview4.html";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      Anton-Latukha
      bryango
    ];

    platforms = lib.platforms.unix;
    mainProgram = "djview";
  };
})
