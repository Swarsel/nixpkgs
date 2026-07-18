{
  lib,
  fetchFromGitHub,
  ant,
  buildPythonPackage,
  openjdk,
  packaging,
  pyinstaller,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "jpype1";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "originell";
    repo = "jpype";
    tag = "v${version}";
    hash = "sha256-CDiVQugxLgmUwAG0e0ryamWvrjUaJxJrU0YSFIIWS1I=";
  };

  nativeBuildInputs = [
    ant
    openjdk
  ];

  preBuild = ''
    ant -f native/build.xml jar
  '';

  # Cannot find various classes. If you want to fix this
  # take a look at the opensuse packaging:
  # https://build.opensuse.org/projects/openSUSE:Factory/packages/python-JPype1/files/python-JPype1.spec?expand=1
  doCheck = false;

  nativeCheckInputs = [
    pyinstaller
    pytestCheckHook
  ];

  preCheck = ''
    ant -f test/build.xml compile
  '';

  build-system = [ setuptools ];
  dependencies = [ packaging ];
  pyproject = true;

  pythonImportsCheck = [
    "jpype"
    "jpype.imports"
    "jpype.types"
  ];

  meta = {
    description = "Python to Java bridge";
    homepage = "https://github.com/originell/jpype/";
    license = lib.licenses.asl20;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];
  };
}
