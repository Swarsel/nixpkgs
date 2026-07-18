{
  lib,
  fetchFromGitea,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "cdist";
  version = "7.0.0";

  src = fetchFromGitea {
    owner = "ungleich-public";
    repo = "cdist";
    rev = finalAttrs.version;
    hash = "sha256-lIx0RtGQJdY2e00azI9yS6TV+5pCegpKOOD0dQmgMqA=";
    domain = "code.ungleich.ch";
  };

  outputs = [
    "out"
    "man"
    "doc"
  ];

  # "make man" creates symlinks in docs/src needed by sphinxHook.
  postPatch = ''
    echo "VERSION = '$version'" > cdist/version.py

    make man
  '';

  nativeBuildInputs = with python3Packages; [
    six
    sphinxHook
    sphinx-rtd-theme
  ];

  preConfigure = ''
    export HOME=/tmp
  '';

  # Test suite requires either non-chrooted environment or root.
  #
  # When "machine_type" explorer figures out that it is running inside
  # chroot, it assumes that it has enough privileges to escape it.
  doCheck = false;

  postInstall = ''
    mkdir -p $out/share
    mv docs/dist/man $out/share
  '';

  build-system = with python3Packages; [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "cdist" ];
  sphinxRoot = "docs/src";

  meta = {
    description = "Minimalistic configuration management system";
    homepage = "https://www.sdi.st";
    changelog = "https://code.ungleich.ch/ungleich-public/cdist/src/tag/${finalAttrs.version}/docs/changelog";
    # Mostly. There are still couple types that are gpl3-only.
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ kaction ];
    platforms = lib.platforms.unix;
  };
})
