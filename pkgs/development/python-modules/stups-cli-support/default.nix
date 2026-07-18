{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  clickclick,
  dnspython,
  isPy3k,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "stups-cli-support";
  version = "1.1.22";

  src = fetchFromGitHub {
    owner = "zalando-stups";
    repo = "stups-cli-support";
    rev = version;
    sha256 = "sha256-/UsQzV1Ljd+K8AIj55UmiVXAshX+rUbYxFeSK7YGgn8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  preCheck = "export HOME=$TEMPDIR";
  build-system = [ setuptools ];

  dependencies = [
    clickclick
    dnspython
    requests
  ];

  disabled = !isPy3k;
  pyproject = true;

  meta = {
    description = "Helper library for all STUPS command line tools";
    homepage = "https://github.com/zalando-stups/stups-cli-support";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.mschuwalow ];
  };
}
