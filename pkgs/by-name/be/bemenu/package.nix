{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  fribidi,
  harfbuzz,
  libpthread-stubs,
  libx11,
  libxcb,
  libxdmcp,
  libxft,
  libxinerama,
  libxkbcommon,
  makeWrapper,
  ncurses,
  pango,
  pkg-config,
  scdoc,
  wayland,
  wayland-protocols,
  wayland-scanner,
  ncursesSupport ? true,
  waylandSupport ? stdenv.hostPlatform.isLinux,
  x11Support ? stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bemenu";
  version = "0.6.23";

  src = fetchFromGitHub {
    owner = "Cloudef";
    repo = "bemenu";
    rev = finalAttrs.version;
    hash = "sha256-0vpqJ2jydTt6aVni0ma0g+80PFz+C4xJ5M77sMODkSg=";
  };

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace GNUmakefile --replace '-soname' '-install_name'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    scdoc
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin makeWrapper
  ++ lib.optional waylandSupport wayland-scanner;

  buildInputs = [
    cairo
    fribidi
    harfbuzz
    libxkbcommon
    pango
  ]
  ++ lib.optional ncursesSupport ncurses
  ++ lib.optionals waylandSupport [
    wayland
    wayland-protocols
  ]
  ++ lib.optionals x11Support [
    libx11
    libxinerama
    libxft
    libxdmcp
    libpthread-stubs
    libxcb
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  buildFlags = [
    "clients"
  ]
  ++ lib.optional ncursesSupport "curses"
  ++ lib.optional waylandSupport "wayland"
  ++ lib.optional x11Support "x11";

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    so="$(find "$out/lib" -name "libbemenu.so.[0-9]" -print -quit)"
    for f in "$out/bin/"*; do
        install_name_tool -change "$(basename $so)" "$so" $f
        wrapProgram $f --set BEMENU_BACKEND curses
    done
  '';

  meta = {
    description = "Dynamic menu library and client program inspired by dmenu";
    homepage = "https://github.com/Cloudef/bemenu";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ crertel ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "bemenu";
  };
})
