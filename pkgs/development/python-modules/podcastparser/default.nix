{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "podcastparser";
  version = "0.6.11";

  src = fetchFromGitHub {
    owner = "gpodder";
    repo = "podcastparser";
    tag = version;
    hash = "sha256-eF/YHKSCMZnavkoX3LcAFHPSPABijn+aPVzaeRYY3WI=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "podcastparser" ];

  meta = {
    description = "Module to parse podcasts";
    homepage = "http://gpodder.org/podcastparser/";
    changelog = "https://github.com/gpodder/podcastparser/releases/tag/${src.tag}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ mic92 ];
  };
}
