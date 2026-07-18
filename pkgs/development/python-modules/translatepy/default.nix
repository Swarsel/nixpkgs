{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  inquirer,
  pytestCheckHook,
  pyuseragents,
  requests,
  safeio,
}:

buildPythonPackage (finalAttrs: {
  pname = "translatepy";
  version = "2.3";

  src = fetchFromGitHub {
    owner = "Animenosekai";
    repo = "translate";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cx5OeBrB8il8KrcyOmQbQ7VCXoaA5RP++oTTxCs/PcM=";
  };

  propagatedBuildInputs = [
    requests
    beautifulsoup4
    pyuseragents
    safeio
    inquirer
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  disabledTestPaths = [
    # Requires network connection
    "tests/test_translate.py"
    "tests/test_translators.py"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "translatepy" ];

  meta = {
    description = "Module grouping multiple translation APIs";
    homepage = "https://github.com/Animenosekai/translate";
    license = with lib.licenses; [ agpl3Only ];
    maintainers = with lib.maintainers; [ emilytrau ];
    mainProgram = "translatepy";
  };
})
