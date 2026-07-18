{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
}:

buildPythonPackage rec {
  pname = "python-ctags3";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "universal-ctags";
    repo = "python-ctags3";
    rev = version;
    hash = "sha256-x+kyCB05VtOPlenkK5vOTjxXR24d436JpGvSd07PIbA=";
  };

  # Regenerating the bindings keeps later versions of Python happy
  postPatch = ''
    cython src/_readtags.pyx
  '';

  nativeBuildInputs = [ cython ];
  format = "setuptools";

  meta = {
    inherit (src.meta) homepage;
    description = "Ctags indexing python bindings";
    license = lib.licenses.lgpl3Plus;
  };
}
