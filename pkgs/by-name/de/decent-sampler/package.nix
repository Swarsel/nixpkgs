{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  alsa-plugins,
  autoPatchelfHook,
  buildFHSEnv,
  copyDesktopItems,
  expat,
  fetchzip,
  freetype,
  libx11,
  makeDesktopItem,
  nghttp2,
}:

let
  pname = "decent-sampler";
  version = "1.18.1";

  icon = fetchurl {
    hash = "sha256-EXjaHrlXY0HU2EGTrActNbltIiqTLfdkFgP7FXoLzrM=";
    url = "https://www.decentsamples.com/wp-content/uploads/2018/09/cropped-Favicon_512x512.png";
  };

  decent-sampler = stdenv.mkDerivation {
    inherit pname version;

    src = fetchzip {
      # Download page: https://store.decentsamples.com/downloads/decent-sampler/versions
      url = "https://cdn.decentsamples.com/production/builds/ds/${version}/Decent_Sampler-${version}-Linux-Static-x86_64.tar.gz";
      hash = "sha256-wL9L4I2iw9r3r69TOr37XXEs3iECMuNGX9Ez63P/f8w=";
    };

    nativeBuildInputs = [
      autoPatchelfHook
      copyDesktopItems
    ];

    buildInputs = [
      alsa-lib
      expat
    ];

    installPhase = ''
      runHook preInstall

      install -Dm755 DecentSampler $out/bin/decent-sampler
      install -Dm755 DecentSampler.so -t $out/lib/vst
      install -d "$out/lib/vst3" && cp -r "DecentSampler.vst3" $out/lib/vst3
      install -Dm444 ${icon} $out/share/icons/hicolor/512x512/apps/decent-sampler.png

      runHook postInstall
    '';

    desktopItems = [
      (makeDesktopItem {
        categories = [
          "Audio"
          "AudioVideo"
        ];

        comment = "DecentSampler player";
        desktopName = "Decent Sampler";
        exec = "decent-sampler";
        icon = "decent-sampler";
        name = "decent-sampler";
        type = "Application";
      })
    ];
  };

in

buildFHSEnv {
  inherit (decent-sampler) pname version;

  extraInstallCommands = ''
    cp -r ${decent-sampler}/lib $out/lib
    cp -r ${decent-sampler}/share $out/share
  '';

  runScript = "decent-sampler";

  targetPkgs = pkgs: [
    alsa-plugins
    decent-sampler
    freetype
    nghttp2
    libx11
  ];

  meta = {
    description = "Audio sample player";

    longDescription = ''
      Decent Sampler is an audio sample player.
      Allowing you to play sample libraries in the DecentSampler format
      (files with extensions: dspreset and dslibrary).
    '';

    homepage = "https://www.decentsamples.com/product/decent-sampler-plugin/";
    # It claims to be free but we currently cannot find any license
    # that it is released under.
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      adam248
      kaptcha0
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "decent-sampler";
  };
}
