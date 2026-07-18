{
  lib,
  stdenv,
  fetchurl,
  directoryListingUpdater,
  efl,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "ecrire";
  version = "0.2.0";

  src = fetchurl {
    url = "https://download.enlightenment.org/rel/apps/${pname}/${pname}-${version}.tar.xz";
    sha256 = "1pszk583rzclfqy3dyjh1m9pz1hnr84vqz8vw9kngcnmj23mjr6r";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    efl
  ];

  passthru.updateScript = directoryListingUpdater { };

  meta = {
    description = "EFL simple text editor";
    homepage = "https://www.enlightenment.org/";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    mainProgram = "ecrire";
    teams = [ lib.teams.enlightenment ];
  };
}
