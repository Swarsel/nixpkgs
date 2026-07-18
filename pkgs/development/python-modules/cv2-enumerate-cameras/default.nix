{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "cv2_enumerate_cameras";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "lukehugh";
    repo = "cv2_enumerate_cameras";
    tag = "v${version}";
    hash = "sha256-4QB/yWpurH/ai49PBRECdCfRRQ0tAvzGnpXj+DeP1pE=";
  };

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "cv2_enumerate_cameras" ];

  meta = {
    description = "Retrieve the connected camera's name, VID, PID, and the corresponding OpenCV index";
    homepage = "https://github.com/lukehugh/cv2_enumerate_cameras";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.qyliss ];
    # Needs pyobjc-framework-avfoundation; not currently packaged.
    broken = stdenv.hostPlatform.isDarwin;
  };
}
