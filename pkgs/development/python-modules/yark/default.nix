{
  lib,
  buildPythonPackage,
  click,
  colorama,
  fetchPypi,
  flask,
  poetry-core,
  progress,
  requests,
  yt-dlp,
}:

buildPythonPackage rec {
  pname = "yark";
  version = "1.2.12";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-K66LC/HhajAMCWU7PPfxkoaK84kLlAccYAH5FXoc+yE=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    click
    colorama
    flask
    progress
    requests
    yt-dlp
  ];

  # Module has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "yark" ];

  pythonRelaxDeps = [
    "flask"
    "requests"
    "yt-dlp"
  ];

  meta = {
    description = "Module for YouTube archiving";
    homepage = "https://github.com/Owez/yark";
    changelog = "https://github.com/Owez/yark/releases/tag/v${lib.versions.majorMinor version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "yark";
  };
}
