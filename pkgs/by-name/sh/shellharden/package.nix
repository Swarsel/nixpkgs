{
  lib,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "shellharden";
  version = "4.3.2";

  src = fetchFromGitHub {
    owner = "anordal";
    repo = "shellharden";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-brDqAxY36dl0xSDgzovq/mqvw3eRy+vkuLQozqPsDlc=";
  };

  postPatch = "patchShebangs moduletests/run";
  cargoHash = "sha256-RE1k9G3xKTJ0F79bKrhgS+5O30eqVnA3iLCc+CHfS2Y=";

  meta = {
    description = "Corrective bash syntax highlighter";

    longDescription = ''
      Shellharden is a syntax highlighter and a tool to semi-automate the
      rewriting of scripts to ShellCheck conformance, mainly focused on quoting.
    '';

    homepage = "https://github.com/anordal/shellharden";
    license = lib.licenses.mpl20;
    maintainers = [ ];
    mainProgram = "shellharden";
  };
})
