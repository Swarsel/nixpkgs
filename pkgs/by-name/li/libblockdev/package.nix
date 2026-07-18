{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  cryptsetup,
  docbook_xml_dtd_43,
  docbook_xsl,
  e2fsprogs,
  glib,
  gobject-introspection,
  gptfdisk,
  gtk-doc,
  json-glib,
  keyutils,
  kmod,
  libatasmart,
  libbytesize,
  libndctl,
  libnvme,
  libxslt,
  libyaml,
  lvm2,
  makeBinaryWrapper,
  nix-update-script,
  nss,
  parted,
  pkg-config,
  python3,
  thin-provisioning-tools,
  udev,
  util-linux,
  volume_key,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libblockdev";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "storaged-project";
    repo = "libblockdev";
    tag = finalAttrs.version;
    hash = "sha256-loll5MYRXBrBSSLCIXuQ0sQCpwSn7yS1Po9ppYnEorY=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
    "python"
  ];

  postPatch = ''
    patchShebangs scripts
    substituteInPlace src/python/gi/overrides/Makefile.am \
      --replace-fail ''\'''${exec_prefix}' '@PYTHON_EXEC_PREFIX@'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoconf-archive
    autoreconfHook
    docbook_xsl
    docbook_xml_dtd_43
    gobject-introspection
    gtk-doc
    libxslt
    makeBinaryWrapper
    pkg-config
    python3
  ];

  buildInputs = [
    cryptsetup
    e2fsprogs
    glib
    gptfdisk
    json-glib
    keyutils
    kmod
    libatasmart
    libbytesize
    libndctl
    libnvme
    libyaml
    lvm2
    nss
    parted
    udev
    util-linux
    volume_key
  ];

  configureFlags = [
    "--with-python_prefix=${placeholder "python"}"
  ];

  postInstall = ''
    wrapProgram $out/bin/lvm-cache-stats --prefix PATH : \
      ${lib.makeBinPath [ thin-provisioning-tools ]}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Library for manipulating block devices";
    homepage = "http://storaged.org/libblockdev/";
    changelog = "https://github.com/storaged-project/libblockdev/raw/${finalAttrs.src.tag}/NEWS.rst";

    license = with lib.licenses; [
      lgpl2Plus
      gpl2Plus
    ]; # lgpl2Plus for the library, gpl2Plus for the utils

    maintainers = with lib.maintainers; [ johnazoidberg ];
    platforms = lib.platforms.linux;
  };
})
