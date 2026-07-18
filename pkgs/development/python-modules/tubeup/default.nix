{
  lib,
  buildPythonPackage,
  docopt,
  fetchPypi,
  internetarchive,
  setuptools,
  yt-dlp,
}:

buildPythonPackage (finalAttrs: {
  pname = "tubeup";
  version = "2025.5.11";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-LZ/kNtw5Tw3PtqQp4Dq2qOeXgofID5upFvpLMXUIuiM=";
  };

  # Tests failing upstream
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    internetarchive
    docopt
    yt-dlp
  ];

  pyproject = true;
  pythonImportsCheck = [ "tubeup" ];
  pythonRelaxDeps = [ "docopt" ];

  meta = {
    description = "Youtube (and other video site) to Internet Archive Uploader";
    homepage = "https://github.com/bibanon/tubeup";
    changelog = "https://github.com/bibanon/tubeup/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    mainProgram = "tubeup";
  };
})
