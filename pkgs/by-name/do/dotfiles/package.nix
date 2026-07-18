{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "dotfiles";
  version = "0.6.5";

  src = fetchPypi {
    inherit (finalAttrs) version pname;
    sha256 = "sha256-fke8lNjyYts6cIrONAFd5r2wAlpWqJhd+usFAPCO5J4=";
  };

  # No tests in archive
  doCheck = false;
  nativeCheckInputs = with python3Packages; [ pytest ];
  build-system = with python3Packages; [ setuptools ];
  dependencies = with python3Packages; [ click ];
  pyproject = true;

  meta = {
    description = "Easily manage your dotfiles";
    homepage = "https://github.com/jbernard/dotfiles";
    license = lib.licenses.isc;
    mainProgram = "dotfiles";
  };
})
