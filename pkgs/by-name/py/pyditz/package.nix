{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "pyditz";
  version = "0.11";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-2gNlrpBk4wxKJ1JvsNeoAv2lyGUc2mmQ0Xvn7eiaJVE=";
  };

  build-system = with python3Packages; [ setuptools-scm ];

  dependencies = with python3Packages; [
    pyyaml
    six
    jinja2
    cerberus
  ];

  pyproject = true;

  meta = {
    description = "Drop-in replacement for the Ditz distributed issue tracker";
    homepage = "https://hg.sr.ht/~zondo/pyditz";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ ilikeavocadoes ];
    platforms = lib.platforms.linux;
  };
})
