local debugger = {}

local ui

function debugger.init(ui_)
   ui = ui_
end

local function make_tree(tv, tk, out, upvs, seen)
   out = out or {}
   seen = seen or {}
   upvs = upvs or out
   if type(tv) == "table" then
      if seen[tv] then
         return nil
      end
      seen[tv] = true

      local r
      if tk then
         r = {}
         out[tk] = r
      else
         r = out
      end
      for k, v in pairs(tv) do
         make_tree(v, k, r, upvs, seen)
      end
   elseif type(tv) == "function" then
      if seen[tv] then
         return nil
      end
      seen[tv] = true

      out[tk] = tv
      local i = 1
      while true do
         local uk, uv = debug.getupvalue(tv, i)
         if uk == nil then
            break
         end
         if uv == nil then
            uv = "nil"
         end
         if uk ~= "_ENV" then
            make_tree(uv, "(upvalue) " .. uk, upvs, upvs, seen)
         end
         i = i + 1
      end
   else
      out[tk] = tv
   end
   seen[tv] = nil
   return out
end

function debugger.eval(cell)
   local prompt = ui.below(cell, "prompt")
   local _, arg = prompt.text:match("^%s*([^%s]+)%s*(.-)%s*$")

   local name, root
   if arg and package.loaded[arg] then
      name = arg
      root = package.loaded[arg]
   else
      name = "_G"
      root = _G
   end

   prompt:set(name)

   cell:remove_n_children_at(1, 2)
   cell:add_child(ui.tree({
      name = "tree",
      min_w = 492,
      max_w = 492,
      max_h = 400,
      spacing = 4,
      fill = 0x222222,
      border = 0x00ffff,
   }, make_tree(root)))
end

function debugger.enable(cell)
   ui.below(cell, "context"):set("debugger")
   local column = ui.above(cell, "column")
   column.data.add_cell(column)
   return true
end

return debugger
