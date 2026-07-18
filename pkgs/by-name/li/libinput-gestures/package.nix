{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  libinput,
  makeWrapper,
  python3,
  wmctrl,
  extraUtilsPath ? lib.optional (xdotool != null) xdotool,
  xdotool ? null,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libinput-gestures";
  version = "2.79";

  src = fetchFromGitHub {
    owner = "bulletmark";
    repo = "libinput-gestures";
    tag = finalAttrs.version;
    hash = "sha256-oMteEOx2bwPBLgxB9uSE7zuR5vmuqX6J1Tk5nxefWa4=";
  };

  patches = [
    ./0001-hardcode-name.patch
    ./0002-paths.patch
  ];

  postPatch = ''
    substituteInPlace libinput-gestures-setup --replace-fail /usr/ /

    substituteInPlace libinput-gestures \
      --replace-fail      /etc     "$out/etc" \
      --subst-var-by libinput "${libinput}/bin/libinput" \
      --subst-var-by wmctrl   "${wmctrl}/bin/wmctrl"
  '';

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ python3 ];

  installPhase = ''
    runHook preInstall
    ${stdenv.shell} libinput-gestures-setup -d "$out" install
    runHook postInstall
  '';

  postFixup = ''
    rm "$out/bin/libinput-gestures-setup"
    substituteInPlace "$out/share/systemd/user/libinput-gestures.service" --replace "/usr" "$out"
    substituteInPlace "$out/share/applications/libinput-gestures.desktop" --replace "/usr" "$out"
    chmod +x "$out/share/applications/libinput-gestures.desktop"
    wrapProgram "$out/bin/libinput-gestures" --prefix PATH : "${
      lib.makeBinPath ([ coreutils ] ++ extraUtilsPath)
    }"
  '';

  meta = {
    description = "Gesture mapper for libinput";
    homepage = "https://github.com/bulletmark/libinput-gestures";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ teozkr ];
    platforms = lib.platforms.linux;
    mainProgram = "libinput-gestures";
  };
})
