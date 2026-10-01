-- Reads source/<jobname>/ and writes LaTeX into the document.
-- The jobname is set with "lualatex -jobname=<folder>", so the
-- folder name decides which source is used.

local batch = {}
local folder = "source/" .. tex.jobname .. "/"

-- read text.txt into a table of lines
local function read_lines()
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

local lines = read_lines()

-- Catcode table -2 prints a string "as is": & % # $ _ { } \ are
-- normal characters, not LaTeX commands.
local function print_raw(s)
  tex.sprint(-2, s)
end

-- the first line of text.txt
function batch.title()
  print_raw(lines[1] or tex.jobname)
end

-- all other lines; an empty line starts a new paragraph
function batch.body()
  for i = 2, #lines do
    if lines[i]:match("^%s*$") then
      tex.sprint("\\par ")
    else
      print_raw(lines[i] .. " ")
    end
  end
  tex.sprint("\\par ")
end

-- every jpg/png in the folder on its own page, sorted by name
function batch.images()
  local names = {}
  for name in lfs.dir(folder) do
    if name:lower():match("%.jpe?g$") or name:lower():match("%.png$") then
      names[#names + 1] = name
    end
  end
  table.sort(names)

  for _, name in ipairs(names) do
    tex.sprint("\\clearpage\\null\\vfill\\begin{center}")
    tex.sprint("\\includegraphics[width=\\textwidth,height=\\textheight,keepaspectratio]{")
    print_raw(folder .. name)
    tex.sprint("}\\end{center}\\vfill")
  end
end

return batch
