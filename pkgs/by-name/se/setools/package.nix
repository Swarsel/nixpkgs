{
  lib,
  fetchFromGitHub,
  checkpolicy,
  libselinux,
  libsepol,
  python3Packages,
  withGraphics ? false,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "setools";
  version = "4.7.0";

  src = fetchFromGitHub {
    owner = "SELinuxProject";
    repo = "setools";
    tag = finalAttrs.version;
    hash = "sha256-Xe+/ZEtSRfBPFcRnyR4igoTJVYBg4jH3Ov76CFVY8+k=";
  };

  buildInputs = [ libsepol ];

  preBuild = ''
    export SEPOL="${lib.getLib libsepol}/lib/libsepol.a"
  '';

  nativeCheckInputs = [
    python3Packages.tox
    checkpolicy
  ];

  preCheck = ''
    export CHECKPOLICY=${lib.getExe checkpolicy}
  '';

  build-system = with python3Packages; [
    cython
    setuptools
  ];

  dependencies =
    with python3Packages;
    [
      libselinux
      setuptools
    ]
    ++ lib.optionals withGraphics [ pyqt5 ];

  optional-dependencies = {
    analysis = with python3Packages; [
      networkx
      pygraphviz
    ];
  };

  pyproject = true;
  setupPyBuildFlags = [ "-i" ];

  meta = {
    inherit (libsepol.meta) maintainers;
    description = "SELinux Policy Analysis Tools";
    homepage = "https://github.com/SELinuxProject/setools";
    changelog = "https://github.com/SELinuxProject/setools/blob/${finalAttrs.version}/ChangeLog";

    license = with lib.licenses; [
      gpl2Only
      lgpl21Plus
    ];

    platforms = lib.platforms.linux;
  };
})
