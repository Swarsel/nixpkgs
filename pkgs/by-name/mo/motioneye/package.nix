{
  lib,
  fetchFromGitHub,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication rec {
  pname = "motioneye";
  version = "0.44.0";

  src = fetchFromGitHub {
    owner = "motioneye-project";
    repo = "motioneye";
    tag = version;
    hash = "sha256-4sXttSSkmMgsoZb7PXEXXh8KNORTSmqq4lYp3JBDmPo=";
  };

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
  ];

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    babel
    boto3
    jinja2
    pillow
    pycurl
    tornado
    argon2-cffi
  ];

  pyproject = true;

  pythonImportsCheck = [
    "motioneye"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/meyectl";
  versionCheckProgramArg = "-v";

  meta = {
    description = "Web frontend for the motion daemon";
    homepage = "https://github.com/motioneye-project/motioneye";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ marcel ];
  };
}
