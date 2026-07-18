{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
  requests,
  responses,
}:

buildPythonPackage rec {
  pname = "pywaterkotte";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "chboland";
    repo = "pywaterkotte";
    tag = "v${version}";
    hash = "sha256-zK0x6LyXPPNPA20Zq+S1B1q7ZWGxQmWf4JxEfjNkPQw=";
  };

  nativeBuildInputs = [ hatchling ];
  propagatedBuildInputs = [ requests ];

  nativeCheckInputs = [
    pytestCheckHook
    responses
  ];

  pyproject = true;
  pythonImportsCheck = [ "pywaterkotte" ];

  meta = {
    description = "Library to communicate with Waterkotte heatpumps";
    homepage = "https://github.com/chboland/pywaterkotte";
    changelog = "https://github.com/chboland/pywaterkotte/releases/tag/v${version}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
