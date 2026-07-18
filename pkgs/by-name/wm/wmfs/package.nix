{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  imlib2,
  libx11,
  libxft,
  libxinerama,
  libxpm,
  libxrandr,
}:
stdenv.mkDerivation {
  pname = "wmfs";
  version = "201902";

  src = fetchFromGitHub {
    owner = "xorg62";
    repo = "wmfs";
    rev = "b7b8ff812d28c79cb22a73db2739989996fdc6c2";
    sha256 = "1m7dsmmlhq2qipim659cp9aqlriz1cwrrgspl8baa5pncln0gd5c";
  };

  patches = [
    # Pull patch pending upstream inclusion to fix build on
    # -fno-common toolchain like upstream gcc-10:
    #  https://github.com/xorg62/wmfs/pull/104
    (fetchpatch {
      name = "fno-common.patch";
      sha256 = "0qvwry9sikvr85anzha9x4gcx0r2ckwdxqw2in2l6bl9z9d9c0w2";
      url = "https://github.com/xorg62/wmfs/commit/e4ec12618f4689d791892ebb49df9610a25d24d3.patch";
    })
  ];

  buildInputs = [
    imlib2
    libx11
    libxinerama
    libxrandr
    libxpm
    libxft
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "XDG_CONFIG_DIR=${placeholder "out"}/etc/xdg"
    "MANPREFIX=${placeholder "out"}/share/man"
  ];

  preConfigure = "substituteInPlace configure --replace '-lxft' '-lXft'";

  meta = {
    description = "Window manager from scratch";
    homepage = "https://github.com/xorg62/wmfs";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.balsoft ];
    platforms = lib.platforms.linux;
    mainProgram = "wmfs";
  };
}
