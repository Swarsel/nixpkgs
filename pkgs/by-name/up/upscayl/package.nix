{
  lib,
  stdenv,
  fetchurl,
  callPackage,
}:

let
  pname = "upscayl";
  version = "2.15.0";
  srcs = {
    aarch64-darwin = fetchurl {
      hash = "sha256-gXqeRaNW0g7ZVkCSbxps9SqPMuVSzLTCGL5F3Om/iwo=";
      url = "https://github.com/upscayl/upscayl/releases/download/v${version}/upscayl-${version}-mac.zip";
    };

    x86_64-linux = fetchurl {
      hash = "sha256-ZFlFfliby5nneepELc5gi6zaM5FrcBmohit8YlKqgik=";
      url = "https://github.com/upscayl/upscayl/releases/download/v${version}/upscayl-${version}-linux.AppImage";
    };
  };
  meta = {
    description = "Free and Open Source AI Image Upscaler";
    homepage = "https://upscayl.github.io/";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      icy-thought
      matteopacini
    ];

    platforms = [ "x86_64-linux" ] ++ lib.platforms.darwin;
    mainProgram = "upscayl";
  };
in
if stdenv.hostPlatform.isDarwin then
  callPackage ./darwin.nix {
    inherit
      pname
      version
      meta
      ;

    src = srcs.${stdenv.hostPlatform.system};
  }
else
  callPackage ./linux.nix {
    inherit
      pname
      version
      meta
      ;

    src = srcs.${stdenv.hostPlatform.system};
  }
