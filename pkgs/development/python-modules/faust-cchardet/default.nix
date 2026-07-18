{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  pkgconfig,
  pytestCheckHook,
  python,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "faust-cchardet";
  version = "2.1.19";

  src = fetchFromGitHub {
    owner = "faust-streaming";
    repo = "cChardet";
    tag = "v${version}";
    hash = "sha256-yY6YEhXC4S47rxnkKAta4m16IVGn7gkHSt056bYOYJ4=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cython
    pkgconfig
    setuptools
    wheel
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  postFixup = ''
    # fake cchardet distinfo, so packages that depend on cchardet
    # accept it as a drop-in replacement
    ln -s $out/${python.sitePackages}/{faust_,}cchardet-${version}.dist-info
  '';

  pyproject = true;
  pythonImportsCheck = [ "cchardet" ];

  meta = {
    description = "High-speed universal character encoding detector";
    homepage = "https://github.com/faust-streaming/cChardet";
    changelog = "https://github.com/faust-streaming/cChardet/blob/${src.rev}/CHANGES.rst";
    license = lib.licenses.mpl11;

    maintainers = with lib.maintainers; [
      dotlambda
    ];

    mainProgram = "cchardetect";
  };
}
