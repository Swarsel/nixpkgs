{
  lib,
  buildPythonPackage,
  fetchPypi,
  jinja2,
  markupsafe,
  standard-imghdr,
  whey,
  whey-pth,
}:
buildPythonPackage rec {
  pname = "sphinx-jinja2-compat";
  version = "0.4.1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-AYjwgC1Cw9pymXUztVoAgVZZp40/gdS0dHsfsVpXKOY=";
    pname = "sphinx_jinja2_compat";
  };

  postPatch = ''
    substituteInPlace \
      requirements.txt PKG-INFO pyproject.toml \
      --replace-fail "standard-imghdr==3.10.14" "standard-imghdr"
  '';

  build-system = [
    whey
    whey-pth
  ];

  dependencies = [
    jinja2
    markupsafe
    standard-imghdr
  ];

  pyproject = true;
  pythonImportsCheck = [ "sphinx_jinja2_compat" ];

  meta = {
    description = "Patches Jinja2 v3 to restore compatibility with earlier Sphinx versions";
    homepage = "https://github.com/sphinx-toolbox/sphinx-jinja2-compat";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
