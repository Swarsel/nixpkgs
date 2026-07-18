{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  configobj,
  numpy,
  pandas,
  pyface,
  pytestCheckHook,
  setuptools,
  tables,
  traits,
  traitsui,
}:

buildPythonPackage rec {
  pname = "apptools";
  version = "5.3.1";

  src = fetchFromGitHub {
    owner = "enthought";
    repo = "apptools";
    tag = version;
    hash = "sha256-46QiVLWdlM89GMCIqVNuNGJjT2nwWJ1c6DyyvEPcceQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ] ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    export HOME=$TMP
  '';

  build-system = [ setuptools ];
  dependencies = [ traits ];

  optional-dependencies = {
    gui = [
      pyface
      traitsui
    ];

    h5 = [
      numpy
      pandas
      tables
    ];

    persistence = [ numpy ];
    preferences = [ configobj ];
  };

  pyproject = true;
  pythonImportsCheck = [ "apptools" ];

  meta = {
    description = "Set of packages that Enthought has found useful in creating a number of applications";
    homepage = "https://github.com/enthought/apptools";
    changelog = "https://github.com/enthought/apptools/releases/tag/${src.tag}";
    license = lib.licenses.bsdOriginal;
    maintainers = [ ];
  };
}
