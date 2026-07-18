{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  cmake,
  doctest,
  libGL,
  libdrm,
  libevdev,
  libexecinfo,
  libinput,
  libjpeg,
  libxcb-wm,
  libxkbcommon,
  libxml2,
  meson,
  ninja,
  nixosTests,
  pango,
  pkg-config,
  vulkan-headers,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wf-config,
  wlroots_0_19,
  yyjson,
}:
let
  wlroots = wlroots_0_19;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "wayfire";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "WayfireWM";
    repo = "wayfire";
    rev = "v${finalAttrs.version}";
    hash = "sha256-yiqtnsXxvC7vk22ZQ5OFt5uX40FCRGWpfZrax9GItAg=";
    fetchSubmodules = true;
  };

  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    substituteInPlace plugins/common/wayfire/plugins/common/cairo-util.hpp \
      --replace "<drm_fourcc.h>" "<libdrm/drm_fourcc.h>"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    libGL
    libdrm
    libexecinfo
    libevdev
    libinput
    libjpeg
    libxkbcommon
    libxml2
    vulkan-headers
    wayland-protocols
    libxcb-wm
    yyjson
  ];

  propagatedBuildInputs = [
    wf-config
    wlroots
    wayland
    cairo
    pango
  ];

  mesonFlags = [
    "--sysconfdir /etc"
    "-Duse_system_wlroots=enabled"
    "-Duse_system_wfconfig=enabled"
    (lib.mesonEnable "wf-touch:tests" (stdenv.buildPlatform.canExecute stdenv.hostPlatform))
  ];

  doCheck = true;

  nativeCheckInputs = [
    cmake
    doctest
  ];

  # CMake is just used for finding doctest.
  dontUseCmakeConfigure = true;
  passthru.providedSessions = [ "wayfire" ];
  passthru.tests.mate = nixosTests.mate-wayland;

  meta = {
    description = "3D Wayland compositor";
    homepage = "https://wayfire.org/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      teatwig
      wucke13
      wineee
    ];

    platforms = lib.platforms.unix;
    mainProgram = "wayfire";
  };
})
