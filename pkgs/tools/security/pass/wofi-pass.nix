{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  findutils,
  gnugrep,
  libnotify,
  makeWrapper,
  pass-wayland,
  pwgen,
  wl-clipboard,
  wofi,
  wtype,
  extensions ? exts: [ ],
}:

let
  wrapperPath = lib.makeBinPath [
    coreutils
    findutils
    gnugrep
    libnotify
    pwgen
    wofi
    wl-clipboard
    wtype
    (pass-wayland.withExtensions extensions)
  ];
in
stdenv.mkDerivation rec {
  pname = "wofi-pass";
  version = "24.1.0";

  src = fetchFromGitHub {
    owner = "schmidtandreas";
    repo = "wofi-pass";
    rev = "v${version}";
    sha256 = "sha256-oRGDhr28UQjr+g//fWcLKWXqKSsRUWtdh39UMFSaPfw=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm755 wofi-pass -t $out/bin
    install -Dm755 wofi-pass.conf -t $out/share/doc/wofi-pass/wofi-pass.conf
  '';

  dontBuild = true;

  fixupPhase = ''
    patchShebangs $out/bin

    wrapProgram $out/bin/wofi-pass \
      --prefix PATH : "${wrapperPath}"
  '';

  meta = {
    description = "Script to make wofi work with password-store";
    homepage = "https://github.com/schmidtandreas/wofi-pass";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ akechishiro ];
    platforms = with lib.platforms; linux;
    mainProgram = "wofi-pass";
  };
}
