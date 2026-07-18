{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "vpk";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "ValvePython";
    repo = "vpk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SPkPb8kveAR2cN9kd2plS+TjmBYBCfa6pJ0c22l69M0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "vpk" ];

  meta = {
    description = "Library for working with Valve Pak files";
    homepage = "https://github.com/ValvePython/vpk";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "vpk";
  };
})
