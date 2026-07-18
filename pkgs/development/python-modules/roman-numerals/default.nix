{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "roman-numerals";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "AA-Turner";
    repo = "roman-numerals";
    tag = "v${finalAttrs.version}";
    hash = "sha256-v+aPIcsggjRJ3l6Xfw97b3zcqpyWNY4XWy2+5aWyitY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];
  pyproject = true;
  pythonImportsCheck = [ "roman_numerals" ];
  sourceRoot = "${finalAttrs.src.name}/python";

  meta = {
    description = "Manipulate roman numerals";
    homepage = "https://github.com/AA-Turner/roman-numerals/";
    changelog = "https://github.com/AA-Turner/roman-numerals/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.cc0;
    platforms = lib.platforms.all;
  };
})
