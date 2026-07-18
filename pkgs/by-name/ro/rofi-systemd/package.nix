{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  gawk,
  jq,
  makeWrapper,
  rofi,
  systemd,
  util-linux,
}:

stdenv.mkDerivation rec {
  pname = "rofi-systemd";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "IvanMalison";
    repo = "rofi-systemd";
    tag = "v${version}";
    sha256 = "1zwbw119mblp5b6dj4h92fi0y2ymimlgh4bawi5ks2051hpq6c1a";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    cp -a rofi-systemd $out/bin/rofi-systemd
  '';

  dontBuild = true;

  fixupPhase = ''
    patchShebangs $out/bin

    wrapProgram $out/bin/rofi-systemd --prefix PATH : "${wrapperPath}"
  '';

  wrapperPath = lib.makeBinPath [
    coreutils
    gawk
    jq
    rofi
    systemd
    util-linux
  ];

  meta = {
    description = "Control your systemd units using rofi";
    homepage = "https://github.com/IvanMalison/rofi-systemd";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ imalison ];
    platforms = with lib.platforms; linux;
    mainProgram = "rofi-systemd";
  };
}
