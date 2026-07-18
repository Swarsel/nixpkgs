{
  lib,
  fetchFromGitHub,
  clang,
  elfutils,
  pkg-config,
  rustPlatform,
  rustfmt,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "below";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "facebookincubator";
    repo = "below";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Paf3+aVsJpC8wyNqszCp3y5qQS8LEAyXvJBp9VG4uFM=";
  };

  nativeBuildInputs = [
    clang
    pkg-config
    rustfmt
  ];

  buildInputs = [
    elfutils
    zlib
  ];

  cargoHash = "sha256-8+8mBbQSFPcjfBB7y+dgyno+EW82ojhPNxx836gCMik=";
  # needs /sys/fs/cgroup
  doCheck = false;

  postInstall = ''
    install -d $out/lib/systemd/system
    install -t $out/lib/systemd/system etc/below.service
  '';

  # bpf code compilation
  hardeningDisable = [
    "stackprotector"
    "zerocallusedregs"
  ];

  prePatch = ''
    sed -i "s,ExecStart=.*/bin,ExecStart=$out/bin," etc/below.service
  '';

  meta = {
    description = "Time traveling resource monitor for modern Linux systems";
    homepage = "https://github.com/facebookincubator/below";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ globin ];
    platforms = lib.platforms.linux;
    mainProgram = "below";
  };
})
