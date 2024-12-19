local events = require "luasnip.util.events"

local M = {}

M.callbacks = {

    [-1] = {
        [events.pre_expand] = function(_, event_args)
            local pos = event_args.expand_pos

            return {
                env_override = {
                    POS = pos,
                }
            }
        end,
    },
}

return M
