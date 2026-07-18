{
  lib,
  stdenv,
  fetchFromGitHub,
  aspell,
  bzip2,
  cmake,
  fetchpatch2,
  gettext,
  libiconv,
  libidn,
  libsForQt5,
  libx11,
  lua5,
  miniupnpc,
  pcre-cpp,
  perl,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "eiskaltdcpp";
  version = "2.4.2";

  src = fetchFromGitHub {
    owner = "eiskaltdcpp";
    repo = "eiskaltdcpp";
    rev = "v${version}";
    sha256 = "sha256-JmAopXFS6MkxW0wDQ1bC/ibRmWgOpzU0971hcqAehLU=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-GIdcIHKXNSbHxbiMGRPgfq2w/zNSfR/FhyyXayFWfg8=";
      url = "https://github.com/eiskaltdcpp/eiskaltdcpp/commit/5ab5e1137a46864b6ecd1ca302756da8b833f754.patch?full_index=1";
    })
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required (VERSION 2.6.3)" "cmake_minimum_required (VERSION 3.10)"
    substituteInPlace {dcpp,dht,extra,json}/CMakeLists.txt \
      --replace-fail "cmake_minimum_required (VERSION 2.6)" "cmake_minimum_required (VERSION 3.10)"
    substituteInPlace eiskaltdcpp-{cli,daemon}/CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.6)" "cmake_minimum_required (VERSION 3.10)"
    substituteInPlace eiskaltdcpp-qt/CMakeLists.txt \
      --replace-fail "cmake_minimum_required (VERSION 2.8.11)" "cmake_minimum_required (VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qttools
    libsForQt5.qtmultimedia
    libsForQt5.qtscript
    bzip2
    libx11
    pcre-cpp
    libidn
    lua5
    miniupnpc
    aspell
    gettext
    (perl.withPackages (
      p: with p; [
        GetoptLong
        TermShellUI
      ]
    ))
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin libiconv;

  cmakeFlags = [
    (lib.cmakeBool "DBUS_NOTIFY" true)
    (lib.cmakeBool "FREE_SPACE_BAR_C" true)
    (lib.cmakeBool "LUA_SCRIPT" true)
    (lib.cmakeBool "PERL_REGEX" true)
    (lib.cmakeBool "USE_ASPELL" true)
    (lib.cmakeBool "USE_CLI_JSONRPC" true)
    (lib.cmakeBool "USE_MINIUPNP" true)
    (lib.cmakeBool "USE_JS" true)
    (lib.cmakeBool "WITH_LUASCRIPTS" true)
    (lib.cmakeBool "WITH_SOUNDS" true)
  ];

  postInstall = ''
    ln -s $out/bin/$pname-qt $out/bin/$pname
  '';

  preFixup = ''
    substituteInPlace $out/bin/eiskaltdcpp-cli-jsonrpc \
      --replace "/usr/local" "$out"
  '';

  meta = {
    description = "Cross-platform program that uses the Direct Connect and ADC protocols";
    homepage = "https://github.com/eiskaltdcpp/eiskaltdcpp";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
