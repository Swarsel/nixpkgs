{
  lib,
  fetchFromGitHub,
  fetchpatch,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "hovercraft";
  version = "2.7";

  src = fetchFromGitHub {
    owner = "regebro";
    repo = "hovercraft";
    tag = finalAttrs.version;
    hash = "sha256-X6EaiVahAYAaFB65oqmj695wlJFXNseqz0SQLzGVD0w=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-qz4Kp4MxlS3KPKRB5/VESCI++66U9q6cjQ0cHy3QjTc=";
      name = "fix tests with pygments 2.14";
      url = "https://sources.debian.org/data/main/h/hovercraft/2.7-5/debian/patches/0003-Fix-tests-with-pygments-2.14.patch";
    })
  ];

  nativeCheckInputs = [ python3Packages.manuel ];
  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    setuptools
    docutils
    lxml
    svg-path
    pygments
    watchdog
  ];

  disabled = !python3Packages.isPy3k;
  pyproject = true;

  meta = {
    description = "Makes impress.js presentations from reStructuredText";
    homepage = "https://github.com/regebro/hovercraft";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.makefu ];
    mainProgram = "hovercraft";
  };
})
