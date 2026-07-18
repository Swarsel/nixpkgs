{
  lib,
  stdenv,
  fetchFromGitHub,
  ncompress,
  nix-update-script,
  which,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pigz";
  version = "2.8";

  src = fetchFromGitHub {
    owner = "madler";
    repo = "pigz";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-PzdxyO4mCg2jE/oBk1MH+NUdWM95wIIIbncBg71BkmQ=";
  };

  outputs = [
    "out"
    "doc"
    "man"
  ];

  strictDeps = true;

  buildInputs = [
    zlib
  ];

  makeFlags = [ "CC=${lib.getExe stdenv.cc}" ];
  doCheck = stdenv.hostPlatform.isLinux;

  nativeCheckInputs = [
    which
    ncompress
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 pigz "$out/bin/pigz"
    ln -s pigz "$out/bin/unpigz"
    install -Dm755 pigz.1 "$man/share/man/man1/pigz.1"
    ln -s pigz.1 "$man/share/man/man1/unpigz.1"
    install -Dm755 pigz.pdf "$doc/share/doc/pigz/pigz.pdf"

    runHook postInstall
  '';

  __structuredAttrs = true;
  checkTarget = "tests";
  enableParallelBuilding = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Parallel implementation of gzip for multi-core machines";
    homepage = "https://www.zlib.net/pigz/";
    license = lib.licenses.zlib;

    maintainers = with lib.maintainers; [
      sandarukasa
    ];

    platforms = lib.platforms.unix;
    mainProgram = "pigz";
  };
})
