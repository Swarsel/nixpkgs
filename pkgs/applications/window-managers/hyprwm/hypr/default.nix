{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  cmake,
  glib,
  gtkmm3,
  harfbuzz,
  libx11,
  libxcb,
  libxcb-cursor,
  libxcb-keysyms,
  libxcb-util,
  libxcb-wm,
  libxdmcp,
  makeWrapper,
  pcre2,
  pkg-config,
  xmodmap,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hypr";
  version = "unstable-2023-01-26";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "Hypr";
    rev = "af4641847b578b233a6f06806f575b3f320d74da";
    hash = "sha256-FUKR5nceEhm9GWa61hHO8+y4GBz7LYKXPB0OpQcQ674=";
  };

  patches = [
    ./000-dont-set-compiler.diff
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.4)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    cairo
    glib
    gtkmm3
    harfbuzz
    libx11
    libxdmcp
    libxcb
    pcre2
    libxcb-cursor
    libxcb-keysyms
    libxcb-wm
    libxcb-util
  ];

  # src/ewmh/ewmh.cpp:67:28: error: non-constant-expression cannot be narrowed from type 'int' to 'uint32_t' (aka 'unsigned int') in initializer list
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isDarwin "-Wno-c++11-narrowing";

  installPhase = ''
    runHook preInstall

    install -Dm755 Hypr -t $out/bin

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/Hypr --prefix PATH : ${lib.makeBinPath [ xmodmap ]}
  '';

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    inherit (libx11.meta) platforms;
    description = "Tiling X11 window manager written in modern C++";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "Hypr";
  };
})
