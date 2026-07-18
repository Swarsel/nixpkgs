{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  boost179,
  cmake,
  gmp,
  htslib,
  pkg-config,
  xz,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "octopus";
  version = "0.7.4";

  src = fetchFromGitHub {
    owner = "luntergroup";
    repo = "octopus";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-FAogksVxUlzMlC0BqRu22Vchj6VX+8yNlHRLyb3g1sE=";
  };

  patches = [
    (fetchurl {
      sha256 = "sha256-VaUr63v7mzhh4VBghH7a7qrqOYwl6vucmmKzTi9yAjY=";
      url = "https://github.com/luntergroup/octopus/commit/17a597d192bcd5192689bf38c5836a98b824867a.patch";
    })
  ];

  postPatch = ''
    # Disable -Werror to avoid build failure on fresh toolchains like
    # gcc-13.
    substituteInPlace lib/date/CMakeLists.txt --replace-fail ' -Werror ' ' '
    substituteInPlace lib/ranger/CMakeLists.txt --replace-fail ' -Werror ' ' '
    substituteInPlace lib/tandem/CMakeLists.txt --replace-fail ' -Werror ' ' '
    substituteInPlace src/CMakeLists.txt --replace-fail ' -Werror ' ' '

    # Fix gcc-13 build due to missing <cstdint> header.
    sed -e '1i #include <cstdint>' -i src/core/tools/vargen/utils/assembler.hpp
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    boost179
    gmp
    htslib
    zlib
    xz
  ];

  postInstall = ''
    mkdir $out/bin
    mv $out/octopus $out/bin
  '';

  meta = {
    description = "Bayesian haplotype-based mutation calling";
    homepage = "https://github.com/luntergroup/octopus";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jbedo ];
    platforms = lib.platforms.x86_64;
    mainProgram = "octopus";
  };
})
