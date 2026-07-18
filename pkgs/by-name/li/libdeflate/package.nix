{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fixDarwinDylibNames,
  pkgsStatic,
  testers,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libdeflate";
  version = "1.25";

  src = fetchFromGitHub {
    owner = "ebiggers";
    repo = "libdeflate";
    rev = "v${finalAttrs.version}";
    hash = "sha256-2TiV3kmFs9j4aYetoYeWg3+MoZ542/0zaD0hwn9b8ZA=";
  };

  nativeBuildInputs = [ cmake ] ++ lib.optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames;
  buildInputs = [ zlib ];

  cmakeFlags = [
    "-DLIBDEFLATE_BUILD_TESTS=ON"
  ]
  ++ lib.optionals stdenv.hostPlatform.isStatic [ "-DLIBDEFLATE_BUILD_SHARED_LIB=OFF" ];

  doCheck = true;

  passthru.tests = {
    pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
    };

    static = pkgsStatic.libdeflate;
  };

  meta = {
    description = "Fast DEFLATE/zlib/gzip compressor and decompressor";
    homepage = "https://github.com/ebiggers/libdeflate";
    changelog = "https://github.com/ebiggers/libdeflate/blob/v${finalAttrs.version}/NEWS.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      kaction
    ];

    platforms = lib.platforms.unix ++ lib.platforms.windows;
    pkgConfigModules = [ "libdeflate" ];
  };
})
