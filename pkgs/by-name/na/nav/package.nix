{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  libxcrypt-legacy,
  nav,
  testers,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nav";
  version = "1.5.2";

  src = fetchurl {
    url = "https://github.com/Jojo4GH/nav/releases/download/v${finalAttrs.version}/nav-${stdenv.hostPlatform.parsed.cpu.name}-unknown-linux-gnu.tar.gz";

    sha256 =
      {
        aarch64-linux = "sha256-YNS/P6TU7qLPn39X6GyUtjBw7GXOi2btd3AV+etpUhQ=";
        x86_64-linux = "sha256-/A6IZRX8v8yKfcxYxo0gxbsZri2dgTs8YH7H2LauaBE=";
      }
      .${stdenv.hostPlatform.system} or (throw "unsupported system ${stdenv.hostPlatform.system}");
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    stdenv.cc.cc.lib
    libxcrypt-legacy
    zlib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp nav $out/bin

    runHook postInstall
  '';

  sourceRoot = ".";

  passthru.tests = {
    version = testers.testVersion {
      package = nav;
    };
  };

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Interactive and stylish replacement for ls & cd";

    longDescription = ''
      To make use of nav, add the following lines to your configuration:
      `programs.bash.shellInit = "eval \"$(nav --init bash)\"";` and
      `programs.zsh.shellInit = "eval \"$(nav --init zsh)\"";`
    '';

    homepage = "https://github.com/Jojo4GH/nav";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

    maintainers = with lib.maintainers; [
      David-Kopczynski
      Jojo4GH
    ];

    platforms = lib.platforms.linux;
    mainProgram = "nav";
  };
})
