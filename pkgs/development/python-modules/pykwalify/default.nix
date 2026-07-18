{
  lib,
  buildPythonPackage,
  docopt,
  fetchPypi,
  fetchpatch,
  pytestCheckHook,
  python-dateutil,
  ruamel-yaml,
  testfixtures,
}:

buildPythonPackage rec {
  pname = "pykwalify";
  version = "1.8.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-eWsq0+1MuZuIMItTP7L1WcMPpu+0+p/aETR/SD0kWIQ=";
  };

  patches = [
    # fix test failures with ruamel.yaml 0.18+
    (fetchpatch {
      hash = "sha256-XUiebDzFSvNrPpRMoc2lv9m+30cfFh0N0rznMiSdQ/0=";
      name = "pykwalify-fix-tests-ruamel-yaml-0.18.patch";
      url = "https://github.com/Grokzen/pykwalify/commit/57bb2ba5c28b6928edb3f07ef581a5a807524baf.diff";
    })
  ];

  propagatedBuildInputs = [
    python-dateutil
    docopt
    ruamel-yaml
  ];

  nativeCheckInputs = [
    pytestCheckHook
    testfixtures
  ];

  format = "setuptools";
  pythonImportsCheck = [ "pykwalify" ];

  meta = {
    description = "YAML/JSON validation library";

    longDescription = ''
      This framework is a port with a lot of added functionality
      of the Java version of the framework kwalify that can be found at
      http://www.kuwata-lab.com/kwalify/

      The original source code can be found at
      http://sourceforge.net/projects/kwalify/files/kwalify-java/0.5.1/

      The source code of the latest release that has been used can be found at
      https://github.com/sunaku/kwalify.
      Please note that source code is not the original authors code
      but a fork/upload of the last release available in Ruby.

      The schema this library is based on and extended from:
      http://www.kuwata-lab.com/kwalify/ruby/users-guide.01.html#schema
    '';

    homepage = "https://github.com/Grokzen/pykwalify";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ siriobalmelli ];
    mainProgram = "pykwalify";
  };
}
