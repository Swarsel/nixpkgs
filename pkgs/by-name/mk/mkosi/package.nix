{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  btrfs-progs,
  coreutils,
  cpio,
  gnutar,
  kmod,
  libseccomp,
  pandoc,
  python3Packages,
  qemu,
  replaceVars,
  systemd,
  udevCheckHook,
  util-linux,
  # Workaround for supporting providing additional package manager
  # dependencies in the recursive use in the binary path.
  # This can / should be removed once the `finalAttrs` pattern is
  # available for Python packages.
  extraDeps ? [ ],
  # Optional dependencies
  withQemu ? false,
}:
let
  # For systemd features used by mkosi, see
  # https://github.com/systemd/mkosi/blob/19bb5e274d9a9c23891905c4bcbb8f68955a701d/action.yaml#L64-L72
  systemdForMkosi = systemd.override {
    withBootloader = true;
    withEfi = true;
    withFirstboot = true;
    withKernelInstall = true;
    withRepart = true;
    withSysusers = true;
    withUkify = true;
  };

  pythonWithPefile = python3Packages.python.withPackages (ps: [ ps.pefile ]);

  deps = [
    bash
    btrfs-progs
    coreutils
    cpio
    gnutar
    kmod
    systemdForMkosi
    util-linux
  ]
  ++ extraDeps
  ++ lib.optionals withQemu [
    qemu
  ];
in
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mkosi";
  version = "26";

  src = fetchFromGitHub {
    owner = "systemd";
    repo = "mkosi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-6DVIyFsEV2VkQ/kesn6cN+iH9MW+mmAZw5i0R5C4xaU=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    (replaceVars ./0001-Use-wrapped-binaries-instead-of-Python-interpreter.patch {
      MKOSI_SANDBOX = null; # will be replaced in postPatch
      NIX_PATH = toString (lib.makeBinPath deps);
      PYTHON_PEFILE = lib.getExe pythonWithPefile;
      UKIFY = "${systemdForMkosi}/lib/systemd/ukify";
    })
    (replaceVars ./0002-Fix-library-resolving.patch {
      LIBC = "${stdenv.cc.libc}/lib/libc.so.6";
      LIBSECCOMP = "${libseccomp.lib}/lib/libseccomp.so.2";
    })
  ]
  ++ lib.optional withQemu (
    replaceVars ./0003-Fix-QEMU-firmware-path.patch {
      QEMU_FIRMWARE = "${qemu}/share/qemu/firmware";
    }
  );

  postPatch = ''
    # As we need the $out reference, we can't use `replaceVars` here.
    substituteInPlace mkosi/{run,__init__}.py \
      --replace-fail '@MKOSI_SANDBOX@' "$out/bin/mkosi-sandbox"
  '';

  nativeBuildInputs = [
    pandoc
    python3Packages.setuptools
    python3Packages.setuptools-scm
    python3Packages.wheel
    udevCheckHook
  ];

  postBuild = ''
    ./tools/make-man-page.sh
  '';

  checkInputs = [
    python3Packages.pytestCheckHook
  ];

  postInstall = ''
    mkdir -p $out/share/man/man1
    mv mkosi/resources/man/mkosi.1 $out/share/man/man1/
  '';

  dependencies = deps;
  pyproject = true;

  meta = {
    description = "Build legacy-free OS images";
    homepage = "https://github.com/systemd/mkosi";
    changelog = "https://github.com/systemd/mkosi/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl21Only;

    maintainers = with lib.maintainers; [
      malt3
      msanft
    ];

    platforms = lib.platforms.linux;
    mainProgram = "mkosi";
  };
})
