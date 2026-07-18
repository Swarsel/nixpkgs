{
  lib,
  stdenv,
  fetchFromGitLab,
  callPackage,
  glib,
  gmobile,
  gnome-desktop,
  gobject-introspection,
  gtk3,
  json-glib,
  libdrm,
  libinput,
  libxcb-wm,
  libxkbcommon,
  meson,
  mutter,
  ninja,
  nix-update-script,
  nixosTests,
  pkg-config,
  python3,
  stdenvNoCC,
  testers,
  wayland,
  wayland-scanner,
  wlroots_0_19,
  wrapGAppsHook3,
}:

let
  # Derived from subprojects/gvdb.wrap
  gvdb = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    # Workaround for https://github.com/NixOS/nixpkgs/issues/485701
    forceFetchGit = true;
    hash = "sha256-4mqoHPlrMPenoGPwDqbtv4/rJ/uq9Skcm82pRvOxNIk=";
    owner = "GNOME";
    repo = "gvdb";
    rev = "4758f6fb7f889e074e13df3f914328f3eecb1fd3";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "phoc";
  version = "0.54.0";

  src = fetchFromGitLab {
    owner = "Phosh";
    repo = "phoc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-P81D3gCC4Q1JQPUlAtLbMZdlVOPpJJ1/rLX7zijFcc0=";
    domain = "gitlab.gnome.org";
    # Workaround for https://github.com/NixOS/nixpkgs/issues/485701
    forceFetchGit = true;
    group = "World";
  };

  postPatch = ''
    ln -s ${gvdb} subprojects/gvdb
  '';

  nativeBuildInputs = [
    gobject-introspection
    meson
    ninja
    pkg-config
    python3
    wayland-scanner
    wrapGAppsHook3
  ];

  buildInputs = [
    libdrm.dev
    libxkbcommon
    libinput
    glib
    gtk3
    gnome-desktop
    # For keybindings settings schemas
    mutter
    json-glib
    wayland
    finalAttrs.wlroots
    libxcb-wm
    gmobile
  ];

  mesonFlags = [ "-Dembed-wlroots=disabled" ];

  # Patch wlroots to remove a check which crashes Phosh.
  # This patch can be found within the phoc source tree.
  wlroots = wlroots_0_19.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      (stdenvNoCC.mkDerivation {
        inherit (finalAttrs) src;
        installPhase = "cp subprojects/packagefiles/wlroots/$name $out";
        allowSubstitutes = false;
        name = "0001-Revert-layer-shell-error-on-0-dimension-without-anch.patch";
        preferLocalBuild = true;
      })
    ];
  });

  passthru = {
    tests.dependency-versions = callPackage ./test-dependency-versions.nix { inherit gvdb; };
    tests.phosh = nixosTests.phosh;

    tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Wayland compositor for mobile phones like the Librem 5";
    homepage = "https://gitlab.gnome.org/World/Phosh/phoc";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      zhaofengli
      armelclo
    ];

    platforms = lib.platforms.linux;
    mainProgram = "phoc";
  };
})
