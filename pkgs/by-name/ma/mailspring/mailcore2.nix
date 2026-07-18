{
  lib,
  stdenv,
  cmake,
  cyrus_sasl,
  glib,
  html-tidy,
  icu,
  libctemplate,
  libsysprof-capture,
  libuuid,
  libxml2,
  mailspring-libetpan,
  openssl,
  pcre2,
  pkg-config,
  src,
  version,
  zlib,
}:
stdenv.mkDerivation {
  inherit src version;
  pname = "mailspring-mailcore2";

  postPatch = ''
    # Fix hardcoded impure paths
    substituteInPlace CMakeLists.txt \
      --replace-fail "/usr/include/libxml2" "${lib.getDev libxml2}/include/libxml2" \
      --replace-fail "/usr/include/tidy" "${lib.getDev html-tidy}/include/tidy"

  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Tell CMake to build with Objective C if the file is C, otherwise Objective C++ if the file is C++.
    substituteInPlace CMakeLists.txt \
      --replace-fail "project (mailcore2)" "project (mailcore2 C CXX OBJC OBJCXX)
    add_compile_options(\"$<$<COMPILE_LANGUAGE:C>:-xobjective-c>\" \"$<$<COMPILE_LANGUAGE:CXX>:-xobjective-c++>\")"

    # Fix old tidy header reference
    substituteInPlace src/core/basetypes/MCHTMLCleaner.cpp \
      --replace-fail "buffio.h" "tidybuffio.h"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    cyrus_sasl
    glib
    html-tidy
    icu
    libctemplate
    libsysprof-capture
    libuuid
    libxml2
    mailspring-libetpan
    openssl
    pcre2
    zlib
  ];

  # Only build the core library, mimicking ./build.sh
  buildFlags = [ "MailCore" ];

  # Prevent GCC 14 pointer errors
  env = {
    CFLAGS = toString [
      "-Wno-error=incompatible-pointer-types"
    ];

    CXXFLAGS = toString [
      "-std=gnu++17"
      "-Wno-error=incompatible-pointer-types"
    ];
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/include

    cp src/libMailCore.* $out/lib/

    cp -r src/include/MailCore $out/include/

    runHook postInstall
  '';

  sourceRoot = "${src.name}/mailsync/Vendor/mailcore2";

  meta = {
    description = "Modified fork of the mailcore2 asynchronous C++ framework";
    homepage = "https://github.com/Foundry376/Mailspring-Sync";
    license = lib.licenses.gpl3Plus;

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
