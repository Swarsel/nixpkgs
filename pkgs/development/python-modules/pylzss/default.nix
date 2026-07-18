{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pylzss";
  version = "0.3.8";

  src = fetchFromGitHub {
    owner = "m1stadev";
    repo = "pylzss";
    tag = "v${version}";
    hash = "sha256-Y0u9rFJWYWyJUVEgpLtQHsXu0JpTgRKxFJHB+B3EFyU=";
  };

  # upstream's test.py is dysfunctional
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "lzss" ];

  meta = {
    description = "Python library for decoding/encoding LZSS-compressed data";
    homepage = "https://github.com/m1stadev/pylzss";
    changelog = "https://github.com/m1stadev/pylzss/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
