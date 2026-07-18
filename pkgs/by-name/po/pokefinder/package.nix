{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  copyDesktopItems,
  gitUpdater,
  iconConvTools,
  makeDesktopItem,
  python3,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pokefinder";
  version = "4.3.2";

  src = fetchFromGitHub {
    owner = "Admiral-Fish";
    repo = "PokeFinder";
    tag = "v${finalAttrs.version}";
    hash = "sha256-viObYX9W1bUzwGyf7rI1gQeB9OHlLfj5Uny0js/1f6M=";
    fetchSubmodules = true;
  };

  patches = [
    ./set-desktop-file-name.patch
  ];

  postPatch = ''
        substituteInPlace CMakeLists.txt \
          --replace-fail 'set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64")' ""
        substituteInPlace Core/CMakeLists.txt \
          --replace-fail 'if (APPLE)' 'if (FALSE)'
        substituteInPlace Core/RNG/SHA1.cpp \
          --replace-fail '#include "SHA1.hpp"' '#include "SHA1.hpp"
    #include <algorithm>'

        mkdir -p Core/Resources/compression
        touch Core/Resources/compression/__init__.py
        cat <<EOF > Core/Resources/compression/zstd.py
    import zstandard as zstd

    def compress(data, level=3):
        cctx = zstd.ZstdCompressor(level=level)
        return cctx.compress(data)

    def decompress(data):
        dctx = zstd.ZstdDecompressor()
        return dctx.decompress(data)
    EOF
  '';

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
    (python3.withPackages (ps: [ ps.zstandard ]))
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    copyDesktopItems
    iconConvTools
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qttools
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ qt6.qtwayland ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isAarch "-flax-vector-conversions";

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString (stdenv.hostPlatform.isDarwin) ''
    mkdir -p $out/Applications
    cp -R PokeFinder.app $out/Applications
  ''
  + lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    install -D PokeFinder $out/bin/PokeFinder
    icoFileToHiColorTheme $src/Form/Images/pokefinder.ico pokefinder $out
  ''
  + ''
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      comment = "Cross platform Pokémon RNG tool";
      desktopName = "PokéFinder";
      exec = "PokeFinder";
      icon = "pokefinder";
      name = "pokefinder";
    })
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "Cross platform Pokémon RNG tool";
    homepage = "https://github.com/Admiral-Fish/PokeFinder";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ leo60228 ];
    platforms = lib.platforms.all;
    mainProgram = "PokeFinder";
  };
})
