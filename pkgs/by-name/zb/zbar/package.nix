{
  lib,
  stdenv,
  fetchFromGitHub,
  argp-standalone,
  autoreconfHook,
  bash,
  dbus,
  docbook_xsl,
  fetchpatch,
  gtk3,
  imagemagickBig,
  libiconv,
  libintl,
  libsForQt5,
  libv4l,
  libx11,
  pkg-config,
  python3,
  wrapGAppsHook3,
  xmlto,
  # The implementation is buggy and produces an error like
  # Name Error (Connection ":1.4380" is not allowed to own the service "org.linuxtv.Zbar" due to security policies in the configuration file)
  # for every scanned code.
  # see https://github.com/mchehab/zbar/issues/104
  enableDbus ? false,
  enableVideo ? stdenv.hostPlatform.isLinux,
  withXorg ? true,
}:

stdenv.mkDerivation rec {
  pname = "zbar";
  version = "0.23.93";

  src = fetchFromGitHub {
    owner = "mchehab";
    repo = "zbar";
    rev = version;
    sha256 = "sha256-6gOqMsmlYy6TK+iYPIBsCPAk8tYDliZYMYeTOidl4XQ=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
    "doc"
    "man"
  ];

  patches = [
    # Fix build, remove these two patches on a release beyond 0.23.93.
    (fetchpatch {
      hash = "sha256-4VEuGAyR7rcIijPLlh4pzL82ESm99Wb35PV/FbY9H6Y=";
      name = "variable-pkg-config-path.patch";
      url = "https://github.com/mchehab/zbar/commit/368571ffa1a0f6cc41f708dd0d27f9b6e9409df8.patch";
    })
    (fetchpatch {
      hash = "sha256-NY3bAElwNvGP9IR6JxUf62vbjx3hONrqu9pMSqaZcLY=";
      name = "qt5-detection-fix.patch";
      url = "https://github.com/mchehab/zbar/commit/a549566ea11eb03622bd4458a1728ffe3f589163.patch";
    })
    # PR from fork not yet merged into upstream
    # See PR: https://github.com/mchehab/zbar/pull/299
    # Remove this patch if the PR is merged or if the issue is solved another way.
    # See https://github.com/NixOS/nixpkgs/issues/456461 for discussion of the root issue
    ./darwin-segfault-optimized-pointer-assignment.patch
  ];

  nativeBuildInputs = [
    pkg-config
    xmlto
    autoreconfHook
    docbook_xsl
  ]
  ++ lib.optionals enableVideo [
    wrapGAppsHook3
    libsForQt5.wrapQtAppsHook
    libsForQt5.qtbase
  ];

  buildInputs = [
    imagemagickBig
    libintl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ]
  ++ lib.optionals enableDbus [
    dbus
  ]
  ++ lib.optionals withXorg [
    libx11
  ]
  ++ lib.optionals enableVideo [
    libv4l
    gtk3
    libsForQt5.qtbase
    libsForQt5.qtwayland
    libsForQt5.qtx11extras
  ];

  configureFlags = [
    "--without-python"
  ]
  ++ (
    if enableDbus then
      [
        "--with-dbusconfdir=${placeholder "out"}/share"
      ]
    else
      [
        "--without-dbus"
      ]
  )
  ++ (
    if enableVideo then
      [
        "--with-gtk=gtk3"
      ]
    else
      [
        "--disable-video"
        "--without-gtk"
        "--without-qt"
      ]
  );

  # Disable assertions which include -dev QtBase file paths.
  env.NIX_CFLAGS_COMPILE = "-DQT_NO_DEBUG";

  # fix iconv linking on macOS
  preConfigure = lib.optionalString stdenv.hostPlatform.isDarwin ''
    export LDFLAGS="-liconv"
  '';

  # Note: postConfigure instead of postPatch in order to include some
  # autoconf-generated files. The template files for the autogen'd scripts are
  # not chmod +x, so patchShebangs misses them.
  postConfigure = ''
    patchShebangs test
  '';

  doCheck = true;

  nativeCheckInputs = [
    bash
    python3
  ];

  checkInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    argp-standalone
  ];

  preCheck = lib.optionalString stdenv.hostPlatform.isDarwin ''
    export NIX_LDFLAGS="$NIX_LDFLAGS -largp"
  '';

  postFixup = lib.optionalString enableVideo ''
    wrapGApp "$out/bin/zbarcam-gtk"
    wrapQtApp "$out/bin/zbarcam-qt"
  '';

  dontWrapGApps = true;
  dontWrapQtApps = true;
  enableParallelBuilding = true;

  meta = {
    description = "Bar code reader";

    longDescription = ''
      ZBar is an open source software suite for reading bar codes from various
      sources, such as video streams, image files and raw intensity sensors. It
      supports many popular symbologies (types of bar codes) including
      EAN-13/UPC-A, UPC-E, EAN-8, Code 128, Code 39, Interleaved 2 of 5 and QR
      Code.
    '';

    homepage = "https://github.com/mchehab/zbar";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.unix;
    mainProgram = "zbarimg";
  };
}
