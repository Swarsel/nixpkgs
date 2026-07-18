{
  lib,
  # dependencies
  absl-py,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  grpcio,
  markdown,
  numpy,
  packaging,
  pillow,
  protobuf,
  python,
  setuptools,
  standard-imghdr,
  tensorboard-data-server,
  versionCheckHook,
  werkzeug,
}:

buildPythonPackage rec {
  pname = "tensorboard";
  version = "2.20.0";

  # tensorflow/tensorboard is built from a downloaded wheel, because
  # https://github.com/tensorflow/tensorboard/issues/719 blocks buildBazelPackage.
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ncn5eMuEwHI6z5o0XZbBhPApPRjxZruNWe4Jjmz6q6Y=";
    dist = "py3";
    format = "wheel";
    python = "py3";
  };

  nativeCheckInputs = [
    versionCheckHook
  ];

  postInstall =
    let
      patch = fetchpatch {
        excludes = [
          "tensorboard/BUILD"
          "tensorboard/data/BUILD"
          "tensorboard/default_test.py"
          "tensorboard/version_test.py"
        ];

        hash = "sha256-+jaXI4fVQP4mOg6y94KPMMCg3XuHV/gBUDNsp3ogS6c=";
        name = "remove-runtime-pkg_resources-dependency.patch";
        url = "https://github.com/tensorflow/tensorboard/commit/29f809f4737489912612635d9079a61f8e570bb8.patch";
      };
    in
    ''
      pushd $out/${python.sitePackages}
      patch -p1 < ${patch}
      popd
    '';

  dependencies = [
    absl-py
    grpcio
    markdown
    numpy
    packaging
    pillow
    protobuf
    setuptools
    tensorboard-data-server
    werkzeug

    # Requires 'imghdr' which has been removed from python in 3.13
    # ModuleNotFoundError: No module named 'imghdr'
    # https://github.com/tensorflow/tensorboard/issues/6964
    standard-imghdr
  ];

  format = "wheel";

  pythonImportsCheck = [
    "tensorboard"
    "tensorboard.backend"
    "tensorboard.compat"
    "tensorboard.data"
    "tensorboard.plugins"
    "tensorboard.summary"
    "tensorboard.util"
  ];

  pythonRelaxDeps = [
    "google-auth-oauthlib"
    "protobuf"
  ];

  meta = {
    description = "TensorFlow's Visualization Toolkit";
    homepage = "https://www.tensorflow.org/";
    changelog = "https://github.com/tensorflow/tensorboard/blob/${version}/RELEASE.md";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];
    mainProgram = "tensorboard";
  };
}
