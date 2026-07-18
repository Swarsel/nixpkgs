{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  pytest-twisted,
  pytestCheckHook,
  scrapy,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "scrapy-splash";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "scrapy-plugins";
    repo = "scrapy-splash";
    tag = version;
    hash = "sha256-eOWqSCuuZtUtaEuAew4g0P67N0zClaguHn2u4ZMT3FU=";
  };

  nativeCheckInputs = [
    hypothesis
    pytest-twisted
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    scrapy
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "scrapy_splash" ];

  meta = {
    description = "Scrapy+Splash for JavaScript integration";
    homepage = "https://github.com/scrapy-plugins/scrapy-splash";
    changelog = "https://github.com/scrapy-plugins/scrapy-splash/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ evanjs ];
    # incompatible with scrapy >= 2.14
    # also deprecated by scrapy committers, see https://github.com/scrapy-plugins/scrapy-splash/issues/327
    broken = true;
  };
}
