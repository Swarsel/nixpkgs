{
  lib,
  buildRubyGem,
  ruby,
}:

buildRubyGem rec {
  inherit ruby;
  version = "6.0.0";
  gemName = "gist";
  name = "${gemName}-${version}";
  source.sha256 = "0qnd1jqd7b04871v4l73grcmi7c0pivm8nsfrqvwivm4n4b3c2hd";

  meta = {
    description = "Upload code to https://gist.github.com (or github enterprise)";
    homepage = "http://defunkt.io/gist/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zimbatm ];
    platforms = ruby.meta.platforms;
  };
}
