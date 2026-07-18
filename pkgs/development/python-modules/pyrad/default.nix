{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  netaddr,
  nix-update-script,
  pytestCheckHook,
  setuptools,
  sphinx-rtd-theme,
  sphinxHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyrad";
  version = "2.5.4";

  src = fetchFromGitHub {
    owner = "pyradius";
    repo = "pyrad";
    tag = finalAttrs.version;
    hash = "sha256-94BjJRzCSJu/bVuYYKFlJkBcOVcQjmbDJ8QG+JwVpxY=";
  };

  outputs = [
    "out"
    "doc"
  ];

  # Upstream doesn't exclude docs, example, and pyrad.tests from package
  # discovery, causing them to be installed into site-packages.
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'exclude = ["tests*"]' 'exclude = ["docs*", "example*", "pyrad.tests*"]'
  '';

  nativeBuildInputs = [
    sphinxHook
    sphinx-rtd-theme
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ netaddr ];
  pyproject = true;
  pythonImportsCheck = [ "pyrad" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Python RADIUS Implementation";
    homepage = "https://github.com/pyradius/pyrad";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ drawbu ];
  };
})
