{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  libjpeg-tools,
  numpy,
  poetry-core,
  pydicom,
  pylibjpeg,
  pylibjpeg-data,
  pytestCheckHook,
  setuptools,
}:

let
  self = buildPythonPackage {
    pname = "pylibjpeg-libjpeg";
    version = "2.4.0";

    src = fetchFromGitHub {
      owner = "pydicom";
      repo = "pylibjpeg-libjpeg";
      tag = "v${self.version}";
      hash = "sha256-e25xCw3KUrZmWSDUQI507n7kybuK0R+xPbJWzzEhZtQ=";
    };

    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-fail 'poetry-core >=1.8,<2' 'poetry-core'
      rmdir lib/libjpeg
      cp -r ${libjpeg-tools.src} lib/libjpeg
      chmod u+w lib/libjpeg
    '';

    doCheck = false; # circular test dependency with `pylibjpeg` and `pydicom`

    nativeCheckInputs = [
      pydicom
      pylibjpeg-data
      pylibjpeg
      pytestCheckHook
    ];

    build-system = [
      cython
      poetry-core
      setuptools
    ];

    dependencies = [ numpy ];
    pyproject = true;
    pythonImportsCheck = [ "libjpeg" ];

    passthru.tests.check = self.overridePythonAttrs (_: {
      doCheck = true;
    });

    meta = {
      description = "JPEG, JPEG-LS and JPEG XT plugin for pylibjpeg";
      homepage = "https://github.com/pydicom/pylibjpeg-libjpeg";
      changelog = "https://github.com/pydicom/pylibjpeg-libjpeg/releases/tag/v${self.version}";
      license = lib.licenses.gpl3Only;
      maintainers = with lib.maintainers; [ bcdarwin ];
    };
  };
in
self
