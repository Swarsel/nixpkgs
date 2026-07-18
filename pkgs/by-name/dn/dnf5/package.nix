{
  lib,
  stdenv,
  fetchFromGitHub,
  acl,
  appstream,
  cmake,
  cppunit,
  createrepo_c,
  doxygen,
  fmt,
  gettext,
  help2man,
  json_c,
  libmodulemd,
  libpkgmanifest,
  librepo,
  libsolv,
  libxml2,
  libyaml,
  nix-update-script,
  pcre2,
  pkg-config,
  python3Packages,
  rpm,
  sdbus-cpp_2,
  sphinx,
  sqlite,
  systemd,
  toml11,
  util-linux,
  versionCheckHook,
  zchunk,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dnf5";
  version = "5.4.2.1";

  src = fetchFromGitHub {
    owner = "rpm-software-management";
    repo = "dnf5";
    tag = finalAttrs.version;
    hash = "sha256-Z+k47LC3gaBQ3y3090MLsSvPKlwPUVrYEBboKhskTik=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    cmake
    createrepo_c
    doxygen
    gettext
    help2man
    pkg-config
    sphinx
  ]
  ++ (with python3Packages; [
    breathe
    sphinx-autoapi
    sphinx-rtd-theme
  ]);

  buildInputs = [
    appstream
    cppunit
    fmt
    json_c
    libmodulemd
    librepo
    util-linux
    libsolv
    libpkgmanifest
    acl
    libxml2
    libyaml
    pcre2.dev
    rpm
    sdbus-cpp_2
    sqlite
    systemd
    toml11
    zchunk
  ];

  cmakeFlags = [
    (lib.cmakeBool "WITH_PERL5" false)
    (lib.cmakeBool "WITH_PYTHON3" false)
    (lib.cmakeBool "WITH_RUBY" false)
    (lib.cmakeBool "WITH_SYSTEMD" false)
    (lib.cmakeBool "WITH_PLUGIN_RHSM" false) # Red Hat Subscription Manager plugin
    # the cmake package does not handle absolute CMAKE_INSTALL_INCLUDEDIR correctly
    # (setting it to an absolute path causes include files to go to $out/$out/include,
    #  because the absolute path is interpreted with root at $out).
    (lib.cmakeFeature "CMAKE_INSTALL_INCLUDEDIR" "include")
    (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
  ];

  # workaround for https://gcc.gnu.org/bugzilla/show_bug.cgi?id=105329
  env.NIX_CFLAGS_COMPILE = "-Wno-restrict -Wno-maybe-uninitialized";

  postBuild = ''
    make doc
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  prePatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "/usr/lib/systemd/system" "$out/lib/systemd/system"
    substituteInPlace dnf5daemon-server/dbus/CMakeLists.txt \
      --replace-fail "/usr" "$out"
    substituteInPlace dnf5daemon-server/polkit/CMakeLists.txt \
      --replace-fail "/usr" "$out"
    substituteInPlace dnf5/CMakeLists.txt \
      --replace-fail "/etc/bash_completion.d" "$out/etc/bash_completion.d"
  '';

  preVersionCheck = ''
    export HOME=$(mktemp -d)
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Next-generation RPM package management system";
    homepage = "https://github.com/rpm-software-management/dnf5";
    changelog = "https://github.com/rpm-software-management/dnf5/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      malt3
      katexochen
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "dnf5";
  };
})
