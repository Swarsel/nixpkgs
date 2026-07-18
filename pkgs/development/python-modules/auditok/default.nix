{
  lib,
  buildPythonPackage,
  fetchPypi,
  matplotlib,
  numpy,
  pyaudio,
  pydub,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "auditok";
  version = "0.1.5";

  src = fetchPypi {
    inherit version;
    hash = "sha256-HNsw9VLP7XEgs8E2X6p7ygDM47AwWxMYjptipknFig4=";
    pname = "auditok";
  };

  propagatedBuildInputs = [
    matplotlib
    numpy
    pyaudio
    pydub
  ];

  nativeCheckInputs = [ unittestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "auditok" ];

  unittestFlagsArray = [
    "-s"
    "tests"
  ];

  # The most recent version is 0.2.0, but the only dependent package is
  # ffsubsync, which is pinned at 0.1.5.
  passthru.skipBulkUpdate = true;

  meta = {
    description = "Audio Activity Detection tool that can process online data as well as audio files";
    homepage = "https://github.com/amsehili/auditok/";
    changelog = "https://github.com/amsehili/auditok/blob/v${version}/CHANGELOG";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "auditok";
  };
}
