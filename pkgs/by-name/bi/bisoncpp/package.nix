{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitLab,
  bobcat,
  flexcpp,
  icmake,
  yodl,
}:
stdenv.mkDerivation rec {
  pname = "bisonc++";
  version = "6.04.00";

  src = fetchFromGitLab {
    owner = "fbb-git";
    repo = "bisoncpp";
    rev = "6.04.00";
    hash = "sha256:0aa9bij4g08ilsk6cgrbgi03vyhqr9fn6j2164sjin93m63212wl";
  };

  postPatch = ''
    substituteInPlace INSTALL.im --replace /usr $out
    patchShebangs .
    for file in $(find documentation -type f); do
      substituteInPlace "$file" --replace /usr/share/common-licenses/GPL ${gpl}
      substituteInPlace "$file" --replace /usr $out
    done
  '';

  nativeBuildInputs = [
    yodl
    icmake
    flexcpp
  ];

  buildInputs = [ bobcat ];

  buildPhase = ''
    ./build program
    ./build man
    ./build manual
  '';

  installPhase = ''
    ./build install x
  '';

  gpl = fetchurl {
    sha256 = "sha256:0hq6i0dm4420825fdm0lnnppbil6z67ls67n5kgjcd912dszjxw1";
    url = "https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt";
  };

  setSourceRoot = ''
    sourceRoot="$(echo */bisonc++)"
  '';

  meta = {
    description = "Parser generator like bison, but it generates C++ code";
    homepage = "https://fbb-git.gitlab.io/bisoncpp/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.linux;
    mainProgram = "bisonc++";
  };
}
