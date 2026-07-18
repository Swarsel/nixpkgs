{
  lib,
  fetchFromGitLab,
  nix-update-script,
  python3,
}:
let
  version = "1.44";
in
python3.pkgs.buildPythonApplication {
  inherit version;
  pname = "dput-ng";

  src = fetchFromGitLab {
    owner = "debian";
    repo = "dput-ng";
    tag = "debian/${version}";
    hash = "sha256-3MdxyTRnoK5SUJzY5DTzfOiurcbtxujhiNpMABNLxgY=";
    domain = "salsa.debian.org";
  };

  postPatch = ''
    substituteInPlace dput/core.py --replace-fail /usr/share/dput-ng "$out/share/dput-ng"
  '';

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
  ];

  postInstall = ''
    cp -r bin $out/
    mkdir -p "$out/share/dput-ng"
    cp -r skel/* "$out/share/dput-ng/"
  '';

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    jsonschema
    paramiko
    sphinx
    coverage
    xdg
    python-debian
    distro-info
  ];

  # Requires running dpkg
  disabledTestPaths = [ "tests/test_upload.py" ];
  pyproject = true;
  pythonImportsCheck = [ "dput" ];

  passthru.updateScript = nix-update-script {
    # Debian's tagging scheme is the bane of my existence.
    # Essentially: all tags from 1.40 onwards start with `debian/`,
    # then the version, and then an optional suffix (usually reserved for backports).
    # We want to ignore the backport versions, and strip the `debian/` prefix.
    extraArgs = [ "--version-regex=(?:debian/)?(\\d+(?:\\.\\d+)*)(?:[_+].*)?" ];
  };

  meta = {
    description = "Next-generation Debian package upload tool";
    homepage = "https://dput.readthedocs.io/en/latest/";
    license = with lib.licenses; [ gpl2Plus ];
    maintainers = with lib.maintainers; [ pluiedev ];
    platforms = lib.platforms.linux;
    mainProgram = "dput";
  };
}
