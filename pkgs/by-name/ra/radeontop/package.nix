{
  lib,
  stdenv,
  fetchFromGitHub,
  gettext,
  libdrm,
  libpciaccess,
  libxcb,
  makeWrapper,
  ncurses,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "radeontop";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "clbr";
    repo = "radeontop";
    rev = "v${finalAttrs.version}";
    sha256 = "0kwqddidr45s1blp0h8r8h1dd1p50l516yb6mb4s6zsc827xzgg3";
  };

  nativeBuildInputs = [
    pkg-config
    gettext
    makeWrapper
  ];

  buildInputs = [
    ncurses
    libdrm
    libpciaccess
    libxcb
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    wrapProgram $out/bin/radeontop \
      --prefix LD_LIBRARY_PATH : $out/lib
  '';

  enableParallelBuilding = true;

  patchPhase = ''
    substituteInPlace getver.sh --replace ver=unknown ver=${finalAttrs.version}
    substituteInPlace Makefile --replace pkg-config "$PKG_CONFIG"
  '';

  meta = {
    description = "Top-like tool for viewing AMD Radeon GPU utilization";

    longDescription = ''
      View GPU utilization, both for the total activity percent and individual
      blocks. Supports R600 and later cards: even Southern Islands should work.
      Works with both the open drivers and AMD Catalyst. Total GPU utilization
      is also valid for OpenCL loads; the other blocks are only useful for GL
      loads.
    '';

    homepage = "https://github.com/clbr/radeontop";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    mainProgram = "radeontop";
  };
})
