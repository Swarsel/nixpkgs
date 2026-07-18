{
  lua,
  toLuaModule,
  writeText,
}:

{
  makeFlags ? [ ],
  propagatedBuildInputs ? [ ],
  ...
}@attrs:

toLuaModule (
  lua.stdenv.mkDerivation (
    attrs
    // {
      propagatedBuildInputs = propagatedBuildInputs ++ [
        lua # propagate it for its setup-hook
      ];

      makeFlags = [
        "PREFIX=$(out)"
        "LUA_INC=-I${lua}/include"
        "LUA_LIBDIR=$(out)/lib/lua/${lua.luaversion}"
        "LUA_VERSION=${lua.luaversion}"
      ]
      ++ makeFlags;

      name = "lua${lua.luaversion}-" + attrs.pname + "-" + attrs.version;
    }
  )
)
