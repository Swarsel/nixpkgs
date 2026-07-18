{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "adafruit-platformdetect";
  version = "3.89.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-dFUtGvz3eahMpjUnoerumZXEKf9CLbFUkrrQw1mcq0s=";
    pname = "adafruit_platformdetect";
  };

  # Project has not published tests yet
  doCheck = false;
  build-system = [ setuptools-scm ];
  pyproject = true;
  pythonImportsCheck = [ "adafruit_platformdetect" ];

  meta = {
    description = "Platform detection for use by Adafruit libraries";
    homepage = "https://github.com/adafruit/Adafruit_Python_PlatformDetect";
    changelog = "https://github.com/adafruit/Adafruit_Python_PlatformDetect/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
