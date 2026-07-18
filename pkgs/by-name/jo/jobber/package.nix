{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gotools,
}:

buildGoModule (finalAttrs: {
  pname = "jobber";
  version = "1.4.4";

  src = fetchFromGitHub {
    owner = "dshearer";
    repo = "jobber";
    rev = "v${finalAttrs.version}";
    hash = "sha256-mLYyrscvT/VK9ehwkPUq4RbwHb+6Wjvt7ZXk/fI0HT4=";
  };

  nativeBuildInputs = [ gotools ];
  vendorHash = null;
  postConfigure = "go generate ./...";

  postInstall = ''
    mkdir -p $out/etc $out/libexec
    $out/bin/jobbermaster defprefs --libexec $out/libexec > $out/etc/jobber.conf
    mv $out/bin/jobber{master,runner} $out/libexec/
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/dshearer/jobber/common.jobberVersion=${finalAttrs.version}"
    "-X github.com/dshearer/jobber/common.etcDirPath=${placeholder "out"}/etc"
  ];

  meta = {
    description = "Alternative to cron, with sophisticated status-reporting and error-handling";
    homepage = "https://dshearer.github.io/jobber";
    changelog = "https://github.com/dshearer/jobber/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "jobber";
  };
})
