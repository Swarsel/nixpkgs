{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  rclone,
  replaceVars,
  rich,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "rclone-python";
  version = "0.1.23";

  src = fetchFromGitHub {
    owner = "Johannes11833";
    repo = "rclone_python";
    tag = "v${version}";
    hash = "sha256-vvsiXS3uI0TcL+X8+75BQmycrF+EGIgQE1dmGef35rI=";
  };

  patches = [
    (replaceVars ./hardcode-rclone-path.patch {
      rclone = lib.getExe rclone;
    })
  ];

  nativeCheckInputs = [
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  preCheck = ''
    # Unlike upstream we don't actually run an S3 server for testing.
    # See https://github.com/Johannes11833/rclone_python/blob/master/launch_test_server.sh
    mkdir -p "$HOME/.config/rclone"
    cat > "$HOME/.config/rclone/rclone.conf" <<EOF
    [test_server_s3]
    type = combine
    upstreams = "testdir=$(mktemp -d)"
    EOF
  '';

  build-system = [ setuptools ];

  dependencies = [
    rich
  ];

  disabledTestPaths = [
    # test requires a remote that supports public links
    "tests/test_link.py"
    # test looks up latest version on rclone.org
    "tests/test_version.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "rclone_python" ];

  meta = {
    description = "Python wrapper for rclone";
    homepage = "https://github.com/Johannes11833/rclone_python";
    changelog = "https://github.com/Johannes11833/rclone_python/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ CaptainJawZ ];
  };
}
