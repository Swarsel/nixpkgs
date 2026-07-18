{
  lib,
  stdenv,
  fetchFromGitLab,
  libcap_ng,
  libseccomp,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "virtiofsd";
  version = "1.14.0";

  src = fetchFromGitLab {
    owner = "virtio-fs";
    repo = "virtiofsd";
    rev = "v${finalAttrs.version}";
    hash = "sha256-NeqeSqPeD3hjAcbck+g8bmarbUL1Nks8AMAi/WxwzwY=";
  };

  buildInputs = [
    libcap_ng
    libseccomp
  ];

  cargoHash = "sha256-7byiMT2/jf0R7zHr/HBeXKk2T+OQhlVhZ9QJHlEY/Ao=";

  env = {
    LIBCAPNG_LIB_PATH = "${lib.getLib libcap_ng}/lib";
    LIBCAPNG_LINK_TYPE = if stdenv.hostPlatform.isStatic then "static" else "dylib";
  };

  postConfigure = ''
    sed -i "s|/usr/libexec|$out/bin|g" 50-virtiofsd.json
  '';

  postInstall = ''
    install -Dm644 50-virtiofsd.json "$out/share/qemu/vhost-user/50-virtiofsd.json"
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  separateDebugInfo = true;

  meta = {
    description = "vhost-user virtio-fs device backend written in Rust";
    homepage = "https://gitlab.com/virtio-fs/virtiofsd";
    changelog = "https://gitlab.com/virtio-fs/virtiofsd/-/releases/v${finalAttrs.version}";

    license = with lib.licenses; [
      asl20 # and
      bsd3
    ];

    maintainers = with lib.maintainers; [
      qyliss
      astro
    ];

    platforms = lib.platforms.linux;
    mainProgram = "virtiofsd";
  };
})
