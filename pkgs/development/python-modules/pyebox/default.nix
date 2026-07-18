{
  lib,
  fetchFromGitHub,
  aiohttp,
  async-timeout,
  beautifulsoup4,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyebox";
  version = "1.1.4";

  src = fetchFromGitHub {
    owner = "titilambert";
    repo = "pyebox";
    tag = version;
    hash = "sha256-87u16rJmwdGiUz3DxThCsNXnz0tpH/9i26eyYwSqpDg=";
  };

  postPatch = ''
    substituteInPlace requirements.txt \
      --replace-fail "bs4" "beautifulsoup4"
  '';

  # Package has no tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    async-timeout
    beautifulsoup4
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyebox" ];

  meta = {
    description = "Get your EBox consumption (www.ebox.ca)";
    homepage = "https://github.com/titilambert/pyebox";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
