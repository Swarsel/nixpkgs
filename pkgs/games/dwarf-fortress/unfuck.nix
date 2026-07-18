{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL,
  SDL_image,
  SDL_ttf,
  cmake,
  dfVersion,
  fetchpatch,
  glew,
  glib,
  gtk2,
  gtk3,
  libGL,
  libsm,
  libsndfile,
  ncurses,
  openal-soft,
  pkg-config,
  zlib,
}:

let
  inherit (lib)
    getAttr
    hasAttr
    licenses
    maintainers
    platforms
    versionOlder
    ;

  unfuck-releases = {
    "0.44.12" = {
      hash = "sha256-f9vDe3Q3Vl2hFLCPSzYtqyv9rLKBKEnARZTu0MKaX88=";
      unfuckRelease = "0.44.12";
    };

    "0.47.05" = {
      hash = "sha256-kBdzU6KDpODOBP9XHM7lQRIEWUGOj838vXF1FbSr0Xw=";
      unfuckRelease = "0.47.05-final";
    };
  };

  release =
    if hasAttr dfVersion unfuck-releases then
      getAttr dfVersion unfuck-releases
    else
      throw "[unfuck] Unknown Dwarf Fortress version: ${dfVersion}";
in

stdenv.mkDerivation {
  pname = "dwarf_fortress_unfuck";
  version = release.unfuckRelease;

  src = fetchFromGitHub {
    inherit (release) hash;
    owner = "svenstaro";
    repo = "dwarf_fortress_unfuck";
    rev = release.unfuckRelease;
  };

  patches = lib.optionals (versionOlder release.unfuckRelease "0.47.05") [
    (fetchpatch {
      hash = "sha256-b9eI3iR7dmFqCrktPyn6QJ9U2A/7LvfYRS+vE3BOaqk=";
      name = "fix-noreturn-returning.patch";
      url = "https://github.com/svenstaro/dwarf_fortress_unfuck/commit/6dcfe5ae869fddd51940c6c37a95f7bc639f4389.patch";
    })
    (fetchpatch {
      hash = "sha256-2VS/Mvhl6oLoMcH4x3hX9RO0VrHha8hhkdKwN0ZfUTs=";
      name = "use-the-glew-cmake-target.patch";
      url = "https://github.com/svenstaro/dwarf_fortress_unfuck/commit/abd2961836ace8cf6277ceff997b02704c6edd7a.patch";
    })
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.8)" "cmake_minimum_required(VERSION 3.10)"

    sed -i "1i #include <cstdint>" g_src/files.h
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libsm
    SDL
    SDL_image
    SDL_ttf
    glew
    openal-soft
    ncurses
    libsndfile
    zlib
    libGL
  ]
  # switched to gtk3 in 0.47.05
  ++ (
    if versionOlder release.unfuckRelease "0.47.05" then
      [
        gtk2
      ]
    else
      [
        gtk3
      ]
  );

  cmakeFlags = [
    "-DGTK2_GLIBCONFIG_INCLUDE_DIR=${glib.out}/lib/glib-2.0/include"
    "-DGTK2_GDKCONFIG_INCLUDE_DIR=${gtk2.out}/lib/gtk-2.0/include"
  ];

  installPhase = ''
    install -D -m755 ../build/libgraphics.so $out/lib/libgraphics.so
  '';

  # Don't strip unused symbols; dfhack hooks into some of them.
  dontStrip = true;
  # Breaks dfhack because of inlining.
  hardeningDisable = [ "fortify" ];
  passthru = { inherit dfVersion; };

  meta = {
    description = "Unfucked multimedia layer for Dwarf Fortress";
    homepage = "https://github.com/svenstaro/dwarf_fortress_unfuck";
    license = licenses.free;

    maintainers = with maintainers; [
      numinit
    ];

    platforms = platforms.linux;
  };
}
