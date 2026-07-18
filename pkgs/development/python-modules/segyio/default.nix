{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  ninja,
  numpy,
  pytest,
  scikit-build,
}:

buildPythonPackage rec {
  pname = "segyio";
  version = "1.9.14";

  src = fetchFromGitHub {
    owner = "equinor";
    repo = "segyio";
    tag = "v${version}";
    hash = "sha256-Gprxxz4wUDrThCghW1Z1dHTjeJCrcDxuwguVC+i+ydc=";
  };

  postPatch = ''
    # Fixing bug making one test fail in the python 3.10 build
    substituteInPlace python/segyio/open.py --replace \
    "cube_metrics = f.xfd.cube_metrics(iline, xline)" \
    "cube_metrics = f.xfd.cube_metrics(int(iline), int(xline))"
  '';

  nativeBuildInputs = [
    cmake
    ninja
    scikit-build
  ];

  # I'm not modifying the checkPhase nor adding a pytestCheckHook because the pytest is called
  # within the cmake test phase
  nativeCheckInputs = [
    pytest
    numpy
  ];

  pyproject = false; # Built with cmake

  meta = {
    description = "Fast Python library for SEGY files";
    homepage = "https://github.com/equinor/segyio";
    license = lib.licenses.lgpl3Only;
    maintainers = [ ];
  };
}
