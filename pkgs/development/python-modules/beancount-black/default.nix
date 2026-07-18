{
  lib,
  fetchFromGitHub,
  beancount-parser,
  buildPythonPackage,
  click,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "beancount-black";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "LaunchPlatform";
    repo = "beancount-black";
    tag = finalAttrs.version;
    hash = "sha256-vo11mlgDhyc8YFnULJ4AFrANWmGpAMNX5jJ6QaUNqk0=";
  };

  buildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    beancount-parser
    click
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "beancount_black" ];

  meta = {
    description = "Opinioned code formatter for Beancount";
    homepage = "https://github.com/LaunchPlatform/beancount-black/";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ ambroisie ];
    mainProgram = "bean-black";
  };
})
