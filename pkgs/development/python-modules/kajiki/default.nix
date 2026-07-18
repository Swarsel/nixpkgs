{
  lib,
  fetchFromGitHub,
  babel,
  buildPythonPackage,
  hatchling,
  linetable,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "kajiki";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "jackrosenthal";
    repo = "kajiki";
    tag = "v${version}";
    hash = "sha256-bAgUMA9PlwsO7FRjwiKCsFffLWNU+Go1DToblmyWprk=";
  };

  propagatedBuildInputs = [ linetable ];

  nativeCheckInputs = [
    babel
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "kajiki" ];

  meta = {
    description = "Module provides fast well-formed XML templates";
    homepage = "https://github.com/nandoflorestan/kajiki";
    changelog = "https://github.com/jackrosenthal/kajiki/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ onny ];
    mainProgram = "kajiki";
  };
}
