{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  coreutils,
  getopt,
  gnused,
  libcap,
  nixosTests,
  po4a,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fakeroot";
  version = "1.38.1";

  src = fetchFromGitLab {
    owner = "clint";
    repo = "fakeroot";
    tag = "upstream/${finalAttrs.version}";
    hash = "sha256-sAzXeONjDT753lbu7amQY6yXpaTNCa4wFOzB01SRbCs=";
    domain = "salsa.debian.org";
  };

  patches = lib.optionals stdenv.hostPlatform.isLinux [
    ./add-missing-wrapawk.patch
    ./einval.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    po4a
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ libcap ];

  postConfigure = ''
    pushd doc
    po4a -k 0 --variable "srcdir=../doc/" po4a/po4a.cfg
    popd
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  postUnpack = ''
    sed -i \
      -e 's@getopt@${getopt}/bin/getopt@g' \
      -e 's@sed@${gnused}/bin/sed@g' \
      -e 's@kill@${coreutils}/bin/kill@g' \
      -e 's@/bin/ls@${coreutils}/bin/ls@g' \
      -e 's@cut@${coreutils}/bin/cut@g' \
      source/scripts/fakeroot.in
  '';

  passthru = {
    tests = {
      # A lightweight *unit* test that exercises fakeroot and fakechroot together:
      nixos-etc = nixosTests.etc.test-etc-fakeroot;
    };
  };

  meta = {
    description = "Give a fake root environment through LD_PRELOAD";
    homepage = "https://salsa.debian.org/clint/fakeroot";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "fakeroot";
  };
})
