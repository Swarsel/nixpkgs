{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  # build-system
  hatchling,
  libx11,
  libxfixes,
  # native dependencies
  libxrandr,
  # tests
  lsof,
  pillow,
  pytest,
  pytest-cov-stub,
  pytest-rerunfailures,
  pyvirtualdisplay,
  replaceVars,
  xvfb-run,
}:

buildPythonPackage rec {
  pname = "mss";
  version = "10.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-cYK69+4WylaeKAQCi2q5vL9r5cRvwogIQPM7UTuctPg=";
  };

  patches = lib.optionals stdenv.hostPlatform.isLinux [
    (replaceVars ./linux-paths.patch {
      x11 = "${libx11}/lib/libX11.so";
      xfixes = "${libxfixes}/lib/libXfixes.so";
      xrandr = "${libxrandr}/lib/libXrandr.so";
    })
  ];

  doCheck = stdenv.hostPlatform.isLinux;

  nativeCheckInputs = [
    lsof
    pillow
    pytest-cov-stub
    pytest-rerunfailures
    pytest
    pyvirtualdisplay
    xvfb-run
  ];

  checkPhase = ''
    runHook preCheck
    xvfb-run pytest -v -k "not test_grab_with_tuple and not test_grab_with_tuple_percents and not test_resource_leaks"
    runHook postCheck
  '';

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "mss" ];

  meta = {
    description = "Cross-platform multiple screenshots module";
    homepage = "https://github.com/BoboTiG/python-mss";
    changelog = "https://github.com/BoboTiG/python-mss/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ austinbutler ];
    mainProgram = "mss";
  };
}
