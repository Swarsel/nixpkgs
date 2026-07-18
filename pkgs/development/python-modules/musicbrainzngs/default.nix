{
  lib,
  buildPythonPackage,
  fetchPypi,
  pkgs,
}:

buildPythonPackage (finalAttrs: {
  pname = "musicbrainzngs";
  version = "0.7.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "09z6k07pxncfgfc8clfmmxl2xqbd7h8x8bjzwr95hc0bzl00275b";
  };

  buildInputs = [ pkgs.glibcLocales ];
  env.LC_ALL = "en_US.UTF-8";

  preCheck = ''
    # Remove tests that rely on networking (breaks sandboxed builds)
    rm test/test_submit.py
  '';

  format = "setuptools";

  meta = {
    description = "Python bindings for musicbrainz NGS webservice";
    homepage = "https://python-musicbrainzngs.readthedocs.org/";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
})
