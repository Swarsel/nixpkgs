{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  html5lib,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "microdata";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "edsu";
    repo = "microdata";
    rev = "v${finalAttrs.version}";
    hash = "sha256-BAygCLBLxZ033ZWRFSR52dSM2nPY8jXplDXQ8WW3KPo=";
  };

  propagatedBuildInputs = [ html5lib ];
  nativeCheckInputs = [ unittestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "microdata" ];

  meta = {
    description = "Library for extracting html microdata";
    homepage = "https://github.com/edsu/microdata";
    license = lib.licenses.cc0;
    maintainers = with lib.maintainers; [ ambroisie ];
    mainProgram = "microdata";
  };
})
