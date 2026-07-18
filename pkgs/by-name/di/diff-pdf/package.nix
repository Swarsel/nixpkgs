{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  cairo,
  pkg-config,
  poppler,
  wxwidgets_3_2,
}:

stdenv.mkDerivation rec {
  pname = "diff-pdf";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "vslavik";
    repo = "diff-pdf";
    rev = "v${version}";
    sha256 = "sha256-Cx1gp7wazaXB/LcUTe7Pas8iLl4TU1Jyt/1AeTu6YEA=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    pkg-config
  ];

  buildInputs = [
    cairo
    poppler
    wxwidgets_3_2
  ];

  preConfigure = "./bootstrap";

  meta = {
    description = "Simple tool for visually comparing two PDF files";
    homepage = "https://vslavik.github.io/diff-pdf/";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "diff-pdf";
  };
}
