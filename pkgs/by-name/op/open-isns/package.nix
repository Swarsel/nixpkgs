{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  openssl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "open-isns";
  version = "0.103";

  src = fetchFromGitHub {
    owner = "open-iscsi";
    repo = "open-isns";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-buqQMsoxRCbWiBDq0XAg93J7bjbdxeIernV8sDVxCAA=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
    "man"
  ];

  # The location of /var/lib is not made configurable in the meson.build file
  postPatch = ''
    substituteInPlace meson.build \
        --replace-fail "/var/lib" "$out/var/lib"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  propagatedBuildInputs = [ openssl ];
  configureFlags = [ "--enable-shared" ];

  mesonFlags = [
    "-Dslp=disabled" # openslp is not maintained and labeled unsafe
    "-Dsystemddir=${placeholder "out"}/lib/systemd"
  ];

  meta = {
    description = "iSNS server and client for Linux";
    homepage = "https://github.com/open-iscsi/open-isns";
    license = lib.licenses.lgpl21Only;
    maintainers = [ lib.maintainers.markuskowa ];
    platforms = lib.platforms.linux;
  };
})
