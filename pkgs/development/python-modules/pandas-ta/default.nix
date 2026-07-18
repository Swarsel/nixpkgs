{
  lib,
  fetchurl,
  buildPythonPackage,
  nix-update-script,
  numpy,
  pandas,
  python-dateutil,
  pytz,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "pandas-ta";
  version = "0.3.14b";

  src = fetchurl {
    url = "https://www.pandas-ta.dev/assets/zip/pandas_ta-${version}.tar.gz";
    hash = "sha256-D6Na7IMdKBXqMLhxaIqNIKdrKIp74tJswAw1zYwJqZM=";
  };

  postPatch = ''
    substituteInPlace pandas_ta/momentum/squeeze_pro.py \
      --replace-fail "import NaN" "import nan"
  '';

  # PyTestCheckHook failing because of missing test dependency. Packages has been tested manually.
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    numpy
    pandas
    python-dateutil
    pytz
    setuptools
    six
  ];

  pyproject = true;
  pythonImportsCheck = [ "pandas_ta" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Technical Analysis Indicators";
    homepage = "https://www.pandas-ta.dev/";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ derdennisop ];
  };
}
