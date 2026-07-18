{
  lib,
  stdenv,
  fetchFromGitHub,
  bobcat,
  icmake,
  yodl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "flexc++";
  version = "2.05.00";

  src = fetchFromGitHub {
    owner = "fbb-git";
    repo = "flexcpp";
    rev = finalAttrs.version;
    sha256 = "0s25d9jsfsqvm34rwf48cxwz23aq1zja3cqlzfz3z33p29wwazwz";
  };

  postPatch = ''
    substituteInPlace INSTALL.im --replace /usr $out
    patchShebangs .
  '';

  nativeBuildInputs = [
    icmake
    yodl
  ];

  buildInputs = [ bobcat ];

  buildPhase = ''
    ./build man
    ./build manual
    ./build program
  '';

  installPhase = ''
    ./build install x
  '';

  setSourceRoot = ''
    sourceRoot=$(echo */flexc++)
  '';

  meta = {
    description = "C++ tool for generating lexical scanners";

    longDescription = ''
      Flexc++ was designed after `flex'. Flexc++ offers a cleaner class design
      and requires simpler specification files than offered by flex's C++
      option.
    '';

    homepage = "https://fbb-git.github.io/flexcpp/";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux;
    mainProgram = "flexc++";
  };
})
