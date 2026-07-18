## Configuration:
# Control you default wine config in nixpkgs-config:
# wine = {
#   release = "stable"; # "stable", "unstable", "staging", "wayland"
#   build = "wineWow"; # "wine32", "wine64", "wineWow"
# };
# Make additional configurations on demand:
# wine.override { wineBuild = "wine32"; wineRelease = "staging"; };
args@{
  lib,
  stdenv,
  callPackage,
  darwin,
  moltenvk, # Allow users to override MoltenVK easily
  alsaSupport ? false,
  cairoSupport ? false,
  cupsSupport ? false,
  cursesSupport ? false,
  dbusSupport ? false,
  embedInstallers ? false, # The Mono and Gecko MSI installers
  ffmpegSupport ? false,
  fontconfigSupport ? false,
  gettextSupport ? false,
  gphoto2Support ? false,
  gstreamerSupport ? false,
  gtkSupport ? false,
  krb5Support ? false,
  mingwSupport ? stdenv.hostPlatform.isDarwin || stdenv.hostPlatform.isAarch64,
  netapiSupport ? false,
  odbcSupport ? false,
  openclSupport ? false,
  openglSupport ? false,
  pcapSupport ? false,
  pulseaudioSupport ? false,
  saneSupport ? false,
  sdlSupport ? false,
  smartcardSupport ? false,
  tlsSupport ? false,
  udevSupport ? false,
  usbSupport ? false,
  v4lSupport ? false,
  vaSupport ? false,
  vulkanSupport ? false,
  waylandSupport ? false,
  wineBuild ?
    if stdenv.hostPlatform.system == "x86_64-linux" then
      "wineWow"
    else if stdenv.hostPlatform.isAarch64 then
      "wine64"
    else
      "wine32",
  wineRelease ? "stable",
  x11Support ? false,
  xineramaSupport ? false,
}:

let
  sources = callPackage ./sources.nix { };

  supportFlags = lib.filterAttrs (
    name: _:
    !builtins.elem name [
      "lib"
      "stdenv"
      "callPackage"
      "darwin"
      "wineRelease"
      "wineBuild"
    ]
  ) args;

  # Map user-facing release names to sources, pname suffix, and staging flag
  releaseInfo = {
    stable = {
      src = sources.stable;
      useStaging = false;
    };

    # Many versions have a "staging" variant, but when we say "staging",
    # the version we want to use is "unstable".
    staging = {
      src = sources.unstable;
      pnameSuffix = "-staging";
      useStaging = true;
    };

    unstable = {
      src = sources.unstable;
      useStaging = false;
    };

    # "yabridge" enables staging too --- we are not interested in
    # yabridge without the staging patches applied.
    yabridge = {
      src = sources.yabridge;
      pnameSuffix = "-yabridge";
      useStaging = true;
    };
  };

  baseWine = lib.getAttr wineBuild (
    callPackage ./packages.nix (releaseInfo.${wineRelease} // supportFlags)
  );
in
if wineRelease == "yabridge" then
  baseWine.overrideAttrs (old: {
    env = old.env // {
      NIX_CFLAGS_COMPILE = "-std=gnu17";
    };
  })
else
  baseWine
