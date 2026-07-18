{
  lib,
  stdenv,
  fetchFromGitHub,
  cairomm,
  cli11,
  cmake,
  eigen,
  hidrd,
  inih,
  meson,
  microsoft-gsl,
  ninja,
  pkg-config,
  sdl2-compat,
  spdlog,
  systemd,
  udevCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "iptsd";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "linux-surface";
    repo = "iptsd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2yYO1xb576IHaJquTrQtmAjJITGdW06I3eHD+HR88xI=";
  };

  # Original installs udev rules and service config into global paths
  postPatch = ''
    substituteInPlace etc/meson.build \
      --replace-fail "install_dir: unitdir" "install_dir: '$out/etc/systemd/system'" \
      --replace-fail "install_dir: rulesdir" "install_dir: '$out/etc/udev/rules.d'"
    substituteInPlace etc/scripts/iptsd-find-service \
      --replace-fail "systemd-escape" "${lib.getExe' systemd "systemd-escape"}"
    substituteInPlace etc/udev/50-iptsd.rules.in \
      --replace-fail "/bin/systemd-escape" "${lib.getExe' systemd "systemd-escape"}"
  '';

  nativeBuildInputs = [
    cmake
    meson
    ninja
    pkg-config
    udevCheckHook
  ];

  buildInputs = [
    cairomm
    cli11
    eigen
    hidrd
    inih
    microsoft-gsl
    sdl2-compat
    spdlog
    systemd
  ];

  mesonFlags = [
    "-Dservice_manager=systemd"
    "-Dsample_config=false"
    "-Db_lto=false" # plugin needed to handle lto object -> undefined reference to ...
  ];

  doInstallCheck = true;
  dontUseCmakeConfigure = true;

  meta = {
    description = "Userspace daemon for Intel Precise Touch & Stylus";
    homepage = "https://github.com/linux-surface/iptsd";
    changelog = "https://github.com/linux-surface/iptsd/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      tomberek
      dotlambda
    ];

    platforms = lib.platforms.linux;
    mainProgram = "iptsd";
  };
})
