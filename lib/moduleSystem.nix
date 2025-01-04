{
  lib,
  r,
  ...
}:
let
  _empty_list = [ ];
in
{
  # known magic from @balsoft flake.nix...
  # some function for <dir: path>
  findModules =
    dir:
    # magic
    builtins.concatLists (
      # magic
      builtins.attrValues (
        # apply first function to every elem of readdir
        builtins.mapAttrs (
          name:
          # filename
          type:
          # filetype: regular, directory, symlink, unknown
          # if just a simple file - remove .nix and add it to path
          if type == "regular" then
            if (builtins.match "(.*)\\.nix" name) != null then
              [
                {
                  # but check, is it really .nix file...
                  name = builtins.elemAt (builtins.match "(.*)\\.nix" name) 0;
                  value = dir + "/${name}";
                }
              ]
            else
              _empty_list
          # if it directory
          else if type == "directory" then
            if (builtins.readDir (dir + "/${name}")) ? "default.nix" then
              [
                {
                  # if contains default.nix - load it
                  inherit name;
                  value = dir + "/${name}";
                }
              ]
            else
              # else just recursive load
              r.findModules (dir + "/${name}")
          else
            _empty_list
        ) (builtins.readDir dir)
      )
    );

  findModulesV2 =
    dir:
    lib.mapAttrs' (
      name:
      # filename
      type:
      # filetype: regular, directory, symlink, unknown
      # if just a simple file - remove .nix and add it to path
      if type == "regular" then
        if (builtins.match "(.*)\\.nix" name) != null then
          {
            # but check, is it really .nix file...
            name = builtins.elemAt (builtins.match "(.*)\\.nix" name) 0;
            value = dir + "/${name}";
          }
        else
          {
            inherit name;
            value = "${name}: is not a nix file";
          }
      # if it directory
      else if type == "directory" then
        if (builtins.readDir (dir + "/${name}")) ? "default.nix" then
          {
            # if contains default.nix - load it
            inherit name;
            value = dir + "/${name}";
          }
        else
          # else just recursive load
          {
            inherit name;
            value = r.findModulesV2 (dir + "/${name}");
          }
      else
        {
          inherit name;
          value = "${name}: unknown file type: ${type}";
        }
    ) (builtins.readDir dir);
}
