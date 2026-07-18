{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoctor,
  botan3,
  bzip2,
  cmake,
  gnupg,
  gtest,
  json_c,
  pkg-config,
  python3,
  sexpp,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rnp";
  version = "0.18.1";

  src = fetchFromGitHub {
    owner = "rnpgp";
    repo = "rnp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-GEgogKPMqBYYufCcjbaCmlNWtV/hxx3ZMfij+HAoHx8=";
  };

  # NOTE: check-only inputs should ideally be moved to nativeCheckInputs, but it
  # would fail during buildPhase.
  # nativeCheckInputs = [ gtest python3 ];
  outputs = [
    "out"
    "lib"
    "dev"
  ];

  patches = [
    # tracked at https://github.com/rnpgp/rnp/pull/2381
    ./0001-fix-build-with-Botan-3.11.patch
  ];

  nativeBuildInputs = [
    asciidoctor
    cmake
    gnupg
    gtest
    pkg-config
    python3
  ];

  buildInputs = [
    zlib
    bzip2
    json_c
    botan3
    sexpp
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DBUILD_SHARED_LIBS=on"
    "-DBUILD_TESTING=on"
    "-DDOWNLOAD_GTEST=off"
    "-DDOWNLOAD_RUBYRNP=off"
    "-DSYSTEM_LIBSEXPP=on"
  ];

  preConfigure = ''
    echo "v${finalAttrs.version}" > version.txt
  '';

  meta = {
    description = "High performance C++ OpenPGP library, fully compliant to RFC 4880";
    homepage = "https://github.com/rnpgp/rnp";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ ribose-jeffreylau ];
    platforms = lib.platforms.all;
  };
})
