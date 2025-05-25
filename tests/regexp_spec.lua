local Config = require("tmux-file-jump.config")

describe("Regex pattern tests with ripgrep", function()
  Config.setup()
  local regex = Config.options.regex

  -- Define test cases (expected valid paths)
  local valid_cases = {
    "foo.js:13",
    "foo.js:13:7",
    "foo.test.js:13:7",
    "foo/bar.js:34:3",
    "foo/bar.test.js:99",
    "src/utils/helper.ts:12",
    "src/.dotfile:23:3",
    "baz/qux.spec.jsx:23:7",
    "nested/path.to.file.py:56:18",
    "good/path.file.ext:123:45",
    "good/path-file.ext:123:45",
    "some/file.name.with.many.dots.cpp:200:10",
    "src/components/shared/test-sadf.test.js:56:3",
  }

  -- Define invalid test cases (should NOT match)
  local invalid_cases = {
    "foo.js", -- No line number
    "not/a/path.txt", -- No line number
    "missing/line/number.js", -- No line number
    "invalid/path:34a", -- Invalid line number
    "invalid/path:34a:12", -- Invalid line number
    "random_text_without_path", -- No file path format
  }

  it("should match valid file paths using ripgrep", function()
    for _, test_case in ipairs(valid_cases) do
      local command = "echo " .. vim.fn.shellescape(test_case) .. " | rg -o '" .. regex .. "'"
      local result = vim.fn.system(command):gsub("%s+", "") -- Remove any trailing whitespace
      assert.is_not_nil(result, "Ripgrep did not match expected pattern: " .. test_case)
      assert.are.equal(test_case, result, "Extracted string does not match original: " .. test_case)
    end
  end)

  it("should not match invalid file paths using ripgrep", function()
    for _, test_case in ipairs(invalid_cases) do
      local command = "echo " .. vim.fn.shellescape(test_case) .. " | rg -o '" .. regex .. "'"
      local result = vim.fn.system(command):gsub("%s+", "")
      result = (result ~= "" and result) or nil
      assert.is_nil(result, "Ripgrep incorrectly matched invalid input: " .. test_case)
    end
  end)
end)

