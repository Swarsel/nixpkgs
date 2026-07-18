{
  lib,
  fetchFromGitHub,
  imagemagick,
  qrencode,
  stdenvNoCC,
  testQR ? false,
  zbar ? null,
}:
assert testQR -> zbar != false;
stdenvNoCC.mkDerivation {
  pname = "asc-key-to-qr-code-gif";
  version = "0-unstable-2019-01-27";

  src = fetchFromGitHub {
    owner = "yishilin14";
    repo = "asc-key-to-qr-code-gif";
    rev = "5d36a1bada8646ae0f61b04356e62ba5ef10a1aa";
    hash = "sha256-DwxYgBsioL86WM6KBFJ+DuSJo3/1pwD1Fl156XD98RY=";
  };

  postPatch =
    let
      substitutions = [
        ''--replace-fail "convert" "${lib.getExe imagemagick}"''
        ''--replace-fail "qrencode" "${lib.getExe qrencode}"''
      ]
      ++ lib.optionals testQR [
        ''--replace-fail "hash zbarimg" "true"'' # hash does not work on NixOS
        ''--replace-fail "$(zbarimg --raw" "$(${zbar}/bin/zbarimg --raw"''
      ];
    in
    ''
      substituteInPlace asc-to-gif.sh ${lib.concatStringsSep " " substitutions}
    '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp asc-to-gif.sh $out/bin/asc-to-gif
    runHook postInstall
  '';

  dontBuild = true;

  meta = {
    description = "Convert ASCII-armored PGP keys to animated QR code";
    homepage = "https://github.com/yishilin14/asc-key-to-qr-code-gif";
    license = lib.licenses.unfree; # program does not have a license

    maintainers = with lib.maintainers; [
      asymmetric
      NotAShelf
    ];

    platforms = lib.platforms.unix;
    mainProgram = "asc-to-gif";
  };
}
