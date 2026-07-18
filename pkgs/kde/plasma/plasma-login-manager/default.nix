{
  lib,
  kwin,
  mkKdeDerivation,
  pam,
  pkg-config,
  qttools,
  replaceVars,
}:
mkKdeDerivation {
  pname = "plasma-login-manager";

  patches = [
    ./config-path.patch

    (replaceVars ./kwin-path.patch {
      CMAKE_INSTALL_FULL_BINDIR = null;
      kwin_wayland = lib.getExe' kwin "kwin_wayland";
    })
  ];

  postInstall = ''
    install -Dm444 ${./defaults.conf} $out/lib/plasmalogin/defaults.conf
  '';

  extraBuildInputs = [ pam ];

  extraCmakeFlags = [
    "-DUID_MIN=1000"
    "-DUID_MAX=29999"
    "-DINSTALL_PAM_CONFIGURATION=OFF"
  ];

  extraNativeBuildInputs = [
    pkg-config
    qttools
  ];
}
