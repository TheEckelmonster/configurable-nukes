local cn_rocket_dashboard_styles =
{
    ["cn_rocket_dashboard_table"] =
    {
        type = "table_style",
        margin = 2,
        column_widths =
        {
            { column = 4, minimal_width = 48 },
        },
        column_alignments =
        {
            { column = 1, alignment = "center" },
            { column = 2, alignment = "center" },
            { column = 3, alignment = "center" },
            { column = 4, alignment = "center" },
            { column = 5, alignment = "center" },
        }
    }
}

for k, v in pairs(cn_rocket_dashboard_styles) do
    data.raw["gui-style"]["default"][k] = v
end