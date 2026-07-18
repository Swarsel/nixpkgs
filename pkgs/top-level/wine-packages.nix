{
  lib,
  stdenv,
  config,
  newScope,
  # not for anything bound in the package set, do note
  pkgs,
  wineBuild,
}:

lib.makeExtensible (
  self:
  let
    callPackage = newScope self;
  in
  {
    inherit callPackage wineBuild;

    base = self.minimal.override {
      alsaSupport = stdenv.hostPlatform.isLinux;
      cairoSupport = stdenv.hostPlatform.isLinux;
      cupsSupport = true;
      cursesSupport = true;
      dbusSupport = stdenv.hostPlatform.isLinux;
      ffmpegSupport = true;
      fontconfigSupport = stdenv.hostPlatform.isLinux;
      gettextSupport = true;
      mingwSupport = true;
      openglSupport = true;
      pulseaudioSupport = config.pulseaudio or stdenv.hostPlatform.isLinux;
      saneSupport = stdenv.hostPlatform.isLinux;
      sdlSupport = true;
      tlsSupport = true;
      udevSupport = stdenv.hostPlatform.isLinux;
      usbSupport = true;
      vulkanSupport = true;
      waylandSupport = stdenv.hostPlatform.isLinux;
      x11Support = stdenv.hostPlatform.isLinux;
      xineramaSupport = stdenv.hostPlatform.isLinux;
    };

    fonts = callPackage ../applications/emulators/wine/fonts.nix { };

    full = self.base.override {
      embedInstallers = true;
      gphoto2Support = true;
      gstreamerSupport = true;
      gtkSupport = stdenv.hostPlatform.isLinux;
      krb5Support = true;
      netapiSupport = stdenv.hostPlatform.isLinux;
      odbcSupport = true;
      openclSupport = true;
      pcapSupport = true;
      smartcardSupport = true;
      v4lSupport = stdenv.hostPlatform.isLinux;
      vaSupport = stdenv.hostPlatform.isLinux;
    };

    minimal = callPackage ../applications/emulators/wine {
      inherit wineBuild;
      wineRelease = config.wine.release or "stable";
    };

    stable = self.base.override { wineRelease = "stable"; };
    stableFull = self.full.override { wineRelease = "stable"; };
    staging = self.base.override { wineRelease = "staging"; };
    stagingFull = self.full.override { wineRelease = "staging"; };
    unstable = self.base.override { wineRelease = "unstable"; };
    unstableFull = self.full.override { wineRelease = "unstable"; };

    wayland = self.base.override {
      x11Support = false;
    };

    waylandFull = self.full.override {
      x11Support = false;
    };

    yabridge =
      let
        yabridge = self.base.override { wineRelease = "yabridge"; };
      in
      if wineBuild == "wineWow" then yabridge else lib.dontDistribute yabridge;
  }
)
