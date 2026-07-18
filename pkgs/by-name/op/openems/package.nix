{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  csxcad,
  fetchpatch,
  fparser,
  hdf5,
  hyp2mat,
  mpi,
  octave,
  qcsxcad,
  tinyxml,
  vtk,
  zlib,
  withHyp2mat ? true,
  withMPI ? false,
  withQcsxcad ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "openems";
  version = "0.0.36";

  src = fetchFromGitHub {
    owner = "thliebig";
    repo = "openEMS";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-wdH+Zw7G2ZigzBMX8p3GKdFVx/AhbTNL+P3w+YjI/dc=";
  };

  patches = [
    # ref. https://github.com/thliebig/openEMS/pull/183 merged upstream
    (fetchpatch {
      hash = "sha256-q/ax7MZHwqSKAjx22uyV13YO/TXZa4bwikoQyItMB7E=";
      name = "update-cmake-minimum-required.patch";
      url = "https://github.com/thliebig/openEMS/commit/0fa7ba3aebc8ee531077973cfa136ead8e887872.patch";
    })
    # ref. https://github.com/thliebig/openEMS/pull/184 merged upstream
    (fetchpatch {
      hash = "sha256-y3pvim/8XUKF5k7shj0D+8P6tdfSZ3E/gxTogbRtxdo=";
      name = "update-nf2ff-cmake-minimum-required.patch";
      url = "https://github.com/thliebig/openEMS/commit/e02e2a8414355482145240e4c2b2464d7a26dd9e.patch";
    })
    # boost 1.89 removed the boost_system stub library
    ./boost-1.89.patch
  ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    fparser
    tinyxml
    hdf5
    vtk
    boost
    zlib
    csxcad
    (octave.override { inherit hdf5; })
  ]
  ++ lib.optionals withQcsxcad [ qcsxcad ]
  ++ lib.optionals withMPI [ mpi ]
  ++ lib.optionals withHyp2mat [ hyp2mat ];

  cmakeFlags = lib.optionals withMPI [ "-DWITH_MPI=ON" ];

  postFixup = ''
    substituteInPlace $out/share/openEMS/matlab/setup.m \
      --replace /usr/lib ${hdf5}/lib \
      --replace /usr/include ${hdf5}/include

    ${octave}/bin/mkoctfile -L${hdf5}/lib -I${hdf5}/include \
      -lhdf5 $out/share/openEMS/matlab/h5readatt_octave.cc \
      -o $out/share/openEMS/matlab/h5readatt_octave.oct
  '';

  meta = {
    description = "Open Source Electromagnetic Field Solver";
    homepage = "https://wiki.openems.de/index.php/Main_Page.html";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ matthuszagh ];
    platforms = lib.platforms.linux;
  };
})
