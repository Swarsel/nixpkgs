{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  # testing
  dejavu_fonts,
  # dependencies
  fontconfig,
  freefont_ttf,
  makeFontsConf,
  python,
  setuptools,
}:

let
  fontsConf = makeFontsConf { fontDirectories = [ freefont_ttf ]; };
in
buildPythonPackage rec {
  pname = "python-fontconfig";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "lilydjwg";
    repo = "python-fontconfig";
    tag = "v${version}";
    hash = "sha256-4qxl5a9oKmhrF8O2OjA8X1wsHyEHL4ViRt20IcU/ANw=";
  };

  buildInputs = [ fontconfig ];

  preBuild = ''
    ${python.pythonOnBuildForHost.interpreter} setup.py build_ext -i
  '';

  nativeCheckInputs = [ dejavu_fonts ];

  preCheck = ''
    export FONTCONFIG_FILE=${fontsConf};
  '';

  checkPhase = ''
    runHook preCheck
    echo y | ${python.interpreter} test/test.py
    runHook postCheck
  '';

  build-system = [
    cython
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "fontconfig" ];

  meta = {
    description = "Python binding for Fontconfig";
    homepage = "https://github.com/Vayn/python-fontconfig";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
