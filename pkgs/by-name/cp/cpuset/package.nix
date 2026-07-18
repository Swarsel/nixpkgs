{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "cpuset";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "SUSE";
    repo = "cpuset";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fW0SXNI10pb6FTn/2TOqxP9qlys0KL/H9m//NjslUaY=";
  };

  makeFlags = [ "prefix=$(out)" ];

  checkPhase = ''
    runHook preCheck

    make -C t

    runHook postCheck
  '';

  build-system = with python3.pkgs; [
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "Python application that forms a wrapper around the standard Linux filesystem calls, to make using the cpusets facilities in the Linux kernel easier";
    homepage = "https://github.com/SUSE/cpuset";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ wykurz ];
    platforms = lib.platforms.linux;
    mainProgram = "cset";
  };
})
