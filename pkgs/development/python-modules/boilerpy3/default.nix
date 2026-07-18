{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
}:

let
  pname = "boilerpy3";
  version = "1.0.7";
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "jmriebold";
    repo = "BoilerPy3";
    tag = "v${version}";
    hash = "sha256-dhAB0VbBGsSrgYGUlZEYaKA6sQB/f9Bb3alsRuQ8opo=";
  };

  postPatch = ''
    # the version mangling in mautrix_signal/get_version.py interacts badly with pythonRelaxDepsHook
    substituteInPlace setup.py \
      --replace '>=3.6.*' '>=3.6'
  '';

  format = "setuptools";
  pythonImportsCheck = [ "boilerpy3" ];

  meta = {
    description = "Python port of Boilerpipe library";
    homepage = "https://github.com/jmriebold/BoilerPy3";
    changelog = "https://github.com/jmriebold/BoilerPy3/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
