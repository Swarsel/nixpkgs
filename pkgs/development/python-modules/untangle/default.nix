{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  defusedxml,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "untangle";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "stchris";
    repo = "untangle";
    # 1.1.1 is not tagged on GitHub
    tag = version;
    hash = "sha256-cJkN8vT5hW5hRuLxr/6udwMO4GVH1pJhAc6qmPO2EEI=";
  };

  propagatedBuildInputs = [ defusedxml ];
  nativeCheckInputs = [ unittestCheckHook ];
  format = "setuptools";

  unittestFlagsArray = [
    "-s"
    "tests"
  ];

  meta = {
    description = "Convert XML documents into Python objects";
    homepage = "https://github.com/stchris/untangle";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
