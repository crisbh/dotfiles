-- Breadcrumbs in the winbar (path > class > function), clickable and pickable
return {
  "Bekaboo/dropbar.nvim",
  event = { "BufReadPost", "BufNewFile" },
  keys = {
    {
      "<leader>;",
      function()
        require("dropbar.api").pick()
      end,
      desc = "Pick breadcrumb",
    },
  },
}
