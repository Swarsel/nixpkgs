{
  lib,
  fetchFromGitHub,
  buildGoModule,
  containerd,
  fetchpatch,
}:

buildGoModule (finalAttrs: {
  pname = "nomad-driver-containerd";
  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "Roblox";
    repo = "nomad-driver-containerd";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-11K1ACk2hhEi+sAlI932eKpyy82Md7j1edRWH2JJ8sI=";
  };

  # bump deps to fix CVE that isn't in a tagged release yet
  patches = [
    (fetchpatch {
      hash = "sha256-d4C/YwemmZQAt0fTAnQkJVKn8cK4kmxB+wQEHycdn9U=";
      url = "https://github.com/Roblox/nomad-driver-containerd/commit/80b9be1353f701b9d47d874923a9e8ffed4dbd98.patch";
    })
    (fetchpatch {
      hash = "sha256-W8ZOKMkv1814cPNyqTaXUGhh44WfMizZNL4cNX+FOqg=";
      url = "https://github.com/Roblox/nomad-driver-containerd/commit/cc0da224669a8f85a8b695288fe5ea748fb270c2.patch";
    })
  ];

  # replace version in file as it's defined using const, and thus cannot be overridden by ldflags
  postPatch = ''
    substituteInPlace containerd/driver.go --replace-warn 'PluginVersion = "v0.9.3"' 'PluginVersion = "v${finalAttrs.version}"'
  '';

  buildInputs = [ containerd ];
  vendorHash = "sha256-OO+a5AqhB0tf6lyodhYl9HUSaWvtXWwevRHYy1Q6VoU=";
  env.CGO_ENABLED = "1";

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "." ];

  meta = {
    description = "Containerd task driver for Nomad";
    homepage = "https://www.github.com/Roblox/nomad-driver-containerd";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ techknowlogick ];
    platforms = lib.platforms.linux;
    mainProgram = "nomad-driver-containerd";
  };
})
