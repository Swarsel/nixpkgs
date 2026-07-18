{
  lib,
  stdenv,
  fetchFromGitHub,
  blueprint-compiler,
  chcase,
  gtksourceview5,
  libadwaita,
  meson,
  ninja,
  pantheon,
  pkg-config,
  vala,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "konbucase";
  version = "4.5.1";

  src = fetchFromGitHub {
    owner = "ryonakano";
    repo = "konbucase";
    tag = finalAttrs.version;
    hash = "sha256-MD+hWZ2+gDuaXdqPUMwbROEzvUgq/YcxGjbz+1fkI9M=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    meson
    ninja
    vala
    pkg-config
    wrapGAppsHook3
    blueprint-compiler
  ];

  buildInputs = [
    pantheon.granite7
    gtksourceview5
    chcase
    libadwaita
  ];

  postInstall = ''
    mv $out/bin/com.github.ryonakano.konbucase $out/bin/konbucase
    substituteInPlace $out/share/applications/com.github.ryonakano.konbucase.desktop \
      --replace-fail "Exec=com.github.ryonakano.konbucase" "Exec=konbucase"
  '';

  meta = {
    description = "Case converting app suitable for coding or typing";
    homepage = "https://github.com/ryonakano/konbucase";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "konbucase";
  };
})
