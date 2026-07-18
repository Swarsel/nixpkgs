{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  curl-cffi,
  garth,
  pdm-backend,
  requests,
  ua-generator,
}:

buildPythonPackage (finalAttrs: {
  pname = "garminconnect";
  version = "0.3.6";

  src = fetchFromGitHub {
    owner = "cyberjunky";
    repo = "python-garminconnect";
    tag = finalAttrs.version;
    hash = "sha256-2nhBLaITFZPzk6fWnS6VAllPxkFofTIU8M+2yLvQMdA=";
  };

  # Tests require a token
  doCheck = false;
  build-system = [ pdm-backend ];

  dependencies = [
    curl-cffi
    garth
    requests
    ua-generator
  ];

  pyproject = true;
  pythonImportsCheck = [ "garminconnect" ];
  pythonRelaxDeps = [ "garth" ];

  meta = {
    description = "Garmin Connect Python API wrapper";
    homepage = "https://github.com/cyberjunky/python-garminconnect";
    changelog = "https://github.com/cyberjunky/python-garminconnect/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
