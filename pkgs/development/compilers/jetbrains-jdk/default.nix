{
  lib,
  fetchurl,
  callPackage,
  jdk,
  jetbrains,
  libxkbcommon,
  speechd-minimal,
  wayland-protocols,
  wayland-scanner,
  debugBuild ? false,
  withJcef ? true,
}:

let
  gtk-protocols =
    let
      rev = "refs/tags/4.22.1";
      hash = "sha256-zCcXuiEYL2N4Q+WT96ouVDwdZVSohgU/QA2BkGlnZZ0=";
    in
    fetchurl {
      hash = hash;
      # We only need the wayland protocols file
      url = "https://raw.githubusercontent.com/GNOME/gtk/${rev}/gdk/wayland/protocol/gtk-shell.xml";
    };
  # To get the new tag:
  # git clone https://github.com/jetbrains/jetbrainsruntime
  # cd jetbrainsruntime
  # git tag --points-at [revision]
  # Look for the line that starts with jbr-
  javaVersion = "25.0.3";
  build = "508.4";
in
callPackage ./common.nix
  {
    inherit jdk debugBuild withJcef;
  }
  {
    inherit javaVersion build;

    extraBuildPhase = ''
      cp -r ${gtk-protocols.out} gtk-shell.xml

      # JBR hardcodes the speech-dispatcher header location to
      # /usr/include/speech-dispatcher in its mkimages scripts.
      substituteInPlace \
        jb/project/tools/linux/scripts/mkimages_x64.sh \
        jb/project/tools/linux/scripts/mkimages_aarch64.sh \
        --replace-fail \
          "--with-speechd-include=/usr/include/speech-dispatcher" \
          "--with-speechd-include=${lib.getDev speechd-minimal}/include/speech-dispatcher"
    '';

    extraConfigureFlags = [
      "--with-wayland-protocols=${wayland-protocols.out}/share/wayland-protocols"
    ];

    extraNativeBuildInputs = [
      wayland-scanner
      libxkbcommon
    ];

    homePath = "${jetbrains.jdk}/lib/openjdk";
    jcefPackage = jetbrains.jcef;
    # run `git log -1 --pretty=%ct` in jdk repo for new value on update
    sourceDateEpoch = 1780959777;
    srcHash = "sha256-N+7D++Cxu0RGWChEWW8gtNz7E2I8qM2AFbXv4luAXto=";
    vendorVersionString = "nix/JBR-${javaVersion}-b${build}${if withJcef then "-jcef" else ""}";
  }
