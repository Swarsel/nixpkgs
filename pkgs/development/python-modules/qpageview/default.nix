{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pycups,
  pyqt6,
}:

buildPythonPackage rec {
  pname = "qpageview";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "frescobaldi";
    repo = "qpageview";
    tag = "v${version}";
    hash = "sha256-oXZr35ZD+cFEgRNojpiW14xceGC9taMNTFvXHmyyeFg=";
  };

  doCheck = false; # no tests
  build-system = [ hatchling ];

  dependencies = [
    pyqt6
    pycups
  ];

  pyproject = true;
  pythonImportsCheck = [ "qpageview" ];

  meta = {
    description = "Page-based viewer widget for Qt6/PyQt6";
    homepage = "https://github.com/frescobaldi/qpageview";
    changelog = "https://github.com/frescobaldi/qpageview/blob/${src.tag}/ChangeLog";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ camillemndn ];
  };
}
