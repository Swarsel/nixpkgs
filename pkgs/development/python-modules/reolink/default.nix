{
  lib,
  fetchFromGitHub,
  aiohttp,
  aiounittest,
  buildPythonPackage,
  ffmpeg-python,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "reolink";
  version = "0.64";

  src = fetchFromGitHub {
    owner = "fwestenberg";
    repo = "reolink";
    tag = "v${version}";
    hash = "sha256-3r5BwVlNolji2HIGjqv8gkizx4wWxrKYkiNmSJedKmI=";
  };

  postPatch = ''
    # Packages in nixpkgs is different than the module name
    substituteInPlace setup.py \
      --replace "ffmpeg" "ffmpeg-python"
  '';

  # https://github.com/fwestenberg/reolink/issues/83
  doCheck = false;

  nativeCheckInputs = [
    aiounittest
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    aiohttp
    ffmpeg-python
    requests
  ];

  disabledTests = [
    # Tests require network access
    "test1_settings"
    "test2_states"
    "test3_images"
    "test4_properties"
    "test_succes"
  ];

  enabledTestPaths = [ "test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "reolink" ];
  passthru.skipBulkUpdate = true;

  meta = {
    description = "Module to interact with the Reolink IP camera API";
    homepage = "https://github.com/fwestenberg/reolink";
    changelog = "https://github.com/fwestenberg/reolink/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
