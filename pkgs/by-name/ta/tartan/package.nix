{
  lib,
  stdenv,
  fetchFromGitLab,
  glib,
  gobject-introspection,
  llvmPackages_20,
  meson,
  ninja,
  pkg-config,
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "tartan";
  version = "0.3.0-unstable-2025-01-07";

  src = fetchFromGitLab {
    owner = "tartan";
    repo = "tartan";
    rev = "983aaf238946ced55da8824c1170a254992d9717";
    hash = "sha256-4w9cAs6kA+RAmi2CC+5CHB1UWC+7zkBqvZlHAdgENu4=";
    domain = "gitlab.freedesktop.org";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    gobject-introspection
    glib
    # https://gitlab.freedesktop.org/tartan/tartan/-/merge_requests/29
    llvmPackages_20.libclang
    llvmPackages_20.libllvm
  ];

  passthru = {
    updateScript = unstableGitUpdater {
      # The updater tries src.url by default, which does not exist for fetchFromGitLab (fetchurl).
      url = "https://gitlab.freedesktop.org/tartan/tartan.git";
    };
  };

  meta = {
    description = "Tools and Clang plugins for developing code with GLib";
    homepage = "https://gitlab.freedesktop.org/tartan/tartan";
    changelog = "https://gitlab.freedesktop.org/tartan/tartan/-/blob/main/NEWS";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ jtojnar ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
  };
}
