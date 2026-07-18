{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  # build-system
  hatchling,
  # dependencies
  matplotlib,
  numba,
  numpy,
  pandas,
  # optional-dependencies
  pyside6,
  # tests
  pytestCheckHook,
  pyyaml,
  qtconsole,
  requests,
  scipy,
  seaborn,
  tabulate,
  torch,
  typing-extensions,
  vtk,
}:

buildPythonPackage (finalAttrs: {
  pname = "optiland";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "HarrisonKramer";
    repo = "optiland";
    tag = "v${finalAttrs.version}";
    hash = "sha256-s+EFsfj+3VIgpqhBv8f6IblyxfxXHWnO/i1lO3bEke4=";
  };

  patches = [
    # wayland is not supported, see:
    # https://github.com/optiland/optiland/issues/556
    (fetchpatch {
      hash = "sha256-a74Z7rp3ji3+9lM8Q/RttMIzwlRBki1N2Y0YtBiVaEA=";
      url = "https://github.com/optiland/optiland/commit/9644df6e06bd24c5a3a7cf36c8df9dd83050bccc.patch";
    })
    # A fixup for the above, see:
    #
    # - https://github.com/optiland/optiland/pull/564#discussion_r3106831922
    # - https://github.com/optiland/optiland/pull/568
    (fetchpatch {
      hash = "sha256-9O+DNbqBDDSAaRkwCy3o76lwy5MJ7WHQqzfcN1fcmnE=";
      url = "https://github.com/optiland/optiland/commit/652922bce5e1854f1d067e292422d95dee129a46.patch";
    })
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ]
  # No need for optional-dependencies.gui, as the relevant tests requiring the
  # gui dependencies are disabled below.
  ++ finalAttrs.finalPackage.passthru.optional-dependencies.torch;

  __structuredAttrs = true;

  build-system = [
    hatchling
  ];

  dependencies = [
    matplotlib
    numba
    numpy
    pandas
    pyyaml
    requests
    scipy
    seaborn
    tabulate
    typing-extensions
    vtk
  ];

  disabledTestPaths = [
    # From some reason, importing pyside6 during tests causes a core dump of the
    # python interpreter, so we disable all GUI tests.
    "tests/gui/"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "optiland"
  ];

  passthru = {
    optional-dependencies = {
      gui = [
        pyside6
        qtconsole
      ];

      torch = [
        torch
      ];
    };
  };

  meta = {
    description = "Comprehensive optical design, optimization, and analysis in Python, including GPU-accelerated and differentiable ray tracing via PyTorch";
    homepage = "https://github.com/HarrisonKramer/optiland";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
    # Intentionally not setting optiland meta.mainProgram, as it is not
    # functional without additional qt6 and python libraries available. See
    # pkgs/by-name/op/optiland/package.nix for a derivation with a working GUI.
  };
})
