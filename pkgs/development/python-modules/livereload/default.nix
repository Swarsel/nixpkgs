{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  pytestCheckHook,
  six,
  tornado,
}:

buildPythonPackage rec {
  pname = "livereload";
  version = "2.7.1";

  src = fetchFromGitHub {
    owner = "lepture";
    repo = "python-livereload";
    tag = "v${version}";
    sha256 = "sha256-WFpPCUjvyGT826EkIuqAB4jcJOEqoohJY9Xw/EJrk6c=";
  };

  buildInputs = [ django ];

  propagatedBuildInputs = [
    tornado
    six
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  disabledTests = [ "test_watch_multiple_dirs" ];
  format = "setuptools";

  meta = {
    description = "Runs a local server that reloads as you develop";
    homepage = "https://github.com/lepture/python-livereload";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "livereload";
  };
}
