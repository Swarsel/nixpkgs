{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  # build-system
  cmake,
  nanobind,
  ninja,
  # dependencies
  numpy,
  # tests
  pytest-xdist,
  pytestCheckHook,
  scikit-build-core,
  scipy,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "ducc0";
  version = "0.41.0";

  src = fetchFromGitLab {
    owner = "mtr";
    repo = "ducc";
    tag = "ducc0_${lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    hash = "sha256-OeTTrIcvY9bhnctc6h1xUdSriQN4RNy3vjxWKKlT0ew=";
    domain = "gitlab.mpcdf.mpg.de";
  };

  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail '"pybind11>=2.13.6", ' ""
  '';

  env = {
    DUCC0_OPTIMIZATION = "portable";
    DUCC0_USE_NANOBIND = "";
  };

  nativeCheckInputs = [
    pytest-xdist
    pytestCheckHook
    scipy
  ];

  postInstall = ''
    mkdir -p $out/include
    cp -r ${finalAttrs.src}/src/ducc0 $out/include
  '';

  build-system = [
    cmake
    nanobind
    ninja
    scikit-build-core
    setuptools
  ];

  dependencies = [ numpy ];
  dontUseCmakeConfigure = true;
  enabledTestPaths = [ "python/test" ];
  pyproject = true;
  pythonImportsCheck = [ "ducc0" ];

  meta = {
    description = "Efficient algorithms for Fast Fourier transforms and more";
    homepage = "https://gitlab.mpcdf.mpg.de/mtr/ducc";
    changelog = "https://gitlab.mpcdf.mpg.de/mtr/ducc/-/blob/${finalAttrs.src.tag}/ChangeLog?ref_type=tags";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ parras ];
  };
})
