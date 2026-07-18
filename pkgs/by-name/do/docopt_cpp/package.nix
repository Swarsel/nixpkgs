{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch2,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "docopt.cpp";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "docopt";
    repo = "docopt.cpp";
    rev = "v${finalAttrs.version}";
    sha256 = "0cz3vv7g5snfbsqcf3q8bmd6kv5qp84gj3avwkn4vl00krw13bl7";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-LXnN36/JuHsCeLnjuPFa42dT52iOcnJd4NGYx96Z5c0=";
      name = "python3-for-tests";
      url = "https://github.com/docopt/docopt.cpp/commit/b3d909dc952ab102a4ad5a1541a41736f35b92ba.patch?full_index=1";
    })
    (fetchpatch2 {
      hash = "sha256-bwKkhU3+GZFIUH0Ig0l9zcTtox9som3DY+ZApWrWl80=";
      name = "Increase-cmake_minimum_required-to-3.5";
      url = "https://github.com/docopt/docopt.cpp/commit/05d507da0d153faff381f44968833ebffdc03447.patch?full_index=1";
    })
  ];

  postPatch = ''
    substituteInPlace docopt.pc.in \
      --replace "@CMAKE_INSTALL_PREFIX@/@CMAKE_INSTALL_LIBDIR@" \
                "@CMAKE_INSTALL_LIBDIR@"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    python3
  ];

  cmakeFlags = [ "-DWITH_TESTS=ON" ];
  doCheck = true;
  checkPhase = "python ./run_tests";

  meta = {
    description = "C++11 port of docopt";
    homepage = "https://github.com/docopt/docopt.cpp";

    license = with lib.licenses; [
      mit
      boost
    ];

    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
