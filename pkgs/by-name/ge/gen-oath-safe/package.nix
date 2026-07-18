{
  lib,
  stdenv,
  coreutils,
  fetchFromSourcehut,
  file,
  libcaca,
  makeWrapper,
  openssl,
  python3,
  qrencode,
  yubikey-manager,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gen-oath-safe";
  version = "0.11.0";

  src = fetchFromSourcehut {
    owner = "~mcepl";
    repo = "gen-oath-safe";
    tag = finalAttrs.version;
    sha256 = "1914z0jgj7lni0nf3hslkjgkv87mhxdr92cmhmbzhpjgjgr23ydp";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase =
    let
      path = lib.makeBinPath [
        coreutils
        file
        libcaca.bin
        openssl.bin
        python3
        qrencode
        yubikey-manager
      ];
    in
    ''
      mkdir -p $out/bin
      cp gen-oath-safe $out/bin/
      wrapProgram $out/bin/gen-oath-safe \
        --prefix PATH : ${path}
    '';

  dontBuild = true;

  meta = {
    description = "Script for generating HOTP/TOTP keys (and QR code)";
    homepage = "https://git.sr.ht/~mcepl/gen-oath-safe";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.makefu ];
    platforms = lib.platforms.unix;
    mainProgram = "gen-oath-safe";
  };

})
