{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  runtimeShell,
  scdoc,
  systemdLibs,
  wayland,
  wayland-protocols,
  wayland-scanner,
  systemdSupport ? lib.meta.availableOn stdenv.hostPlatform systemdLibs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swayidle";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "swayidle";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fxDwRfAXb9D6epLlyWnXpy9g8V3ovJRpQ/f3M4jxY/s=";
  };

  postPatch = ''
    substituteInPlace main.c \
      --replace '"sh"' '"${runtimeShell}"'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
    wayland-scanner
  ];

  buildInputs = [
    wayland
    wayland-protocols
  ]
  ++ lib.optionals systemdSupport [ systemdLibs ];

  mesonFlags = [
    "-Dman-pages=enabled"
    "-Dlogind=${if systemdSupport then "enabled" else "disabled"}"
  ];

  depsBuildBuild = [ pkg-config ];

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Idle management daemon for Wayland";

    longDescription = ''
      Sway's idle management daemon. It is compatible with any Wayland
      compositor which implements the KDE idle protocol.
    '';

    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wineee ];
    platforms = lib.platforms.linux;
    mainProgram = "swayidle";
  };
})
