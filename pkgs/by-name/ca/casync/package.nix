{
  lib,
  stdenv,
  fetchFromGitHub,
  acl,
  curl,
  fuse,
  glibcLocales,
  libselinux,
  meson,
  ninja,
  pkg-config,
  python3,
  rsync,
  sphinx,
  udev,
  udevCheckHook,
  xz,
  zstd,
  fuseSupport ? true,
  selinuxSupport ? true,
  udevSupport ? true,
}:

stdenv.mkDerivation {
  pname = "casync";
  version = "2-unstable-2023-10-16";

  src = fetchFromGitHub {
    owner = "systemd";
    repo = "casync";
    rev = "e6817a79d89b48e1c6083fb1868a28f1afb32505";
    hash = "sha256-L7I80kSG4/ES2tGvHHgvOxJZzF76yeqy2WquKCPhnFk=";
  };

  postPatch = ''
    for f in test/test-*.sh.in; do
      patchShebangs $f
    done
    patchShebangs test/http-server.py
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
    sphinx
  ];

  buildInputs = [
    acl
    curl
    xz
    zstd
  ]
  ++ lib.optionals fuseSupport [ fuse ]
  ++ lib.optionals selinuxSupport [ libselinux ]
  ++ lib.optionals udevSupport [ udev ];

  mesonFlags =
    lib.optionals (!fuseSupport) [ "-Dfuse=false" ]
    ++ lib.optionals (!udevSupport) [ "-Dudev=false" ]
    ++ lib.optionals (!selinuxSupport) [ "-Dselinux=false" ];

  env.PKG_CONFIG_UDEV_UDEVDIR = "lib/udev";
  doCheck = true;

  nativeCheckInputs = [
    glibcLocales
    rsync
  ]
  ++ lib.optionals udevSupport [
    udevCheckHook
  ];

  preCheck = ''
    export LC_ALL="en_US.utf-8"
  '';

  doInstallCheck = true;

  meta = {
    description = "Content-Addressable Data Synchronizer";
    homepage = "https://github.com/systemd/casync";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ flokli ];
    platforms = lib.platforms.linux;
    mainProgram = "casync";
  };
}
