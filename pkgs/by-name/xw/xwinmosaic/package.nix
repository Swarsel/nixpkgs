{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  gtk2,
  libxdamage,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xwinmosaic";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "soulthreads";
    repo = "xwinmosaic";
    tag = "v${finalAttrs.version}";
    sha256 = "16qhrpgn84fz0q3nfvaz5sisc82zk6y7c0sbvbr69zfx5fwbs1rr";
  };

  patches = [
    # Pull upstream fix for -fno-common toolchains like upstream gcc-10:
    #  https://github.com/soulthreads/xwinmosaic/pull/33
    (fetchpatch {
      name = "fno-common.patch";
      sha256 = "0qpk802j5x6bsfvj6jqw1nz482jynwyk7yrrh4bsziwc53khm95q";
      url = "https://github.com/soulthreads/xwinmosaic/commit/a193a3f30850327066e5a93b29316cba2735e10d.patch";
    })
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required (VERSION 2.8)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [
    gtk2
    libxdamage
  ];

  meta = {
    description = "X window switcher drawing a colourful grid";
    homepage = "https://github.com/soulthreads/xwinmosaic";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.linux;
    mainProgram = "xwinmosaic";
  };
})
