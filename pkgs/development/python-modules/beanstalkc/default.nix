{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "beanstalkc";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "bosondata";
    repo = "beanstalkc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-uvCdSIt5Owsvdn10TXuMGUHTU3Zi6VdntO6KW6MP67Y=";
  };

  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "beanstalkc" ];

  meta = {
    description = "Simple beanstalkd client library for Python";
    homepage = "https://github.com/bosondata/beanstalkc";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ aanderse ];
  };
})
