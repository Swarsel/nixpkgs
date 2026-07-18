{
  lib,
  fetchPypi,
  python3Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "dazel";
  version = "0.0.43";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-2enQRKg4CAPGHte02io+EfiW9AmuP3Qi41vNQeChg+8=";
  };

  build-system = [
    python3Packages.setuptools
  ];

  pyproject = true;

  meta = {
    description = "Run Google's bazel inside a docker container via a seamless proxy";
    homepage = "https://github.com/nadirizr/dazel";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      malt3
    ];
  };
})
