{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  runc,
  wrapperDir ? "/run/wrappers/bin", # Default for NixOS, other systems might need customization.
}:

buildGoModule (finalAttrs: {
  pname = "img";
  version = "0.5.11";

  src = fetchFromGitHub {
    owner = "genuinetools";
    repo = "img";
    rev = "v${finalAttrs.version}";
    sha256 = "0r5hihzp2679ki9hr3p0f085rafy2hc8kpkdhnd4m5k4iibqib08";
  };

  postPatch = ''
    V={newgidmap,newgidmap} \
      substituteInPlace ./internal/unshare/unshare.c \
        --replace "/usr/bin/$V" "${wrapperDir}/$V"
  '';

  nativeBuildInputs = [
    makeWrapper
  ];

  vendorHash = null;
  # Tests fail as: internal/binutils/install.go:57:15: undefined: Asset
  doCheck = false;

  postInstall = ''
    wrapProgram "$out/bin/img" --prefix PATH : ${lib.makeBinPath [ runc ]}
  '';

  ldflags = [
    "-X github.com/genuinetools/img/version.VERSION=v${finalAttrs.version}"
    "-s -w"
  ];

  tags = [
    "seccomp"
    "noembed" # disables embedded `runc`
  ];

  meta = {
    description = "Standalone, daemon-less, unprivileged Dockerfile and OCI compatible container image builder";
    homepage = "https://github.com/genuinetools/img";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "img";
  };
})
