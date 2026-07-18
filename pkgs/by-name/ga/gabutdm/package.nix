{
  lib,
  stdenv,
  fetchFromGitHub,
  aria2,
  curl,
  desktop-file-utils,
  json-glib,
  libadwaita,
  libcanberra,
  libgee,
  libsoup_3,
  meson,
  ninja,
  pkg-config,
  qrencode,
  sqlite,
  vala,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gabutdm";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "gabutakut";
    repo = "gabutdm";
    rev = finalAttrs.version;
    hash = "sha256-nzhEJiGBH+semfwLPdpIfPNGQLorqPwwmiAUNM91Br4=";
  };

  postPatch = ''
    substituteInPlace meson/post_install.py \
      --replace-fail gtk-update-icon-cache gtk4-update-icon-cache
  '';

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
    vala
    wrapGAppsHook4
    desktop-file-utils
  ];

  buildInputs = [
    sqlite
    libcanberra
    libsoup_3
    libgee
    json-glib
    qrencode
    curl
    libadwaita
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ aria2 ]}
    )
  '';

  meta = {
    description = "Simple and fast download manager";
    homepage = "https://github.com/gabutakut/gabutdm";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.unix;
    mainProgram = "com.github.gabutakut.gabutdm";
  };
})
