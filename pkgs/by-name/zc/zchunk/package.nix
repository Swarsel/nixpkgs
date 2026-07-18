{
  lib,
  stdenv,
  fetchFromGitHub,
  argp-standalone,
  callPackage,
  curl,
  gitUpdater,
  meson,
  ninja,
  pkg-config,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zchunk";
  version = "1.5.3";

  src = fetchFromGitHub {
    owner = "zchunk";
    repo = "zchunk";
    rev = finalAttrs.version;
    hash = "sha256-cBOcU8e2AA4NNYe4j6NDqhK+21ZWNBoJMgKEhyJHpi4=";
  };

  outputs = [
    "out"
    "dev"
    "lib"
    "man"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    curl
    zstd
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ argp-standalone ];

  passthru = {
    tests = lib.packagesFromDirectoryRecursive {
      inherit callPackage;
      directory = ./tests;
    };

    updateScript = gitUpdater { };
  };

  meta = {
    description = "File format designed for highly efficient deltas while maintaining good compression";

    longDescription = ''
      zchunk is a compressed file format that splits the file into independent
      chunks. This allows you to only download changed chunks when downloading a
      new version of the file, and also makes zchunk files efficient over rsync.

      zchunk files are protected with strong checksums to verify that the file
      you downloaded is, in fact, the file you wanted.
    '';

    homepage = "https://github.com/zchunk/zchunk";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "zck";
  };
})
