{
  lib,
  fetchFromGitHub,
  docutils,
  libelfin,
  makeWrapper,
  ncurses,
  pkg-config,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "coz";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "plasma-umass";
    repo = "coz";
    tag = version;
    hash = "sha256-tvFXInxjodB0jEgEKgnOGapiVPomBG1hvrhYtG2X5jI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    ncurses
    docutils
  ];

  buildInputs = [
    ncurses
    libelfin
  ];

  makeFlags = [ "prefix=${placeholder "out"}" ];

  # fix executable includes
  postInstall = ''
    chmod -x $out/include/coz.h
  '';

  dependencies = [ python3Packages.docutils ];
  pyproject = false; # Built with make

  meta = {
    description = "Profiler based on casual profiling";
    homepage = "https://github.com/plasma-umass/coz";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      zimbatm
      aleksana
    ];

    mainProgram = "coz";
  };
}
