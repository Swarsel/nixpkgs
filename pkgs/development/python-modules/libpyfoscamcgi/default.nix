{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  defusedxml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "libpyfoscamcgi";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner = "Foscam-wangzhengyu";
    repo = "libfoscamcgi";
    tag = "v${version}";
    hash = "sha256-tKA2UnVHAUjDfvm+t/aCk+3YfWfwjfEWPRgieDAcr7k=";
  };

  # tests need access to a camera
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    defusedxml
  ];

  pyproject = true;
  pythonImportsCheck = [ "libpyfoscamcgi" ];

  meta = {
    description = "Python Library for Foscam IP Cameras";
    homepage = "https://github.com/Foscam-wangzhengyu/libfoscamcgi";
    changelog = "https://github.com/Foscam-wangzhengyu/libfoscamcgi/releases/tag/${src.tag}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
