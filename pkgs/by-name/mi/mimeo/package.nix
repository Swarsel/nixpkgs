{
  lib,
  fetchurl,
  desktop-file-utils,
  file,
  python3Packages,
}:

let
  version = "2023";
in
python3Packages.buildPythonApplication {
  inherit version;
  pname = "mimeo";

  src = fetchurl {
    url = "https://xyne.dev/projects/mimeo/src/mimeo-${version}.tar.xz";
    hash = "sha256-CahvSypwR1aHVDHTdtty1ZfaKBWPolxc73uZ5OyeqZA=";
  };

  postPatch = ''
    substituteInPlace Mimeo.py \
      --replace-fail "EXE_UPDATE_DESKTOP_DATABASE = 'update-desktop-database'" \
                     "EXE_UPDATE_DESKTOP_DATABASE = '${desktop-file-utils}/bin/update-desktop-database'" \
      --replace-fail "EXE_FILE = 'file'" \
                     "EXE_FILE = '${file}/bin/file'"
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/mimeo --help > /dev/null
  '';

  build-system = [ python3Packages.setuptools ];
  dependencies = [ python3Packages.pyxdg ];
  pyproject = true;

  meta = {
    description = "Open files by MIME-type or file name using regular expressions";
    homepage = "https://xyne.dev/projects/mimeo/";
    license = [ lib.licenses.gpl2Only ];
    maintainers = [ lib.maintainers.rycee ];
    platforms = lib.platforms.unix;
    mainProgram = "mimeo";
  };
}
