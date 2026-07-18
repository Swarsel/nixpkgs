{
  lib,
  apeye,
  autodocsumm,
  beautifulsoup4,
  buildPythonPackage,
  cachecontrol,
  dict2css,
  fetchPypi,
  filelock,
  html5lib,
  python,
  roman,
  ruamel-yaml,
  sphinx,
  sphinx-autodoc-typehints,
  sphinx-jinja2-compat,
  sphinx-prompt,
  sphinx-tabs,
  tabulate,
  whey,
}:

buildPythonPackage (finalAttrs: {
  pname = "sphinx-toolbox";
  version = "4.1.2";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-wwpPhsTCnpetsOuTN9NfUJPLlqRPScr/z31bxYqIt4E=";
    pname = "sphinx_toolbox";
  };

  postPatch = ''
    substituteInPlace \
      requirements.txt PKG-INFO pyproject.toml \
      --replace-fail "sphinx-tabs<3.4.7,>=1.2.1" "sphinx-tabs<=3.5.0,>=1.2.1" \
      --replace-fail "ruamel.yaml<=0.18.16,>=0.16.12" "ruamel.yaml<=0.19.1,>=0.16.12"
  '';

  # Not PEP420 compliant, some variables are imported from within the package.
  postFixup = ''
    echo '__version__: str = "${finalAttrs.version}"' > $out/${python.sitePackages}/sphinx_toolbox/__init__.py
  '';

  build-system = [ whey ];

  dependencies = [
    sphinx
    apeye
    autodocsumm
    beautifulsoup4
    cachecontrol
    dict2css
    filelock
    html5lib
    roman
    ruamel-yaml
    sphinx-autodoc-typehints
    sphinx-jinja2-compat
    sphinx-prompt
    sphinx-tabs
    tabulate
  ];

  pyproject = true;

  meta = {
    description = "Box of handy tools for Sphinx";
    homepage = "https://github.com/sphinx-toolbox/sphinx-toolbox";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
