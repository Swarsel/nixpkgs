{
  lib,
  fetchFromGitHub,
  feh,
  python3,
  srandrd,
  xrandr,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "screenconfig";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "jceb";
    repo = "screenconfig";
    tag = "v${finalAttrs.version}";
    hash = "sha256-X1Mz8UbOOW/4LM9IZoG/kbwv2G0EppTsacKapQMChkc=";
  };

  propagatedBuildInputs = [
    xrandr
    srandrd
    feh
  ];

  build-system = [ python3.pkgs.setuptools ];

  dependencies = with python3.pkgs; [
    toml
  ];

  pyproject = true;

  meta = {
    description = "Automatic configuration of connected screens/monitors";
    homepage = "https://github.com/jceb/screenconfig";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jceb ];
    platforms = lib.platforms.linux;
    mainProgram = "screenconfig";
  };
})
