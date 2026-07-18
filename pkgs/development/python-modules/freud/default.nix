{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # nativeBuildInputs
  cmake,
  # build-system
  cython,
  # tests
  gsd,
  matplotlib,
  # buildInputs
  nanobind,
  ninja,
  numpy,
  onetbb,
  # dependencies
  parsnip,
  pytestCheckHook,
  rowan,
  scikit-build-core,
  scipy,
  sympy,
}:

buildPythonPackage (finalAttrs: {
  pname = "freud";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "glotzerlab";
    repo = "freud";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NRI3cv3yQxAwkGxh0CFYEERNkjP51Z58vtCV9GlIESY=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    nanobind
    onetbb
  ];

  # Because we prefer to not `leaveDotGit`, we need to fool upstream into
  # thinking we left the .git files in the submodules, so cmake won't think we
  # didn't initialize them. Upstream doesn't support using the system wide
  # installed version of these libraries, and it's probably aint's worth the
  # hassle, because upstream also doesn't distribute all of these dependencies'
  # libraries, and probably it uses only what it needs.
  preConfigure = ''
    touch extern/{voro++,fsph,Eigen}/.git
  '';

  nativeCheckInputs = [
    gsd
    matplotlib
    pytestCheckHook
    sympy
  ];

  # https://github.com/NixOS/nixpkgs/issues/255262
  preCheck = ''
    rm -rf freud
  '';

  build-system = [
    cython
    numpy
    scikit-build-core
  ];

  dependencies = [
    numpy
    parsnip
    rowan
    scipy
  ];

  disabledTests = [
    # 4 tests fail with:
    #
    # AttributeError: module 'scipy.special' has no attribute 'sph_harm'
    #
    # See: https://github.com/glotzerlab/freud/issues/1408
    "test_ld"
    "test_multiple_l"
    "test_qlmi"
    "test_query_point_ne_points"
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "freud" ];

  meta = {
    description = "Powerful, efficient particle trajectory analysis in scientific Python";
    homepage = "https://github.com/glotzerlab/freud";
    changelog = "https://github.com/glotzerlab/freud/blob/${finalAttrs.src.tag}/ChangeLog.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
})
