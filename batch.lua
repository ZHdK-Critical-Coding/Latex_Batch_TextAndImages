-- Reads all folders in source/ and writes LaTeX into the document.
-- The layout of title, text and images is defined in template.tex
-- (\itemtitle, \itemimage); this file only supplies the content.

local batch = {}
local source = "source/"

-- Catcode table -2 prints a string "as is": & % # $ _ { } \ are
-- normal characters, not LaTeX commands.
local function print_raw(s)
  tex.sprint(-2, s)
end

-- names in a folder that match a test, sorted alphabetically
local function list(folder, test)
  local names = {}
  for name in lfs.dir(folder) do
    if name:sub(1, 1) ~= "." and test(folder .. name, name) then
      names[#names + 1] = name
    end
  end
  table.sort(names)
  return names
end

local function is_folder(path)
  return lfs.attributes(path, "mode") == "directory"
end

local function is_image(_, name)
  name = name:lower()
  return name:match("%.jpe?g$") or name:match("%.png$")
end

-- text.txt as a table of lines
local function read_lines(folder)
  local lines = {}
  local file = io.open(folder .. "text.txt", "r")
  if not file then
    tex.error("batch.lua: " .. folder .. "text.txt not found")
    return lines
  end
  for line in file:lines() do
    lines[#lines + 1] = line:gsub("\r$", "")
  end
  file:close()
  return lines
end

-- one folder: title, text (an empty line starts a new paragraph), images
local function item(name)
  local folder = source .. name .. "/"
  local lines = read_lines(folder)

  tex.sprint("\\clearpage\\itemtitle{")
  print_raw(lines[1] or name)
  tex.sprint("}")

  for i = 2, #lines do
    if lines[i]:match("^%s*$") then
      tex.sprint("\\par ")
    else
      print_raw(lines[i] .. " ")
    end
  end
  tex.sprint("\\par ")

  for _, image in ipairs(list(folder, is_image)) do
    tex.sprint("\\itemimage{")
    print_raw(folder .. image)
    tex.sprint("}")
  end
end

-- every folder in source/, sorted by name
function batch.items()
  for _, name in ipairs(list(source, is_folder)) do
    item(name)
  end
end

return batch
