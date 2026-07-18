{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mnemonicode";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "singpolyma";
    repo = "mnemonicode";
    rev = finalAttrs.version;
    hash = "sha256-bGipPvLj6ig+lMLsl/Yve8PmuA93ETvhNKoMPh0JMBM=";
  };

  installPhase = ''
    mkdir -p $out/bin
    mv mnencode $out/bin
    mv mndecode $out/bin
  '';

  meta = {
    description = ''
      Routines which implement a method for encoding binary data into a sequence
      of words which can be spoken over the phone, for example, and converted
      back to data on the other side.
    '';

    homepage = "https://github.com/singpolyma/mnemonicode";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kirillrdy ];
    platforms = lib.platforms.all;
    mainProgram = "mnencode";
  };
})
