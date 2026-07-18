{
  lib,
  fetchurl,
  bash,
  cabextract,
  curl,
  gnupg,
  libGL,
  libGLU,
  libx11,
  pkgsi686Linux,
  stdenv_32bit,
}:

let
  wine_custom = pkgsi686Linux.wine-staging;

  mozillaPluginPath = "/lib/mozilla/plugins";

  stdenv' = stdenv_32bit;

in
stdenv'.mkDerivation (finalAttrs: {

  pname = "pipelight";
  version = "0.2.8.2";

  src = fetchurl {
    url = "https://bitbucket.org/mmueller2012/pipelight/get/v${finalAttrs.version}.tar.gz";
    sha256 = "1kyy6knkr42k34rs661r0f5sf6l1s2jdbphdg89n73ynijqmzjhk";
  };

  patches = [
    ./pipelight.patch
    ./wine-6.13-new-args.patch
    # https://source.winehq.org/git/wine.git/commit/cf4a781e987a98a8d48610362a20a320c4a1016d
    # adds ControlMask as a static variable.
    ./wine-7.10-ControlMask.patch
  ];

  buildInputs = [
    wine_custom
    libx11
    libGLU
    libGL
    curl
  ];

  env.NIX_CFLAGS_COMPILE = toString [ "-fpermissive" ];

  postInstall = ''
    $out/bin/pipelight-plugin --create-mozilla-plugins
  '';

  preFixup = ''
    substituteInPlace $out/share/pipelight/install-dependency \
      --replace cabextract ${cabextract}/bin/cabextract
  '';

  configurePhase = ''
    patchShebangs .
    ./configure \
      --prefix=$out \
      --moz-plugin-path=$out/${mozillaPluginPath} \
      --wine-path=${wine_custom} \
      --gpg-exec=${gnupg}/bin/gpg \
      --bash-interp=${bash}/bin/bash \
      --downloader=${curl.bin}/bin/curl
      $configureFlags
  '';

  enableParallelBuilding = true;

  passthru = {
    mozillaPlugin = mozillaPluginPath;
    wine = wine_custom;
  };

  meta = {
    description = "Wrapper for using Windows plugins in Linux browsers";
    homepage = "http://pipelight.net/";

    license = with lib.licenses; [
      mpl11
      gpl2Only
      lgpl21
    ];

    maintainers = [ ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];

    mainProgram = "pipelight-plugin";
  };
})
