{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  ncurses,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "diskscan";
  version = "0.21";

  src = fetchFromGitHub {
    owner = "baruch";
    repo = "diskscan";
    rev = finalAttrs.version;
    sha256 = "sha256-2y1ncPg9OKxqImBN5O5kXrTsuwZ/Cg/8exS7lWyZY1c=";
  };

  patches = [
    # cmake-4 support:
    #   https://github.com/baruch/diskscan/pull/77
    (fetchpatch {
      hash = "sha256-05ctYPmGWTJRUc4aN35fvb0ITwIZlQdIweH7tSQ0RjA=";
      name = "cmake-4.patch";
      url = "https://github.com/baruch/diskscan/commit/6e342469dcab32be7a33109a4d394141d5c905b5.patch";
    })
  ];

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    ncurses
    zlib
  ];

  meta = {
    description = "Scan HDD/SSD for failed and near failed sectors";
    homepage = "https://github.com/baruch/diskscan";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ peterhoeg ];
    platforms = with lib.platforms; linux;
    mainProgram = "diskscan";
  };
})
