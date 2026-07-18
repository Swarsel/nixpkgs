{
  lib,
  stdenv,
  fetchFromSourcehut,
  fuse3,
  libarchive,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "archivemount";
  version = "1b";

  src = fetchFromSourcehut {
    owner = "~nabijaczleweli";
    repo = "archivemount-ng";
    rev = finalAttrs.version;
    hash = "sha256-QQeVr3kPLVX543PwM2jtMnVQgkEfiQd09hG9VQvqLng=";
  };

  # Fix cross-compilation
  postPatch = ''
    substituteInPlace Makefile --replace-fail pkg-config "$PKG_CONFIG"
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    fuse3
    libarchive
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "VERSION=${finalAttrs.version}"
  ];

  dontConfigure = true;

  meta = {
    description = "Gateway between FUSE and libarchive: allows mounting of cpio, .tar.gz, .tar.bz2 archives";
    homepage = "https://git.sr.ht/~nabijaczleweli/archivemount-ng";
    changelog = "https://git.sr.ht/~nabijaczleweli/archivemount-ng/refs/${finalAttrs.version}";

    license = [
      lib.licenses.lgpl2Plus
      lib.licenses.bsd0
    ];

    platforms = lib.platforms.unix;
    mainProgram = "archivemount";
  };
})
