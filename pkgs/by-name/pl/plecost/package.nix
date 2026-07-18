{
  lib,
  fetchFromGitHub,
  fetchpatch,
  python3Packages,
  unstableGitUpdater,
}:

python3Packages.buildPythonApplication {
  pname = "plecost";
  version = "0-unstable-2022-08-03";

  src = fetchFromGitHub {
    owner = "iniqua";
    repo = "plecost";
    # Release is untagged
    rev = "4895e345d71bffe956be43530632e303dd379a5f";
    hash = "sha256-cXXFLoiLZpo3qiAPztavns4EkOG2aC6UKMf0N4Eun/w=";
  };

  # Project has no tests
  doCheck = false;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    aiohttp
    async-timeout
    termcolor
    lxml
  ];

  pyproject = true;
  pythonImportsCheck = [ "plecost_lib" ];
  passthru.updateScript = unstableGitUpdater { hardcodeZeroVersion = true; };

  meta = {
    description = "Vulnerability fingerprinting and vulnerability finder for Wordpress blog engine";
    homepage = "https://github.com/iniqua/plecost";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ emilytrau ];
    mainProgram = "plecost";
  };
}
