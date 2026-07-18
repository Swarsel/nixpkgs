{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  SDL2_ttf,
  alsa-lib,
  cairo,
  cjson,
  cmake,
  cups,
  docbook-xsl-nons,
  faac,
  faad2,
  ffmpeg,
  fuse3,
  glib,
  gnome-remote-desktop,
  icu,
  libcbor,
  libfido2,
  libjpeg_turbo,
  libkrb5,
  libopus,
  libpulseaudio,
  libunwind,
  libusb1,
  libx11,
  libxcursor,
  libxdamage,
  libxdmcp,
  libxext,
  libxi,
  libxinerama,
  libxkbcommon,
  libxkbfile,
  libxrandr,
  libxrender,
  libxslt,
  libxtst,
  libxv,
  makeWrapper,
  nix-update-script,
  openh264,
  openssl,
  orc,
  pcre2,
  pcsclite,
  pkcs11helper,
  pkg-config,
  remmina,
  sdl3,
  sdl3-image,
  sdl3-ttf,
  systemd,
  uriparser,
  wayland,
  wayland-scanner,
  writableTmpDirAsHomeHook,
  zlib,
  buildServer ? true,
  nocaps ? false,
  # tries to compile and run generate_argument_docbook.c
  withManPages ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
  withSDL2 ? false,
  withUnfree ? false,
  withWaylandSupport ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "freerdp";
  version = "3.27.1";

  src = fetchFromGitHub {
    owner = "FreeRDP";
    repo = "FreeRDP";
    tag = finalAttrs.version;
    hash = "sha256-4U3QC1hka+qTQ0F7GqKPiMVwkkFeJvbjNtom5A7V/Sg=";
  };

  postPatch = ''
    # skip NIB file generation on darwin
    substituteInPlace "client/Mac/CMakeLists.txt" "client/Mac/cli/CMakeLists.txt" \
      --replace-fail "if(NOT IS_XCODE)" "if(FALSE)"

    substituteInPlace "libfreerdp/freerdp.pc.in" \
      --replace-fail "Requires:" "Requires: @WINPR_PKG_CONFIG_FILENAME@"

    substituteInPlace client/SDL/SDL2/dialogs/{sdl_input.cpp,sdl_select.cpp,sdl_widget.cpp,sdl_widget.hpp} \
      --replace-fail "<SDL_ttf.h>" "<SDL2/SDL_ttf.h>"
  ''
  + lib.optionalString (pcsclite != null) ''
    substituteInPlace "winpr/libwinpr/smartcard/smartcard_pcsc.c" \
      --replace-fail "libpcsclite.so" "${lib.getLib pcsclite}/lib/libpcsclite.so"
  ''
  + lib.optionalString nocaps ''
    substituteInPlace "libfreerdp/locale/keyboard_xkbfile.c" \
      --replace-fail "RDP_SCANCODE_CAPSLOCK" "RDP_SCANCODE_LCONTROL"
  '';

  nativeBuildInputs = [
    cmake
    libxslt
    docbook-xsl-nons
    pkg-config
    wayland-scanner
    writableTmpDirAsHomeHook
    makeWrapper
  ];

  buildInputs = [
    cairo
    cjson
    cups
    faad2
    ffmpeg
    glib
    icu
    libcbor
    libfido2
    libx11
    libxcursor
    libxdamage
    libxdmcp
    libxext
    libxi
    libxinerama
    libxrandr
    libxrender
    libxtst
    libxv
    libjpeg_turbo
    libkrb5
    libopus
    libpulseaudio
    libunwind
    libusb1
    libxkbcommon
    libxkbfile
    openh264
    openssl
    orc
    pcre2
    pcsclite
    pkcs11helper
    sdl3
    sdl3-ttf
    sdl3-image
    uriparser
    zlib
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    fuse3
    systemd
    wayland
    wayland-scanner
  ]
  ++ lib.optionals withSDL2 [
    SDL2
    SDL2_ttf
    SDL2_image
  ]
  ++ lib.optionals withUnfree [
    faac
  ];

  # https://github.com/FreeRDP/FreeRDP/issues/8526#issuecomment-1357134746
  cmakeFlags = [
    "-Wno-dev"
    (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
    (lib.cmakeFeature "DOCBOOKXSL_DIR" "${docbook-xsl-nons}/xml/xsl/docbook")
  ]
  ++ lib.mapAttrsToList lib.cmakeBool (
    {
      BUILD_TESTING = false; # false is recommended by upstream
      CHANNEL_RDPEWA = true;
      CHANNEL_RDPEWA_CLIENT = true;
      WITH_CAIRO = cairo != null;
      WITH_CUPS = cups != null;
      WITH_FAAC = withUnfree && faac != null;
      WITH_FAAD2 = faad2 != null;
      WITH_FUSE = stdenv.hostPlatform.isLinux && fuse3 != null;
      WITH_JPEG = libjpeg_turbo != null;
      WITH_KRB5 = libkrb5 != null;
      WITH_MANPAGES = withManPages;
      WITH_OPENH264 = openh264 != null;
      WITH_OPUS = libopus != null;
      WITH_OSS = false;
      WITH_PCSC = pcsclite != null;
      WITH_PULSE = libpulseaudio != null;
      WITH_SERVER = buildServer;
      WITH_VAAPI = false; # false is recommended by upstream
      WITH_WEBVIEW = false; # avoid introducing webkit2gtk-4.0
    }
    // lib.filterAttrs (name: value: value) {
      WITH_WAYLAND = withWaylandSupport;
      # Only select one
      WITH_X11 = !withWaylandSupport;
    }
  )
  ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    (lib.cmakeBool "SDL_USE_COMPILED_RESOURCES" false)
  ];

  env.NIX_CFLAGS_COMPILE = toString (
    lib.optionals stdenv.hostPlatform.isDarwin [
      "-include AudioToolbox/AudioToolbox.h"
    ]
    ++ lib.optionals stdenv.cc.isClang [
      "-Wno-error=incompatible-function-pointer-types"
    ]
  );

  postFixup = lib.optionalString (withWaylandSupport && withSDL2) ''
    wrapProgram $out/bin/sdl2-freerdp \
      --set SDL_VIDEODRIVER wayland
  '';

  passthru = {
    tests = {
      inherit gnome-remote-desktop remmina;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Remote Desktop Protocol Client";

    longDescription = ''
      FreeRDP is a client-side implementation of the Remote Desktop Protocol (RDP)
      following the Microsoft Open Specifications.
    '';

    homepage = "https://www.freerdp.com/";
    changelog = "https://github.com/FreeRDP/FreeRDP/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      cizra
      deimelias
    ];

    platforms = lib.platforms.unix;
  };
})
