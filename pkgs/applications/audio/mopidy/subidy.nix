{
  lib,
  fetchFromGitHub,
  mopidy,
  pythonPackages,
}:

pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "mopidy-subidy";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Prior99";
    repo = "mopidy-subidy";
    tag = finalAttrs.version;
    sha256 = "0c5ghhhrj5v3yp4zmll9ari6r5c6ha8c1izwqshvadn40b02q7xz";
  };

  nativeCheckInputs = [
    pythonPackages.pytestCheckHook
  ];

  build-system = [
    pythonPackages.setuptools
  ];

  dependencies = [
    mopidy
    pythonPackages.py-sonic
  ];

  pyproject = true;
  pythonImportsCheck = [ "mopidy_subidy" ];

  meta = {
    description = "Mopidy extension for playing music from a Subsonic-compatible Music Server";
    homepage = "https://www.mopidy.com/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ wenngle ];
  };
})
