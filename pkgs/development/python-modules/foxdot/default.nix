{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  supercollider,
  tkinter,
}:

buildPythonPackage rec {
  pname = "foxdot";
  version = "0.9.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-9dIaqrGcYpZeWlRlymRvG9YnTRav0zktfmUpFBlN/7E=";
  };

  # Requires a running SuperCollider instance
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    tkinter
  ]
  # we currently build SuperCollider only on Linux
  # but FoxDot is totally usable on macOS with the official SuperCollider binary
  ++ lib.optionals stdenv.hostPlatform.isLinux [ supercollider ];

  pyproject = true;

  meta = {
    description = "Live coding music with SuperCollider";
    homepage = "https://foxdot.org/";
    license = lib.licenses.cc-by-sa-40;
    maintainers = with lib.maintainers; [ mrmebelman ];
    mainProgram = "FoxDot";
  };
}
