{
  lib,
  stdenv,
  buildPythonPackage,
  # tests
  cmake,
  cython,
  fetchPypi,
  fetchpatch,
  gitMinimal,
  # build-system, dependencies
  meson,
  ninja,
  pyproject-metadata,
  pytest-mock,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "meson-python";
  version = "0.20.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-bZcmrmzTfiLyEMdLNkswGApowgRC6X/wnzxWakFK9zg=";
    pname = "meson_python";
  };

  nativeCheckInputs = [
    cmake
    cython
    gitMinimal
    pytestCheckHook
    pytest-mock
  ];

  # meson-python respectes MACOSX_DEPLOYMENT_TARGET, but compares it with the
  # actual platform version during tests, which mismatches.
  # https://github.com/mesonbuild/meson-python/issues/760
  # FIXME: drop in 0.19.0
  preCheck =
    if stdenv.hostPlatform.isDarwin then
      ''
        unset MACOSX_DEPLOYMENT_TARGET
      ''
    else
      null;

  build-system = [
    meson
    ninja
    pyproject-metadata
  ];

  dependencies = [
    meson
    ninja
    pyproject-metadata
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  setupHooks = [ ./add-build-flags.sh ];

  meta = {
    description = "Meson Python build backend (PEP 517)";
    homepage = "https://github.com/mesonbuild/meson-python";
    changelog = "https://github.com/mesonbuild/meson-python/blob/${version}/CHANGELOG.rst";
    license = [ lib.licenses.mit ];
    maintainers = with lib.maintainers; [ doronbehar ];
    teams = [ lib.teams.python ];
  };
}
