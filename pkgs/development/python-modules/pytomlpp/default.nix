{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  doxygen,
  matplotlib,
  pelican,
  pybind11,
  pytestCheckHook,
  python,
  python-dateutil,
}:

buildPythonPackage rec {
  pname = "pytomlpp";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "bobfang1992";
    repo = "pytomlpp";
    rev = "v${version}";
    hash = "sha256-RRsjnZK0FJiSkpWxurs9vJFyo2SUAKyFKXoJ8bcsHKI=";
    fetchSubmodules = true;
  };

  # The latest setuptools has deprecated `setup_requires` and will attempt to automatically invoke `pip` to install dependencies during the build.
  patches = [ ./0001-remove-setup_requires.patch ];
  buildInputs = [ pybind11 ];
  doCheck = true;

  nativeCheckInputs = [
    pytestCheckHook

    python-dateutil
    doxygen
    python
    pelican
    matplotlib
  ];

  preCheck = ''
    cd tests
  '';

  disabledTests = [
    # incompatible with pytest7
    # https://github.com/bobfang1992/pytomlpp/issues/66
    "test_loads_valid_toml_files"
    "test_round_trip_for_valid_toml_files"
    "test_decode_encode_binary"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "pytomlpp" ];

  meta = {
    description = "Python wrapper for tomlplusplus";
    homepage = "https://github.com/bobfang1992/pytomlpp";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
