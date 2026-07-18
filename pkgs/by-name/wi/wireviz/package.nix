{
  lib,
  fetchPypi,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "wireviz";
  version = "0.4.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-DiWtjC46Jpp91Kf0Xk6NME234EMrGEOmIKz6a+cFcOE=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs = with python3.pkgs; [
    click
    graphviz
    pillow
    pyyaml
  ];

  pyproject = true;

  pythonImportsCheck = [
    "wireviz"
    "wireviz.wireviz"
    "wireviz.wv_cli"
  ];

  meta = {
    description = "Easily document cables and wiring harnesses";
    homepage = "https://pypi.org/project/wireviz/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ pinpox ];
    mainProgram = "wireviz";
  };
})
