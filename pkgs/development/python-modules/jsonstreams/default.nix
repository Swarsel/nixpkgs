{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  six,
}:

buildPythonPackage rec {
  pname = "jsonstreams";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "dcbaker";
    repo = "jsonstreams";
    rev = version;
    sha256 = "0qw74wz9ngz9wiv89vmilbifsbvgs457yn1bxnzhrh7g4vs2wcav";
  };

  propagatedBuildInputs = [ six ];
  nativeCheckInputs = [ pytestCheckHook ];

  enabledTestPaths = [
    "tests"
    "jsonstreams"
  ];

  format = "setuptools";
  pytestFlags = [ "--doctest-modules" ];

  meta = {
    description = "JSON streaming writer";
    homepage = "https://github.com/dcbaker/jsonstreams";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ chkno ];
    broken = stdenv.hostPlatform.isDarwin;
  };
}
