{
  lib,
  fetchFromGitea,
  fetchpatch,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bootspec-lix";
  version = "1.0.0";

  src = fetchFromGitea {
    owner = "lix-community";
    repo = "bootspec";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5IGSMHeL0eKfl7teDejAckYQjc8aeLwfwIQSzQ8YaAg=";
    domain = "git.lix.systems";
  };

  patches = [
    # https://github.com/DeterminateSystems/bootspec/pull/127
    # Fixes the synthesize tool for aarch64-linux
    (fetchpatch {
      name = "aarch64-support.patch";
      sha256 = "sha256-wU/jWnOqVBrU2swANdXbQfzRpNd/JIS4cxSyCvixZM0=";
      url = "https://github.com/DeterminateSystems/bootspec/commit/1d0e925f360f0199f13422fb7541225fd162fd4f.patch";
    })
  ];

  cargoHash = "sha256-65jk8UlXZgQoxuwRcGlMnI4e+LpCJuP2TaqK+Kn4GnQ=";

  meta = {
    description = "Vendor-neutral implementation of RFC-0125's datatype and synthesis tooling";
    homepage = "https://git.lix.systems/lix-community/bootspec";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.raitobezarius ];
    platforms = lib.platforms.unix;
  };
})
