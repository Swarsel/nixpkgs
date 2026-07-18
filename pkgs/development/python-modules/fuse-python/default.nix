{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  fuse,
  pkg-config,
  setuptools,
}:

buildPythonPackage rec {
  pname = "fuse-python";
  version = "1.0.9";

  src = fetchPypi {
    inherit version;
    hash = "sha256-ntWVd8NqshjXAKooOfAh8SwlKzVxhgV1crmOGbwqhYk=";
    pname = "fuse_python";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail 'pkg-config' "${stdenv.cc.targetPrefix}pkg-config"
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ fuse ];
  # no tests implemented
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "fuse" ];

  meta = {
    description = "Python bindings for FUSE";
    homepage = "https://github.com/libfuse/python-fuse";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ psyanticy ];
    broken = stdenv.hostPlatform.isDarwin;
  };
}
