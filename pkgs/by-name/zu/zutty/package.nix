{
  lib,
  stdenv,
  fetchgit,
  freetype,
  glew,
  libxmu,
  nixosTests,
  pkg-config,
  python3,
  ucs-fonts,
  wafHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "zutty";
  version = "0.16-unstable-2024-08-18";

  src = fetchgit {
    url = "https://git.hq.sig7.se/zutty.git";
    rev = "04b2ca3b3aaa070c41583247f8112c31b6003886"; # 20240818
    hash = "sha256-izUbn2B3RqIIOW9tuL7DFLqJdektCftxnpQssJMYxC8=";
  };

  postPatch =
    let
      fontpaths = [
        "/run/current-system/sw/share/X11/fonts" # available if fonts.fontDir.enable = true
        "${ucs-fonts}/share/fonts"
      ];
    in
    ''
      substituteInPlace src/options.h \
        --replace-fail /usr/share/fonts ${builtins.concatStringsSep ":" fontpaths}
    '';

  nativeBuildInputs = [
    pkg-config
    wafHook
    python3
  ];

  buildInputs = [
    freetype
    libxmu
    glew
  ];

  passthru = {
    tests = lib.optionalAttrs stdenv.hostPlatform.isLinux {
      default = nixosTests.terminal-emulators.zutty;
    };
  };

  meta = {
    description = "X terminal emulator rendering through OpenGL ES Compute Shaders";
    homepage = "https://tomscii.sig7.se/zutty/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.rolfschr ];
    platforms = lib.platforms.linux;
  };
})
