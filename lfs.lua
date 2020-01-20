-- fake lfs

return {
    dir = function(dirname)
        local files = {
            "spreadsheet.lua",
        }
        return function()
            local f = files[#files]
            files[#files]=nil
            return f
        end
    end,
}

