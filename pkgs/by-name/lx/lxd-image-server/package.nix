{
  lib,
  fetchFromGitHub,
  nixosTests,
  openssl,
  python3,
  rsync,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "lxd-image-server";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "Avature";
    repo = "lxd-image-server";
    rev = finalAttrs.version;
    sha256 = "yx8aUmMfSzyWaM6M7+WcL6ouuWwOpqLzODWSdNgwCwo=";
  };

  patches = [
    ./state.patch
    ./run.patch
  ];

  doCheck = false;

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    setuptools # pkg_resources is imported during runtime
    attrs
    click
    inotify
    cryptography
    confight
    python-pidfile
  ];

  makeWrapperArgs = [
    ''--prefix PATH ':' "${
      lib.makeBinPath [
        openssl
        rsync
      ]
    }"''
  ];

  pyproject = true;
  pythonImportsCheck = [ "lxd_image_server" ];
  passthru.tests.lxd-image-server = nixosTests.lxd-image-server;

  meta = {
    description = "Creates and manages a simplestreams lxd image server on top of nginx";
    homepage = "https://github.com/Avature/lxd-image-server";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mkg20001 ];
    platforms = lib.platforms.unix;
    mainProgram = "lxd-image-server";
  };
})
