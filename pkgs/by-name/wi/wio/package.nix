{
  lib,
  stdenv,
  fetchFromGitLab,
  alacritty,
  cage,
  cairo,
  libgbm,
  libxkbcommon,
  makeWrapper,
  meson,
  ninja,
  pkg-config,
  udev,
  unstableGitUpdater,
  wayland,
  wayland-protocols,
  wayland-scanner,
  wlroots_0_19,
  xwayland,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wio";
  version = "0.19.0";

  src = fetchFromGitLab {
    owner = "Rubo";
    repo = "wio";
    rev = finalAttrs.version;
    hash = "sha256-Ol9/dMYg1L+3jGFMpKsAPUAA7hkxu/v88JrI3v+ozAM=";
  };

  strictDeps = false; # why is it so hard?

  nativeBuildInputs = [
    makeWrapper
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    cairo
    libxkbcommon
    libgbm
    udev
    wayland
    wayland-protocols
    wlroots_0_19
    xwayland
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=maybe-uninitialized";

  postInstall = ''
    wrapProgram $out/bin/wio \
      --prefix PATH ":" "${
        lib.makeBinPath [
          alacritty
          cage
        ]
      }"
  '';

  passthru = {
    providedSessions = [ "wio" ];
    updateScript = unstableGitUpdater { };
  };

  meta = {
    inherit (wayland.meta) platforms;
    description = "Wayland compositor similar to Plan 9's rio";

    longDescription = ''
      Wio is a Wayland compositor for Linux and FreeBSD which has a similar look
      and feel to plan9's rio.
    '';

    homepage = "https://github.com/Rubo3/wio";
    license = with lib.licenses; [ bsd3 ];
    maintainers = [ ];
    mainProgram = "wio";
  };
})
