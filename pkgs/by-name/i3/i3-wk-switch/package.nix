{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "i3-wk-switch";
  version = "2020-03-18";

  src = fetchFromGitHub {
    owner = "tmfink";
    repo = "i3-wk-switch";
    rev = "a618cb8f52120aa8d533bb7c0c8de3ff13b3dc06";
    hash = "sha256-H8rlR6JsBGHuBhf2rarkVc1W32Un9Ew6Ur1M+WLhIDI=";
  };

  propagatedBuildInputs = with python3Packages; [ i3ipc ];
  doCheck = false;

  installPhase = ''
    mkdir -p "$out/bin"
    cp i3-wk-switch.py "$out/bin/i3-wk-switch"
  '';

  dontBuild = true;
  pyproject = false;

  meta = {
    description = "XMonad-like workspace switching for i3 and sway";
    homepage = "https://travisf.net/i3-wk-switcher";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "i3-wk-switch";
  };
}
