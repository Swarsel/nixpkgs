{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  jansson,
  libsearpc,
  libuuid,
  nix-update-script,
  pkg-config,
  qt6,
  seafile-shared,
  withShibboleth ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "seafile-client";
  version = "9.0.20";

  src = fetchFromGitHub {
    owner = "haiwen";
    repo = "seafile-client";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0idZCoTsuC32DolSLFDknQjvGWHGd4DQPCUyqocuuKA=";
  };

  patches = [
    # https://github.com/NixOS/nixpkgs/issues/442063
    (fetchpatch {
      hash = "sha256-N1fepqjTm/M17+TgwNTUecP/wGVlBuZEtTezFgJEeVM=";
      name = "fix_build_with_QT6.patch";
      url = "https://aur.archlinux.org/cgit/aur.git/plain/fix_build_with_QT6.diff?h=seafile-client&id=8bbd6e5017f03dbb368603b4313738b0d783ca2a";
    })
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt --replace-fail \
      'CMAKE_MINIMUM_REQUIRED(VERSION 2.8.9)' \
      'CMAKE_MINIMUM_REQUIRED(VERSION 3.10)'
  '';

  nativeBuildInputs = [
    libuuid
    pkg-config
    cmake
    qt6.wrapQtAppsHook
    qt6.qttools
  ];

  buildInputs = [
    qt6.qt5compat
    seafile-shared
    jansson
    libsearpc
  ]
  ++ lib.optional withShibboleth qt6.qtwebengine;

  cmakeFlags = lib.optional withShibboleth "-DBUILD_SHIBBOLETH_SUPPORT=ON";

  qtWrapperArgs = [
    "--suffix PATH : ${lib.makeBinPath [ seafile-shared ]}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Desktop client for Seafile, the Next-generation Open Source Cloud Storage";
    homepage = "https://github.com/haiwen/seafile-client";
    changelog = "https://github.com/haiwen/seafile-client/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      schmittlauch
    ];

    platforms = lib.platforms.linux;
    mainProgram = "seafile-applet";
  };
})
