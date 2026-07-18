{
  lib,
  stdenv,
  fetchFromSourcehut,
  fetchpatch,
  wayland,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "stacktile";
  version = "1.0.0";

  src = fetchFromSourcehut {
    owner = "~leon_plickat";
    repo = "stacktile";
    rev = "v${finalAttrs.version}";
    hash = "sha256-IOFxgYMjh92jx2CPfBRZDL/1ucgfHtUyAL5rS2EG+Gc=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    (fetchpatch {
      hash = "sha256-y5ArQyjIqT2ICmm8ZYDHZ04DwGgw2d7wsgoH5XJPZf0=";
      url = "https://aur.archlinux.org/cgit/aur.git/plain/fix-compilation.patch?h=stacktile&id=388a522b69e34c01cc5d57341d8578470a7dccfb";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    wayland-scanner
  ];

  buildInputs = [
    wayland
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "MANDIR=${placeholder "man"}/share/man"
  ];

  meta = {
    description = "Layout generator for the river Wayland compositor";
    homepage = "https://sr.ht/~leon_plickat/stacktile/";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "stacktile";
  };
})
