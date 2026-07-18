{
  lib,
  stdenv,
  fetchFromGitLab,
  accountsservice,
  coreutils,
  dbus,
  glib,
  glib-testing,
  gobject-introspection,
  malcontent-ui,
  meson,
  ninja,
  nixosTests,
  pam,
  pkg-config,
  polkit,
  python3,
  wrapGAppsNoGuiHook,
}:

stdenv.mkDerivation rec {
  pname = "malcontent";
  version = "0.13.1";

  src = fetchFromGitLab {
    owner = "pwithnall";
    repo = "malcontent";
    rev = version;
    hash = "sha256-ekRi4yXu8u8t1AjyS3bD6tdqqnqtKyI6yZs+28LnfRY=";
    domain = "gitlab.freedesktop.org";
  };

  outputs = [
    "bin"
    "out"
    "lib"
    "pam"
    "dev"
    "man"
    "installedTests"
  ];

  patches = [
    # Allow installing installed tests to a separate output.
    ./installed-tests-path.patch

    # Do not build things that are part of malcontent-ui package
    ./better-separation.patch
  ];

  postPatch = ''
    substituteInPlace libmalcontent/tests/app-filter.c \
      --replace-fail "/usr/bin/true" "${coreutils}/bin/true" \
      --replace-fail "/bin/true" "${coreutils}/bin/true" \
      --replace-fail "/usr/bin/false" "${coreutils}/bin/false" \
      --replace-fail "/bin/false" "${coreutils}/bin/false"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gobject-introspection
    wrapGAppsNoGuiHook
  ];

  buildInputs = [
    accountsservice
    dbus
    pam
    polkit
    glib-testing
    (python3.withPackages (
      pp: with pp; [
        pygobject3
      ]
    ))
  ];

  propagatedBuildInputs = [
    glib
  ];

  mesonFlags = [
    "-Dinstalled_tests=true"
    "-Dinstalled_test_prefix=${placeholder "installedTests"}"
    "-Dpamlibdir=${placeholder "pam"}/lib/security"
    "-Dui=disabled"
  ];

  postInstall = ''
    # `giDiscoverSelf` only picks up paths in `out` output.
    # This needs to be in `postInstall` so that it runs before
    # `gappsWrapperArgsHook` that runs as one of `preFixupPhases`.
    addToSearchPath GI_TYPELIB_PATH "$lib/lib/girepository-1.0"
  '';

  passthru = {
    tests = {
      inherit malcontent-ui;
      installedTests = nixosTests.installed-tests.malcontent;
    };
  };

  meta = {
    inherit (polkit.meta) platforms badPlatforms;
    description = "Parental controls library";
    homepage = "https://gitlab.freedesktop.org/pwithnall/malcontent";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ jtojnar ];
    mainProgram = "malcontent-client";

    # We need to install Polkit & AccountsService data files in `out`
    # but `buildEnv` only uses `bin` when both `bin` and `out` are present.
    outputsToInstall = [
      "bin"
      "out"
      "man"
    ];
  };
}
