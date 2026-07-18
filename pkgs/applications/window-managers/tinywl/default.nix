{
  lib,
  stdenv,
  libxkbcommon,
  nixosTests,
  pixman,
  pkg-config,
  udev,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlroots,
}:

stdenv.mkDerivation {
  inherit (wlroots)
    version
    src
    patches
    postPatch
    ;

  pname = "tinywl";

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    libxkbcommon
    pixman
    udev
    wayland
    wayland-protocols
    wlroots
  ];

  makeFlags = [
    "-C"
    "tinywl"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp tinywl/tinywl $out/bin
    runHook postInstall
  '';

  passthru.tests = { inherit (nixosTests) tinywl; };

  meta = {
    inherit (wlroots.meta) platforms;
    description = ''A "minimum viable product" Wayland compositor based on wlroots'';
    homepage = "https://gitlab.freedesktop.org/wlroots/wlroots/tree/master/tinywl";
    license = lib.licenses.cc0;
    maintainers = with lib.maintainers; [ qyliss ] ++ wlroots.meta.maintainers;
    mainProgram = "tinywl";
  };
}
