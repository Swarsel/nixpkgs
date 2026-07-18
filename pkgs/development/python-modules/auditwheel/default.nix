{
  lib,
  buildPythonPackage,
  # non-python dependencies
  bzip2,
  fetchPypi,
  gnutar,
  packaging,
  patchelf,
  pretend,
  pyelftools,
  pytestCheckHook,
  setuptools-scm,
  unzip,
}:

buildPythonPackage rec {
  pname = "auditwheel";
  version = "6.7.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-cKpP6OJNRH6ftHCC8KoN4ta96Kqpu/5RcCAyjOqA4PE=";
  };

  nativeCheckInputs = [
    pretend
    pytestCheckHook
  ];

  # Ensure that there are no undeclared deps
  postCheck = ''
    PATH= PYTHONPATH= $out/bin/auditwheel --version > /dev/null
  '';

  build-system = [ setuptools-scm ];

  dependencies = [
    packaging
    pyelftools
  ];

  # Integration tests require docker and networking
  disabledTestPaths = [ "tests/integration" ];

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      bzip2
      gnutar
      patchelf
      unzip
    ])
  ];

  pyproject = true;

  meta = {
    description = "Auditing and relabeling cross-distribution Linux wheels";
    homepage = "https://github.com/pypa/auditwheel";
    changelog = "https://github.com/pypa/auditwheel/blob/${version}/CHANGELOG.md";

    license = with lib.licenses; [
      mit # auditwheel and nibabel
      bsd2 # from https://github.com/matthew-brett/delocate
      bsd3 # from https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-projects/pax-utils/lddtree.py
    ];

    maintainers = with lib.maintainers; [ davhau ];
    platforms = lib.platforms.linux;
    mainProgram = "auditwheel";
  };
}
