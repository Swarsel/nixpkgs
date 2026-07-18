{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  qcheck,
}:

buildDunePackage (finalAttrs: {
  pname = "qtest";
  version = "2.11.2";

  src = fetchFromGitHub {
    owner = "vincent-hugot";
    repo = "qtest";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-VLY8+Nu6md0szW4RVxTFwlSQ9kyrgUqf7wQEA6GW8BE=";
  };

  propagatedBuildInputs = [ qcheck ];

  preBuild = ''
    substituteInPlace src/dune \
      --replace "(libraries bytes)" "" \
      --replace "libraries qcheck ounit2 bytes" "libraries qcheck ounit2"
  '';

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Inline (Unit) Tests for OCaml";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ vbgl ];
    mainProgram = "qtest";
  };
})
