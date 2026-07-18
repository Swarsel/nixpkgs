{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pyaftership";
  version = "23.1.0";

  src = fetchFromGitHub {
    owner = "ludeeus";
    repo = "pyaftership";
    tag = version;
    hash = "sha256-njlDScmxIYWxB4EL9lOSGCXqZDzP999gI9EkpcZyFlE=";
  };

  postPatch = ''
    # Upstream is releasing with the help of a CI to PyPI, GitHub releases
    # are not in their focus
    substituteInPlace setup.py \
      --replace 'version="main",' 'version="${version}",'
  '';

  propagatedBuildInputs = [ aiohttp ];

  nativeCheckInputs = [
    aresponses
    pytest-asyncio
    pytestCheckHook
  ];

  format = "setuptools";
  pythonImportsCheck = [ "pyaftership" ];

  meta = {
    description = "Python wrapper package for the AfterShip API";
    homepage = "https://github.com/ludeeus/pyaftership";
    changelog = "https://github.com/ludeeus/pyaftership/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
}
