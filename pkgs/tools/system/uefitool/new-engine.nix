{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qt6,
  wrapGAppsHook3,
  zip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "uefitool";
  version = "A73";

  src = fetchFromGitHub {
    owner = "LongSoft";
    repo = "uefitool";
    tag = finalAttrs.version;
    hash = "sha256-XZGddj0i/r1rqntEcqU2AK6ihvqwN031TR12qmEmKLk=";
  };

  patches = lib.optionals stdenv.hostPlatform.isDarwin [ ./bundle-destination.patch ];

  nativeBuildInputs = [
    cmake
    zip
    qt6.wrapQtAppsHook
    wrapGAppsHook3
  ];

  buildInputs = [ qt6.qtbase ];

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;

  meta = {
    description = "UEFI firmware image viewer and editor";
    homepage = "https://github.com/LongSoft/uefitool";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ athre0z ];
    platforms = lib.platforms.unix;
    mainProgram = "uefitool";
  };
})
