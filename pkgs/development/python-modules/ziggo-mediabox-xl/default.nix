{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ziggo-mediabox-xl";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "b10m";
    repo = "ziggo_mediabox_xl";
    tag = version;
    hash = "sha256-ElULsHfZXYTZ1cFEdAjhURWGOmJw2uJWMy49whGAV7g=";
  };

  # Tests require network access
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "ziggo_mediabox_xl" ];

  meta = {
    description = "Python interface to Ziggo's Mediabox XL";
    homepage = "https://github.com/b10m/ziggo_mediabox_xl";
    changelog = "https://github.com/b10m/ziggo_mediabox_xl/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
