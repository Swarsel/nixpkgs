{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  gdk-pixbuf,
  libxkbcommon,
  meson,
  ninja,
  pam,
  pkg-config,
  scdoc,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "swaylock-effects";
  version = "1.7.0.0";

  src = fetchFromGitHub {
    owner = "jirutka";
    repo = "swaylock-effects";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cuFM+cbUmGfI1EZu7zOsQUj4rA4Uc4nUXcvIfttf9zE=";
  };

  postPatch = ''
    sed -i "s/version: '1\.3',/version: '${finalAttrs.version}',/" meson.build
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
    libxkbcommon
    cairo
    gdk-pixbuf
    pam
  ];

  mesonFlags = [
    "-Dpam=enabled"
    "-Dgdk-pixbuf=enabled"
    "-Dman-pages=enabled"
  ];

  depsBuildBuild = [ pkg-config ];

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Screen locker for Wayland";

    longDescription = ''
      Swaylock, with fancy effects
    '';

    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gnxlxnxx ];
    platforms = lib.platforms.linux;
    mainProgram = "swaylock";
  };
})
