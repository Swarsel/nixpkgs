{
  lib,
  fetchFromGitHub,
  aquamarine,
  cairo,
  cmake,
  expat,
  file,
  fribidi,
  gcc15Stdenv,
  hyprgraphics,
  hyprlang,
  hyprtoolkit,
  hyprutils,
  hyprwayland-scanner,
  hyprwire,
  libGL,
  libdatrie,
  libdrm,
  libjpeg,
  libjxl,
  libselinux,
  libsepol,
  libthai,
  libwebp,
  libxdmcp,
  pango,
  pcre2,
  pkg-config,
  util-linux,
  versionCheckHook,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

gcc15Stdenv.mkDerivation (finalAttrs: {
  pname = "hyprpaper";
  version = "0.8.4";

  src = fetchFromGitHub {
    owner = "hyprwm";
    repo = "hyprpaper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/4eWbt5XtOHzw3C9U0XPtoy8io03GxrEBd9znWMacbY=";
  };

  nativeBuildInputs = [
    cmake
    hyprwayland-scanner
    hyprwire
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    aquamarine
    cairo
    expat
    file
    fribidi
    hyprgraphics
    hyprlang
    hyprutils
    hyprtoolkit
    libGL
    libdatrie
    libdrm
    libjpeg
    libjxl
    libselinux
    libsepol
    libthai
    libwebp
    libxdmcp
    pango
    pcre2
    wayland
    wayland-protocols
    util-linux
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  cmakeBuildType = "RelWithDebInfo";

  prePatch = ''
    substituteInPlace src/main.cpp \
      --replace-fail GIT_COMMIT_HASH '"${finalAttrs.src.tag}"'
  '';

  separateDebugInfo = true;

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    inherit (wayland.meta) platforms;
    description = "Blazing fast wayland wallpaper utility";
    license = lib.licenses.bsd3;
    mainProgram = "hyprpaper";
    broken = gcc15Stdenv.hostPlatform.isDarwin;
    teams = [ lib.teams.hyprland ];
  };
})
