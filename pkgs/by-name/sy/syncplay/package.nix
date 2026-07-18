{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  qt6,
  enableGUI ? true,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "syncplay";
  version = "1.7.5";

  src = fetchFromGitHub {
    owner = "Syncplay";
    repo = "syncplay";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-qNkucK7+OuNmTGLuTn4hXxKjMq3WpT4CvGRXoQ2+1Oc=";
  };

  patches = [
    ./trusted_certificates.patch
  ];

  nativeBuildInputs = lib.optionals enableGUI [ qt6.wrapQtAppsHook ];

  buildInputs = lib.optionals enableGUI [
    (if stdenv.hostPlatform.isLinux then qt6.qtwayland else qt6.qtbase)
  ];

  makeFlags = [
    "DESTDIR="
    "PREFIX=$(out)"
  ];

  postFixup = lib.optionalString enableGUI ''
    wrapQtApp $out/bin/syncplay
  '';

  dependencies =
    with python3Packages;
    [
      certifi
      pem
      twisted
    ]
    ++ twisted.optional-dependencies.tls
    ++ lib.optional enableGUI pyside6
    ++ lib.optional (stdenv.hostPlatform.isDarwin && enableGUI) appnope;

  pyproject = false;

  meta = {
    description = "Free software that synchronises media players";
    homepage = "https://syncplay.pl/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ assistant ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
