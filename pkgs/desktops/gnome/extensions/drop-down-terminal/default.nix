{
  lib,
  stdenv,
  fetchFromGitHub,
  gjs,
  gnome,
  replaceVars,
  vte,
}:

stdenv.mkDerivation {
  pname = "gnome-shell-extension-drop-down-terminal";
  version = "unstable-2020-03-25";

  src = fetchFromGitHub {
    owner = "zzrough";
    repo = "gs-extensions-drop-down-terminal";
    rev = "a59669afdb395b3315619f62c1f740f8b2f0690d";
    sha256 = "0igfxgrjdqq6z6xg4rsawxn261pk25g5dw2pm3bhwz5sqsy4bq3i";
  };

  patches = [
    (replaceVars ./fix_vte_and_gjs.patch {
      inherit gjs vte;
    })
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gnome-shell/extensions
    cp -r "drop-down-terminal@gs-extensions.zzrough.org" $out/share/gnome-shell/extensions/
    runHook postInstall
  '';

  passthru = {
    extensionPortalSlug = "drop-down-terminal";
    extensionUuid = "drop-down-terminal@gs-extensions.zzrough.org";
  };

  meta = {
    description = "Configurable drop down terminal shell";
    homepage = "https://github.com/zzrough/gs-extensions-drop-down-terminal";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ ericdallo ];
  };
}
