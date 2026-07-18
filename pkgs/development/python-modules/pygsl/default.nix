{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch2,
  gsl,
  meson-python,
  numpy,
  pkg-config,
  pytestCheckHook,
  swig,
}:

buildPythonPackage rec {
  pname = "pygsl";
  version = "2.6.4";

  src = fetchFromGitHub {
    owner = "pygsl";
    repo = "pygsl";
    tag = "v${version}";
    hash = "sha256-dZIWOwRRrF1bux9UTIxN31/S380wPT4gpQ/gYbUO4FQ=";
  };

  patches = [
    # Fix gcc 15 -Wincompatible-pointer-types errors in arraycopy.c.
    (fetchpatch2 {
      hash = "sha256-o7hZScnRqD7rxRn2EOxoys2F1U4GVOS9BmcxjTsh/vc=";
      url = "https://src.fedoraproject.org/rpms/pygsl/raw/c35177ef7f8f5104a2b96a87d909248140ee6009/f/pygsl-incompatible-pointer.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    swig
  ];

  buildInputs = [
    gsl
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    cd tests
  '';

  build-system = [
    meson-python
    numpy
  ];

  dependencies = [
    numpy
  ];

  pyproject = true;

  meta = {
    description = "Python interface for GNU Scientific Library";
    homepage = "https://github.com/pygsl/pygsl";
    changelog = "https://github.com/pygsl/pygsl/blob/${src.tag}/ChangeLog";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ matthiasbeyer ];
  };
}
