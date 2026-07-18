{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
}:

buildPythonPackage rec {
  pname = "pytun";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "montag451";
    repo = "pytun";
    rev = "v${version}";
    sha256 = "sha256-DZ7CoLi6LPhuc55HF9dtek+/N4A29ecnZn7bk7jweuI=";
  };

  # Test directory contains examples, not tests.
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Linux TUN/TAP wrapper for Python";
    homepage = "https://github.com/montag451/pytun";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ montag451 ];
    platforms = lib.platforms.linux;
  };
}
