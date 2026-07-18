{
  alsa-lib,
  callPackage,
  cmake,
  gtk2,
  libjack2,
  libvterm-neovim,
  libxcb,
  lilv,
  qt5,
  robodoc,
  sratom,
  xcbutilxrm,
  zita-alsa-pcmi,
  ...
}@args:

callPackage ./generic.nix (
  args
  // {
    pname = "synthpod";
    version = "unstable-2021-10-22";

    additionalBuildInputs = [
      lilv
      libjack2
      alsa-lib
      zita-alsa-pcmi
      libxcb
      xcbutilxrm
      sratom
      gtk2
      qt5.qtbase
      qt5.wrapQtAppsHook
      libvterm-neovim
      robodoc
      cmake
    ];

    description = "Lightweight Nonlinear LV2 Plugin Container";
    sha256 = "sha256-59WBlOKum5Pcmq2CfFfRHCNEa8uPCoBk0kSjFlIcypw=";
    url = "https://git.open-music-kontrollers.ch/lv2/synthpod/snapshot/synthpod-6f284bdad882037a522c120af92b96d8abf2de60.tar.xz";
  }
)
