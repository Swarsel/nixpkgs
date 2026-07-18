{
  linuxPackages,
  xpra,
}:
xpra.override {
  nvidia_x11 = linuxPackages.nvidia_x11.override { libsOnly = true; };
  withNvenc = true;
}
