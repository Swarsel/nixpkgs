{
  lib,
  fetchFromGitHub,
  libsForQt5,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "rmview";
  version = "3.1.4";

  src = fetchFromGitHub {
    owner = "bordaigorl";
    repo = "rmview";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-yae86PR/TZKApqrMP7MdS8941J9wqlKzkOnFyIhUk4o=";
  };

  nativeBuildInputs = with python3Packages; [
    pyqt5
    setuptools
    libsForQt5.wrapQtAppsHook
  ];

  propagatedBuildInputs = with python3Packages; [
    pyqt5
    paramiko
    twisted
    pyjwt
    pyopenssl
    service-identity
    sshtunnel
  ];

  preBuild = ''
    pyrcc5 -o src/rmview/resources.py resources.qrc
  '';

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  pyproject = true;

  meta = {
    description = "Fast live viewer for reMarkable 1 and 2";
    homepage = "https://github.com/bordaigorl/rmview";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.nickhu ];
    mainProgram = "rmview";
  };
})
