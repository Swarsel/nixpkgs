{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
}:

buildPythonPackage rec {
  pname = "pcpp";
  version = "1.30";

  src = fetchFromGitHub {
    owner = "ned14";
    repo = "pcpp";
    tag = "v${version}";
    hash = "sha256-Fs+CMV4eRKcB+KdV93ncgcqaMnO5etnMY/ivmSJh3Wc=";
    fetchSubmodules = true;
  };

  format = "setuptools";

  meta = {
    description = "C99 preprocessor written in pure Python";
    homepage = "https://github.com/ned14/pcpp";
    license = lib.licenses.bsd0;
    maintainers = with lib.maintainers; [ rakesh4g ];
    mainProgram = "pcpp";
  };
}
