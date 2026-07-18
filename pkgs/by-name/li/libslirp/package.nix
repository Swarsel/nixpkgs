{
  lib,
  stdenv,
  fetchFromGitLab,
  glib,
  meson,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libslirp";
  version = "4.9.3";

  src = fetchFromGitLab {
    owner = "slirp";
    repo = "libslirp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Spr3dO5ehuUlzx3EnJi8najANWOirwQcTsWTVRVXYuY=";
    domain = "gitlab.freedesktop.org";
  };

  postPatch = ''
    echo ${finalAttrs.version} > .tarball-version
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [ glib ];
  separateDebugInfo = true;

  meta = {
    description = "General purpose TCP-IP emulator";
    homepage = "https://gitlab.freedesktop.org/slirp/libslirp";
    changelog = "https://gitlab.freedesktop.org/slirp/libslirp/-/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
