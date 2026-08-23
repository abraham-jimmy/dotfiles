return {
  dap = {
    Stopped = { "*", "DiagnosticWarn", "DapStoppedLine" },
    Breakpoint = "B",
    BreakpointCondition = "?",
    BreakpointRejected = { "!", "DiagnosticError" },
    LogPoint = "L",
  },
  diagnostics = {
    error = "E",
    warn = "W",
    info = "I",
    hint = "H",
  },
  git = {
    added = "+",
    changed = "~",
    removed = "_",
  },
}
