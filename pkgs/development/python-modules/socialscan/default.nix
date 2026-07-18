{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  colorama,
  setuptools,
  tqdm,
}:

buildPythonPackage (finalAttrs: {
  pname = "socialscan";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "iojw";
    repo = "socialscan";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4JJVhB6x1NGagtfzE03Jae2GOr25hh+4l7gQ23zc7Ck=";
  };

  # Tests require network access
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    colorama
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "socialscan" ];

  meta = {
    description = "Python library and CLI for accurately querying username and email usage on online platforms";
    homepage = "https://github.com/iojw/socialscan";
    changelog = "https://github.com/iojw/socialscan/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [ mpl20 ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "socialscan";
  };
})
