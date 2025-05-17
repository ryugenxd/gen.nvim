local M = {}

local  get_current_buffer = function ()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  return {
    filename = filename,
    content = table.concat(lines, "\n"),
  }
end

local function send_to_ai(prompt, file)
  local body = vim.fn.json_encode({
    prompt = prompt,
    file = file,
  })

  local response = vim.fn.system({
    "curl", "-s",
    "-X", "POST",
    "-H", "Content-Type: application/json",
    "--data", body,
    "http://localhost:11434/api" 
  })

  return vim.fn.json_decode(response)
end

M.edit_current_file = function(prompt)
  vim.notify("📤 Mengambil isi file...", vim.log.levels.INFO)

  local file = get_current_buffer()
  vim.notify("🧠 Think...", vim.log.levels.INFO)

  local result = send_to_ai(prompt, file)

  if result and result.content then
    local new_lines = vim.split(result.content, "\n")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
    vim.notify("✅ Perubahan berhasil diterapkan!", vim.log.levels.INFO)
  else
    vim.notify("❌ AI tidak memberikan hasil", vim.log.levels.ERROR)
  end
end

return M
