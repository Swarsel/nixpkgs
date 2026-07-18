{
  lib,
  buildPythonPackage,
  fetchPypi,
  libjpeg,
  libpng,
  libtiff,
  libwebp,
  numpy,
  pkg-config,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "imread";
  version = "0.7.6";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ULPXCJyGJQTCKyVu9R/kWFGzRhbbFMDr/FU2AByZYBU=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libjpeg
    libpng
    libtiff
    libwebp
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    cd $TMPDIR
    export HOME=$TMPDIR
  '';

  build-system = [ setuptools ];
  dependencies = [ numpy ];
  pyproject = true;

  pytestFlags = [
    # verbose build outputs needed to debug hard-to-reproduce hydra failures
    "-v"
    "--pyargs"
    "imread"
  ];

  pythonImportsCheck = [ "imread" ];

  meta = {
    description = "Python package to load images as numpy arrays";
    homepage = "https://imread.readthedocs.io/";
    changelog = "https://github.com/luispedro/imread/blob/v${version}/ChangeLog";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ luispedro ];
    platforms = lib.platforms.unix;
  };
}
