{
  lib,
  stdenv,
  cairo,
  cmake,
  fetchFromSourcehut,
  meson,
  ninja,
  pango,
  pkg-config,
  scdoc,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "proycon-wayout";
  version = "0.1.3";

  src = fetchFromSourcehut {
    owner = "~proycon";
    repo = "wayout";
    rev = finalAttrs.version;
    sha256 = "sha256-pxHz8y63xX9I425OG0jPvQVx4mAbTYHxVMMkfjZpURo=";
  };

  postPatch = ''
    substituteInPlace meson.build --replace "'werror=true'," "" # Build fails with -Werror, remove
  '';

  strictDeps = true;

  nativeBuildInputs = [
    scdoc
    ninja
    meson
    cmake
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    wayland-protocols
    wayland
    cairo
    pango
  ];

  postFixup = ''
    mv $out/bin/wayout $out/bin/proycon-wayout # Avoid conflict with shinyzenith/wayout
  '';

  depsBuildBuild = [ pkg-config ];

  meta = {
    description = "Takes text from standard input and outputs it to a desktop-widget on Wayland desktops";
    homepage = "https://git.sr.ht/~proycon/wayout";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ wentam ];
    platforms = lib.platforms.linux;
    mainProgram = "proycon-wayout";
  };
})
