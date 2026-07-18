{
  lib,
  fetchFromGitHub,
  argcomplete,
  buildPythonPackage,
  colorama,
  halo,
  platformdirs,
  pytestCheckHook,
  semver,
  setuptools,
  spinners,
  types-colorama,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "milc";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "clueboard";
    repo = "milc";
    tag = version;
    hash = "sha256-zy62VjtoNhl5hXywJO1p9rO19YAJeKOg+NkfCfgn1Xs=";
  };

  postPatch = ''
    # Needed for tests
    patchShebangs --build \
      example \
      custom_logger \
      questions \
      sparkline \
      hello \
      passwd_confirm \
      passwd_complexity \
      config_source
  '';

  nativeCheckInputs = [
    pytestCheckHook
    semver
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    argcomplete
    colorama
    halo
    platformdirs
    spinners
    types-colorama
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "milc" ];

  meta = {
    description = "Opinionated Batteries-Included Python 3 CLI Framework";
    homepage = "https://milc.clueboard.co";
    license = lib.licenses.mit;
    mainProgram = "milc-color";
  };
}
