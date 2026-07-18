{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qt5,
}:

stdenv.mkDerivation rec {
  pname = "grantlee";
  version = "5.3.1";

  src = fetchFromGitHub {
    owner = "steveire";
    repo = "grantlee";
    rev = "v${version}";
    sha256 = "sha256-enP7b6A7Ndew2LJH569fN3IgPu2/KL5rCmU/jmKb9sY=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    ./grantlee-nix-profiles.patch
    ./grantlee-no-canonicalize-filepath.patch
  ];

  nativeBuildInputs = [
    cmake
    qt5.wrapQtAppsHook
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtscript
  ];

  doCheck = false; # fails all the tests (ctest)

  postFixup =
    # Disabuse CMake of the notion that libraries are in $dev
    ''
      for way in release debug; do
          cmake="$dev/lib/cmake/Grantlee5/GrantleeTargets-$way.cmake"
          if [ -f "$cmake" ]; then
              sed -i "$cmake" -e "s|\''${_IMPORT_PREFIX}|$out|"
          fi
      done
    '';

  grantleePluginPrefix = "lib/grantlee/${lib.versions.majorMinor version}";
  setupHook = ./setup-hook.sh;

  meta = {
    inherit (qt5.qtbase.meta) platforms;
    description = "Qt5 port of Django template system";

    longDescription = ''
      Grantlee is a plugin based String Template system written using the Qt
      framework. The goals of the project are to make it easier for application
      developers to separate the structure of documents from the data they
      contain, opening the door for theming.

      The syntax is intended to follow the syntax of the Django template system,
      and the design of Django is reused in Grantlee.'';

    homepage = "https://github.com/steveire/grantlee";
    license = lib.licenses.lgpl21;
    maintainers = [ ];
  };
}
