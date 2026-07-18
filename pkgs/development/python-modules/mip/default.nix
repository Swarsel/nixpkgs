{
  lib,
  stdenv,
  buildPythonPackage,
  cffi,
  dos2unix,
  fetchPypi,
  gurobi,
  gurobipy,
  matplotlib,
  networkx,
  numpy,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  wheel,
  # If Gurobi has already been installed outside of the Nix store, specify its
  # installation directory here
  gurobiHome ? null,
  # Enable support for the commercial Gurobi solver (requires a license)
  gurobiSupport ? false,
}:

buildPythonPackage rec {
  pname = "mip";
  version = "1.15.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-f28Dgc/ixSwbhkAgPaLLVpdLJuI5UN37GnazfZFvGX4=";
  };

  patches = [
    # Some tests try to be smart and dynamically construct a path to their test
    # inputs. Unfortunately, since the test phase is run after installation,
    # those paths point to the Nix store, which no longer contains the test
    # data. This patch hardcodes the data path to point to the source directory.
    ./test-data-path.patch
  ];

  postPatch = ''
    # Allow newer cffi versions to be used
    substituteInPlace pyproject.toml --replace "cffi==1.15.*" "cffi>=1.15"
  '';

  nativeBuildInputs = [
    dos2unix
    setuptools
    setuptools-scm
    wheel
  ];

  propagatedBuildInputs = [
    cffi
  ]
  ++ lib.optionals gurobiSupport ([ gurobipy ] ++ lib.optional (gurobiHome == null) gurobi);

  nativeCheckInputs = [
    matplotlib
    networkx
    numpy
    pytestCheckHook
  ];

  # Tests that rely on Gurobi are activated only when Gurobi support is enabled
  disabledTests = lib.optional (!gurobiSupport) "gurobi";

  # Make MIP use the Gurobi solver, if configured to do so
  makeWrapperArgs = lib.optional gurobiSupport "--set GUROBI_HOME ${
    if gurobiHome == null then gurobi.outPath else gurobiHome
  }";

  optional-dependencies = {
    inherit gurobipy numpy;
  };

  # Source files have CRLF terminators, which make patch error out when supplied
  # with diffs made on *nix machines
  prePatch = ''
    find . -type f -exec ${dos2unix}/bin/dos2unix {} \;
  '';

  pyproject = true;

  meta = {
    description = "Collection of Python tools for the modeling and solution of Mixed-Integer Linear programs (MIPs)";
    homepage = "https://python-mip.com/";
    changelog = "https://github.com/coin-or/python-mip/releases/tag/${version}";
    license = lib.licenses.epl20;
    maintainers = with lib.maintainers; [ nessdoor ];
    broken = stdenv.hostPlatform.isAarch64;
    downloadPage = "https://github.com/coin-or/python-mip/releases";
  };
}
