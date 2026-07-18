{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  pkgs,
  python-dateutil,
  which,
}:

buildPythonPackage rec {
  pname = "pync";
  version = "2.0.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "38b9e61735a3161f9211a5773c5f5ea698f36af4ff7f77fa03e8d1ff0caa117f";
  };

  propagatedBuildInputs = [ python-dateutil ];
  nativeCheckInputs = [ which ];

  preInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    sed -i 's|^\([ ]*\)self.bin_path.*$|\1self.bin_path = "${pkgs.terminal-notifier}/bin/terminal-notifier"|' build/lib/pync/TerminalNotifier.py
  '';

  format = "setuptools";

  meta = {
    description = "Python Wrapper for Mac OS 10.8 Notification Center";
    homepage = "https://pypi.org/project/pync/";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.darwin;
  };
}
