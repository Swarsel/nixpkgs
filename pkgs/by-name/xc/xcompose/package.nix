{
  lib,
  fetchFromGitHub,
  libx11,
  python3,
  xorgproto,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "xcompose";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "Udzu";
    repo = "xcompose";
    rev = "v${version}";
    hash = "sha256-TO7HqGoq9uq6USkvvDubBK3VC0i23yOqSo/t5B1xTiI=";
  };

  postPatch = ''
    substituteInPlace src/xcompose/__init__.py \
      --replace-fail /usr/include/X11 ${xorgproto}/include/X11 \
      --replace-fail /usr/share/X11 ${libx11}/share/X11
  '';

  build-system = [
    python3.pkgs.hatchling
  ];

  dependencies = with python3.pkgs; [
    pygtrie
  ];

  pyproject = true;

  pythonImportsCheck = [
    "xcompose"
  ];

  meta = {
    description = "Utility for managing X11 compose key sequences";
    homepage = "https://github.com/Udzu/xcompose";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ncfavier ];
    mainProgram = "xcompose";
  };
}
