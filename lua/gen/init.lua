local M = {}

local get_current_buffer = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  return {
    filename = filename ~= "" and filename or "untitled",
    content = table.concat(lines, "\n"),
  }
end

local function send_to_ai(prompt, file)
  local full_prompt = string.format([[
### File: %s

%s

### Instruction:
%s

### Response:
]], file.filename, file.content, prompt)

  local body = vim.fn.json_encode({
    model = "codellama:7b",
    prompt = full_prompt,
    stream = false
  })

  local response = vim.fn.system({
    "curl", "-s",
    "-X", "POST",
    "-H", "Content-Type: application/json",
    "--data", body,
    "http://localhost:11434/api/generate"
  })

  if response == "" then
    vim.notify("❌ Tidak ada respon dari model", vim.log.levels.ERROR)
    return nil
  end

  local ok, result = pcall(vim.fn.json_decode, response)
  if not ok or not result.response then
    vim.notify("❌ Gagal decode respon: " .. response, vim.log.levels.ERROR)
    return nil
  end

  return {
    content = result.response
  }
end

M.edit_current_file = function(prompt)
  vim.notify("📤 Mengambil isi file...", vim.log.levels.INFO)

  local file = get_current_buffer()
  vim.notify("🧠 Memproses...", vim.log.levels.INFO)

  local result = send_to_ai(prompt, file)

  if result and result.content then
    local new_lines = vim.split(result.content, "\n")
    vim.api.nvim_buf_set_lines(0, 0, -1, false, new_lines)
    vim.notify("✅ Perubahan berhasil diterapkan!", vim.log.levels.INFO)
  else
    vim.notify("❌ Model tidak memberikan hasil", vim.log.levels.ERROR)
  end
end

return M

