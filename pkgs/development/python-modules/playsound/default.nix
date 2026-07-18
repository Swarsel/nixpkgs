{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
}:

buildPythonPackage rec {
  pname = "playsound";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "TaylorSMarks";
    repo = "playsound";
    rev = "v${version}";
    sha256 = "0jbq641lmb0apq4fy6r2zyag8rdqgrz8c4wvydzrzmxrp6yx6wyd";
  };

  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "playsound" ];

  meta = {
    description = "Pure Python, cross platform, single function module with no dependencies for playing sounds";
    homepage = "https://github.com/TaylorSMarks/playsound";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
