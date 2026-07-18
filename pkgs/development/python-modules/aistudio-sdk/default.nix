{
  lib,
  bce-python-sdk,
  buildPythonPackage,
  click,
  fetchPypi,
  prettytable,
  psutil,
  requests,
  tqdm,
}:

let
  version = "0.3.8";

  format = "wheel";
in
buildPythonPackage {
  inherit version format;
  pname = "aistudio-sdk";

  # No source code dist available
  src = fetchPypi {
    inherit version format;
    hash = "sha256-v8lq9yQ6wu4zAwFISapAKHF8zlr6Yir4z+Oh1E0ZQdY=";
    dist = "py3";
    pname = "aistudio_sdk";
    python = "py3";
  };

  dependencies = [
    bce-python-sdk
    requests
    tqdm
    # Implicit dependency for file_download.py
    psutil
    # `aistudio` binary dependencies
    click
    prettytable
  ];

  pythonImportsCheck = [ "aistudio_sdk" ];

  meta = {
    description = "Python client library for the AIStudio API";
    homepage = "https://pypi.org/project/aistudio-sdk";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ kyehn ];
    mainProgram = "aistudio";
  };
}
