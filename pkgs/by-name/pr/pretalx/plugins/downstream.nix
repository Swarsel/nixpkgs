{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pretalx-downstream";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "pretalx";
    repo = "pretalx-downstream";
    rev = "v${version}";
    hash = "sha256-sYdaG1F2jprSnzvVgxRyDrKzeQh9H7IKS/T3lObdvzc=";
  };

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pretalx_downstream" ];

  meta = {
    description = "Use pretalx passively by importing another event's schedule";
    homepage = "https://github.com/pretalx/pretalx-downstream";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ wegank ];
  };
}
