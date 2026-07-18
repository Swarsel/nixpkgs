{
  lib,
  stdenv,
  fetchurl,
  libsForQt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libguytools";
  version = "2.1.0";

  src = fetchurl {
    url = "mirror://sourceforge/project/libguytools/libguytools/LatestSource/tools-${finalAttrs.version}.tar.gz";
    hash = "sha256-eVYvjo2wKW2g9/9hL9nbQa1FRWDMMqMHok0V/adPHVY=";
  };

  postPatch = ''
    sed -i "/dpkg-buildflags/d" tools.pro
    patchShebangs create_version_file.sh
  '';

  nativeBuildInputs = [
    libsForQt5.qmake
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [ libsForQt5.qtbase ];

  preConfigure = ''
    ./create_version_file.sh
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r lib $out/
    cp -r include $out/
    runHook postInstall
  '';

  dontWrapQtApps = true;
  enableParallelBuilding = true;

  qmakeFlags = [
    "trunk.pro"
    "toolsstatic.pro"
  ];

  meta = {
    description = "Small programming toolbox";
    homepage = "https://libguytools.sourceforge.io";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "libguytools";
  };
})
