{
  lib,
  fetchFromGitLab,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "deqp-runner";
  version = "0.18.0";

  src = fetchFromGitLab {
    owner = "anholt";
    repo = "deqp-runner";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5ngyONV7X3JyU0Kd7VE8XGgsAMb9OCSrZuAuFIbQjgs=";
    domain = "gitlab.freedesktop.org";
  };

  cargoHash = "sha256-rVYRbaj+9nFVyo9Zjdmd5t7CoFfxtntXIW2bWp2L7DE=";

  meta = {
    description = "VK-GL-CTS/dEQP wrapper program to parallelize it across CPUs and report results against a baseline";
    homepage = "https://gitlab.freedesktop.org/anholt/deqp-runner";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
