{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "base16-shell-preview";
  version = "1.1.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-UWS1weiccSGqBU8grPAUKkuXb7qs5wliHVaPgdW4KtI=";
    pname = "${lib.replaceStrings [ "-" ] [ "_" ] finalAttrs.pname}";
  };

  # If enabled, it will attempt to run '__init__.py, failing by trying to write
  # at "/homeless-shelter" as HOME
  doCheck = false;

  build-system = with python3Packages; [
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "Browse and preview Base16 Shell themes in your terminal";
    homepage = "https://github.com/nvllsvm/base16-shell-preview";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "base16-shell-preview";
  };
})
