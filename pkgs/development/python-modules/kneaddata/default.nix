{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "kneaddata";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "biobakery";
    repo = "kneaddata";
    tag = version;
    hash = "sha256-biZ6lS0a81CBAAhTOb1Ol38/YagLqXA3AbMr2nBmSEw=";
  };

  nativeCheckInputs = [ unittestCheckHook ];
  dependencies = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "kneaddata" ];
  unittestFlagsArray = [ "kneaddata/tests/ '*.py'" ];

  meta = {
    description = "Quality control tool for metagenomic and metatranscriptomic sequencing data";
    homepage = "https://github.com/biobakery/kneaddata";
    changelog = "https://github.com/biobakery/kneaddata/releases";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pandapip1 ];
    platforms = lib.platforms.all;
    mainProgram = "kneaddata";
  };
}
