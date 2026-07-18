{
  lib,
  fetchFromGitHub,
  aiohttp,
  async-timeout,
  buildPythonPackage,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "python-yate";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "eventphone";
    repo = "python-yate";
    tag = "v${version}";
    hash = "sha256-/tlDme4RmO9XH5PNTvK2yVzbF+iDNeCY21nArq6NU+g=";
  };

  propagatedBuildInputs = [
    aiohttp
    async-timeout
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "yate" ];

  meta = {
    description = "Python library for the yate telephony engine";
    homepage = "https://github.com/eventphone/python-yate";
    changelog = "https://github.com/eventphone/python-yate/releases/tag/${src.tag}";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ clerie ];
    mainProgram = "yate_callgen";
  };
}
