{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libsForQt5,
  xdg-utils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fstl";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "fstl-app";
    repo = "fstl";
    rev = "v" + finalAttrs.version;
    hash = "sha256-puDYXANiyTluSlmnT+gnNPA5eCcw0Ny6md6Ock6pqLc=";
  };

  postPatch = ''
    patchShebangs --build xdg/xdg_install.sh
    substituteInPlace xdg/fstlapp-fstl.desktop \
      --replace-fail 'Exec=fstl' 'Exec=${placeholder "out"}/bin/fstl'
  '';

  nativeBuildInputs = [
    cmake
    libsForQt5.wrapQtAppsHook
    xdg-utils
  ];

  installPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    runHook preInstall

    mkdir -p $out/Applications
    mv fstl.app $out/Applications

    runHook postInstall
  '';

  postInstall = ''
    env --chdir ../xdg XDG_DATA_HOME=$out/share ./xdg_install.sh fstl
  '';

  meta = {
    description = "Fastest STL file viewer";
    homepage = "https://github.com/fstl-app/fstl";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tweber ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "fstl";
  };
})
