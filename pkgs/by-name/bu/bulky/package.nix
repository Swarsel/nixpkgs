{
  lib,
  stdenv,
  fetchFromGitHub,
  common-licenses,
  gettext,
  glib,
  gobject-introspection,
  gsettings-desktop-schemas,
  gtk3,
  python3,
  wrapGAppsHook3,
  xapp-symbolic-icons,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bulky";
  version = "4.2";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "bulky";
    tag = finalAttrs.version;
    hash = "sha256-rUQ4GN8Pj7dXLbQBt99RmFk4rs+mFL/1taFJiTTVC2A=";
  };

  postPatch = ''
    substituteInPlace usr/lib/bulky/bulky.py \
      --replace-fail "/usr/share/locale" "$out/share/locale" \
      --replace-fail /usr/share/bulky "$out/share/bulky" \
      --replace-fail /usr/share/common-licenses "${common-licenses}/share/common-licenses" \
      --replace-fail __DEB_VERSION__  "${finalAttrs.version}"
  '';

  nativeBuildInputs = [
    wrapGAppsHook3
    gsettings-desktop-schemas
    gettext
    gobject-introspection
  ];

  buildInputs = [
    (python3.withPackages (
      p: with p; [
        pygobject3
        setproctitle
        unidecode
      ]
    ))
    gsettings-desktop-schemas
    gtk3
    glib
  ];

  installPhase = ''
    runHook preInstall
    chmod +x usr/share/applications/*
    cp -ra usr $out
    ln -sf $out/lib/bulky/bulky.py $out/bin/bulky
    runHook postInstall
  '';

  postInstall = ''
    glib-compile-schemas $out/share/glib-2.0/schemas
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix XDG_DATA_DIRS : ${lib.makeSearchPath "share" [ xapp-symbolic-icons ]}
    )
  '';

  meta = {
    description = "Bulk rename app";
    homepage = "https://github.com/linuxmint/bulky";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "bulky";
    teams = [ lib.teams.cinnamon ];
  };
})
