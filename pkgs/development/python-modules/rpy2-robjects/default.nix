{
  lib,
  fetchurl,
  R,
  buildPythonPackage,
  fetchpatch2,
  ipython,
  isPyPy,
  jinja2,
  numpy,
  pandas,
  pytestCheckHook,
  rpy2-rinterface,
  setuptools,
  tzlocal,
}:

buildPythonPackage rec {
  pname = "rpy2-robjects";
  version = "3.6.5";

  src = fetchurl {
    url = "mirror://pypi/${builtins.substring 0 1 pname}/${pname}/${
      builtins.replaceStrings [ "-" ] [ "_" ] pname
    }-${version}.tar.gz";

    hash = "sha256-A9CZ9DagGotR+4+L9gJCCpnHzdqMP84OOg9TLja0r+Q=";
  };

  patches = [
    # https://github.com/rpy2/rpy2/pull/1171#issuecomment-3263994962
    (fetchpatch2 {
      hash = "sha256-aR44E8wIBlD7UpQKm7B+aMn2p3FQ8dwBwLwkibIpcuM=";
      relative = "rpy2-robjects";
      revert = true;
      url = "https://github.com/rpy2/rpy2/commit/524546eef9b8f7f3d61aeb76d7e7fa7beeabd2d2.patch?full_index=1";
    })
  ];

  nativeBuildInputs = [
    R # needed at setup time to detect R_HOME (alternatively set R_HOME explicitly)
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    ipython
    jinja2
    numpy
    pandas
    rpy2-rinterface
    tzlocal
  ];

  disabled = isPyPy;

  disabledTests = [
    # panda 3.0 type mismatch
    "test_ri2pandas"
  ];

  pyproject = true;

  pytestFlags = [
    # https://github.com/rpy2/rpy2/issues/1218
    "-Wignore::pytest.PytestRemovedIn9Warning"
  ];

  meta = {
    description = "Python interface to R";
    homepage = "https://rpy2.github.io/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ joelmo ];
    platforms = lib.platforms.unix;
  };
}
