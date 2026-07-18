{
  lib,
  buildPythonPackage,
  cython,
  fetchPypi,
  numpy,
  pytestCheckHook,
  python-utils,
  setuptools,
}:

buildPythonPackage rec {
  pname = "lap";
  version = "0.5.13";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-nv9xaePKRSmVrwSTzCDTVFLEv9BhIsNsBkVxGf+9QRs=";
  };

  nativeBuildInputs = [ cython ];
  nativeCheckInputs = [ pytestCheckHook ];

  # See https://github.com/NixOS/nixpkgs/issues/255262
  preCheck = ''
    cd "$out"
  '';

  build-system = [ setuptools ];

  dependencies = [
    numpy
    python-utils
  ];

  pyproject = true;
  pythonImportsCheck = [ "lap" ];

  meta = {
    description = "Linear Assignment Problem solver (LAPJV/LAPMOD)";
    homepage = "https://github.com/gatagat/lap";
    changelog = "https://github.com/gatagat/lap/releases/tag/v${version}";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      doronbehar
      tebriel
    ];
  };
}
