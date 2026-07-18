{
  lib,
  buildPecl,
  pcre2,
}:

buildPecl {
  pname = "protobuf";
  version = "3.21.9";
  buildInputs = [ pcre2 ];
  sha256 = "05zlq9k6c45wj1286850nl31024ik158jnj1f5kskr1pchknnsf3";

  meta = {
    description = "Google's language-neutral, platform-neutral, extensible mechanism for serializing structured data";
    homepage = "https://developers.google.com/protocol-buffers/";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.php ];
  };
}
