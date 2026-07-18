{
  lib,
  argcomplete,
  buildPythonPackage,
  colorama,
  fetchPypi,
  jmespath,
  mock,
  pygments,
  pytest,
  pyyaml,
  six,
  tabulate,
  vcrpy,
}:

buildPythonPackage rec {
  pname = "knack";
  version = "0.14.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Ld0y/WND7Jtu0NpymyEjYtDmsSCMAWJjPJDLb5SgWHc=";
  };

  propagatedBuildInputs = [
    argcomplete
    colorama
    jmespath
    pygments
    pyyaml
    six
    tabulate
  ];

  nativeCheckInputs = [
    mock
    vcrpy
    pytest
  ];

  checkPhase = ''
    HOME=$TMPDIR pytest .
  '';

  format = "setuptools";
  pythonImportsCheck = [ "knack" ];

  meta = {
    description = "Command-Line Interface framework";
    homepage = "https://github.com/microsoft/knack";
    changelog = "https://github.com/microsoft/knack/blob/v${version}/HISTORY.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
