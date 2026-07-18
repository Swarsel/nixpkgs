{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  gnumake,
  jdk8,
  makeWrapper,
  versionCheckHook,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "drip";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "ninjudd";
    repo = "drip";
    tag = finalAttrs.version;
    hash = "sha256-ASsEPS8l3E3ReerIrVRQ1ICyMKMFa1XE+WYqxxsXhv4=";
  };

  patches = [ ./wait.patch ];

  postPatch = ''
    patchShebangs .
  '';

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jdk8 ];

  installPhase = ''
    runHook preInstall
    mkdir $out
    cp ./* $out -r
    wrapProgram $out/bin/drip \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          which
          gnumake
          jdk8
        ]
      }
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "version";

  meta = {
    description = "Launcher for the Java Virtual Machine intended to be a drop-in replacement for the java command, only faster";
    homepage = "https://github.com/ninjudd/drip";
    license = lib.licenses.epl10;

    maintainers = with lib.maintainers; [
      rybern
      da157
    ];

    platforms = lib.platforms.linux;
  };
})
