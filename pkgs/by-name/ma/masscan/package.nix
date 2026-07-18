{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  installShellFiles,
  libpcap,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "masscan";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "robertdavidgraham";
    repo = "masscan";
    rev = finalAttrs.version;
    sha256 = "sha256-mnGC/moQANloR5ODwRjzJzBa55OEZ9QU+9WpAHxQE/g=";
  };

  patches = [
    # Patches the missing "--resume" functionality
    (fetchpatch {
      name = "resume.patch";
      sha256 = "sha256-A7Fk3MBNxaad69MrUYg7fdMG77wba5iESDTIRigYslw=";
      url = "https://github.com/robertdavidgraham/masscan/commit/90791550bbdfac8905917a109ed74024161f14b3.patch";
    })
  ];

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Fix broken install command
    substituteInPlace Makefile --replace "-pm755" "-pDm755"
  '';

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "GITVER=${finalAttrs.version}"
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  postInstall = ''
    installManPage doc/masscan.?

    install -Dm444 -t $out/etc/masscan            data/exclude.conf
    install -Dm444 -t $out/share/doc/masscan      doc/*.{html,js,md}
    install -Dm444 -t $out/share/licenses/masscan LICENSE

    wrapProgram $out/bin/masscan \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libpcap ]}"
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/masscan --selftest
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Fast scan of the Internet";
    homepage = "https://github.com/robertdavidgraham/masscan";
    changelog = "https://github.com/robertdavidgraham/masscan/releases/tag/${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ rnhmjoj ];
    platforms = lib.platforms.unix;
    mainProgram = "masscan";
  };
})
