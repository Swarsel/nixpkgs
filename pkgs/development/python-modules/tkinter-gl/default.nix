{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  python,
  setuptools,
  setuptools-scm,
  tkgl,
  tkinter,
}:

buildPythonPackage rec {
  pname = "tkinter-gl";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "3-manifolds";
    repo = "tkinter_gl";
    tag = "v${version}_as_released";
    hash = "sha256-PNxxjyVGoMw4J/SXWvVITuGMq/HypxUwDkSxeFy2Vag=";
  };

  postPatch = ''
    # Remove compiled TkGL, we compile it ourselves
    rm -r src/tkinter_gl/tk
    # Platform-specific directories are only necessary when using compiled TkGL
    substituteInPlace src/tkinter_gl/__init__.py \
      --replace-fail "pkg_dir = os.path.join(__path__[0], 'tk', target)" \
                     "pkg_dir = os.path.join(__path__[0], 'tk')"
  '';

  postInstall =
    let
      pkgDir = "$out/${python.sitePackages}/tkinter_gl/tk";
    in
    ''
      mkdir -p ${pkgDir}
      ln -s ${tkgl}/lib/Tkgl* ${pkgDir}
    '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ tkinter ];
  pyproject = true;
  pythonImportsCheck = [ "tkinter_gl" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "v(.*)_as_released"
    ];
  };

  meta = {
    description = "Base class for GL rendering surfaces in tkinter";
    homepage = "https://github.com/3-manifolds/tkinter_gl";
    changelog = "https://github.com/3-manifolds/tkinter_gl/releases/tag/${src.tag}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      noiioiu
      alejo7797
    ];
  };
}
