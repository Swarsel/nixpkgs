{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  geos,
  numpy,
  oldest-supported-numpy,
  pytestCheckHook,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "shapely";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "shapely";
    repo = "shapely";
    tag = version;
    hash = "sha256-tnnOJsAI3v52ngFOIUIkeDuRIu2JlZGuHreVv4W8LeE=";
  };

  nativeBuildInputs = [
    cython
    geos # for geos-config
    oldest-supported-numpy
    setuptools
    wheel
  ];

  buildInputs = [ geos ];
  nativeCheckInputs = [ pytestCheckHook ];

  # Fix a ModuleNotFoundError. Investigated at:
  # https://github.com/NixOS/nixpkgs/issues/255262
  preCheck = ''
    cd $out
  '';

  dependencies = [ numpy ];

  disabledTests = lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    # FIXME(lf-): these logging tests are broken, which is definitely our
    # fault. I've tried figuring out the cause and failed.
    #
    # It is apparently some sandbox or no-sandbox related thing on macOS only
    # though.
    "test_error_handler_exception"
    "test_error_handler"
    "test_info_handler"
  ];

  pyproject = true;
  pythonImportsCheck = [ "shapely" ];

  meta = {
    description = "Manipulation and analysis of geometric objects";
    homepage = "https://github.com/shapely/shapely";
    changelog = "https://github.com/shapely/shapely/blob/${src.tag}/CHANGES.txt";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.geospatial ];
  };
}
