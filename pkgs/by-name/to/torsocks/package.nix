{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  fetchpatch,
  libcap,
  nix-update-script,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "torsocks";
  version = "2.5.0";

  src = fetchFromGitLab {
    owner = "core";
    repo = "torsocks";
    tag = "v${finalAttrs.version}";
    hash = "sha256-um5D6d/fzKynfa1kA/VbdnKvAlZ7jQs+pmOgWQMpwgM=";
    domain = "gitlab.torproject.org";
    group = "tpo";
  };

  patches = [
    # tsocks_libc_accept4 only exists on Linux, use tsocks_libc_accept on other platforms
    (fetchpatch {
      hash = "sha256-XWi8+UFB8XgBFSl5QDJ+hLu/dH4CvAwYbeZz7KB10Bs=";
      url = "https://gitlab.torproject.org/tpo/core/torsocks/uploads/eeec9833512850306a42a0890d283d77/0001-Fix-macros-for-accept4-2.patch";
    })
    # no gethostbyaddr_r on darwin
    ./torsocks-gethostbyaddr-darwin.patch
  ];

  postPatch = lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace src/bin/torsocks.in --replace-fail \
    '"$(PATH="$PATH:/usr/sbin:/sbin" command -v getcap)"' '${libcap}/bin/getcap'
  '';

  nativeBuildInputs = [ autoreconfHook ];
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  installCheckTarget = "check-recursive";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Wrapper to safely torify applications";
    homepage = "https://gitlab.torproject.org/tpo/core/torsocks";
    changelog = "https://gitlab.torproject.org/tpo/core/torsocks/-/releases/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ thoughtpolice ];
    platforms = lib.platforms.unix;
    mainProgram = "torsocks";
  };
})
