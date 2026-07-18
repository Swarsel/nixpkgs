{
  lib,
  stdenv,
  fetchFromGitHub,
  bicpl,
  cmake,
  coreutils,
  libminc,
  makeWrapper,
  minc_tools,
  perlPackages,
  zlib,
}:

stdenv.mkDerivation {
  pname = "conglomerate";
  version = "unstable-2023-01-19";

  src = fetchFromGitHub {
    owner = "BIC-MNI";
    repo = "conglomerate";
    rev = "6fb26084f2871a85044e2e4afc868982702b40ed";
    hash = "sha256-Inr4b2bxguzkcRQBURObsQQ0Rb3H/Zz6hEzNRd+IX3w=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "CMAKE_MINIMUM_REQUIRED(VERSION 3.1)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    makeWrapper
  ];

  buildInputs = [
    libminc
    zlib
    bicpl
  ];

  propagatedBuildInputs = [
    coreutils
    minc_tools
  ]
  ++ (with perlPackages; [
    perl
    GetoptTabular
    MNI-Perllib
  ]);

  cmakeFlags = [
    "-DLIBMINC_DIR=${libminc}/lib/cmake"
    "-DBICPL_DIR=${bicpl}/lib"
  ];

  postFixup = ''
    for p in $out/bin/*; do
      wrapProgram $p --prefix PERL5LIB : $PERL5LIB --set PATH "${
        lib.makeBinPath [
          coreutils
          minc_tools
        ]
      }";
    done
  '';

  meta = {
    description = "More command-line utilities for working with MINC files";
    homepage = "https://github.com/BIC-MNI/conglomerate";
    license = lib.licenses.hpndUc;
    maintainers = with lib.maintainers; [ bcdarwin ];
    platforms = lib.platforms.unix;
  };
}
