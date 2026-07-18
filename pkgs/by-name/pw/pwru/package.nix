{
  lib,
  fetchFromGitHub,
  buildGoModule,
  clang,
  libpcap,
}:

buildGoModule (finalAttrs: {
  pname = "pwru";
  version = "1.0.12";

  src = fetchFromGitHub {
    owner = "cilium";
    repo = "pwru";
    tag = "v${finalAttrs.version}";
    hash = "sha256-U7xDjurLVX46cLjjKiWBtx1rKZ3CarWXaSXvuJpnejg=";
  };

  postPatch = ''
    substituteInPlace internal/libpcap/compile.go \
      --replace "-static" ""
  '';

  nativeBuildInputs = [ clang ];
  buildInputs = [ libpcap ];
  vendorHash = null;

  preBuild = ''
    TARGET_GOARCH="$GOARCH" GOOS= GOARCH= go generate
  '';

  # this breaks go generate as bpf does not support -fzero-call-used-regs=used-gpr
  hardeningDisable = [ "zerocallusedregs" ];

  ldflags = [
    "-X github.com/cilium/pwru/internal/pwru.Version=v${finalAttrs.version}"
  ];

  subPackages = [ "." ];

  meta = {
    description = "eBPF-based Linux kernel networking debugger";
    homepage = "https://github.com/cilium/pwru";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      nickcao
      miniharinn
    ];

    platforms = lib.platforms.linux;
    mainProgram = "pwru";
  };
})
