{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  loguru,
  poetry-core,
}:

buildPythonPackage rec {
  pname = "apple-compress";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "m1stadev";
    repo = "apple-compress";
    tag = "v${version}";
    hash = "sha256-uM5HFkhvzAIfdAglPUvJfckngjUPSZqydyVcPcdtyfs=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ poetry-core ];

  dependencies = [
    click
    loguru
  ];

  pyproject = true;
  pythonImportsCheck = [ "apple_compress" ];

  meta = {
    description = "Python bindings for Apple's libcompression";
    homepage = "https://github.com/m1stadev/apple-compress";
    changelog = "https://github.com/m1stadev/apple-compress/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
    platforms = lib.platforms.darwin;
    mainProgram = "acompress";
  };
}
