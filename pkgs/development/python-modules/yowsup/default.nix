{
  lib,
  fetchFromGitHub,
  appdirs,
  buildPythonPackage,
  consonance,
  isPy3k,
  protobuf,
  pyasyncore,
  pytestCheckHook,
  python-axolotl,
  pythonOlder,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "yowsup";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "tgalal";
    repo = "yowsup";
    tag = "v${version}";
    sha256 = "1pz0r1gif15lhzdsam8gg3jm6zsskiv2yiwlhaif5rl7lv3p0v7q";
  };

  env = {
    # make protobuf compatible with old versions
    # https://developers.google.com/protocol-buffers/docs/news/2022-05-06#python-updates
    PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION = "python";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    appdirs
    consonance
    protobuf
    python-axolotl
    six
  ]
  ++ lib.optionals (!pythonOlder "3.12") [ pyasyncore ];

  # The Python 2.x support of this package is incompatible with `six==1.11`:
  # https://github.com/tgalal/yowsup/issues/2416#issuecomment-365113486
  disabled = !isPy3k;
  pyproject = true;
  pythonRelaxDeps = true;
  pythonRemoveDeps = [ "argparse" ];

  meta = {
    description = "Python WhatsApp library";
    homepage = "https://github.com/tgalal/yowsup";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "yowsup-cli";
  };
}
