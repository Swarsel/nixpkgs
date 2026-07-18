{
  lib,
  fetchFromGitHub,
  aiofiles,
  aiohttp,
  buildPythonPackage,
  colorlog,
  commonregex,
  defusedxml,
  deprecated,
  ifaddr,
  platformdirs,
  pycryptodome,
  setuptools,
}:

buildPythonPackage rec {
  pname = "midea-local";
  version = "6.8.0";

  src = fetchFromGitHub {
    owner = "midea-lan";
    repo = "midea-local";
    tag = "v${version}";
    hash = "sha256-tJxSAjugFWvlpmLE7A7+wqsxM8RlgPQGE0fH7cdwxxI=";
  };

  build-system = [ setuptools ];

  dependencies = [
    aiofiles
    aiohttp
    colorlog
    commonregex
    defusedxml
    deprecated
    ifaddr
    pycryptodome
    platformdirs
  ];

  pyproject = true;

  meta = {
    description = "Control your Midea M-Smart appliances via local area network";
    homepage = "https://github.com/midea-lan/midea-local";
    changelog = "https://github.com/midea-lan/midea-local/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ k900 ];
  };
}
